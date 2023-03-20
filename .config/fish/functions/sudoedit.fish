function sudoedit --description 'alias sudoedit=sudo sudo -e'
    set -lx SUDO_COMMAND "sudoedit $argv"
    if command -q sudoedit
        command sudoedit $argv
    else
        sudo sudo -e $argv
    end
end
