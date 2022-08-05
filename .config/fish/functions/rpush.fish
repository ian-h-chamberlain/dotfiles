function rpush
    source ~/.config/fish/functions/remote_cmd.fish
    remote_cmd rpush $argv

    set rpush_status $status
    if test $rpush_status -ne 0
        echo (set_color yellow)"WARNING:"(set_color normal) \
            "rpush exited with code $rpush_status" >&2
    end

    greset
end
