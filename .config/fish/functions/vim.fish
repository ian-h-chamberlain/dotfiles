function vim
    if command -qs nvim
        command nvim -p $argv
    else
        command vim -p $argv
    end
end
