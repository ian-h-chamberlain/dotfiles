function __fish_print_help --argument item
    man -- $item; and return
    __fish_original_print_help $argv
end
