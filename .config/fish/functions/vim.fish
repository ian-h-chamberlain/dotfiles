function vim
    if command -qs nvim
        command nvim $argv
    else
        command vim $argv
    end
end
