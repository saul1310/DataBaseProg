USE ap;

DROP PROCEDURE IF EXISTS update_invoices_credit_total;

DELIMITER //

CREATE PROCEDURE update_invoices_credit_total
(
  invoice_id_param      INT,
  credit_total_param    DECIMAL(9,2) 
)
BEGIN
  DECLARE sql_error BOOL DEFAULT FALSE;
  
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    SET sql_error = TRUE;

  START TRANSACTION;  

  UPDATE invoices
  SET credit_total = credit_total_param
  WHERE invoice_id = invoice_id_param;

  IF sql_error = FALSE THEN
    COMMIT;
  ELSE
    ROLLBACK;
  END IF;
END//

DELIMITER ;

-- Use the CALL statement
CALL update_invoices_credit_total(56, 200);

-- View the result of the CALL statement
SELECT invoice_id, credit_total 
FROM invoices WHERE invoice_id = 56;

-- Reset data to original value
CALL update_invoices_credit_total(56, 0);