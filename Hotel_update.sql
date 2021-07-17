/*
RDBMS used: MySQL
*/

USE Hotels;

SET SQL_SAFE_UPDATES = 0;


-- Update A
/* Updates the public rating of the Finzels Reach Hotel to 8.0. */
UPDATE Hotel SET Hotel.rating = 8.0 -- new rating
WHERE Hotel.hotelName = 'Finzels Reach Hotel' ;

SELECT hotelName, rating FROM Hotel WHERE Hotel.hotelName = 'Finzels Reach Hotel';


-- Update B
/* Joe Smiths booked a double bed in the Finzels Reach Hotel today, the check-in date is 26/12/2018, 
the check- out date is 29/12/2018, 1 adult and 1 child, with breakfast, he chose to ‘pay on arrival’. */
INSERT INTO Reservation (reservationID, reservationDate, checkIn, checkOut, breakfast, payOnArrival, paymentOption, numOfChildren, numOfGuests, customerID ) 
	VALUES (NULL, CURDATE(), '2018-12-26', '2018-12-29', TRUE, TRUE, 'Card', 1, 1,       
		(SELECT customerID
		 FROM Customer 
		 WHERE firstName = 'Joe' AND
		 lastName = 'Smiths')
	);
    
-- new variable that stores all room ids that are not single and are available
SELECT @var := roomID 
	FROM Room AS r
		JOIN Hotel AS h ON
			r.hotelID = h.hotelID
			
	WHERE roomID NOT IN(SELECT roomID from AllReservations) AND roomType != 'Single'
	LIMIT 1;                  -- if there are many available rooms, limit to one only 
    
-- insert the available room into AllReservations for the future record
INSERT INTO AllReservations (roomID, reservationID, leadGuest) 
	VALUES( @var,
		(SELECT re.reservationID
		 FROM Reservation AS re
		 WHERE  re.customerID = 3 
		 LIMIT 1),
		NULL 
    );
    
-- creating an invoice for this resrvation
INSERT INTO Invoice (invoiceID, invoiceStatus, invoiceDate, reservationID, customerID) 
	VALUES( NULL, 'awaiting payment', CURDATE(), 
		(SELECT re.reservationID
		 FROM Reservation AS re
		 WHERE  re.customerID = 3),
		3
	);
                        
SELECT * FROM Invoice;


-- Update C
/* Ian Cooper would like to cancel his booking by offering the booking ID. */

DELETE FROM AllReservations WHERE reservationID = 1 ; -- 1 is Ian Cooper's bookingID
SELECT * FROM AllReservations;

UPDATE Invoice SET invoiceStatus = 'Canceled' -- the invoice status also needs to be updated
	WHERE reservationID = 1;

SELECT * FROM Invoice;


-- Update D
/*  Finzels Reach Hotel would like to decrease the discount of all 
family rooms to 5%, keeping the same grace period as before. */

UPDATE Hotel SET premiumDiscount = 0.05 -- new discount
	WHERE hotelName LIKE '%Finzels Reach Hotel%' ;

SELECT hotelName, premiumDiscount from Hotel where Hotel.hotelName LIKE 'Finzels Reach Hotel' ;


-- Update E
/* Because of refurbishment, all the rooms’ state on the first floor (starting with digit 1) in the Finzels Reach Hotel 
are changed to ‘unavailable’ from 01/6/2019 to 10/6/2019. */

-- inserting into Refurbishment all rooms from the first floor
INSERT INTO Refurbishment (roomID)
	SELECT roomID
	FROM Room AS r
		JOIN Hotel AS h ON
			r.hotelID = h.hotelID
				
	WHERE h.hotelName LIKE 'Finzels Reach Hotel' AND
	r.roomNumber LIKE '1%'; -- room number that begin with 1

-- once in the refurbishment are inserted all rooms on the first floor, descriptions, start and end date must be updated 
UPDATE Refurbishment SET startDate = '2019-06-01', endDate = '2019-06-10', descriptions = 'Refurbishment on the 1 st floor'
WHERE roomID IN (
	SELECT roomID
	FROM Room AS r
		JOIN Hotel AS h ON
			r.hotelID = h.hotelID
				
	WHERE h.hotelName LIKE 'Finzels Reach Hotel' AND
	r.roomNumber LIKE '1%'
); 

SELECT * FROM Refurbishment;


SET SQL_SAFE_UPDATES = 1;