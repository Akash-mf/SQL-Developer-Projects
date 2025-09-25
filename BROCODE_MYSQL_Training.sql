CREATE DATABASE myDB;
USE myDB;

DROP DATABASE myDB;

ALTER DATABASE myDB READ ONLY = 1;
ALTER DATABASE myDB READ ONLY = 0;

CREATE TABLE employee (
	employee_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    hourly_pay DECIMAL(5, 2),
    hire_day DATE
)

DROP TABLE employees
SELECT * FROM employees;

RENAME TABLE employee TO workers;
RENAME TABLE workers TO employees;

DROP TABLE employees;

ALTER TABLE employees
ADD phone_number VARCHAR(100);

ALTER TABLE employees
RENAME column phone_number TO Email; 

ALTER TABLE employees
modify column Email VARCHAR(100);

ALTER TABLE employees
MODIFY COLUMN Email VARCHAR(255)
AFTER last_name;

ALTER TABLE employees
MODIFY COLUMN Email VARCHAR(255)
FIRST;

ALTER TABLE employees
DROP COLUMN email;

SELECT * FROM employees; 

DESCRIBE employees;

INSERT INTO employees (employee_id, first_name, last_name, hourly_pay, hire_day)
VALUES (1, 'Eugene', 'Krabs', 25.50, '2023-01-02');

INSERT INTO employees (employee_id, first_name, last_name, hourly_pay, hire_date)
VALUES (2, 'Squidward', 'Tentacles', 15.00, '2023-01-03'),
       (3, 'Spongebob', 'SquarePants', 12.50, '2023-01-04'),
       (4, 'Partrick', 'Star', 12.50, '2023-01-05'),
       (5, 'Sandy', 'Cheaks', 17.25, '2023-01-06');
	
INSERT INTO employees (employee_id, first_name, last_name)
VALUES (6, 'Sheldon', 'Plankon');

SELECT first_name, last_name
FROM employees;

SELECT last_name, first_name
FROM employees; 

SELECT * FROM employees
WHERE employee_id = 6;

SELECT * FROM employees
WHERE first_name = 'spongebob';

SELECT * FROM employees
WHERE hourly_pay >= 15;

SELECT * FROM employees
WHERE hire_date <= '2023-01-03';

SELECT * FROM employees
WHERE employee_id != 1; 

SELECT * FROM employees
WHERE hire_day IS NULL;

SELECT * FROM employees
WHERE hire_day IS NOT NULL;

ALTER TABLE employees
RENAME COLUMN hire_day TO hire_date; 

SELECT * FROM employees
WHERE hire_date IS NULL  
AND employee_id = 1
AND hire_date IS NOT NULL;

SET SQL_SAFE_UPDATES = 0;

UPDATE employees
SET hourly_pay = 10.25,
    hire_date = '2023-01-07'
WHERE employee_id = 6;

SELECT * FROM employees;

UPDATE employees
SET hire_date = NULL
WHERE employee_id = 6;

UPDATE employees
SET hourly_pay = 17.25
WHERE employee_id = 5;

SELECT * FROM employees;

INSERT INTO employees (employee_id, first_name, last_name, hourly_pay, hire_date)
VALUES (12, 'Ramya', 'Balaji', 65.00, '2024-10-20');
       
DELETE FROM employees
SELECT * FROM employees;

DELETE FROM employees
WHERE employee_id = 11;

SELECT * FROM employees;

SET AUTOCOMMIT = OFF;
COMMIT;

SELECT * FROM employees;

ROLLBACK;
SELECT * FROM employees;

DELETE FROM employees
SELECT * FROM employees; 

COMMIT;
SELECT * FROM employee;

CREATE TABLE test (
    my_date DATE,
    my_time TIME,
    my_Datetime DATETIME
);

SELECT * FROM test;

INSERT INTO test 
VALUES (CURRENT_DATE(), CURRENT_TIME(), NOW());

SELECT * FROM test; 

INSERT INTO test 
VALUES (CURRENT_DATE()+1, NULL, NULL);


INSERT INTO test 
VALUES (CURRENT_DATE()-1, NULL, NULL);

-- UNIQUE
CREATE TABLE products (
    product_id INT,
    product_name VARCHAR(25) UNIQUE,
    price DECIMAL(4, 2)
); 

SELECT * FROM products;

ALTER TABLE products
ADD CONSTRAINT
UNIQUE (product_name);

SELECT * FROM products

INSERT INTO products (product_id, product_name, price)
VALUES 
    (100, 'Hamburger', 3.99),
    (101, 'Fries', 1.89),
    (102, 'Soda', 1.00),
    (103, 'Ice Cream', 1.49);

-- NOT NULL
ALTER TABLE products
MODIFY price  DECIMAL(4, 2) NOT NULL; 

SELECT * FROM products;  

INSERT INTO products
VALUES (104, 'Cookie', NULL);

describe products; 

-- CHECK

SELECT * FROM employees;

SET SQL_SAFE_UPDATEs = 0;

DELETE FROM employees
WHERE hire_date = '2023-01-04';

ALTER TABLE employees
ADD CONSTRAINT chk_hourly_pay CHECK(hourly_pay >= 10.00);

SELECT * FROM employees; 

SET SQL_SAFE_UPDATES = 0;

UPDATE employees
SET hire_date = '2023-02-02'
WHERE employee_id = 6;

SELECT * FROM employees;

-- Default
 SELECT * FROM products; 
 
 INSERT INTO products (product_id, product_name, price)
 VALUES (104, 'straw', 0.00),
        (105, 'napkin', 0.00),
        (106, 'fork', 0.00),
        (107, 'spoon', 0.00); 
        
 DELETE FROM products
 WHERE product_id >= 104; 
 
 SELECT * FROM products; 
 
 ALTER TABLE products
 ALTER price SET DEFAULT 0;

SELECT * FROM products;  

INSERT INTO products (product_id, product_name)
VALUES (104, 'straw'),
       (105, 'napkin'),
       (106, 'fork'),
       (107, 'spoon'); 
       
SELECT * FROM products;

 CREATE TABLE transactions (
     transaction_id INT,
     amount DECIMAL(5, 2),
     transaction_date DATETIME DEFAULT NOW()
); 

SELECT * FROM transactions; 

DROP TABLE transactions;

SELECT * FROM transactions;

DESCRIBE products; 

ALTER TABLE products
MODIFY price DECIMAL(4,2) DEFAULT 0;

-- primary key

ALTER TABLE transactions
ADD CONSTRAINT
PRIMARY KEY (transaction_id); 

SELECT * FROM transactions; 

ALTER TABLE transactions
MODIFY amount DECIMAL(10, 2);

INSERT INTO transactions (transaction_id, amount, transaction_date)
VALUES
    (1001, 30000.00, '2025-01-07 10:15:00'),
    (1002, 40000.50, '2025-01-06 14:30:00'),
    (1003, 50000.75, '2025-01-05 09:45:00');

SELECT * FROM transactions;

SELECT amount 
FROM transactions
WHERE transaction_id = 1003; 

 DESCRIBE transactions; 
 
ALTER TABLE transactions
DROP PRIMARY KEY; 

ALTER TABLE transaction
MODIFY transaction_id INT AUTO_INCREMENT PRIMARY KEY;

SHOW CREATE TABLE transaction;

SELECT * FROM transactions; 

DESCRIBE myDB.transactions;

SHOW DATABASES; 
SHOW TABLES;  

SELECT * FROM transactions; 

INSERT INTO transactions (amount) VALUES (4.99);

DROP TABLE employee;

SELECT * FROM transactions;

ALTER TABLE transactions
AUTO_INCREMENT = 1000; 

DELETE FROM transaction;

SELECT * FROM transactions; 

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50)
);  

SELECT * FROM customers; 

INSERT INTO customers (first_name, last_name)
VALUES ('fred', 'fish'),
       ('larry', 'lobster'),
       ('Bubble', 'bass');

SELECT * FROM customers;
SELECT * FROM transactions; 

ALTER TABLE transactions
ADD CONSTRAINT fk_customer_id FOREIGN KEY(customer_id) REFERENCES Customers (customer_id);

ALTER TABLE transactions
ADD COLUMN customer_id INT ;

SET SQL_SAFE_UPDATES = 0;

DELETE FROM transactions;
SELECT * FROM transactions;

ALTER TABLE transactions
AUTO_INCREMENT = 1000;

ALTER TABLE transactions
MODIFY transaction_id INT AUTO_INCREMENT PRIMARY KEY;

INSERT INTO transactions (amount, customer_id)
VALUES 
    (4.99, 3),
    (2.89, 2),
    (3.38, 3),
    (4.99, 1);

SELECT amount FROM transactions; 
SELECT * FROM transactions; 
SELECT * FROM customers;

SET SQL_SAFE_UPDATES = 0; 

DELETE FROM transactions WHERE customer_id = 3; 

INSERT INTO transactions (amount, customer_id)
VALUES (1.00, NULL);

SELECT * FROM transactions; 

INSERT INTO customers (first_name, last_name)
VALUES ('poppy', 'puff'); 

SELECT * FROM customers; 

-- JOIN
SELECT transaction_id, amount, first_name, last_name FROM transactions INNER JOIN customers ON transactions.customer_id = customers.customer_id; 

-- LEFT JOIN
SELECT transaction_id, amount, first_name, last_name FROM transactions LEFT JOIN customers ON transactions.customer_id = customers.customer_id;

-- RIGHT JOIN
SELECT transaction_id, amount, first_name, last_name FROM transactions RIGHT JOIN customers ON transactions.customer_id = customers.customer_id;

SELECT * FROM transactions;

SELECT SUM(amount)
FROM transactions
WHERE transaction_date = '2025-04-16';

SELECT COUNT(amount) AS count
FROM transactions; 

SELECT COUNT(amount) AS 'Todays Transactions'
FROM transactions;

SELECT MAX(amount) AS Maximum
FROM transactions;  

SELECT MIN(amount) AS Minimum
FROM transactions;  

SELECT AVG(amount) AS Average
FROM transactions; 

SELECT SUM(amount) AS SUM
FROM transactions;  

-- CONCAT
SELECT * FROM employees; 

SELECT CONCAT(first_name, last_name) AS full_name
FROM employees; 

SELECT CONCAT(first_name,"", last_name) AS full_name
FROM employees;

 SELECT * FROM employees;
 
 ALTER TABLE employees
 ADD COLUMN Job VARCHAR(50);
 
 SET SQL_SAFE_UPDATES = 0;
 
 UPDATE employees
 SET Job = 'Janitor'
 WHERE employee_id = 5;  
 
 SELECT * FROM employees
 WHERE hire_date < '2023-01-5' AND Job = 'cook';
 
 SELECT * FROM employees WHERE job = 'cook';
 
 SELECT * FROM employees WHERE job = 'cook' OR job = 'cashier'; 
 
SELECT * FROM employees WHERE job = 'cook' AND job = 'cashier'; 

SELECT * FROM employees WHERE NOT job = 'Manager' AND NOT job = 'Assistent Manager'; 

 SELECT * FROM employees WHERE hire_date BETWEEN '2023-01-04' AND '2023-01-07'; 
 
 SELECT * FROM employees WHERE job IN ('cook', 'cashier', 'janitor'); 

-- Wild card
SELECT * FROM employees
WHERE hire_date LIKE '2023%'; 

SELECT * FROM employees
WHERE Last_name LIKE "%r"; 

SELECT * FROM employees
WHERE last_name LIKE "ku%"; 

SELECT * FROM employees
WHERE first_name LIKE "sp%"; 

SELECT * FROM employees
WHERE Job LIKE "_ook"; 

SELECT * FROM employees
WHERE hire_date LIKE "2023";

SELECT * FROM employees
WHERE hire_date LIKE "2023"; 

-- ORDER BY
SELECT * FROM employees
ORDER BY last_name DESC;

SELECT * FROM employees
ORDER BY last_name ASC;

SELECT * FROM employees
ORDER BY first_name ASC;

SELECT * FROM employees
ORDER BY first_name DESC; 


SELECT * FROM employees
ORDER BY hire_date ASC; 

SELECT * FROM employees
ORDER BY hire_date; 

SELECT * FROM transactions
ORDER BY amount; 

SELECT * FROM transactions
ORDER BY amount, customer_id;

SELECT * FROM transactions
ORDER BY amount ASC, customer_id DESC; 

-- Limit
SELECT * FROM customers
ORDER BY last_name DESC 
LIMIT 1;

SELECT * FROM customers 
LIMIT 1; 
      2;
      3;
      4;
      
SELECT * FROM customers
LIMIT 1; 

-- UNION
CREATE TABLE income (
    income_id INT AUTO_INCREMENT PRIMARY KEY,
    source VARCHAR(100),
    amount DECIMAL(10, 2),
    income_date DATE
);
 
INSERT INTO income (source, amount, income_date) VALUES
('Salary', 50000.00, '2025-01-01'),
('Freelance', 15000.00, '2025-01-10'),
('Dividends', 2000.00, '2025-01-15');

CREATE TABLE expenses (
    expense_id INT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(100),
    amount DECIMAL(10, 2),
    expense_date DATE
);

INSERT INTO expenses (category, amount, expense_date) VALUES
('Groceries', 5000.00, '2025-01-05'),
('Rent', 15000.00, '2025-01-01'),
('Electricity', 2000.00, '2025-01-12');


SELECT * FROM income
UNION
SELECT * FROM expenses; 

SELECT * FROM income
UNION ALL
SELECT * FROM expenses; 

SELECT first_name, last_name FROM employees
UNION
SELECT first_name, last_name FROM customers;

SELECT first_name, last_name FROM employees
UNION ALL
SELECT first_name, last_name FROM customers; 

INSERT INTO customers
VALUES (5, 'sheldon', 'plankton'); 

SELECT * FROM customers; 

INSERT INTO employees
VALUES (5, 'sheldon', 'plankton'); 

SELECT * FROM employees;

SET SQL_SAFE_UPDATES = 0;
DELETE FROM customers
WHERE customer_id =5;

SELECT * FROM customers;

ALTER TABLE customers
ADD referral_id INT;

SET SQL_SAFE_UPDATES = 0; 

UPDATE customers
SET referral_id = 4
WHERE customer_id = 4;

SELECT * 
FROM customers AS a
INNER JOIN customers AS b 
ON a.referral_id = b.customer_id;

SELECT * 
FROM customers AS a
INNER JOIN customers AS b
ON a.referral_id = b.customer_id; 

-- wrong
SELECT customer_id, first_name, last_name
FROM customers AS a
INNER JOIN customers AS b
ON a.referral_id = b.customer_id;

SELECT 
    a.customer_id AS referred_id,
    a.first_name AS referred_first_name,
    a.last_name AS referred_last_name,
    b.customer_id AS referrer_id,
    b.first_name AS referrer_first_name,
    b.last_name AS referrer_last_name
FROM customers AS a
INNER JOIN customers AS b
ON a.referral_id = b.customer_id;

SELECT a.customer_id, a.first_name, a.last_name, b.first_name, b.last_name
FROM customers AS a
INNER JOIN customers AS b
ON a.referral_id = b.customer_id;

SELECT a.customer_id, a.first_name, a.last_name, CONCAT(b.first_name, b.last_name)
FROM customers AS a
INNER JOIN customers AS b
ON a.referral_id = b.customer_id;

SELECT a.customer_id, a.first_name, a.last_name, CONCAT(b.first_name, b.last_name) AS "referred_by"
FROM customers AS a
INNER JOIN customers AS b
ON a.referral_id = b.customer_id; 

SELECT * FROM employees; 

ALTER TABLE employees
ADD supervisor_id INT; 

SET SQL_SAFE_UPDATES = 0;

UPDATE employees
SET supervisor_id = 10
WHERE employee_id = 10;

SELECT * FROM employees; 

SELECT *
FROM employees AS a
INNER JOIN employees AS b
ON  a.supervisor_id = b.employee_id; 

SELECT a.first_name, a.last_name
FROM employees AS a
INNER JOIN employees AS b
ON  a.supervisor_id = b.employee_id; 

SELECT 
    a.first_name AS employee_first_name,
    a.last_name AS employee_last_name,
    CONCAT(b.first_name, ' ', b.last_name)
FROM employees AS a
INNER JOIN employees AS b
ON a.supervisor_id = b.employee_id;
 
SELECT 
    a.first_name AS employee_first_name,
    a.last_name AS employee_last_name,
    CONCAT(b.first_name, ' ', b.last_name) AS reports_to
FROM employees AS a
INNER JOIN employees AS b
ON a.supervisor_id = b.employee_id; 

SELECT 
    a.first_name AS employee_first_name,
    a.last_name AS employee_last_name,
    CONCAT(b.first_name, ' ', b.last_name) AS reports_to
FROM employees AS a
LEFT JOIN employees AS b
ON a.supervisor_id = b.employee_id; 

SELECT * FROM employees;
SELECT * FROM transactions; 

SHOW INDEXES FROM customers; 

CREATE INDEX last_name_idx ON customers(last_name); 

SHOW INDEXES FROM customers; 

SELECT * FROM customers
WHERE last_name = 'puff'; 

SELECT * FROM customers
WHERE first_name = 'poppy'; 

CREATE INDEX last_name_first_name_idx 
ON customers(last_name, first_name);

SHOW INDEXES FROM customers; 

-- views

SELECT * FROM employees; 

CREATE VIEW employee_attendance AS
SELECT first_name, last_name
FROM employees; 
 
DROP VIEW employee_attendance; 

SELECT * FROM customers; 

ALTER TABLE customers
ADD COLUMN email VARCHAR(50); 

SELECT * FROM customers; 

UPDATE customers
SET email = 'poppy1@gmail.com'
WHERE customer_id = 4;

CREATE VIEW customer_emails AS 
SELECT email
FROM customers; 

SELECT * FROM customer_emails; 

SELECT * FROM customers; 

INSERT INTO customers
VALUES (5, 'pearl', 'krabs', NULL, 'Pkrabs@gmail.com');

SELECT * FROM customer_emails;

-- SUBquery
SELECT * FROM employees; 

SELECT AVG(hourly_pay) FROM employees; 

SELECT 
    first_name, 
    last_name, 
    hourly_pay,
    (SELECT AVG(hourly_pay) FROM employees) AS avg_hourly_pay
FROM 
    employees; 
    
SELECT
    first_name,
    last_name,
    hourly_pay,
    (SELECT AVG(hourly_pay) FROM employees) AS avg_pay
FROM
    employees; 
    
SELECT first_name, last_name, hourly_pay, 15.45
FROM employees; 

SELECT first_name, last_name, hourly_pay,
(SELECT AVG(hourly_pay) FROM employees) AS AVG_pay
FROM employees; 

SELECT first_name, last_name, hourly_pay
FROM employees
WHERE hourly_pay > (SELECT AVG(hourly_pay) FROM employees);


SELECT first_name, last_name, hourly_pay 
FROM employees
WHERE hourly_pay > 15.45; 

SELECT * FROM transactions; 

SELECT customer_id
FROM transactions
WHERE customer_id IS NOT NULL; 

SELECT DISTINCT customer_id
FROM transactions
WHERE customer_id IS NOT NULL;  

SELECT * FROM customers
WHERE last_name = 'puff' AND first_name = 'poppy'; 

SELECT * FROM customers
WHERE first_name = 'poppy';

SELECT first_name, last_name
FROM customers
WHERE customer_id IN
(SELECT DISTINCT customer_id 
FROM transactions
WHERE customer_id IS NOT NULL); 

SELECT first_name, last_name
FROM customers
WHERE customer_id IN (1,2,3); 


SELECT first_name, last_name
FROM customers
WHERE customer_id  NOT IN (1,2,3); 

SELECT first_name, last_name
FROM customers
WHERE customer_id IN (SELECT DISTINCT customer_id 
FROM transactions
WHERE customer_id IS NOT NULL); 

SELECT first_name, last_name
FROM customers
WHERE customer_id NOT IN 
(SELECT DISTINCT customer_id
FROM transactions
WHERE customer_id IS NOT NULL); 

-- GROUP BY
SELECT * FROM transactions;

SELECT transaction_date AS order_date
FROM transactions; 

SELECT MAX(amount),transaction_date AS order_date
FROM transactions
GROUP BY order_date; 

SELECT MIN(amount),transaction_date AS order_date
FROM transactions
GROUP BY order_date; 

SELECT SUM(amount),transaction_date AS order_date
FROM transactions
GROUP BY order_date; 

-- wrong
SELECT COUNT(amount), customer_id
FROM transactions
GROUP BY customer_id
WHERE COUNT(amount) > 1;

-- correct
SELECT 
    customer_id,
    COUNT(amount) AS txn_count
FROM 
    transactions
GROUP BY 
    customer_id
HAVING 
    COUNT(amount) > 1;


SELECT COUNT(amount), customer_id
FROM transactions
GROUP BY customer_id
HAVING COUNT(amount) > 1; 

SELECT COUNT(amount), customer_id
FROM transactions
GROUP BY customer_id
HAVING COUNT(amount) > 1 AND customer_id IS NOT NULL; 

-- wrong
SELECT COUNT(amount), customer_id
FROM transactions
GROUP BY customer_id
WHERE COUNT(amount) > 1 AND customer_id IS NOT NULL;

-- correct
SELECT 
    customer_id,
    COUNT(amount) AS txn_count
FROM 
    transactions
WHERE 
    customer_id IS NOT NULL
GROUP BY 
    customer_id
HAVING 
    COUNT(amount) > 1; 
    
SELECT COUNT(amount), order_date
FROM transactions
GROUP BY order_date;

SELECT * FROM transactions; 

ALTER TABLE transactions
ADD COLUMN order_date DATE; 

SELECT * FROM transactions;

SELECT SUM(amount), customer_id
FROM transactions
GROUP BY customer_id; 

SELECT MIN(amount), customer_id
FROM transactions
GROUP BY customer_id; 

SELECT MAX(amount), customer_id
FROM transactions
GROUP BY customer_id; 

SELECT COUNT(amount), customer_id
FROM transactions
GROUP BY customer_id; 

SELECT AVG(amount), customer_id
FROM transactions
GROUP BY customer_id; 

SELECT COUNT(amount), customer_id 
FROM transactions
GROUP BY customer_id
HAVING COUNT(amount) > 1 AND CUSTOMER_id IS NOT NULL; 

SELECT * FROM transactions;

SELECT SUM(amount), order_date
FROM transactions
GROUP BY order_date WITH ROLLUP; 

SELECT COUNT(transaction_id), order_date
FROM transactions
GROUP BY order_date WITH ROLLUP;

SELECT 
    customer_id,
    COUNT(transaction_id) AS '# of orders'
FROM 
    transactions
GROUP BY 
    customer_id;

SELECT * FROM employees;

SELECT SUM(hourly_pay) AS "hourly pay", employee_id
FROM employees
GROUP BY employee_id WITH ROLLUP; 

-- ON DELETE
DELETE FROM customers
WHERE customer_id = 4;

SELECT * FROM customers; 

SET foreign_key_checks = 0; 
SET foreign_key_checks = 1; 

DELETE FROM customers
WHERE customer_id = 4;

SELECT * FROM customers 

SELECT * FROM transactions;
SELECT * FROM customers; 

INSERT INTO customers
VALUES (4, 'poppy', 'puff', 2, 'ppuff@gmail.com'); 

SELECT * FROM transactions;

UPDATE transactions
SET customer_id = 4
WHERE transaction_id = 1005; 

SELECT * FROM transactions; 

INSERT INTO customers
VALUES (4, 'poppy', 'puff', 2, 'ppuff@gmail.com'); 

DESCRIBE myDB.transactions;

ALTER TABLE transactions
ADD CONSTRAINT fk_customer_id
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
ON DELETE SET NULL;

-- Find the existing constraint name
SELECT CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'transactions'
  AND REFERENCED_TABLE_NAME = 'customers';

-- 2. Drop it (replace fk_customer_id with the actual name if it's different):
ALTER TABLE transactions
DROP FOREIGN KEY fk_customer_id; 

SELETE FROM customers
WHERE customer_id = 4;

SELECT * FROM transactions; 

SELECT DISTINCT first_name, last_name
FROM transactions AS a
INNER JOIN customers AS b
ON a.customer_id = b.customer_id; 

CALL get_customers();

SELECT * FROM customers; 

DELIMITER $$

CREATE PROCEDURE mydb.get_customers()
BEGIN
    SELECT * FROM customers;
END$$

DELIMITER ;

CALL get_customers(); 

DROP PROCEDURE get_customers;

CALL get_customers(3); 

DELIMITER $$

CREATE PROCEDURE find_customers(IN customer_id INT)
BEGIN
    SELECT * FROM customers WHERE id = customer_id;
END $$

DELIMITER ;

CALL get_customers(1);

DROP PROCEDURE find_customers;

DELIMITER $$

CREATE PROCEDURE find_customer1(
    IN f_name VARCHAR(50),
    IN l_name VARCHAR(50)
)
BEGIN 
    SELECT * FROM customers
    WHERE first_name = f_name AND last_name = l_name;
END $$

DELIMITER ;


DROP PROCEDURE IF EXISTS find_customer;

DELIMITER $$

CREATE PROCEDURE find_customer(
    IN f_name VARCHAR(50),
    IN l_name VARCHAR(50)
)
BEGIN 
    SELECT * FROM customers
    WHERE first_name = f_name AND last_name = l_name;
END $$

DELIMITER ;

CALL find_customer('larry', 'lobster');