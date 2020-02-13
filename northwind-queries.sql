-- http://www.techsapphire.in/index/sql_complex_queries_query_optimization_and_interview_questions_sql_server_2016/0-190

USE Northwind; 
SHOW TABLES; 


/*	List row number of products in categories	*/
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


/*	Running totals - Aggregation with Over Operator	*/ 
SELECT ProductName, total_amount, 
		SUM(total_amount) OVER (ORDER BY ProductName) AS 'running_total' 
	FROM (
		SELECT p.ProductName, SUM(o.UnitPrice*o.Quantity) AS total_amount 
		FROM Order_Details o JOIN Products p USING(ProductID) GROUP BY 1) tt;



SELECT cat.CategoryName,
       productname,
       TotalAmout,
       sum([TotalAmout]) over(PARTITION BY cat.categoryid
                              ORDER BY productname) AS RunningTotal
FROM
  (SELECT prod.CategoryID,
          prod.ProductName,
          sum(ord.Quantity*ord.UnitPrice) [TotalAmout]
   FROM [Order Details] ord
   INNER JOIN Products prod ON ord.ProductID=prod.ProductID
   GROUP BY prod.ProductName,
            prod.CategoryID) t
INNER JOIN Categories cat ON t.CategoryID=cat.CategoryID

--Lead and Lag
SELECT cust.CustomerID,
       cust.CompanyName,
       ord.OrderDate,
       LEAD(ord.OrderDate) over(PARTITION BY cust.companyname
                                ORDER BY ord.orderdate) [NextOrderDate],
       LAG(ord.OrderDate) over(PARTITION BY cust.companyname
                                ORDER BY ord.orderdate) [PreviousOrderDate]
FROM orders ord
INNER JOIN Customers cust ON ord.CustomerID=cust.CustomerID 

WITH CTE AS
  (SELECT cust.CustomerID,
          cust.CompanyName,
          ord.OrderDate,
          LEAD(ord.OrderDate) over(PARTITION BY cust.companyname
                                   ORDER BY ord.orderdate) [NextOrderDate],
                              LAG(ord.OrderDate) over(PARTITION BY cust.companyname
                                                      ORDER BY ord.orderdate) [PreviousOrderDate]
   FROM orders ord
   INNER JOIN Customers cust ON ord.CustomerID=cust.CustomerID)
SELECT CustomerID,
       CompanyName,
       ISNULL(DATEDIFF(dd,OrderDate,isnull(NextOrderDate,OrderDate)),0) [NextDateDifference],
	   ISNULL(DATEDIFF(dd,isnull(PreviousOrderDate,OrderDate),OrderDate),0) [PreviousDateDifference],
       OrderDate,
       NextOrderDate,
	   PreviousOrderDate
FROM CTE
 --select DATEDIFF(dd,'1997-08-25 00:00:00.000','1997-10-03 00:00:00.000')

 --Paging
DECLARE @PageNumber int=3 DECLARE @PageSize int=10 DECLARE @StartPage int,@EndPage int
SET @StartPage=@PageNumber*@PageSize-@PageSize+1
SET @EndPage=@PageNumber*@PageSize

SELECT *
FROM
  (SELECT ROW_NUMBER() Over(ORDER BY ord.orderid) AS RowNum,*
   FROM orders ord) t
WHERE t.RowNum BETWEEN @StartPage AND @EndPage

SELECT @StartPage,@EndPage


DECLARE @PageNumber int=3 DECLARE @PageSize int=10 DECLARE @StartPage int,@EndPage int
SET @StartPage=@PageNumber*@PageSize-@PageSize+1
SET @EndPage=@PageNumber*@PageSize

SELECT *
FROM
  (SELECT ROW_NUMBER() Over(ORDER BY(SELECT 1)) AS RowNum,*
   FROM orders ord) t
WHERE t.RowNum BETWEEN @StartPage AND @EndPage

SELECT *
   FROM orders ord
 ORDER BY ord.orderid
OFFSET 20 ROWS
FETCH NEXT 10 ROWS ONLY

DECLARE @PageNumber int=3 DECLARE @PageSize int=10 DECLARE @StartPage int,@EndPage int
SET @StartPage=@PageNumber*@PageSize-@PageSize+1
SET @EndPage=@PageNumber*@PageSize
SELECT *
   FROM orders ord
 ORDER BY ord.orderid
OFFSET @PageNumber*@PageSize-@PageSize ROWS
FETCH NEXT @PageNumber*@PageSize ROWS ONLY


--First_value and Last_Value
SELECT cust.CustomerID,
       cust.CompanyName,
       ord.OrderDate,
       First_Value(ord.OrderDate) over(PARTITION BY cust.companyname
                                ORDER BY (select 1)) [FirstOrderDate],
       Last_Value(ord.OrderDate) over(PARTITION BY cust.companyname
                                ORDER BY (select 1)) [LastOrderDate]
FROM orders ord
INNER JOIN Customers cust ON ord.CustomerID=cust.CustomerID 


WITH CTE AS
  (SELECT cust.CustomerID,
          cust.CompanyName,
          ord.OrderDate,
          LEAD(ord.OrderDate) over(PARTITION BY cust.companyname
                                   ORDER BY ord.orderdate) [NextOrderDate],
                              LAG(ord.OrderDate) over(PARTITION BY cust.companyname
                                                      ORDER BY ord.orderdate) [PreviousOrderDate]
   FROM orders ord
   INNER JOIN Customers cust ON ord.CustomerID=cust.CustomerID)
,
CTE2
AS(
SELECT CustomerID,CompanyName,AVG(NextDateDifference) [AvgDiff] 
,IIF(AVG(NextDateDifference)<30,'1',IIF(AVG(NextDateDifference)>=30 and AVG(NextDateDifference)<90,'2',
IIF(AVG(NextDateDifference)>=90,'3','4'))) AS [Tag]
 FROM (SELECT CustomerID,
       CompanyName,
       ISNULL(DATEDIFF(dd,OrderDate,isnull(NextOrderDate,OrderDate)),0) [NextDateDifference],
	   ISNULL(DATEDIFF(dd,isnull(PreviousOrderDate,OrderDate),OrderDate),0) [PreviousDateDifference],
       OrderDate,
       NextOrderDate,
	   PreviousOrderDate FROM CTE) t
GROUP BY CustomerID,CompanyName
) 
SELECT customerid,CompanyName,AvgDiff,
CHOOSE([Tag],'Important','Recommended','Normal','Ignore') [Flag]
 from CTE2


 select iif(1=2,'a','b')
 select choose(3,'hello','friend','ghost')
 declare @var1 varchar(10),@var2 varchar(10)
 set @var1='Best'
 set @var2=null
 select @var1 + ' ' + @var2,concat(@var1,' ',@var2)


 --Complex Match Join
 SELECT * INTO #CITY FROM 
(
SELECT 1 AS ID,'ind'  CITY
UNION ALL
SELECT 2 AS ID,'aus'  CITY
UNION ALL
SELECT 3 AS ID,'sri'  CITY
UNION ALL
SELECT 4 AS ID,'Eng'  CITY
)VW

select * from #CITY

SELECT c.id fromid,c.city fromcity,c1.id toid,c1.city tocity
INTO #team
FROM #CITY c
INNER JOIN #CITY c1 ON c.id <> c1.id

select * from #team

SELECT c.* FROM #team c
INNER JOIN #team c1 ON c.fromid = c1.toid AND c.toid = c1.fromid AND c1.fromid <=c1.toid
ORDER BY c.tocity

drop table #CITY
drop table #team

--Second Highest Salary
declare @n int;
set @n=2;
Select e1.*
from Employee e1 where (@n-1)=(Select COUNT(distinct salary) from Employee e2 where e2.Salary>e1.Salary);

--Second Highest Salary Department Wise
;WITH DepartmentWiseSalary AS
(
	SELECT	*,DENSE_RANK() OVER(PARTITION BY Department ORDER BY Salary DESC) AS RowNum
	FROM	Employee
)
SELECT	* 
FROM	DepartmentWiseSalary
WHERE	RowNum = 2;

--Getting All Level Child
;WITH cteEmployee (EmpId, FirstName, LastName, ManagerID, Level)
AS
(
    SELECT	EmpId, FirstName, LastName, ManagerID, 0 AS Level
    FROM	Employee 
    WHERE	ManagerID = 2
    
    UNION ALL
    
    SELECT	e.EmpId, e.FirstName, e.LastName, e.ManagerID, Level + 1
    FROM	Employee e
			INNER JOIN cteEmployee AS d ON e.ManagerID = d.EmpId
)
SELECT	EmpId, FirstName, LastName, ManagerID,Level
FROM	cteEmployee;


--Finding Duplicates Record
WITH CTE
AS
(
SELECT ROW_NUMBER() OVER(ORDER BY (Select 1)) [RowNum],* FROM EMPLOYEE
)
SELECT * FROM CTE c1
WHERE
1<(SELECT count(c2.RowNum) FROM CTE c2 WHERE c1.EmpId=c2.EmpId)


--PIVOT Count of employee joining as per YEAR
SELECT	*
FROM	
		(
		  SELECT	Department,
					YEAR(DOJ) AS [Year],
					COUNT(EmpId) AS [EmployeeCount]
		  FROM		Employee
		  GROUP BY	Department, YEAR(DOJ)
		) TT
		PIVOT 
		(
			  SUM([EmployeeCount])
			  FOR [Year] IN ([2006],[2007],[2008],[2009],[2010],[2011])
		) PT

--Count SPACE
DECLARE 	@strName VARCHAR(1000)
SET		@strName = ' White Space is where the world and all distraction falls away '
PRINT		(LEN(@strName) - LEN(REPLACE(@strName, ' ', '')))
PRINT		(DATALENGTH(@strName) - DATALENGTH(REPLACE(@strName, ' ', '')))


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
		