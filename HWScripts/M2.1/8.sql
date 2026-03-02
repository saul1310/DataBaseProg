
-- 8
SELECT vendor_name,vendor_contact_last_name,vendor_contact_first_name
FROM Vendors
ORDER BY vendor_contact_last_name;



-- 9
SELECT CONCAT(vendor_contact_first_name,',',' ',vendor_contact_last_name) as full_name
FROM vendors
WHERE vendor_contact_last_name LIKE 'a%' OR vendor_contact_last_name LIKE 'b%' OR vendor_contact_last_name LIKE 'c%' OR vendor_contact_last_name LIKE 'e%'
ORDER BY vendor_contact_last_name ASC;


-- 10
SELECT invoice_due_date         AS "Due Date",
       invoice_total            AS "Invoice Total",
       invoice_total * 0.10     AS "10%",
       invoice_total * 1.10     AS "Plus 10%"
FROM   Invoices
WHERE invoice_total >= 500
  AND invoice_total <= 1000
ORDER BY invoice_due_date DESC;

-- 11

SELECT invoice_number, invoice_total, payment_total + credit_total AS payment_credit_total, invoice_total - payment_total - credit_total AS balance_due
FROM invoices
WHERE invoice_total - payment_total - credit_total > 50
ORDER BY invoice_total - payment_total - credit_total DESC 
LIMIT 5;


-- 12

SELECT invoice_number,invoice_date,invoice_total - payment_total - credit_total,payment_date
FROM invoices 
WHERE payment_date is NULL;

-- 13
SELECT 
	-- Returns today's date in default YYYY-MM-DD format
    CURRENT_DATE,
    -- Reformats the date to mm-dd-yyyy
    DATE_FORMAT(CURRENT_DATE, '%m-%d-%Y') AS 'current_date';
    
-- 14
SELECT
  50000                    AS starting_principal,
  50000 * 0.065            AS interest,
  50000 + 50000 * 0.065    AS principal_plus_interest;



