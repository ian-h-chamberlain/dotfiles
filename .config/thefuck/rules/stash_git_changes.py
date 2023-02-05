"""
Custom rule to automatically stash git changes if needed to perform an action.
"""

from thefuck.types import Command
from thefuck.utils import for_app


enabled_by_default = True
requires_output = True
priority = 500


@for_app("git", "yadm")
def match(command: Command) -> bool:
    return "Please commit your changes or stash them" in command.output


def get_new_command(command: Command) -> str:
    return f"git stash && {command.script} && git stash pop"
