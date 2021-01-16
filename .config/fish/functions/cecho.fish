function cecho
    isatty stdout && echo -n (set_color $argv[1])

    echo $argv[2..-1]

    isatty stdout && echo -n (set_color normal)
end
