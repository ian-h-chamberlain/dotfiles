# Use latest curl version from brew for updated SSL support
set -gpx fish_user_paths \
    /usr/local/opt/curl/bin \
    /opt/homebrew/opt/curl/bin
