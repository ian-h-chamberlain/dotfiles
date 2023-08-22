function py --description 'alias py=bpython'
    set -x PYTHONSTARTUP ~/.config/bpython/startup.py
    bpython $argv
end
