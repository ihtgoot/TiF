"""
Test Suite Module for Students Time-Based Report Management System

Automated tests covering all functional requirements, edge cases, validation rules,
and marks allocation logic.
"""

import unittest
from report_manager import ReportManager
from utils import is_valid_roll_number, VALID_TEST_CODE, MAX_MARKS


class TestStudentReportSystem(unittest.TestCase):
    """Test suite using Python unittest framework."""

    def setUp(self) -> None:
        """Set up fresh ReportManager instance before each test."""
        self.manager = ReportManager()

    # 1. Valid Roll Number Test
    def test_valid_roll_number(self) -> None:
        """Test roll numbers 1, 25, and 50 are accepted."""
        for roll in [1, 25, 50]:
            is_valid, roll_num, msg = is_valid_roll_number(str(roll))
            self.assertTrue(is_valid)
            self.assertEqual(roll_num, roll)

            success, reg_msg = self.manager.validate_roll(roll)
            self.assertTrue(success)
            self.assertIn("verified", reg_msg.lower())

    # 2. Invalid Roll Number Test
    def test_invalid_roll_number(self) -> None:
        """Test out of bounds and non-numeric inputs are rejected."""
        invalid_inputs = ["0", "51", "-5", "100", "abc", "", "   "]
        for inp in invalid_inputs:
            is_valid, roll_num, msg = is_valid_roll_number(inp)
            self.assertFalse(is_valid)
            self.assertIsNone(roll_num)
            self.assertTrue(msg.startswith("Error:"))

    # 3. Wrong Test Code Test
    def test_wrong_test_code(self) -> None:
        """Test submission with invalid test codes (e.g., '002', 'abc')."""
        success, msg = self.manager.submit_test(roll_number=1, test_code="002")
        self.assertFalse(success)
        self.assertIn("Incorrect Test Code", msg)

    # 4. Duplicate Submission Test
    def test_duplicate_submission(self) -> None:
        """Test that a student cannot submit Test Code 001 twice."""
        # First submission
        success1, _ = self.manager.submit_test(roll_number=5, test_code=VALID_TEST_CODE)
        self.assertTrue(success1)

        # Second submission
        success2, msg2 = self.manager.submit_test(roll_number=5, test_code=VALID_TEST_CODE)
        self.assertFalse(success2)
        self.assertIn("ALREADY submitted", msg2)

    # 5. Submission Order & Marks Calculation Test
    def test_submission_order_and_marks(self) -> None:
        """Test that 1st student gets 50 marks, 2nd gets 49, 3rd gets 48."""
        # 1st submission
        ok1, _ = self.manager.submit_test(roll_number=10, test_code=VALID_TEST_CODE)
        self.assertTrue(ok1)
        s1 = self.manager.students[10]
        self.assertEqual(s1.submission_order, 1)
        self.assertEqual(s1.marks, 50)

        # 2nd submission
        ok2, _ = self.manager.submit_test(roll_number=20, test_code=VALID_TEST_CODE)
        self.assertTrue(ok2)
        s2 = self.manager.students[20]
        self.assertEqual(s2.submission_order, 2)
        self.assertEqual(s2.marks, 49)

        # 3rd submission
        ok3, _ = self.manager.submit_test(roll_number=30, test_code=VALID_TEST_CODE)
        self.assertTrue(ok3)
        s3 = self.manager.students[30]
        self.assertEqual(s3.submission_order, 3)
        self.assertEqual(s3.marks, 48)

    # 6. Marks Floor at Zero Test
    def test_marks_never_negative(self) -> None:
        """Test that marks never drop below 0 even for >50 submissions."""
        # Simulate 52 submissions across valid roll numbers
        for i in range(1, 51):
            self.manager.submit_test(roll_number=i, test_code=VALID_TEST_CODE)

        # Student 50 (50th submission) should have 1 mark
        self.assertEqual(self.manager.students[50].marks, 1)

    # 7. Search Existing Student
    def test_search_existing_student(self) -> None:
        """Test searching for registered student returns student data."""
        self.manager.validate_roll(15)
        found, msg, student = self.manager.search_student(15)
        self.assertTrue(found)
        self.assertIsNotNone(student)
        self.assertEqual(student.roll_number, 15)

    # 8. Search Missing Student
    def test_search_missing_student(self) -> None:
        """Test searching for un-registered student returns error."""
        found, msg, student = self.manager.search_student(99)
        self.assertFalse(found)
        self.assertIsNone(student)
        self.assertIn("not found", msg)

    # 9. Delete Existing Student
    def test_delete_existing_student(self) -> None:
        """Test deleting existing student removes record from hash map and queue."""
        self.manager.submit_test(7, VALID_TEST_CODE)
        self.assertIn(7, self.manager.students)

        success, msg = self.manager.delete_student(7)
        self.assertTrue(success)
        self.assertNotIn(7, self.manager.students)
        self.assertNotIn(7, self.manager.submission_queue)

    # 10. Delete Missing Student
    def test_delete_missing_student(self) -> None:
        """Test deleting missing student returns error."""
        success, msg = self.manager.delete_student(42)
        self.assertFalse(success)
        self.assertIn("does not exist", msg)


if __name__ == "__main__":
    unittest.main(verbosity=2)
