-- 1. Create the Database
drop database if exists airline_db;
create database airline_db;
use airline_db;

-- 2. Create Tables
CREATE TABLE Flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(10) UNIQUE NOT NULL,
    origin VARCHAR(50) NOT NULL,
    destination VARCHAR(50) NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    total_seats INT NOT NULL,
    base_price DECIMAL(10,2) NOT NULL
);

CREATE TABLE Passengers (
    passenger_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15)
);

CREATE TABLE Tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT,
    passenger_id INT,
    seat_number VARCHAR(5) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    status ENUM('Booked', 'Cancelled') DEFAULT 'Booked',
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id) ON DELETE CASCADE,
    FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id) ON DELETE CASCADE
);

CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT,
    payment_method ENUM('Credit Card', 'PayPal', 'Bank Transfer') NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Pending',
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id) ON DELETE CASCADE
);

-- 3. Sample Queries

-- Insert Flights
INSERT INTO Flights (flight_number, origin, destination, departure_time, arrival_time, total_seats, base_price) VALUES 
('AI101', 'New York', 'Los Angeles', '2024-06-01 08:00:00', '2024-06-01 11:00:00', 180, 300.00),
('BA202', 'London', 'Paris', '2024-06-02 09:30:00', '2024-06-02 10:30:00', 150, 150.00);

-- Insert Passengers
INSERT INTO Passengers (name, email, phone) VALUES 
('Alice Johnson', 'alice@example.com', '1234567890'),
('Bob Smith', 'bob@example.com', '0987654321');

-- Book Ticket with Dynamic Pricing (Assume price increases by 10% if seats booked > 50%)
SET @flight_id = 1;
SET @passenger_id = 1;
SET @base_price = (SELECT base_price FROM Flights WHERE flight_id = @flight_id);
SET @booked_seats = (SELECT COUNT(*) FROM Tickets WHERE flight_id = @flight_id);
SET @final_price = IF(@booked_seats > (SELECT total_seats FROM Flights WHERE flight_id = @flight_id) * 0.5, @base_price * 1.1, @base_price);
INSERT INTO Tickets (flight_id, passenger_id, seat_number, price) VALUES (@flight_id, @passenger_id, '12A', @final_price);
SET @ticket_id = LAST_INSERT_ID();

-- Process Payment
INSERT INTO Payments (ticket_id, payment_method, payment_status) VALUES (@ticket_id, 'Credit Card', 'Completed');

-- Cancel Ticket
UPDATE Tickets SET status = 'Cancelled' WHERE ticket_id = @ticket_id;

-- Reports
-- Monthly Revenue Report
SELECT DATE_FORMAT(booking_date, '%Y-%m') AS month, SUM(price) AS total_revenue
FROM Tickets WHERE status = 'Booked' GROUP BY month;

-- Seat Occupancy Report
SELECT f.flight_number, COUNT(t.ticket_id) AS booked_seats, f.total_seats, 
       (COUNT(t.ticket_id) / f.total_seats) * 100 AS occupancy_rate
FROM Flights f
LEFT JOIN Tickets t ON f.flight_id = t.flight_id AND t.status = 'Booked'
GROUP BY f.flight_id;

-- 4. Performance Optimization
CREATE INDEX idx_tickets_flight ON Tickets(flight_id);
CREATE INDEX idx_tickets_passenger ON Tickets(passenger_id);
CREATE INDEX idx_payments_ticket ON Payments(ticket_id);

-- 5. Partitioning for Large Datasets (Fixed Version with Computed Column)
ALTER TABLE Tickets ADD COLUMN booking_year_month INT GENERATED ALWAYS AS (YEAR(booking_date) * 100 + MONTH(booking_date)) STORED;
ALTER TABLE Tickets PARTITION BY RANGE (booking_year_month) (
    PARTITION p202401 VALUES LESS THAN (202402),
    PARTITION p202402 VALUES LESS THAN (202403),
    PARTITION p202403 VALUES LESS THAN (202404),
    PARTITION pFuture VALUES LESS THAN MAXVALUE
);


CREATE TABLE Tickets_Archive (
    ticket_id INT,
    flight_id INT,
    passenger_id INT,
    seat_number VARCHAR(5),
    price DECIMAL(10,2),
    status ENUM('Booked', 'Cancelled'),
    booking_date TIMESTAMP,
    booking_year_month INT GENERATED ALWAYS AS (YEAR(booking_date) * 100 + MONTH(booking_date)) STORED,
    PRIMARY KEY (ticket_id, booking_year_month)  -- ✅ Fix: Include partition key in PK
) PARTITION BY RANGE (booking_year_month) (
    PARTITION p202401 VALUES LESS THAN (202402),
    PARTITION p202402 VALUES LESS THAN (202403),
    PARTITION p202403 VALUES LESS THAN (202404),
    PARTITION pFuture VALUES LESS THAN MAXVALUE
);
