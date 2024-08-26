# Tampermonkey Backups

Due to [limitations](https://www.tampermonkey.net/faq.php?ext=dhdg#Q105) of
Firefox, it's not really feasible to automatically save and restore from
dotfiles directly, without a server running to sync changes like TamperDAV.

As a slightly simpler alternative, this directory should be usable for manual
backup + restore. Exporting a ZIP and extracting it to `archive` will let git
show diffs and things like that, and re-zipping the contents of `archive`
should make it importable by Tampermonkey. Using zip instead of a single JSON
file mainly just makes the files a bit more organized.
