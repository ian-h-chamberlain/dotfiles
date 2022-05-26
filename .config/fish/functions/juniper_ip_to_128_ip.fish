function juniper_ip_to_128_ip
    function __sub_ips
        set -l regex (string escape --style=regex $argv[1])
        string replace --regex --filter '^'$regex'[.]' $argv[2]'.' -- $argv[3]
    end

    for arg in $argv
        # Burlington
        #   10.24.0.0         Nat to  172.24.0.0      (SE/Support lab)
        #   10.25.0.0         Nat to  10.0.0.0        (legacy corp network)
        #   10.26.0.0         Nat to  172.17.0.0      (Engineering lab)
        #
        # Andover
        #   10.22.0.0/16      Nat to  172.18.0.0/16   (alfred/tbm testbeds)
        #   10.23.0.0/16      Nat to  172.20.0.0/16   (openstack mgmt/devvm network)
        #   10.88.127.0/24    Nat to  172.30.0.0/24   (DMZ)
        #   10.31.0.0/16      Nat to  10.4.0.0/16     (corp mgmt network)

        # TODO: /24 does not work with this, but I don't really care about DMZ
        if set -l new_arg (
            __sub_ips '172.24'  '10.24' $arg ||
            __sub_ips '10.0'    '10.25' $arg ||
            __sub_ips '172.17'  '10.26' $arg ||
            __sub_ips '172.18'  '10.22' $arg ||
            __sub_ips '172.20'  '10.23' $arg ||
            __sub_ips '10.4'    '10.31' $arg ||
            false
        )
            echo $new_arg
            continue
        end

        echo $arg
    end
end
