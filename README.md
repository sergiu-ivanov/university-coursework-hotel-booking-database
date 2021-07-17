# HotelBookingDatabase

Design and implementation of a hotel booking database in MySQL

<img width="501" alt="Screenshot 2021-07-17 at 19 20 59" src="https://user-images.githubusercontent.com/43847681/126043378-da8efc6d-e4ba-42b6-bde9-c67ac397fc99.png">

Physical Model:

<img width="475" alt="Screenshot 2021-07-17 at 19 25 20" src="https://user-images.githubusercontent.com/43847681/126043454-96bac67f-8bf7-4e54-9a8f-6d0e70d6f777.png">
<img width="473" alt="Screenshot 2021-07-17 at 19 25 34" src="https://user-images.githubusercontent.com/43847681/126043455-b361bb14-3dc9-496b-b609-cad665e452ef.png">

#### User Requirement Specification

#### Hotels

The database must hold records of the hotels. The hotels are identified by their name and address, however the table should also store unique hotel ID. The system must hold other information about the hotel like its facilities and public rating in order to help the customer choose the most suitable hotel. The customer needs a way of contacting hotel, therefore email and phone number of the hotel must be stored. It is also needed to store the prices and discount rates for different room types in order to avoid data repetition by storing this information in room database. Breakfast price is also important information to store in the database.

#### Room

Each hotel contains many rooms of a different type. So, after selecting a specific hotel, the customers need to select the type of the room they would like to stay in (Single, Double, Twin or Family). There must be a way to identify the room, as well as its location, therefore room number must be stored. Room number may include letters in order to identify which building it is in. For example, room number ‘205 A’ means it is on the second floor in the building ‘A’. Since the database holds data of different hotels, the room number cannot be used as primary key, therefore room ID is needed.

#### Reservation

The system must keep records of the room reservations, which could be identified by their unique ID, also used as reservation reference. Reservation record must hold customer ID, which links the reservation to the customers details. The system must hold the check-in and check-out dates, which will also be used for identifying which rooms are available during specific time period. The date of when the reservation was created is important, as it will help identify the discount eligibility. Customer might travel with other guests and children, therefore both the numbers needs to be stored. This will be used to both identify the total breakfast price and needed for security purposes. It is also needed to know which payment option the customer prefers- pay on arrival or during online booking, pay by cash or card.

#### Customer

The customer makes a reservation and his details must be stored in a table for further use. Each customer is identified by their unique ID, title, first & last name along with their date of birth. The database should also store customers contact details such as telephone number, email and address. Since the customer may want to cancel the booking for which he has paid online, the system should store the credit card number and the expiry date of the card, however the customer should have the option not to store this information. Card details must be hashed when moving to a functioning online server to ensure data integrity and must be encrypted to prevent its corruption.

#### AllResservations

Since the customer can make a reservation that might contain multiple rooms, it is essential to have a separate table that will hold this information in order to avoid data duplication. This allows linking different rooms to the same reservation reference, allowing the customer to make one reservation for separate rooms. For each room there must be a lead guest, therefore if there are multiple rooms booked, for each room there needs to be lead guest name specified and stored.
Invoice
The invoice is issued when the reservation is made and is identified by its unique ID. It also stores the invoice date and the status of the payment which can be either "Paid", "Awaiting payment" or "Cancelled". The invoice references to the customer through their customer ID.

#### Justification of the Design:

#### Hotel
Is a strong entity created to store a chain of hotels and information about each of them. The essential attributes for each hotel are its unique primary key hotelID, since in a hotel chain may exist different hotels with the same name, for example "Premier Inn". The email address is the alternate key and is also unique for each hotel. The breakfastPrice is kept in the hotel entity and not in the reservation because the price is different for each hotel. Room prices and the discount are also kept in the hotel and not in the room entity, to avoid data duplication. Other important attributes such as the hotel name, facilities, instructions and rating were also added to give basic information about each of them. The address is a composite attribute, because it does contain multiple components such as street and house number. The phone number is a single-valued attribute holding the reception phone number.

#### Room 
Is also a strong entity and contains just four simple attributes. Its purpose is to store room numbers and their type and link them to different hotels. The room number cannot be a primary key as other hotels may have the same room numbers. Therefore, roomID is the primary key that helps to identify each room uniquely. HotelID represents the foreign key that reference each room to a particular hotel. RoomNmber is of a varchar data- type because it can contain a letter at the end of the room number such as "102A" to denote its location, assuming there are multiple wings in any of the hotels. RoomType atribute represents the room type that can be either single, double, twin or family.

#### Refurbishment 
Is a weak entity and keeps record of any room that are under refurbishment process. StartDate and endDate specify how long the refurbishment is going to take. Descriptions attribute contain some useful information about refurbishment such as the floor number. The foreign key roomID references the refurbishment to each room.

#### Customer 
Is a strong entity and its role is to keep most data related to the customer in one place. Since in this entity may exist customers with the same first and last names, customer name cannot be the primary key. To solve this issue, customerID will be the primary key that identifies each customer uniquely. Email address is the alternate key and is unique for each customer. The title, date of birth, first name, last name, card number and expire day are all simple single-valued attributes. Datatype for card number is bigInt as there are 16 digits

in a credit card number. The post code is also a simple attribute, while the address is a composite attribute, because it contains the street name and the house number. The phone number is not a multi-valued attribute, as one mobile number is enough, besides the email address, where a customer may be contacted alternatively.

#### Reservation 
Is a strong entity as well and is designed to keep all reservations together. ReservationID is the primary key that will differentiate the reservations between them. CustomerID is the foreign key that links each reservation to its customer. Reservation date, check in and check out are single-valued attributes that are of a date data-type. Breakfast is of a Boolean type which can be true if the customer has chosen to include it in reservation and false otherwise. Each reservation specifies the number of guests and children that could be zero or more. The data type for these two atributes is set to smallInt to save space, as their value is small. PayOnArrival is of Boolean type and is true if the customer chooses to pay when arrives at the hotel and false otherwise. PaymentOption specifies payment option that can be either by card or with cash.

#### AllReservations 
Is a weak entity because it doesn't have a primary key. Every reservation may contain one or more rooms and the same room may be booked at different times in various reservations. Therefore, to avoid multi-valued attribute or data duplication in other entity such as Reservation, AllReservations entity was designed. RoomID and ReservationID are the foreign keys that links each room to a specific reservation. The lead guest is a composite attribute that contains first and last name of a lead guest. If there is no a lead guest, either because the customer is alone or he decided to be the lead guest, the value will be null. In this way, each room will have a lead guest even if there are multiple rooms booked in the same reservation.

#### Invoice 
Is a strong entity and its purpose is to store information related to the bill. InvoiceID is the primary key that identify each bill for each customer. InvoiceStatus is of a varchar type and represents the payment status which can be either "Paid", "Awaiting payment" or "Cancelled". InvoiceDate is a single-valued attribute that stores the issue date of the bill. Each invoice is referenced to a reservation through the foreign key ReservationID. Each invoice is issued for an individual customer and to achieve this, the customerID foreign key is also kept here.

#### Installing

Use MySQL as a database management system.

#### Running

1. Run the Hotel_init.sql to create the tables and insert data in them.
2. Run Hotel_query.sql to see the result of each query.
3. Run Hotel_update.sql ONCE to update the tables.
4. Run Hotel_query.sql again to see the changes in the table.

*  To reset all the data, begin from step 1.
