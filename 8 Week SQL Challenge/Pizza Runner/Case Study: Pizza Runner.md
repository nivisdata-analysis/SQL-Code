# SQL Case Study #2 (Week 2) - Pizza Runner

Note: All source material and respected credit is from: https://8weeksqlchallenge.com/

## Table of Contents:
1. Dataset Structure
2. Entity Relationship Diagram
3. Data Cleaning
4. Case Study Questions + Answers

## Dataset Structure
Note: The original data was built around PostgreSQL, but was swapped to fit SQL Server syntax.

```
USE pizza_runner;

-- Create runners table
DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INT,
  registration_date DATE
);

-- Insert data into runners table
INSERT INTO runners (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

-- Create customer_orders table
DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INT,
  customer_id INT,
  pizza_id INT,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time DATETIME
);

-- Insert data into customer_orders table
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

-- Create runner_orders table
DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INT,
  runner_id INT,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

-- Insert data into runner_orders table
INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

-- Create pizza_names table
DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INT,
  pizza_name TEXT
);

-- Insert data into pizza_names table
INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

-- Create pizza_recipes table
DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INT,
  toppings TEXT
);

-- Insert data into pizza_recipes table
INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

-- Create pizza_toppings table
DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INT,
  topping_name TEXT
);

-- Insert data into pizza_toppings table
INSERT INTO pizza_toppings (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
```
## Entity Relationship Diagram
![Pizza Runner - dbdiagram](https://github.com/nivisdata-analysis/SQL-Code/assets/171444078/10bc265a-8a1e-4f6e-a1cc-77359b374552)

## Data Cleaning
After investigating the data in the tables, we conclude there is need for data cleaning before we can start the analysis part. 

To clean the **customer_orders** and **runner_orders** table: I created new tables called customer_orders_temp and runner_orders_temp respectively to avoid any data loss of the original table.

### customer_orders_temp

Changes:
+ Changing all the null and blank to Null
```
DROP TABLE IF EXISTS customer_orders_temp
SELECT order_id, 
       customer_id,
       pizza_id, 
       CASE
            WHEN exclusions = '' or exclusions like 'null' or exclusions like 'NaN' THEN NULL
            ELSE exclusions END AS exclusions,
       CASE
            WHEN extras = '' OR extras like 'null' or extras like 'NaN' THEN NULL
            ELSE extras END AS extras, 
       order_time
INTO customer_orders_temp
FROM customer_orders;
```
### runner_orders_temp

Changes:
+ Changing all the null and blank to Null
+ Removing 'km' from distance
+ Removing anything after the numbers from duration
+ Creating a clean temp table
```
DROP TABLE IF EXISTS runner_orders_temp
SELECT	order_id, 
	runner_id,
	CASE 
		WHEN pickup_time like 'null' THEN NULL
		ELSE pickup_time END AS pickup_time,
	CASE 
		WHEN distance like 'null' THEN NULL
		WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
		ELSE distance END AS distance,
	CASE 
		WHEN duration like 'null' THEN NULL
		WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
		WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)        
		WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)  
		ELSE duration END AS duration,	
	CASE 
		WHEN cancellation = '' OR cancellation LIKE 'null' OR cancellation LIKE 'NaN'  THEN NULL
		ELSE cancellation END AS cancellation
INTO runner_orders_temp
FROM runner_orders;
```
### pizza_recipes_temp

Changes:
+ Splitting comma delimited lists into rows
+ Creating a clean new table
```
DROP TABLE IF EXISTS pizza_recipes_temp;
SELECT pizza_id, 
       TRIM(topping_id.value) as topping_id,
       topping_name
INTO pizza_recipes_temp
FROM pizza_recipes as p
CROSS APPLY string_split(p.toppings, ',') as topping_id
INNER JOIN pizza_toppings p2 ON TRIM(topping_id.value) = p2.topping_id
```
## Changing data types

For runner_orders table:
+ Change pickup_time DATETIME
+ Change distance to FLOAT
+ Change duration to INT

For pizza_names table:
+ Change pizza_name to VARCHAR(MAX)

For pizza_recipes table:
+ Change toppings to VARCHAR(MAX)

For pizza_toppings table:
+ Change topping_name to VARCHAR(MAX)

```
ALTER TABLE runner_orders_temp
ALTER COLUMN pickup_time DATETIME

ALTER TABLE runner_orders_temp
ALTER COLUMN distance FLOAT

ALTER TABLE runner_orders_temp
ALTER COLUMN duration INT;

ALTER TABLE pizza_names
ALTER COLUMN pizza_name VARCHAR(MAX);

ALTER TABLE pizza_recipes
ALTER COLUMN toppings VARCHAR(MAX);

ALTER TABLE pizza_toppings
ALTER COLUMN topping_name VARCHAR(MAX)
```
Now, we can perform the analysis on the cleaned data.




















