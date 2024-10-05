#!/usr/bin/env python3

import configparser
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


if __name__ == "__main__":
    main()
