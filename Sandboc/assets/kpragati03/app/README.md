# Students Time-Based Report Management System

A production-ready, object-oriented, console-based Python 3.13 application designed for university DSA assignments. This application manages student test code submissions, enforces validation constraints, tracks submission arrival times, allocates marks dynamically based on sequence order, and allows record lookups, deletions, and reporting.

---

## 📌 Contest Rules

- **Maximum Marks:** `50`
- **Valid Roll Numbers:** `1` to `50` (inclusive).
- **Test Code:** `001` (Only submissions with code `001` are accepted).
- **Time-Based Mark Allocation:**
  - **1st Submission:** 50 Marks
  - **2nd Submission:** 49 Marks
  - **3rd Submission:** 48 Marks
  - **$N^{\text{th}}$ Submission:** $\max(0, 50 - (N - 1))$ Marks
- **Floor Limit:** Marks never fall below `0`.
- **Submission Limit:** Each student roll number can submit at most **once**. Duplicate submissions are strictly rejected.

---

## ✨ Features

1. **Roll Number Verification:** Validates student roll numbers against the valid range `[1, 50]`.
2. **Test Submission (`001`):** Enforces correct test code matching, prevents duplicate submissions, and logs arrival sequence order.
3. **Sequence-Based Mark Allocation:** Automatically computes and records student marks based on submission order.
4. **Submission Status Check:** Displays whether a specific student has submitted their test.
5. **Fast Search:** Instant $O(1)$ search by roll number.
6. **Student Record Deletion:** Removes student records and updates queue state.
7. **Sorted Display:** Lists all registered students in ascending order of roll numbers.

---

## 🏗️ Data Structures Used & Justification

| Data Structure | Implementation | Purpose & DSA Justification |
| :--- | :--- | :--- |
| **Dictionary (Hash Map)** | `dict[int, Student]` | Used for storing student objects keyed by `roll_number`. Offers **$O(1)$ average time complexity** for instant verification, search, insertion, and deletion. |
| **Queue (FIFO)** | `collections.deque[int]` | Used to record the exact submission arrival order of student roll numbers. Preserves **First-In-First-Out (FIFO)** semantics with **$O(1)$ push operations**. |

---

## 📊 Complexity Analysis

### Time & Space Complexity Table

| Operation | Method Name | Data Structure | Time Complexity | Space Complexity | Description / Explanation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Roll Validation** | `validate_roll()` | Hash Map | **$O(1)$** | **$O(1)$** | Direct key lookup and range comparison. |
| **Test Submission** | `submit_test()` | Queue & Hash Map | **$O(1)$** | **$O(1)$** | $O(1)$ hash check + $O(1)$ queue append. |
| **Mark Allocation** | `allocate_marks()` | Hash Map | **$O(1)$** | **$O(1)$** | Arithmetic mark formula $\max(0, 50 - N + 1)$. |
| **Status Check** | `check_status()` | Hash Map | **$O(1)$** | **$O(1)$** | Direct key access in dictionary. |
| **Search Student** | `search_student()` | Hash Map | **$O(1)$** | **$O(1)$** | Instant lookup by roll number. |
| **Delete Student** | `delete_student()` | Hash Map & Queue | **$O(N)$** | **$O(N)$** | $O(1)$ key deletion + $O(N)$ queue rebuild. |
| **Display All** | `display_all_students()` | Array Sorting | **$O(K \log K)$** | **$O(K)$** | Sorting registered records ($K \le 50$). |

> **Overall Auxiliary Space Complexity:** **$O(K)$** where $K \le 50$ is the total number of registered students.

---

## 📁 Project Structure

```text
student_report_system/
│
├── main.py            # CLI entrypoint with interactive menu
├── student.py         # Student data model class (OOP)
├── report_manager.py  # ReportManager business logic & DSA implementations
├── utils.py           # Input validation helpers and console visual formatters
├── test_cases.py      # Python unittest automated test suite
├── requirements.txt   # Standard library dependency declaration
├── README.md          # Project documentation
├── Dockerfile         # Docker container configuration
└── .gitignore         # Git ignore rules
```

---

## 💻 Local Installation & Execution

### Prerequisites
- **Python 3.13+** installed on your system.

### Steps

1. **Clone or Navigate to the project directory:**
   ```bash
   cd student_report_system
   ```

2. **Run the Interactive CLI application:**
   ```bash
   python main.py
   ```

3. **Run the Automated Unit Test Suite:**
   ```bash
   python test_cases.py
   ```

---

## 🐳 Docker Guide

### 1. Build Docker Image
```bash
docker build -t student-report-system:latest .
```

### 2. Run Application in Interactive Mode
```bash
docker run -it --rm student-report-system:latest
```

### 3. Tag and Push Image to Docker Hub (Optional)
```bash
# Login to Docker Hub
docker login

# Tag the image (replace 'yourusername' with your actual Docker Hub username)
docker tag student-report-system:latest yourusername/student-report-system:v1.0

# Push image to Docker Hub
docker push yourusername/student-report-system:v1.0
```

---

## 💻 Sample Console Interaction

```text
============================================================
           STUDENTS TIME BASED REPORT MANAGEMENT SYSTEM           
============================================================
  1. Verify & Accept Student Roll Number
  2. Submit Test (Code 001)
  3. Allocate Marks according to submission sequence
  4. Check Submission Status
  5. Search Student
  6. Delete Student
  7. Display All Students
  8. Exit
============================================================
Enter choice (1-8): 2

------------------------------------------------------------
                    OPTION 2: SUBMIT TEST                   
------------------------------------------------------------
Enter Student Roll Number (1 - 50): 12
Enter Test Code (Required: '001'): 001

[+] Submission Accepted!
  - Roll Number     : 12
  - Submission Order: #1
  - Marks Allocated : 50 / 50

============================================================
           STUDENTS TIME BASED REPORT MANAGEMENT SYSTEM           
============================================================
Enter choice (1-8): 7

------------------------------------------------------------
                  OPTION 7: DISPLAY ALL STUDENTS            
------------------------------------------------------------
Total Registered Students: 1

-----------------------------------------------------------------
  Roll No: 12 | Status: Submitted     | Submission Order: 1    | Marks: 50
-----------------------------------------------------------------
```

---

## 🚀 Edge Cases Handled

1. **Invalid Roll Numbers:** Any roll number $< 1$, $> 50$, non-numeric, or blank input is rejected with clear error messages.
2. **Incorrect Test Code:** Entering codes other than `001` is rejected.
3. **Duplicate Submissions:** Submitting twice under the same roll number yields an explicit error.
4. **Marks Lower Limit:** Submissions beyond 50 receive `0` marks rather than negative numbers.
5. **Non-existent Search/Delete:** Gracefully handled with friendly error messages instead of runtime exceptions.

---

## 🔮 Future Improvements

1. **Persistent Database:** Integrate SQLite or JSON file storage to persist records across sessions.
2. **REST API / Web UI:** Expose endpoints using FastAPI/Flask and build a modern web dashboard.
3. **Real-Time Timestamping:** Record sub-second execution timestamps for high-concurrency submission tie-breaking.
