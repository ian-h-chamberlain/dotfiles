# Defined in /Users/ichamberlain/.config/fish/functions/bash_env.fish @ line 2
function bash_env
	set -x BASH_ENV ~/.bashrc.aliases
    command bash -c "$argv"
end
