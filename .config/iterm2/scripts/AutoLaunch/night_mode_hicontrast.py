#!/usr/bin/env python3

from datetime import datetime
import time
import iterm2
import asyncio
import enum
from bisect import bisect


class Contrast(float, enum.Enum):
    """
    Presets for minimum contrast. This inherits from float so that the
    iTerm2 async plugin runtime can serialize it to JSON.
    """
    HIGH = 0.6
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
    app = await iterm2.async_get_app(connection)
    session = app.current_terminal_window.current_tab.current_session
    change = iterm2.LocalWriteOnlyProfile()

    while True:
        now = datetime.now()

        i = bisect(_HOURS, now.hour)
        min_contrast = _CONTRAST_CHANGES[_HOURS[i-1]]

        if i < len(_HOURS):
            next_hour = _HOURS[i]
            next_day = now.day
        else:
            # We can skip straight to hour 8 for the next wakeup
            next_hour = _HOURS[1]
            next_day = now.day+1

        wakeup = now.replace(
            day=next_day,
            hour=next_hour,
            minute=0,
            second=0,
            microsecond=0,
        )

        print(f"setting minimum contrast to {min_contrast}")
        change.set_minimum_contrast(min_contrast)
        await session.async_set_profile_properties(change)

        print(f"Sleeping until approximately {wakeup} to adjust contrast again")
        await asyncio.sleep((wakeup - now).total_seconds())

iterm2.run_forever(main)
