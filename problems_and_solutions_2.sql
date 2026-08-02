-- SQL project 2 library system part 2
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM books;
SELECT * FROM return_status;
/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

-- problem breaking down: issued_status == members == books == return_status
-- days overdue = current_date - issued_date > 30, filter out those already returned

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

/*Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" 
when they are returned (based on entries in the return_status table).
*/

-- objective update return status automatically

-- update manually

SELECT * FROM books
WHERE status = 'no'

-- isbn '978-0-307-58837-1','978-0-375-41398-8','978-0-7432-7357-1'are not returned

-- check if they are in the return_status table
SELECT * FROM issued_status AS i
LEFT JOIN return_status AS rs
ON i.issued_id = rs.issued_id
WHERE i.issued_book_isbn = '978-0-307-58837-1'
	AND i.issued_book_isbn = '978-0-375-41398-8'
	AND i.issued_book_isbn = '978-0-7432-7357-1'

-- update first, get the issued_id
SELECT * FROM return_status;

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1'
	OR issued_book_isbn = '978-0-375-41398-8'
	OR issued_book_isbn = '978-0-7432-7357-1'

-- issued_id are 'IS134', 'IS135', 'IS136'

INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
VALUES
('RS200', 'IS134', CURRENT_DATE, 'Good');

UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-375-41398-8';

-- check if it's updated
SELECT * FROM books
WHERE isbn = '978-0-375-41398-8';

-- Now updating it automatically, we need to store a procedure

CREATE OR REPLACE PROCEDURE add_return_record(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(15))
LANGUAGE plpgsql
AS $$

DECLARE
	v_isbn VARCHAR(25);
	v_book_name VARCHAR(75);

BEGIN -- the procedure we have done above
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

-- testing procedure by using IS135, which book name is 'Sapiens: A Brief History of Humankind'
SELECT status FROM books
WHERE isbn = '978-0-307-58837-1';

CALL add_return_record ('RS201', 'IS135', 'Good');

/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned, 
and the total revenue generated from book rentals.
*/

SELECT * FROM branch
SELECT * FROM employees
SELECT * FROM books
SELECT * FROM issued_status
SELECT * FROM return_status

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

/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table 
active_members containing members who have issued at least one book in the last 6 months.
*/
DROP TABLE IF EXISTS active_members;
CREATE TABLE active_members
AS
SELECT *
FROM members
WHERE member_id IN (
					SELECT DISTINCT issued_member_id
					FROM issued_status
					WHERE issued_date >= CURRENT_DATE - INTERVAL'6 months'
					);
SELECT * FROM active_members;

/* Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed 
the most book issues. Display the employee name, number of books processed, 
and their branch.*/

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

/*
Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice 
with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.
*/

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


	










