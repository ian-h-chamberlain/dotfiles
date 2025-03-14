# shellcheck shell=bash
# shellcheck disable=SC1091

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

os_name="$(uname)"
if [[ $os_name == "Darwin" ]]; then
    MAC_OS=true
else
    MAC_OS=false
fi

if [[ "$(uname -o)" = Msys ]]; then
    # Make symlinks work more how you'd expect
    export MSYS=winsymlinks:nativestrict
fi

umask 0002

# alias various commands
if [ -r "$HOME/.bashrc.aliases" ]; then
    source "$HOME/.bashrc.aliases"
fi

# add bash completions
if [ -r "$HOME/.bashrc.completions" ]; then
    source "$HOME/.bashrc.completions"
fi

# "$(tput sitm)" is probably safest here, but actually it seems easier to just
# not use italics at all, because terminfo is annoying to setup if they're not
# already supported
YEL='\[\e[93m\]'
BLU='\[\e[0;36m\]'
GRE='\[\e[0;32m\]'
RED='\[\e[0;31m\]'
MAG='\[\e[0;35m\]'
ENDCOL='\[\e[0m\]'
# shellcheck disable=SC2016
SUCCESS='$(if [ $? -eq 0 ]; then printf "'"$GRE"'"; else printf "'"$RED"'"; fi)'

if declare -F __git_ps1 >/dev/null; then
    PROMPT_COMMAND='__git_ps1'
    PROMPT_COMMAND+=' "${MAG}${DOCKER_NAME:+(${DOCKER_NAME}) }${ENDCOL}[\u@\h] ${BLU}\W${ENDCOL} "'
    PROMPT_COMMAND+=' "\n${SUCCESS}\$${ENDCOL} "'
    # shellcheck disable=SC2089
    PROMPT_COMMAND+=' "${YEL}(%s)${ENDCOL}"'
    # shellcheck disable=SC2090
    export PROMPT_COMMAND
else
    export PS1="${MAG}${DOCKER_NAME:+(${DOCKER_NAME}) }${ENDCOL}[\u@\h] ${BLU}\W${ENDCOL}\n${SUCCESS}\$${ENDCOL} "
fi

if [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

export PATH="/usr/local/opt/node@8/bin:$PATH"

# Explicit XDG dirs for Windows (i.e. gitbash)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# `history` timestamp in output
export HISTTIMEFORMAT="%F %T "

# https://stackoverflow.com/a/39352670
export LESS=Rx4

if [ "$MAC_OS" = true ]; then
    # (macOS) set up LS colors
    export CLICOLOR=1
    dir=Gx          # bold cyan/default
    symlink=Fx      # bold magenta/default
    sock=Cx         # bold green/default
    pipe=Dx         # bold yellow/default
    exe=Bx          # bold red/default
    block=eg        # blue/cyan
    char="ed"       # blue/yellow
    setuid=ab       # black/red
    setguid=ag      # black/cyan
    sticky=ac       # black/green
    nostick="ed"    # blue/yellow

    export LSCOLORS=$dir$symlink$sock$pipe$exe$block$char$setuid$setguid$sticky$nostick
fi

export LNAV_EXP="mouse"
export EDITOR="vim"
export SUDO_EDITOR="vim"
export PYTHONSTARTUP=$HOME/.pythonrc.py

# disable ctrl-s = suspend session
[[ $- == *i* ]] && stty -ixon

if which thefuck &>/dev/null; then
    eval "$(thefuck --alias)"
fi

export PYENV_VIRTUALENV_DISABLE_PROMPT=1

if which pyenv &>/dev/null && [[ "$(uname -o)" != Msys ]]; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [ -f "$HOME/bin/git-completion.bash" ]; then
   source "$HOME/bin/git-completion.bash"
fi

if [ -f "$HOME/bin/git-prompt.sh" ]; then
   source "$HOME/bin/git-prompt.sh"
   PS1=${DOCKER_NAME:+(${DOCKER_NAME})}'[\u@\h \W$(__git_ps1 " (%s)")]\$ '
fi

if test -f "$HOME/.cargo/env"; then
    source "$HOME/.cargo/env"
fi
