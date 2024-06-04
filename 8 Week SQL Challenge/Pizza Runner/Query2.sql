--B. Runner and Customer Experience
--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SET DATEFIRST 1;
SELECT DATEPART(WEEK, registration_date ) AS week_period, COUNT(runner_id) AS runners_count
FROM runners
GROUP BY DATEPART(WEEK, registration_date);

--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

WITH time_diff AS (
	SELECT ro.runner_id, ro.order_id, order_time, pickup_time, DATEDIFF(minute,order_time,pickup_time) AS time_taken
	FROM runner_orders_temp ro
	JOIN customer_orders_temp co ON ro.order_id = co.order_id
	WHERE ro.cancellation IS NULL
)

SELECT runner_id, ROUND(AVG(time_taken), 0) AS average_time
FROM time_diff
GROUP BY runner_id;
--Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH time_diff AS (
	SELECT co.order_id, COUNT(co.order_id) as pizza_count, DATEDIFF(minute,order_time,pickup_time) AS time_taken
	FROM runner_orders_temp ro
	JOIN customer_orders_temp co ON ro.order_id = co.order_id
	WHERE ro.cancellation IS NULL
	GROUP BY co.order_id, order_time, pickup_time
)

SELECT pizza_count, time_taken 
FROM time_diff
GROUP BY pizza_count, time_taken;

--What was the average distance travelled for each customer?
SELECT customer_id, 
	ROUND(AVG(distance),2) AS avg_distance_travelled
FROM customer_orders_temp co
JOIN runner_orders_temp ro ON co.order_id = ro.order_id
GROUP BY customer_id;
--What was the difference between the longest and shortest delivery times for all orders?
SELECT 
	MAX(duration) AS longest, 
	MIN(duration) AS shortest,
	MAX(duration) - MIN(duration) AS delivery_time_diff 
FROM runner_orders_temp;

--What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT order_id, runner_id, ROUND(AVG(60*distance/duration), 2) AS avg_speed
FROM runner_orders_temp
WHERE cancellation IS NULL
GROUP BY runner_id, order_id
ORDER BY runner_id, order_id;

--What is the successful delivery percentage for each runner?
SELECT 
	runner_id,
    COUNT(pickup_time) AS success_delivery,
    COUNT(order_id) AS total_order,
    ROUND(100*COUNT(pickup_time)/COUNT(order_id),0) AS perc_delivery
FROM runner_orders_temp
GROUP BY runner_id;

--C. Ingredient Optimisation
--What are the standard ingredients for each pizza?
SELECT pizza_id, STRING_AGG(topping_name, ', ') AS standard_ingredients
FROM pizza_recipes_temp
GROUP BY pizza_id;
 
--What was the most commonly added extra?
WITH max_extra AS (
	SELECT p.pizza_id, 
		   TRIM(topping_id.value) as topping_id,
		   topping_name
	FROM customer_orders_temp as p
	CROSS APPLY string_split(p.extras, ',') as topping_id
	INNER JOIN pizza_toppings p2 ON TRIM(topping_id.value) = p2.topping_id
)
SELECT topping_id,COUNT(topping_id) AS exclusion_counts, topping_name
FROM max_extra
GROUP BY topping_id, topping_name
ORDER BY exclusion_counts DESC;

--What was the most common exclusion?
WITH max_exclusion AS (
	SELECT p.pizza_id, 
       TRIM(topping_id.value) as topping_id,
       topping_name
	FROM customer_orders_temp as p
	CROSS APPLY string_split(p.exclusions, ',') as topping_id
	RIGHT JOIN pizza_toppings p2 ON TRIM(topping_id.value) = p2.topping_id
)

SELECT topping_id,COUNT(topping_id) AS exclusion_counts, topping_name
FROM max_exclusion
GROUP BY topping_id, topping_name
ORDER BY exclusion_counts DESC;
--Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

--What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
