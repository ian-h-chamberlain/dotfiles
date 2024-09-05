#!/usr/bin/env python3

"""Simple script to like the currently playing spotify song"""

import logging
import pathlib
import subprocess
import sys
from typing import Optional, Union

import spotipy
import spotipy.oauth2

# CLIENT_ID and CLIENT_SECRET are .gitignored
import local_secrets

_REDIRECT_URL = "https://localhost/callback"
_SCOPES = ["user-library-read", "user-library-modify", "user-read-currently-playing"]

_NOTIF_SCRIPT = pathlib.Path(__file__).parent / "run_applescript.app"

LOG = logging.getLogger(__name__)


def main() -> Union[str, int]:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s: %(message)s",
        filename="like_spotify_song.log",
    )

    auth_client = spotipy.oauth2.SpotifyOAuth(
        client_id=local_secrets.CLIENT_ID,
        client_secret=local_secrets.CLIENT_SECRET,
        scope=" ".join(_SCOPES),
        redirect_uri=_REDIRECT_URL,
        open_browser=False,
    )

    spotify = spotipy.Spotify(client_credentials_manager=auth_client)
    try:
        track_data = spotify.current_user_playing_track()
    except spotipy.SpotifyException as err:
        msg = f"Failed to get track data: {err}"
        LOG.error(msg)
        return msg

    if track_data is None:
        msg = "No track data available; is this a private listening session?"
        _send_notification(
            contents=msg,
            title="Track not found",
        )
        LOG.info(msg)
        return msg

    try:
        track = track_data["item"]
    except KeyError:
        msg = f"Missing track data for currently playing song"
        LOG.error(msg)
        LOG.debug(f"Track data: {track_data!r}")
        return msg

    track_ids = [track["id"]]
    artist_names = ", ".join(artist["name"] for artist in track["artists"])
    human_track = f"{track['name']} by {artist_names}"
    LOG.info(f"Currently playing: {human_track}")

    should_save = True
    try:
        library_already_contains = spotify.current_user_saved_tracks_contains(track_ids)
    except spotipy.SpotifyException as err:
        LOG.warning(f"Failed to check if track already saved: {err}")
    else:
        should_save = not library_already_contains[0]

    if should_save:
        LOG.info("Will attempt to save track")
        action = "Saved to Library"
        try:
            spotify.current_user_saved_tracks_add([track["id"]])
        except spotipy.SpotifyException as err:
            LOG.error(err)
            return f"Failed to save song: {err}"

        LOG.info(f"Saved {human_track} to library")
    else:
        action = "Already in Library"
        LOG.info("Track already saved to library")

    _send_notification(
        title=track["name"],
        subtitle=artist_names,
        contents=action,
    )

    return 0


def _send_notification(
    *,
    title: str,
    contents: str,
    subtitle: Optional[str] = None,
) -> None:
    applescript = f'display notification "{contents}" with title "{title}"'
    if subtitle:
        applescript += f' subtitle "{subtitle}"'

    LOG.info(f"Displaying notification {title!r}")
    cmd = ["open", "-a", str(_NOTIF_SCRIPT.absolute())]
    LOG.debug(f"Command: APPLESCRIPT={applescript!r} {cmd!r}")

    try:
        subprocess.run(cmd, env={"APPLESCRIPT": applescript}, shell=False, check=True)
    except subprocess.CalledProcessError as err:
        LOG.warning(f"Failed to display notification: {err}")


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as err:
        LOG.exception(f"Unhandled exception: {err}")
        _send_notification(
            title="Error",
            subtitle="Failed to like currently playing song",
            contents=str(err),
        )
        sys.exit(1)
