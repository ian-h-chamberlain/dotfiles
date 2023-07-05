function iterm2
    set -l dir $PWD
    if test (count $argv) -gt 0
        if test -d $argv[1]
            set dir (realpath $argv[1])
        else
            set dir (realpath (dirname $argv[1]))
        end
    end

    osascript \
        -e 'tell application "iTerm2" to open "'$dir'"' \
        -e return
end
