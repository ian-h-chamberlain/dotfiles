# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.0uYmmr/bash_env.fish @ line 2
function bash_env
    set -x BASH_ENV ~/.bashrc.aliases
    command bash -c "$argv"
end
