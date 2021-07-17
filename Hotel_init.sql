/*
RDBMS used: MySQL
*/

DROP DATABASE IF EXISTS Hotels;
CREATE DATABASE Hotels;
USE Hotels;

CREATE TABLE Hotel(
	hotelID int AUTO_INCREMENT UNIQUE,
    hotelName varchar(30) NOT NULL,
    email varchar(50) NOT NULL UNIQUE,
    phoneNumber varchar(15) NOT NULL UNIQUE,
    address varchar(255) NOT NULL UNIQUE,
    postCode varchar(10) NOT NULL,
    facilities varchar(255) NOT NULL,
	breakfastPrice float NOT NULL,
    standartPrice float NOT NULL,
	premiumPrice float NOT NULL,
	standardDiscount float NOT NULL,
	premiumDiscount float NOT NULL,
    rating float,
	instructions varchar(255),
   
	PRIMARY KEY (hotelID)
);


CREATE TABLE Customer (
	customerID int AUTO_INCREMENT UNIQUE,
    title varchar(5) NOT NULL,
    firstName varchar(30) NOT NULL,
    lastName varchar(30) NOT NULL,
    email varchar(50) NOT NULL UNIQUE,
    phoneNumber varchar(15) NOT NULL UNIQUE,
    address varchar(255) NOT NULL,
    postCode varchar(10) NOT NULL,
    dateOfBirth date NOT NULL,
    cardNo bigint,
    expireDate varchar(5),

	PRIMARY KEY (customerID)
);


CREATE TABLE Reservation (
	reservationID int AUTO_INCREMENT UNIQUE,
    reservationDate date NOT NULL,
    checkIn date NOT NULL,
    checkOut date NOT NULL,
    breakfast boolean NOT NULL,
    payOnArrival boolean NOT NULL,
	paymentOption varchar(20) NOT NULL,
    numOfChildren smallint,
    numOfGuests smallint,
	customerID int ,
    
	PRIMARY KEY (reservationID),
	FOREIGN KEY (customerID) REFERENCES Customer (customerID)
);


CREATE TABLE Room (
	roomID int AUTO_INCREMENT UNIQUE,
    roomNumber varchar(6) NOT NULL,
    roomType varchar(10) NOT NULL,
    hotelID int,

	PRIMARY KEY (roomID),
	FOREIGN KEY (hotelID) REFERENCES Hotel (hotelID)
);

CREATE TABLE Refurbishment (
    startDate  date ,
    endDate date,
    descriptions varchar(200),
    roomID int,
    
	FOREIGN KEY (roomID) REFERENCES Room (roomID)
);


CREATE TABLE AllReservations (
	roomID int,
    reservationID int,
    leadGuest varchar(50),
    
	FOREIGN KEY (roomID) REFERENCES Room (roomID),
	FOREIGN KEY (reservationID) REFERENCES Reservation (reservationID)
);


CREATE TABLE Invoice (
	invoiceID int AUTO_INCREMENT UNIQUE,
    invoiceStatus  varchar(20) NOT NULL,
    invoiceDate date NOT NULL,
    reservationID int,
    customerID int,
    
	PRIMARY KEY (invoiceID),
	FOREIGN KEY (reservationID) REFERENCES Reservation (reservationID),
	FOREIGN KEY (customerID) REFERENCES Customer (customerID)
);


INSERT INTO Hotel (hotelID, hotelName, email, phoneNumber, address, postCode, facilities, breakfastPrice,  standartPrice, premiumPrice, standardDiscount, premiumDiscount, rating, instructions) VALUES 
(NULL, 'Mercury Platinum', 'platinum_reception@mercury.com', '+4456717321', 'St Davids 1, Exeter, UK', 'EX4 4PH', 'Wi-Fi, free parking', 7.8,  34.6, 48, 0.3, 0.15, 8.7, ' Check in after 10:00 AM'),
(NULL, 'Finzels Reach Hotel','finzel_reception@finzels.com', '+4456717323', 'Cecil 14, Bristol, UK', 'BS4 4OH', 'Wi-Fi, sauna, free parking, restaurant, spa', 9.5,  40, 49.6, 0.3, 0.15, 9.9, ' Check in after 10:00 AM'),
(NULL, 'Mercury Inn', 'inn_reception_bristol@mercury.com', '+4456717324', 'Howard road 19, Bristol, UK', 'BS3 6CU', 'Wi-Fi', 5.7,  34.6, 38, 0.3, 0.15, 8.2, ' Check in after 10:00 AM'),
(NULL, 'Mercury Premium', 'premium2_reception_bristol@mercury.com', '+4456717325', 'Bonhay road 10, Bristol, UK', 'BS4 8WR', 'Wi-Fi, sauna, free parking', 7.6,  39, 45.6, 0.3, 0.15, 9.6, ' Check in after 10:00 AM');


INSERT INTO Customer (customerID, title, firstName, lastName, email, phoneNumber, address, postCode, dateOfBirth, cardNo, expireDate) VALUES 
(NULL, 'Mr', 'Ian', 'Cooper', 'ian_cooper@hotmail.com', '+44778990234','Elton road 3, London, UK', 'LN4 2PH', '1990-08-23', 3345672950684930, '08-20'),
(NULL, 'Mr', 'Jim', 'Jeffers', 'jeffers@gmail.com', '+44778911114','St DavIDs 3, Exeter, UK', 'EX4 3GH', '1970-09-12', NULL, NULL),
(NULL, 'Mr', 'Joe', 'Smiths', 'joe_smiths@apple.com', '+447234990345','Bonnington grove 17, London, UK', 'LN1 3FH', '1985-12-03', 3345222211115556, '09-21'),
(NULL, 'Miss', 'Ellen', 'Din', 'ellen_din@hotmail.com', '+44778990111','Primary road 15, Bristol, UK', 'BO7 9JH', '1995-08-01', NULL, NULL),
(NULL, 'Mrs', 'Maria', 'Nest', 'maria@btinternet.co.uk', '+44778991231','Waterloo road 20, London, UK', 'LN1 7LD', '1977-01-20', 1111333322228888, '10-19'),
(NULL, 'Mr', 'DavID', 'White', 'davID_white@hotmail.com', '+44778999999','Monks road 1, London, UK', 'LN4 8PH', '1980-05-16', 9098364728395647, '01-20'),
(NULL, 'Mrs', 'Alice', 'Bloodworth', 'alice@hotmail.com', '+447789999120','Primary road 15, Exeter, UK', 'EX7 9JH', '1995-08-01', NULL, NULL),
(NULL, 'Mr', 'Ben', 'Nowland', 'ben_nowland@btinternet.co.uk', '+44778990000','Waterloo road 20, Manchester, UK', 'MN1 3KD', '1977-01-20', NULL, NULL),
(NULL, 'Mr', 'James', 'Pablo', 'james_pablo@hotmail.com', '+447789993339','Monks road 1, Lancaster, UK', 'LA2 9PH', '1980-05-16', 9098364728395647, '02-22');


INSERT INTO Reservation (reservationID, reservationDate, checkIn, checkOut, breakfast, payOnArrival, paymentOption, numOfChildren, numOfGuests, customerID ) VALUES 
(NULL, '2018-11-22', '2018-12-25', '2018-12-27', True, False, 'Card', 0, 2, 1),
(NULL, '2018-11-22', '2018-12-25', '2018-12-30', True, False, 'Card', 0, 0, 2),
(NULL, '2018-11-23', '2018-11-24', '2018-12-01', True, True, 'Cash', 1, 1, 4),
(NULL, '2018-11-23', '2018-12-19', '2018-12-27', False, True, 'Cash', 0, 0, 5),
(NULL, '2018-11-23', '2018-12-12', '2018-12-15', False, True, 'Card', 1, 0, 6),
(NULL, '2018-12-12', '2018-12-29', '2019-01-20', True, True, 'Card', 0, 1, 7),
(NULL, '2018-12-12', '2018-12-23', '2018-12-27', False, False, 'Card', 2, 1, 8),
(NULL, '2018-12-12', '2018-12-30', '2019-01-04', True, False, 'Card', 0, 1, 9),
(NULL, '2018-11-22', '2019-01-21', '2019-02-01', True, False, 'Card', 0, 0, 1);


INSERT INTO Room (roomID, roomNumber, roomType, hotelID) VALUES 
(NULL, '101', 'Double', 2),
(NULL, '102', 'Single', 2),
(NULL, '201', 'Double', 2),
(NULL, '202', 'Single', 2),
(NULL, '203', 'Single', 2),
(NULL, '204', 'Family', 2),
(NULL, '205', 'Double', 2),

(NULL, '101', 'Double', 3),
(NULL, '102', 'Twin', 3),
(NULL, '103', 'Single', 3),
(NULL, '108', 'Single', 3),
(NULL, '201', 'Single', 3),
(NULL, '202', 'Family', 3),
(NULL, '203', 'Double', 3),

(NULL, '101 A', 'Single', 4),
(NULL, '102 B', 'Double', 4),
(NULL, '201 C', 'Twin', 4),
(NULL, '202 D', 'Double', 4),
(NULL, '203 A', 'Double', 4);


INSERT INTO AllReservations (roomID, reservationID, leadGuest) VALUES 
( 1, 1, NULL),
( 2, 1, 'Sarah Freeman'),
( 9, 2, NULL),
( 10, 3, NULL),
( 4, 4, NULL),
( 11, 5, NULL),
( 6, 6, NULL),
( 7, 7, NULL),
( 8, 8, NULL),
( 9, 5, NULL),
( 14, 9, NULL);


INSERT INTO Invoice (invoiceID, invoiceStatus, invoiceDate, reservationID, customerID) VALUES 
( NULL, 'Paid', '2018-02-03', 1, 1),
( NULL,  'Awaiting payment', '2018-02-03', 2, 2),
( NULL,  'Paid', '2018-02-03', 3, 3),
( NULL,  'Paid', '2018-02-03', 4, 4),
( NULL,  'Paid', '2018-02-03', 5, 5),
( NULL,  'Payment overdue', '2018-02-03', 6, 6),
( NULL,  'Awaiting payment', '2018-02-03', 7, 7),
( NULL,  'Awaiting payment', '2018-02-03', 8, 8),
( NULL,  'Awaiting payment', '2018-02-03', 9, 9);



