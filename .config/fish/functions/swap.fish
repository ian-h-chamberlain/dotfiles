function swap
    set -l tmpfile (mktemp)
    mv "$argv[1]" $tmpfile
    mv "$argv[2]" "$argv[1]"
    mv $tmpfile "$argv[2]"
end
