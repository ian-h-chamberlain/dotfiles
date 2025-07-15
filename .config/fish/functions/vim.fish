set wrapped vim

if command -qs hx
    # Force myself to get used to running hx for small one-off edits
    set wrapped hx
else if command -qs nvim
    set wrapped nvim
end

function vim --wraps "$wrapped" --inherit-variable wrapped
    command "$wrapped" $argv
end
