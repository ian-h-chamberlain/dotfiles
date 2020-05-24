thefuck --alias f | source

# eval (ssh-agent -c) >/dev/null

status --is-interactive; and pyenv init - | source
status --is-interactive; and pyenv-virtualenv-init - | source

# Set here instead of in fish_variables to expand $HOME per-machine
set -U fish_user_paths (npm bin) ~/.cargo/bin ~/.pyenv/shims /usr/local/Cellar/pyenv-virtualenv/*/shims

