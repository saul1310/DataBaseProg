USE ap;

DROP PROCEDURE IF EXISTS select_invoices;

DELIMITER //

CREATE PROCEDURE select_invoices
(
  min_date_param   DATE,
  min_total_param  DECIMAL(9,2)
)
BEGIN
  PREPARE statement FROM 
	'SELECT invoice_id, invoice_number, invoice_date, invoice_total 
	 FROM invoices 
     WHERE invoice_date > ? AND invoice_total > ?';

  SET @date = min_date_param;
  SET @total = min_total_param;

  EXECUTE statement USING @date, @total;
  
  DEALLOCATE PREPARE statement;  
END//

DELIMITER ;

CALL select_invoices('2022-07-25', 100);
