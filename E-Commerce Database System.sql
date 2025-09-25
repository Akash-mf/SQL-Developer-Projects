-- 2. E-Commerce Database System 🛒
-- Skills Used: SQL Queries, Normalization, Transactions
-- •	Tables: Users, Orders, Products, Payments, Shipments
-- •	Features:
-- o	Users can place orders.
-- o	Payment processing and order status tracking.
-- o	Generate reports for monthly sales, top-selling products.
-- •	Advanced: Implement indexing and query optimization for performance.

-- 1. Create the Database
drop database if exists ecommerce_db;
create database ecommerce_db;
use ecommerce_db;

-- 2. Create Tables
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE OrderDetails (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
);

CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    payment_method ENUM('Credit Card', 'PayPal', 'Bank Transfer') NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Pending',
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE
);

CREATE TABLE Shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    shipment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tracking_number VARCHAR(50) UNIQUE,
    carrier VARCHAR(50),
    status ENUM('In Transit', 'Delivered', 'Failed') DEFAULT 'In Transit',
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE
);

-- 3. Sample Queries

-- Insert Users
INSERT INTO Users (name, email, password) VALUES 
('John Doe', 'john@example.com', 'hashed_password'),
('Jane Smith', 'jane@example.com', 'hashed_password');

-- Insert Products
INSERT INTO Products (name, description, price, stock) VALUES 
('Laptop', 'Gaming Laptop', 1200.00, 10),
('Smartphone', 'Latest Model', 800.00, 15);

-- Place an Order
INSERT INTO Orders (user_id, total_amount) VALUES (1, 2000.00);
SET @order_id = LAST_INSERT_ID();
INSERT INTO OrderDetails (order_id, product_id, quantity, subtotal) VALUES (@order_id, 1, 1, 1200.00), (@order_id, 2, 1, 800.00);

-- Process Payment
INSERT INTO Payments (order_id, payment_method, payment_status) VALUES (@order_id, 'Credit Card', 'Completed');

-- Ship Order
INSERT INTO Shipments (order_id, tracking_number, carrier, status) VALUES (@order_id, 'TRACK12345', 'FedEx', 'In Transit');

-- Reports
-- Monthly Sales Report
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(total_amount) AS total_sales
FROM Orders WHERE status = 'Delivered' GROUP BY month;

-- Top-Selling Products
SELECT p.name, SUM(od.quantity) AS total_sold
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_sold DESC LIMIT 5;

-- 4. Performance Optimization
CREATE INDEX idx_orders_user ON Orders(user_id);
CREATE INDEX idx_orderdetails_product ON OrderDetails(product_id);
CREATE INDEX idx_payments_order ON Payments(order_id);
CREATE INDEX idx_shipments_order ON Shipments(order_id);
