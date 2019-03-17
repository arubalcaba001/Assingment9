use sakila; 

#1a. Display the first and last names of all actors from the table `actor`.

select first_name, last_name
from actor; 

#1b. Display the first and last name of each actor in a single column in upper case letters. 
#Name the column `Actor Name`.

select upper(concat(first_name, ' ', last_name)) as `Actor Name`
from actor; 

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the 
#first name, "Joe." What is one query would you use to obtain this information?

select actor_id, first_name, last_name
from actor
where first_name='Joe';

#2b. Find all actors whose last name contain the letters `GEN`:

select actor_id, first_name, last_name
from actor
where last_name like '%GEN%';

#2c. Find all actors whose last names contain the letters `LI`. This time, order the rows 
#by last name and first name, in that order:
select actor_id, first_name, last_name
from actor
where last_name like '%LI%';

#2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
#Afghanistan, Bangladesh, and China:

select country_id, country
from country 
where country in 
('Afghanistan', 'Bangladesh', 'China');

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
#so create a column in the table `actor` named `description` and use the data type `BLOB` 
#(Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

alter table actor
add column description blob after last_update;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
#Delete the `description` column.

alter table actor
drop column description; 

#4aList the last names of actors, as well as how many actors have that last name.

select last_name, 
count(*) as number_of_actors
from actor group by last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that 
#are shared by at least two actors

select last_name, 
count(*) as number_of_actors
from actor group by last_name having count(*)>=2;

#4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
#Write a query to fix the record.

update actor 
set first_name = 'Harpo'
where First_name = 'Groucho' and last_name = 'Williams';
 
#4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct 
#name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

update actor 
set first_name = 'Groucho'
where First_name = 'Harpo' and last_name = 'Williams';

#5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

describe sakila.address;
show create table address; 
CREATE TABLE if not exists `address` (
   `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
   `address` varchar(50) NOT NULL,
   `address2` varchar(50) DEFAULT NULL,
   `district` varchar(20) NOT NULL,
   `city_id` smallint(5) unsigned NOT NULL,
   `postal_code` varchar(10) DEFAULT NULL,
   `phone` varchar(20) NOT NULL,
   `location` geometry NOT NULL,
   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`address_id`),
   KEY `idx_fk_city_id` (`city_id`),
   SPATIAL KEY `idx_location` (`location`),
   CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
 ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8
 
#6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
#Use the tables `staff` and `address`:

select first_name, last_name, address
from staff s 
join address a
on s.address_id=a.address_id;

#6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
#Use tables `staff` and `payment`.

select  staff.first_name, staff.last_name, sum(payment.amount) as payment_received
from  staff inner join payment on staff.staff_id = payment.staff_id
where payment.payment_date like '%2005-08%'
group by payment.staff_id;

#6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. 
#Use inner join.

select  film.title, count(actor_id) as number_of_actors
from film inner join film_actor  on film.film_id = film_actor.film_id
group by title;

#6d. How many copies of the film `Hunchback Impossible` exist in the 
#inventory system?

select title, count(inventory_id) as number_of_copies
from film inner join inventory on film.film_id=inventory.film_id
where title='Hunchback Impossible';

#6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
#List the customers alphabetically by last name:
#![Total amount paid](Images/total_payment.png)

select first_name, last_name, sum(amount) as total_paid
from payment inner join customer on payment.customer_id=customer.customer_id
group by payment.customer_id
order by last_name asc;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
#films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries 
#to display the titles of movies starting with the letters `K` and `Q` whose language is English.

select title from film
where language_id in
	(select language_id 
	from language
	where name = "English" )
and title like "K%" or title like "Q%";

#7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select first_name, last_name
from actor
where actor_id in 
	(select actor_id from film_actor
	where film_id in 
		(select film_id from film
		where title = "Alone Trip"));
        
#Another way
select  actor.first_name, actor.last_name
from  actor inner join film_actor on actor.actor_id = film_actor.actor_id 
where film_id in 
	(select film_id from film
	where title = "Alone Trip");

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
#of all Canadian customers. Use joins to retrieve this information.

select customer.last_name, customer.first_name, customer.email
from customer inner join customer_list ON customer.customer_id = customer_list.ID
where customer_list.country = 'Canada';

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#Identify all movies categorized as _family_ films.

select  title
from film
where film_id in 
	(select film_id
	from film_category
	where category_id in 
		(select category_id
		from category
		where name = 'Family'));
 
 #Another Way using inner join twice 
 
#7e. Display the most frequently rented movies in descending order.

select film.title, count(*) as number_rented 
from film, inventory, rental
where film.film_id=inventory.film_id
	and rental.inventory_id=inventory.inventory_id
group by inventory.film_id
order by count(*) desc; 

#7f. Write a query to display how much business, in dollars, each store brought in.

select  store.store_id, sum(amount) as business_revenue
from store inner join staff on store.store_id =staff.store_id 
	inner join payment on payment.staff_id=staff.staff_id
group by store.store_id;

#check total above is correct 
select sum(amount) as total_revenue
from payment; 

#Another way 2 different answers????
select store, total_sales
from sales_by_store; 

#7g. Write a query to display for each store its store ID, city, and country.

select store.store_id, city.city, country.country
from store inner join address on store.address_id = address.address_id
	inner join city on address.city_id = city.city_id
	inner join country on city.country_id = country.country_id;

#7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use 
#the following tables: category, film_category, inventory, payment, and rental.)

select category.name, sum(amount) as business_revenue
from category inner join film_category on film_category.category_id=category.category_id
	inner join inventory on inventory.film_id=film_category.film_id
    inner join rental on rental.inventory_id=inventory.inventory_id
    right join payment on payment.rental_id=rental.rental_id
group by name
order by business_revenue desc
limit 5; 

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres 
#by gross revenue. Use the solution from the problem above to create a view. 
#If you haven't solved 7h, you can substitute another query to create a view.

drop view if exists top_five_genres;
create view top_five_genres as 
	select category.name, sum(amount) as business_revenue
	from category inner join film_category on film_category.category_id=category.category_id
		inner join inventory on inventory.film_id=film_category.film_id
		inner join rental on rental.inventory_id=inventory.inventory_id
		right join payment on payment.rental_id=rental.rental_id
	group by name
	order by business_revenue desc
	limit 5; 

#8b. How would you display the view that you created in 8a?

select * from top_five_genres;

#8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

drop view top_five_genres;






