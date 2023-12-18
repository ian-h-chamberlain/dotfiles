function citra
    if command -q flatpak; and not command -q citra
        flatpak run --command=citra org.citra_emu.citra $argv
    else
        command citra $argv
    end
end
