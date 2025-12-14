#!/usr/bin/env bash
set -eu

# Setup script for personal HPC configurations
GIT_REPO="Justype/personal_hpc_setup"
GIT_URL_BASE="https://raw.githubusercontent.com/$GIT_REPO/main"
HOME_TXT_URL="$GIT_URL_BASE/metadata/home.txt"
HOME=test_home  # DEBUG: set to test directory

DRY_RUN=0

usage() {
	cat <<EOF
Usage: $(basename "$0") [-n|--dry-run]
	-n, --dry-run   Show actions without making changes
EOF
	exit 1
}

while [[ ${1:-} != "" ]]; do
	case "$1" in
		-n|--dry-run)
			DRY_RUN=1
			shift
			;;
		-h|--help)
			usage
			;;
		*)
			echo "Unknown option: $1"
			usage
			;;
	esac
done

HOME_CONTENT="$(curl -fsSL "$HOME_TXT_URL")"
if [[ -z "$HOME_CONTENT" ]]; then
    echo "Error: Failed to fetch home.txt from $HOME_TXT_URL"
    exit 1
fi

# region Home
# sync files listed in home.txt
# line example: home/bin/rc
while IFS= read -r line; do
    rel_path="${line#home/}" # remove home/ prefix
    local_path="$HOME/$rel_path"
    remote_url="$GIT_URL_BASE/$line"

    if [[ -f "$local_path" ]]; then
        if [[ $DRY_RUN -eq 0 ]]; then
            echo "Updating file: $local_path from $remote_url"
            curl -fsSL "$remote_url" -o "$local_path".tmp && mv "$local_path".tmp "$local_path"
            echo ${rel_path}
            if [[ $rel_path == bin/* ]]; then
                chmod +x "$local_path"
            fi
        else
            echo "[Dry Run] Would fetch $remote_url and overwrite $local_path"
        fi
    elif [[ $DRY_RUN -eq 0 ]]; then
        echo "Downloading new file: $local_path from $remote_url"
        mkdir -p "$(dirname "$local_path")"
        curl -fsSL "$remote_url" -o "$local_path".tmp && mv "$local_path".tmp "$local_path"
        if [[ $rel_path == bin/* ]]; then
            chmod +x "$local_path"
        fi
    else
        echo "[Dry Run] Would download new file: $local_path from $remote_url"
    fi
done <<< "$HOME_CONTENT"

# Shell Config
if ! grep -q ".shellrc" "$HOME/.bashrc"; then
    if [[ $DRY_RUN -eq 0 ]]; then
        echo "Appending shell configuration to $HOME/.bashrc"
        cat << 'EOF' >> "$HOME/.bashrc"
# Source personal shell configuration
if [ -f "$HOME/.shellrc" ]; then
    source "$HOME/.shellrc"
fi
EOF
    else
        echo "[Dry Run] Would append shell configuration to $HOME/.bashrc"
    fi
fi
# endregion

# region Tools
if ! [[ -f $HOME/.local/share/nvim/site/autoload/plug.vim ]]; then
    if [[ $DRY_RUN -eq 0 ]]; then
        echo "Installing vim-plug for Neovim..."
        curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    else
        echo "[Dry Run] Would install vim-plug for Neovim at $HOME/.local/share/nvim/site/autoload/plug.vim"
    fi
fi

if ! command -v bat &> /dev/null; then
    if [[ $DRY_RUN -eq 0 ]]; then
        BAT_URL="https://github.com/sharkdp/bat/releases/download/v0.26.0/bat-v0.26.0-$(uname -m)-unknown-linux-musl.tar.gz"
        BAT_TAR="$HOME/bat.tar.gz"
        echo "Downloading bat from $BAT_URL"
        curl -L "$BAT_URL" -o "$BAT_TAR"
        tar -xzf "$BAT_TAR" -C "$HOME/bin" --strip-components=1 --wildcards "bat*/bat"
        rm "$BAT_TAR"
    else
        echo "[Dry Run] Would download and install bat to $HOME/bin"
    fi
fi

if ! command -v zoxide &> /dev/null; then
    if [[ $DRY_RUN -eq 0 ]]; then
        ZOXIDE_URL="https://github.com/ajeetdsouza/zoxide/releases/download/v0.9.8/zoxide-0.9.8-$(uname -m)-unknown-linux-musl.tar.gz"
        ZOXIDE_TAR="$HOME/zoxide.tar.gz"
        echo "Downloading zoxide from $ZOXIDE_URL"
        curl -L "$ZOXIDE_URL" -o "$ZOXIDE_TAR"
        tar -xzf "$ZOXIDE_TAR" -C "$HOME/bin" zoxide
        rm "$ZOXIDE_TAR"
    else
        echo "[Dry Run] Would download and install zoxide to $HOME/bin"
    fi
fi

if ! command -v rclone &> /dev/null; then
    if [[ $DRY_RUN -eq 0 ]]; then
        if uname -m | grep -q 'x86_64'; then
            ARCH='amd64'
        elif uname -m | grep -q 'aarch64'; then
            ARCH='arm64'
        fi
        if [[ -n "$ARCH" ]]; then
            RCLONE_URL="https://downloads.rclone.org/rclone-current-linux-$ARCH.zip"
            RCLONE_ZIP="$HOME/rclone.zip"
            echo "Downloading rclone from $RCLONE_URL"
            curl -L "$RCLONE_URL" -o "$RCLONE_ZIP"
            folder_name=$(unzip -l "$RCLONE_ZIP" | head -n 4 | tail -n 1 | awk '{print $4}' | cut -d'/' -f1)
            unzip -o "$RCLONE_ZIP" -d "$HOME"
            mv "$HOME/$folder_name/rclone" "$HOME/bin/rclone"
            rm -r "$HOME/$folder_name"
            rm "$RCLONE_ZIP"
        else
            echo "Unsupported architecture for rclone installation."
        fi
    else
        echo "[Dry Run] Would download and install rclone to $HOME/bin"
    fi
fi
# endregion
