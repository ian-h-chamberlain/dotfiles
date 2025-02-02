#!/usr/bin/env python3

import asyncio
import enum
from bisect import bisect
from datetime import datetime

import iterm2


class Contrast(float, enum.Enum):
    """
    Presets for minimum contrast. This inherits from float so that the
    iTerm2 async plugin runtime can serialize it to JSON.
    """

    HIGH = 0.7
    MEDIUM = 0.3
    DEFAULT = 0.0


# This must be sorted for bisect to work properly:
_CONTRAST_CHANGES = {
    0: Contrast.HIGH,
    8: Contrast.DEFAULT,
    17: Contrast.MEDIUM,
    22: Contrast.HIGH,
}

_HOURS = list(_CONTRAST_CHANGES.keys())


async def main(connection):
    # Session.all_proxy would be preferable here but seems broken...
    app = await iterm2.async_get_app(connection)
    assert app
    sessions = app.buried_sessions
    for window in app.windows:
        for tab in window.tabs:
            sessions.extend(tab.sessions)

    profile = iterm2.LocalWriteOnlyProfile()

    while True:
        now = datetime.now()

        i = bisect(_HOURS, now.hour)
        min_contrast = _CONTRAST_CHANGES[_HOURS[i - 1]]

        if i < len(_HOURS):
            next_hour = _HOURS[i]
            next_day = now.day
        else:
            # We can skip straight to hour 8 for the next wakeup
            next_hour = _HOURS[1]
            next_day = now.day + 1

        wakeup = now.replace(
            day=next_day,
            hour=next_hour,
            minute=0,
            second=0,
            microsecond=0,
        )

        print(f"setting minimum contrast to {min_contrast}")
        profile.set_minimum_contrast(min_contrast)
        for session in sessions:
            try:
                await session.async_set_profile_properties(profile)
            except Exception as err:
                print("Failed to set profile properties:", err)
                continue

        print(f"Sleeping until approximately {wakeup} to adjust contrast again")
        await asyncio.sleep((wakeup - now).total_seconds())


iterm2.run_forever(main)
