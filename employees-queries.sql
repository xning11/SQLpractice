USE employees; 


/*	Find the number of employees hired each year.
	Find the number of employees hired each month.
	Find the number of employees hired each week. 	*/ 
    
SELECT YEAR(hire_date) AS year, COUNT(*) number_hired FROM employees GROUP BY 1 ORDER BY 1; 
SELECT YEAR(hire_date) AS year, MONTH(hire_date) AS month, COUNT(*) number_hired FROM employees GROUP BY 1, 2 ORDER BY 1, 2; 
SELECT YEAR(hire_date) AS year, WEEK(hire_date) AS week, COUNT(*) number_hired FROM employees WHERE hire_date >= '1999-01-01' GROUP BY 1, 2 ORDER BY 1, 2; 


/*	Pivot title rows by year */

SELECT DISTINCT title FROM titles ORDER BY 1;
SELECT title, COUNT(*) FROM titles GROUP BY 1 ORDER BY 1;

SELECT YEAR(from_date) AS year, 
		SUM(CASE WHEN title = 'Assistant Engineer' THEN 1 ELSE 0 END) AS 'AssistantEngineer',
		SUM(CASE WHEN title = 'Engineer' THEN 1 ELSE 0 END) AS 'Engineer',
		SUM(CASE WHEN title = 'Manager' THEN 1 ELSE 0 END) AS 'Manager',
		SUM(CASE WHEN title = 'Senior Engineer' THEN 1 ELSE 0 END) AS 'SeniorEngineer',
		SUM(CASE WHEN title = 'Senior Staff' THEN 1 ELSE 0 END) AS 'SeniorStaff',
		SUM(CASE WHEN title = 'Staff' THEN 1 ELSE 0 END) AS 'Staff',
		SUM(CASE WHEN title = 'Technique Leader' THEN 1 ELSE 0 END) AS 'TechniqueLeader'        
	FROM titles GROUP BY 1 ORDER BY 1; 


-- 	https://www.tarynpivots.com/post/how-to-rotate-rows-into-columns-in-mysql/
-- 	Dynamic SQL, to create the SQL string to be executed 

SET @titlecolumn = NULL;
SELECT 
	GROUP_CONCAT(DISTINCT
         CONCAT(
            "SUM(CASE WHEN title = '", 
            title,
            "' THEN 1 ELSE 0 END) AS '",
            title,
            "'"
		)
	) INTO @titlecolumn 
FROM (SELECT DISTINCT title FROM titles ORDER BY 1) d; 
    
-- SELECT @titlecolumn; 

SET @titlecolumn = 
	CONCAT(
		"SELECT YEAR(from_date) AS year, ",
        @titlecolumn, 
        "FROM titles GROUP BY 1 ORDER BY 1"); 
        
PREPARE stmt FROM @titlecolumn;
EXECUTE stmt;
DEALLOCATE PREPARE stmt; 



/*	Find the 3 most recently hired employees and what department they work in.	*/

WITH recent_hired3 AS (SELECT * FROM employees ORDER BY hire_date DESC LIMIT 3) 
SELECT recent_hired3.*, departments.dept_name FROM dept_emp JOIN recent_hired3 USING(emp_no) JOIN departments USING(dept_no); 



/*	Find the Running Daily Sum of number of employees hired ever.	*/

WITH tab AS (SELECT hire_date, COUNT(*) AS number_hired FROM employees WHERE hire_date > '2000-01-01' GROUP BY hire_date ORDER BY hire_date)
	SELECT *, SUM(number_hired) OVER (ORDER BY hire_date) AS total_hired FROM tab ;

SELECT t.hire_date, t.number_hired, (@total := @total + t.number_hired) AS total_hired 
	FROM (SELECT hire_date, COUNT(*) AS number_hired FROM employees WHERE hire_date > '2000-01-01' GROUP BY hire_date) AS t, (SELECT @total := 0) AS n;  


