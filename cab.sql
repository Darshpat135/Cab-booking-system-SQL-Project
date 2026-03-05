Create Database Project;
use Project;


Create table Customers (
CustomerID INT PRIMARY KEY,
Name VARCHAR(100),
Phone VARCHAR(15),
Email VARCHAR(100),
JoinDate DATE
);

INSERT INTO Customers (CustomerID, Name, Phone, Email, JoinDate) 
VALUES
(1, 'Rajan Pandey', '9876543210', 'rajan@example.com', '2024-01-10'),
(2, 'Jay Tiwari', '8765432109', 'jay@example.com', '2024-02-15'),
(3, 'Rakesh Yadav', '7654321098', 'rakesh1@example.com', '2024-03-01'),
(4, 'Harsh Singh', '6543210987', 'harshu@example.com', '2024-04-05');

Select * from Customers;


Create table Drivers (
DriverID INT PRIMARY KEY,
Name VARCHAR(100),
Phone VARCHAR(15),
LicenseNumber VARCHAR(50),
JoinDate DATE,
Rating FLOAT
);

INSERT INTO Drivers (DriverID, Name, Phone, LicenseNumber, JoinDate, Rating) 
VALUES
(1, 'Raj Singh', '9123456789', 'DL12345678', '2023-09-01', 4.5),
(2, 'Sunny Chaudhary', '9234567890', 'DL87654321', '2023-10-12', 3.2),
(3, 'Anshu P', '9345678901', 'DL23456789', '2024-01-20', 2.8),
(4, 'Alina Kapoor', '9456789012', 'DL34567890', '2024-03-15', 4.0);

Select * from Drivers;


Create table Cabs(
CabID INT PRIMARY KEY,
DriverID INT,
CabType VARCHAR(20), 
PlateNumber VARCHAR(20),
FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID));

INSERT INTO Cabs (CabID, DriverID, CabType, PlateNumber)
VALUES
(1, 1, 'Sedan', 'KA01AB1234'),
(2, 2, 'SUV', 'KA01CD5678'),
(3, 3, 'Sedan', 'KA01EF9012'),
(4, 4, 'SUV', 'KA01GH3456');

Select * from Cabs;


Create table Bookings(
BookingID INT PRIMARY KEY,
CustomerID INT,
CabID INT,
BookingTime DATETIME,
TripStartTime DATETIME,
TripEndTime DATETIME,
PickupLocation VARCHAR(100),
DropoffLocation VARCHAR(100),
Status VARCHAR(20), -- 'Completed', 'Cancelled', 'Ongoing'
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
FOREIGN KEY (CabID) REFERENCES Cabs(CabID));

INSERT INTO Bookings (BookingID, CustomerID, CabID, BookingTime, TripStartTime, TripEndTime, PickupLocation, DropoffLocation, Status) 
VALUES
(101, 1, 1, '2025-05-01 08:00:00', '2025-05-01 08:10:00', '2025-05-01 08:40:00', 'Downtown', 'Airport', 'Completed'),
(102, 2, 2, '2025-05-01 09:00:00', NULL, NULL, 'Station', 'Mall', 'Cancelled'),
(103, 1, 3, '2025-05-02 10:00:00', '2025-05-02 10:15:00', '2025-05-02 10:50:00', 'Downtown', 'Hospital', 'Completed'),
(104, 3, 4, '2025-05-03 11:30:00', '2025-05-03 11:45:00', '2025-05-03 12:30:00', 'Mall', 'University', 'Completed'),
(105, 4, 1, '2025-05-04 14:00:00', NULL, NULL, 'Airport', 'Downtown', 'Cancelled');

Select * from Bookings;


Create table TripDetails(
TripID INT PRIMARY KEY,
BookingID INT,
Distance FLOAT,
Fare DECIMAL(10,2),
DriverRating FLOAT,
FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID));

INSERT INTO TripDetails (TripID, BookingID, Distance, Fare, DriverRating)
VALUES
(1001, 101, 12.5, 250.00, 5.0),
(1002, 103, 10.0, 200.00, 4.0),
(1003, 104, 15.0, 300.00, 3.5);

Select * from TripDetails;

-- Note: Bookings 102 and 105 are cancelled, so they don’t appear here.



Create table Feedback(
FeedbackID INT PRIMARY KEY,
BookingID INT,
CustomerFeedback TEXT,
ReasonForCancellation VARCHAR(100),
FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID));

INSERT INTO Feedback (FeedbackID, BookingID, CustomerFeedback, ReasonForCancellation) 
VALUES
(501, 102, 'Cab was late, had to cancel.', 'Driver Delay'),
(502, 105, 'Change of plans.', 'Customer Personal Reason');

Select * from Feedback;
 -- Customers (CustomerID, Name, Phone, Email, JoinDate)
-- Drivers (DriverID, Name, Phone, LicenseNumber, JoinDate, Rating)  
-- Cabs (CabID, DriverID, CabType, PlateNumber) 
-- Bookings (BookingID, CustomerID, CabID, BookingTime, TripStartTime, TripEndTime, PickupLocation, DropoffLocation, Status) 
-- TripDetails (TripID, BookingID, Distance, Fare, DriverRating) 
-- Feedback (FeedbackID, BookingID, CustomerFeedback, ReasonForCancellation) 

-- 1. Identify customers who have completed the most bookings. What insights can you draw about their behavior?

SELECT 
    name, COUNT(*) AS complete_booking
FROM
    customers c
        JOIN
    bookings b ON c.customerid = b.customerid
WHERE
    status = 'completed'
GROUP BY name
ORDER BY complete_booking DESC;

-- 2. Find customers who have canceled more than 30% of their total bookings. What could be the reason for frequent cancellations?

SELECT 
    c.customerid,
    name,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) * 1.0 / COUNT(bookingid) AS cancelledbooking
FROM
    customers c
        JOIN
    bookings b ON c.customerid = b.customerid
GROUP BY c.customerid
HAVING cancelledbooking > 0.3;

-- 3. Determine the busiest day of the week for bookings. How can the company optimize cab availability on peak days?

SELECT 
    DAYNAME(bookingtime) AS busiest_weekday,
    COUNT(*) AS total_booking
FROM
    bookings
GROUP BY busiest_weekday
LIMIT 1;

-- Driver Performance & Efficiency
-- 4. Which drivers have the highest cancellation rate, and what are the common reasons?

SELECT d.DriverID,d.Name, 
    COUNT(CASE WHEN b.Status = 'Cancelled' THEN 1 END) * 1.0 / COUNT(b.BookingID) AS CancellationRate,
    COUNT(b.BookingID) AS TotalBookings
FROM Drivers d
        JOIN Cabs c 
        ON d.DriverID = c.DriverID
        JOIN Bookings b 
        ON c.CabID = b.CabID
GROUP BY d.DriverID , d.Name
HAVING COUNT(b.BookingID) > 0;

-- 5. Find the top 5 drivers who have completed the longest trips in terms of distance. What does this say about their working patterns?

SELECT 
    d.driverid, d.name, SUM(t.distance) AS totaldistance
FROM drivers d
        JOIN cabs c 
        ON d.driverid = c.driverid
        JOIN bookings b 
        ON c.cabid = b.cabid
        JOIN tripdetails t 
        ON b.bookingid = t.bookingid
WHERE b.status = 'completed'
GROUP BY d.driverid , d.name
ORDER BY totaldistance DESC
limit 5;

-- 6. Compare average driver ratings across completed trips. Who consistently performs well?

SELECT d.DriverID,d.Name,
    ROUND(AVG(td.DriverRating), 2) AS AvgRating,
    COUNT(td.TripID) AS CompletedTrips
FROM Drivers d
JOIN Cabs c ON d.DriverID = c.DriverID
JOIN Bookings b ON c.CabID = b.CabID
JOIN TripDetails td ON b.BookingID = td.BookingID
GROUP BY d.DriverID, d.Name
ORDER BY AvgRating DESC;

-- Revenue & Business Metrics
-- 7. Calculate the total revenue generated by completed bookings in the last 6 months.How has the revenue trend changed over time?

SELECT DATE_FORMAT(b.tripendtime, '%Y-%m') AS yearmonth,
    COUNT(t.tripid) AS completed_trips,
    ROUND(SUM(t.fare), 2) AS total_revenue
FROM bookings b
JOIN tripdetails t ON b.bookingid = t.bookingid
WHERE b.status = 'completed' AND b.tripendtime >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY yearmonth
ORDER BY yearmonth ASC;

-- 8. Identify the top 3 most frequently traveled routes based on PickupLocation and DropoffLocation. Should the company allocate more cabs to these routes?

SELECT PickupLocation, DropoffLocation, COUNT(*) AS TripCount
FROM Bookings
WHERE Status = 'Completed'
GROUP BY PickupLocation , DropoffLocation
ORDER BY TripCount DESC LIMIT 3;

-- 9.How long do customers typically wait between booking and pickup?
SELECT 
    BookingID,
    TIMESTAMPDIFF(MINUTE, BookingTime, TripStartTime) AS WaitTimeMinutes
FROM Bookings
WHERE TripStartTime IS NOT NULL;

-- Operational Efficiency & Optimization
-- 10. Which trips took longer than expected for their distance?

SELECT td.TripID,b.BookingID,b.TripStartTime,b.TripEndTime,td.Distance,
    TIMESTAMPDIFF(MINUTE,b.TripStartTime,b.TripEndTime) AS DurationMinutes,
    ROUND(td.Distance / (TIMESTAMPDIFF(MINUTE,b.TripStartTime,b.TripEndTime) / 60.0),2) AS SpeedKmPerHour
FROM Bookings b
JOIN TripDetails td 
ON b.BookingID = td.BookingID
WHERE b.TripStartTime IS NOT NULL AND b.TripEndTime IS NOT NULL;

-- 11. Identify the most common reasons for trip cancellations from customer feedback.What actions can be taken to reduce cancellations?
SELECT 
    Comments, COUNT(*) AS CountReason
FROM
    Feedback
        JOIN
    Bookings ON Feedback.BookingID = Bookings.BookingID
WHERE
    Bookings.Status = 'Canceled'
GROUP BY Comments
ORDER BY CountReason DESC;

-- 3. Find out whether shorter trips (low-distance) contribute significantly to revenue.Should the company encourage more short-distance rides?

-- Comparative & Predictive Analysis

-- 1. Compare the revenue generated from 'Sedan' and 'SUV' cabs. Should the company invest more in a particular vehicle type?

-- 2. Predict which customers are likely to stop using the service based on their last booking date and frequency of rides. How can customer retention be improved?

-- 3. Analyze whether weekend bookings differ significantly from weekday bookings. Should the company introduce dynamic pricing based on demand?
