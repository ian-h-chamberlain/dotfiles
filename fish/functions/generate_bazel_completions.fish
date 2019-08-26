# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.aqSxKZ/generate_bazel_completions.fish @ line 2
function generate_bazel_completions --description 'Print a list of completion strings for bazel'
	command bazel help completion | sed -E 's/([A-Z_]+)=(.+)/set __\1 \2/g'
end
