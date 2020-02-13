-- https://datamastery.gitlab.io/exercises/sakila-queries.html 

/*  Which actors have the first name 'Scarlett' */ 
SELECT * FROM actor WHERE first_name = 'Scarlett';

/*  Which actors have the last name 'Johansson' */ 
SELECT * FROM actor WHERE last_name = 'Johansson';

/*  How many distinct actors last names are there? */ 
SELECT COUNT(DISTINCT last_name) FROM actor;  

/*  Which last names are not repeated? */ 
SELECT last_name FROM actor GROUP BY 1 HAVING count(*) = 1;

/*  Which last names appear more than once? */ 
SELECT last_name FROM actor GROUP BY 1 HAVING count(*) > 1;

/*  Which actor has appeared in the most films? */ -- GINA DEGENERES
SELECT a.first_name, a.last_name, fa.film_number 
		FROM (SELECT actor_id, COUNT(film_id) film_number FROM film_actor GROUP BY actor_id) fa 
		JOIN actor a ON fa.actor_id = a.actor_id
		ORDER BY fa.film_number DESC LIMIT 1;

select actor.actor_id, actor.first_name, actor.last_name,
			   count(actor_id) as film_count
		from actor join film_actor using (actor_id)
		group by actor_id
		order by film_count desc
		limit 1;


/*  Is 'Academy Dinosaur' available for rent from Store 1? */ 
/*  Step 1: which copies are at Store 1? */ 
	SELECT f.film_id, f.title, v.store_id, v.inventory_id 
			FROM film f 
			JOIN inventory v 
			ON f.film_id = v.film_id 
			WHERE f.title LIKE 'Academy Dinosaur' 
			AND v.store_id = 1;

	-- SELECT COLLATION(VERSION()); -- Used to check case sensitivity; 
	-- utf8_general_ci --> case-insensitive, default 
	-- utf8mb4_bin --> case-sensitive 

/*  Step 2: pick an inventory_id to rent: */ 	-- meaning previous rents have been returned with a valid return date  
	SELECT f.title, r.inventory_id 
			FROM film f 
			JOIN inventory v 
			ON f.film_id = v.film_id 
			JOIN rental r 
			ON v.inventory_id = r.inventory_id
			WHERE f.title LIKE 'Academy Dinosaur' 
			AND v.store_id = 1 
			AND r.return_date IS NOT NULL;

/*  Insert a record to represent Mary Smith renting 'Academy Dinosaur' from Mike Hillyer at Store 1 today. */ 
	INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id) 
	VALUES (NOW(), 1, 1, 1); 

	SELECT * FROM rental WHERE staff_id = 1 AND customer_id = 1 AND YEAR(last_update) = 2020; 	-- check insertion 

	DELETE FROM rental WHERE staff_id = 1 AND customer_id = 1  AND YEAR(last_update) = 2020; 	-- check deletion 

	SELECT * FROM rental WHERE staff_id = 1 AND customer_id = 1; 

	-- SELECT staff_id FROM staff WHERE first_name = 'Mike' AND last_name = 'Hillyer';		-- staff_id = 1  
	-- SELECT customer_id FROM customer WHERE first_name = 'Mary' AND last_name = 'Smith'; 	-- customer_id = 1 


/*  When is 'Academy Dinosaur' due? */ 
/*  Step 1: what is the rental duration? */ -- 6 days  
    SELECT f.film_id, f.title, r.rental_id, f.rental_duration, DATEDIFF(r.return_date, r.rental_date) AS rental_duration_act
			FROM film f 
			JOIN inventory v 
			ON f.film_id = v.film_id 
			JOIN rental r 
			ON v.inventory_id = r.inventory_id 
			WHERE f.title LIKE 'Academy Dinosaur';

	-- SELECT *, DATEDIFF(return_date, rental_date) AS rental_duration FROM rental; 
	-- SELECT rental_duration FROM film WHERE title LIKE 'Academy Dinosaur';

/*  Step 2: which rental are we referring to -- the last one. */ 
	SELECT * FROM rental ORDER BY rental_id DESC LIMIT 1; 
    
/*  Step 3: add the rental duration to the rental date. */ 		-- Add 6 days to the rental date 
	SELECT rental_date, 
		   rental_date + INTERVAL
					   (SELECT rental_duration FROM film WHERE film_id = 1) DAY
					   AS due_date
		FROM rental
		WHERE rental_id = (select rental_id from rental order by rental_id desc limit 1);


/*  What is that average running time of all the films in the sakila DB? */ 
SELECT AVG(length) FROM film;

/*  What is the average running time of films by category? */ 
SELECT fc.category_id, AVG(f.length)
		FROM film f 
		JOIN film_category fc 
		ON f.film_id = fc.film_id 
		GROUP BY fc.category_id;

/* 	Which film categories are long? */
SELECT c.name, AVG(f.length) AS cat_length 
		FROM film f 
		JOIN film_category fc 
		ON f.film_id = fc.film_id 
		JOIN category c
		ON fc.category_id = c.category_id
		GROUP BY 1
		HAVING AVG(f.length) > (SELECT AVG(length) FROM film)
		ORDER BY 2 DESC;

/*  Why does this query return the empty set? */  -- both have film_id and last_update, but last_update does not match 
show columns from film;

select * from film join inventory using(film_id, last_update); 
select * from film join inventory using(film_id); 



-- http://courses.cs.tau.ac.il/databases/databases201213a/assignments/
-- http://courses.cs.tau.ac.il/databases/databases201213a/assignments/hw1.pdf 

/* 	1. What are the names of all the languages in the database (sorted alphabetically)? */ 
SELECT DISTINCT name FROM language ORDER BY 1 ; 

/* 	2. Return the full names (first and last) of actors with “SON” in their last name, ordered by their first name. */
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM actor WHERE last_name LIKE '%SON%' ORDER BY 1; 

/* 	3. Find all the addresses where the second address is not empty (i.e., contains some text), and return these second addresses sorted. */ 
SELECT address2 FROM address WHERE address2 IS NOT NULL; 

/* 	4. Return the first and last names of actors who played in a film involving a “Crocodile” and a “Shark”, along with the release year of the movie, sorted by the actors’ last names. */ 
SELECT CONCAT(a.first_name, ' ', a.last_name) AS actor_name, f.title, f.description, f.release_year
		FROM actor a 
		JOIN film_actor fa ON a.actor_id = fa.actor_id 
		JOIN film f ON f.film_id = fa.film_id 
		WHERE f.description LIKE '%Crocodile%' AND f.description LIKE '%Shark%' ;

/* 	5. How many films involve a “Crocodile” and a “Shark”? */
SELECT COUNT(DISTINCT title)
		FROM film_text 
		WHERE description LIKE '%Crocodile%' AND description LIKE '%Shark%' ;

/* 	6. Find all the film categories in which there are between 55 and 65 films. Return the names of these
categories and the number of films per category, sorted by the number of films. */ 
SELECT category_id, COUNT(*) AS number_of_films
		FROM film_category
		GROUP BY category_id
		HAVING COUNT(*) >= 55 AND COUNT(*) <= 65
		ORDER BY 2; 

/* 	7. In how many film categories is the average difference between the film replacement cost and the rental rate larger than 17? */ 
SELECT COUNT(*) FROM (
			SELECT fc.category_id, AVG(replacement_cost - rental_rate) AS margin 
				FROM film f JOIN film_category fc ON f.film_id = fc.film_id 
				GROUP BY 1
			) cat_margin
		WHERE margin > 17; 

SELECT fc.category_id, AVG(replacement_cost - rental_rate) AS margin 
		FROM film f JOIN film_category fc ON f.film_id = fc.film_id 
		GROUP BY 1; 

/* 	8. Find the address district(s) name(s) such that the minimal postal code in the district(s) is maximal
over all the districts. Make sure your query ignores empty postal codes and district names. */ 
SELECT district, MIN(postal_code) AS district_min_code FROM address 
		WHERE postal_code IS NOT NULL AND district != ''
		GROUP BY 1 ORDER BY 2 DESC LIMIT 1; 

WITH dist_min_postal_code AS (
	SELECT district, MIN(postal_code) AS district_min_code FROM address WHERE postal_code IS NOT NULL GROUP BY 1 ORDER BY 2 DESC
) 
SELECT district FROM dist_min_postal_code 
WHERE district_min_code = (SELECT MAX(district_min_code) FROM dist_min_postal_code);  

/* 	9. Find the names (first and last) of all the actors and costumers whose first name is the same as the
first name of the actor with ID 8. Do not return the actor with ID 8 himself. Note that you cannot
use the name of the actor with ID 8 as a constant (only the ID). There is more than one way to solve
this question, but you need to provide only one solution. */ 
SELECT first_name, last_name FROM actor WHERE first_name = (SELECT first_name FROM actor WHERE actor_id = 8) AND actor_id != 8
UNION
SELECT first_name, last_name FROM customer WHERE first_name = (SELECT first_name FROM actor WHERE actor_id = 8); 

/* 	10. Give an interesting query of your own that is not already in the assignment. The query should
involve an aggregation operation, and a nested SELECT. Give, along with the query, the English
explanation and the answer. */ 
SELECT customer_id, COUNT(*), 
		AVG(amount), MIN(amount), MAX(amount), 
		STD(amount), STDDEV(amount), STDDEV_POP(amount), STDDEV_SAMP(amount) 
		FROM payment GROUP BY 1;

SELECT rating, count(*) FROM film GROUP BY rating; 



-- 	https://www.chegg.com/homework-help/questions-and-answers/exercise-working-sakila-mysql-database-needed-downloaded-http-devmysqlcom-doc-sakila-en-sa-q25309942 

/*	1. How many distinct countries are there? */ 
SELECT COUNT(DISTINCT country_id) FROM country;

/*	2. Find out the top 5 countries with most number of clients.  */ 
SELECT ct.country, COUNT(*) FROM customer cs 
		JOIN address ad ON cs.address_id = ad.address_id
		JOIN city ci ON ad.city_id = ci.city_id
		JOIN country ct ON ci.country_id = ct.country_id
		GROUP BY 1 ORDER BY 2 DESC LIMIT 5; 

/*	3. What are the names of all the languages in the database (sorted alphabetically)?	*/
SELECT DISTINCT name FROM language ORDER BY 1; 

/*	4. Return the full names (first and last) of actors with “SON” in their last name, ordered by their first name.	*/ 
SELECT first_name, last_name FROM actor WHERE last_name LIKE '%SON%' ORDER BY 1;

/*	5. Create a list of films and their corresponding categories. */ 
SELECT f.title, c.name FROM film f JOIN film_category fc ON f.film_id = fc.film_id JOIN category c ON fc.category_id = c.category_id; 

/*	6. Create a list of categories and the number of films for each category. */
SELECT c.name, COUNT(*) FROM film_category fc JOIN category c on (fc.category_id = c.category_id) GROUP BY 1 ORDER BY 2 DESC;
 
/*	7. Create a list of actors and the number of movies by each actor.	*/ 
SELECT first_name, last_name, number_of_films FROM actor a JOIN (SELECT actor_id, COUNT(*) AS number_of_films FROM film_actor GROUP BY 1) nb ON a.actor_id = nb.actor_id ORDER BY 3 DESC; 

/*	8. List the film_id and titles of those films that are not in inventory. */ 
SELECT DISTINCT f.film_id, f.title from film f LEFT JOIN inventory i ON f.film_id = i.film_id WHERE i.inventory_id IS NULL;
SELECT DISTINCT f.film_id, f.title from film f WHERE film_id NOT IN (SELECT film_id FROM inventory);

/*	9. Find a list of customers who have not rented a movie yet. */ 
SELECT * FROM customer WHERE customer_id not in (SELECT DISTINCT customer_id FROM rental);

/*	10. Find the number of English films in the category of ‘Documentary’. */ 
SELECT COUNT(*) FROM film JOIN film_category USING(film_id) 
		WHERE language_id = (SELECT language_id FROM language WHERE name = 'English') 
		AND category_id = (SELECT category_id FROM category WHERE name = 'Documentary'); 



-- 	http://mercury.pr.erau.edu/~siewerts/cs317/assignments/Fall-16/Exercise-1-Requirements.pdf
-- 	https://downloads.mysql.com/docs/sakila-en.a4.pdf

/*	a) Find all films that are have ever been rented. How many are there? */ 
SELECT count(distinct film_id) FROM inventory JOIN rental USING(inventory_id); 
 
/*	b) How many films are rented out and have not been returned? */ 
SELECT count(distinct film_id) FROM inventory JOIN rental USING(inventory_id) WHERE return_date IS NULL; 

/*	c) How many films are overdue? */ 
SELECT count(film_id) FROM rental JOIN inventory USING(inventory_id) JOIN film USING(film_id) 
		WHERE return_date IS NULL AND rental_date + INTERVAL film.rental_duration DAY < CURRENT_DATE();

/*	d) Create a list of overdue DVDs and explain to the best of your knowledge what the INNER JOIN operation does. */ 
SELECT CONCAT(customer.last_name, ', ', customer.first_name) AS customer,
		address.phone, film.title, ROW_NUMBER() OVER (ORDER BY title) AS 'row_number'
		FROM rental INNER JOIN customer ON rental.customer_id = customer.customer_id
		INNER JOIN address ON customer.address_id = address.address_id
		INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id
		INNER JOIN film ON inventory.film_id = film.film_id
		WHERE rental.return_date IS NULL
		AND rental_date + INTERVAL film.rental_duration DAY < CURRENT_DATE()
		ORDER BY title;


/*	e) Create a list of currently rented films (limit to 5 sorted by customer_id) and provide a screen dump of your query and results. */ 


/*	Write a query to display the total payment (total payment is calculated by sum up all amounts in Payment table) and 
	number of renting times of films for all customers who have number of renting times is greater than or equals to 40. Order by number of renting as ascending.  */ 
SELECT customer_id, 
		SUM(amount) AS total_amount, 
        COUNT(rental_id) AS total_rentals, 
        SUM(amount)/COUNT(rental_id) AS unit_amount 
		FROM payment GROUP BY 1 HAVING COUNT(rental_id) >= 40 ORDER BY 3 ;



SELECT customer_id, 
		SUM(amount) AS monthly_payment, 
        LAST_DAY(DATE(payment_date)) AS payment_date_cleaned 
        FROM payment GROUP BY 1, 3 ORDER BY 1, 3;



SELECT customer_id, 
		SUM(amount) AS daily_payment, 
        DATE(payment_date) AS payment_date_cleaned
        FROM payment GROUP BY 1, 3 ORDER BY 1, 3;



-- 	https://github.com/joelsotelods/sakila-db-queries  
-- 	https://github.com/sid83/MYSQL_Queries

-- 	http://perso.sinfronteras.ws/index.php/Advanced_Databases
-- 	https://www3.ntu.edu.sg/home/ehchua/programming/sql/SampleDatabases.html


-- 	https://www.oreilly.com/library/view/high-performance-mysql/9780596101718/ch04.html
 
 
