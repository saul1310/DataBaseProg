
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


SELECT invoice_number, invoice_total, payment_total + credit_total AS payment_credit_total, invoice_total - payment_total - credit_total AS balance_due
FROM invoices
WHERE invoice_total - payment_total - credit_total > 50
ORDER BY invoice_total - payment_total - credit_total DESC 
LIMIT 5;


-- 11

SELECT invoice_number,invoice_date,invoice_total - payment_total - credit_total,payment_date
FROM invoices 
WHERE payment_date is NULL


