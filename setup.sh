#!/usr/bin/env bash
set -eu

# Setup script for personal HPC configurations
GIT_REPO="Justype/personal_hpc_setup"
GIT_URL_BASE="https://raw.githubusercontent.com/$GIT_REPO/main"
HOME_TXT_URL="$GIT_URL_BASE/metadata/home.txt"
# HOME=test_home  # DEBUG: set to test directory

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
get_latest_release() {
    local repo="$1"
    curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r .tag_name
}

if ! [[ -f $HOME/.local/share/nvim/site/autoload/plug.vim ]]; then
    if [[ $DRY_RUN -eq 0 ]]; then
        echo "Installing vim-plug for Neovim..."
        curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    else
        echo "[Dry Run] Would install vim-plug for Neovim at $HOME/.local/share/nvim/site/autoload/plug.vim"
    fi
fi

if ! [ -f "$HOME/.local/bin/bat" ] &> /dev/null; then
    if [[ $DRY_RUN -eq 0 ]]; then
        BAT_VERSION=$(get_latest_release "sharkdp/bat")
        BAT_URL="https://github.com/sharkdp/bat/releases/download/$BAT_VERSION/bat-$BAT_VERSION-$(uname -m)-unknown-linux-musl.tar.gz"
        BAT_TAR="$HOME/bat.tar.gz"
        echo "Downloading bat from $BAT_URL"
        curl -L "$BAT_URL" -o "$BAT_TAR"
        tar -xzf "$BAT_TAR" -C "$HOME/.local/bin" --strip-components=1 --wildcards "bat*/bat"
        rm "$BAT_TAR"
    else
        echo "[Dry Run] Would download and install bat to $HOME/.local/bin"
    fi
fi

if ! [ -f "$HOME/.local/bin/zoxide" ] &> /dev/null; then
    if [[ $DRY_RUN -eq 0 ]]; then
        ZOXIDE_VERSION=$(get_latest_release "ajeetdsouza/zoxide")
        ZOXIDE_URL="https://github.com/ajeetdsouza/zoxide/releases/download/$ZOXIDE_VERSION/zoxide-$ZOXIDE_VERSION-$(uname -m)-unknown-linux-musl.tar.gz"
        ZOXIDE_TAR="$HOME/zoxide.tar.gz"
        echo "Downloading zoxide from $ZOXIDE_URL"
        curl -L "$ZOXIDE_URL" -o "$ZOXIDE_TAR"
        tar -xzf "$ZOXIDE_TAR" -C "$HOME/.local/bin" zoxide
        rm "$ZOXIDE_TAR"
    else
        echo "[Dry Run] Would download and install zoxide to $HOME/.local/bin"
    fi
fi

if ! [ -f "$HOME/.local/bin/rclone" ] &> /dev/null; then
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
            mv "$HOME/$folder_name/rclone" "$HOME/.local/bin/rclone"
            rm -r "$HOME/$folder_name"
            rm "$RCLONE_ZIP"
        else
            echo "Unsupported architecture for rclone installation."
        fi
    else
        echo "[Dry Run] Would download and install rclone to $HOME/.local/bin"
    fi
fi

if ! [ -f "$HOME/.local/bin/fzf" ] &> /dev/null; then
    if [[ $DRY_RUN -eq 0 ]]; then
        echo "Installing fzf..."
        if uname -m | grep -q 'x86_64'; then
            ARCH='amd64'
        elif uname -m | grep -q 'aarch64'; then
            ARCH='arm64'
        fi
        if [[ -n "$ARCH" ]]; then
            FZF_VERSION=$(get_latest_release "junegunn/fzf")
            FZF_URL="https://github.com/junegunn/fzf/releases/download/$FZF_VERSION/fzf-$FZF_VERSION-linux_$ARCH.tar.gz"
            FZF_TAR="$HOME/fzf.tar.gz"
            echo "Downloading fzf from $FZF_URL"
            curl -L "$FZF_URL" -o "$FZF_TAR"
            tar -xzf "$FZF_TAR" -C "$HOME/.local/bin" fzf
            rm "$FZF_TAR"
        else
            echo "Unsupported architecture for fzf installation."
        fi
    else
        echo "[Dry Run] Would download and install fzf to $HOME/.local/bin"
    fi
fi

if ! [ -f "$HOME/.local/bin/yazi" ] &> /dev/null; then
    if [[ $DRY_RUN -eq 0 ]]; then
        echo "Installing yazi..."
        YAZI_VERSION=$(get_latest_release "sxyazi/yazi")
        YAZI_URL="https://github.com/sxyazi/yazi/releases/download/$YAZI_VERSION/yazi-$(uname -m)-unknown-linux-musl.zip"
        YAZI_ZIP="$HOME/yazi.zip"
        echo "Downloading yazi from $YAZI_URL"
        curl -L "$YAZI_URL" -o "$YAZI_ZIP"
        folder_name=$(unzip -l "$YAZI_ZIP" | head -n 4 | tail -n 1 | awk '{print $4}' | cut -d'/' -f1)
        unzip -o "$YAZI_ZIP" -d "$HOME"
        mv "$HOME/$folder_name/yazi" "$HOME/.local/bin/yazi"
        mv "$HOME/$folder_name/ya" "$HOME/.local/bin/ya"
        rm -r "$HOME/$folder_name"
        rm "$YAZI_ZIP"
    else
        echo "[Dry Run] Would download and install yazi to $HOME/.local/bin"
    fi
fi

# endregion
