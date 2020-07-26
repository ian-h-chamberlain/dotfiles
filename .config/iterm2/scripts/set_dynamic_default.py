#!/usr/bin/env python3.7

"""
Simple iTerm2 script to set the default profile after dynamic loading.

Based on https://iterm2.com/python-api/examples/change_default_profile.html
"""

import iterm2


async def main(connection):
    all_profiles = await iterm2.PartialProfile.async_query(connection)
    for profile in all_profiles:
        if profile.name == "Default":
            await profile.async_make_default()
            break


iterm2.run_until_complete(main)
