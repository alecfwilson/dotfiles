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

# Configure Rectangle with Spectacle-compatible shortcuts
if [[ -d /Applications/Rectangle.app ]]; then
  python3 << 'PYEOF'
import subprocess

CMD, OPT, CTRL, SHIFT = 1048576, 524288, 262144, 131072
LEFT, RIGHT, DOWN, UP = 123, 124, 125, 126
F_KEY, C_KEY, Z_KEY, D_KEY, G_KEY, E_KEY, T_KEY, RETURN_KEY = 3, 8, 6, 2, 5, 14, 17, 36

shortcuts = {
    # Spectacle shortcuts
    'leftHalf':        (LEFT,       OPT|CMD),
    'rightHalf':       (RIGHT,      OPT|CMD),
    'topHalf':         (UP,         OPT|CMD),
    'bottomHalf':      (DOWN,       OPT|CMD),
    'center':          (C_KEY,      OPT|CMD),
    'maximize':        (F_KEY,      CTRL|OPT|CMD),
    'topLeft':         (LEFT,       CTRL|CMD),
    'topRight':        (RIGHT,      CTRL|CMD),
    'bottomLeft':      (LEFT,       CTRL|SHIFT|CMD),
    'bottomRight':     (RIGHT,      CTRL|SHIFT|CMD),
    'nextDisplay':     (RIGHT,      CTRL|OPT|CMD),
    'previousDisplay': (LEFT,       CTRL|OPT|CMD),
    'larger':          (RIGHT,      CTRL|OPT|SHIFT),
    'smaller':         (LEFT,       CTRL|OPT|SHIFT),
    'nextThird':       (RIGHT,      CTRL|OPT),
    'previousThird':   (LEFT,       CTRL|OPT),
    'undo':            (Z_KEY,      OPT|CMD),
    'redo':            (Z_KEY,      OPT|SHIFT|CMD),
    # Rectangle defaults for actions not in Spectacle
    'almostMaximize':  (RETURN_KEY, CTRL|OPT|SHIFT),
    'maximizeHeight':  (UP,         CTRL|OPT|SHIFT),
    'firstThird':      (D_KEY,      CTRL|OPT),
    'centerThird':     (F_KEY,      CTRL|OPT),
    'lastThird':       (G_KEY,      CTRL|OPT),
    'firstTwoThirds':  (E_KEY,      CTRL|OPT),
    'lastTwoThirds':   (T_KEY,      CTRL|OPT),
}

for action, (keycode, modifiers) in shortcuts.items():
    subprocess.run([
        'defaults', 'write', 'com.knollsoft.Rectangle', action,
        '-dict', 'keyCode', '-int', str(keycode), 'modifierFlags', '-int', str(modifiers)
    ], capture_output=True)
print("Rectangle shortcuts configured.")
PYEOF
fi

# Set default shell to zsh if not already
if [[ "$SHELL" != "$(which zsh)" ]]; then
  chsh -s "$(which zsh)"
fi

echo ""
echo "Done. Next steps:"
echo "  1. source ~/.zshrc (or open a new terminal)"
echo "  2. mackup restore  (after confirming Dropbox is synced)"
echo "  3. For Python projects: add 'layout uv' to .envrc in project dirs"
