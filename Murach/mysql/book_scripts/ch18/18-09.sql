ALTER USER john IDENTIFIED BY 'pa55word';

ALTER USER USER() IDENTIFIED BY 'secret';  -- careful, if you are logged in as the root user, this will change its password

ALTER USER IF EXISTS john PASSWORD EXPIRE INTERVAL 90 DAY;

SELECT Host, User
FROM mysql.user
WHERE authentication_string = '' AND password_expired = 'N';