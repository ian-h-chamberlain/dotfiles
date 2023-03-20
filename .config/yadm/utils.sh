#!/bin/bash
# Helper utilities for `yadm bootstrap` and hooks

VSCODE_EXTENSIONS=~/.config/Code/User/extensions.txt

function confirm() {
    read -r -n 1 -p "$1 [Y/n]: "

    # Default to yes for empty input
    if [[ "$REPLY" == "" ]]; then
        return 0
    else
        echo
    fi

    # Only 'y' input is valid if something was typed
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        return 0
    fi

    echo "Operation skipped."
    return 1
}

function list_vscode_exts() {
    # Linux `code` outputs with CRLF for some reason
    code --list-extensions --show-versions | sed 's/\r$//g'
}

function check_vscode_exts() {
    command -v code || return 0

    diff "$VSCODE_EXTENSIONS" \
        <(list_vscode_exts) \
        --unchanged-line-format=""  \
        "$@"
}

function error() {
    # Print message in red to stderr
    printf '\033[31mERROR:\033[0m ' >&2
    printf '%s\n' "$@" >&2
}

function warn() {
    # Print message in yellow to stderr
    printf '\033[33mWARNING:\033[0m ' >&2
    printf '%s\n' "$@" >&2
}

function exit_with_error() {
    error "$@"
    echo
    exit 1
}

function install_vscode_exts() {
    xargs printf -- "--install-extension %s " <"$VSCODE_EXTENSIONS" | xargs code
    echo

    # TODO: some kind of vscode extension "prune" command. Or just uninstall all every time?
    if ! check_vscode_exts &>/dev/null; then
        # This check may not be needed since `code` errors if it can't install
        local UNINSTALLED
        UNINSTALLED=$(check_vscode_exts \
            --old-line-format="    %L" \
            --new-line-format="" \
            || :
        )

        if [[ -n $UNINSTALLED ]]; then
            exit_with_error "Some VSCode extensions were not installed:" "$UNINSTALLED"
        fi

        local INSTALLED
        INSTALLED=$(check_vscode_exts \
            --old-line-format="" \
            --new-line-format="    %L" \
            || :
        )
        if [[ -n $INSTALLED ]]; then
            warn "Some installed VSCode extensions were not found in $VSCODE_EXTENSIONS:"
            echo "$INSTALLED" >&2
            echo >&2
        fi
    fi
}

function is_merging() {
    git rev-parse -q --verify MERGE_HEAD
}
