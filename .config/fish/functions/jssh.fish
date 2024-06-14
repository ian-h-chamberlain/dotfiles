function jssh --wraps=ssh
    ssh (juniper_ip_to_128_ip $argv)
end
