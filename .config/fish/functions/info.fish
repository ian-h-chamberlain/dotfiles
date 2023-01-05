function info
    if test -f (command info --where $argv[1])
        # Info file really exists, open it with vim :Info
        vim -R -M -c "Info $argv[1] $argv[2]" +only -c 'buffer 1 | bdelete'
    else
        man $argv
    end
end
