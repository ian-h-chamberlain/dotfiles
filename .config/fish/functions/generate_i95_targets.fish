# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.0IaV7o/generate_i95_targets.fish @ line 2
function generate_i95_targets
    date
    if ! count $argv >/dev/null
        echo "Error: no I95 repository specified"
        return 1
    end
    set -l dir $argv[1]
    cd $dir/build
    make help | sed 's/\.\.\. //' > i95_cmake_targets.txt
    echo "Completed generating i95 targets!"
end
