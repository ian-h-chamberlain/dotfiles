os_name="$(uname)"
if [[ $os_name == "Darwin" ]]; then
    MAC_OS=true
else
    MAC_OS=false
fi

# alias various commands
if [ -r $HOME/.bashrc.aliases ]; then
    source $HOME/.bashrc.aliases
fi

if which brew &>/dev/null; then
    # homebrew bash-completion@2
    if [ -r $(brew --prefix)/etc/profile.d/bash_completion.sh ]; then
        source $(brew --prefix)/etc/profile.d/bash_completion.sh
    fi

    # git-completion
    if [ -r $(brew --prefix)/etc/bash_completion.d/git-completion.bash ]; then
        source $(brew --prefix)/etc/bash_completion.d/git-completion.bash
    fi

    # bazel completion
    if [ -r $(brew --prefix)/etc/bash_completion.d/bazel-complete.bash ]; then
        source $(brew --prefix)/etc/bash_completion.d/bazel-complete.bash
    fi

    # rustup completion
    if [ -r $(brew --prefix)/etc/bash_completion.d/rustup.bash-completion ]; then
        source $(brew --prefix)/etc/bash_completion.d/rustup.bash-completion
    fi

    # rustup completion
    if [ -r $(brew --prefix)/etc/bash_completion.d/brew ]; then
        source $(brew --prefix)/etc/bash_completion.d/brew
    fi

    # git-prompt
    if [ -r $(brew --prefix)/etc/bash_completion.d/git-prompt.sh ]; then
        source $(brew --prefix)/etc/bash_completion.d/git-prompt.sh
    fi
else
    if [ -r $HOME/bin/git-prompt.sh ]; then
        source $HOME/bin/git-prompt.sh
    fi

    if [ -r $HOME/bin/git-completion.bash ]; then
        source $HOME/bin/git-completion.bash
    fi
fi

YEL='\[\e[3;93m\]'
BLU='\[\e[0;36m\]'
GRE='\[\e[0;32m\]'
RED='\[\e[0;31m\]'
MAG='\[\e[0;35m\]'
ENDCOL='\[\e[0m\]'
SUCCESS='$(if [ $? -eq 0 ]; then printf "'"$GRE"'"; else printf "'"$RED"'"; fi)'

if declare -F __git_ps1 >/dev/null; then
    export PROMPT_COMMAND='__git_ps1 "${MAG}${DOCKER_NAME:+(${DOCKER_NAME}) }${ENDCOL}[\u@\h] ${BLU}\W${ENDCOL}${YEL}" "${ENDCOL}\n${SUCCESS}\$${ENDCOL} "'
else
    export PS1="${MAG}${DOCKER_NAME:+(${DOCKER_NAME}) }${ENDCOL}[\u@\h] ${BLU}\W${ENDCOL}\n${SUCCESS}\$${ENDCOL} "
fi

if [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

export PATH="/usr/local/opt/node@8/bin:$PATH"

# grep colors
export GREP_OPTIONS="--color=auto"

# `history` timestamp in output
export HISTTIMEFORMAT="%F %T "

if [ "$MAC_OS" = true ]; then
    # (macOS) set up LS colors
    export CLICOLOR=1
    dir=Gx      # bold cyan/default
    symlink=Fx  # bold magenta/default
    sock=Cx     # bold green/default
    pipe=Dx     # bold yellow/default
    exe=Bx      # bold red/default
    block=eg    # blue/cyan
    char=ed     # blue/yellow
    setuid=ab   # black/red
    setguid=ag  # black/cyan
    sticky=ac   # black/green
    nostick=ed  # blue/yellow

    export LSCOLORS=$dir$symlink$sock$pipe$exe$block$char$setuid$setguid$sticky$nostick
fi

export LNAV_EXP="mouse"
export EDITOR="vim"
export PYTHONSTARTUP=$HOME/.pythonrc.py

# disable ctrl-s = suspend session
stty -ixon

if which thefuck &>/dev/null; then
    eval "$(thefuck --alias)"
fi

export PYENV_VIRTUALENV_DISABLE_PROMPT=1

if which pyenv &>/dev/null; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
