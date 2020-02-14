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



/*	Second or Nth Highest Salary	*/ 

-- Limit emp_no <= 10100 in order to speed up query 
WITH full_employee_salaries AS (
	SELECT d.dept_name, s.emp_no, MAX(s.salary) AS salary
		FROM (SELECT * FROM salaries WHERE emp_no <= 10100) s	
			JOIN dept_emp de USING (emp_no) 
			JOIN departments d USING(dept_no) 
		GROUP BY 1 , 2
), 
salary_rankings AS (
	SELECT *, DENSE_RANK() OVER (ORDER BY salary DESC) AS salary_ranking 
		FROM full_employee_salaries
)
SELECT * FROM salary_rankings WHERE salary_ranking = 3; 


SET @n=3; 
WITH full_employee_salaries AS (
SELECT d.dept_name, s.emp_no, MAX(s.salary) AS salary
	FROM (SELECT * FROM salaries WHERE emp_no <= 10100) s	
		JOIN dept_emp de USING (emp_no) 
		JOIN departments d USING(dept_no) 
	GROUP BY 1 , 2
) 
SELECT s1.* FROM full_employee_salaries AS s1 
	WHERE (@n-1)=(SELECT COUNT(DISTINCT salary) FROM full_employee_salaries AS s2 WHERE s2.salary > s1.salary); 



/*	Second or Nth Highest Salary Department Wise	*/ 

WITH full_employee_salaries AS (
	SELECT d.dept_name, s.emp_no, MAX(s.salary) AS salary
		FROM (SELECT * FROM salaries) s	
			JOIN dept_emp de USING (emp_no) 
			JOIN departments d USING(dept_no) 
		GROUP BY 1 , 2
), 
salary_rankings_dept AS (
	SELECT *, DENSE_RANK() OVER (PARTITION BY dept_name ORDER BY salary DESC) AS salary_ranking 
		FROM full_employee_salaries
)
SELECT * FROM salary_rankings_dept WHERE salary_ranking = 3; 



/*	Current Manager in Each Department	*/ 

SELECT dept_no, COUNT(emp_no) AS number_of_managers 
			FROM dept_manager GROUP BY dept_no; 


WITH current_manager AS (
SELECT m.dept_no, m.emp_no, m.from_date 
	FROM dept_manager m
	JOIN (SELECT dept_no, MAX(from_date) AS from_date 
			FROM dept_manager GROUP BY dept_no) tt 
		USING (from_date)
) 
SELECT CONCAT(e.first_name, ' ', e.last_name) AS manager_name, d.dept_name, 
		cm.from_date AS manager_date, e.hire_date, 
        FLOOR(DATEDIFF(cm.from_date, e.hire_date)/365) AS years_to_be_manager
	FROM current_manager cm 
		JOIN departments d USING(dept_no) 
		JOIN employees e USING(emp_no); 



/*	Getting All Level Child	*/ 
-- The database does not contain manager-employee relations, thus not able to do this. 

