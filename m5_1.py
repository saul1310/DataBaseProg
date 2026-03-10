import sqlite3
import sys

DB_FILE = "m5_1_student_courses.db"



def init_db(conn):
    cursor = conn.cursor()
    cursor.executescript("""
        CREATE TABLE IF NOT EXISTS students (
            student_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE
        );

        CREATE TABLE IF NOT EXISTS courses (
            course_id INTEGER PRIMARY KEY AUTOINCREMENT,
            course_name TEXT NOT NULL,
            day_of_week TEXT NOT NULL,
            start_time TEXT NOT NULL,
            end_time TEXT NOT NULL
        );
       
        CREATE TABLE IF NOT EXISTS enrollments (
            student_id INTEGER NOT NULL,
            course_id INTEGER NOT NULL,
            PRIMARY KEY (student_id, course_id),
            FOREIGN KEY (student_id) REFERENCES students(student_id),
            FOREIGN KEY (course_id) REFERENCES courses(course_id)
        );
    """)
    conn.commit()

# This function prompts the user to enter a student's name and email, then inserts the new student into the "students" table.
def enroll_student(conn):
    name = input("Enter student name: ")
    email = input("Enter student email: ")
    try:
        conn.execute("INSERT INTO students (name, email) VALUES (?, ?)", (name, email))
        conn.commit()
        print(f"Student '{name}' enrolled successfully.")
    # If the email already exists in the database, an IntegrityError will be raised due to the UNIQUE constraint on the email column. We catch this exception and print an error message to inform the user.
    except sqlite3.IntegrityError:
        print("Error: A student with that email already exists.")


def add_course(conn):
    course_name = input("Enter course name: ")
    day_of_week = input("Enter day of the week (e.g. Monday): ")
    start_time = input("Enter start time (e.g. 09:00): ")
    end_time = input("Enter end time (e.g. 10:30): ")
    conn.execute(
        "INSERT INTO courses (course_name, day_of_week, start_time, end_time) VALUES (?, ?, ?, ?)",
        (course_name, day_of_week, start_time, end_time),
    )
    conn.commit()
    print(f"Course '{course_name}' added successfully.")


def enroll_student_in_course(conn):
    # Show available students
    students = conn.execute("SELECT student_id, name, email FROM students ORDER BY student_id").fetchall()
    if not students:
        print("No students in the system. Please enroll a student first.")
        return
    print("\nAvailable Students:")
    for s in students:
        print(f"  {s[0]}. {s[1]} ({s[2]})")

    # Show available courses
    courses = conn.execute("SELECT course_id, course_name, day_of_week, start_time, end_time FROM courses ORDER BY course_id").fetchall()
    if not courses:
        print("No courses in the system. Please add a course first.")
        return
    print("\nAvailable Courses:")
    for c in courses:
        print(f"  {c[0]}. {c[1]} - {c[2]} {c[3]}-{c[4]}")

    try:
        student_id = int(input("\nEnter student ID: "))
        course_id = int(input("Enter course ID: "))
    except ValueError:
        print("Invalid input. Please enter numeric IDs.")
        return

    # Verify student and course exist
    student = conn.execute("SELECT name FROM students WHERE student_id = ?", (student_id,)).fetchone()
    course = conn.execute("SELECT course_name FROM courses WHERE course_id = ?", (course_id,)).fetchone()
    if not student:
        print("Student not found.")
        return
    if not course:
        print("Course not found.")
        return

    try:
        conn.execute("INSERT INTO enrollments (student_id, course_id) VALUES (?, ?)", (student_id, course_id))
        conn.commit()
        print(f"Student '{student[0]}' enrolled in '{course[0]}' successfully.")
    except sqlite3.IntegrityError:
        print("This student is already enrolled in that course.")


def query_students_in_course(conn):
    courses = conn.execute("SELECT course_id, course_name, day_of_week, start_time, end_time FROM courses ORDER BY course_id").fetchall()
    if not courses:
        print("No courses in the system.")
        return
    print("\nAvailable Courses:")
    for c in courses:
        print(f"  {c[0]}. {c[1]} - {c[2]} {c[3]}-{c[4]}")

    try:
        course_id = int(input("\nEnter course ID: "))
    except ValueError:
        print("Invalid input.")
        return

    rows = conn.execute("""
        SELECT s.student_id, s.name, s.email
        FROM students s
        JOIN enrollments e ON s.student_id = e.student_id
        WHERE e.course_id = ?
        ORDER BY s.name
    """, (course_id,)).fetchall()

    course = conn.execute("SELECT course_name FROM courses WHERE course_id = ?", (course_id,)).fetchone()
    if not course:
        print("Course not found.")
        return

    print(f"\nStudents in '{course[0]}':")
    if rows:
        for r in rows:
            print(f"  {r[0]}. {r[1]} ({r[2]})")
    else:
        print("  No students enrolled in this course.")


def query_courses_for_student(conn):
    students = conn.execute("SELECT student_id, name, email FROM students ORDER BY student_id").fetchall()
    if not students:
        print("No students in the system.")
        return
    print("\nAvailable Students:")
    for s in students:
        print(f"  {s[0]}. {s[1]} ({s[2]})")

    try:
        student_id = int(input("\nEnter student ID: "))
    except ValueError:
        print("Invalid input.")
        return

    student = conn.execute("SELECT name FROM students WHERE student_id = ?", (student_id,)).fetchone()
    if not student:
        print("Student not found.")
        return

    rows = conn.execute("""
        SELECT c.course_id, c.course_name, c.day_of_week, c.start_time, c.end_time
        FROM courses c
        JOIN enrollments e ON c.course_id = e.course_id
        WHERE e.student_id = ?
        ORDER BY c.course_name
    """, (student_id,)).fetchall()

    print(f"\nCourses for '{student[0]}':")
    if rows:
        for r in rows:
            print(f"  {r[0]}. {r[1]} - {r[2]} {r[3]}-{r[4]}")
    else:
        print("  This student is not enrolled in any courses.")


def query_schedule_by_day(conn):
    students = conn.execute("SELECT student_id, name, email FROM students ORDER BY student_id").fetchall()
    if not students:
        print("No students in the system.")
        return
    print("\nAvailable Students:")
    for s in students:
        print(f"  {s[0]}. {s[1]} ({s[2]})")

    try:
        student_id = int(input("\nEnter student ID: "))
    except ValueError:
        print("Invalid input.")
        return

    student = conn.execute("SELECT name FROM students WHERE student_id = ?", (student_id,)).fetchone()
    if not student:
        print("Student not found.")
        return

    day = input("Enter day of the week (e.g. Monday): ")

    rows = conn.execute("""
        SELECT c.course_name, c.start_time, c.end_time
        FROM courses c
        JOIN enrollments e ON c.course_id = e.course_id
        WHERE e.student_id = ? AND LOWER(c.day_of_week) = LOWER(?)
        ORDER BY c.start_time
    """, (student_id, day)).fetchall()

    print(f"\nSchedule for '{student[0]}' on {day}:")
    if rows:
        for r in rows:
            print(f"  {r[0]}: {r[1]} - {r[2]}")
    else:
        print(f"  No courses scheduled on {day}.")


def main():
    conn = sqlite3.connect(DB_FILE)
    init_db(conn)

    menu = """
===== Student Course Scheduler =====
1. Enroll a new student
2. Add a new course
3. Enroll a student in a course
4. View students in a course
5. View courses for a student
6. View schedule for a student on a day
7. Exit
====================================="""

    while True:
        print(menu)
        choice = input("Enter your choice (1-7): ").strip()

        if choice == "1":
            enroll_student(conn)
        elif choice == "2":
            add_course(conn)
        elif choice == "3":
            enroll_student_in_course(conn)
        elif choice == "4":
            query_students_in_course(conn)
        elif choice == "5":
            query_courses_for_student(conn)
        elif choice == "6":
            query_schedule_by_day(conn)
        elif choice == "7":
            print("Goodbye!")
            conn.close()
            sys.exit(0)
        else:
            print("Invalid choice. Please enter a number between 1 and 7.")


if __name__ == "__main__":
    main()
