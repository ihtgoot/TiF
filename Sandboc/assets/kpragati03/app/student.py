"""
Student Module

This module defines the Student data model representing a university student's
test submission details in the Time-Based Report Management System.
"""


class Student:
    """Represents a student and their test submission details.

    Attributes:
        roll_number (int): The unique identification number of the student (1-50).
        marks (int): The marks allocated based on submission sequence (0-50).
        submission_order (int): The 1-based order in which the student submitted (0 if unsubmitted).
        has_submitted (bool): Flag indicating whether the test code '001' was successfully submitted.
    """

    def __init__(self, roll_number: int) -> None:
        """Initialize a Student record with roll number.

        Args:
            roll_number (int): Unique student roll number (1 to 50).
        """
        self.roll_number: int = roll_number
        self.marks: int = 0
        self.submission_order: int = 0
        self.has_submitted: bool = False

    def record_submission(self, order: int, score: int) -> None:
        """Record the student's submission details.

        Args:
            order (int): The 1-based sequence order of submission.
            score (int): Marks allocated to the student based on submission sequence.
        """
        self.has_submitted = True
        self.submission_order = order
        self.marks = score

    def reset_submission(self) -> None:
        """Reset submission details when student record is cleared or re-verified."""
        self.has_submitted = False
        self.submission_order = 0
        self.marks = 0

    def to_dict(self) -> dict[str, int | bool]:
        """Convert student details to a dictionary representation.

        Returns:
            dict[str, int | bool]: Dictionary containing student attributes.
        """
        return {
            "roll_number": self.roll_number,
            "marks": self.marks,
            "submission_order": self.submission_order,
            "has_submitted": self.has_submitted,
        }

    def __str__(self) -> str:
        """User-friendly string representation of Student."""
        status = "Submitted" if self.has_submitted else "Not Submitted"
        order_str = str(self.submission_order) if self.has_submitted else "N/A"
        return (
            f"Roll No: {self.roll_number:02d} | "
            f"Status: {status:<13} | "
            f"Submission Order: {order_str:<4} | "
            f"Marks: {self.marks}"
        )

    def __repr__(self) -> str:
        """Developer representation of Student."""
        return (
            f"Student(roll_number={self.roll_number}, "
            f"marks={self.marks}, "
            f"submission_order={self.submission_order}, "
            f"has_submitted={self.has_submitted})"
        )
