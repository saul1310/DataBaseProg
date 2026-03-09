-- Module 3, Exercise 1
-- Add an index to the AP database for the zip code field in the Vendors table

USE ap;

CREATE INDEX ix_vendor_zip_code
  ON Vendors (vendor_zip_code);
