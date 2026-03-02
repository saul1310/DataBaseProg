SELECT vendor_name, invoice_number, invoice_date, invoice_total
FROM vendors v JOIN invoices i
	ON v.vendor_id = i.vendor_id;