-- Create Database
CREATE DATABASE IF NOT EXISTS MovieBookingDB;
USE MovieBookingDB;

-- Users Table
CREATE TABLE IF NOT EXISTS Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15)
);

-- Movies Table
CREATE TABLE IF NOT EXISTS Movies (
    MovieID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(100),
    Genre VARCHAR(50),
    Duration INT, -- in minutes
    Language VARCHAR(50)
);

-- Theatres Table
CREATE TABLE IF NOT EXISTS Theatres (
    TheatreID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Location VARCHAR(100)
);

-- ShowTimes Table
CREATE TABLE IF NOT EXISTS ShowTimes (
    ShowID INT AUTO_INCREMENT PRIMARY KEY,
    MovieID INT,
    TheatreID INT,
    ShowTime DATETIME,
    AvailableSeats INT,
    TotalSeats INT,
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID),
    FOREIGN KEY (TheatreID) REFERENCES Theatres(TheatreID)
);

-- Bookings Table
CREATE TABLE IF NOT EXISTS Bookings (
    BookingID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT,
    ShowID INT,
    SeatsBooked INT,
    BookingTime DATETIME,
    Status ENUM('Booked', 'Cancelled') DEFAULT 'Booked',
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (ShowID) REFERENCES ShowTimes(ShowID)
);

-- Payments Table
CREATE TABLE IF NOT EXISTS Payments (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    BookingID INT,
    Amount DECIMAL(10, 2),
    PaymentStatus ENUM('Success', 'Failed'),
    PaymentTime DATETIME,
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

-- Users
INSERT INTO Users (Name, Email, Phone)
VALUES 
('Akash Kumar', 'akash@example.com', '9876543210'),
('Priya Sharma', 'priya@example.com', '9998877665');

-- Movies
INSERT INTO Movies (Title, Genre, Duration, Language)
VALUES 
('Inception', 'Sci-Fi', 148, 'English'),
('RRR', 'Action', 180, 'Telugu'),
('3 Idiots', 'Comedy', 171, 'Hindi');

-- Theatres
INSERT INTO Theatres (Name, Location)
VALUES 
('PVR Cinemas', 'Chennai'),
('INOX', 'Bangalore'),
('Sathyam Cinemas', 'Hyderabad');

-- ShowTimes
INSERT INTO ShowTimes (MovieID, TheatreID, ShowTime, AvailableSeats, TotalSeats)
VALUES 
(1, 1, '2025-04-06 18:00:00', 100, 100),
(2, 2, '2025-04-06 20:30:00', 80, 80),
(3, 3, '2025-04-07 17:00:00', 120, 120);

-- Bookings
INSERT INTO Bookings (UserID, ShowID, SeatsBooked, BookingTime, Status)
VALUES 
(1, 1, 2, NOW(), 'Booked'),
(2, 2, 3, NOW(), 'Booked');

-- Payments
INSERT INTO Payments (BookingID, Amount, PaymentStatus, PaymentTime)
VALUES 
(1, 400.00, 'Success', NOW()),
(2, 600.00, 'Success', NOW());

-- Trigger: Auto Update Seat Availability after Booking
DELIMITER $$
CREATE TRIGGER trg_reduce_seats
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
  UPDATE ShowTimes
  SET AvailableSeats = AvailableSeats - NEW.SeatsBooked
  WHERE ShowID = NEW.ShowID;
END$$
DELIMITER ;

-- Trigger: Auto Refund Seats if Booking Cancelled
DELIMITER $$
CREATE TRIGGER trg_refund_seats
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
  IF OLD.Status = 'Booked' AND NEW.Status = 'Cancelled' THEN
    UPDATE ShowTimes
    SET AvailableSeats = AvailableSeats + OLD.SeatsBooked
    WHERE ShowID = OLD.ShowID;
  END IF;
END$$
DELIMITER ;

-- View: Available Shows
CREATE OR REPLACE VIEW Available_Shows AS
SELECT 
    s.ShowID, m.Title AS Movie, t.Name AS Theatre,
    s.ShowTime, s.AvailableSeats
FROM ShowTimes s
JOIN Movies m ON s.MovieID = m.MovieID
JOIN Theatres t ON s.TheatreID = t.TheatreID
WHERE s.ShowTime > NOW();

-- Report Queries
-- 1. View Available Shows
SELECT * FROM Available_Shows;

-- 2. Revenue Report per Movie
SELECT 
  m.Title,
  SUM(p.Amount) AS TotalRevenue
FROM Payments p
JOIN Bookings b ON p.BookingID = b.BookingID
JOIN ShowTimes s ON b.ShowID = s.ShowID
JOIN Movies m ON s.MovieID = m.MovieID
WHERE p.PaymentStatus = 'Success'
GROUP BY m.Title;

-- How to Test:
-- Check available shows:
SELECT * FROM Available_Shows; 

-- Check bookings and payments:
SELECT * FROM Bookings;
SELECT * FROM Payments;

-- Revenue report per movie:

SELECT 
  m.Title,
  SUM(p.Amount) AS TotalRevenue
FROM Payments p
JOIN Bookings b ON p.BookingID = b.BookingID
JOIN ShowTimes s ON b.ShowID = s.ShowID
JOIN Movies m ON s.MovieID = m.MovieID
WHERE p.PaymentStatus = 'Success'
GROUP BY m.Title;

SHOW Tables;

-- 1. Modify Table for Booking Status
-- You already have a Status field in the Bookings table. So let’s use 'Cancelled' as a status.

-- 2. Stored Procedure: Cancel Booking + Refund Logic
DELIMITER $$

CREATE PROCEDURE CancelBooking (
    IN p_booking_id INT
)
BEGIN
    DECLARE v_show_id INT;
    DECLARE v_seats INT;
    DECLARE v_payment_status VARCHAR(10);

    -- Get Show ID and number of seats booked
    SELECT ShowID, SeatsBooked INTO v_show_id, v_seats
    FROM Bookings
    WHERE BookingID = p_booking_id;

    -- Set booking as Cancelled
    UPDATE Bookings
    SET Status = 'Cancelled'
    WHERE BookingID = p_booking_id;

    -- Update seat availability back to ShowTimes
    UPDATE ShowTimes
    SET AvailableSeats = AvailableSeats + v_seats
    WHERE ShowID = v_show_id;

    -- Process refund by updating Payment status
    UPDATE Payments
    SET PaymentStatus = 'Refunded', PaymentTime = NOW()
    WHERE BookingID = p_booking_id;
END$$

DELIMITER ;

-- 3. Try Booking Cancellation Example
-- Let’s cancel Booking ID 1 (you added earlier):
CALL CancelBooking(1);

-- Check updated booking
SELECT * FROM Bookings WHERE BookingID = 1;

-- Check refund status
SELECT * FROM Payments WHERE BookingID = 1;

-- Check seat availability
SELECT * FROM ShowTimes WHERE ShowID = 1;

-- 4. Check Booking + Payment After Cancellation
-- Check updated booking
SELECT * FROM Bookings WHERE BookingID = 1;

-- Check refund status
SELECT * FROM Payments WHERE BookingID = 1;

-- Check seat availability
SELECT * FROM ShowTimes WHERE ShowID = 1;

-- 5. Revenue Report (Excluding Refunded Payments)

SELECT 
  m.Title,
  SUM(p.Amount) AS TotalRevenue
FROM Payments p
JOIN Bookings b ON p.BookingID = b.BookingID
JOIN ShowTimes s ON b.ShowID = s.ShowID
JOIN Movies m ON s.MovieID = m.MovieID
WHERE p.PaymentStatus = 'Success'
GROUP BY m.Title;


