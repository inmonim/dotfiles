#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Starting Dotfiles Installation..."

# Define directories
DOTFILES_DIR="$HOME/dotfiles"
OMZ_DIR="$HOME/.oh-my-zsh"

# 1. Detect OS and Install System Packages
if [ -f /etc/debian_version ]; then
    echo "📦 Debian/Ubuntu detected. Installing dependencies via apt..."
    sudo apt update
    sudo apt install -y zsh curl git tmux htop bat zoxide
    
    # Setup bat symlink if batcat is installed
    if command -v batcat >/dev/null 2>&1 && [ ! -f "$HOME/.local/bin/bat" ]; then
        mkdir -p "$HOME/.local/bin"
        ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
    fi
elif [ "$(uname)" = "Darwin" ]; then
    echo "📦 macOS detected. Checking for Homebrew..."
    if ! command -v brew >/dev/null 2>&1; then
        echo "⚠️ Homebrew not found. Please install it first: https://brew.sh/"
        exit 1
    fi
    echo "Installing dependencies via brew..."
    brew install zsh git tmux htop bat eza zoxide fzf starship
else
    echo "⚠️ Unsupported OS. Please install zsh, git, tmux, htop, bat, eza, zoxide, fzf, starship manually."
fi

# 2. Install Starship (Linux only, since macOS brew handles it)
if [ "$(uname)" != "Darwin" ]; then
    if ! command -v starship >/dev/null 2>&1; then
        echo "⭐ Installing Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
fi

# 3. Install Oh My Zsh
if [ ! -d "$OMZ_DIR" ]; then
    echo "🐚 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "✅ Oh My Zsh is already installed."
fi

# 4. Install Oh My Zsh Plugins
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$OMZ_DIR/custom}"
mkdir -p "$ZSH_CUSTOM_DIR/plugins"

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ]; then
    echo "🔌 Cloning zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]; then
    echo "🔌 Cloning zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
fi

# 5. Create Symlinks
echo "🔗 Creating symlinks..."

# Backup function
backup_and_link() {
    local src="$1"
    local dest="$2"
    if [ -f "$dest" ] && [ ! -L "$dest" ]; then
        echo "💾 Backing up existing $dest to ${dest}.backup"
        mv "$dest" "${dest}.backup"
    fi
    ln -sf "$src" "$dest"
}

# Link Zsh config
backup_and_link "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"

# Link Tmux config
backup_and_link "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"

# Link Starship config
mkdir -p "$HOME/.config"
backup_and_link "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"

echo "✨ Installation complete!"
echo "👉 Run the following command to switch your shell to zsh:"
echo "   chsh -s \$(which zsh)"
echo "👉 Then restart your terminal or run: source ~/.zshrc"
