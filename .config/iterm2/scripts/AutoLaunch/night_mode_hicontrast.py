#!/usr/bin/env python3

from datetime import datetime
import time
import iterm2
import asyncio

# For now, this will be manually triggered, I guess?

HI_CONTRAST = 0.45
DEFAULT_CONTRAST = 0.0

START_HOUR = 22
END_HOUR = 8

async def main(connection):
    app = await iterm2.async_get_app(connection)
    session = app.current_terminal_window.current_tab.current_session
    change = iterm2.LocalWriteOnlyProfile()

    while True:
        now = datetime.now()

        if now.hour >= START_HOUR or now.hour < END_HOUR:
            min_contrast = HI_CONTRAST
            wakeup = now.replace(
                day=now.day+1,
                hour=END_HOUR,
                minute=0,
                second=0,
                microsecond=0,
            )
        else:
            min_contrast = DEFAULT_CONTRAST
            wakeup = now.replace(
                hour=START_HOUR,
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
