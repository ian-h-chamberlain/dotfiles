function ssh_ping
    while ! nc -vz $argv[1] 22
        sleep 3
    end
    beep
end
