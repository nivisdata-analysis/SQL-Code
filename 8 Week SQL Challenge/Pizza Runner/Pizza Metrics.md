# Pizza Metrics Solution

**1. How many pizzas were ordered?**
```
SELECT COUNT(order_id) as pizza_ordered 
FROM customer_orders_temp;
```

**2. How many unique customer orders were made?**
```
SELECT COUNT(DISTINCT order_id) as unique_pizza_ordered
FROM customer_orders_temp;
```

**3. How many successful orders were delivered by each runner?**
```
SELECT runner_id, COUNT(order_id) as succesful_orders
FROM runner_orders_temp
WHERE cancellation IS NULL
GROUP BY runner_id;
```

**4. How many of each type of pizza was delivered?**
```
SELECT pn.pizza_name,
	COUNT(co.pizza_id) AS pizza_delivered
FROM pizza_names pn
JOIN customer_orders_temp co ON pn.pizza_id = co.pizza_id
JOIN runner_orders_temp rot ON co.order_id = rot.order_id AND cancellation IS NULL
GROUP BY pizza_name;
```

**5. How many Vegetarian and Meatlovers were ordered by each customer?**
```
SELECT customer_id, pn.pizza_name,
	COUNT(co.pizza_id) AS pizza_ordered
FROM pizza_names pn
JOIN customer_orders_temp co ON pn.pizza_id = co.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id;
```

**6. What was the maximum number of pizzas delivered in a single order?**
```
SELECT TOP 1 co.order_id,
	COUNT(co.order_id) AS pizza_delivered_count
FROM customer_orders_temp co
JOIN runner_orders_temp ro ON co.order_id = ro.order_id
WHERE cancellation IS NULL
GROUP BY co.order_id
ORDER BY pizza_delivered_count DESC;
```

**7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**
```
SELECT customer_id, 
	SUM(
		CASE WHEN  exclusions IS NOT NULL OR extras IS NOT NULL THEN 1
		ELSE 0 END) AS change,
	SUM(
		CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1
		ELSE 0 END) AS unchange
FROM customer_orders_temp co
JOIN runner_orders_temp ro ON co.order_id = ro.order_id
WHERE cancellation IS NULL
GROUP BY customer_id;
```

**8. How many pizzas were delivered that had both exclusions and extras?**
```
SELECT COUNT(co.order_id) AS pizza_having_exclusions_n_extras
FROM customer_orders_temp co
JOIN runner_orders_temp ro ON co.order_id = ro.order_id
WHERE exclusions IS NOT NULL AND extras IS NOT NULL AND cancellation IS NOT NULL;
```

**9. What was the total volume of pizzas ordered for each hour of the day?**
```
SELECT 
	DATEPART(HOUR, order_time) AS hour_of_day, 
	COUNT(order_id) AS tota_volume 
FROM customer_orders_temp
GROUP BY  DATEPART(HOUR, order_time);
```

**10. What was the volume of orders for each day of the week?**
```
SELECT 
	DATENAME(WEEKDAY, order_time) AS day_of_week,
	COUNT(order_id) AS pizza_count
FROM customer_orders_temp
GROUP BY DATENAME(WEEKDAY, order_time);
```
