function find_completions
    for pth in $fish_complete_path
        set -l possible_completion "$pth/$argv[1].fish"
        if test -f $possible_completion
            echo $possible_completion
            break
        end
    end
end
