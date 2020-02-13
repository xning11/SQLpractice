-- 	https://www.media-division.com/using-mysql-generate-daily-sales-reports-filled-gaps/

USE sakila;

CREATE TABLE IF NOT EXISTS orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_date DATETIME,
    product_id INT,
    quantity INT,
    customer_id INT
);

INSERT INTO orders (order_date, product_id, quantity, customer_id) VALUES 
	('2009-08-15 12:20:20', '1', '2', '123'),
	('2009-08-15 12:20:20', '2', '2', '123'),
	('2009-08-17 16:43:09', '1', '1', '456'),
	('2009-08-18 09:21:43', '1', '5', '789'),
	('2009-08-18 14:23:11', '3', '7', '123'),
	('2009-08-21 08:34:21', '1', '1', '456'); 
    

-- SELECT * FROM orders; 

SELECT DATE(order_date) AS date, SUM(quantity) AS total_sales FROM orders GROUP BY 1; 


CREATE TABLE IF NOT EXISTS calendar (datefield DATE);

DELIMITER \\ 
CREATE PROCEDURE fill_calendar(start_date DATE, end_date DATE)
BEGIN 
	DECLARE crt_date DATE;
    SET crt_date = start_date;
    WHILE crt_date < end_date DO
		INSERT INTO calendar VALUES(crt_date);
        SET crt_date = ADDDATE(crt_date, INTERVAL 1 DAY);
	END WHILE;
END \\ 
DELIMITER ;

CALL fill_calendar('2009-08-01', '2009-08-31');

-- SELECT * FROM calendar; 


SELECT 
    c.datefield AS date, SUM(o.quantity) AS total_sales
FROM
    calendar c
        LEFT JOIN
    orders o ON DATE(o.order_date) = c.datefield
GROUP BY 1
ORDER BY 1; 
    

SELECT 
    calendar.datefield AS date,
    IFNULL(SUM(orders.quantity), 0) AS total_sales
FROM
    orders
        RIGHT JOIN
    calendar ON DATE(orders.order_date) = calendar.datefield
WHERE
    (calendar.datefield BETWEEN (SELECT 
            MIN(DATE(order_date))
        FROM
            orders) AND (SELECT 
            MAX(DATE(order_date))
        FROM
            orders))
GROUP BY 1; 


DROP TABLE orders, calendar; 
DROP PROCEDURE fill_calendar; 


