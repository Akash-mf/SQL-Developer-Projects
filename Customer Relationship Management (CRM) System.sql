 -- 8. Customer Relationship Management (CRM) System 📊 
-- Skills Used: SQL Queries, Data Warehousing, Reporting
-- •	Tables: Customers, Sales, Support Tickets, Feedback
-- •	Features:
-- o	Track customer interactions and purchases.
-- o	Analyze customer feedback and sales trends.
-- o	Generate reports for sales performance.
--  •	Advanced: Implement data warehouse concepts for analytical reporting.

 -- Tools & Technologies:
-- Database: PostgreSQL / MySQL / SQL Server

-- ETL Tool (Optional for DWH): Apache Airflow / Python Scripts

-- BI Tool (Optional for reports): Power BI / Tableau / Excel

-- Data Warehouse Concepts: Star Schema, Fact & Dimension Tables

CREATE DATABASE CRM_System;
USE CRM_System;

-- Database Tables:
-- 1. Customers

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    location VARCHAR(100),
    created_at DATE
);

-- 2. Sales

CREATE TABLE Sales (
    sale_id INT PRIMARY KEY,
    customer_id INT,
    product VARCHAR(100),
    amount DECIMAL(10, 2),
    sale_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- 3. Support_Tickets
CREATE TABLE Support_Tickets (
    ticket_id INT PRIMARY KEY,
    customer_id INT,
    issue VARCHAR(255),
    status VARCHAR(20),
    created_at DATE,
    resolved_at DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- 4. Feedback
CREATE TABLE Feedback (
    feedback_id INT PRIMARY KEY,
    customer_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    submitted_at DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Features Implementation (SQL Queries):
-- 1. Track Customer Interactions and Purchases
-- Get recent interactions for a customer
SELECT c.name, s.product, s.amount, s.sale_date, t.issue, t.status
FROM Customers c
LEFT JOIN Sales s ON c.customer_id = s.customer_id
LEFT JOIN Support_Tickets t ON c.customer_id = t.customer_id
WHERE c.customer_id = 101;

--  2. Analyze Customer Feedback and Sales Trends
--  1. Average Customer Feedback by Location
SELECT location, AVG(rating) AS avg_rating
FROM Customers c
JOIN Feedback f ON c.customer_id = f.customer_id
GROUP BY location;

-- 2. Monthly Sales Trend 
SELECT DATE_FORMAT(sale_date, '%Y-%m-01') AS month, SUM(amount) AS total_sales
FROM Sales
GROUP BY month
ORDER BY month;


-- 3. Generate Sales Performance Reports
-- Top 5 customers by total purchase
SELECT c.name, SUM(s.amount) AS total_spent
FROM Customers c
JOIN Sales s ON c.customer_id = s.customer_id
GROUP BY c.name
ORDER BY total_spent DESC
LIMIT 5;


