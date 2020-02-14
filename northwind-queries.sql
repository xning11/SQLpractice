-- http://www.techsapphire.in/index/sql_complex_queries_query_optimization_and_interview_questions_sql_server_2016/0-190

USE Northwind; 

/*	List row number of products by categories	*/
SELECT CategoryName, ProductName, 
		COUNT(*) OVER (ORDER BY (SELECT 1)) AS 'total_count', 
		ROW_NUMBER() OVER (ORDER BY ProductID) AS 'row_number_all_cat',
		ROW_NUMBER() OVER (PARTITION BY CategoryID ORDER BY ProductID) AS 'row_number_each_cat',
        RANK() OVER (ORDER BY CategoryID) AS 'rank_cat', 
        DENSE_RANK() OVER (ORDER BY CategoryID) AS 'dense_rank_cat'
	FROM Categories JOIN Products USING(CategoryID); 


/*	Total sales per product	*/
SELECT p.ProductName, SUM(o.UnitPrice*o.Quantity) AS total_amount 
		FROM Order_Details o JOIN Products p USING(ProductID) GROUP BY 1 ORDER BY 2 DESC;


/*	Running totals - by products */ 
SELECT ProductName, total_amount, 
		SUM(total_amount) OVER (ORDER BY ProductName) AS 'running_total' 
	FROM (SELECT p.ProductName, SUM(o.UnitPrice*o.Quantity) AS total_amount 
			FROM Order_Details o JOIN Products p USING(ProductID) GROUP BY 1) tt;


/*	Running totals - by categories */ 
SELECT CategoryID, ProductName, total_amount, 
		SUM(total_amount) OVER (PARTITION BY CategoryID ORDER BY ProductName) AS 'running_total' 
	FROM (SELECT p.CategoryID, p.ProductName, SUM(o.UnitPrice*o.Quantity) AS total_amount 
			FROM Order_Details o JOIN Products p USING(ProductID) GROUP BY 1,2) tt
	JOIN Categories c USING(CategoryID); 


/*	Data in lag and lead	*/
WITH orderdates AS (
	SELECT CustomerID, CompanyName, OrderDate,
			LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS previous_order_date, 
			LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS next_order_date 
		FROM Orders JOIN Customers USING(CustomerID)
) SELECT *, 
			IFNULL(DATEDIFF(IFNULL(next_order_date,OrderDate), OrderDate),0) AS days_for_next_order,
			IFNULL(DATEDIFF(OrderDate, IFNULL(previous_order_date,OrderDate)),0) AS days_for_previous_order
		FROM orderdates ; 


/*	First_value and Last_Value */ 
SELECT CustomerID, CompanyName, 
		MIN(OrderDate) AS first_order_date, 
        MAX(OrderDate) AS last_order_date 
	FROM Orders JOIN Customers USING(CustomerID) GROUP BY CustomerID; 


SELECT CustomerID, CompanyName, OrderDate, 
       First_Value(OrderDate) OVER(PARTITION BY companyname ORDER BY (select 1)) first_order_date,
       Last_Value(OrderDate) OVER(PARTITION BY companyname ORDER BY (select 1)) last_order_date
	FROM orders JOIN Customers USING(CustomerID);


/* 	Customer groups based on purchase frequency */
CREATE OR REPLACE VIEW customer_groups AS 
WITH orderdates AS (
	SELECT CustomerID, CompanyName, OrderDate,
			LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS previous_order_date, 
			LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS next_order_date 
		FROM Orders JOIN Customers USING(CustomerID)
), 
days_next_order AS (
	SELECT CustomerID, CompanyName, OrderDate, next_order_date, previous_order_date, 
			IFNULL(DATEDIFF(IFNULL(next_order_date,OrderDate), OrderDate),0) AS days_for_next_order,
			IFNULL(DATEDIFF(OrderDate, IFNULL(previous_order_date,OrderDate)),0) AS days_for_previous_order
		FROM orderdates 
), 
customer_tag AS (
	SELECT CustomerID, CompanyName, 
			FLOOR(AVG(days_for_next_order)) AS avg_days_for_next_order,
			IF(AVG(days_for_next_order)<30,'1', IF(AVG(days_for_next_order)>=30 AND AVG(days_for_next_order)<90, '2',IF(AVG(days_for_next_order)>=90, '3', '4'))) AS tag 
        FROM days_next_order GROUP BY CustomerID, CompanyName
) SELECT CustomerID, CompanyName, avg_days_for_next_order,
		ELT(tag, 'Important','Recommended','Normal','Ignore') AS customer_group
	FROM customer_tag; 


SELECT * FROM customer_groups; 
SELECT customer_group, COUNT(*) AS num_customers FROM customer_groups GROUP BY 1 ORDER BY 1; 


-- SELECT IF(3 > 2, 'a', 'b');
-- SELECT ELT(3, 'hello', 'friend', 'boss');


-- DECLARE @var1 INT, @var2 INT, @var3 varchar(10), @var4 varchar(10) 
DELIMITER //
SET @var1=6;
SET @var2=8;
SET @var3='Best';
SET @var4='Friend';
SET @var5=Null;
SELECT @var1+@var2, CONCAT(@var3,' ',@var4), @var3+' '+@var4, CONCAT(@var3,' ',@var5), SIN(PI());
DELIMITER ; 


/*	Complex match join 	*/
SELECT * FROM Region;

-- With overlap
SELECT r1.RegionID AS from_RegionID, r1.RegionDescription AS from_RegionDescription, 
		r2.RegionID AS to_RegionID, r2.RegionDescription AS to_RegionDescription
FROM Region AS r1 
JOIN Region AS r2 
ON r1.RegionID <> r2.RegionID; 

-- No overlap 
SELECT r1.RegionID AS from_RegionID, r1.RegionDescription AS from_RegionDescription, 
		r2.RegionID AS to_RegionID, r2.RegionDescription AS to_RegionDescription
FROM Region AS r1 
CROSS JOIN Region AS r2
ON r1.RegionID < r2.RegionID; 


/* 
--Optimize Below Query
SELECT		* 
FROM		Student AS S
WHERE		DOB IN
			(
				SELECT		MAX(DOB)
				FROM		Student sp
				WHERE		YEAR(S.DOB) = YEAR(sp.DOB)
				GROUP BY	YEAR(sp.DOB)
			) 
ORDER BY	DOB

--Optimized Query
WITH CTE
AS
(
SELECT		YEAR(DOB) [Year],max(DOB) [DOB]
				FROM		Student sp
				GROUP BY YEAR(DOB)
)
SELECT		* 
FROM		Student AS S
join CTE ON		s.DOB =CTE.DOB
		