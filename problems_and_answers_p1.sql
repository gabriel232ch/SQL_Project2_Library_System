SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

-- Task 2: Update an Existing Member's Address
SELECT * FROM members;

UPDATE members
SET member_address = '321 Main St'
WHERE member_id = 'C101';


-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status;

DELETE FROM issued_status
WHERE issued_id = 'IS121';
-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
	issued_member_id,
	COUNT(issued_id)
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_id) > 1;

--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
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

-- Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Fantasy';

-- Task 8: Find Total Rental Income by Category:

SELECT 
	b.category,
	SUM(b.rental_price * cnt.count) AS total_rental_income
FROM books AS b
LEFT JOIN book_cnt AS cnt
ON b.isbn = cnt.isbn
GROUP BY b.category
ORDER BY total_rental_income DESC;

-- another solution could be:

SELECT 
	b.category,
	SUM(b.rental_price) AS total_rental_income,
	COUNT(*)
FROM books AS b
JOIN issued_status AS i
ON b.isbn = i.issued_book_isbn
GROUP BY b.category
ORDER BY total_rental_income DESC;

-- task 9 List Members Who Registered in the Last 180 Days:

INSERT INTO members
VALUES
('C666', 'Gabriel Chen', '001 Beverly Hill', '2026-08-01'),
('C888', 'Rachel Green', '002 Beverly Hill', '2026-08-01'),
('C999', 'Monica Bing', '003 Beverly Hill', '2026-08-01')

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

-- Task 10 List Employees with Their Branch Manager's Name and their branch details:

SELECT 
	e1.*,
	b.manager_id,
	e2.emp_name AS manager
FROM employees AS e1
JOIN branch AS b
ON e1.branch_id = b.branch_id
JOIN employees AS e2
ON b.manager_id = e2.emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE expensive_books
AS
SELECT *
FROM books
WHERE rental_price >= 7;

SELECT * FROM expensive_books;

-- ask 12: Retrieve the List of Books Not Yet Returned

SELECT * FROM return_status 

SELECT 
	issued_book_name
FROM issued_status AS i
LEFT JOIN return_status AS r
ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL;





