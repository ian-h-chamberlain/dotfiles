function retry_ssh
    false
    while test $status -ne 0
        ssh $argv
        or begin
            sleep 1
            false
        end
    end
end
