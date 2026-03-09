USE AP;
-- -------------------------------------------------------
-- Exercise 1: Sum of invoice totals per vendor
-- -------------------------------------------------------

-- this is returning 35, even though the text says 34, but the vendor_id column in invoices that are not null is in fact 35.
SELECT vendor_id,
       SUM(invoice_total) AS total_invoiced
FROM Invoices
WHERE vendor_id IS NOT NULL
GROUP BY vendor_id;



-- -------------------------------------------------------
-- Exercise 2: Sum of payment totals per vendor (descending)
-- -------------------------------------------------------
SELECT v.vendor_name,
       SUM(i.payment_total) AS total_payments
FROM Vendors v
    JOIN Invoices i ON v.vendor_id = i.vendor_id
GROUP BY v.vendor_name
ORDER BY total_payments DESC;

-- -------------------------------------------------------
-- Exercise 3: Count and sum of invoices per vendor
-- -------------------------------------------------------
SELECT v.vendor_name,
       COUNT(i.invoice_id)  AS invoice_count,
       SUM(i.invoice_total) AS total_invoiced
FROM Vendors v
    JOIN Invoices i ON v.vendor_id = i.vendor_id
GROUP BY v.vendor_name
ORDER BY invoice_count DESC;

-- -------------------------------------------------------
-- Exercise 4: Count and sum of line items per GL account
-- only accounts with more than 1 line item
-- -------------------------------------------------------
SELECT g.account_description,
       COUNT(li.invoice_id)        AS line_item_count,
       SUM(li.line_item_amount)    AS total_amount
FROM General_Ledger_Accounts g
    JOIN Invoice_Line_Items li ON g.account_number = li.account_number
GROUP BY g.account_description
HAVING COUNT(li.invoice_id) > 1
ORDER BY total_amount DESC;

-- -------------------------------------------------------
-- Exercise 5: Same as exercise 4 but only Q2 2018 invoices
-- -------------------------------------------------------

-- however the dates requested in the textbook are wrong and this will return nothing
SELECT g.account_description,
       COUNT(li.invoice_id)        AS line_item_count,
       SUM(li.line_item_amount)    AS total_amount
FROM General_Ledger_Accounts g
    JOIN Invoice_Line_Items li ON g.account_number = li.account_number
    JOIN Invoices i            ON li.invoice_id    = i.invoice_id
WHERE i.invoice_date BETWEEN '2018-04-01' AND '2018-06-30'
GROUP BY g.account_description
HAVING COUNT(li.invoice_id) > 1
ORDER BY total_amount DESC;


-- these are the earliest and latest dates, which all exist after the date range requested in the textbook
SELECT MIN(invoice_date) AS earliest, 
       MAX(invoice_date) AS latest
FROM Invoices;

-- -------------------------------------------------------
-- Exercise 6: Total amount invoiced per GL account
-- with grand total using WITH ROLLUP
-- -------------------------------------------------------
SELECT account_number,
       SUM(line_item_amount) AS total_amount
FROM Invoice_Line_Items
GROUP BY account_number WITH ROLLUP;

-- -------------------------------------------------------
-- Exercise 7: Vendors paid from more than one account
-- -------------------------------------------------------
SELECT v.vendor_name,
       COUNT(DISTINCT li.account_number) AS account_count
FROM Vendors v
-- link invoices to their line items, which is where the account numbers live 
    JOIN Invoices i        ON v.vendor_id  = i.vendor_id
    JOIN Invoice_Line_Items li ON i.invoice_id = li.invoice_id
GROUP BY v.vendor_name
-- this line here seperates the ones we want
HAVING COUNT(DISTINCT li.account_number) > 1;

-- -------------------------------------------------------
-- Exercise 8: Last payment date and balance due
-- per vendor per terms_id, with rollup summaries
-- -------------------------------------------------------
SELECT 
-- IF() checks if this row is a rollup/summary row using GROUPING()
    IF(GROUPING(i.terms_id)  = 1, 'Grand Total',     i.terms_id)  AS terms_id,
	-- Same logic for vendor_id
    -- if vendor_id is a rollup row → show 'Terms Subtotal', otherwise show the actual vendor_id
    IF(GROUPING(i.vendor_id) = 1, 'Terms Subtotal',  i.vendor_id) AS vendor_id,
 -- MAX gets the most recent payment date for each vendor+terms combination
-- on subtotal/grand total rows this gives the most recent date across the whole group
 MAX(i.payment_date)                                            AS last_payment_date,
    -- Balance due = what's left to pay on each invoice
    -- invoice_total is the full amount
    -- subtract payment_total (what's been paid) and credit_total (any credits applied)
    -- SUM adds these up across all invoices in each group
    SUM(i.invoice_total - i.payment_total - i.credit_total)       AS total_balance_due
-- GROUP BY terms_id first, then vendor_id within each terms group
FROM Invoices i
-- WITH ROLLUP automatically adds those subtotal and grand total rows
GROUP BY i.terms_id, i.vendor_id WITH ROLLUP;