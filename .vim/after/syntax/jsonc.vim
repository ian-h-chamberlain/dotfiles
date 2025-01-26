" Builtin JSONC still errors for trailing commas, but at least for
" use cases I care about they are parsed fine, so clear the syntax group:
if !exists('g:vim_json_warnings') || g:vim_json_warnings==1
    syntax clear jsonTrailingCommaError
endif
