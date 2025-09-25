-- 9. Hotel Booking System 🏨
-- Skills Used: SQL Triggers, Views, Functions
-- •	Tables: Hotels, Rooms, Guests, Bookings, Payments
-- •	Features:
-- o	Check room availability and pricing.
-- o	Book and cancel reservations.
-- o	Generate revenue reports for different hotels.
-- •	Advanced: Optimize queries for handling large datasets.

-- Skills & Concepts:
-- SQL DDL & DML
-- Triggers for automatic logic (e.g., auto-cancel, auto-update status)
-- Views for simplified reporting
-- Functions for room pricing and availability
-- Query optimization (indexes, joins, limits, etc.)

-- 1. Hotels
CREATE TABLE Hotels (
    hotel_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100),
    address VARCHAR(255)
);

-- 2. Rooms
CREATE TABLE Rooms (
    room_id INT PRIMARY KEY,
    hotel_id INT,
    room_type VARCHAR(50),
    price DECIMAL(10, 2),
    is_available BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (hotel_id) REFERENCES Hotels(hotel_id)
);

--  3. Guests
CREATE TABLE Guests (
    guest_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20)
);

--  4. Bookings
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY,
    guest_id INT,
    room_id INT,
    check_in DATE,
    check_out DATE,
    status VARCHAR(20) CHECK (status IN ('Booked', 'Cancelled')),
    FOREIGN KEY (guest_id) REFERENCES Guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);

-- 5. Payments
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    booking_id INT,
    amount DECIMAL(10, 2),
    paid_on DATE,
    payment_method VARCHAR(50),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

-- 1. Check Room Availability & Pricing

CREATE VIEW Available_Rooms AS
SELECT r.room_id, h.name AS hotel, r.room_type, r.price, h.city
FROM Rooms r
JOIN Hotels h ON r.hotel_id = h.hotel_id
WHERE r.is_available = TRUE;

--  2. Book a Room (Function + Trigger)
-- Stored Function to Check Availability
DELIMITER $$

CREATE FUNCTION IsRoomAvailable(rid INT, checkin DATE, checkout DATE)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
  DECLARE booking_count INT;
  SELECT COUNT(*) INTO booking_count
  FROM Bookings
  WHERE room_id = rid
    AND status = 'Booked'
    AND (checkin BETWEEN check_in AND check_out
         OR checkout BETWEEN check_in AND check_out);

  RETURN booking_count = 0;
END$$

DELIMITER ;

-- Trigger to Auto-Update Room Availability on Booking
DELIMITER $$

CREATE TRIGGER trg_after_booking
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
  UPDATE Rooms SET is_available = FALSE
  WHERE room_id = NEW.room_id AND NEW.status = 'Booked';
END$$

DELIMITER ;

-- Trigger to Auto-Make Room Available on Cancellation
DELIMITER $$

CREATE TRIGGER trg_after_cancellation
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
  IF NEW.status = 'Cancelled' THEN
    UPDATE Rooms SET is_available = TRUE
    WHERE room_id = NEW.room_id;
  END IF;
END$$

DELIMITER ;

-- 3. Generate Revenue Reports
CREATE VIEW Revenue_Report AS
SELECT h.name AS hotel, h.city, SUM(p.amount) AS total_revenue
FROM Payments p
JOIN Bookings b ON p.booking_id = b.booking_id
JOIN Rooms r ON b.room_id = r.room_id
JOIN Hotels h ON r.hotel_id = h.hotel_id
GROUP BY h.name, h.city;

