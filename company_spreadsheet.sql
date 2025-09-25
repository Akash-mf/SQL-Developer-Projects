USE product;

SELECT * FROM company_spreadsheet;

SELECT COUNT(id) FROM company_spreadsheet;

SELECT * FROM company_spreadsheet WHERE tshirt_size = 'S';


RENAME TABLE company_spreadsheet TO employees;

SELECT * FROM employees; 

SELECT first_name FROM employees;

SELECT last_name FROM employees;

SELECT id FROM employees;

SELECT first_name, last_name, id FROM employees;

SELECT last_name AS 'Lastname' FROM employees;

-- WHERE --
SELECT * FROM employees
WHERE department = "Sales"; 

SELECT * FROM employees
WHERE department = "Marketing"; 

-- LIKE
SELECT * FROM employees
WHERE department LIKE "Sales"; 

SELECT First_name, last_name FROM employees
WHERE department LIKE "Sales"; 

SELECT first_name, last_name, department 
FROM employees
WHERE (department = 'Sales' OR department = 'marketing')
  AND tshirt_size = 'L'
  AND first_name != 'Rikki'; 
  
SELECT first_name, last_name, department, tshirt_size
FROM employees
WHERE(department = 'sales' OR department = 'Marketing') AND tshirt_size = 'L' AND first_name != 'Rikki';


-- Limit
SELECT * FROM employees
LIMIT 10; 

SELECT * FROM employees
WHERE tshirt_size = 'L'
LIMIT 10; 

-- WHERE
SELECT first_name, last_name, tshirt_size
FROM employees
WHERE tshirt_size = 'L';

SELECT first_name, last_name
FROM employees
WHERE id = 10;

SELECT first_name, last_name, department
FROM employees
WHERE department = 'sales' OR department = 'Marketing'; 

SELECT first_name, last_name, department
FROM employees
WHERE department = "marketing" AND tshirt_size = "L"; 

SELECT first_name, last_name, department
FROM employees
WHERE department != 'sales';

SELECT * FROM employees
WHERE vacation_taken = 9; 

SELECT * FROM employees
WHERE vacation_taken > 9; 


SELECT * FROM employees
WHERE vacation_taken >= 9; 

SELECT * FROM employees
WHERE vacation_taken < 9;

SELECT * FROM employees
WHERE vacation_taken <= 9; 

SELECT * FROM employees
WHERE vacation_taken <> 9; 

SELECT * FROM employees
WHERE vacation_taken != 9;

-- like operator 
SELECT * FROM employees
WHERE last_name LIKE 'T%'; 

SELECT * FROM employees 
WHERE last_name LIKE '%t%';  

SELECT * FROM employees
WHERE last_name LIKE '_t%'; 

SELECT * FROM employees
WHERE last_name LIKE '_a%';  

-- Aggregate functions
SELECT SUM(num_desks)
FROM departments;
WHERE id >=1 AND  id <=5; 

SELECT MIN(vacation_taken)
FROM employees
WHERE department = 'Marketing';

SELECT max(vacation_taken)
FROM employees
WHERE department = 'Marketing';

SELECT COUNT(vacation_taken)
FROM employees
WHERE department = 'Marketing'; 

SELECT AVG(vacation_taken)
FROM employees
WHERE department = 'Marketing';

SELECT sum(vacation_taken)
FROM employees
WHERE department = 'Marketing';

