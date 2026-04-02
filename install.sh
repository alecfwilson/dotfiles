#!/bin/zsh

# Guard: must be run from inside the cloned dotfiles repo
if [[ ! -d "$HOME/.dotfiles" ]]; then
  echo "Error: ~/.dotfiles not found. Clone the repo first:"
  echo "  git clone https://github.com/alecfwilson/dotfiles ~/.dotfiles"
  exit 1
fi

echo "Setting up your Mac..."

# Install Homebrew if missing
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add Homebrew to PATH for Apple Silicon (needed immediately in this script)
if [[ $(uname -m) == "arm64" ]] && [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install all dependencies from Brewfile
brew update
brew bundle --file="$HOME/.dotfiles/Brewfile"

# Install oh-my-zsh if missing
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Remove any default files that would block stow, then symlink dotfiles
for file in home/.*; do
  target="$HOME/$(basename $file)"
  [[ -f "$target" && ! -L "$target" ]] && rm "$target"
done
cd "$HOME/.dotfiles"
stow --no-folding home

# Initialize zsh plugin submodules
git submodule update --init

# Install Ruby via rbenv (version read from ~/.ruby-version)
rbenv install --skip-existing
rbenv global "$(cat "$HOME/.ruby-version")"

# Install Node LTS via nvm
if [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
  # nvm not found — install via official script (check https://github.com/nvm-sh/nvm for latest version)
  PROFILE=/dev/null curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default lts/*

# Create .dropboxignore in all Dropbox locations if present
for DROPBOX in "$HOME/Dropbox" "$HOME/Library/CloudStorage/Dropbox"; do
  if [[ -d "$DROPBOX" ]] && [[ ! -f "$DROPBOX/.dropboxignore" ]]; then
    cat > "$DROPBOX/.dropboxignore" <<'EOF'
.DS_Store
._*
Thumbs.db
Desktop.ini
EOF
  fi
done

# Set default shell to zsh if not already
if [[ "$SHELL" != "$(which zsh)" ]]; then
  chsh -s "$(which zsh)"
fi

echo ""
echo "Done. Next steps:"
echo "  1. source ~/.zshrc (or open a new terminal)"
echo "  2. mackup restore  (after confirming Dropbox is synced)"
echo "  3. For Python projects: add 'layout uv' to .envrc in project dirs"
