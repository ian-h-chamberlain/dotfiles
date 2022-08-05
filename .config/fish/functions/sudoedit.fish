function sudoedit --description 'alias sudoedit=sudo sudo -e'
    if command -q sudoedit
        command sudoedit $argv
    else
        sudo sudo -e $argv
    end
end
