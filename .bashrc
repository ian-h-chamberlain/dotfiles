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

# add bash completions
if [ -r $HOME/.bashrc.completions ]; then
    source $HOME/.bashrc.completions
fi

YEL='\[\e[3;93m\]'
BLU='\[\e[0;36m\]'
GRE='\[\e[0;32m\]'
RED='\[\e[0;31m\]'
MAG='\[\e[0;35m\]'
ENDCOL='\[\e[0m\]'
SUCCESS='$(if [ $? -eq 0 ]; then printf "'"$GRE"'"; else printf "'"$RED"'"; fi)'

if declare -F __git_ps1 >/dev/null; then
    PROMPT_COMMAND='__git_ps1'
    PROMPT_COMMAND+=' "${MAG}${DOCKER_NAME:+(${DOCKER_NAME}) }${ENDCOL}[\u@\h] ${BLU}\W${ENDCOL} "'
    PROMPT_COMMAND+=' "\n${SUCCESS}\$${ENDCOL} "'
    PROMPT_COMMAND+=' "${YEL}(%s)${ENDCOL}"'
    export PROMPT_COMMAND
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