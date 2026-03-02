USE ap;

DROP FUNCTION IF EXISTS update_invoices_credit_total;

DELIMITER //

CREATE FUNCTION update_invoices_credit_total
(
   invoice_id_param INT
)
RETURNS DECIMAL
DETERMINISTIC
MODIFIES SQL DATA
BEGIN
  DECLARE credit_total_var DECIMAL;
  
  UPDATE invoices
  SET credit_total = invoice_total - payment_total
  WHERE invoice_id = invoice_id_param;
  
  SELECT credit_total INTO credit_total_var
  FROM invoices
  WHERE invoice_id = invoice_id_param;
  
  RETURN(credit_total_var);
END//

DELIMITER ;

SELECT invoice_number, invoice_total, payment_total, update_invoices_credit_total(102)
FROM invoices;