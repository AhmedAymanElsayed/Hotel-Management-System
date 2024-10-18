CREATE TABLE DIM.Staff (
	Staff_Key INT PRIMARY KEY IDENTITY(1,1),
  Staff_ID INT ,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Position VARCHAR(50) NULL,
    Salary DECIMAL(10,2) NULL,
  Phone VARCHAR(15) NULL,
  Email VARCHAR(255) NULL,
  Hire_Date DATE,
  start_date DATE,
  end_date DATE,
  acive_flag Bit
);


CREATE TABLE DIM.Hotel (
	Hotel_Key INT PRIMARY KEY IDENTITY(1,1),

  Hotel_ID INT,
    Name VARCHAR(255),
    Address VARCHAR(255),
    Phone VARCHAR(15),
    Email VARCHAR(255),
  Stars INT,
  start_date DATE,
  end_date DATE,
  acive_flag Bit
);


CREATE TABLE DIM.Guest (
	Guest_Key INT PRIMARY KEY IDENTITY(1,1),
  Guest_ID INT ,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Address VARCHAR(255) NULL,
    DateOfBirth DATE NULL,
    Phone VARCHAR(15) NULL,
    Email VARCHAR(255) NULL,
  start_date DATE,
  end_date DATE,
  acive_flag Bit
);

CREATE TABLE DIM.Room (
	Room_Key INT PRIMARY KEY IDENTITY(1,1),
  Room_Num INT ,
  Room_Type varchar(50) NOT NULL,
  Capacity INT,
  Price_Per_Night DECIMAL,
  Status varchar(20),
  start_date DATE,
  end_date DATE,
  acive_flag Bit
);


CREATE TABLE DIM.Payment (
	Payment_ID int primary key,
	Amount Decimal,
	Payment_Method varchar(50)
);


CREATE TABLE FACT.StaffSalariesFact (
  Staff_Salaries_Fact_ID INT PRIMARY KEY IDENTITY (1,1),
  Staff_ID INT FOREIGN KEY REFERENCES DIM.Staff(Staff_Key),
  Hotel_ID INT FOREIGN KEY REFERENCES DIM.Hotel(Hotel_Key),
  Date_Key INT FOREIGN KEY REFERENCES Date_Dimension(Date_Key),
  Salary Decimal
);


CREATE TABLE FACT.BookingFact (
  Booking_ID INT PRIMARY KEY,
  Guest_ID INT FOREIGN KEY REFERENCES DIM.Guest(Guest_Key),
  Hotel_ID INT FOREIGN KEY REFERENCES DIM.Hotel(Hotel_Key),
  Room_Num INT FOREIGN KEY REFERENCES DIM.Room(Room_Key),
  Check_In_Date INT,
  Check_Out_Date INT,
  Total_Peice INT -- Measure, semi-additive
);


CREATE TABLE FACT.RoomStatusFact (
  Room_Status_Fact_Key INT PRIMARY KEY IDENTITY (1,1),
  Hotel_ID INT FOREIGN KEY REFERENCES DIM.Hotel(Hotel_Key),
  Date_Key INT FOREIGN KEY REFERENCES Date_Dimension(Date_Key),
  Available_Rooms INT ,
  Busy_Rooms INT,
  Available_Rooms_Percentage Decimal,
  Busy_Rooms_Percentage Decimal,
);


CREATE TABLE FACT.PaymentFact (
  Payment_fact_ID INT PRIMARY KEY IDENTITY (1,1),
  Payment_ID INT FOREIGN KEY REFERENCES DIM.Payment(Payment_ID),
  Payment_Method varchar(50),
  Total_Amount DECIMAL, -- Measure, semi-additive,
  Date_Key INT FOREIGN KEY REFERENCES Date_Dimension(Date_Key),
  Hotel_ID INT FOREIGN KEY REFERENCES DIM.Hotel(Hotel_Key)
);









