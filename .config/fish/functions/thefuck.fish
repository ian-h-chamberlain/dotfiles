if not status is-interactive
    # workround for thefuck not being in PATH for non-interactive sessions,
    # which breaks e.g. SCP/SFTP by echoing output; see 
    # https://github.com/oh-my-fish/plugin-thefuck/blob/master/conf.d/thefuck.fish
    #
    # Probably just echoing to stderr or skipping the echo for non-interactive would fix
    function thefuck; end
end
