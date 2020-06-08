# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.D9g25f/swap.fish @ line 1
function swap
    set -l tmpfile (mktemp)
    mv "$argv[1]" $tmpfile
    mv "$argv[2]" "$argv[1]"
    mv $tmpfile "$argv[2]"
end
