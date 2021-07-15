set -gx GOPATH ~/go
set -gx GO111MODULE on

set -gx PYP_CONFIG_PATH ~/.config/pyp.py

# Set fish_user_paths here instead of fish_variables to expand $HOME per-machine
set -Ux fish_user_paths \
    /usr/local/bin \
    ~/.cargo/bin \
    $GOPATH/bin \
    (pwd)/node_modules/.bin \
    ~/Library/Python/3.7/bin \
    /usr/local/sbin

# Set a proper TTY for gpg commands to work
set -x GPG_TTY (tty)

# Use `bat` as pager if it present
if command -qs bat
    set -gx PAGER bat
    set -gx GIT_PAGER 'bat --plain'

    # macOS `man` suports piping in MANPAGER, but on Linux this needs a
    # wrapper script (see `man man`)
    set -gx MANPAGER 'sh -c "col -bx | bat --plain --language Manpage"'
end

if test -d $HOME/.local/share/yadm
    # if we use `yadm` directly, it will setup alts which can cause a race, so
    # instead just manually set the env variables it would normally set
    # (a la `yadm enter`)
    set -lx GIT_DIR $HOME/.local/share/yadm/repo.git
    set -lx GIT_WORKTREE ~

    if test (git config local.class) = personal
        # Set global cask dir for 'personal' computers
        set -gx HOMEBREW_CASK_OPTS "--appdir=~/Applications"
    end
end

if not set -q DOCKER_NAME; and test -f /etc/profile.d/docker_name.sh
    set -gx DOCKER_NAME (sed -E 's/.*DOCKER_NAME=(.+)/\1/' /etc/profile.d/docker_name.sh)
end

if status is-interactive
    if command -qs thefuck
        thefuck --alias | source
    end

    if command -qs pyenv; and ! set -qg __fish_pyenv_initialized
        pyenv init - fish | source
        pyenv virtualenv-init - fish | source
        set -g __fish_pyenv_initialized
    end
end

# Used to ensure Docker cache hits on dev VM
umask 0002
