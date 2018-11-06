os_name = "$(uname)"
if [[ $os_name == "Darwin" ]]; then
    MAC_OS = true
else
    MAC_OS = false
fi

# alias various commands
if [ -f $HOME/.bashrc.aliases ]; then
    source $HOME/.bashrc.aliases
fi

# git-completion
if [ -f $HOME/bin/git-completion.bash ]; then
    source $HOME/bin/git-completion.bash
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

if [ MAC_OS = true ]; then
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

eval "$(thefuck --alias f)"

export PYENV_VIRTUALENV_DISABLE_PROMPT=1

if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
eval "$(pyenv virtualenv-init -)"

export PATH="$HOME/.cargo/bin:$PATH"
