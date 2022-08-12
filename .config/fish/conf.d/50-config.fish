set -gx GOPATH ~/go

set -gx PYP_CONFIG_PATH ~/.config/pyp.py

set -gx DEVKITPRO /opt/devkitpro
set -gx DEVKITARM $DEVKITPRO/devkitARM

set -gx CARGO_UNSTABLE_SPARSE_REGISTRY true

if not set -gq GPG_TTY
    # Set a proper TTY for gpg commands to work
    set -gx GPG_TTY (tty)
end

# Set jq to show null/true/false as magenta instead of black or otherwise
set -gx JQ_COLORS "1;35:1;35:1;35:0;39:0;32:1;39:1;39"

# Use `bat` as pager if it present
if command -qs bat
    set -gx PAGER bat
    set -gx GIT_PAGER 'bat --plain'

    # macOS `man` suports piping in MANPAGER, but on Linux this needs a
    # wrapper script (see `man man`)
    set -gx MANPAGER 'sh -c "col -bx | bat --plain --language Manpage"'
end

if not set -q DOCKER_NAME; and test -f /etc/profile.d/docker_name.sh
    set -gx DOCKER_NAME (sed -E 's/.*DOCKER_NAME=(.+)/\1/' /etc/profile.d/docker_name.sh)
end

# Kinda silly this can't just be in workspace config, but oh well
set -gx ROBOTFRAMEWORK_LS_WATCH_IMPL fsnotify
set -gx ROBOTFRAMEWORK_LS_IGNORE_DIRS '[
    "**/bazel-*",
    "**/.bazel_out",
    "**/.tox",
    "**/vendor",
    "**/CMakeFiles",
    "**/thirdparty",
    "**/src"
]'

# Set fish_user_paths here instead of fish_variables to expand $HOME per-machine
set -Ux fish_user_paths \
    $DEVKITARM/bin \
    ~/.cargo/bin \
    $GOPATH/bin \
    node_modules/.bin \
    /usr/local/bin \
    /usr/local/sbin

if status is-interactive
    if command -qs thefuck
        thefuck --alias | source
    end

    if command -qs pyenv; and ! set -qg __fish_pyenv_initialized
        pyenv init - | source
        pyenv init --path | source
        pyenv virtualenv-init - fish | source
        set -g __fish_pyenv_initialized

        # Disable extraneous message from pyenv-virtualenv, since we use a
        # custom prompt anyway
        set -gx PYENV_VIRTUALENV_DISABLE_PROMPT 1
    end

    if command -qs rbenv; and ! set -qg __fish_rbenv_initialized
        rbenv init - | source
        set -g __fish_rbenv_initialized
    end

    if test -f .nvmrc
        nvm
    end
end

# Used to ensure Docker cache hits on dev VM
umask 0002
