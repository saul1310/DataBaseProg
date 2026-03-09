-- -------------------------------------------------------
-- Exercise 1: Add index to AP database
-- -------------------------------------------------------
USE AP;
CREATE INDEX ix_vendors_zip_code
ON Vendors (vendor_zip_code);

-- -------------------------------------------------------
-- Exercise 2: Create tables in EX database
-- -------------------------------------------------------
USE ex;

DROP TABLE IF EXISTS members_committees;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS committees;

CREATE TABLE members (
    member_id   INT             NOT NULL    AUTO_INCREMENT,
    first_name  VARCHAR(100)    NOT NULL,
    last_name   VARCHAR(100)    NOT NULL,
    address     VARCHAR(200),
    city        VARCHAR(100),
    state       CHAR(2),
    phone       VARCHAR(20),
    PRIMARY KEY (member_id)
);

CREATE TABLE committees (
    committee_id    INT             NOT NULL    AUTO_INCREMENT,
    committee_name  VARCHAR(100)    NOT NULL,
    PRIMARY KEY (committee_id)
);

CREATE TABLE members_committees (
    member_id       INT     NOT NULL,
    committee_id    INT     NOT NULL,
    PRIMARY KEY (member_id, committee_id),
    CONSTRAINT fk_mc_member
        FOREIGN KEY (member_id)
        REFERENCES members (member_id),
    CONSTRAINT fk_mc_committee
        FOREIGN KEY (committee_id)
        REFERENCES committees (committee_id)
);

-- -------------------------------------------------------
-- Exercise 3: Insert data and SELECT
-- -------------------------------------------------------
INSERT INTO members (first_name, last_name, address, city, state, phone)
VALUES
    ('John', 'Smith', '123 Main St', 'Los Angeles', 'CA', '555-111-2222'),
    ('Jane', 'Doe',   '456 Oak Ave', 'San Diego',   'CA', '555-333-4444');

INSERT INTO committees (committee_name)
VALUES
    ('Finance'),
    ('Marketing');

INSERT INTO members_committees (member_id, committee_id)
VALUES
    (1, 2),
    (2, 1),
    (2, 2);

SELECT 
    c.committee_name,
    m.last_name,
    m.first_name
FROM members_committees mc
    JOIN members    m ON mc.member_id    = m.member_id
    JOIN committees c ON mc.committee_id = c.committee_id
ORDER BY
    c.committee_name,
    m.last_name,
    m.first_name;
    
 -- Exercise 4                                                                 
  -- Add two new columns to the Members table:
  -- 1) annual_dues: holds dollar amounts up to 999.99 (3 digits left, 2 right
--   of decimal)
  --    defaults to 52.50 if no value is provided
  -- 2) payment_date: stores the date the member last paid their dues
  ALTER TABLE Members
    ADD annual_dues    DECIMAL(5,2)   DEFAULT 52.50,
    ADD payment_date   DATE;

  -- Exercise 5
  -- Add a UNIQUE constraint to committee_name so no two committees can have the
--    same name
  ALTER TABLE Committees
    ADD CONSTRAINT committees_name_uq UNIQUE (committee_name);

  -- This INSERT should FAIL because 'Budget' already exists in the Committees
--   table
  -- and we just added a UNIQUE constraint on committee_name
  INSERT INTO Committees (committee_name)
  VALUES ('Budget');
