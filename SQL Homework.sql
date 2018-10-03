use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name
from actor_info;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name.
select upper(concat(first_name, ',', last_name)) AS 'Actor Name'
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name
from actor
where first_name LIKE 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
select actor_id, first_name, last_name
from actor
where last_name like '%Gen%';

-- 2c. Find all actors whose last names contain the letters LI. This time, 
-- order the rows by last name and first name, in that order:
select actor_id, first_name, last_name
from actor
where last_name like '%Li%'
order by last_name, first_name asc;

--  2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN desciption BLOB NOT NULL;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.
ALTER TABLE actor
DROP COLUMN desciption;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) as 'Last Name Count' 
from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
select last_name, count(*) as 'Last Name Count' 
from actor 
group by last_name
having count(*) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.

update actor 
set first_name = "HARPO"
where first_name = "Groucho" AND last_name = "Williams";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO.

update actor 
set first_name = 'GROUCHO'
where actor_id = 172;

-- 5a. You cannot locate the schema of the address table. 
-- Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:

SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON staff.address_id=address.address_id;


-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.

select payment.staff_id as 'Staff ID', staff.first_name as 'First Name', 
staff.last_name as 'Last Name', sum(payment.amount) as 'Staff Member Total Transactions (August 2005)'
from staff 
inner join payment on staff.staff_id = payment.staff_id 
where payment.payment_date between '2005-08-01' and '2005-08-31'
group by payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. 
-- Use inner join.

select film.title as 'Film Title', count(film_actor.actor_id) as `Number of Actors`
from film_actor 
inner join film
on film_actor.film_id= film.film_id
group by film.title;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select film.title as "Title", (
select count(*) from inventory
where film.film_id = inventory.film_id
) as 'Number of Copies'
from film
where title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
-- ![Total amount paid](Images/total_payment.png)

select customer.customer_id as "Customer ID",customer.first_name,customer.last_name, 
sum(payment.amount) as "Number of Total Amount Paid"
from payment 
inner join customer
where customer.customer_id = payment.customer_id
group by payment.customer_id;
 

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select title as "Title", language_id as "Language ID"
from film where title 
like 'K%' or title like 'Q%'
and title in 
(
select title 
from film 
where language_id = 1
);


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

select first_name as "First Name", last_name  as "Last Name"
from actor where actor_id in
	(select actor_id from film_actor
    where film_id in
    (select film_id from film
    where title = "Alone Trip"));

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

select customer.first_name as "First Name", customer.last_name as "Last Name", 
customer.email as "Email"
from customer
inner join address on customer.address_id = address.address_id
inner join city on city.city_id = address.city_id
inner join country on country.country_id = city.country_id
where country.country = "Canada";


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for 
-- a promotion. Identify all movies categorized as family films.

select film.title as "Film Title"
from film
inner join film_category on film_category.film_id = film.film_id
inner join category on category.category_id = film_category.category_id
where category.name = "Family";

-- 7e. Display the most frequently rented movies in descending order.

select film.title as "Film Title"
from film
inner join inventory on inventory.film_id = film.film_id
inner join rental on rental.inventory_id = inventory.inventory_id
group by rental_date desc;


-- 7f. Write a query to display how much business, in dollars, each store brought in.

select store.store_id as "Store ID", sum(payment.amount) as "Total Revenue"
from payment
inner join staff on staff.staff_id = payment.staff_id
inner join store on store.store_id = staff.store_id
group by store.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.

select store.store_id as "Store ID", city.city as "City Name", country.country as "Country Name"
from store
inner join address on address.address_id = store.address_id
inner join city on city.city_id = address.city_id
inner join country on country.country_id = city.country_id;


-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select category.name as "Genre", sum(payment.amount) as "Gross"
from category
inner join film_category on film_category.category_id = category.category_id
inner join inventory on inventory.film_id = film_category.film_id
inner join rental on rental.inventory_id = inventory.inventory_id
inner join payment on payment.rental_id = rental.rental_id
group by Genre
order by Gross desc limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres 
-- by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, 
-- you can substitute another query to create a view.

create view top_five_genres_by_gross_revenue as
select category.name as "Genre", sum(payment.amount) as "Gross"
from category
inner join film_category on film_category.category_id = category.category_id
inner join inventory on inventory.film_id = film_category.film_id
inner join rental on rental.inventory_id = inventory.inventory_id
inner join payment on payment.rental_id = rental.rental_id
group by Genre
order by Gross desc limit 5;

-- 8b. How would you display the view that you created in 8a?

select * from top_five_genres_by_gross_revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view top_five_genres_by_gross_revenue;







