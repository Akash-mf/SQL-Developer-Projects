-- 3. Employee Attendance & Payroll System 💼
-- Skills Used: SQL Functions, Views, CTEs, PL/SQL
-- •	Tables: Employees, Attendance, Payroll, Leave Records
-- •	Features:
-- o	Track attendance and working hours.
-- o	Auto-calculate salary based on working days.
-- o	Leave management and deductions.
-- •	Advanced: Implement triggers to auto-update leave balances.

-- Project: Employee Attendance & Payroll System
-- 1 Database Schema (Tables)
-- Create the following tables with appropriate columns:

-- 1.DATABASE
CREATE DATABASE EmployeePayrollDB;
USE EmployeePayrollDB;

-- Employees Table

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100),
    Department VARCHAR(50),
    Designation VARCHAR(50),
    JoiningDate DATE,
    Salary DECIMAL(10,2)
);

-- Attendance Table

CREATE TABLE Attendance (
    AttendanceID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT,
    AttendanceDate DATE,
    CheckIn TIME,
    CheckOut TIME,
    HoursWorked DECIMAL(5,2),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Payroll Table
CREATE TABLE Payroll (
    PayrollID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT,
    MonthYear VARCHAR(7), -- Format: YYYY-MM
    WorkingDays INT,
    SalaryPaid DECIMAL(10,2),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- LeaveRecords Table

CREATE TABLE LeaveRecords (
    LeaveID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT,
    LeaveDate DATE,
    LeaveType VARCHAR(20), -- e.g., Sick Leave, Casual Leave
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

INSERT INTO Employees (Name, Department, Designation, JoiningDate, Salary) 
VALUES 
('John Doe', 'HR', 'Manager', '2022-01-10', 50000),
('Jane Smith', 'IT', 'Developer', '2023-02-15', 60000),
('Mike Johnson', 'Finance', 'Analyst', '2021-07-20', 55000);

INSERT INTO Attendance (EmployeeID, AttendanceDate, CheckIn, CheckOut) 
VALUES 
(1, '2025-03-01', '09:00:00', '18:00:00'),
(2, '2025-03-01', '09:30:00', '18:30:00'),
(3, '2025-03-01', '09:15:00', '17:45:00');

INSERT INTO LeaveRecords (EmployeeID, LeaveDate, LeaveType) 
VALUES 
(1, '2025-03-05', 'Sick Leave'),
(2, '2025-03-10', 'Casual Leave');



-- 2.SQL Functions & Views
-- View: Employee Salary Summary
CREATE VIEW EmployeeSalaryView AS
SELECT e.EmployeeID, e.Name, e.Salary, 
       COUNT(a.AttendanceID) AS TotalWorkingDays, 
       (COUNT(a.AttendanceID) * (e.Salary / 30)) AS ComputedSalary
FROM Employees e
LEFT JOIN Attendance a ON e.EmployeeID = a.EmployeeID
GROUP BY e.EmployeeID, e.Name, e.Salary;

-- Function: Calculate Salary

DELIMITER //
CREATE FUNCTION CalculateSalary(empID INT, monthYear VARCHAR(7)) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE totalDays INT;
    DECLARE baseSalary DECIMAL(10,2);
    
    SELECT COUNT(AttendanceID) INTO totalDays 
    FROM Attendance WHERE EmployeeID = empID 
    AND DATE_FORMAT(AttendanceDate, '%Y-%m') = monthYear;
    
    SELECT Salary INTO baseSalary FROM Employees WHERE EmployeeID = empID;
    
    RETURN (baseSalary / 30) * totalDays;
END;
//
DELIMITER ;

-- 3. Advanced: PL/SQL Triggers
-- Trigger to Auto-Update Leave Balances

DELIMITER //
CREATE TRIGGER UpdateLeaveBalance AFTER INSERT ON LeaveRecords
FOR EACH ROW
BEGIN
    UPDATE Employees 
    SET Salary = Salary - (Salary / 30) 
    WHERE EmployeeID = NEW.EmployeeID;
END;
//
DELIMITER ;

-- 4. Queries for Payroll Processing
-- Insert Payroll Data

INSERT INTO Payroll (EmployeeID, MonthYear, WorkingDays, SalaryPaid)
SELECT e.EmployeeID, '2025-03', 
       COUNT(a.AttendanceID), 
       CalculateSalary(e.EmployeeID, '2025-03')
FROM Employees e
LEFT JOIN Attendance a ON e.EmployeeID = a.EmployeeID
AND DATE_FORMAT(a.AttendanceDate, '%Y-%m') = '2025-03'
GROUP BY e.EmployeeID;
