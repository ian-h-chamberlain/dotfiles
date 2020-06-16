function __fish_vscode_ext_complete_vscode_extensions
    command --quiet code; and code --list-extensions
end

function __fish_vscode_ext_complete_wrap_code
    set -l cmd (commandline -opc)
    contains -- '--' $cmd
end

complete -c vscode_ext --wraps code

complete -c vscode_ext -n '! __fish_vscode_ext_complete_wrap_code' \
    -xa '(__fish_vscode_ext_complete_vscode_extensions)'

complete -c vscode_ext -n '! __fish_vscode_ext_complete_wrap_code' \
    -l dry-run -s d -d "Print the command instead of running it"
complete -c vscode_ext -n '! __fish_vscode_ext_complete_wrap_code' \
    -l help -s d -d "Show help text"
complete -c vscode_ext -n '! __fish_vscode_ext_complete_wrap_code' \
    -s '-' -d "Pass through remaining args to code"

complete -c vscode_ext -n '__fish_vscode_ext_complete_wrap_code' --wraps=code
