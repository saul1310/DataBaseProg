-- drop the users 
DROP USER IF EXISTS john;
DROP USER IF EXISTS jane;
DROP USER IF EXISTS jim;
DROP USER IF EXISTS joel@localhost;

-- create the users
CREATE USER john PASSWORD EXPIRE;
CREATE USER jane PASSWORD EXPIRE;
CREATE USER jim PASSWORD EXPIRE;
CREATE USER joel@localhost PASSWORD EXPIRE;

-- grant privileges to the ap_developer (joel)
GRANT ALL ON *.* TO joel@localhost WITH GRANT OPTION;

-- grant privileges to the ap manager (jim)
GRANT SELECT, INSERT, UPDATE, DELETE ON ap.* TO jim WITH GRANT OPTION;

-- grant privileges to ap users (john, jane)
GRANT SELECT, INSERT, UPDATE, DELETE ON ap.vendors TO john, jane;
GRANT SELECT, INSERT, UPDATE, DELETE ON ap.invoices TO john, jane;
GRANT SELECT, INSERT, UPDATE, DELETE ON ap.invoice_line_items TO john, jane;
GRANT SELECT ON ap.general_ledger_accounts TO john, jane;
GRANT SELECT ON ap.terms TO john, jane;
