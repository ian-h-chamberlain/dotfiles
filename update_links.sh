#/bin/bash
function abs_path {
  (cd "$(dirname '$1')" &>/dev/null && printf "%s/%s" "$PWD" "${1##*/}")
}

current_path=$(abs_path $(dirname "$0"))

all_dotfiles="bashrc bash_profile bashrc.aliases pythonrc.py vimrc"

for dotfile in $all_dotfiles; do
    dest_path="$HOME/.$dotfile"

    if [[ -L "$dest_path" ]]; then
        echo "Found link at $dest_path, removing it first"
        rm "$dest_path"
    fi
    echo "Symlinking $dest_path -> $current_path/$dotfile"
    ln -s "$current_path/$dotfile" "$dest_path"
done
