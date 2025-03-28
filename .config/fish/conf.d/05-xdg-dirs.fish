set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_STATE_HOME $HOME/.local/state
set -gx XDG_CACHE_HOME $HOME/.cache

# Courtesy of xdg-ninja:
set -gx ANDROID_HOME $XDG_DATA_HOME/android
set -gx CCACHE_DIR $XDG_CACHE_HOME/ccache
set -gx DOCKER_CONFIG $XDG_CONFIG_HOME/docker
set -gx GDBHISTFILE $XDG_DATA_HOME/gdb/history
set -gx LESSHISTFILE $XDG_DATA_HOME/less/history
set -gx NODE_REPL_HISTORY $XDG_DATA_HOME/node_repl_history
set -gx PYLINTHOME $XDG_CACHE_HOME/pylint
set -gx RBENV_ROOT $XDG_DATA_HOME/rbenv

export CARGO_HOME="$XDG_CONFIG_HOME"/cargo
export RUSTUP_HOME="$XDG_CONFIG_HOME"/rustup
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc

export BUNDLE_USER_CACHE="$XDG_CACHE_HOME"/bundle
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME"/bundle
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME"/bundle
export SQLITE_HISTORY="$XDG_CACHE_HOME"/sqlite_history
export WINEPREFIX="$XDG_DATA_HOME"/wine

# TODO:
# - GOPATH
# - .npm
# - .pyenv
# - pylint.d
# - tmux
# - vim
# - .gem
# - gnupg
# .nix-profile etc.
# - terminfo (maybe doesn't work on macos)
# - .bash_history
# - .zsh_history
# - .python_history
