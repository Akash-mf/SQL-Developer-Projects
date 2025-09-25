-- Hospital Management System - MySQL Project Script

CREATE DATABASE IF NOT EXISTS HospitalDB;
USE HospitalDB;

-- Patients Table
CREATE TABLE IF NOT EXISTS Patients (
    PatientID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    DOB DATE,
    Gender ENUM('Male', 'Female', 'Other'),
    ContactNumber VARCHAR(15),
    Address TEXT
);

-- Doctors Table
CREATE TABLE IF NOT EXISTS Doctors (
    DoctorID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Specialty VARCHAR(50),
    ContactNumber VARCHAR(15)
);

-- Appointments Table
CREATE TABLE IF NOT EXISTS Appointments (
    AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT,
    DoctorID INT,
    AppointmentDate DATETIME,
    Status ENUM('Scheduled', 'Completed', 'Cancelled'),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

-- Prescriptions Table
CREATE TABLE IF NOT EXISTS Prescriptions (
    PrescriptionID INT AUTO_INCREMENT PRIMARY KEY,
    AppointmentID INT,
    MedicationDetails TEXT,
    Notes TEXT,
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID)
);

-- Billing Table
CREATE TABLE IF NOT EXISTS Billing (
    BillID INT AUTO_INCREMENT PRIMARY KEY,
    AppointmentID INT,
    Amount DECIMAL(10, 2),
    PaymentStatus ENUM('Pending', 'Paid'),
    GeneratedDate DATETIME,
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID)
);

-- Stored Procedure: Add Appointment
DELIMITER $$
CREATE PROCEDURE AddAppointment (
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_date DATETIME
)
BEGIN
    INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Status)
    VALUES (p_patient_id, p_doctor_id, p_date, 'Scheduled');
END$$
DELIMITER ;

-- Stored Procedure: Generate Bill
DELIMITER $$
CREATE PROCEDURE GenerateBill (
    IN p_appointment_id INT,
    IN p_amount DECIMAL(10,2)
)
BEGIN
    INSERT INTO Billing (AppointmentID, Amount, PaymentStatus, GeneratedDate)
    VALUES (p_appointment_id, p_amount, 'Pending', NOW());
END$$
DELIMITER ;

-- Trigger: Auto-generate bill after appointment insert
DELIMITER $$
CREATE TRIGGER trg_auto_bill
AFTER INSERT ON Appointments
FOR EACH ROW
BEGIN
    INSERT INTO Billing(AppointmentID, Amount, PaymentStatus, GeneratedDate)
    VALUES (NEW.AppointmentID, 500.00, 'Pending', NOW());
END$$
DELIMITER ;

-- Sample Data: Doctors
INSERT INTO Doctors (Name, Specialty, ContactNumber)
VALUES 
('Dr. Asha Reddy', 'Cardiology', '1234567890'),
('Dr. John Doe', 'Dermatology', '9876543210');

-- Sample Data: Patients
INSERT INTO Patients (Name, DOB, Gender, ContactNumber, Address)
VALUES 
('Ravi Kumar', '1985-05-12', 'Male', '9999988888', 'Chennai'),
('Priya Mehta', '1990-11-23', 'Female', '8888877777', 'Bangalore');


-- Sample Data: Appointments
INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Status)
VALUES
(1, 1, '2024-04-10 10:00:00', 'Scheduled'),
(2, 2, '2024-04-11 15:00:00', 'Completed');

-- Sample Data: Prescriptions
INSERT INTO Prescriptions (AppointmentID, MedicationDetails, Notes)
VALUES
(1, 'Paracetamol 500mg twice a day', 'Monitor fever'),
(2, 'Skin ointment - apply once daily', 'Follow-up in 7 days');

-- Sample Data: Billing (generated via trigger or procedure if needed)
INSERT INTO Billing (AppointmentID, Amount, PaymentStatus, GeneratedDate)
VALUES
(1, 500.00, 'Pending', NOW()),
(2, 800.00, 'Paid', NOW());

-- 1. Verify Tables Are Created
SHOW TABLES;

-- 2. Check Sample Data

SELECT * FROM Patients;
SELECT * FROM Doctors;
SELECT * FROM Appointments;
SELECT * FROM Prescriptions;
SELECT * FROM Billing;

-- 3. Test Stored Procedure: AddAppointment Call the stored procedure like this:
CALL AddAppointment(1, 2, '2024-04-20 09:30:00');

-- Then check:
SELECT * FROM Appointments ORDER BY AppointmentID DESC;
SELECT * FROM Billing ORDER BY BillID DESC;

-- 4. Test Stored Procedure: GenerateBill
-- Use this if the trigger didn't fire or you want manual billing:
CALL GenerateBill(1, 1000.00);
SELECT * FROM Billing WHERE AppointmentID = 1;

-- 5. Test Trigger
-- Insert an appointment directly:
INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Status)
VALUES (1, 1, NOW(), 'Scheduled');

-- Then check if billing is automatically generated:
SELECT * FROM Billing ORDER BY BillID DESC;

-- 6. Test Foreign Key Constraints
-- Try inserting an appointment with a non-existent patient or doctor:

INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Status)
VALUES (999, 999, NOW(), 'Scheduled');

-- It should fail due to foreign key constraints.

-- 7. Check Prescriptions Linked Correctly

SELECT a.AppointmentID, p.Name AS PatientName, d.Name AS DoctorName, pr.MedicationDetails
FROM Appointments a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Doctors d ON a.DoctorID = d.DoctorID
JOIN Prescriptions pr ON pr.AppointmentID = a.AppointmentID;

-- 8. Run a Simple Report: Revenue
SELECT SUM(Amount) AS TotalRevenue, COUNT(*) AS TotalBills FROM Billing WHERE PaymentStatus = 'Paid';
