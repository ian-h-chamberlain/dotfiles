# Per (swda help), I didn't feel like parsing the output:
set -l commands \
    getHandler "Returns the default application registered for the URI Scheme or <subtype> you specify." \
    getApps "Returns a list of all registered applications." \
    getSchemes "Returns a list of all known URI schemes, accompanied by their default handler." \
    getUTIs "Returns a list of all known UTIs, and their default handler." \
    setHandler "Sets <application> as the default handler for a given <type>/<subtype> combination." \
    help "Prints this help information" \
    version "Prints the current version of this app"

function __swda_commands -V commands
    printf '%s\t%s\n' $commands
end

# NOTE \t must be unquoted here!!!
set -l command_names (__swda_commands | string split \t -f 1)

complete -c swda -f
complete -c swda -n "not __fish_seen_subcommand_from $command_names" -a '(__swda_commands)'

set -l handler_opts \
    URL=getSchemes \
    UTI=getUTIs \
    ftp \
    # Weirdly, these don't seem to get merged like I would expect from
    # https://github.com/fish-shell/fish-shell/issues/8146
    "internet browser web" \
    "mail email e-mail" \
    news \
    rss

set -l handler_desc \
    'the default application for URL <subtype>' \
    'the default application for UTI <subtype>' \
    'the default FTP client.' \
    'the default web browser.' \
    'the default e-mail client.' \
    'the default news client.' \
    'the default RSS client.'

# https://github.com/fish-shell/fish-shell/issues/390#issuecomment-360259983
for opt in $handler_opts
    if set -l i (contains -i -- $opt $handler_opts)
        set -l complete_args
        if set -l split_opt (string split '=' $opt)
            set opt $split_opt[1]
            # amazingly, it's already in the perfect format (tab-separated list)
            set -a complete_args -xa "(swda $split_opt[2])"
        end

        set -l aliases "-l "(string split ' ' -- $opt)
        set -p complete_args (string split ' ' -- $aliases)

        complete -c swda -n "__fish_seen_subcommand_from getHandler" \
            $complete_args -d "Returns $handler_desc[$i]"

        complete -c swda -n "__fish_seen_subcommand_from setHandler" \
            $complete_args -d "Changes $handler_desc[$i]"
    end
end

complete -c swda -n "__fish_seen_subcommand_from setHandler getHandler" \
    -l help -s h -d 'Show help information for this command'

complete -c swda -n "__fish_seen_subcommand_from setHandler getHandler" \
    -l role -xa 'Viewer Editor Shell All' \
    -d 'Specifies the role with which to register the handler. Default is All'

complete -c swda -n "__fish_seen_subcommand_from setHandler" \
    -l app -l application -d 'The <application> to register as default handler. Specifying "None" will remove the currently registered handler.' \
    # Special case "None" and add extra \t to blank out the descriptions
    -xa 'None (swda getApps)\t'

complete -c swda -n "__fish_seen_subcommand_from getHandler" \
    -l all -d 'When this flag is added, a list of all applications registered for that content will printed.'
