-- Module 3, Exercises 2 & 3

USE ex;

-- Exercise 2
-- Drop tables if they already exist (child table first)
DROP TABLE IF EXISTS Members_Committees;
DROP TABLE IF EXISTS Members;
DROP TABLE IF EXISTS Committees;

CREATE TABLE Members
(
  member_id       INT            PRIMARY KEY       AUTO_INCREMENT,
  first_name      VARCHAR(55)    NOT NULL,
  last_name       VARCHAR(55)    NOT NULL,
  address         VARCHAR(128)   NOT NULL,
  city            VARCHAR(55)    NOT NULL,
  state           CHAR(2)        NOT NULL    DEFAULT 'CA',
  phone           VARCHAR(20)    DEFAULT NULL
);

CREATE TABLE Committees
(
  committee_id    INT            PRIMARY KEY       AUTO_INCREMENT,
  committee_name  VARCHAR(128)   NOT NULL
);

CREATE TABLE Members_Committees
(
  member_id       INT            NOT NULL,
  committee_id    INT            NOT NULL,
  CONSTRAINT members_committees_pk
    PRIMARY KEY (member_id, committee_id),
  CONSTRAINT members_committees_fk_members
    FOREIGN KEY (member_id)
    REFERENCES Members (member_id),
  CONSTRAINT members_committees_fk_committees
    FOREIGN KEY (committee_id)
    REFERENCES Committees (committee_id)
);

-- Exercise 3
-- Insert two rows into Members
INSERT INTO Members (member_id, first_name, last_name, address, city, state, phone)
VALUES
  (1, 'John', 'Smith', '123 Main St', 'Los Angeles', 'CA', '555-1234'),
  (2, 'Jane', 'Doe', '456 Oak Ave', 'San Diego', 'CA', '555-5678');

-- Insert two rows into Committees
INSERT INTO Committees (committee_id, committee_name)
VALUES
  (1, 'Budget'),
  (2, 'Membership');

-- Insert three rows into Members_Committees
-- Member 1 in Committee 2, Member 2 in Committee 1, Member 2 in Committee 2
INSERT INTO Members_Committees (member_id, committee_id)
VALUES
  (1, 2),
  (2, 1),
  (2, 2);

-- SELECT that joins all three tables
SELECT c.committee_name, m.last_name, m.first_name
FROM Members m
  JOIN Members_Committees mc
    ON m.member_id = mc.member_id
  JOIN Committees c
    ON mc.committee_id = c.committee_id
ORDER BY c.committee_name, m.last_name, m.first_name;

-- Exercise 4
-- Add two new columns to the Members table:
-- 1) annual_dues: holds dollar amounts up to 999.99 (3 digits left, 2 right of decimal)
--    defaults to 52.50 if no value is provided
-- 2) payment_date: stores the date the member last paid their dues
ALTER TABLE Members
  ADD annual_dues    DECIMAL(5,2)   DEFAULT 52.50,
  ADD payment_date   DATE;

-- Exercise 5
-- Add a UNIQUE constraint to committee_name so no two committees can have the same name
ALTER TABLE Committees
  ADD CONSTRAINT committees_name_uq UNIQUE (committee_name);

-- This INSERT should FAIL because 'Budget' already exists in the Committees table
-- and we just added a UNIQUE constraint on committee_name
INSERT INTO Committees (committee_name)
VALUES ('Budget');
