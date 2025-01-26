Set-PSReadLineOption -EditMode Emacs

# For iTerm2 compat on macOS (guess this is just what my profile sends?)
Set-PSReadLineKeyHandler -Chord 'Ctrl+Alt+Backspace' -Function BackwardDeleteWord
