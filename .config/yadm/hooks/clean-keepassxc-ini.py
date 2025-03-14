#!/usr/bin/env python3

import configparser
import os
import pathlib
import sys


def main():
    filename = pathlib.Path(sys.argv[1])

    config = configparser.ConfigParser(interpolation=None)
    # Preserve case in option names (default is to .lower()):
    config.optionxform = lambda optionstr: optionstr

    config.read(filename)
    config.remove_section("KeeShare")
    with filename.open("w") as newfile:
        config.write(newfile, space_around_delimiters=False)

        # trim extra trailing newline, to avoid conflict with end-of-file-fixer
        newfile.seek(0, os.SEEK_END)
        newfile.truncate(newfile.tell() - 1)


if __name__ == "__main__":
    main()
