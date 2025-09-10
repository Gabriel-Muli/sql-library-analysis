DROP DATABASE IF EXISTS library_db;
CREATE DATABASE library_db;

DROP TABLE IF EXISTS books;
CREATE TABLE BOOKS(
isbn VARCHAR(30) PRIMARY KEY ,
book_title VARCHAR(70),	
category VARCHAR(30),
rental_price FLOAT,
statu_s	VARCHAR(5),
author	VARCHAR(30),
publisher VARCHAR(30)
);

DROP TABLE IF EXISTS branch;
CREATE TABLE branch(
branch_id VARCHAR(5) PRIMARY KEY,	
manager_id	VARCHAR(5),
branch_address	VARCHAR(15),
contact_no VARCHAR(15)
);

DROP TABLE IF EXISTS employees;
CREATE TABLE employees(
emp_id VARCHAR(5) PRIMARY KEY,
emp_name VARCHAR(20),
positio_n VARCHAR(10),
salary	INT,
branch_id VARCHAR(5),
CONSTRAINT branch_fok FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

DROP TABLE IF EXISTS members;
CREATE TABLE members(
member_id VARCHAR(5) PRIMARY KEY,
member_name	VARCHAR(15),
member_address	VARCHAR(15),
reg_date DATE
);

DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status(
issued_id VARCHAR(7) PRIMARY KEY,
issued_member_id VARCHAR(5),
CONSTRAINT member_fok FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
issued_book_name VARCHAR(60),
issued_date	DATE,
issued_book_isbn VARCHAR(20),
CONSTRAINT isbn_fok FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn),
issued_emp_id VARCHAR(5),
CONSTRAINT employee_fok FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id)
);

DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status(
return_id VARCHAR(7) PRIMARY KEY,
issued_id VARCHAR(7),
CONSTRAINT issued_fok FOREIGN KEY (issued_id) REFERENCES issued_status(issued_id),
return_book_name VARCHAR(5),
return_date	DATE,
return_book_isbn VARCHAR(5)
);

-- Note the 1st three rows of data in the return_status are not imported because they have issued ids which do not exist 
select*from issued_status
WHERE issued_id='IS101' OR issued_id='IS103' OR issued_id='IS105';

-- 1) Insert 3 new records in the books table
INSERT INTO BOOKS(isbn,book_title,category,rental_price,statu_s,author,publisher)
VALUES
('978-0-375-72578-4', 'Life of Pi', 'Adventure', 5.29, 'no', 'Yann Martel', 'Knopf Canada'),
('978-0-3855-3322-5', 'The Goldfinch', 'Fiction', 6.19, 'no', 'Donna Tartt', 'Little, Brown and Company'),
('978-1-5011-2803-5', 'It', 'Horror', 7.49, 'yes', 'Stephen King', 'Viking');

-- 2) update 3 existing members address
UPDATE members
SET member_address = CASE member_id
    WHEN 'C108' THEN '44 Drive In'
    WHEN 'C102' THEN '96 Walk Way'
    WHEN 'C119' THEN 'Docklands 19' 
END
WHERE member_id IN ('C108', 'C102', 'C119');

-- 3) Delete the record from issued_status with issued_id 'IS121'
DELETE FROM issued_status
WHERE issued_id='IS121';
  
-- 4) select all books issued by employee with emp_id 'E101'
SELECT*FROM issued_status
WHERE issued_emp_id='E101';

-- 5) List members who have been issued more than 3 books
SELECT * FROM
(
	SELECT
			issued_member_id,
			COUNT(issued_id) as no_of_books_issued
	FROM issued_status
	GROUP BY 1
) as temp
WHERE no_of_books_issued>3;

-- 6) Use CTAS to create a new table containing each book and the number of times the book is issued 
CREATE TABLE book_issues AS
SELECT
	B.isbn,
    B.book_title,
    COUNT(I.issued_id) as no_of_issues
FROM books as B
JOIN
issued_status as I
ON B.isbn=I.issued_book_isbn
GROUP BY 1,2
ORDER BY 3 DESC;

-- 7) What is the total rental income by category
SELECT
	B.category,
    COUNT(category) as frequency,
	SUM(B.rental_price) total_rental_income
FROM 
issued_status as I
JOIN
books as B
ON B.isbn=I.issued_book_isbn
GROUP BY category;

-- 8) List members who registered in the last 2 years 
SELECT*FROM members
WHERE reg_date >= current_date - interval 2 year;

-- 9) List employees with their branch manager and branch details 
SELECT
	e.emp_id,
	e.emp_name,
	e.positio_n,
	e.branch_id,
	b.manager_id,
	emp.emp_name as manager_name
FROM employees as e
JOIN
branch as b
ON e.branch_id=b.branch_id
JOIN
employees as emp
ON
emp.emp_id=b.manager_id;

-- 10) Create a table of books with rental price >7
DROP TABLE IF EXISTS premium_books;
CREATE TABLE premium_books AS
select*from books
where rental_price>7;

SELECT*FROM premium_books;

-- 11) retrieve the books which have not yet been returned
SELECT
	i.issued_id,
	issued_book_isbn,
	issued_book_name
FROM issued_status as i
LEFT JOIN
return_status as r
ON i.issued_id=r.issued_id
WHERE return_id is NULL;

-- 12) Add a column 'book_quality' to return_status and set 'good' as the default entry afterwards update 5 rows book_quality to 'damaged'
SELECT*FROM return_status;
ALTER TABLE return_status
ADD COLUMN book_quality VARCHAR(10) DEFAULT 'good';

UPDATE return_status
SET book_quality='damaged'
WHERE return_id in ('RS104','RS106','RS110','RS116','RS113');

-- 13) Identify members with overdue books(520 dys). Display mbrs_id, mbrs_name, book title, issue date and days overdue
SELECT
	issued_member_id,
    m.member_name,
	issued_book_name,
	i.issued_date,
	DATEDIFF(current_date,issued_date) as overdue_days
FROM issued_status as i
LEFT JOIN
return_status as r
ON i.issued_id=r.issued_id
JOIN
members as m 
ON m.member_id=i.issued_member_id
WHERE r.return_date IS NULL  
AND 
DATEDIFF(current_date,issued_date) >520;

-- 14) Write a querry to update the status of the books table to 'yes' when a book is returned
DELIMITER //
DROP PROCEDURE IF EXISTS updating_returns//
CREATE PROCEDURE updating_returns(u_return_id VARCHAR(10),u_issued_id VARCHAR(10),u_book_quality VARCHAR(10))
BEGIN
	DECLARE u_book_name VARCHAR(100);
    DECLARE u_isbn VARCHAR(100);
    
	INSERT INTO return_status(return_id,issued_id,return_date,book_quality)
    VALUES
    (u_return_id,u_issued_id,current_date,u_book_quality);
    
    SELECT issued_book_name,issued_book_isbn
    INTO u_book_name,u_isbn
    FROM issued_status
    WHERE issued_id=u_issued_id;
    
	update books
    SET statu_s='yes'
    WHERE isbn=u_isbn;
    
    SELECT CONCAT('Thank you for returning the book:',u_book_name) as message;

END //
DELIMITER ;

/* Testing the created procedure
lets first begin by setting the statu_s of issued books to 'no' */

UPDATE books
SET statu_s ='no'
WHERE isbn in('978-0-451-52993-5','978-0-345-39180-3','978-0-06-025492-6','978-0-06-112241-5','978-0-06-440055-8','978-0-06-440055-8',
'978-0-14-027526-3','978-0-7434-7679-3','978-0-451-52994-2','978-0-06-112008-4','978-0-7432-7356-4','978-0-7432-4722-5','978-0-375-41398-8',
'978-0-307-58837-1','978-0-7432-7357-1','978-0-553-29698-2','978-0-525-47535-5','978-0-679-76489-8','978-0-330-25864-8');

CALL updating_returns('RS119','IS122','bad');
CALL updating_returns('RS120','IS130','bad');
CALL updating_returns('RS121','IS139','bad');
CALL updating_returns('RS122','IS126','bad');
CALL updating_returns('RS123','IS137','good');

/* 15) Write a procedure for issuing books. The strored procedure should first check if the book is available statu_s 'yes' .If the books is 
availabLe it should be issued and the statu_s updated to 'no'.If the book is not available the stored procedure should return a message indicating
that the book is currently not available */

DELIMITER //
DROP PROCEDURE IF EXISTS issuing //
CREATE PROCEDURE issuing(u_issued_id VARCHAR(10),u_issued_member_id VARCHAR(10), u_book_title VARCHAR(100), u_issued_emp_id VARCHAR(10))
BEGIN
	DECLARE u_status VARCHAR(5);
    DECLARE u_isbn VARCHAR(100);
    
    SELECT statu_s,isbn
    INTO u_status,u_isbn
    FROM books
    WHERE book_title=u_book_title
    LIMIT 1;
    
	IF 
		u_status='yes' THEN
        INSERT INTO issued_status(issued_id,issued_member_id,issued_book_name,issued_date,issued_book_isbn,issued_emp_id)
        VALUES
        (u_issued_id,u_issued_member_id,u_book_title,current_date,u_isbn,u_issued_emp_id);
        
        SELECT CONCAT('The book: ',u_book_title, ' has been issued') as message;
        
        UPDATE books
        SET statu_s = 'no'
        WHERE isbn=u_isbn;
        
    ELSE
		SELECT CONCAT('The book: ',u_book_title, ' is currently not available') as message;
    END IF;
END //
DELIMITER ;

-- testing the procedure
CALL issuing('IS141','C103', 'Where the Wild Things Are', 'E103');
CALL issuing('IS142','C103', 'The Histories', 'E106');
CALL issuing('IS143','C109', 'The Alchemist', 'E110');
CALL issuing('IS144','C105', 'The Catcher in the Rye', 'E102');
CALL issuing('IS145','C102', 'The Goldfinch', 'E105');

/* 16) Create a querry that generates a performance report for each branch showing the number of books issued, the number of books
returned and the total revenue generated from book rentals */

DROP TABLE IF EXISTS branch_performance;

CREATE TABLE branch_performance as
SELECT
	COUNT(i.issued_id) books_issued,
	COUNT(r.return_id) books_returned,
	sum(b.rental_price) as revenue_generated,
	e.branch_id
FROM issued_status as i
LEFT JOIN return_status as r 
ON i.issued_id=r.issued_id
JOIN books as b
on i.issued_book_isbn=b.isbn
JOIN employees as e
on e.emp_id=i.issued_emp_id
GROUP BY branch_id
ORDER BY revenue_generated DESC;

SELECT*FROM branch_performance;

--  17) Use CTAS statement to create a new table 'active members' containing members who have used at least two books in the last 3 months 
-- Lets first issue some books using the stored procedure we created
CALL issuing('IS145','C103', 'One Hundred Years of Solitude', 'E106');
CALL issuing('IS146','C103', 'Jane Eyre', 'E103');
CALL issuing('IS147','C118', 'A Peoples History of the United States', 'E103');
CALL issuing('IS148','C118', 'Fahrenheit 451', 'E109');
CALL issuing('IS149','C105', 'Brave New World', 'E109');
CALL issuing('IS150','C105', '1984', 'E106');
CALL issuing('IS151','C105', 'Harry Potter and the Sorcerers Stone', 'E102');
CALL issuing('IS152','C118', 'The Da Vinci Code', 'E102');

-- Now creating the table active_members
DROP TABLE IF EXISTS active_members;
CREATE TABLE active_members as 
SELECT
	issued_member_id,
    COUNT(issued_id) as books_borrowed
FROM issued_status
WHERE DATEDIFF(current_date,issued_date)<=90
GROUP BY 1
HAVING COUNT(issued_id) >2;

SELECT*FROM active_members;

--  18) Find the top 3 employees who have issued the most books. Display the employee name,number of books processsed and their branch

WITH top_employees as
(
SELECT
	i.issued_emp_id as emp_id,
    e.emp_name,
    e.branch_id,
    COUNT(issued_id) as books_issued,
    DENSE_RANK() OVER(ORDER BY COUNT(issued_id) DESC)as ranking
FROM issued_status as i
JOIN 
employees as e
ON e.emp_id=i.issued_emp_id
GROUP BY emp_id
)
SELECT
	emp_id,
    emp_name,
    branch_id,
    books_issued
FROM top_employees
WHERE ranking<=3;




