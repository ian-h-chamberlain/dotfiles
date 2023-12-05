function brew
    # Force system python, for brew-file. This might break on linuxbrew ?
    set -x PYENV_VERSION system

    if command -q rtx
        rtx env python@system | sed s/-gx/-x/g | source
    end

    # Brew expects the latest XCode, and complains if you xcode-select an older one
    set -x DEVELOPER_DIR /Applications/Xcode.app

    command brew $argv
end
