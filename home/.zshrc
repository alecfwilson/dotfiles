# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export DOTFILES=$HOME/.dotfiles
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_CUSTOM=$DOTFILES

export UPDATE_ZSH_DAYS=7
ENABLE_CORRECTION="true"
HIST_STAMPS="yyyy-mm-dd"
# DISABLE_UNTRACKED_FILES_DIRTY="true"  # uncomment for faster git status in large repos

plugins=(
	git
	history-substring-search
	last-working-dir
	macos
	python
	sublime
	tmux
	vi-mode
	vscode
	zoxide
	zsh-autosuggestions
	zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh
source ~/.aliases

export DEFAULT_GIT_REMOTE=origin

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export EDITOR='vim'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Google Cloud SDK completion (binary in PATH via Homebrew)
if [ -f "$HOMEBREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc" ]; then
  . "$HOMEBREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"
fi

# pyenv — shims added first, then pushed back by Homebrew below
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Homebrew takes priority over pyenv so that python3 resolves to Homebrew's python
export PATH=/opt/homebrew/bin:$PATH

# Lazy-load rbenv: shims go in front of Homebrew so ruby/gem/bundle use rbenv
export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
_rbenv_load() {
  unset -f rbenv
  eval "$(rbenv init - --no-rehash)"
}
rbenv() { _rbenv_load && rbenv "$@" }

# Lazy-load nvm: defer the ~500ms source until first use
export NVM_DIR="$HOME/.nvm"
_nvm_load() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
}
nvm()  { _nvm_load && nvm  "$@" }
node() { _nvm_load && node "$@" }
npm()  { _nvm_load && npm  "$@" }
npx()  { _nvm_load && npx  "$@" }

export PATH="$HOME/.local/bin:$PATH"

eval "$(direnv hook zsh)"

# vi-mode: reduce Esc delay from 400ms to ~10ms
KEYTIMEOUT=1

# history-substring-search keybindings (up/down arrows, both insert and normal mode)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd '^[[A' history-substring-search-up
bindkey -M vicmd '^[[B' history-substring-search-down
