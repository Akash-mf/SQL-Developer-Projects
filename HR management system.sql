-- Top-Notch HR Management System (MySQL)
-- Date: 2025-08-08 (script prepared)
-- Run on MySQL 5.7+ / 8.0+

-- ===== 0. Clean start =====
DROP DATABASE IF EXISTS hr_management;
CREATE DATABASE hr_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hr_management;

-- ===== 1. Core tables =====
-- Departments and Roles
CREATE TABLE departments (
  dept_id INT AUTO_INCREMENT PRIMARY KEY,
  dept_name VARCHAR(100) UNIQUE NOT NULL,
  manager_emp_id INT NULL
);

CREATE TABLE roles (
  role_id INT AUTO_INCREMENT PRIMARY KEY,
  role_name VARCHAR(100) UNIQUE NOT NULL,
  privilege_level INT NOT NULL DEFAULT 1
);

-- Employees
CREATE TABLE employees (
  emp_id INT AUTO_INCREMENT PRIMARY KEY,
  emp_code VARCHAR(20) UNIQUE, -- e.g. EMP0001
  name VARCHAR(150) NOT NULL,
  email VARCHAR(150) UNIQUE,
  phone VARCHAR(30),
  hire_date DATE NOT NULL,
  department_id INT,
  role_id INT,
  position VARCHAR(100),
  base_salary DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  employment_status ENUM('ACTIVE','INACTIVE','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  performance_rating TINYINT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_emp_dept FOREIGN KEY (department_id) REFERENCES departments(dept_id) ON DELETE SET NULL,
  CONSTRAINT fk_emp_role FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE SET NULL
);

-- Attendance (daily)
CREATE TABLE attendance (
  attendance_id INT AUTO_INCREMENT PRIMARY KEY,
  emp_id INT NOT NULL,
  attend_date DATE NOT NULL,
  status ENUM('PRESENT','ABSENT','LEAVE','REMOTE','HALF_DAY') NOT NULL DEFAULT 'PRESENT',
  hours_worked DECIMAL(4,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_att_emp FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE,
  UNIQUE (emp_id, attend_date)
);

-- Leave requests
CREATE TABLE leave_requests (
  leave_id INT AUTO_INCREMENT PRIMARY KEY,
  emp_id INT NOT NULL,
  leave_from DATE NOT NULL,
  leave_to DATE NOT NULL,
  leave_type VARCHAR(50),
  reason TEXT,
  status ENUM('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_leave_emp FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE
);

-- Payroll (monthly)
CREATE TABLE payroll (
  payroll_id INT AUTO_INCREMENT PRIMARY KEY,
  emp_id INT NOT NULL,
  period_year INT NOT NULL,
  period_month INT NOT NULL,
  gross_pay DECIMAL(12,2) NOT NULL,
  tax_amount DECIMAL(12,2) DEFAULT 0.00,
  deductions DECIMAL(12,2) DEFAULT 0.00,
  net_pay DECIMAL(12,2) NOT NULL,
  generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pay_emp FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE,
  UNIQUE (emp_id, period_year, period_month)
);

-- Salary slips (store generated slip metadata)
CREATE TABLE salary_slips (
  slip_id INT AUTO_INCREMENT PRIMARY KEY,
  payroll_id INT UNIQUE NOT NULL,
  file_path VARCHAR(500) DEFAULT NULL, -- if files are generated
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_slip_pay FOREIGN KEY (payroll_id) REFERENCES payroll(payroll_id) ON DELETE CASCADE
);

-- Audit log (records of employee modifications)
CREATE TABLE employee_audit_log (
  audit_id INT AUTO_INCREMENT PRIMARY KEY,
  emp_id INT,
  action_type ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  changed_by VARCHAR(150) DEFAULT NULL, -- username or system
  old_data JSON NULL,
  new_data JSON NULL,
  change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Activity log (general system events)
CREATE TABLE activity_log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  source VARCHAR(100),
  event_type VARCHAR(100),
  message TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===== 2. Indexes & helper views =====
CREATE INDEX idx_emp_dept ON employees(department_id);
CREATE INDEX idx_emp_role ON employees(role_id);
CREATE INDEX idx_att_date ON attendance(attend_date);

-- HR dashboard view: quick overview per employee
CREATE VIEW hr_dashboard AS
SELECT
  e.emp_id, e.emp_code, e.name, e.email, d.dept_name AS department,
  r.role_name AS role, e.position, e.base_salary,
  ROUND(e.base_salary * 12,2) AS yearly_salary,
  e.performance_rating, e.employment_status,
  IFNULL((SELECT COUNT(*) FROM attendance a WHERE a.emp_id = e.emp_id AND a.status='PRESENT'),0) AS total_present_days
FROM employees e
LEFT JOIN departments d ON e.department_id = d.dept_id
LEFT JOIN roles r ON e.role_id = r.role_id;

-- Payroll summary view per month
CREATE VIEW payroll_summary AS
SELECT period_year, period_month, COUNT(*) AS employees_paid, SUM(net_pay) AS total_net, SUM(gross_pay) AS total_gross
FROM payroll GROUP BY period_year, period_month;

-- ===== 3. Sample seed data (departments, roles, employees - 20 rows) =====
INSERT INTO departments (dept_name) VALUES
('Management'),('Tech'),('HR'),('Finance'),('Customer Service'),('Operations');

INSERT INTO roles (role_name, privilege_level) VALUES
('CEO', 10), ('CTO', 9), ('Manager', 6), ('Senior Engineer', 5), ('Engineer', 4),
('Analyst',4), ('Recruiter',3), ('Support',2), ('Intern',1);

-- Insert 20 employees
INSERT INTO employees (emp_code, name, email, phone, hire_date, department_id, role_id, position, base_salary, performance_rating)
VALUES
('EMP0001','Alice Smith','alice@company.com','+91-9000000001','2015-01-15',1,1,'CEO',250000.00,5),
('EMP0002','Bob Johnson','bob@company.com','+91-9000000002','2016-03-12',2,2,'CTO',200000.00,5),
('EMP0003','Carol Davis','carol@company.com','+91-9000000003','2018-07-22',3,3,'HR Manager',90000.00,4),
('EMP0004','David Miller','david@company.com','+91-9000000004','2020-09-01',2,5,'Senior Engineer',85000.00,4),
('EMP0005','Eva Wilson','eva@company.com','+91-9000000005','2021-04-18',4,6,'Financial Analyst',75000.00,3),
('EMP0006','Frank Moore','frank@company.com','+91-9000000006','2019-06-25',2,4,'Engineer',80000.00,3),
('EMP0007','Grace Taylor','grace@company.com','+91-9000000007','2020-10-13',3,7,'Recruiter',60000.00,4),
('EMP0008','Hank Anderson','hank@company.com','+91-9000000008','2017-12-04',2,4,'Senior Engineer',88000.00,5),
('EMP0009','Ivy Thomas','ivy@company.com','+91-9000000009','2018-08-30',4,6,'Accountant',70000.00,3),
('EMP0010','Jake Jackson','jake@company.com','+91-9000000010','2019-05-14',2,3,'Tech Manager',95000.00,4),
('EMP0011','Kelly White','kelly@company.com','+91-9000000011','2021-02-17',5,8,'Support',50000.00,2),
('EMP0012','Leo Harris','leo@company.com','+91-9000000012','2021-09-11',5,8,'Support',48000.00,2),
('EMP0013','Mona Clark','mona@company.com','+91-9000000013','2020-01-05',5,3,'CS Manager',70000.00,4),
('EMP0014','Nick Lewis','nick@company.com','+91-9000000014','2022-03-20',2,4,'Engineer',86000.00,4),
('EMP0015','Olivia Lee','olivia@company.com','+91-9000000015','2023-01-01',4,6,'Senior Analyst',78000.00,4),
('EMP0016','Paul Young','paul@company.com','+91-9000000016','2021-11-23',3,7,'HR Assistant',52000.00,3),
('EMP0017','Queen Hall','queen@company.com','+91-9000000017','2022-07-30',2,4,'Engineer',82000.00,3),
('EMP0018','Ray King','ray@company.com','+91-9000000018','2020-08-19',2,8,'Technician',64000.00,2),
('EMP0019','Sara Scott','sara@company.com','+91-9000000019','2019-10-07',2,4,'Engineer',87000.00,4),
('EMP0020','Tom Walker','tom@company.com','+91-9000000020','2024-05-15',2,9,'Intern',30000.00,1);

-- Set department managers (example)
UPDATE departments SET manager_emp_id = (SELECT emp_id FROM employees WHERE emp_code='EMP0001') WHERE dept_name='Management';
UPDATE departments SET manager_emp_id = (SELECT emp_id FROM employees WHERE emp_code='EMP0010') WHERE dept_name='Tech';
UPDATE departments SET manager_emp_id = (SELECT emp_id FROM employees WHERE emp_code='EMP0003') WHERE dept_name='HR';

-- ===== 4. Triggers: Audit + Protection + Attendance autofill =====
-- Audit triggers: store JSON old/new snapshots for robust history
DELIMITER $$

-- AFTER INSERT: log new JSON
CREATE TRIGGER tg_employees_after_insert
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
  INSERT INTO employee_audit_log (emp_id, action_type, changed_by, old_data, new_data)
  VALUES (NEW.emp_id, 'INSERT', 'system', NULL, JSON_OBJECT(
      'emp_id', NEW.emp_id, 'emp_code', NEW.emp_code, 'name', NEW.name, 'email', NEW.email,
      'department_id', NEW.department_id, 'role_id', NEW.role_id, 'position', NEW.position,
      'base_salary', NEW.base_salary, 'performance_rating', NEW.performance_rating, 'employment_status', NEW.employment_status
  ));
END$$

-- AFTER UPDATE: log both old and new
CREATE TRIGGER tg_employees_after_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
  INSERT INTO employee_audit_log (emp_id, action_type, changed_by, old_data, new_data)
  VALUES (OLD.emp_id, 'UPDATE', 'system', 
     JSON_OBJECT('emp_id', OLD.emp_id, 'emp_code', OLD.emp_code, 'name', OLD.name, 'email', OLD.email, 'department_id', OLD.department_id, 'base_salary', OLD.base_salary),
     JSON_OBJECT('emp_id', NEW.emp_id, 'emp_code', NEW.emp_code, 'name', NEW.name, 'email', NEW.email, 'department_id', NEW.department_id, 'base_salary', NEW.base_salary)
  );
END$$

-- AFTER DELETE: log old
CREATE TRIGGER tg_employees_after_delete
AFTER DELETE ON employees
FOR EACH ROW
BEGIN
  INSERT INTO employee_audit_log (emp_id, action_type, changed_by, old_data, new_data)
  VALUES (OLD.emp_id, 'DELETE', 'system',
     JSON_OBJECT('emp_id', OLD.emp_id, 'emp_code', OLD.emp_code, 'name', OLD.name, 'email', OLD.email, 'department_id', OLD.department_id, 'base_salary', OLD.base_salary),
     NULL
  );
END$$

-- BEFORE UPDATE: prevent salary decrease for high-level roles and negative salary
CREATE TRIGGER tg_employees_before_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
  -- prevent negative salary
  IF NEW.base_salary < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'base_salary cannot be negative';
  END IF;

  -- forbid decrease for CEO or privilege_level >=9 (example)
  IF NEW.base_salary < OLD.base_salary THEN
    DECLARE v_priv INT;
    SELECT privilege_level INTO v_priv FROM roles WHERE role_id = OLD.role_id;
    IF v_priv >= 9 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot decrease salary of high-privilege employees';
    END IF;
  END IF;
END$$

-- BEFORE DELETE: protect HR department employees and Management CEO
CREATE TRIGGER tg_employees_before_delete
BEFORE DELETE ON employees
FOR EACH ROW
BEGIN
  DECLARE dept_name VARCHAR(100);
  SELECT dept_name INTO dept_name FROM departments WHERE dept_id = OLD.department_id;
  IF dept_name = 'HR' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete employees from HR department';
  END IF;

  -- Protect CEO (emp_code EMP0001) from deletion
  IF OLD.emp_code = 'EMP0001' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete the CEO';
  END IF;
END$$

-- Attendance autofill trigger: when first day of month, auto-create entries for all active employees (example)
-- NOTE: This trigger triggers on insert to payroll as a convenient place to ensure monthly attendance baseline exists.
CREATE TRIGGER tg_payroll_after_insert
AFTER INSERT ON payroll
FOR EACH ROW
BEGIN
  DECLARE cur_emp INT;
  DECLARE done INT DEFAULT FALSE;
  DECLARE emp_cursor CURSOR FOR SELECT emp_id FROM employees WHERE employment_status='ACTIVE';
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN emp_cursor;
  read_loop: LOOP
    FETCH emp_cursor INTO cur_emp;
    IF done THEN
      LEAVE read_loop;
    END IF;
    -- ensure at least a record for the first day of month if missing
    INSERT IGNORE INTO attendance (emp_id, attend_date, status, hours_worked)
    VALUES (cur_emp, MAKEDATE(NEW.period_year,1) + INTERVAL (NEW.period_month-1) MONTH, 'PRESENT', 0);
  END LOOP;
  CLOSE emp_cursor;
END$$

DELIMITER ;

-- ===== 5. Stored Procedures =====
DELIMITER $$

-- Calculate monthly gross/net pay for an employee: simple example with tax slab
CREATE PROCEDURE calc_monthly_pay(IN p_emp_id INT, IN p_year INT, IN p_month INT)
BEGIN
  DECLARE base DECIMAL(12,2);
  DECLARE gross DECIMAL(12,2);
  DECLARE tax DECIMAL(12,2);
  DECLARE ded DECIMAL(12,2);
  DECLARE net DECIMAL(12,2);

  SELECT base_salary INTO base FROM employees WHERE emp_id = p_emp_id;
  IF base IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee not found';
  END IF;

  -- Basic gross: base salary (monthly)
  SET gross = ROUND(base,2);

  -- Simple tax calculation (example)
  IF gross > 150000 THEN
    SET tax = gross * 0.3;
  ELSEIF gross > 50000 THEN
    SET tax = gross * 0.2;
  ELSE
    SET tax = gross * 0.05;
  END IF;

  -- deductions: provident fund (5%) + others (flat)
  SET ded = ROUND(gross * 0.05 + 500,2);
  SET net = ROUND(gross - tax - ded,2);

  -- Insert or update payroll
  INSERT INTO payroll (emp_id, period_year, period_month, gross_pay, tax_amount, deductions, net_pay)
  VALUES (p_emp_id, p_year, p_month, gross, tax, ded, net)
  ON DUPLICATE KEY UPDATE gross_pay=gross, tax_amount=tax, deductions=ded, net_pay=net, generated_at=CURRENT_TIMESTAMP;
END$$

-- Generate payroll for all active employees for given month
CREATE PROCEDURE generate_payroll_for_month(IN p_year INT, IN p_month INT)
BEGIN
  DECLARE cur_emp INT;
  DECLARE done INT DEFAULT FALSE;
  DECLARE emp_cursor CURSOR FOR SELECT emp_id FROM employees WHERE employment_status='ACTIVE';
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN emp_cursor;
  read_loop: LOOP
    FETCH emp_cursor INTO cur_emp;
    IF done THEN
      LEAVE read_loop;
    END IF;
    CALL calc_monthly_pay(cur_emp, p_year, p_month);
  END LOOP;
  CLOSE emp_cursor;
END$$

-- Award bonus to a department (adds to base_salary)
CREATE PROCEDURE award_department_bonus(IN p_dept_id INT, IN p_amount DECIMAL(12,2))
BEGIN
  UPDATE employees SET base_salary = base_salary + p_amount WHERE department_id = p_dept_id;
  INSERT INTO activity_log (source, event_type, message) VALUES ('system','BONUS','Department bonus awarded');
END$$

-- Generate salary slip metadata for a payroll entry
CREATE PROCEDURE generate_salary_slip(IN p_payroll_id INT)
BEGIN
  INSERT IGNORE INTO salary_slips (payroll_id, file_path) VALUES (p_payroll_id, NULL);
END$$

-- Department-wise salary report (result set)
CREATE PROCEDURE department_salary_report()
BEGIN
  SELECT d.dept_name, COUNT(e.emp_id) AS total_employees, ROUND(SUM(e.base_salary),2) AS sum_base_salary,
         ROUND(AVG(e.base_salary),2) AS avg_base_salary
  FROM departments d
  LEFT JOIN employees e ON e.department_id = d.dept_id
  GROUP BY d.dept_name;
END$$

DELIMITER ;

-- ===== 6. Utility: Export payroll CSV (requires FILE privilege; path on server) =====
-- Example (commented): change '/tmp/payroll_YYYY_MM.csv' to server-writable path
-- SELECT CONCAT(period_year,'-',LPAD(period_month,2,'0')) AS period, e.emp_code, e.name, p.gross_pay, p.tax_amount, p.deductions, p.net_pay
-- INTO OUTFILE '/tmp/payroll_export.csv'
-- FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n'
-- FROM payroll p JOIN employees e ON p.emp_id = e.emp_id
-- WHERE p.period_year=2025 AND p.period_month=8;

-- ===== 7. Example queries & usage comments =====
-- Run payroll for August 2025:
-- CALL generate_payroll_for_month(2025, 8);

-- View HR dashboard:
-- SELECT * FROM hr_dashboard;

-- Get department report:
-- CALL department_salary_report();

-- View audit log:
-- SELECT * FROM employee_audit_log ORDER BY change_time DESC LIMIT 200;

-- ===== 8. Final notes recorded in activity_log =====
INSERT INTO activity_log (source, event_type, message) VALUES ('system','INIT','HR Management schema created and seeded with sample data');

-- ===== End of script =====


-- Create a new user for HR Manager
CREATE USER 'hr_manager'@'localhost' IDENTIFIED BY 'HRmanager@123';

-- Give HR Manager rights to view and modify employee data
GRANT SELECT, INSERT, UPDATE ON hr_management.employees TO 'hr_manager'@'localhost';

-- Grant rights to view reports and dashboards
GRANT SELECT ON hr_management.department_salary_report TO 'hr_manager'@'localhost';
GRANT SELECT ON hr_management.hr_dashboard TO 'hr_manager'@'localhost';

-- Create a user for Payroll Officer
CREATE USER 'payroll_officer'@'localhost' IDENTIFIED BY 'Payroll@123';

-- Payroll Officer can view salaries but not modify employee details
GRANT SELECT ON hr_management.employees TO 'payroll_officer'@'localhost';
GRANT SELECT, INSERT ON hr_management.salary_payments TO 'payroll_officer'@'localhost';

-- Revoke UPDATE rights from Payroll Officer if no longer needed
REVOKE UPDATE ON hr_management.employees FROM 'payroll_officer'@'localhost';

-- Apply changes
FLUSH PRIVILEGES;

