"""
Main Application Entrypoint

This module implements the interactive, menu-driven CLI interface for the
Students Time-Based Report Management System.
"""

import sys
from report_manager import ReportManager
from utils import format_header, is_valid_roll_number, VALID_TEST_CODE


def print_menu() -> None:
    """Print the interactive console menu options."""
    print(format_header("STUDENTS TIME BASED REPORT MANAGEMENT SYSTEM"))
    print("  1. Verify & Accept Student Roll Number")
    print("  2. Submit Test (Code 001)")
    print("  3. Allocate Marks according to submission sequence")
    print("  4. Check Submission Status")
    print("  5. Search Student")
    print("  6. Delete Student")
    print("  7. Display All Students")
    print("  8. Exit")
    print("=" * 60)


def prompt_roll_number() -> int | None:
    """Helper function to prompt user for a valid roll number with validation error handling.

    Returns:
        int | None: Valid integer roll number or None if user entered invalid input.
    """
    raw_input = input("Enter Student Roll Number (1 - 50): ")
    is_valid, roll_num, error_msg = is_valid_roll_number(raw_input)
    if not is_valid:
        print(f"\n[!] {error_msg}")
        return None
    return roll_num


def handle_verify(manager: ReportManager) -> None:
    """Option 1: Verify & Accept Student Roll Number."""
    print(format_header("OPTION 1: VERIFY & ACCEPT ROLL NUMBER", char="-"))
    roll_num = prompt_roll_number()
    if roll_num is not None:
        _, msg = manager.validate_roll(roll_num)
        print(f"\n[+] {msg}")


def handle_submit(manager: ReportManager) -> None:
    """Option 2: Submit Test (Code 001)."""
    print(format_header("OPTION 2: SUBMIT TEST", char="-"))
    roll_num = prompt_roll_number()
    if roll_num is None:
        return

    test_code = input(f"Enter Test Code (Required: '{VALID_TEST_CODE}'): ")
    success, msg = manager.submit_test(roll_num, test_code)
    if success:
        print(f"\n[+] {msg}")
    else:
        print(f"\n[-] {msg}")


def handle_allocate(manager: ReportManager) -> None:
    """Option 3: Allocate Marks according to submission sequence."""
    print(format_header("OPTION 3: ALLOCATE MARKS", char="-"))
    roll_num = prompt_roll_number()
    if roll_num is None:
        return

    success, msg = manager.allocate_marks(roll_num)
    if success:
        print(f"\n[+] {msg}")
    else:
        print(f"\n[-] {msg}")


def handle_check_status(manager: ReportManager) -> None:
    """Option 4: Check Submission Status."""
    print(format_header("OPTION 4: CHECK SUBMISSION STATUS", char="-"))
    roll_num = prompt_roll_number()
    if roll_num is None:
        return

    _, msg, _ = manager.check_status(roll_num)
    print(f"\n[*] {msg}")


def handle_search(manager: ReportManager) -> None:
    """Option 5: Search Student."""
    print(format_header("OPTION 5: SEARCH STUDENT", char="-"))
    roll_num = prompt_roll_number()
    if roll_num is None:
        return

    success, msg, _ = manager.search_student(roll_num)
    if success:
        print(f"\n[+] {msg}")
    else:
        print(f"\n[-] {msg}")


def handle_delete(manager: ReportManager) -> None:
    """Option 6: Delete Student."""
    print(format_header("OPTION 6: DELETE STUDENT", char="-"))
    roll_num = prompt_roll_number()
    if roll_num is None:
        return

    success, msg = manager.delete_student(roll_num)
    if success:
        print(f"\n[+] {msg}")
    else:
        print(f"\n[-] {msg}")


def handle_display_all(manager: ReportManager) -> None:
    """Option 7: Display All Students."""
    print(format_header("OPTION 7: DISPLAY ALL STUDENTS", char="-"))
    students = manager.display_all_students()
    if not students:
        print("\n[*] No student records currently registered in the system.")
        return

    print(f"\nTotal Registered Students: {len(students)}\n")
    print("-" * 65)
    for student in students:
        print(f"  {student}")
    print("-" * 65)


def main() -> None:
    """Main CLI loop execution."""
    manager = ReportManager()

    while True:
        try:
            print_menu()
            choice = input("Enter choice (1-8): ").strip()

            if choice == "1":
                handle_verify(manager)
            elif choice == "2":
                handle_submit(manager)
            elif choice == "3":
                handle_allocate(manager)
            elif choice == "4":
                handle_check_status(manager)
            elif choice == "5":
                handle_search(manager)
            elif choice == "6":
                handle_delete(manager)
            elif choice == "7":
                handle_display_all(manager)
            elif choice == "8":
                print("\nExiting Student Report Management System. Goodbye!\n")
                sys.exit(0)
            else:
                print("\n[!] Invalid Choice! Please enter a number between 1 and 8.")
        except KeyboardInterrupt:
            print("\n\nSession terminated by user. Goodbye!")
            sys.exit(0)
        except Exception as e:
            print(f"\n[!] Unexpected Error: {e}")


if __name__ == "__main__":
    main()
