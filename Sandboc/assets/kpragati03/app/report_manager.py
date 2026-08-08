"""
ReportManager Module

This module contains the ReportManager class which handles all core business operations,
submission sequence tracking, mark allocations, student lookups, and deletions.

Data Structures Chosen & DSA Justification:
-------------------------------------------
1. Dictionary (`self.students: Dict[int, Student]`):
   - Fast O(1) average time complexity for lookup, insertion, verification, and deletion by roll number.
   - Key is `roll_number` (1 to 50), Value is the `Student` object.

2. Queue (`self.submission_queue: deque[int]`):
   - First-In-First-Out (FIFO) queue implemented using `collections.deque`.
   - Efficient O(1) enqueuing of student roll numbers in exact submission order.
   - Preserves historical submission sequence for contest rule validation and mark calculation.
"""

from collections import deque
from typing import Dict, List, Optional, Tuple

from student import Student
from utils import (
    MAX_MARKS,
    MAX_ROLL_NUMBER,
    MIN_ROLL_NUMBER,
    VALID_TEST_CODE,
    is_valid_roll_number,
)


class ReportManager:
    """Manages student records, test submission sequence, and contest grading."""

    def __init__(self) -> None:
        """Initialize ReportManager with storage data structures."""
        # Hash Map storing student objects indexed by roll number
        self.students: Dict[int, Student] = {}

        # FIFO Queue maintaining submission order of roll numbers
        self.submission_queue: deque[int] = deque()

    def validate_roll(self, roll_number: int) -> Tuple[bool, str]:
        """Validate if roll number is within [1, 50] and register student if new.

        Complexity:
            Time Complexity: O(1) hash map lookup/insertion.
            Space Complexity: O(1) per student.

        Args:
            roll_number (int): Student roll number.

        Returns:
            Tuple[bool, str]: Success status and descriptive message.
        """
        if roll_number < MIN_ROLL_NUMBER or roll_number > MAX_ROLL_NUMBER:
            return (
                False,
                f"Validation Failed: Roll number {roll_number} is invalid! Must be between {MIN_ROLL_NUMBER} and {MAX_ROLL_NUMBER}."
            )

        if roll_number not in self.students:
            self.students[roll_number] = Student(roll_number)
            return True, f"Success: Roll number {roll_number} verified and registered into system."

        return True, f"Success: Roll number {roll_number} verified. Student record exists."

    def submit_test(self, roll_number: int, test_code: str) -> Tuple[bool, str]:
        """Accept test submission, check rules, and allocate marks based on submission sequence.

        Rules:
            - Valid roll numbers only (1 to 50).
            - Test code must match '001'.
            - Duplicate submissions rejected.
            - 1st submission gets 50 marks.
            - Every subsequent submission loses 1 mark (50, 49, 48, ... down to min 0).

        Complexity:
            Time Complexity: O(1) lookup and enqueuing.
            Space Complexity: O(1) auxiliary space.

        Args:
            roll_number (int): Student roll number.
            test_code (str): Entered test code string.

        Returns:
            Tuple[bool, str]: Success status and descriptive outcome message.
        """
        # Step 1: Validate Roll Number
        is_valid, msg = self.validate_roll(roll_number)
        if not is_valid:
            return False, msg

        student = self.students[roll_number]

        # Step 2: Validate Test Code
        if test_code.strip() != VALID_TEST_CODE:
            return (
                False,
                f"Submission Failed: Incorrect Test Code '{test_code}'. Test Code must be '{VALID_TEST_CODE}'."
            )

        # Step 3: Check Duplicate Submission
        if student.has_submitted:
            return (
                False,
                f"Submission Failed: Student with Roll Number {roll_number} has ALREADY submitted Test Code {VALID_TEST_CODE}."
            )

        # Step 4: Determine Submission Sequence Order (1-indexed)
        order = len(self.submission_queue) + 1

        # Step 5: Calculate Time-Based Marks (50 for 1st, 49 for 2nd, ..., min 0)
        allocated_marks = max(0, MAX_MARKS - (order - 1))

        # Step 6: Record Submission Details and Queue
        student.record_submission(order=order, score=allocated_marks)
        self.submission_queue.append(roll_number)

        return (
            True,
            f"Submission Accepted!\n"
            f"  - Roll Number     : {roll_number}\n"
            f"  - Submission Order: #{order}\n"
            f"  - Marks Allocated : {allocated_marks} / {MAX_MARKS}"
        )

    def allocate_marks(self, roll_number: int) -> Tuple[bool, str]:
        """Check or recalculate allocated marks for a given student roll number.

        Complexity:
            Time Complexity: O(1) dictionary lookup.
            Space Complexity: O(1).

        Args:
            roll_number (int): Student roll number.

        Returns:
            Tuple[bool, str]: Success status and mark details message.
        """
        if roll_number not in self.students:
            return False, f"Allocation Check Failed: Student Roll Number {roll_number} is not registered."

        student = self.students[roll_number]
        if not student.has_submitted:
            return (
                False,
                f"Allocation Check Failed: Roll Number {roll_number} has not submitted Test Code {VALID_TEST_CODE} yet."
            )

        return (
            True,
            f"Marks Allocated for Roll Number {roll_number}:\n"
            f"  - Submission Order: #{student.submission_order}\n"
            f"  - Final Marks     : {student.marks} / {MAX_MARKS}"
        )

    def check_status(self, roll_number: int) -> Tuple[bool, str, Optional[Student]]:
        """Check submission status of a student by roll number.

        Complexity:
            Time Complexity: O(1).
            Space Complexity: O(1).

        Args:
            roll_number (int): Student roll number.

        Returns:
            Tuple[bool, str, Optional[Student]]: Status flag, status message, and student instance.
        """
        if roll_number not in self.students:
            return False, f"Status: Student Roll Number {roll_number} is not registered in the system.", None

        student = self.students[roll_number]
        if student.has_submitted:
            msg = (
                f"Status: SUBMITTED\n"
                f"  - Roll Number     : {student.roll_number}\n"
                f"  - Submission Order: #{student.submission_order}\n"
                f"  - Allocated Marks : {student.marks}"
            )
        else:
            msg = f"Status: NOT SUBMITTED\n  - Roll Number {student.roll_number} is verified but test is pending."

        return True, msg, student

    def search_student(self, roll_number: int) -> Tuple[bool, str, Optional[Student]]:
        """Search student record by roll number.

        Complexity:
            Time Complexity: O(1) dictionary lookup.
            Space Complexity: O(1).

        Args:
            roll_number (int): Student roll number.

        Returns:
            Tuple[bool, str, Optional[Student]]: Found status, message, and Student object.
        """
        if roll_number not in self.students:
            return False, f"Search Error: Student with Roll Number {roll_number} not found.", None

        student = self.students[roll_number]
        return True, f"Student Found:\n  {student}", student

    def delete_student(self, roll_number: int) -> Tuple[bool, str]:
        """Delete student record by roll number and remove from submission queue if applicable.

        Complexity:
            Time Complexity: O(N) where N is number of queue items (to rebuild queue cleanly).
            Space Complexity: O(N) temporary space for queue reconstruction.

        Args:
            roll_number (int): Student roll number to delete.

        Returns:
            Tuple[bool, str]: Success flag and descriptive message.
        """
        if roll_number not in self.students:
            return False, f"Delete Error: Student with Roll Number {roll_number} does not exist."

        # Remove from hash map
        del self.students[roll_number]

        # Clean up queue if present
        if roll_number in self.submission_queue:
            new_queue = deque([r for r in self.submission_queue if r != roll_number])
            self.submission_queue = new_queue

        return True, f"Success: Student with Roll Number {roll_number} has been deleted."

    def display_all_students(self) -> List[Student]:
        """Retrieve list of all registered students sorted by roll number.

        Complexity:
            Time Complexity: O(K log K) where K is total registered students (at most 50).
            Space Complexity: O(K) space for sorted list.

        Returns:
            List[Student]: List of Student objects sorted by roll number.
        """
        return sorted(self.students.values(), key=lambda s: s.roll_number)
