"""
Utils Module

Helper constants and utility functions for validation and console formatting
in the Students Time-Based Report Management System.
"""

from typing import Tuple, Optional

# Global System Constants
MIN_ROLL_NUMBER: int = 1
MAX_ROLL_NUMBER: int = 50
MAX_MARKS: int = 50
VALID_TEST_CODE: str = "001"


def is_valid_roll_number(roll_input: str) -> Tuple[bool, Optional[int], str]:
    """Validate whether the user input is an integer roll number within range [1, 50].

    Args:
        roll_input (str): Raw user string input.

    Returns:
        Tuple[bool, Optional[int], str]:
            - success flag (bool)
            - parsed integer roll number or None
            - user message explaining validation outcome
    """
    cleaned = roll_input.strip()
    if not cleaned:
        return False, None, "Error: Input cannot be empty. Please enter a number."

    if not cleaned.isdigit() and not (cleaned.startswith('-') and cleaned[1:].isdigit()):
        return False, None, f"Error: '{roll_input}' is not a valid integer. Enter a number between 1 and 50."

    try:
        roll_num = int(cleaned)
    except ValueError:
        return False, None, "Error: Invalid numeric input."

    if roll_num < MIN_ROLL_NUMBER or roll_num > MAX_ROLL_NUMBER:
        return (
            False,
            None,
            f"Error: Roll number {roll_num} is out of bounds! Valid range is {MIN_ROLL_NUMBER} to {MAX_ROLL_NUMBER}."
        )

    return True, roll_num, f"Success: Roll number {roll_num} is valid."


def format_header(title: str, char: str = "=", width: int = 60) -> str:
    """Generate formatted section headers for CLI output.

    Args:
        title (str): Header title text.
        char (str): Border character.
        width (int): Total line width.

    Returns:
        str: Formatted string banner.
    """
    border = char * width
    centered_title = title.center(width - 4)
    return f"\n{border}\n  {centered_title}  \n{border}"
