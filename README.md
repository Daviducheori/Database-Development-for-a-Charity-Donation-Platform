# Database-Development-for-a-Charity-Donation-Platform

### Table of Contents
- [Project Overview](#project-overview)
- [Requirement Analysis](#requirement-analysis)
- [Database Design](#database-design)
- [Implementation in Postgresql](#implementation-in-postgresql)
- [Stored Procedures Triggers and Constraints Documentation](#stored-procedures-triggers-and-constraints-documentation)
- [Stored Procedures](#stored-procedures)
- [Triggers](#triggers)
- [Constraints](#constraints)
- [Optimizing Database Performance](#optimizing-database-performance)
- [Security Measures](#security-measures)


### Project Overview

The relational database for this project was developed using PostgreSQL, a powerful and feature-rich open-source relational database management system.

### Requirement Analysis

The stakeholders have highlighted a number of requirements for the platform. These requirements are crucial for the successful development and implementation of the platform. Based on their input, the following list of requirements has been identified:

- The system should allow users to register and store their information, such as name, email, password, phone, address, postcode.
- The system should support admin users who can be associated with regular user accounts for administrative purposes.
- The system should allow users to make donations to Charities, and store relevant information about the donors.
- The system should track information about donations made, including donor information, donation amount, and donation timestamp.
- The system should record and associate donations with specific charities, allowing charities to track donations received.
- The system should store information about Charities, including name, description, registration number, website, email, and phone number.
- Charities should be able to create and manage their own accounts, allowing them to update their profiles.
- The system should support different causes that Charities may support, such as poverty, health, education, etc.
- The system should allow for subcategories within causes to be stored, providing more specific categorization of Charities.
- Charities should be able to associate themselves with multiple causes and subcategories, and causes should be associated with multiple charities.
- The system should store information about locations, including name, address, postcode, country, city, latitude, and longitude, to link with charities.
- Charities might have multiple locations, and locations should be associated with multiple Charities.
- The system should store information about events organized by Charities, including event name, description, location, start time, and end time.
- Charities should be able to organise events and users should also be able to attend events.
- The system should support communities or groups with names and descriptions.
- Users should be able to join different communities.
- Users should be able to send and receive messages to and from other users, with message content, sender ID, recipient ID, and timestamp tracking.

## Database Design
The design of a database typically includes three main components: conceptual structure design, logical structure design, and physical structure design.

### Conceptual Design
To accurately describe a real-world requirements for users, a conceptual model is created by grouping and condensing information. This model should represent the structure and flow of information. It should remain abstract and avoid specific implementation details of the database on the computer. The Hiroek Entity-Relationship diagram is shown below.

![image](https://github.com/Daviducheori/Database-Development-for-a-Charity-Donation-Platform/assets/76125377/fe40306a-9d66-4e92-909a-5710b2fb27d0)


### Logical Design
In the conceptual design phase, the E-R diagram is created with entities, attributes, and relationships. In the logical design phase, the E-R diagram is transformed into a set of related relational patterns that constitute the relational database. This transformation involves converting the entities, attributes, and relationships of the system into relational patterns. During the development of a logical data model, the model is tested and validated to ensure it aligns with the requirements of the users. Normalisation is a technique utilised to verify the accuracy of a logical data model by ensuring that the derived relations from the model do not contain data redundancy. This helps prevent update anomalies when the data model is implemented.

Based on the proposed concept of 1NF -3NF by Dr. E.F. Codd between 1971 - 1972 and R. Boyce and E. F. Codd (Codd, 1974) the following normalisation rules were applied.
- First Normal Form (1NF): I ensured that all tables possess a primary key column that distinctively identifies each row in the table, for example the "id" column in most tables. This eliminates duplicate rows and ensures that each row has a unique identifier.
- Second Normal Form (2NF): I ensure tables like "Charity", "Subcategory", and "CharityCause" have separate tables for related data and use foreign keys to establish relationships between tables. This eliminates redundancy and ensures that each table contains only data that is related to the primary key.
- Third Normal Form (3NF): I ensured tables like "Charity", "Location", "Cause", and "Users" have columns that are dependent only on the primary key and do not have transitive dependencies. This eliminates redundancy and ensures that each column contains only data that is directly related to the primary key.
- Boyce-Codd Normal Form (BCNF): I ensured Tables like "Charity", "CharityAccount", "CharityCause", and "CharityLocation" do not have any overlapping candidate keys, and all non-prime attributes are fully functionally dependent on the primary key. This eliminates redundancy and ensures that each table is in a state where all dependencies are preserved.

The relationship patterns converted in the logic design phase are as follows:
1. Users (Id, title, firstname, middlename, lastname, birthdate, gender, email, password, phone, user_contact_address1, user_contact_address2, user_contact_address3, user_contact_address4, user_contact_address5, postcode, created_at)
2. Admin (Id, Users_id, created_at)
3. Charity (id, charity_name, description, registration_number, website, email, phone, logo_filename, location_id, causes, subcategory)
4. CharityAccount (Id, charity_id, username, password)
5. Location (id, country, city, address, postcode, latitude, longitude)
6. CharityLocation (charity_id, location_id)
7. Cause (id, name)
8. Subcategory (id, name, cause_id)
9. CharityCause (charity_id, cause_id, subcategory_id)
10. Donors (id, users_id, charity_id, donation_amount, donation_date)
11. Donation (id, donor_id, payment_method, donation_status)
12. Donations_to_Charities (donation_to_charity_id, donation_id, charity_id)
13. Event (id, charity_id, Name, description, location_id, start_time, end_time)
14. EventAttendance (users_id, event_id)
15. Communities (community_id, name, description)
16. Community_Members (members_id, users_id, community_id)
17. Messages (message_id, sender_id, recipient_id, content, timestamp)

### Physical Design
The physical design involves selecting an appropriate relational database management system (RDBMS) based on the logical structure of the database and designing the storage structure and access methods for the database. It focuses on the actual implementation of the database, considering performance, storage requirements, and other practical considerations. After the analysis and design process, it was determined that the system should consist of 17 information tables.
1. The Users table which stores user information.
2. The Admin table includes an id column for the admin user, as well as a foreign key reference to the User table. This allows you to associate admin users with regular user accounts.
3. The Donors table which stores information about the users who donate to Charities.
4. The Donations table which stores information about the donations made by donors.
5. The Donations_to_Charities table will store information about the donations made to each Charity. It associates donations with the Charities that receive them.
6. The Charity table contains information about each Charity.
7. The CharityAccount table allow Charities to have an account and access to update their profile.
8. The Cause table contains a list of causes that Charities may support.
9. The subcategories are stored in the Subcategory table. The Subcategory table has a foreign key that references the id column in the Cause table, indicating which main cause the subcategory belongs to.
10. The CharityCause table is a junction table that links the Charity, Causes and Subcategory tables together. This table has three foreign keys that reference the id columns in the Charity, Cause and Subcategory tables, respectively. This table allows a Charity to support multiple causes, cause to be supported by multiple Charities also allows a Charity to support multiple subcategories within a cause.
11. The Location table contains information about each location. This would allow you to associate each charity with a specific location in the UK.
12. The CharityLocation table is a junction table that links the Charity and Location tables together. This table has two foreign keys that reference the id columns in the Charity and Location tables, respectively. This table allows a Charity to be in multiple locations, and a location to have multiple Charities.
13. The Event table stores information about events, including the Charity organizing the event.
14. The EventAttendance table is a many-to-many table that tracks which users are attending which events.
15. The Communities table stores information about different communities or groups, including a name and description.
16. The Community_Members table links users to the communities they are members of, with a unique ID for each membership record.
17. The Messages table stores information about messages that users send to each other.

![image](https://github.com/Daviducheori/Database-Development-for-a-Charity-Donation-Platform/assets/76125377/f01f036e-1b1d-44e4-9751-ef63306a44e6)

Schema for the database

## Implementation in Postgresql
This section highlights the use of PostgreSQL in the development of a database system, which involved setting up the database, defining the schema, inserting data, and querying the database using SQL.

#### Setting Up the Environment
To work with PostgreSQL, PgAdmin4 was installed. PgAdmin4 is an open-source client for PostgreSQL.

####Creation of Database
The database was created through PgAdmin4.

#### Importing Data into PostgreSQL
Three tables were created with the defined schema and populated with data from the transformed CSV file. The DELIMITER ',' option specifies that the delimiter used in the CSV file is a comma, and the CSV HEADER option specifies that the first line of the CSV file contains the column names.

#### Creation of Tables
To organize and store the data, a relational database was created, that consists of 17 tables.

### Stored Procedures Triggers and Constraints Documentation
#### Stored Procedures
A stored procedure is a set of pre-written SQL queries stored in a database system that can be executed upon request (Suver, 2020). A few stored procedures were created to perform various functions, such as recording donations, retrieving donor information, updating donor information, deleting donations. They are intended to support the functionality and operations of the charity donation platform.

- Calculate Age of Users:
To calculate the age of users in the system based on their birthdate, a stored function named calculate_age was created. This function uses birthdate parameter of type date and returns an integer value representing a user's age.

- Get Donation Total:
This procedure retrieves the total donations made by a specific donor or Charity. It takes the donor_id or charity_id as a parameter and returns the total amount donated.

- Get Donor Information:
This stored procedure could be used to retrieve information about a specific donor based on their donor ID or email. It could retrieve donor details such as name, email,donation history, and other relevant information from the database and return it to the caller.

- Update Donor Information:
This stored procedure could be used to update the information of a specific donor, such as their name, email, or other details. It could take input parameters such as donor ID, updated information, and perform validation checks before updating the donor information in the database.

### Triggers
A database trigger is a form of procedural code that is automatically executed in response to specific events occurring on a particular table or view within a database, triggers are commonly used to ensure the integrity of information stored in the database.

- Creating a Trigger to Set Default Password:
This trigger is designed to automatically set a default password for new users in the charity donation platform. The trigger function generates a random password and encrypts it using the bcrypt algorithm, and then assigns the encrypted password to the "password" field of the new user record.

- Update Total Donations:
This trigger updates the total donations field in the donors table whenever a new donation is inserted, or an existing donation is deleted from the donors’ table.

- Donor Level Update:
This trigger could be used to automatically update the donor's level or status based on their total donation amount. For example, it could update a donor's level from "Bronze" to "Silver" when their total donation amount exceeds a certain threshold. It could be triggered by an INSERT or UPDATE operation on the donation table and update the donor's level in the donor table.

### Constraints
Constraints play a critical role in relational databases, as they are the sole mechanism that prevents the storage of invalid or implausible data in the database instances (Mancas, 2015).

- Constraint "chk_email":
The "chk_email" constraint validates that email addresses stored in the database conform to a specific pattern: a single '@' symbol, followed by at least two characters, a dot (.), and finally at least two characters after the dot. This constraint ensures that only correctly formatted email addresses are stored, minimizing the risk of storing incorrect or invalid email addresses in the database. In summary, the "chk_email" constraint ensures that email addresses are properly formatted, enhancing data accuracy and integrity.

- Constraint "chk_password":
The "chk_password" constraint validates that passwords stored in the database adhere to a specific length requirement, specifically 20 characters. This constraint enforces a minimum password length that meets security standards, providing protection against password-related security risks like brute force attacks or password guessing. In summary, the "chk_password" constraint ensures that passwords are of sufficient length to enhance security and mitigate potential risks.

- Constraint "fk_charity_id":
The "fk_charity_id" constraint is a foreign key constraint that establishes a relationship between the "CharityAccount" table and the "Charity" table. It ensures that the "charity_id" column in the "CharityAccount" table references valid "id" values in the "Charity" table, maintaining data integrity. This constraint prevents the insertion of invalid "charity_id" values, ensuring that only valid references to the "Charity" table are stored in the "CharityAccount" table. In summary, the "fk_charity_id" constraint enhances data integrity by enforcing the relationship between the two tables and ensuring the accuracy of data references.

### Optimizing Database Performance
To optimize database performance, we utilised indexing, caching, stored procedures, and query optimization techniques in postgreSQL. Indexing was used to speed up data retrieval by creating indexes on frequently accessed columns, such as donor IDs or transaction IDs. Caching mechanisms were implemented to store frequently used data in memory, reducing the need for expensive disk I/O operations. Query optimization techniques, such as analysing query execution plans and optimizing query performance, were also applied to improve the efficiency of database queries and reduce the overall response time of the platform.

### Security Measures
Appropriate security measures were implemented, such as encryption and access controls, to protect the data from unauthorized access. PostgreSQL's built-in security features, such as authentication mechanisms and user management, were also utilised to permit only authorized users access to the database and its functionalities.
