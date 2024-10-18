CREATE TABLE STG.Staff (
    Staff_ID INT PRIMARY KEY,
	Hotel_ID INT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Position VARCHAR(50) NULL,
    Salary DECIMAL(10,2) NULL,
    Phone VARCHAR(15) NULL,
    Email VARCHAR(255) NULL,
    Hire_Date DATE
);
----------------------------------------------
CREATE TABLE STG.Guest (
    Guest_ID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Address VARCHAR(255) NULL,
    DateOfBirth DATE NULL,
    Phone VARCHAR(15) NULL,
    Email VARCHAR(255) NULL
);
---------------------------------------------
CREATE TABLE STG.Room (
    RoomNr INT PRIMARY KEY,
    TypeName VARCHAR(50),
    Capacity INT,
    Status VARCHAR(20),
    PricePerNight DECIMAL(10,2)
);
---------------------------------------------------------
CREATE TABLE STG.Hotel (
    Hotel_ID INT PRIMARY KEY,
	Name VARCHAR(255),
    Address VARCHAR(255),
    Phone VARCHAR(15),
    Email VARCHAR(255) NULL,
    Stars INT
);
----------------------------------------------------------
CREATE TABLE Date_Dimension (
    Date_Key INT PRIMARY KEY,
    Day VARCHAR(10),
    Month VARCHAR(10),
    Year INT
);

----------------------------------------------------------
DECLARE @DateCounter DATE = '2015-01-01';

CREATE TABLE Date_Dimension (
    Date_Key INT PRIMARY KEY,
    Day VARCHAR(10),
    Month VARCHAR(10),
    Year INT
);
CREATE TABLE Date_Dimension (
    Date_Key INT PRIMARY KEY,
    Day VARCHAR(10),
    Month VARCHAR(10),
    Year INT
);

-- Populate the Date Dimension table
DECLARE @DateCounter DATE = '2015-01-01';

WHILE @DateCounter <= '2024-12-31'
BEGIN
    INSERT INTO Date_Dimension (
        Date_Key,
        Day,
        Month,
        Year
    )
    VALUES (
        CONVERT(INT, FORMAT(@DateCounter, 'yyyyMMdd')),
        DAY(@DateCounter),
        DATENAME(MONTH, @DateCounter),
        YEAR(@DateCounter)
    );

    SET @DateCounter = DATEADD(DAY, 1, @DateCounter);
END;


----------------------------------------------------------------------------------
CREATE TABLE STG.Payment (
    Payment_ID INT PRIMARY KEY,
    Amount DECIMAL,
    PaymentMethodId VARCHAR(50)
);

---------------------------------------------

CREATE TABLE Conf_Table (
    Table_Name VARCHAR(255),
    Last_Extraction_Date DATE
);
--------------------------------------------
-- Insert into Conf_Table
INSERT INTO Conf_Table (Table_Name, Last_Extraction_Date)
VALUES
    ('Staff', '1930-01-01'),
    ('Guest', '1930-01-01'),
    ('Booking', '1930-01-01'),
    ('Room', '1930-01-01'),
    ('Payment', '1930-01-01'),
    ('Hotel', '1930-01-01')

CREATE TABLE STG.Booking (
  Booking_ID INT PRIMARY KEY,
  RoomNum INT,
  GuestID INT,
  HotelID INT,
  Date_Key INT ,
  Check_In_Date Date,
  Check_Out_Date Date,
  Total_Bookings INT -- Measure, semi-additive
);