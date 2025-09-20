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
    # running `git commit` I usually just want to keep focus in the terminal
    set -gx GIT_EDITOR $EDITOR
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

# Most of the default fish theme colors are fine, but escape sequences are a little too close
# to some other colors; this makes them more like my editor
set -g fish_color_escape "#AE81FF"

# Bash-like behavior to print '^C' and keep the commandline visible (pre-4.0 behavior)
bind ctrl-c 'commandline -f cancel-commandline'

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

    if command -qs batman
        command batman --export-env | source
    else
        # wewlad: https://github.com/sharkdp/bat/issues/652
        # Pending better support from bat, just strip all overstrike chars
        # and rely on the syntax highlighting instead of underscores/bold
        set -gx MANPAGER \
            "sh -c \"$sed -E -e 's#(.)\x08\1#\1#g' -e 's#_\x08(.)#\1#g' | bat --plain --language=Manpage\""
    end
end

# https://stackoverflow.com/a/39352670
set -gx LESS Rx4

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
    ~/.config/cargo/bin \
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
# Doesn't seem to affect NixOS the same way
if test (uname) = Darwin
    for profile in (string split " " $NIX_PROFILES)
        fish_add_path --global --prepend --move $profile/bin
    end
end

if test "$YADM_OS" = WSL; and set -q USERPROFILE
    # Add some basic paths but not *everything* from Windows' $env:Path variable, otherwise the
    # filesystem interop slows down every time we try to do command-completion
    # There might be some commands missing here but I'll just try to add them as I find them
    fish_add_path --global --append --path \
        "$USERPROFILE/scoop/shims" \
        "$USERPROFILE/.cargo/bin" \
        /mnt/c/Windows/System32/WindowsPowerShell/v1.0 \
        /mnt/c/Windows \
        /mnt/c/Windows/System32
end

for pth in $PATH[-1..1]
    # Any explicit nix store paths should remain at the front, most likely
    # introduced by e.g. `nix shell` or `nix develop`
    if string match --quiet -- '/nix/store/*' "$pth"
        fish_add_path --global --prepend --move --path "$pth"
    end
end

# interactiveShellInit seems to be usable as its own sourceable file to do this
# automatically in some later nixpkgs but for now just gonna add this manually
if not contains /etc/fish/generated_completions -- $fish_complete_path
    set -a fish_complete_path /etc/fish/generated_completions
end

# https://github.com/nix-community/home-manager/issues/5602
if test -f ~/.nix-profile/etc/profile.d/hm-session-vars.fish
    source ~/.nix-profile/etc/profile.d/hm-session-vars.fish
end

set -gx nvm_default_version lts/iron
if test -f .nvmrc; and functions -q nvm
    nvm use --silent
end

if test "$TERM_PROGRAM" = vscode
    and command -q code
    and test "$vsc_initialized" != 1
    source (code --locate-shell-integration-path fish)
end

# Used to ensure Docker cache hits on dev VM
umask 0002
