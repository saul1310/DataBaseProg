-- 1
SELECT *
FROM Vendors
INNER JOIN Invoices ON Vendors.vendor_id = Invoices.vendor_id;

-- 2
-- here we are joining the two tables using aliases, and linking vendors rto their invoices
-- then returning vendors with a non zero balance and sorting alphabetically by name
SELECT 

    v.vendor_name,
    i.invoice_number,
    i.invoice_date,
    (i.invoice_total - i.payment_total - i.credit_total) AS balance_due
FROM Vendors v
JOIN Invoices i ON v.vendor_id = i.vendor_id
WHERE (i.invoice_total - i.payment_total - i.credit_total) <> 0
ORDER BY v.vendor_name ASC;

-- 3
SELECT vendors.vendor_name, vendors.default_account_number, general_ledger_accounts.account_description 
FROM vendors 
JOIN general_ledger_accounts ON vendors.default_account_number =  general_ledger_accounts.account_number 
ORDER BY account_description, vendors.vendor_name;

-- 4
-- there are two join conditions here because we're connecting three tables:
-- This query joins three tables in a chain: Vendors to Invoices using vendor_id,
-- then Invoices to Invoice_Line_Items using invoice_id, returning one row per line item.
SELECT v.vendor_name, i.invoice_date, i.invoice_number, 
       li.invoice_sequence, li.line_item_amount
FROM vendors v
JOIN invoices i ON v.vendor_id = i.vendor_id
JOIN invoice_line_items li ON i.invoice_id = li.invoice_id
ORDER BY v.vendor_name, i.invoice_date, i.invoice_number, li.invoice_sequence;

-- 5
SELECT v1.vendor_id,v1.vendor_name, CONCAT(v1.vendor_contact_first_name,' ',v1.vendor_contact_last_name) AS contact_name
FROM vendors v1
JOIN vendors v2 ON v1.vendor_contact_last_name = v2.vendor_contact_last_name AND v1.vendor_name != v2.vendor_name
ORDER BY v1.vendor_contact_last_name;

-- 6
-- LEFT JOIN returns all rows from General_Ledger_Accounts, along with any matching 
-- rows from Invoice_Line_Items. 
-- If there's no match, the Invoice_Line_Items columns will be NULL.
-- WHERE ili.invoice_id IS NULL filters the result to only include accounts 
-- that have never been used in any invoice line item.
SELECT
    gla.account_number,
    gla.account_description
FROM General_Ledger_Accounts gla
LEFT JOIN Invoice_Line_Items ili
    ON gla.account_number = ili.account_number
WHERE ili.invoice_id IS NULL
ORDER BY gla.account_number;


-- 7
-- First SELECT retrieves vendors located in California, returning their actual vendor_state value of 'CA'.
-- Second SELECT retrieves all vendors not in California, replacing their vendor_state value with the literal string 'Outside CA'.
-- UNION combines both result sets, removing any duplicates

SELECT vendor_name, vendor_state
FROM Vendors
WHERE vendor_state = 'CA'

UNION

SELECT vendor_name, 'Outside CA' AS vendor_state
FROM Vendors
WHERE vendor_state <> 'CA'

ORDER BY vendor_name;



