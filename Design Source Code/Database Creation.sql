CREATE TABLE Hotel (
    HotelID INT PRIMARY KEY,
    Name VARCHAR(255),
    Address VARCHAR(255),
    Phone VARCHAR(15),
    Email VARCHAR(255) NULL,
    Stars INT,
    CheckInTime TIME,
    CheckOutTime TIME
);

CREATE TABLE Staff (
    StaffID INT PRIMARY KEY,
    HotelID INT FOREIGN KEY REFERENCES Hotel(HotelID),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Position VARCHAR(50) NULL,
    Salary DECIMAL(10,2) NULL,
    DateOfBirth DATE NULL,
    Phone VARCHAR(15) NULL,
    Email VARCHAR(255) NULL,
    HireDate DATE
);

CREATE TABLE RoomType (
    TypeID INT PRIMARY KEY,
    Name VARCHAR(50),
    Description VARCHAR(255) NULL,
    PricePerNight DECIMAL(10,2),
    Capacity INT
);

CREATE TABLE Room (
    RoomID INT PRIMARY KEY,
    HotelID INT FOREIGN KEY REFERENCES Hotel(HotelID),
    TypeID INT FOREIGN KEY REFERENCES RoomType(TypeID),
    Status VARCHAR(20)
);

CREATE TABLE Guest (
    GuestID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Address VARCHAR(255) NULL,
    DateOfBirth DATE NULL,
    Phone VARCHAR(15) NULL,
    Email VARCHAR(255) NULL
);

CREATE TABLE Booking (
    BookingID INT PRIMARY KEY,
    GuestID INT FOREIGN KEY REFERENCES Guest(GuestID),
    RoomID INT FOREIGN KEY REFERENCES Room(RoomID),
    CheckInDate DATE,
    CheckOutDate DATE,
    TotalPrice DECIMAL(10,2)
);

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY,
    PaymentAmount DECIMAL(10,2) NOT NULL,
    PaymentMethod VARCHAR(50) NOT NULL,
    PaymentDate DATE NOT NULL,
    GuestID INT FOREIGN KEY REFERENCES Guest(GuestID)
);


-- Display the contents of the temporary dimension table
SELECT * FROM @TempPaymentDimension;
--------------------------------------------------------------------------------------------------

INSERT INTO Hotel (HotelID, Name, Address, Phone, Email, Stars, CheckInTime, CheckOutTime) 
VALUES 
(1, 'Hotel A', '123 Main St, City', '+1234567890', 'info@hotela.com', 5, '14:00:00', '12:00:00'),
(2, 'Hotel B', '456 Elm St, Town', '+9876543210', 'info@hotelb.com', 4, '15:00:00', '11:00:00'),
(3, 'Hotel C', '789 Oak St, Village', '+1122334455', 'info@hotelc.com', 3, '13:00:00', '10:00:00'),
(4, 'Hotel D', '101 Pine St, Countryside', '+9988776655', 'info@hoteld.com', 4, '12:00:00', '11:00:00'),
(5, 'Hotel E', '202 Maple St, Mountains', '+6677889900', 'info@hotele.com', 5, '16:00:00', '13:00:00');
-------------------------------------------------------------------------------
-- Insert dummy room types
INSERT INTO RoomType (TypeID, Name, Description, PricePerNight, Capacity)
VALUES 
(1, 'Single Room', 'A room with a single bed', 100.00, 1),
(2, 'Double Room', 'A room with a double bed', 150.00, 2);

---------------------------------------------------------------
DECLARE @Counter INT = 1;

WHILE @Counter <= 150
BEGIN
    DECLARE @FirstName VARCHAR(50);
    DECLARE @LastName VARCHAR(50);

    -- Generate random first and last names
    SET @FirstName = (SELECT TOP 1 FirstName FROM (VALUES ('John'), ('Alice'), ('Michael'), ('Emily'), ('William')) AS FirstNameList(FirstName) ORDER BY NEWID());
    SET @LastName = (SELECT TOP 1 LastName FROM (VALUES ('Smith'), ('Johnson'), ('Brown'), ('Wilson'), ('Taylor')) AS LastNameList(LastName) ORDER BY NEWID());

    INSERT INTO SRC.Guest (GuestID, FirstName, LastName, Address, DateOfBirth, Phone, Email)
    VALUES 
    (@Counter, @FirstName, @LastName, 'Address' + CAST(@Counter AS VARCHAR(10)), DATEADD(YEAR, -ABS(CHECKSUM(NEWID())) % 50, GETDATE()), '+1234567890', 'guest' + CAST(@Counter AS VARCHAR(10)) + '@example.com');
    
    SET @Counter = @Counter + 1;
END;
-----------------------------------------------------------
DECLARE @Counter INT = 1;

WHILE @Counter <= 125
BEGIN
    DECLARE @HotelID INT;
    IF @Counter <= 25
        SET @HotelID = 1;
    ELSE IF @Counter <= 50
        SET @HotelID = 2;
    ELSE IF @Counter <= 75
        SET @HotelID = 3;
    ELSE IF @Counter <= 100
        SET @HotelID = 4;
    ELSE
        SET @HotelID = 5;
        
    DECLARE @FirstName VARCHAR(50);
    DECLARE @LastName VARCHAR(50);
    DECLARE @StaffID INT = @Counter;

    -- Generate random first and last names
    SET @FirstName = (SELECT TOP 1 FirstName FROM (VALUES ('John'), ('Alice'), ('Michael'), ('Emily'), ('William')) AS FirstNameList(FirstName) ORDER BY NEWID());
    SET @LastName = (SELECT TOP 1 LastName FROM (VALUES ('Smith'), ('Johnson'), ('Brown'), ('Wilson'), ('Taylor')) AS LastNameList(LastName) ORDER BY NEWID());

    -- Generate random salary between 2000 and 3000
    DECLARE @Salary DECIMAL(10, 2) = CAST((2000 + ABS(CHECKSUM(NEWID())) % 1001) AS DECIMAL(10, 2));

    -- Generate random hire date between January 1, 2019 and April 30, 2021
    DECLARE @RandomDateOffset INT = ABS(CHECKSUM(NEWID())) % ((DATEDIFF(DAY, '2019-01-01', '2021-04-30') + 1));
    DECLARE @HireDate DATE = DATEADD(DAY, @RandomDateOffset, '2019-01-01');

    INSERT INTO Staff (StaffID, HotelID, FirstName, LastName, Position, Salary, DateOfBirth, Phone, Email, HireDate)
    VALUES 
    (@StaffID,
     @HotelID,
     @FirstName,
     @LastName,
     CASE WHEN @Counter % 2 = 0 THEN 'Receptionist' ELSE 'Housekeeping' END, -- Alternating positions
     @Salary,
     DATEADD(YEAR, -ABS(CHECKSUM(NEWID())) % 40, GETDATE()), -- Random date of birth between 40 years ago and now
     '+1234567890',
     'staff' + CAST(@Counter AS VARCHAR(10)) + '@hotel' + CAST(@HotelID AS VARCHAR(10)) + '.com',
     @HireDate
    );
    
    SET @Counter = @Counter + 1;
END;

--------------------------------------------------------------------------
DECLARE @Counter INT = 1;

-- Loop through each hotel
WHILE @Counter <= 5
BEGIN
    DECLARE @HotelID INT = @Counter;
    DECLARE @RoomTypeID INT;

    -- For each hotel, insert 25 rooms
    DECLARE @RoomCounter INT = 1;
    WHILE @RoomCounter <= 25
    BEGIN
        -- For every even numbered room, set the room type ID to 2 (type two)
        IF @RoomCounter % 2 = 0
            SET @RoomTypeID = 2;
        ELSE
            SET @RoomTypeID = 1;

        -- Insert room record
        INSERT INTO SRC.Room (RoomID, HotelID, TypeID, Status)
        VALUES 
        ((@Counter - 1) * 25 + @RoomCounter, -- Calculate RoomID
         @HotelID,
         @RoomTypeID,
         'Available' -- Assuming all rooms are initially available
        );
        
        SET @RoomCounter = @RoomCounter + 1;
    END;

    SET @Counter = @Counter + 1;
END;

----------------------------------------------------------------------
DECLARE @BookingID INT = 1;
DECLARE @PaymentID INT = 1;

DECLARE @Counter INT = 1;

WHILE @Counter <= 1000
BEGIN
    DECLARE @GuestID INT = 1 + ABS(CHECKSUM(NEWID())) % 150; -- Random GuestID between 1 and 150
    DECLARE @HotelID INT = 1 + ABS(CHECKSUM(NEWID())) % 5; -- Random HotelID between 1 and 5
    DECLARE @RoomID INT = (100 * (@HotelID - 1)) + 1 + ABS(CHECKSUM(NEWID())) % 100; -- Random RoomID within the hotel range
    DECLARE @CheckInDate DATE;
    DECLARE @CheckOutDate DATE;
    DECLARE @NumOfDays INT;
    
    -- Find available CheckInDate for the hotel where at least 5 staff members are hired
    SELECT @CheckInDate = MAX(HireDate)
    FROM Staff
    WHERE HotelID = @HotelID
    HAVING COUNT(*) >= 5;

    -- Randomly generate CheckOutDate with the condition that the difference between CheckInDate and CheckOutDate is not more than one week
    SET @CheckOutDate = DATEADD(DAY, 1 + ABS(CHECKSUM(NEWID())) % 7, @CheckInDate);
    SET @NumOfDays = DATEDIFF(DAY, @CheckInDate, @CheckOutDate);

    -- Calculate TotalPrice for the booking
    DECLARE @TotalPrice DECIMAL(10, 2);
    SELECT @TotalPrice = PricePerNight * @NumOfDays
    FROM RoomType
    WHERE TypeID = (SELECT TypeID FROM Room WHERE RoomID = @RoomID);

    -- Generate random PaymentMethod
    DECLARE @PaymentMethod VARCHAR(50) = CASE ABS(CHECKSUM(NEWID())) % 2 WHEN 0 THEN 'Credit Card' ELSE 'Cash' END;

    -- Generate random PaymentDate between CheckInDate and CheckOutDate but not more than 3 months before CheckInDate
    DECLARE @PaymentDate DATE = DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % (30 * 3)), @CheckInDate);

    -- Check if the guest already has a booking for the same time period
    IF NOT EXISTS (
        SELECT 1
        FROM Booking
        WHERE GuestID = @GuestID
        AND NOT (@CheckInDate >= CheckOutDate OR @CheckOutDate <= CheckInDate)
    )
    BEGIN
        -- Book the room
        INSERT INTO Booking (BookingID, GuestID, RoomID, CheckInDate, CheckOutDate, TotalPrice)
        VALUES (@BookingID, @GuestID, @RoomID, @CheckInDate, @CheckOutDate, @TotalPrice);

        -- Make the payment record
        INSERT INTO Payment (PaymentID, PaymentAmount, PaymentMethod, PaymentDate, GuestID)
        VALUES (@PaymentID, @TotalPrice, @PaymentMethod, @PaymentDate, @GuestID);

        SET @BookingID = @BookingID + 1;
        SET @PaymentID = @PaymentID + 1;
    END;

    SET @Counter = @Counter + 1;
END;
--------------------------------------------------------------------------------------
DECLARE @BookingID INT = 1;
DECLARE @PaymentID INT = 1;

DECLARE @Counter INT = 1;

WHILE @Counter <= 2000
BEGIN
    DECLARE @GuestID INT = 1 + ABS(CHECKSUM(NEWID())) % 150; -- Random GuestID between 1 and 150
    DECLARE @HotelID INT = 1 + ABS(CHECKSUM(NEWID())) % 5; -- Random HotelID between 1 and 5
    DECLARE @RoomID INT;

    -- Find an available room for booking in the hotel
    SELECT TOP 1 @RoomID = RoomID
    FROM Room
    WHERE HotelID = @HotelID
    AND Status = 'Available'
    ORDER BY NEWID(); -- Randomize room selection

    IF @RoomID IS NOT NULL
    BEGIN
        DECLARE @CheckInDate DATE;
        DECLARE @CheckOutDate DATE;
        DECLARE @NumOfDays INT;

        -- Find available CheckInDate for the hotel where at least 5 staff members are hired
        SELECT @CheckInDate = MAX(HireDate)
        FROM Staff
        WHERE HotelID = @HotelID
        HAVING COUNT(*) >= 5;

        -- Randomly generate CheckOutDate with the condition that the difference between CheckInDate and CheckOutDate is not more than one week
        SET @CheckOutDate = DATEADD(DAY, 1 + ABS(CHECKSUM(NEWID())) % 7, @CheckInDate);

        -- Check if the room has been booked before
        IF EXISTS (
            SELECT 1
            FROM Booking
            WHERE RoomID = @RoomID
        )
        BEGIN
            -- Get the last check-out date for the room
            DECLARE @LastCheckOutDate DATE;
            SELECT TOP 1 @LastCheckOutDate = CheckOutDate
            FROM Booking
            WHERE RoomID = @RoomID
            ORDER BY CheckOutDate DESC;

            -- Check if the proposed check-in date meets the conditions for booking again
            IF @LastCheckOutDate >= @CheckInDate
            BEGIN
                SET @CheckInDate = DATEADD(DAY, 1, @LastCheckOutDate);
                SET @CheckOutDate = DATEADD(DAY, 1 + ABS(CHECKSUM(NEWID())) % 7, @CheckInDate);
            END;
        END;

        SET @NumOfDays = DATEDIFF(DAY, @CheckInDate, @CheckOutDate);

        -- Calculate TotalPrice for the booking
        DECLARE @PricePerNight DECIMAL(10, 2);
        SELECT @PricePerNight = PricePerNight
        FROM RoomType
        WHERE TypeID = (SELECT TypeID FROM Room WHERE RoomID = @RoomID);

        DECLARE @TotalPrice DECIMAL(10, 2) = @PricePerNight * @NumOfDays;

        -- Generate random PaymentMethod
        DECLARE @PaymentMethod VARCHAR(50) = CASE ABS(CHECKSUM(NEWID())) % 2 WHEN 0 THEN 'Credit Card' ELSE 'Cash' END;

        -- Generate random PaymentDate between CheckInDate and CheckOutDate but not more than 3 months before CheckInDate
        DECLARE @PaymentDate DATE = DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % (30 * 3)), @CheckInDate);

        -- Check if the CheckInDate is before August 2024
        IF @CheckInDate <= '2024-08-01'
        BEGIN
            -- Book the room
            INSERT INTO Booking (BookingID, GuestID, RoomID, CheckInDate, CheckOutDate, TotalPrice)
            VALUES (@BookingID, @GuestID, @RoomID, @CheckInDate, @CheckOutDate, @TotalPrice);

            -- Make the payment record
            INSERT INTO Payment (PaymentID, PaymentAmount, PaymentMethod, PaymentDate, GuestID)
            VALUES (@PaymentID, @TotalPrice, @PaymentMethod, @PaymentDate, @GuestID);

            SET @BookingID = @BookingID + 1;
            SET @PaymentID = @PaymentID + 1;
        END;
    END;

    SET @Counter = @Counter + 1;
END;


create TABLE payment_temp (
    PaymentID INT PRIMARY KEY,
    PaymentAmount DECIMAL(10,2) NOT NULL,
    PaymentMethod VARCHAR(50) NOT NULL,
    PaymentDate DATE NOT NULL,
    GuestID INT FOREIGN KEY REFERENCES Guest(GuestID)
);
-- Insert data into the temporary dimension table from the Payment table
INSERT INTO paymepayment_temp(PaymentID, PaymentAmount, PaymentMethod, PaymentDate, GuestID)
SELECT PaymentID, PaymentAmount, PaymentMethod, PaymentDate, GuestID, NULL
FROM Payment;

