SET autocommit = 0;
-- 1
INSERT INTO Terms (terms_id, terms_description, terms_due_days)
VALUES (6, 'Net due 120 days', 120);

-- 2

UPDATE terms
SET terms_description = 'Net due 125 days',
    terms_due_days = 125
WHERE terms_id = 6;

-- 3
DELETE FROM terms
WHERE terms_id = 6;


-- 4
-- DEFAULT – lets the database auto-generate the next invoice ID
INSERT INTO Invoices
VALUES (DEFAULT, 32, 'AX-014-027', '2018-08-01', 434.58, 0.00, 0.00, 2, '2018-08-31', NULL);

-- 5
-- LAST_INSERT_ID() retrieves the auto-generated invoice_id from the Invoices insert in exercise 4
INSERT INTO Invoice_Line_Items (invoice_id, invoice_sequence, account_number, line_item_amount, line_item_description)
VALUES
  (LAST_INSERT_ID(), 1, 160, 180.23, 'Hard drive'),
  (LAST_INSERT_ID(), 2, 527, 254.35, 'Exchange Server update');
  
-- 6 
UPDATE Invoices
SET credit_total = invoice_total * 0.10,
    payment_total = invoice_total - (invoice_total * 0.10)
WHERE invoice_id = LAST_INSERT_ID();

-- 7 
UPDATE Vendors
SET default_account_number = 403
WHERE vendor_id = 44;

-- 8
-- example of a subquery
UPDATE Invoices
SET terms_id = 2
WHERE vendor_id IN
  (SELECT vendor_id
   FROM Vendors
   WHERE default_terms_id = 2);

-- 9
-- First, delete the related line items
DELETE FROM Invoice_Line_Items
WHERE invoice_id = LAST_INSERT_ID();

-- Then, delete the invoice
DELETE FROM Invoices
WHERE invoice_id = LAST_INSERT_ID();
