# TODO: switch out some of these things for nix activation
#
if command -qs yadm; and test "$(yadm config local.class)" = personal
    set -gx HOMEBREW_CASK_OPTS "--appdir=$HOME/Applications"
end

# Set up brew PATH when it's installed in unusual places
if status is-interactive
    if test -x /home/linuxbrew/.linuxbrew/bin/brew
        eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    else if test -x /opt/homebrew/bin/brew
        # TODO: might have to update a lot of hardcoded `/usr/local`s...
        eval (/opt/homebrew/bin/brew shellenv)
    else if test -x /usr/local/bin/brew
        eval (/usr/local/bin/brew shellenv)
    end
end

# command-not-found is a nice idea, but it's incredibly slow (4-6s on average)
# A lot of that is `brew` itself, see https://github.com/Homebrew/homebrew-command-not-found/issues/108
#set -l HB_CNF_HANDLER "$HOMEBREW_REPOSITORY/Library/Taps/homebrew/homebrew-command-not-found/handler.fish"
#if test -f $HB_CNF_HANDLER
#    source $HB_CNF_HANDLER
#end

# This lets us use `brew bundle add --global` for cross-system packages
# and `brew bundle add` for system-specific packages.
set -gx HOMEBREW_BUNDLE_FILE_GLOBAL ~/.config/brew/Brewfile
set -gx HOMEBREW_BUNDLE_FILE ~/.config/brew/10-class.Brewfile
# For https://github.com/superatomic/homebrew-bundle-extensions/pull/14
set -gx HOMEBREW_BUNDLE_DUMP_DESCRIBE 1
