# Library Management System using SQL Project — P2

## Project Overview

**Project Title**: Library Management System
**Level**: Intermediate
**Database**: `library_db`

This is my practice version of a library management SQL project. I started from an existing project concept found on GitHub, then rebuilt the schema and queries myself and worked through it end-to-end to strengthen my SQL skills. It covers creating and managing tables, performing CRUD operations, and executing advanced SQL queries — showcasing database design, manipulation, and querying.

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1: Create a New Book Record**
-- `'978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.'`

```sql
INSERT INTO books
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```

**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '321 Main St'
WHERE member_id = 'C101';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with `issued_id = 'IS121'` from the `issued_status` table.

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with `emp_id = 'E101'`.
```sql
SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101';
```

**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use `GROUP BY` to find members who have issued more than one book.

```sql
SELECT 
	issued_member_id,
	COUNT(issued_id)
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_id) > 1;
```

### 3. CTAS (Create Table As Select)

**Task 6: Create Summary Tables**
-- Used CTAS to generate a new table showing each book and its total issued count.

```sql
CREATE TABLE book_cnt
AS
SELECT b.isbn,
	b.book_title,
	COUNT(i.issued_id)
FROM books AS b
LEFT JOIN issued_status AS i
ON b.isbn = i.issued_book_isbn
GROUP BY b.isbn, b.book_title;

SELECT * FROM book_cnt;
```

### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

**Task 7: Retrieve All Books in a Specific Category**

```sql
SELECT * FROM books
WHERE category = 'Fantasy';
```

**Task 8: Find Total Rental Income by Category**

```sql
SELECT 
	b.category,
	SUM(b.rental_price * cnt.count) AS total_rental_income
FROM books AS b
LEFT JOIN book_cnt AS cnt
ON b.isbn = cnt.isbn
GROUP BY b.category
ORDER BY total_rental_income DESC;
```
Another solution:

```sql
SELECT 
	b.category,
	SUM(b.rental_price) AS total_rental_income,
	COUNT(*)
FROM books AS b
JOIN issued_status AS i
ON b.isbn = i.issued_book_isbn
GROUP BY b.category
ORDER BY total_rental_income DESC;
```

**Task 9: List Members Who Registered in the Last 180 Days**
```sql
INSERT INTO members
VALUES
('C666', 'Gabriel Chen', '001 Beverly Hill', '2026-08-01'),
('C888', 'Rachel Green', '002 Beverly Hill', '2026-08-01'),
('C999', 'Monica Bing', '003 Beverly Hill', '2026-08-01');

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

**Task 10: List Employees with Their Branch Manager's Name and Branch Details**

```sql
SELECT 
	e1.*,
	b.manager_id,
	e2.emp_name AS manager
FROM employees AS e1
JOIN branch AS b
ON e1.branch_id = b.branch_id
JOIN employees AS e2
ON b.manager_id = e2.emp_id;
```

**Task 11: Create a Table of Books with Rental Price Above a Certain Threshold**
```sql
CREATE TABLE expensive_books
AS
SELECT *
FROM books
WHERE rental_price >= 7;

SELECT * FROM expensive_books;
```

**Task 12: Retrieve the List of Books Not Yet Returned**
```sql
SELECT * FROM return_status;

SELECT 
	issued_book_name
FROM issued_status AS i
LEFT JOIN return_status AS r
ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's id, member's name, book title, issue date, and days overdue.

```sql
SELECT 
	m.member_id,
	m.member_name,
	bk.book_title,
	i.issued_date,
	CURRENT_DATE - i.issued_date AS days_overdue
FROM issued_status AS i
JOIN members AS m
ON i.issued_member_id = m.member_id
JOIN books AS bk
ON i.issued_book_isbn = bk.isbn
LEFT JOIN return_status AS rs
ON i.issued_id = rs.issued_id
WHERE rs.return_date IS NULL
	AND CURRENT_DATE - i.issued_date > 30
ORDER BY m.member_name;
```

**Task 14: Update Book Status on Return**
Write a query to update the status of books in the `books` table to "Yes" when they are returned (based on entries in the `return_status` table).

```sql
-- update manually

SELECT * FROM books
WHERE status = 'no';

-- isbn '978-0-307-58837-1', '978-0-375-41398-8', '978-0-7432-7357-1' are not returned

-- check if they are in the return_status table
SELECT * FROM issued_status AS i
LEFT JOIN return_status AS rs
ON i.issued_id = rs.issued_id
WHERE i.issued_book_isbn IN ('978-0-307-58837-1', '978-0-375-41398-8', '978-0-7432-7357-1');

-- get the issued_id for each isbn first
SELECT * FROM return_status;

SELECT * FROM issued_status
WHERE issued_book_isbn IN ('978-0-307-58837-1', '978-0-375-41398-8', '978-0-7432-7357-1');

-- issued_id values are 'IS134', 'IS135', 'IS136'

INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
VALUES
('RS200', 'IS134', CURRENT_DATE, 'Good');

UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-375-41398-8';

-- check if it's updated
SELECT * FROM books
WHERE isbn = '978-0-375-41398-8';

-- Now automate it with a stored procedure

CREATE OR REPLACE PROCEDURE add_return_record(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(15))
LANGUAGE plpgsql
AS $$

DECLARE
	v_isbn VARCHAR(25);
	v_book_name VARCHAR(75);

BEGIN -- same logic as the manual steps above
	INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
	VALUES 
	(p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);
		 
	SELECT 
		issued_book_isbn,
		issued_book_name
		INTO
		v_isbn,
		v_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id;

	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'Thank you for returning the book: %', v_book_name;

END;
$$

-- testing the procedure with IS135, book name 'Sapiens: A Brief History of Humankind'
SELECT status FROM books
WHERE isbn = '978-0-307-58837-1';

CALL add_return_record('RS201', 'IS135', 'Good');
```

**Task 15: Branch Performance Report**
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
CREATE TABLE branch_reports
AS
SELECT 
            b.branch_id,
            b.manager_id,
            COUNT(i.issued_id) AS number_of_books_issued,
            COUNT(rs.return_id) AS number_of_books_returned,
            SUM(bk.rental_price) AS total_revenue
FROM branch AS b
JOIN employees AS e
ON b.branch_id = e.branch_id
JOIN issued_status AS i
ON e.emp_id = i.issued_emp_id
LEFT JOIN return_status AS rs
ON rs.issued_id = i.issued_id
JOIN books AS bk
ON bk.isbn = i.issued_book_isbn
GROUP BY b.branch_id, b.manager_id;

SELECT * FROM branch_reports;
```

**Task 16: CTAS — Create a Table of Active Members**
Use the `CREATE TABLE AS` (CTAS) statement to create a new table `active_members` containing members who have issued at least one book in the last 6 months.

```sql
DROP TABLE IF EXISTS active_members;
CREATE TABLE active_members
AS
SELECT *
FROM members
WHERE member_id IN (
					SELECT DISTINCT issued_member_id
					FROM issued_status
					WHERE issued_date >= CURRENT_DATE - INTERVAL '6 months'
					);
SELECT * FROM active_members;
```

**Task 17: Find Employees with the Most Book Issues Processed**
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT 
	e.emp_name,
	e.branch_id,
	COUNT(i.issued_id) AS num_of_books_issued
FROM issued_status AS i
JOIN employees AS e
ON i.issued_emp_id = e.emp_id
GROUP BY e.emp_name, e.branch_id
ORDER BY num_of_books_issued DESC
LIMIT 3;
```

**Task 18: Identify Members Issuing High-Risk Books**
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.

```sql
SELECT 
	e.emp_name,
	i.issued_book_name,
	COUNT(i.issued_id) AS num_of_damaged_book_issued
FROM issued_status AS i
JOIN employees AS e
ON  e.emp_id = i.issued_emp_id
LEFT JOIN return_status AS rs
ON rs.issued_id = i.issued_id
WHERE rs.book_quality = 'Damaged'
GROUP BY e.emp_name, i.issued_book_name;
```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project was a hands-on exercise in applying SQL to build and manage a library management system. Working through database setup, data manipulation, and advanced querying helped me strengthen my foundation in data management and analysis.



## About This Version

This project is based on a publicly available library management SQL exercise. I reused the original concept and schema design, rebuilt the queries myself, and practiced the full workflow — including fixing a few mismatches between the original task descriptions and their reference solutions 

— Gabriel
