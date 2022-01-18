set -gx GOPATH ~/go

set -gx PYP_CONFIG_PATH ~/.config/pyp.py

set -gx DEVKITPRO /opt/devkitpro
set -gx DEVKITARM $DEVKITPRO/devkitARM

# Set fish_user_paths here instead of fish_variables to expand $HOME per-machine
set -Ux fish_user_paths \
    $DEVKITARM/bin \
    ~/.cargo/bin \
    $GOPATH/bin \
    node_modules/.bin \
    /usr/local/bin \
    /usr/local/sbin

if not set -gq GPG_TTY
    # Set a proper TTY for gpg commands to work
    set -gx GPG_TTY (tty)
end

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

if status is-interactive
    if command -qs thefuck
        thefuck --alias | source
    end

    if command -qs pyenv; and ! set -qg __fish_pyenv_initialized
        pyenv init - | source
        pyenv init --path | source
        pyenv virtualenv-init - fish | source
        set -g __fish_pyenv_initialized
    end

    if command -qs rbenv
        rbenv init - | source
    end
end

# Used to ensure Docker cache hits on dev VM
umask 0002
