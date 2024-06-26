"""
Custom rule to temporarily run pre-commit without a pre-commit-config.yaml
"""

from thefuck.types import Command
from thefuck.utils import for_app

enabled_by_default = True
requires_output = True
priority = 500


@for_app("git")
def match(command: Command) -> bool:
    return "No .pre-commit-config.yaml file was found" in command.output


def get_new_command(command: Command) -> str:
    return f"PRE_COMMIT_ALLOW_NO_CONFIG=1 {command.script}"
