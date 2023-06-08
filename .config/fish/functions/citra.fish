function citra
    if command -q citra
        command citra $argv
    else
        flatpak run --command=citra org.citra_emu.citra $argv
    end
end
