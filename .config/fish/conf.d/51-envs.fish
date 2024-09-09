# "hardcoded" implementations of `pyenv init`, `rbenv init` etc., to save on
# startup cost from those calls invoking bash and stuff like that.
#
# Also slightly modified to be more portable (~ instead of absolute path, globs
# instead of hardcoded versions).

set -Ux PYENV_VIRTUALENV_DISABLE_PROMPT 1


if status is-interactive
    # TODO: rtx activation can be inlined here, and replace pyenv/rbenv ideally
    if command -qs rtx
        rtx activate | source
    end

    if command -qs pyenv; and not set -qg __fish_pyenv_initialized
        # TODO: this might be a little slower than what I used to have, but
        # it should work better when pyenv-x86 is also installed
        function _pyenv_hook --on-variable PWD --on-variable PYENV_VERSION
            set --erase PYENV_VERSION PYENV_ROOT PYENV_SHELL PYENV_VIRTUALENV_INIT
            set -l version_file (upfind .python-version)
            if test -f "$version_file"; and test "$(head -n1 "$version_file")" = "#!x86_64"
                set -gx PYENV_ROOT (pyenv-x86 root)
                test -d $PYENV_ROOT/bin; and fish_add_path --global "$PYENV_ROOT/bin"
                pyenv-x86 init --no-rehash - fish | source
                pyenv-x86 virtualenv-init - fish | source
            else
                set -gx PYENV_ROOT (pyenv root)
                test -d $PYENV_ROOT/bin; and fish_add_path --global "$PYENV_ROOT/bin"
                pyenv init --no-rehash - fish | source
                pyenv virtualenv-init - fish | source
            end
        end
        _pyenv_hook
        set -g __fish_pyenv_initialized
    end

    if command -qs rbenv; and not set -qg __fish_rbenv_initialized
        ###############################################################
        # Begin generated content
        ###############################################################
        set -gx PATH ~/.rbenv/shims $PATH
        set -gx RBENV_SHELL fish
        function rbenv
            set command $argv[1]
            set -e argv[1]

            switch "$command"
                case rehash shell
                    rbenv "sh-$command" $argv | source
                case '*'
                    command rbenv "$command" $argv
            end
        end
        ###############################################################
        # End generated content
        ###############################################################
    end
end
