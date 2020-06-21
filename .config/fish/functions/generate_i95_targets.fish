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
