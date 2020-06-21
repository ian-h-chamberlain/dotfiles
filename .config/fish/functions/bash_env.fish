function bash_env
	set -x BASH_ENV ~/.bashrc.aliases
    command bash -c "$argv"
end
