function cat
    if command -qs bat
        command bat $argv
    else
        command cat $argv
    end
end
