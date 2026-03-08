#!/bin/bash

# source other dotfiles
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra,inputrc}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# leave bashrc for any OS-specific stuff, i guess?
#[[ -f ~/.bashrc ]] && . ~/.bashrc

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


DEFAULT_GIT_REMOTE=origin

[[ -f ~/.private ]] && . ~/.private

#
# ~/.bash_profile
#
function just_git_branch {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    echo "${ref#refs/heads/}"
}

function parse_git_branch {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    echo " ("${ref#refs/heads/}") "
}

function print_symlink {
    wd="$(pwd)"
    linkdir="$(readlink -n $wd)";
    if readlink -n $wd >/dev/null;
    then
        echo " -> $linkdir ";
    fi
}

# switch to the nvm version defined by .nvmrc
enter_directory() {
if [[ $PWD == $PREV_PWD ]]; then
    return
fi
PREV_PWD=$PWD
if [[ -f ".nvmrc" ]]; then
    nvm use
    NVM_DIRTY=true
elif [[ $NVM_DIRTY = true ]]; then
    nvm use default
    NVM_DIRTY=false
fi
}
export PROMPT_COMMAND="enter_directory; ${PROMPT_COMMAND}"

# https://timingapp.com/help/terminal
PROMPT_TITLE='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\007"'
export PROMPT_COMMAND="${PROMPT_TITLE}; ${PROMPT_COMMAND}"

export PS1='\h \[\e[0;32m\] \W\[\e[0;36m\]$(print_symlink)\[\e[0;31m\]$(parse_git_branch)\[\e[0m\] $ '

export PATH=$PATH:~/.dotfiles/bin
export PATH=~/bin:~/scripts/:~/private-scripts:$PATH
export PATH=/usr/local/bin:/usr/local/sbin:$PATH

# make sure DOTFILES_OS and DOTFILES_PROFILE are set.
[[ -f ~/.dotfiles_env ]] && . ~/.dotfiles_env


if which brew &> /dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
    # Ensure existing Homebrew v1 completions continue to work
    export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d";
    source "$(brew --prefix)/etc/profile.d/bash_completion.sh";
elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion;
fi;

# default settings that may get overriden by profiles...
export CONDA_HOME=/opt/conda

#
# OS-specific settings
#
if [ "$DOTFILES_OS" == "macos" ]
then

    export PATH=$PATH:/Applications/Araxis\ Merge.app/Contents/Utilities
    # export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

[ -f /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash ] && . /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash
    
    [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
    ## ignore this conditional and just assume im using bash?
    #if [ -f $(brew --prefix)/etc/bash_completion ]; then
    #fi

    # macvim loading stuff:
    # - https://github.com/altercation/solarized/issues/60
    # alias vim=/Applications/MacVim.app/Contents/MacOS/Vim

fi

# Go
export GOROOT="/usr/local/go"
export GOPATH="$HOME/go"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"


# Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then source "$HOME/google-cloud-sdk/path.bash.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]; then source "$HOME/google-cloud-sdk/completion.bash.inc"; fi


#############################
# CONDA
#############################
if [ -d $CONDA_HOME/miniconda3 ]; then
    export PATH="/opt/conda/miniconda3/bin:$PATH"
fi
if [ -d $CONDA_HOME/miniconda2 ]; then
    export PATH="/opt/conda/miniconda2/bin:$PATH"
fi

# nvm setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# for installing node-gyp / node-sass
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:/usr/local/opt/libffi/lib/pkgconfig"


eval "$(direnv hook bash)"


[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh


