ALTER TABLE vendors
ADD last_transaction_date DATE;

ALTER TABLE vendors
DROP COLUMN last_transaction_date;

ALTER TABLE vendors
MODIFY vendor_name VARCHAR(100) NOT NULL;

ALTER TABLE vendors
MODIFY vendor_name CHAR(100) NOT NULL;

ALTER TABLE vendors
MODIFY vendor_name VARCHAR(100) NOT NULL DEFAULT 'New Vendor';

ALTER TABLE vendors
RENAME COLUMN vendor_name TO v_name;