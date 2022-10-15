function jssh-jump
    set -l first_ip $argv[1]
    set -l second_ip $argv[2]

    jssh -t root@$first_ip "ssh centos@$second_ip"
end
