 -- Schema Design:
-- 1. Customers – Stores user info
-- 2. Accounts – Tracks user account balances
-- 3. Transactions – Logs all financial activities
-- 4. Loans – Records loan details with interest
-- 5. AuditLog – Captures system events and suspicious activities

-- Tables:
-- Customers
-- Stores customer details.

SHOW DATABASES;
DROP DATABASE bankingsystem;
CREATE DATABASE bankingsystem;
USE bankingsystem; 

-- Customers Table
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Accounts Table
CREATE TABLE Accounts (
    AccountID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    Balance DECIMAL(15,2) DEFAULT 0,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Transactions Table
CREATE TABLE Transactions (
    TransactionID INT AUTO_INCREMENT PRIMARY KEY,
    AccountID INT,
    Type VARCHAR(20),
    Amount DECIMAL(15,2),
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Description TEXT,
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);

-- Loans Table
CREATE TABLE Loans (
    LoanID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    Amount DECIMAL(15,2),
    InterestRate DECIMAL(5,2),
    DurationMonths INT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- 2. Stored Procedures for Banking Operations
-- Deposit Procedure
DELIMITER $$

CREATE PROCEDURE deposit(IN acc_id INT, IN amt DECIMAL(15,2))
BEGIN
    UPDATE Accounts SET Balance = Balance + amt WHERE AccountID = acc_id;

    INSERT INTO Transactions (AccountID, Type, Amount, Description)
    VALUES (acc_id, 'Deposit', amt, 'Amount Deposited');
END$$

DELIMITER ;

-- Withdrawal Procedure 
DELIMITER $$

CREATE PROCEDURE withdraw(IN acc_id INT, IN amt DECIMAL(15,2))
BEGIN
    DECLARE current_balance DECIMAL(15,2);

    SELECT Balance INTO current_balance FROM Accounts WHERE AccountID = acc_id;

    IF current_balance < amt THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient Funds';
    ELSE
        UPDATE Accounts SET Balance = Balance - amt WHERE AccountID = acc_id;

        INSERT INTO Transactions (AccountID, Type, Amount, Description)
        VALUES (acc_id, 'Withdrawal', amt, 'Amount Withdrawn');
    END IF;
END$$

DELIMITER ;

-- Transfer Procedure
DELIMITER $$

CREATE PROCEDURE transfer(IN from_acc INT, IN to_acc INT, IN amt DECIMAL(15,2))
BEGIN
    CALL withdraw(from_acc, amt);
    CALL deposit(to_acc, amt);

    INSERT INTO Transactions (AccountID, Type, Amount, Description)
    VALUES (from_acc, 'Transfer', amt, CONCAT('Transferred to Account ', to_acc));
END$$

DELIMITER ;

-- 3. Loan Interest Calculation (Function)
DELIMITER $$

CREATE FUNCTION calculate_installment(loan_id INT) RETURNS DECIMAL(15,2)
DETERMINISTIC
BEGIN
    DECLARE principal DECIMAL(15,2);
    DECLARE rate DECIMAL(5,2);
    DECLARE months INT;
    DECLARE interest DECIMAL(15,2);
    DECLARE total DECIMAL(15,2);

    SELECT Amount, InterestRate, DurationMonths INTO principal, rate, months
    FROM Loans WHERE LoanID = loan_id;

    SET interest = (principal * rate * months) / (12 * 100);
    SET total = principal + interest;

    RETURN total / months;
END$$

DELIMITER ;

-- 4. Trigger for Fraud Detection

DELIMITER $$

CREATE TRIGGER fraud_detection
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    IF NEW.Amount > 100000 THEN
        INSERT INTO AuditLog (TableName, Operation, ChangedData)
        VALUES ('Transactions', 'Suspicious Transaction', JSON_OBJECT('TransactionID', NEW.TransactionID, 'Amount', NEW.Amount));
    END IF;
END$$

DELIMITER ;

-- 5. Audit Log Table + Trigger
-- Audit Table
CREATE TABLE AuditLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    TableName VARCHAR(100),
    Operation VARCHAR(100),
    ChangedData JSON,
    ChangedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit Trigger for Accounts table

DELIMITER $$

CREATE TRIGGER audit_accounts
AFTER INSERT ON Accounts
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (TableName, Operation, ChangedData)
    VALUES (
        'Accounts',
        'Insert',
        JSON_OBJECT('AccountID', NEW.AccountID, 'Balance', NEW.Balance)
    );
END$$

DELIMITER ;

-- Sample Usage
-- Insert sample data
INSERT INTO Customers (Name, Email, Phone) VALUES ('Akash', 'akash@example.com', '9876543210');
INSERT INTO Accounts (CustomerID, Balance) VALUES (1, 5000.00);

-- Deposit
CALL deposit(1, 2000.00);

-- Withdraw
CALL withdraw(1, 1000.00);

-- Transfer (Need two accounts)
INSERT INTO Accounts (CustomerID, Balance) VALUES (1, 3000.00);
CALL transfer(1, 2, 500.00);

-- Loan and installment
INSERT INTO Loans (CustomerID, Amount, InterestRate, DurationMonths)
VALUES (1, 120000.00, 12.0, 24);

SELECT calculate_installment(1);

