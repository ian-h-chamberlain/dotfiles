if test -f ~/.local/state/yadm/env
    source ~/.local/state/yadm/env
end

set -g fish_greeting

if command -qs nvim
    set -gx EDITOR nvim
else if command -qs vim
    set -gx EDITOR vim
else
    # we'll just assume vi of some kind is always available...
    set -gx EDITOR vi
end

if test "$TERM_PROGRAM" = vscode
    # vscode doesn't always seem to handle weird perms well
    set -gx SUDO_EDITOR $EDITOR
    set -gx EDITOR "code --wait"
end

set -gx GOPATH ~/go

set -gx PYP_CONFIG_PATH ~/.config/pyp.py

set -gx DEVKITPRO /opt/devkitpro
set -gx DEVKITARM $DEVKITPRO/devkitARM

set -gx CARGO_UNSTABLE_SPARSE_REGISTRY true

# Set a proper TTY for gpg commands to work
set -gx GPG_TTY (tty)

# Set jq to show null/true/false as magenta instead of black or otherwise
set -gx JQ_COLORS "1;35:1;35:1;35:0;39:0;32:1;39:1;39"

# Use `bat` as pager if it present
if command -qs bat
    set -gx PAGER bat
    set -gx GIT_PAGER 'bat --plain'
    # journalctl output doesn't necessarily play nice with bat
    set -gx SYSTEMD_PAGER less

    set -l sed sed
    if command -q gsed
        set sed gsed
    end

    # wewlad: https://github.com/sharkdp/bat/issues/652
    # Pending better support from bat, just strip all overstrike chars
    # and rely on the syntax highlighting instead of underscores/bold
    set -gx MANPAGER \
        "sh -c \"$sed -E -e 's#(.)\x08\1#\1#g' -e 's#_\x08(.)#\1#g' | bat --plain --language=Manpage\""
end

if command -qs xcode-select
    # Guess these don't get added automatically, make sure
    for pth in (xcode-select --show-manpaths)
        if not contains -- $pth $MANPATH
            set --path -gax MANPATH $pth
        end
    end
end

if not set -q DOCKER_NAME; and test -f /etc/profile.d/docker_name.sh
    set -gx DOCKER_NAME (sed -E 's/.*DOCKER_NAME=(.+)/\1/' /etc/profile.d/docker_name.sh)
end

# Default for linux etc. if not passed in by a parent
if not set -q COLOR_THEME
    set -gx COLOR_THEME dark
end

# Set fish_user_paths here instead of fish_variables to expand $HOME per-machine
set -gax fish_user_paths \
    $DEVKITARM/bin \
    $DEVKITPRO/tools/bin \
    ~/.cargo/bin \
    ~/.local/share/rbenv/shims \
    ~/.local/bin \
    $GOPATH/bin \
    node_modules/.bin \
    /usr/local/sbin \
    /opt/homebrew/bin

# Manually active nix-managed fish profile.
# Sets up miscellaneous nix paths, session vars, completions etc.
# If this gets unwieldy, https://github.com/lilyball/nix-env.fish might be handy
if not set -q NIX_PROFILES
    set -l nix_fish_profile ~/.nix-profile/etc/profile.d/nix.fish
    test -f $nix_fish_profile; and source $nix_fish_profile
end

# https://github.com/LnL7/nix-darwin/issues/122
for profile in (string split " " $NIX_PROFILES)
    fish_add_path --global --prepend --move $profile/bin
end

set -gx nvm_default_version lts/iron
if test -f .nvmrc; and functions -q nvm
    nvm use --silent
end

if string match -q "$TERM_PROGRAM" vscode
    and command -q code
    and test -z "$REMOTE_CONTAINERS"
    and test -f "$vscode_shell_integration"
    source (code --locate-shell-integration-path fish)
end

# Used to ensure Docker cache hits on dev VM
umask 0002
