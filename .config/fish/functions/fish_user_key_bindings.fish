function fish_user_key_bindings
    bind ! __fish_bind_bang
    bind '$' __fish_bind_dollar

    # Bind cmd+backspace + cmd+del to delete remainder of line
    bind \e\[3\;9~ kill-line
    bind \cU backward-kill-line
end
