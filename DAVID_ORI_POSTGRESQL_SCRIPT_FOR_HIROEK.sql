-----------------------
-- Creating a Database
-----------------------

-- DROP DATABASE IF EXISTS "Hiroek";

CREATE DATABASE "Hiroek"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_United Kingdom.1252'
    LC_CTYPE = 'English_United Kingdom.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
	
-------------------------
--Importing the CSV files	
-------------------------
--Creating a table for CharityData for Scotland CSV

CREATE TABLE CharityDataScotland(
    registration_number VARCHAR(20) NULL,
    charity_name VARCHAR(255) NULL,
	postcode VARCHAR(20) NULL,
    website VARCHAR(255) NULL, 
	latitude DECIMAL(10,6) NULL,
    longitude DECIMAL(10,6) NULL,
	country VARCHAR(30) NULL,
	city VARCHAR(30) NULL,
	address TEXT NULL,
	logo_filename TEXT NULL,
    subcategory VARCHAR(2000)NULL,
	causes VARCHAR(2000) NULL		        
);

--Importing the CSV file for Scotland
COPY "charitydatascotland" FROM 'C:\Users\Dell\Documents\MY HERO\CSV\Scotland_f.csv' DELIMITER ',' CSV HEADER;

--Inspecting the table
SELECT * FROM "charitydatascotland"


--Creating a table for CharityData for Northern Ireland CSV

CREATE TABLE CharityDataNorthernIreland (
    registration_number VARCHAR(20) NULL,
    charity_name VARCHAR(255) NULL,
	address TEXT NULL,
	website VARCHAR(255) NULL, 
	email VARCHAR(100) NULL,
	phone VARCHAR(100) NULL,
	postcode VARCHAR(20) NULL, 
	city VARCHAR(30) NULL,
	country VARCHAR(30) NULL,
	latitude DECIMAL(10,6) NULL,
    longitude DECIMAL(10,6) NULL,
	logo_filename TEXT NULL,
	causes VARCHAR(2000) NULL,
	subcategory VARCHAR(2000)NULL
);

--Importing the CSV file for Northern Ireland
COPY "charitydatanorthernireland" FROM 'C:\Users\Dell\Documents\MY HERO\CSV\Northern_Ireland_f.csv' DELIMITER ',' CSV HEADER;

--Inspecting the table
SELECT *
FROM charitydatanorthernireland

--Creating a table for CharityData for England and Wales

CREATE TABLE CharityDataEnglandandWales (
    registration_number VARCHAR(20) NULL,
    charity_name VARCHAR(255) NULL,
	postcode VARCHAR(20) NULL,
	phone VARCHAR(100) NULL,
	email VARCHAR(100) NULL,
	website VARCHAR(255) NULL,
	latitude DECIMAL(10,6) NULL,
    longitude DECIMAL(10,6) NULL,
	address TEXT NULL,
	city VARCHAR(30) NULL,
	country VARCHAR(30) NULL,
	logo_filename TEXT NULL,
	causes VARCHAR(2000) NULL, 
	subcategory VARCHAR(2000)NULL
);

--Importing the CSV file for England and Wales
COPY "charitydataenglandandwales" FROM 'C:\Users\Dell\Documents\MY HERO\CSV\England_and_Wales_f.csv' DELIMITER ',' CSV HEADER;

--Inspecting the table
SELECT *
FROM charitydataenglandandwales

---------------------
--Creation of Tables
---------------------

--Creating a table for Users

CREATE TABLE Users (
    id SERIAL PRIMARY KEY,
    title VARCHAR(15) NOT NULL,
    firstname VARCHAR(30) NOT NULL,
    middlename VARCHAR(30),
    lastname VARCHAR(30) NOT NULL,
    birthdate DATE NOT NULL,
    gender CHAR(1) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password BYTEA NOT NULL,
    phone VARCHAR(30) NOT NULL, 
    user_contact_address1 VARCHAR(255) NOT NULL,
    user_contact_address2 VARCHAR(255),
    user_contact_address3 VARCHAR(255),
    user_contact_address4 VARCHAR(255),
    user_contact_address5 VARCHAR(255),
    postcode VARCHAR(20) NOT NULL,
    created_at TIMESTAMP,
    CONSTRAINT chk_email CHECK (email LIKE '%_@__%.__%'),
    CONSTRAINT chk_password CHECK (octet_length(password) = 20)
);

-------------------------
--CREATING AN AGE COLUMN
-------------------------

CREATE FUNCTION calculate_age(birthdate date)
  RETURNS integer
  IMMUTABLE
AS $$
  SELECT DATE_PART('year', CURRENT_DATE) - DATE_PART('year', $1);
$$ LANGUAGE SQL;

ALTER TABLE users ADD COLUMN age integer GENERATED ALWAYS AS (
  calculate_age(birthdate)
) STORED;



------------------------------------------------------
--Creating a trigger to set default password for users
------------------------------------------------------
CREATE OR REPLACE FUNCTION set_default_password()
RETURNS trigger AS $$
DECLARE
  random_password TEXT;
BEGIN
  random_password := substr(md5(random()::text), 0, 20);
  NEW.password := crypt(random_password, gen_salt('bf'));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_default_password_trigger
BEFORE INSERT ON users
FOR EACH ROW
WHEN (NEW.password IS NULL)
EXECUTE FUNCTION set_default_password();


--Creating a table for Admins

CREATE TABLE Admin (
	id SERIAL PRIMARY KEY,
	Users_id INT,
	created_at TIMESTAMP,
	FOREIGN KEY (Users_id) REFERENCES Users(id)
);

--Creating a table for Location

CREATE TABLE Location (
    id SERIAL PRIMARY KEY,
    country VARCHAR(30),
    city VARCHAR(30),
    address TEXT,
    postcode VARCHAR(20),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
	registration_number VARCHAR(20) NULL
);

--Creating a table for the Charities

CREATE TABLE Charity (
    id SERIAL PRIMARY KEY,
    charity_name VARCHAR(255),
    description TEXT,
    registration_number VARCHAR(20),
    website VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    logo_filename TEXT,
	location_id INT,
	causes VARCHAR(2000) NULL, 
	subcategory VARCHAR(2000)NULL
);

-- Creating a table for CharityAccount

CREATE TABLE CharityAccount (
  id SERIAL PRIMARY KEY,
  charity_id INT NOT NULL,
  username VARCHAR(255) UNIQUE NOT NULL,
  password BYTEA NOT NULL,
  FOREIGN KEY (charity_id) REFERENCES Charity(id),
  CONSTRAINT fk_charity_id FOREIGN KEY (charity_id) REFERENCES Charity(id),
  CONSTRAINT chk_password CHECK (octet_length(password) = 20)
);

---------------------------------------------------------------
--Creating a trigger to set default password for CharityAccount
---------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_default_password()
RETURNS trigger AS $$
DECLARE
  random_password TEXT;
BEGIN
  random_password := substr(md5(random()::text), 0, 20);
  NEW.password := crypt(random_password, gen_salt('bf'));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_default_password_trigger
BEFORE INSERT ON CharityAccount
FOR EACH ROW
WHEN (NEW.password IS NULL)
EXECUTE FUNCTION set_default_password();


--Creating a table for Causes

CREATE TABLE Cause (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

--Creating a table for Subcategory

CREATE TABLE Subcategory (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    cause_id INT,
    FOREIGN KEY (cause_id) REFERENCES Cause(id)
);

--Creating a table for CharityCause

CREATE TABLE CharityCause (
    charity_id INT,
    cause_id INT,
    subcategory_id INT,
    PRIMARY KEY (charity_id, cause_id, subcategory_id),
    FOREIGN KEY (charity_id) REFERENCES Charity(id),
    FOREIGN KEY (cause_id) REFERENCES Cause(id),
    FOREIGN KEY (subcategory_id) REFERENCES Subcategory(id)
);

--Creating a table for CharityLocation

CREATE TABLE CharityLocation (
    charity_id INT,
    location_id INT,
    PRIMARY KEY (charity_id, location_id),
    FOREIGN KEY (charity_id) REFERENCES Charity(id),
    FOREIGN KEY (location_id) REFERENCES Location(id)
);

--Creating a table for Donors

CREATE TABLE Donors (
    id SERIAL PRIMARY KEY,
    users_id INT,
    charity_id INT,
    donation_amount DECIMAL(10,2),
    donation_date TIMESTAMP,
    FOREIGN KEY (users_id) REFERENCES Users(id),
    FOREIGN KEY (charity_id) REFERENCES Charity(id)
);

--Creating a table for Donation

CREATE TABLE Donation(
	id SERIAL PRIMARY KEY,
	donor_id INT,
	payment_method VARCHAR(30),
	donation_status VARCHAR(30),
	FOREIGN KEY (donor_id) REFERENCES Donors(id)
);

--Creating a table for Donations_to_Charities

CREATE TABLE Donations_to_Charities(
	donation_to_charity_id SERIAL PRIMARY KEY,
	donation_id INT, 
	charity_id INT,
	FOREIGN KEY (charity_id) REFERENCES Charity(id)
);

--Creating a table for Event

CREATE TABLE Event (
    id SERIAL PRIMARY KEY,
    charity_id INT,
    name VARCHAR(255),
    description TEXT,
    location_id INT,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    FOREIGN KEY (charity_id) REFERENCES Charity(id),
    FOREIGN KEY (location_id) REFERENCES Location(id)

);

--Creating a table for EventAttendance

CREATE TABLE EventAttendance(
	users_id INT,
	event_id INT,
	PRIMARY KEY (users_id, event_id),
	FOREIGN KEY (event_id) REFERENCES Event(id),
	FOREIGN KEY (users_id) REFERENCES Users(id)
);

--Creating a table for Communities

CREATE TABLE Communities(
	community_id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	description TEXT
);

--Creating a table for Community_Members

 CREATE TABLE Community_Members(
	members_id SERIAL PRIMARY KEY,
	users_id INT,
	community_id INT,
	FOREIGN KEY (users_id) REFERENCES Users(id),
	FOREIGN KEY (community_id) REFERENCES Communities(community_id)
);


--Creating a table for Messages

CREATE TABLE Messages(
	message_id SERIAL PRIMARY KEY,
	sender_id INT,
	recipient_id INT,
	content TEXT,
	timestamp TIMESTAMP,
	FOREIGN KEY (sender_id) REFERENCES Users(id),
	FOREIGN KEY (recipient_id) REFERENCES Users(id)
);

-----------------------------------
--Inserting data into created table
-----------------------------------

-- Inserting the Scotland data into the charity and location tables

INSERT INTO charity (registration_number, charity_name, website, logo_filename,causes,subcategory)
SELECT registration_number, charity_name, website,logo_filename,causes,subcategory
FROM charitydatascotland;

INSERT INTO location (country, city, address, postcode,latitude,longitude,registration_number)
SELECT country, city, address, postcode,latitude, longitude,registration_number
FROM charitydatascotland;


-- Inserting the Northern Ireland data into the charity and location tables

INSERT INTO charity (registration_number, charity_name, website,email,phone,logo_filename,causes,subcategory)
SELECT registration_number, charity_name, website,email,phone,logo_filename,causes,subcategory
FROM charitydatanorthernireland;

INSERT INTO location (country, city, address, postcode,latitude, longitude,registration_number)
SELECT country, city, address, postcode,latitude, longitude,registration_number
FROM charitydatanorthernireland;

-- Insert the England and Wales data into the table for the Charities

INSERT INTO charity (registration_number, charity_name, website,email,phone,logo_filename,causes,subcategory)
SELECT registration_number, charity_name, website,email,phone,logo_filename,causes,subcategory
FROM charitydataenglandandwales;

INSERT INTO location (country, city, address, postcode,latitude, longitude,registration_number)
SELECT country, city, address, postcode,latitude, longitude,registration_number
FROM charitydataenglandandwales;


-------------------------------------------------------
--Update the location_id attribute in the charity table
-------------------------------------------------------
UPDATE charity
SET location_id = location.id
FROM location
WHERE charity.registration_number = location.registration_number;


--Inserting data into the charitylocation table

INSERT INTO charitylocation (charity_id, location_id)
SELECT charity.id, location_id
FROM charity;

-------------------------------------------------
--Inspecting the Cause and Subcategory attributes
-------------------------------------------------

-- Spliting the comma seperated causes into seperate rows and unnesting them

SELECT DISTINCT trim(unnest(string_to_array(causes, ','))) as cause
FROM charity
ORDER BY cause;

-- Spliting the comma seperated subcategories into seperate rows and unnesting them

SELECT DISTINCT trim(unnest(string_to_array(subcategory, ','))) as subcategory
FROM charity
ORDER BY subcategory;



--------------------------------------
--Insert the causes in the cause table
--------------------------------------

INSERT INTO Cause (name) VALUES 
('Disability'),
('Health'),
('Human Rights'),
('Religious'),
('Housing'),
('Community Development'),
('Arts & Culture'),
('Education & Training'),
('Animals'),
('Environment & Conservation'),
('Sport & Recreation'),
('Employment, Trades & Professions'),
('Armed & Ex-Services'),
('Overseas Aid'),
('Elderly Care & Aging'),
('Rescue Services'),
('Women''s Rights & Empowerment'),
('Children & Youth'),
('Philanthropy & Grant Making'),
('General Charitable Purposes'),
('Other Charitable Purposes'),
('Poverty');

--Inspecting the cause table
SELECT *
FROM cause

---------------------------------------
--Inserting data into the subcategories
---------------------------------------
--Disability
INSERT INTO Subcategory (name, cause_id) VALUES
('Education & Learning', (SELECT id FROM Cause WHERE name = 'Disability')),
('Employment', (SELECT id FROM Cause WHERE name = 'Disability')),
('Hearing Impairment', (SELECT id FROM Cause WHERE name = 'Disability')),
('Physical Disabilities', (SELECT id FROM Cause WHERE name = 'Disability')),
('Sensory Disabilities', (SELECT id FROM Cause WHERE name = 'Disability')),
('Holidays & Respite Care', (SELECT id FROM Cause WHERE name = 'Disability')),
('Independent Living', (SELECT id FROM Cause WHERE name = 'Disability')),
('Learning Disabilities', (SELECT id FROM Cause WHERE name = 'Disability')),
('Sports', (SELECT id FROM Cause WHERE name = 'Disability')),
('Supported Living', (SELECT id FROM Cause WHERE name = 'Disability')),
('Visual Impairments', (SELECT id FROM Cause WHERE name = 'Disability'));

--Health
INSERT INTO Subcategory (name, cause_id) 
VALUES 
  ('Cancer', (SELECT id FROM Cause WHERE name = 'Health')),
  ('Children’s Health', (SELECT id FROM Cause WHERE name = 'Health')),
  ('Disability', (SELECT id FROM Cause WHERE name = 'Health')),
  ('Heart Conditions', (SELECT id FROM Cause WHERE name = 'Health')),
  ('Medical Research', (SELECT id FROM Cause WHERE name = 'Health')),
  ('Mental Health', (SELECT id FROM Cause WHERE name = 'Health')),
  ('Specific Conditions', (SELECT id FROM Cause WHERE name = 'Health')),
  ('Stroke', (SELECT id FROM Cause WHERE name = 'Health')),
  ('Research/Evaluation', (SELECT id FROM Cause WHERE name = 'Health')),
  ('Addiction & Substance Abuse', (SELECT id FROM Cause WHERE name = 'Health')),
  ('Medical/Health/Sickness', (SELECT id FROM Cause WHERE name = 'Health')),
  ('Hiv/Aids', (SELECT id FROM Cause WHERE name = 'Health'));

--Human Rights

INSERT INTO Subcategory (name, cause_id) VALUES
('Abuse', (SELECT id FROM Cause WHERE name = 'Human Rights')),
('Counselling & Support', (SELECT id FROM Cause WHERE name = 'Human Rights')),
('Family', (SELECT id FROM Cause WHERE name = 'Human Rights')),
('Legal Advice', (SELECT id FROM Cause WHERE name = 'Human Rights')),
('Criminal Justice', (SELECT id FROM Cause WHERE name = 'Human Rights')),
('LGBTQ', (SELECT id FROM Cause WHERE name = 'Human Rights')),
('Sexual Orientation', (SELECT id FROM Cause WHERE name = 'Human Rights')),
('Minority Groups', (SELECT id FROM Cause WHERE name = 'Human Rights')),
('Ethnic Minorities', (SELECT id FROM Cause WHERE name = 'Human Rights')),
('Poverty', (SELECT id FROM Cause WHERE name = 'Human Rights')),
('Asylum seekers/Refugees', (SELECT id FROM Cause WHERE name = 'Human Rights')),
('Ex-offenders and Prisoners', (SELECT id FROM Cause WHERE name = 'Human Rights')),
('Rehabilitation', (SELECT id FROM Cause WHERE name = 'Human Rights')),
('Gender', (SELECT id FROM Cause WHERE name = 'Human Rights')),
('Victim Support', (SELECT id FROM Cause WHERE name = 'Human Rights')),
('Equality', (SELECT id FROM Cause WHERE name = 'Human Rights'));

--Religious

INSERT INTO Subcategory(name, cause_id)VALUES
('Buddhism', (SELECT id FROM Cause WHERE name = 'Religious')),
('Christian', (SELECT id FROM Cause WHERE name = 'Religious')),
('Hinduism', (SELECT id FROM Cause WHERE name = 'Religious')),
('Islam', (SELECT id FROM Cause WHERE name = 'Religious')),
('Judaism', (SELECT id FROM Cause WHERE name = 'Religious')),
('Sikhism', (SELECT id FROM Cause WHERE name = 'Religious')),
('Religious Activities', (SELECT id FROM Cause WHERE name = 'Religious'));

--Housing

INSERT INTO Subcategory(name, cause_id)VALUES
('Almshouses', (SELECT id FROM Cause WHERE name = 'Housing')),
('Elderly', (SELECT id FROM Cause WHERE name = 'Housing')),
('Homelessness', (SELECT id FROM Cause WHERE name = 'Housing')),
('Rehabilitation', (SELECT id FROM Cause WHERE name = 'Housing')),
('Shelters', (SELECT id FROM Cause WHERE name = 'Housing')),
('Tenants', (SELECT id FROM Cause WHERE name = 'Housing')),
('Social Welfare', (SELECT id FROM Cause WHERE name = 'Housing')),
('Supported Living', (SELECT id FROM Cause WHERE name = 'Housing'));


--Community Development
INSERT INTO Subcategory(name, cause_id)VALUES
('Counselling & Support', (SELECT id FROM Cause WHERE name = 'Community Development')),
('Education & Training', (SELECT id FROM Cause WHERE name = 'Community Development')),
('Homelessness', (SELECT id FROM Cause WHERE name = 'Community Development')),
('Local Community', (SELECT id FROM Cause WHERE name = 'Community Development')),
('Interface Communities', (SELECT id FROM Cause WHERE name = 'Community Development')),
('Supported Living', (SELECT id FROM Cause WHERE name = 'Community Development')),
('Community Transport', (SELECT id FROM Cause WHERE name = 'Community Development')),
('Community Safety', (SELECT id FROM Cause WHERE name = 'Community Development')),
('Community Enterprise', (SELECT id FROM Cause WHERE name = 'Community Development')),
('General Public', (SELECT id FROM Cause WHERE name = 'Community Development')),
('Cross-Border/Cross-Community', (SELECT id FROM Cause WHERE name = 'Community Development')),
('Rural Development', (SELECT id FROM Cause WHERE name = 'Community Development')),
('Urban Development', (SELECT id FROM Cause WHERE name = 'Community Development')),
('Economic Development', (SELECT id FROM Cause WHERE name = 'Community Development')),
('Volunteer Development', (SELECT id FROM Cause WHERE name = 'Community Development')),
('Voluntary and Community Sector', (SELECT id FROM Cause WHERE name = 'Community Development')),
('Language Community', (SELECT id FROM Cause WHERE name = 'Community Development'));


-- Arts & Culture 
INSERT INTO Subcategory(name, cause_id)VALUES
('Historic & Religious Buildings', (SELECT id FROM Cause WHERE name = 'Arts & Culture')),
('Heritage/Historical', (SELECT id FROM Cause WHERE name = 'Arts & Culture')),
('Museums', (SELECT id FROM Cause WHERE name = 'Arts & Culture')),
('The Arts', (SELECT id FROM Cause WHERE name = 'Arts & Culture')),
('Cultural', (SELECT id FROM Cause WHERE name = 'Arts & Culture')),
('Urban or Rural Conservation', (SELECT id FROM Cause WHERE name = 'Arts & Culture'));

--Education & Training

INSERT INTO Subcategory(name, cause_id)VALUES
('Academies & Further Education', (SELECT id FROM Cause WHERE name = 'Education & Training')),
('Apprenticeship & Vocational Training', (SELECT id FROM Cause WHERE name = 'Education & Training')),
('Higher Education', (SELECT id FROM Cause WHERE name = 'Education & Training')),
('Independent Schools', (SELECT id FROM Cause WHERE name = 'Education & Training')),
('Special Educational Needs', (SELECT id FROM Cause WHERE name = 'Education & Training')),
('Adult Training', (SELECT id FROM Cause WHERE name = 'Education & Training'));

--Animals

INSERT INTO Subcategory(name, cause_id)VALUES
('Animal Rescue, Centres & Homes', (SELECT id FROM Cause WHERE name = 'Animals')),
('Assistance Dogs', (SELECT id FROM Cause WHERE name = 'Animals')),
('Endangered Animals & Wildlife Conservation', (SELECT id FROM Cause WHERE name = 'Animals')),
('Pets', (SELECT id FROM Cause WHERE name = 'Animals')),
('Working Animals', (SELECT id FROM Cause WHERE name = 'Animals'));

--Environment & Conservation

INSERT INTO Subcategory(name, cause_id)VALUES
('Botanical Conservation', (SELECT id FROM Cause WHERE name = 'Environment & Conservation')),
('Climate Change', (SELECT id FROM Cause WHERE name = 'Environment & Conservation')),
('International', (SELECT id FROM Cause WHERE name = 'Environment & Conservation')),
('Wildlife Conservation', (SELECT id FROM Cause WHERE name = 'Environment & Conservation')),
('Sustainable Development', (SELECT id FROM Cause WHERE name = 'Environment & Conservation'));


--Sport & Recreation

INSERT INTO Subcategory(name, cause_id)VALUES
('Children', (SELECT id FROM Cause WHERE name = 'Sport & Recreation')),
('Clubs & Association for the Young', (SELECT id FROM Cause WHERE name = 'Sport & Recreation')),
('Disabled', (SELECT id FROM Cause WHERE name = 'Sport & Recreation')),
('Facilities & Equipment', (SELECT id FROM Cause WHERE name = 'Sport & Recreation')),
('Holidays & Respite Care', (SELECT id FROM Cause WHERE name = 'Sport & Recreation')),
('Scouts & Guides', (SELECT id FROM Cause WHERE name = 'Sport & Recreation'));

-- Employment, Trades & Professions

INSERT INTO Subcategory(name, cause_id)VALUES
('Apprenticeships', (SELECT id FROM Cause WHERE name = 'Employment, Trades & Professions')),
('Counselling & Support', (SELECT id FROM Cause WHERE name = 'Employment, Trades & Professions')),
('Disabled/Injured', (SELECT id FROM Cause WHERE name = 'Employment, Trades & Professions')),
('Employment', (SELECT id FROM Cause WHERE name = 'Employment, Trades & Professions')),
('Financial Support', (SELECT id FROM Cause WHERE name = 'Employment, Trades & Professions')),
('Professional/Trade Support Groups', (SELECT id FROM Cause WHERE name = 'Employment, Trades & Professions')),
('Retired', (SELECT id FROM Cause WHERE name = 'Employment, Trades & Professions'));

--Armed & Ex-Services

INSERT INTO Subcategory(name, cause_id)VALUES
('Army', (SELECT id FROM Cause WHERE name = 'Armed & Ex-Services')),
('Ex-Services', (SELECT id FROM Cause WHERE name = 'Armed & Ex-Services')),
('Navy/Merchant Navy', (SELECT id FROM Cause WHERE name = 'Armed & Ex-Services')),
('Royal Air Forces (RAF)', (SELECT id FROM Cause WHERE name = 'Armed & Ex-Services'));

-- Overseas Aid

INSERT INTO Subcategory(name, cause_id)VALUES
('Children Overseas', (SELECT id FROM Cause WHERE name = 'Overseas Aid')),
('Overseas Aid/Famine Relief', (SELECT id FROM Cause WHERE name = 'Overseas Aid')),
('Overseas/Developing Countries', (SELECT id FROM Cause WHERE name = 'Overseas Aid')),
('Development', (SELECT id FROM Cause WHERE name = 'Overseas Aid')),
('Disability', (SELECT id FROM Cause WHERE name = 'Overseas Aid')),
('Education', (SELECT id FROM Cause WHERE name = 'Overseas Aid')),
('Emergency Relief', (SELECT id FROM Cause WHERE name = 'Overseas Aid')),
('Health', (SELECT id FROM Cause WHERE name = 'Overseas Aid')),
('Social Welfare', (SELECT id FROM Cause WHERE name = 'Overseas Aid'));


--Elderly Care & Aging

INSERT INTO Subcategory(name, cause_id)VALUES
('Assisted Living for the Elderly', (SELECT id FROM Cause WHERE name = 'Elderly Care & Aging')),
('Elderly Care and Welfare', (SELECT id FROM Cause WHERE name = 'Elderly Care & Aging')),
('Illness in the Elderly', (SELECT id FROM Cause WHERE name = 'Elderly Care & Aging')),
('Independent Living', (SELECT id FROM Cause WHERE name = 'Elderly Care & Aging'));

--Rescue Services

INSERT INTO Subcategory(name, cause_id)VALUES
('Air Ambulances', (SELECT id FROM Cause WHERE name = 'Rescue Services')),
('International', (SELECT id FROM Cause WHERE name = 'Rescue Services')),
('Search & Rescue', (SELECT id FROM Cause WHERE name = 'Rescue Services'));


--Women's Rights & Empowerment

INSERT INTO Subcategory(name, cause_id)VALUES
('Women', (SELECT id FROM Cause WHERE name = 'Women''s Rights & Empowerment')),
('Economic Empowerment', (SELECT id FROM Cause WHERE name = 'Women''s Rights & Empowerment')),
('Education & Training', (SELECT id FROM Cause WHERE name = 'Women''s Rights & Empowerment')),
('Health & Wellness', (SELECT id FROM Cause WHERE name = 'Women''s Rights & Empowerment')),
('Legal Rights and Support', (SELECT id FROM Cause WHERE name = 'Women''s Rights & Empowerment')),
('Violence Prevention', (SELECT id FROM Cause WHERE name = 'Women''s Rights & Empowerment'));


-- Children & Youth

INSERT INTO Subcategory(name, cause_id)VALUES
('Playgroup/After Schools', (SELECT id FROM Cause WHERE name = 'Children & Youth')),
('Preschool (0-5 year Olds)', (SELECT id FROM Cause WHERE name = 'Children & Youth')),
('Children (5-13 year Olds)', (SELECT id FROM Cause WHERE name = 'Children & Youth')),
('Youth (14-25 year Olds)', (SELECT id FROM Cause WHERE name = 'Children & Youth')),
('Education & Training', (SELECT id FROM Cause WHERE name = 'Children & Youth')),
('Youth Development ', (SELECT id FROM Cause WHERE name = 'Children & Youth')),
('Health & Wellness', (SELECT id FROM Cause WHERE name = 'Children & Youth')),
('Child Welfare', (SELECT id FROM Cause WHERE name = 'Children & Youth')),
('Sports & Recreation', (SELECT id FROM Cause WHERE name = 'Children & Youth'));


-- Philanthropy & Grant Making

INSERT INTO Subcategory(name, cause_id)VALUES
('Grant Making', (SELECT id FROM Cause WHERE name = 'Philanthropy & Grant Making')),
('Grants to Individuals', (SELECT id FROM Cause WHERE name = 'Philanthropy & Grant Making')),
('Grants to Organisations', (SELECT id FROM Cause WHERE name = 'Philanthropy & Grant Making')),
('Provides Other Finance', (SELECT id FROM Cause WHERE name = 'Philanthropy & Grant Making'));

--General Charitable Purposes

INSERT INTO Subcategory(name, cause_id)VALUES
('Poverty', (SELECT id FROM Cause WHERE name = 'General Charitable Purposes')),
('Disaster Relief & Humanitarian Aid', (SELECT id FROM Cause WHERE name = 'General Charitable Purposes')),
('Environmental Protection', (SELECT id FROM Cause WHERE name = 'General Charitable Purposes')),
('Arts and Culture', (SELECT id FROM Cause WHERE name = 'General Charitable Purposes')),
('Animal Welfare', (SELECT id FROM Cause WHERE name = 'General Charitable Purposes')),
('Religious Activities', (SELECT id FROM Cause WHERE name = 'General Charitable Purposes')),
('Welfare/Benevolent', (SELECT id FROM Cause WHERE name = 'General Charitable Purposes'));


--Other Charitable Purposes

INSERT INTO Subcategory(name, cause_id)VALUES
('Medical Research & Treatment', (SELECT id FROM Cause WHERE name = 'Other Charitable Purposes')),
('International Development & Aid', (SELECT id FROM Cause WHERE name = 'Other Charitable Purposes')),
('Scientific Research & Innovation', (SELECT id FROM Cause WHERE name = 'Other Charitable Purposes')),
('Social Justice & Advocacy', (SELECT id FROM Cause WHERE name = 'Other Charitable Purposes')),
('LGBTQ+ Rights & Support', (SELECT id FROM Cause WHERE name = 'Other Charitable Purposes')),
('Disability ', (SELECT id FROM Cause WHERE name = 'Other Charitable Purposes')),
('Travellers', (SELECT id FROM Cause WHERE name = 'Other Charitable Purposes')),
('Volunteers', (SELECT id FROM Cause WHERE name = 'Other Charitable Purposes')),
('Men', (SELECT id FROM Cause WHERE name = 'Other Charitable Purposes')),
('Parents', (SELECT id FROM Cause WHERE name = 'Other Charitable Purposes')),
('Provides Services', (SELECT id FROM Cause WHERE name = 'Other Charitable Purposes')),
('Provides Human Resources', (SELECT id FROM Cause WHERE name = 'Other Charitable Purposes')),
('Acts As An Umbrella Or Resource Body', (SELECT id FROM Cause WHERE name = 'Other Charitable Purposes')),
('Other Charities Or Voluntary Bodies', (SELECT id FROM Cause WHERE name = 'Other Charitable Purposes'));

--Poverty
INSERT INTO Subcategory(name, cause_id)VALUES
('Specific Areas of Deprivation', (SELECT id FROM Cause WHERE name = 'Poverty'));

-----------------------------
--Inserting into charitycause
-----------------------------

INSERT INTO CharityCause (charity_id, cause_id, subcategory_id)
SELECT c.id, ca.id, sc.id
FROM charity c
JOIN (SELECT name, id FROM Cause) ca ON c.causes LIKE '%' || ca.name || '%'
JOIN (
  SELECT name, id, cause_id FROM Subcategory
) sc ON c.subcategory LIKE '%' || sc.name || '%'
   AND sc.cause_id = ca.id;


--Inspecting the charitycause table
SELECT *
FROM charitycause


-----------------------------------------------------------------------
--Removing the causes and subcategory attributes from the charity table
-----------------------------------------------------------------------

ALTER TABLE charity
DROP COLUMN causes;

ALTER TABLE charity
DROP COLUMN subcategory;

--------------------------------------------------------------------
--Removing the registration_number attribute form the location table
--------------------------------------------------------------------

ALTER TABLE location
DROP COLUMN registration_number;



------------------
--	Sample Queries
------------------

--Retrieve all charities that are associated with a particular cause:

SELECT * FROM charity
JOIN charitycause ON charity.id = charitycause.charity_id
WHERE charitycause.cause_id = 1;

--Retrieve all subcategories that are associated with a particular cause:

SELECT * FROM subcategory
JOIN cause ON subcategory.cause_id = cause.id
WHERE cause.id = 2;

--Retrieve all charities that are associated with a particular subcategory:

SELECT * FROM charity
JOIN charitycause ON charity.id = charitycause.charity_id
WHERE charitycause.subcategory_id = 9;

--Retrieve all charities that are associated with a particular location:

SELECT *
FROM charity
JOIN charitylocation ON charity.id = charitylocation.charity_id
JOIN location ON charitylocation.location_id = location.id
WHERE city='Liverpool';


--Retrieve all NHS charities

SELECT *
FROM charity
WHERE charity_name LIKE '%NHS%';

--Retrieving the countries 

SELECT COUNT(DISTINCT country) as num_countries, string_agg(DISTINCT country, ', ') as countries
FROM location;


--------------------------------
--Stored Procedures and Triggers
--------------------------------

--Get donation total

CREATE OR REPLACE FUNCTION get_donation_total(p_id INTEGER, p_type CHAR)
RETURNS DECIMAL AS $$
DECLARE
    total DECIMAL;
BEGIN
    IF p_type = 'donor' THEN
        SELECT COALESCE(SUM(donation_amount), 0) INTO total
        FROM donors
        WHERE id = p_id;
    ELSIF p_type = 'donor' THEN
        SELECT COALESCE(SUM(donation_amount), 0) INTO total
        FROM donors
        WHERE charity_id = p_id;
    ELSE
        RAISE EXCEPTION 'Invalid parameter value for p_type';
    END IF;
    
    RETURN total;
END;
$$
LANGUAGE plpgsql;

--Calling the get_donation_total stored procedure with the required parameters
SELECT get_donation_total(1, 'donor');

--Extract Donor Information

CREATE OR REPLACE FUNCTION get_donor_information(p_donor_id INTEGER, p_email VARCHAR)
RETURNS TABLE (donor_id INTEGER, user_id INTEGER, email VARCHAR, firstname VARCHAR, lastname VARCHAR, middlename VARCHAR)
AS $$
BEGIN
    RETURN QUERY
    SELECT d.id AS donor_id, u.id AS user_id, u.email, u.firstname, u.lastname, u.middlename
    FROM donors d
    JOIN users u ON d.id = u.id 
    WHERE d.id = p_donor_id OR u.email = p_email;
END;
$$
LANGUAGE plpgsql;

--Calling the get_donor_information stored procedure with the required parameters
SELECT * FROM get_donor_information(1, 'gbartolomieu0@amazonaws.com');



--Update Donor Information

CREATE OR REPLACE FUNCTION update_donor_information(
    p_donor_id INTEGER,
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_middle_name VARCHAR,
    p_email VARCHAR
)
RETURNS VOID
AS $$
BEGIN    
    -- Update donor information in the database
    UPDATE users
    SET firstname = p_first_name,
        lastname = p_last_name,
        middlename = p_middle_name,
        email = p_email
    WHERE id = p_donor_id;
      -- Raise a notice to indicate successful update
    RAISE NOTICE 'Donor information updated successfully for donor ID: %', p_donor_id;
END;
$$
LANGUAGE plpgsql;

-- Call the update_donor_information stored procedure with the required parameters
#SELECT update_donor_information(1, 'Keriann', 'Bartolomieu', 'Goldi', 'gbartolomieu0@amazonaws.com');

----------
--Triggers
----------

--Update Donor Information
CREATE OR REPLACE FUNCTION update_donor_total_donation()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE donors
    SET total_donation = total_donation + NEW.donation_amount
    WHERE id = NEW.donor_id;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trg_update_donor_total_donation
AFTER INSERT ON donors
FOR EACH ROW
EXECUTE FUNCTION update_donor_total_donation();

--Drop column in a table
ALTER TABLE donors DROP COLUMN total_donation_amount;

-- Step 1: Add the total_donation_amount field to the donors table
ALTER TABLE donors ADD COLUMN total_donation_amount INTEGER DEFAULT NULL;

select * from donors


--Donor Level Update

-- Step 1: Create a function to update donor level
CREATE OR REPLACE FUNCTION update_donor_level()
RETURNS TRIGGER
AS $$
BEGIN
    -- Define the threshold and corresponding donor levels
    -- You can customize the threshold and donor levels as needed
    DECLARE
        v_threshold INTEGER := 5000;
        v_bronze_level VARCHAR := 'Bronze';
        v_silver_level VARCHAR := 'Silver';
        v_gold_level VARCHAR := 'Gold';
    BEGIN
        -- Calculate the total donation amount for the donor
        SELECT SUM(donation_amount) INTO NEW.total_donation_amount
        FROM donors
        WHERE id = NEW.id;

        -- Update the donor level based on the total donation amount
        IF NEW.total_donation_amount >= v_threshold THEN
            IF NEW.total_donation_amount >= 10000 THEN
                NEW.donor_level := v_gold_level;
            ELSE
                NEW.donor_level := v_silver_level;
            END IF;
        ELSE
            NEW.donor_level := v_bronze_level;
        END IF;

        RETURN NEW;
    END;
END;
$$
LANGUAGE plpgsql;
-- Step 2: Create the trigger on the donors table
CREATE TRIGGER update_donor_level_trigger
AFTER INSERT OR UPDATE ON donors
FOR EACH ROW EXECUTE FUNCTION update_donor_level();




--Update Charity Profile
-- Step 1: Create a function to update charity profile
CREATE OR REPLACE FUNCTION update_charity_profile()
RETURNS TRIGGER
AS $$
BEGIN
    -- Update the total donation amount for the charity
    UPDATE charity
    SET total_donation_amount = total_donation_amount + NEW.amount
    WHERE id = NEW.charity_id;
    -- Update the donors for the charity
    INSERT INTO donors (charity_id, donation_amount, donation_date)
    VALUES (NEW.charity_id, NEW.amount, NOW());
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;
-- Step 2: Create the trigger on the donations_to_charities table
CREATE TRIGGER update_charity_profile_trigger
AFTER INSERT ON donations_to_charities
FOR EACH ROW EXECUTE FUNCTION update_charity_profile();


---------------------
--Importing Test Data
---------------------

CREATE TABLE Testdata (
	title VARCHAR(50),
	firstname VARCHAR(50),
	lastname VARCHAR(50), 
	email VARCHAR(50),
	gender CHAR(1),
	middlename VARCHAR(50),
	password BYTEA NOT NULL,
	user_contact_address1 VARCHAR(255) NOT NULL,
    user_contact_address2 VARCHAR(255),
    user_contact_address3 VARCHAR(255),
    user_contact_address4 VARCHAR(255),
    user_contact_address5 VARCHAR(255),
	postcode VARCHAR(50), 
	created_at TIMESTAMP,
	donation_amount MONEY,
	phone VARCHAR(50),
	donor_id INT,
	donation_id INT,
	user_id INT,
	location_id INT,
	donation_to_charity_id INT,
	charity_id INT,
	birthdate DATE,
	donation_date DATE,
	country VARCHAR(50)
);


--Importing the CSV file for Scotland
COPY "testdata" FROM 'C:\Users\Dell\Documents\MY HERO\CSV\Testdata.csv' DELIMITER ',' CSV HEADER;

--Inspecting the table
select * from testdata


--A number of adjustments were made to insert the test data into the database

--Dropping the Not null constraint
ALTER TABLE users 
  ALTER COLUMN user_contact_address2 DROP NOT NULL,
  ALTER COLUMN user_contact_address3 DROP NOT NULL,
  ALTER COLUMN user_contact_address4 DROP NOT NULL,
  ALTER COLUMN user_contact_address5 DROP NOT NULL;
  
--Adjusting the password constraint
ALTER TABLE users
DROP CONSTRAINT chk_password,
ADD CONSTRAINT chk_password CHECK (octet_length(password) BETWEEN 6 AND 12);

--Dropping the chk_email constraint
ALTER TABLE users
DROP CONSTRAINT chk_email;


--Iserting the test data into the requured tables

--Inserting the test data into the user table
INSERT INTO users (id, title, firstname, middlename, lastname, birthdate, gender, email, password, phone, user_contact_address1,user_contact_address2,user_contact_address3,user_contact_address4,user_contact_address5, postcode, created_at)
SELECT user_id, title, firstname, middlename, lastname, birthdate, gender, email, password, phone, user_contact_address1,user_contact_address2,user_contact_address3,user_contact_address4,user_contact_address5, postcode, created_at
FROM testdata;

--Inspecting the user table
select * from users

--Inserting the test data into the donors table
INSERT INTO donors (id, users_id, charity_id,donation_amount,donation_date)
SELECT donor_id, user_id, charity_id,donation_amount,donation_date
FROM testdata;

--Inserting the test data into the donors table
INSERT INTO donation (id, donor_id)
SELECT donation_id, donor_id
FROM testdata;

--Inserting the test data into the donation_to_charities table
INSERT INTO Donations_to_Charities (donation_to_charity_id, donation_id,charity_id)
SELECT donation_to_charity_id, donation_id,charity_id
FROM testdata;





















