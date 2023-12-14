# Set up brew PATH when it's installed in unusual places
if status is-interactive
    if test -x /home/linuxbrew/.linuxbrew/bin/brew
        eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    else if test -x /opt/homebrew/bin/brew
        # TODO: might have to update a lot of hardcoded `/usr/local`s...
        eval (/opt/homebrew/bin/brew shellenv)
    end
end
