# SQL Practice 


## MySQL Databases
1. sakila https://dev.mysql.com/doc/index-other.html
2. employees https://dev.mysql.com/doc/employee/en/employees-installation.html
3. Northwind http://perso.sinfronteras.ws/index.php/File:NorthwindDB.zip 


## Collection of questions

### sakila
1. Which actors have the first name 'Scarlett'? 
2. Which actors have the last name 'Johansson'?  
3. How many distinct actors last names are there?  
4. Which last names are not repeated? 
5. Which last names appear more than once? 
6. Which actor has appeared in the most films? 
7. Is 'Academy Dinosaur' available for rent from Store 1? 
    - Step 1: which copies are at Store 1? 
    - Step 2: pick an inventory_id to rent: 
8. Insert a record to represent Mary Smith renting 'Academy Dinosaur' from Mike Hillyer at Store 1 today. 
9. When is 'Academy Dinosaur' due? 
    - Step 1: what is the rental duration? 
    - Step 2: which rental are we referring to -- the last one. 
    - Step 3: add the rental duration to the rental date. 
10. What is that average running time of all the films in the sakila DB? 
11. What is the average running time of films by category? 
12. Which film categories are long? 
13. Why does this query return the empty set? 

1. What are the names of all the languages in the database (sorted alphabetically)? 
2. Return the full names (first and last) of actors with “SON” in their last name, ordered by their first name. 
3. Find all the addresses where the second address is not empty (i.e., contains some text), and return these second addresses sorted. 
4. Return the first and last names of actors who played in a film involving a “Crocodile” and a “Shark”, along with the release year of the movie, sorted by the actors’ last names. 
5. How many films involve a “Crocodile” and a “Shark”? 
6. Find all the film categories in which there are between 55 and 65 films. Return the names of these categories and the number of films per category, sorted by the number of films. 
7. In how many film categories is the average difference between the film replacement cost and the rental rate larger than 17? 
8. Find the address district(s) name(s) such that the minimal postal code in the district(s) is maximal over all the districts. Make sure your query ignores empty postal codes and district names. 
9. Find the names (first and last) of all the actors and costumers whose first name is the same as the first name of the actor with ID 8. Do not return the actor with ID 8 himself. Note that you cannot use the name of the actor with ID 8 as a constant (only the ID). There is more than one way to solve this question, but you need to provide only one solution. 
10. Give an interesting query of your own that is not already in the assignment. The query should involve an aggregation operation, and a nested SELECT. Give, along with the query, the English explanation and the answer. 

1. How many distinct countries are there? 
2. Find out the top 5 countries with most number of clients.  
3. What are the names of all the languages in the database (sorted alphabetically)?	
4. Return the full names (first and last) of actors with “SON” in their last name, ordered by their first name.	
5. Create a list of films and their corresponding categories. 
6. Create a list of categories and the number of films for each category. 
7. Create a list of actors and the number of movies by each actor.	
8. List the film_id and titles of those films that are not in inventory. 
9. Find a list of customers who have not rented a movie yet. 
10. Find the number of English films in the category of ‘Documentary’. 

1. Find all films that are have ever been rented. How many are there? 
2. How many films are rented out and have not been returned? 
3. How many films are overdue? 
4. Create a list of overdue DVDs and explain to the best of your knowledge what the INNER JOIN operation does. 
5. Create a list of currently rented films (limit to 5 sorted by customer_id) and provide a screen dump of your query and results. 
6. Write a query to display the total payment (total payment is calculated by sum up all amounts in Payment table) and number of renting times of films for all customers who have number of renting times is greater than or equals to 40. Order by number of renting as ascending.  


### employees
1. Find the number of employees hired each year, the number of employees hired each month, and the number of employees hired each week. 
2. Pivot title rows by year. 
3. Find the 3 most recently hired employees and what department they work in.
4. Find the Running Daily Sum of number of employees hired ever. 
5. Find the second or Nth highest salary by department. 


### Reference 
- https://datamastery.gitlab.io/exercises/sakila-queries.html 
- http://courses.cs.tau.ac.il/databases/databases201213a/assignments/hw1.pdf 
- https://www.chegg.com/homework-help/questions-and-answers/exercise-working-sakila-mysql-database-needed-downloaded-http-devmysqlcom-doc-sakila-en-sa-q25309942 
- http://mercury.pr.erau.edu/~siewerts/cs317/assignments/Fall-16/Exercise-1-Requirements.pdf
- http://www.techsapphire.in/index/sql_complex_queries_query_optimization_and_interview_questions_sql_server_2016/0-190 