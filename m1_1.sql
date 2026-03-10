-- 7

SELECT vendor_name FROM vendors;
-- 9
SELECT COUNT(*) AS number_of_invoices,
	SUM(invoice_total) AS grand_invoice_total
FROM invoices

