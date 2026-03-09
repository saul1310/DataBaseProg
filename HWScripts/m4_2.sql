-- -------------------------------------------------------
-- Exercise 1: Replace JOIN with subquery using IN
-- -------------------------------------------------------
SELECT DISTINCT vendor_name        -- DISTINCT removes duplicate vendor names
FROM Vendors                       -- outer query pulls from Vendors table
WHERE vendor_id IN                 -- check if this vendor's ID exists IN the list
    (SELECT vendor_id              -- inner query runs FIRST and returns a list
     FROM Invoices)                -- of every vendor_id that has at least one invoice
                                   -- e.g. returns (32, 34, 37, 48, 72...)
                                   -- outer query then only returns vendors whose
                                   -- vendor_id appears in that list
ORDER BY vendor_name;

-- -------------------------------------------------------
-- Exercise 2: Invoices with payment total greater than
-- the average payment total (for invoices with payment > 0)
-- -------------------------------------------------------
SELECT invoice_number,
       invoice_total
FROM Invoices
WHERE payment_total >              -- compare each invoice's payment_total against...
    (SELECT AVG(payment_total)     -- ...the average payment total (inner query runs first
     FROM Invoices                 -- and returns ONE number, e.g. 1500.00)
     WHERE payment_total > 0)      -- only include invoices with actual payments
                                   -- when calculating the average (excludes $0 payments)
                                   -- outer query then returns invoices above that average
ORDER BY invoice_total DESC;

-- -------------------------------------------------------
-- Exercise 3: GL accounts never assigned to any line item
-- using NOT EXISTS
-- -------------------------------------------------------
SELECT account_number,
       account_description
FROM General_Ledger_Accounts g     -- alias 'g' so we can reference it in subquery
WHERE NOT EXISTS                   -- only return rows where the subquery finds NOTHING
    (SELECT 1                      -- SELECT 1 just means "find any matching row"
     FROM Invoice_Line_Items li    -- we don't care what data comes back
     WHERE li.account_number       -- just whether ANY line item uses this account number
         = g.account_number)       -- g.account_number ties back to the outer query
                                   -- making this a CORRELATED subquery
                                   -- for each GL account, MySQL asks:
                                   -- "does any line item use this account?"
                                   -- NOT EXISTS = only keep accounts where answer is NO
ORDER BY account_number;

-- -------------------------------------------------------
-- Exercise 4: Line items from invoices with more than
-- one line item
-- -------------------------------------------------------
SELECT v.vendor_name,
       li.invoice_id,
       li.invoice_sequence,        -- sequence number tells us the order of line items
       li.line_item_amount         -- e.g. sequence 1 = first item, sequence 2 = second item
FROM Invoice_Line_Items li
    JOIN Invoices i ON li.invoice_id = i.invoice_id   -- join to get vendor info
    JOIN Vendors  v ON i.vendor_id   = v.vendor_id    -- chain join to get vendor name
WHERE li.invoice_id IN             -- only return line items whose invoice_id appears IN...
    (SELECT invoice_id             -- ...this list of invoice IDs that have MORE than
     FROM Invoice_Line_Items       -- one line item
     WHERE invoice_sequence > 1)  -- if sequence > 1 exists, the invoice has multiple items
                                   -- e.g. returns invoice IDs (1, 5, 12...)
                                   -- outer query then returns ALL line items for those invoices
ORDER BY v.vendor_name, li.invoice_id, li.invoice_sequence;

-- -------------------------------------------------------
-- Exercise 5a: Largest unpaid invoice per vendor
-- -------------------------------------------------------
SELECT vendor_id,
       MAX(invoice_total             -- MAX finds the largest value in the group
           - payment_total           -- balance due = invoice total
           - credit_total)           -- minus payments and credits already applied
           AS largest_unpaid
FROM Invoices
WHERE (invoice_total                 -- filter to only unpaid invoices
       - payment_total               -- balance due must be greater than 0
       - credit_total) > 0           -- this excludes fully paid invoices
GROUP BY vendor_id;                  -- calculate the MAX separately for each vendor
                                     -- returns one row per vendor with their largest unpaid

-- -------------------------------------------------------
-- Exercise 5b: Sum of all largest unpaid invoices
-- uses 5a as a subquery in the FROM clause
-- -------------------------------------------------------
SELECT SUM(largest_unpaid)           -- sum up the largest_unpaid column
       AS total_largest_unpaid       -- from the temporary table below
FROM
    (SELECT vendor_id,               -- this is the SAME query as 5a
            MAX(invoice_total
                - payment_total
                - credit_total) AS largest_unpaid
     FROM Invoices
     WHERE (invoice_total
            - payment_total
            - credit_total) > 0
     GROUP BY vendor_id) AS largest_unpaid_per_vendor;
                        -- ^^^^^^^^^^^^^^^^^^^^^^^^
                        -- subqueries in FROM MUST have an alias
                        -- MySQL treats this result as a temporary table
                        -- the outer query then SUMs the largest_unpaid column
                        -- from that temporary table

-- -------------------------------------------------------
-- Exercise 6: Vendors in a unique city and state
-- -------------------------------------------------------
SELECT vendor_name,
       vendor_city,
       vendor_state
FROM Vendors
WHERE (vendor_city, vendor_state) IN   -- check if this city+state COMBINATION
                                       -- appears in the list below
                                       -- note: checking TWO columns together
    (SELECT vendor_city, vendor_state  -- inner query returns city+state combinations
     FROM Vendors
     GROUP BY vendor_city, vendor_state  -- group by the combination
     HAVING COUNT(*) = 1)               -- only keep combinations that appear ONCE
                                        -- meaning no other vendor shares that city+state
ORDER BY vendor_state, vendor_city;

-- -------------------------------------------------------
-- Exercise 7: Oldest invoice per vendor
-- using a correlated subquery
-- -------------------------------------------------------
SELECT v.vendor_name,
       i.invoice_number,
       i.invoice_date,
       i.invoice_total
FROM Invoices i                        -- alias 'i' so subquery can reference it
    JOIN Vendors v ON i.vendor_id = v.vendor_id
WHERE i.invoice_date =                 -- only keep invoices where the date equals...
    (SELECT MIN(invoice_date)          -- ...the earliest invoice date...
     FROM Invoices                     -- ...found in the Invoices table...
     WHERE vendor_id = i.vendor_id)    -- ...for THIS specific vendor (ties to outer query)
                                       -- this is a CORRELATED subquery because it
                                       -- references i.vendor_id from the outer query
                                       -- it runs ONCE PER VENDOR, each time finding
                                       -- the MIN date for that specific vendor
                                       -- outer query then only returns the invoice
                                       -- that matches that earliest date
ORDER BY v.vendor_name;