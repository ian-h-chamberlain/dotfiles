#!/usr/bin/env python3

import iterm2
from iterm2 import PreferenceKey as P

DEFAULT_DYNAMIC_PROFILE = "Default"

# NOTE: values must be JSON serializable, but may be any type otherwise
GLOBAL_PREFERENCES = {
    P.APPS_MAY_ACCESS_PASTEBOARD: True,
    P.AUTO_HIDE_TMUX_CLIENT_SESSION: True,
    P.COPY_TO_PASTEBOARD_ON_SELECTION: True,
    P.DRAW_WINDOW_BORDER: False,
    P.DIM_BACKGROUND_WINDOWS: True,
    P.HIDE_SCROLLBAR: False,
    P.HIDE_TAB_BAR_WHEN_ONLY_ONE_TAB: False,
    P.HIDE_TAB_NUMBER: True,
    P.OPEN_TMUX_WINDOWS_IN: 2,  # tabs in existing window
    P.PASTE_TAB_TO_STRING_TAB_STOP_SIZE: 4,
    P.SPLIT_PANE_DIMMING_AMOUNT: 0.15,
    P.STATUS_BAR_POSITION: 1,  # bottom
    P.STATUS_BAR_POSITION: 1,  # bottom
    P.STRETCH_TABS_TO_FILL_BAR: False,
    P.THEME: 5,  # Minimal "borderless" theme
    P.WINDOW_NUMBER: False,
    P.WORD_CHARACTERS: "".join(["/", "-", "+", "\\", "~", "_", "."]),
    # These don't have PreferenceKey enums, but the API still works to set them.
    "DynamicProfilesPath": "~/.config/iterm2/profiles",
    "NoSyncTurnOffBracketedPasteOnHostChange": True,
    "PointerActions": {
        "Button,1,1,,": {"Action": "kContextMenuPointerAction"},
        "Button,2,1,,": {"Action": "kPasteFromClipboardPointerAction"},
    },
}


async def main(connection: iterm2.Connection):
    await set_global_preferences(connection)

    # Set the default profile *after* we've ensured dynamic profiles are loaded
    # from the proper path ("DynamicProfilesPath" preference key)
    await set_default_profile(connection)


async def set_default_profile(connection: iterm2.Connection):
    """
    Based on https://iterm2.com/python-api/examples/change_default_profile.html
    """
    all_profiles = await iterm2.PartialProfile.async_query(
        connection,
        properties=["Guid", "Name", "Dynamic Profile Filename"],
    )
    for profile in all_profiles:
        if profile.name == "Default" and profile.dynamic_profile_file_name is not None:
            print("Setting default profile to", profile.guid)
            await profile.async_make_default()
            break


async def set_global_preferences(connection: iterm2.Connection):
    """
    Set global configuration values in iTerm. This seems more portable than trying to
    track the whole .plist and also means I can focus on configuration values I care
    about, without having to worry about the rest of it or deal with schema upgrades.
    """
    failed = {}

    for pref, value in GLOBAL_PREFERENCES.items():
        if isinstance(pref, P):
            pref = pref.value

            print("Setting global preference", repr(pref), "to", repr(value))
        try:
            await iterm2.async_set_preference(
                connection,
                pref,  # type:ignore # https://gitlab.com/gnachman/iterm2/-/issues/11824
                value,
            )
        except Exception as err:
            failed[pref] = err

    if failed:
        await iterm2.Alert(
            "Failed to set some preferences",
            ", ".join(
                f"{getattr(pref, 'name', pref)}: {err}" for pref, err in failed.items()
            ),
        ).async_run(connection)


iterm2.run_until_complete(main)
