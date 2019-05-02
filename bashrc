os_name="$(uname)"
if [[ $os_name == "Darwin" ]]; then
    MAC_OS=true
else
    MAC_OS=false
fi

# alias various commands
if [ -f $HOME/.bashrc.aliases ]; then
    source $HOME/.bashrc.aliases
fi

# git-completion
if [ -f $HOME/bin/git-completion.bash ]; then
    source $HOME/bin/git-completion.bash
fi

# bazel completion
if [ -f $HOME/bin/bazel-complete.bash ]; then
    source $HOME/bin/bazel-complete.bash
elif [ -f /usr/share/bash-completion/completions/bazel ]; then
    source /usr/share/bash-completion/completions/bazel
fi

# General completions from brew
if [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]]; then 
    . "/usr/local/etc/profile.d/bash_completion.sh"
fi


YEL='\[\e[3;93m\]'
BLU='\[\e[0;36m\]'
GRE='\[\e[0;32m\]'
RED='\[\e[0;31m\]'
MAG='\[\e[0;35m\]'
ENDCOL='\[\e[0m\]'
SUCCESS='$(if [ $? -eq 0 ]; then echo "'"$GRE"'"; else echo "'"$RED"'"; fi)'

# setup prompt with git repo support
if [ -f $HOME/bin/git-prompt.sh ]; then
    source $HOME/bin/git-prompt.sh
    PS1="${MAG}${DOCKER_NAME:+(${DOCKER_NAME}) }${ENDCOL}[\u@\h] ${BLU}\W${ENDCOL} \$(__git_ps1 \"${YEL}(%s)${ENDCOL}\")\n${SUCCESS}\$${ENDCOL} "
fi

# grep colors
export GREP_OPTIONS="--color=auto"

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

if [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
