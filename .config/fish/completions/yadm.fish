# Derived from https://github.com/TheLocehiliosan/yadm/pull/224

function __fish_yadm_universal_optspecs
    string join \n 'a-yadm-dir=' 'b-yadm-repo=' 'c-yadm-config=' \
        'd-yadm-encrypt=' 'e-yadm-archive=' 'f-yadm-bootstrap='
end

function __fish_yadm_needs_command
    # Figure out if the current invocation already has a command.
    set -l cmd (commandline -opc)
    set -e cmd[1]
    argparse -s (__fish_yadm_universal_optspecs) -- $cmd 2>/dev/null
    or return 0
    if set -q argv[1]
        echo $argv[1]
        return 1
    end
    return 0
end

function __fish_yadm_using_command
    set -l cmd (__fish_yadm_needs_command)
    test -z "$cmd"
    and return 1
    contains -- $cmd $argv
    and return 0
end


if not functions -q __fish_git_using_command; and test -f $__fish_data_dir/completions/git.fish
    source $__fish_data_dir/completions/git.fish
end

function __fish_yadm_files
    # if we use `yadm` directly, it will setup alts which can cause a race, so instead
    # just manually set the env variables it would normally set (a la `yadm enter`)
    set -fx GIT_DIR $HOME/.local/share/yadm/repo.git
    set -fx GIT_WORKTREE $HOME

    __fish_git_files $argv
end

# yadm's specific autocomplete
complete -x -c yadm -n __fish_yadm_needs_command -a clone -d 'Clone an existing repository'
complete -F -c yadm -n '__fish_yadm_using_command clone' -s w -d 'work-tree to use (default: $HOME)'
complete -f -c yadm -n '__fish_yadm_using_command clone' -s b -d 'branch to clone'
complete -x -c yadm -n '__fish_yadm_using_command clone' -s f -d 'force to overwrite'
complete -x -c yadm -n '__fish_yadm_using_command clone' -l bootstrap -d 'force bootstrap to run'
complete -x -c yadm -n '__fish_yadm_using_command clone' -l no-bootstrap -d 'prevent bootstrap from beingrun'

complete -x -c yadm -n __fish_yadm_needs_command -a alt -d 'Create links for alternates'
complete -x -c yadm -n __fish_yadm_needs_command -a bootstrap -d 'Execute $HOME/.config/yadm/bootstrap'
complete -x -c yadm -n __fish_yadm_needs_command -a perms -d 'Fix perms for private files'
complete -x -c yadm -n __fish_yadm_needs_command -a enter -d 'Run sub-shell with GIT variables set'
complete -c yadm -n __fish_yadm_needs_command -a git-crypt -d 'Run git-crypt commands for the yadm repo'
complete -x -c yadm -n __fish_yadm_needs_command -a help -d 'Print a summary of yadm commands'
complete -x -c yadm -n __fish_yadm_needs_command -a upgrade -d 'Upgrade to version 2 of yadm directory structure'
complete -x -c yadm -n __fish_yadm_needs_command -a version -d 'Print the version of yadm'

complete -x -c yadm -n __fish_yadm_needs_command -a init -d 'Initialize an empty repository'
complete -x -c yadm -n '__fish_yadm_using_command init' -s f -d 'force to overwrite'
complete -F -c yadm -n '__fish_yadm_using_command init' -s w -d 'set work-tree (default: $HOME)'

complete -x -c yadm -n __fish_yadm_needs_command -a list -d 'List tracked files at current directory'
complete -x -c yadm -n '__fish_yadm_using_command list' -s a -d 'list all managed files instead'

complete -x -c yadm -n __fish_yadm_needs_command -a encrypt -d 'Encrypt files'
complete -x -c yadm -n __fish_yadm_needs_command -a decrypt -d 'Decrypt files'
complete -x -c yadm -n '__fish_yadm_using_command decrypt' -s l -d 'list the files stored without extracting'

complete -x -c yadm -n __fish_yadm_needs_command -a introspect -d 'Report internal yadm data'
complete -x -c yadm -n '__fish_yadm_using_command introspect' -a (printf -- '%s\n' 'commands configs repo switches') -d category

complete -x -c yadm -n __fish_yadm_needs_command -a gitconfig -d 'Pass options to the git config command'
complete -x -c yadm -n __fish_yadm_needs_command -a config -d 'Configure a setting'
for name in (yadm introspect configs)
    complete -x -c yadm -n '__fish_yadm_using_command config' -a "$name" -d 'yadm config'
end

# yadm universal options
complete --force-files -c yadm -s Y -l yadm-dir -d 'Override location of yadm directory'
complete --force-files -c yadm -l yadm-repo -d 'Override location of yadm repository'
complete --force-files -c yadm -l yadm-config -d 'Override location of yadm configuration file'
complete --force-files -c yadm -l yadm-encrypt -d 'Override location of yadm encryption configuration'
complete --force-files -c yadm -l yadm-archive -d 'Override location of yadm encrypted files archive'
complete --force-files -c yadm -l yadm-bootstrap -d 'Override location of yadm bootstrap program'

# setup variables for git completion using `yadm enter`
complete -c yadm -w "git --git-dir='$GIT_DIR' --work-tree='$GIT_WORK_TREE'"

# Override some file completions to avoid waiting forever for untracked files.
# These are mostly just copy-pastes of the same completions in git.fish with minor
# modifications
complete -f -c yadm -n '__fish_git_using_command add' -a '(__fish_yadm_files modified deleted unmerged modified-staged-deleted)'
complete -f -c yadm -n '__fish_git_using_command commit' -a '(__fish_yadm_files modified deleted modified-staged-deleted)'
complete -f -c yadm -n '__fish_git_using_command diff' -n '__fish_git_contains_opt cached staged' -a '(__fish_yadm_files all-staged)'
complete -f -c yadm -n '__fish_git_using_command diff' -n 'not __fish_git_contains_opt cached staged' -a '(__fish_yadm_files all-staged modified modified-staged-deleted)'
complete -f -c yadm -n '__fish_git_using_command reset' -n 'not contains -- -- (commandline -opc)' -a '(__fish_yadm_files all-staged modified)'
complete -f -c yadm -n '__fish_git_using_command reset' -n 'contains -- -- (commandline -opc)' -a '(__fish_yadm_files all-staged deleted modified)'
complete -f -c yadm -n '__fish_git_using_command restore' -n 'not __fish_git_contains_opt -s S staged' -a '(__fish_yadm_files modified deleted modified-staged-deleted unmerged)'
complete -f -c yadm -n '__fish_git_using_command restore' -n '__fish_git_contains_opt -s S staged' -a '(__fish_yadm_files added modified-staged deleted-staged renamed copied)'
complete -f -c yadm -n '__fish_git_using_command rm' -n '__fish_git_contains_opt cached' -a '(__fish_yadm_files all-staged)'
complete -f -c yadm -n '__fish_git_using_command rm' -n 'not __fish_git_contains_opt cached' -a '(__fish_yadm_files all-staged)'
complete -f -c yadm -n '__fish_git_stash_using_command push' -a '(__fish_yadm_files modified deleted modified-staged-deleted)'
