function fish_normalize_saved_functions --description "Remove fish-generated paths in saved functions"
    set -l exclude_functions \
        "fish_normalize_saved_functions" \
        "fish_prompt" \
        "fisher"

    for fish_function in ~/.config/fish/functions/*.fish
        set -l func_name (basename $fish_function .fish)
        set -l rel_func_path '~/.config/fish/functions/'$func_name'.fish'

        if ! contains $func_name $exclude_functions
            funcsave $func_name
        end

        if test $func_name != "fish_normalize_saved_functions"
            sed -e '/ Defined in .*\.fish/d' $fish_function >$fish_function.new
            mv $fish_function.new $fish_function
        end
    end
end
