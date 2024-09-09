function pyenv-x86 --wraps pyenv
    set -x PYENV_ROOT ~/.local/share/pyenv-x86_64
    arch -x86_64 command pyenv $argv
end
