# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export TERM=xterm-256color

# Set theme to empty because we use Starship prompt
ZSH_THEME=""

# Enable plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

# --- Aliases & Modern Tools Fallback ---

# eza (ls replacement)
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons"
  alias ll="eza -alF --icons --git"
  alias la="eza -a --icons"
  alias l="eza -l --icons"
elif command -v exa >/dev/null 2>&1; then
  alias ls="exa --icons"
  alias ll="exa -alF --icons --git"
  alias la="exa -a --icons"
  alias l="exa -l --icons"
else
  # Default colorized ls
  if [ "$(uname)" = "Darwin" ]; then
    alias ls="ls -G"
  else
    alias ls="ls --color=auto"
  fi
  alias ll="ls -alF"
  alias la="ls -A"
  alias l="ls -CF"
fi

# bat (cat replacement)
if command -v bat >/dev/null 2>&1; then
  alias cat="bat"
elif command -v batcat >/dev/null 2>&1; then
  # Ubuntu apt packages name it batcat
  alias cat="batcat"
fi

# --- Inits ---

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# starship
if command -v starship >/dev/null 2>&1; then
  export STARSHIP_CONFIG="$HOME/.config/starship.toml"
  eval "$(starship init zsh)"
fi

# fzf
if command -v fzf >/dev/null 2>&1; then
  # Support modern fzf init
  source <(fzf --zsh) 2>/dev/null || source /usr/share/doc/fzf/examples/key-bindings.zsh 2>/dev/null
fi
