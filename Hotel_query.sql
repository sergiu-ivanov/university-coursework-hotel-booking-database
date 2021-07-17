/*
RDBMS used: MySQL
*/

USE Hotels;

-- Query A
/* List all Bristol hotels with public rating higher than 8.5 and whith free parking */
SELECT hotelName AS 'Name', address AS 'Address', rating AS 'Rating'
FROM Hotel 
WHERE
	address LIKE '%Bristol%'  AND
	rating > 8.5 AND 
    facilities LIKE '%free parking%';


-- Query B
/* List all available double rooms in all Bristol hotels on 26/12/2018, 
ordered by the price without breakfasts, offering basic room information and hotel information */
SELECT DISTINCT h.hotelName AS 'Hotel Name', h.address AS 'Hotel Address', h.postCode AS 'Postcode', 
h.phoneNumber AS 'Phone number', h.email AS 'Email', h.rating AS 'Public rating', h.facilities AS 'Facilities', 
r.roomType AS 'Room Type', GROUP_CONCAT(DISTINCT r.roomNumber SEPARATOR ', ') AS 'Room Numbers',
	IF  (DATEDIFF('2018-12-26', CURDATE() ) > 14, 
		ROUND((1-h.premiumDiscount) *h.premiumPrice,2), 
		ROUND(h.premiumPrice,2)) AS price

FROM 
	Hotel AS h
		JOIN Room AS r ON
			r.hotelID = h.hotelID,
			
	Reservation AS re 
		JOIN Customer AS c ON
			c.customerID = re.customerID 			
WHERE 
	r.roomType = 'double'  AND 
	h.address LIKE '%Bristol%' AND 
	r.roomID NOT IN (            -- need to make sure that the room is not reserved on 26/12/2018, 
		SELECT r.roomID			 -- therefore need to check if that room is not in the all reservations table
		FROM Room AS r 			 -- and if it is, check if date is not between the found reservation check in and out dates
			JOIN AllReservations AS allres ON
				allres.roomID = r.roomID,
		
		Reservation AS re
			JOIN AllReservations AS allre ON
				allre.reservationID = re.reservationID
		  
		WHERE '2018-12-26' BETWEEN re.checkIn AND re.checkOut 
        AND allre.roomID = r.roomID
	)
	
GROUP BY h.hotelID
ORDER BY price;


-- Query C
/* Display Ian Cooper’s booking information, and how much he has paid 
(suppose he has paid online right after booking). */
SELECT DISTINCT c.title AS 'Title', c.firstName AS 'First Name', c.lastName AS 'Second Name', 
r.reservationID AS 'Reservation reference', r.reservationDate AS 'Reservation Date', 
h.hotelName AS 'Hotel Name', h.address AS 'Hotel Address', r.checkIn AS 'Check in', 
r.checkOut AS 'Check out', r.numOfGuests AS 'Number of adult guests', r.numOfChildren AS 'Number of children', 

@nights := DATEDIFF(r.checkOut, r.checkIn) AS 'Nights',

-- since r.breakfast is a boolean, if it is true, only need to multiply the total number of people with the
-- total number ot nights to get the total number of breakfasts needed 
@breakfastQuantity := IF (r.breakfast, @nights * (1 + r.numOfGuests + r.numOfChildren), 0) AS 'Breakfast quantity',
@totalBreakfast := h.breakfastPrice * @breakfastQuantity AS 'Total breakfast price',

-- if reservation ID appears more than once in all reservations table, count.
@numberOfRooms := COUNT(IF(allre.reservationID = r.reservationID, TRUE, FALSE)) AS 'Number of Booked rooms', 

-- if leadGuest value is null, then the lead gues is the customer, otherwise get the value
GROUP_CONCAT(IF (allre.leadGuest IS NULL,  
	CONCAT_WS(' ', c.firstName, c.lastName), allre.leadGuest) 
	SEPARATOR ', ') AS 'Lead Guests', 

GROUP_CONCAT(ro.roomNumber SEPARATOR ', ') AS 'Room', 
GROUP_CONCAT(ro.roomType SEPARATOR ', ') AS 'Room Type',

-- if Ian booked the room more than 14 days ago, then a discount must be applied
-- also check which room type it is and calculate price per night
GROUP_CONCAT(@pricePerNight := IF(DATEDIFF(r.checkIn, r.reservationDate) > 14, 
	ROUND(IF (ro.roomType = 'Single', (1 - h.standardDiscount) * h.standartPrice, (1 - h.premiumDiscount) * h.premiumPrice), 2), 
	ROUND(IF (ro.roomType = 'Single', h.standartPrice, h.premiumPrice), 2) ) 
    SEPARATOR ', ') AS 'Price per night', 

-- if the customer only booked one room, then the simply multiply number of nights on the price per night 
-- and add total breakfast price
-- else sum the prices per night for each toom type and then multiply that value on the number of nights, adding 
-- total breakfast price
IF(@numberOfRooms = 1, 
	@nights * @pricePerNight + @totalBreakfast, 
    @nights * SUM(
		IF(DATEDIFF(r.checkIn, r.reservationDate) > 14, 
			ROUND(IF(ro.roomType = 'Single', (1 - h.standardDiscount) * h.standartPrice, (1 - h.premiumDiscount) * h.premiumPrice), 2), 
			ROUND(IF(ro.roomType = 'Single', h.standartPrice, h.premiumPrice), 2) )
		) + @totalBreakfast) 
	AS 'Total price',

r.paymentOption, i.invoiceStatus
    
FROM 
	Hotel AS h
		JOIN Room AS ro ON
			ro.hotelID = h.hotelID,
				
	Reservation AS r
		JOIN Customer AS c ON
			 r.customerID = c.customerID 
		JOIN Invoice AS i ON
			i.reservationID = r.reservationID
			AND i.customerID = c.customerID
		JOIN AllReservations as allre ON
			allre.reservationID = r.reservationID
	 
WHERE 
	ro.roomID = allre.roomID AND
	firstName = 'Ian' AND 
	lastName = 'Cooper'
GROUP BY c.firstName;


-- Query D
/* Find all the hotels whose double bedroom prices are higher than the average 
double bedroom price on 26/12/2018. */
SELECT @avr := AVG(IF(DATEDIFF('2018-12-26', CURDATE())  > 14, -- at first calculate the average
	((1- premiumDiscount) * premiumPrice), 
    premiumPrice ) 
    ) as 'Average double bedroom price on 2018-12-26'

FROM Hotel;

SELECT DISTINCT hotelName AS 'Hotel Name', address AS 'Address',
	IF (DATEDIFF('2018-12-26', CURDATE()) > 14, 
		ROUND((1- premiumDiscount) * premiumPrice,2), 
		ROUND(premiumPrice,2) 
	) AS 'Price'
	
FROM Hotel
WHERE IF (DATEDIFF('2018-12-26', CURDATE()) > 14, ((1- premiumDiscount) * premiumPrice), premiumPrice ) > @avr;


-- Query E
/* Produce a booking status report on all the rooms in the
Finzels Reach Hotel on 26/12/2018. */
SELECT DISTINCT h.hotelName AS 'Hotel Name', h.address AS 'Address', r.roomNumber AS 'Room Number',
	IF (r.roomID NOT IN ( -- The same as in query B
		SELECT r.roomID
		FROM Room AS r 
			JOIN AllReservations AS allres ON
				allres.roomID = r.roomID,
		
		Reservation AS re
			JOIN AllReservations AS allre ON
				allre.reservationID = re.reservationID
		  
		WHERE '2018-12-26' BETWEEN re.checkIn AND re.checkOut 
		AND allre.roomID = r.roomID
	), 'AVAILABLE', 'BOOKED') as 'Booking Status'

FROM Hotel AS h
		JOIN Room AS r ON
			r.hotelID = h.hotelID
WHERE
	h.hotelName = 'Finzels Reach Hotel';
    

-- Query F
/* List how many rooms there are in the Finzels Reach Hotel
for each room type (i.e., family, double, twin, single). */
SELECT r.roomType AS 'Room Type', COUNT(r.roomType) AS 'Amount'
FROM Room as r
	JOIN Hotel AS h ON
		r.hotelID = h.hotelID
        
WHERE h.hotelName = 'Finzels Reach Hotel'
GROUP BY roomType;


-- Query G
/* Count how many adult guests will be staying in the
Finzels Reach Hotel on 26/12/2018. */
SELECT DISTINCT h.hotelName AS 'Hotel Name', SUM(re.numOfGuests) AS 'Number of adult guests on 26/12/2018'
FROM 
	Hotel as h, 
	Reservation AS re
WHERE
	h.hotelName = 'Finzels Reach Hotel' AND
	'2018-12-26' BETWEEN re.checkIn AND re.checkOut
GROUP BY h.hotelName;


-- Query H
/* List all the availability for the Room 204 in the Finzels
Reach Hotel in from 25/12/2018 to 30/12/2018. On each
day, list the booking customer’s name if it is booked. */
DROP TABLE IF EXISTS AllDates; 
CREATE TABLE AllDates (    -- need to create a table for all the dates between 25/12/2018 and 30/12/2018
    dt DATE PRIMARY KEY
);

INSERT INTO AllDates (dt) VALUES 
('2018-12-26'),
('2018-12-27'),
('2018-12-28'),
('2018-12-29'),
('2018-12-30');

SELECT DISTINCT h.hotelName AS 'Hotel Name', r.roomNumber AS 'Room Number', dt AS 'Date',
-- for each date in the AllDates table, check if it is between check in and check out dates in reservations
@av := IF(dt BETWEEN re.checkIn AND re.checkOut,'BOOKED', 'AVAILABLE') AS 'Availability', 
IF(@av = 'BOOKED', CONCAT_WS(' ', c.firstName, c.lastName), NULL) AS 'Customer Name'
		             
FROM 
	AllDates,
	Hotel AS h
		JOIN Room AS r ON
			r.hotelID = h.hotelID,
				 
	Reservation AS re
		JOIN Customer AS c ON
			 re.customerID = c.customerID 
		JOIN AllReservations as allre ON
			allre.reservationID = re.reservationID
	
WHERE
	r.roomNumber = '204' AND
    allre.roomID = r.roomID AND
	h.hotelName = 'Finzels Reach Hotel';


-- Query I
/* List how many breakfasts have been ordered in the
Finzels Reach hotel on 26/12/2018. */
SELECT DISTINCT h.hotelName AS 'Hotel Name',
SUM(IF (re.breakfast = TRUE, TRUE, FALSE)) AS 'Number ordered breakfasts on 26/12/2018'
FROM 
	Hotel AS h
		JOIN Room AS r ON
			r.hotelID = h.hotelID,
            
	Reservation AS re
		JOIN AllReservations as allre ON
			allre.reservationID = re.reservationID
	
WHERE
	r.roomID = allre.roomID AND
	h.hotelName = 'Finzels Reach Hotel' AND
	'2018-12-26' BETWEEN re.checkIn AND re.checkOut
GROUP BY h.hotelName;