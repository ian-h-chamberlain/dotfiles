function citra
    if command -q flatpak
        flatpak run --command=citra org.citra_emu.citra $argv
    else
        command citra $argv
    end
end
