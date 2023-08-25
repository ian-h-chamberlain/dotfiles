function repro
    clear
    echo '```console'
    fish --interactive --init-command='function fish_prompt; printf \'$ \'; end'
    echo '```'
end
