# Dotfiles

My macOS setup, managed with [GNU Stow](https://www.gnu.org/software/stow/). Covers shell, git, editor config, and app preferences. Bootstrapped with a single script.

## What's managed

| File | Purpose |
|------|---------|
| `.zshrc` | Shell config — oh-my-zsh, plugins, PATH, lazy-loads |
| `.aliases` | Aliases and shell functions |
| `.gitconfig` | Git identity, aliases, color |
| `.gitignore` | Global gitignore |
| `.p10k.zsh` | Powerlevel10k prompt config |
| `.ruby-version` | rbenv default Ruby version |
| `.mackup.cfg` | Mackup storage config (Dropbox) |
| `.config/direnv/direnvrc` | direnv `layout uv` hook for Python projects |
| `.claude/settings.json` | Claude Code permissions and hooks |

Zsh plugins (zsh-autosuggestions, zsh-syntax-highlighting, powerlevel10k) are tracked as git submodules in `plugins/` and `themes/`.

App preferences are synced via [mackup](https://github.com/lra/mackup) to Dropbox.

## Fresh macOS setup

### 1. Before you wipe

- Push any uncommitted work
- Run `update_all` one last time (backs up Brewfile + mackup)
- Confirm Dropbox is fully synced

### 2. Install macOS cleanly

Boot to Recovery Mode, erase the disk, reinstall macOS. On first boot:

```zsh
xcode-select --install
```

### 3. Restore dotfiles

```zsh
# Copy SSH keys to ~/.ssh and set permissions
chmod 600 ~/.ssh/id_*

# Clone dotfiles
git clone https://github.com/alecfwilson/dotfiles ~/.dotfiles

# Run the install script
~/.dotfiles/install.sh
```

`install.sh` handles: Homebrew, Brewfile, oh-my-zsh, stow symlinks, git submodules, rbenv, nvm, Dropbox ignore rules, default shell.

### 4. Restore app preferences

Wait for Dropbox to finish syncing, then:

```zsh
mackup restore
```

### 5. Finish up

```zsh
source ~/.zshrc   # or open a new terminal
```

Run `.macos` to apply system defaults (optional — review it first):

```zsh
~/.dotfiles/.macos
```

## Day-to-day

### Updating everything

```zsh
update_all
```

Runs: brew update/upgrade, oh-my-zsh update, plugin pulls, mas upgrade, gem cleanup, uv cache clean, yarn cache clean, Brewfile dump, mackup backup, trash empty.

### Python (uv)

```zsh
uv init my-project       # new project
uv add pandas numpy      # add dependencies
uv run script.py         # run without activating venv
uv tool install ruff     # global CLI tools (replaces pipx)
uv python install 3.12   # install a Python version
```

In any project directory, drop a `.envrc` with `layout uv` and direnv handles venv creation/activation automatically on `cd`.

### Node (nvm)

nvm is lazy-loaded — first call to `node`, `npm`, or `nvm` triggers initialization.

```zsh
nvm install --lts
nvm use 22
```

### Ruby (rbenv)

rbenv is lazy-loaded. Default version is set in `.ruby-version`.

```zsh
rbenv install 3.3.7
rbenv global 3.3.7
```

### Syncing dotfile changes

```zsh
dotfilepush   # stages home/, commits, pushes
```

### Adding a new app preference to mackup

1. Check if mackup supports the app: `mackup --help` or [the app list](https://github.com/lra/mackup/tree/master/mackup/applications)
2. Run `mackup backup` (or let `update_all` do it)
