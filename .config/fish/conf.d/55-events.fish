# See `help funcsave` for why this is a conf file instead of in $fish_function_path

function __set_color_theme --on-event fish_preexec
    # On macOS, this can change dynamically, so re-evaluate every time
    if test "$YADM_OS" = Darwin
        if test "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" != Dark
            set -gx COLOR_THEME light
        else
            set -gx COLOR_THEME dark
        end
    end
end
