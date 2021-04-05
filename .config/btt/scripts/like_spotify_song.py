#!/usr/bin/env python3

"""Simple script to like the currently playing spotify song"""

import logging
import shlex
import subprocess
import sys
from typing import Union

import spotipy
import spotipy.oauth2

# CLIENT_ID and CLIENT_SECRET are .gitignored
import local_secrets

_REDIRECT_URL = "https://corewa.rs/callback"
_SCOPES = ["user-library-read", "user-library-modify", "user-read-currently-playing"]

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
    )

    spotify = spotipy.Spotify(client_credentials_manager=auth_client)
    try:
        track = spotify.current_user_playing_track()["item"]
    except spotipy.SpotifyException as err:
        msg = f"Failed to get track data: {err}"
        LOG.error(msg)
        return msg

    track_ids = [track["id"]]
    artist_names = ", ".join(artist["name"] for artist in track["artists"])
    human_track = f"{track['name']} by {artist_names}"
    LOG.info(f"Currently playing: {human_track}")

    should_save = True
    try:
        if spotify.current_user_saved_tracks_contains(track_ids):
            should_save = False
    except spotipy.SpotifyException as err:
        LOG.warning(f"Failed to check if track already saved: {err}")

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

    applescript = (
        f'display notification "{artist_names}" '
        f'with title "{action}" '
        f'subtitle "{track["name"]}"'
    )

    try:
        LOG.info("Displaying notification")
        subprocess.run(
            ["/usr/bin/osascript", "-e", applescript],
            shell=False,
            check=True,
        )
    except subprocess.CalledProcessError as err:
        LOG.warning(f"Failed to display notification: {err}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
