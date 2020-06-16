#!/bin/bash
# Helper utilities for `yadm bootstrap` and hooks

VSCODE_EXTENSIONS=~/.config/vscode/extensions.txt

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
    code --list-extensions --show-versions
}

function check_vscode_exts() {
    diff "$VSCODE_EXTENSIONS" \
        <(list_vscode_exts) \
        --unchanged-line-format=""  \
        "$@"
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
            echo "ERROR: some VSCode extensions were not installed:"
            echo "$UNINSTALLED"
            echo
            return 1
        fi

        local INSTALLED
        INSTALLED=$(check_vscode_exts \
            --old-line-format="" \
            --new-line-format="    %L" \
            || :
        )
        if [[ -n $INSTALLED ]]; then
            echo "WARNING: some installed VSCode extensions were not found in $VSCODE_EXTENSIONS:"
            echo "$INSTALLED"
            echo
        fi
    fi
}
