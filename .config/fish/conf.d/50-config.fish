if test -f ~/.config/yadm/env
    source ~/.config/yadm/env
end

set -gx GOPATH ~/go

set -gx PYP_CONFIG_PATH ~/.config/pyp.py

set -gx DEVKITPRO /opt/devkitpro
set -gx DEVKITARM $DEVKITPRO/devkitARM

set -gx CARGO_UNSTABLE_SPARSE_REGISTRY true

# Set a proper TTY for gpg commands to work
set -gx GPG_TTY (tty)

# Inhibit suspend while logged into SSH session
if command -qs systemd-inhibit; and set -q SSH_TTY
    # systemd-inhibit \
    #     --what=idle \
    #     --who='fish shell' \
    #     --why="prevent suspend during SSH session" \
    #     sleep infinity &

    # # If we don't disown this, it takes two tries to quit, but we can still
    # # kill it on exit with a trap
    # trap "kill "(jobs --last --pid) EXIT
    # disown %1
end

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
    set -gx MANPAGER "$sed -E 's#(.)\x08\1#\1#g' |
        $sed -E 's#_\x08(.)#\1#g' |
        bat --plain --language=Manpage"
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
    "**/integrationTest",
    "**/build",
    "**/src",
    "**/go",
    "**/web",
    "**/Jenkinsfiles",
    "**/python",
    "**/.pyenv",
    "**/node_modules",
    "**/packaging"
]'

# Set fish_user_paths here instead of fish_variables to expand $HOME per-machine
set -Ux fish_user_paths \
    $DEVKITARM/bin \
    ~/.cargo/bin \
    ~/.local/bin \
    $GOPATH/bin \
    node_modules/.bin \
    /usr/local/bin \
    /usr/local/sbin

test -e {$HOME}/.iterm2_shell_integration.fish; and source {$HOME}/.iterm2_shell_integration.fish

if status is-interactive; and test -f .nvmrc
    nvm use >/dev/null
end

# This is hella slow, let's not use it for now...
# if string match -q "$TERM_PROGRAM" vscode
#     source (code --locate-shell-integration-path fish)
# end

# Used to ensure Docker cache hits on dev VM
umask 0002
