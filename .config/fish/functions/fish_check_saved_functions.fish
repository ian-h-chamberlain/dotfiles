function fish_check_saved_functions --description 'check syntax of saved files'
    set -l exclude_functions \
        fish_check_saved_functions \
        fish_prompt \
        fisher

    for fish_function in ~/.config/fish/functions/*.fish
        set -l func_name (basename $fish_function .fish)
        set -l rel_func_path '~/.config/fish/functions/'$func_name'.fish'

        if contains $func_name $exclude_functions
            continue
        end

        funcsave $func_name &>/dev/null
        sed -e '/ Defined in .*\.fish/d' $fish_function >$fish_function.new
        mv $fish_function.new $fish_function
    end

    set -l retcode 0

    for fish_file in ~/.config/fish/**/*.fish
        if contains $fish_file $exclude_functions
            continue
        end

        if ! fish --no-execute $fish_file
            set -l retcode (math 1 + $retcode)
        end
    end

    fish_indent --check ~/.config/fish/**/*.fish
    set -l failed_files $status
    if test $failed_files -ne 0
        set retcode (math $retcode + $failed_files)
        fish_indent --write ~/.config/fish/**/*.fish
    end

    return $retcode
end
