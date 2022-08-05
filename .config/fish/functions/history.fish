function history --description alias\ history\ \'history\ --show-time=\"\%F\ \%T\ \"\'
    builtin history --reverse --show-time="%F %T \$ " $argv
end
