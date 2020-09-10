# Set fish_user_paths here instead of fish_variables to expand $HOME per-machine
set -gx fish_user_paths \
    ~/.cargo/bin \
    ~/Library/Python/3.7/bin

# Set a proper TTY for gpg commands to work
set -x GPG_TTY (tty)

# Use `bat` as pager if it present
if command -qs bat
    set -gx PAGER (which bat)
end

# Set global cask dir for 'personal' computers
if command -qs yadm && test (yadm config local.class) = "personal"
    set -x HOMEBREW_CASK_OPTS "--appdir=~/Applications"
end

if not set -q DOCKER_NAME; and test -f /etc/profile.d/docker_name.sh
    set -gx DOCKER_NAME (sed -E 's/.*DOCKER_NAME=(.+)/\1/' /etc/profile.d/docker_name.sh)
end

if status is-interactive
    # Run nvm to update fish_user_paths for npm installs. Allow failure if running
    # outside home directory (no .nvmrc found), and run in background to avoid
    # blocking the shell from starting
    if functions -q nvm
        nvm &>/dev/null & || true
    end

    if command -qs thefuck
        thefuck --alias | source
    end

    if command -qs pyenv
        pyenv init - fish | source
        pyenv virtualenv-init - fish | source
    end
end

# Used to ensure Docker cache hits on dev VM
umask 0002
