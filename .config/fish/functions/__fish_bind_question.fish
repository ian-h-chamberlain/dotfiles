function __fish_bind_question
    switch (commandline --current-token)[-1]
        case '$' '*$'
            commandline --insert status
        case "*"
            commandline --insert '?'
    end
end
