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
        ###############################################################
        # Begin generated content
        ###############################################################
        while set pyenv_index (contains -i -- ~/.pyenv/shims $PATH)
            set -eg PATH[$pyenv_index]
        end
        set -e pyenv_index
        set -gx PATH ~/.pyenv/shims $PATH
        set -gx PYENV_SHELL fish
        function pyenv
            set command $argv[1]
            set -e argv[1]

            switch "$command"
                case activate deactivate rehash shell
                    source (pyenv "sh-$command" $argv|psub)
                case '*'
                    command pyenv "$command" $argv
            end
        end

        # NOTE: Modified to use glob instead of hardcoded version
        if command -qs brew
            set -gx PATH (brew --cellar)/pyenv-virtualenv/*/shims $PATH
        end
        set -gx PYENV_VIRTUALENV_INIT 1
        # NOTE: modified for https://github.com/pyenv/pyenv-virtualenv/issues/338
        # Also see https://github.com/pyenv/pyenv-virtualenv/issues/45
        function _pyenv_virtualenv_hook --on-variable PWD --on-variable PYENV_VERSION
            set -l ret $status
            if [ -n "$VIRTUAL_ENV" ]
                pyenv activate --quiet; or pyenv deactivate --quiet; or true
            else
                pyenv activate --quiet; or true
            end
            return $ret
        end
        ###############################################################
        # End generated content
        ###############################################################
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
