command -q thefuck
    and thefuck --alias f | source

status --is-interactive
    and command -q pyenv
    and pyenv init - | source
status --is-interactive
    and command -q pyenv-virtualenv
    and pyenv-virtualenv-init - | source

# Set here instead of in fish_variables to expand $HOME per-machine
command -q npm
    and set -U fish_user_paths (npm bin)

set -Ua fish_user_paths ~/.cargo/bin ~/.pyenv/shims /usr/local/Cellar/pyenv-virtualenv/*/shims

