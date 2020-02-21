# SQL high-level questions 

1.	What is cardinality in a database? 
    - In the context of databases, cardinality refers to the uniqueness of data values contained in a column. High cardinality means that the column contains a large percentage of totally unique values. Low cardinality means that the column contains a lot of “repeats” in its data range.  
2.	What is Normalization?
    - Normalization is the process of organizing data to avoid duplication and redundancy. 
    - It is to decompose a table into a number of tables. It automatically reduces duplicate data and also automatically avoids insertion, update, deletion problems. 
3.	What is the sixth normal form in SQL Server? 
    - Sixth Normal Form is the irreducible Normal Form, there will be no further NFs after this, because the data cannot be Normalized further. The rows have been Normalized to the utmost degree. 
    - The definition of 6NF is that a table is in 6NF when the row contains the Primary Key, and at most one attribute. 
4.	When might someone denormalize their data?
    - Denormalization is a strategy used on a previously-normalized database to increase performance. 
    - Databases intended for online transaction processing (OLTP) are typically more normalized than databased intended for online analytical processing (OLAP). 
    - OLAP applications tend to extract historical data that has accumulated over a long period of time. For such databases, redundant or “denormalized” data may facilitate business intelligence applications. 
5.	In which files does SQL Server actually store data?
    - SQL Server data is stored in data files that, by default, have an .MDF extension. The log file (.LDF) files are sequential files used by SQL Server to log transactions executed against the SQL Server instance (more on instances in a moment). 
6.	What is the SQL Profiler?
    - Microsoft SQL Server Profiler is a graphical user interface to SQL trade for monitoring an instance of the database engine or analysis services. 
7.	What does UNION do? What is the difference between UNION and UNION ALL?
    - Combine the result sets of two or more SELECT statements. 
    - UNION will remove duplicated rows, while UNION ALL doesn’t.  
8.	What is the difference between an INNER and OUTER JOIN? 
    - Both inner and outer joins are used to combine rows from two or more tables into a single result. 
    - An inner join finds and returns matching data from tables, while an outer join finds and returns matching data and some dissimilar data from tables. 
9.	What are the NVL and the NVL2 functions in SQL? How do they differ?
    - Similar as IFNULL function in MySQL. 
10.	What is the difference between the RANK() and DENSE_RANK() functions?
    - When have a tie, RANK() will return discontinued number, while DENSE_RANK() will return consecutive number. 
11.	What is the difference between the WHERE and HAVING clauses?
    - WHERE applies filter on original table results, while HAVING applies filter on aggregated table results. 
    - HAVING is usually used in a GROUP BY clause, while WHERE is applied to each row before they a part of the GROUP BY function in a query. 
12.	What is the difference between single-row functions and multiple-row functions?
    - Single row functions work on single row and return one output per row. 
    - Multiple row functions work upon group of rows and return one result for the complete set of rows per group. 
13.	What is the difference between IN and EXISTS? 
    - IN - the inner query is executed first and the list of values obtained as its result is used by the outer query. The inner query is executed for only once. 
    - EXISTS — the first row from the outer query is selected, then the inner query is executed and, the outer query output uses this result for checking. 
14.	How do you copy data from one table to another table?
    - INSERT INTO SELECT statement. 
15.	What is the difference between COUNT(*) and COUNT(col1)? 
    - COUNT(*) returns the total number of rows in a table, including NULL valued rows. 
    - COUNT(col1) returns the total number of non-NULL rows, ignoring NULL valued rows. 
16.	What is the difference between DELETE and TRUNCATE statements? 
    - DELETE is used to delete a row in a table, you can rollback data after using delete statement. It is a DML command, slower. 
    - TRUNCATE is used to delete all the rows from a table, you cannot rollback data. It is a DDL command, faster. 
    - DROP is used to remove a table and it cannot be rolled back from the database. 
17.	What are the different subsets of SQL?
    - DDL (Data Definition Language) — It allows you to perform various operations on the database such as CREATE, ALTER, RENAME, DROP and TRUNCATE objects. 
    - DML (Data Manipulation Language) — It allows you to access and manipulate data, such as INSERT, UPDATE, DELETE and retrieve data from the database. 
    - DCL (Data Control Language) — It allows you to control access to the database, such as GRANT, REVOKE access permissions. 
    - TCL (Transaction Control Language) — COMMIT, ROLLBACK and SAVEPOINT
18.	What is Primary Key and Foreign Key?
    - A Primary key is a column (or collection of columns) that uniquely identifies each row in the table. NULL values are not allowed. 
    - A Foreign Key in one table is the Primary Key of another table. It can be NULL and it does not have to be unique. It maintains referential integrity by enforcing a link between the data in two tables. 
19.	What is the difference between CROSS JOIN and NATURAL JOIN?
    - CROSS JOIN produces the cross product or Cartesian product of two tables. 
    - NATURAL JOIN is based on all the columns having the same same and data types in both the tables. 
20.	What are different operators available in SQL?
    - Arithmetic Operators
    - Logical Operators
    - Comparison Operators 
21.	Are NULL values same as that of zero or a blank space? 
    - A Null value is different from a zero value or a field that contains spaces. A field with a NULL value is one that has been left blank during record creation. 
22.	… 
