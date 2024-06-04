# Runner and Customer Experience solutions

**1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)**
```
SET DATEFIRST 1;
SELECT DATEPART(WEEK, registration_date ) AS week_period, COUNT(runner_id) AS runners_count
FROM runners
GROUP BY DATEPART(WEEK, registration_date);
```

**2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**
```
WITH time_diff AS (
	SELECT ro.runner_id, ro.order_id, order_time, pickup_time, DATEDIFF(minute,order_time,pickup_time) AS time_taken
	FROM runner_orders_temp ro
	JOIN customer_orders_temp co ON ro.order_id = co.order_id
	WHERE ro.cancellation IS NULL
)

SELECT runner_id, ROUND(AVG(time_taken), 0) AS average_time
FROM time_diff
GROUP BY runner_id;
```

**3. Is there any relationship between the number of pizzas and how long the order takes to prepare?**
```
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
```

**4. What was the average distance travelled for each customer?**
```
SELECT customer_id, 
	ROUND(AVG(distance),2) AS avg_distance_travelled
FROM customer_orders_temp co
JOIN runner_orders_temp ro ON co.order_id = ro.order_id
GROUP BY customer_id;
```

**5. What was the difference between the longest and shortest delivery times for all orders?**
```
SELECT 
	MAX(duration) AS longest, 
	MIN(duration) AS shortest,
	MAX(duration) - MIN(duration) AS delivery_time_diff 
FROM runner_orders_temp;
```

**6. What was the average speed for each runner for each delivery and do you notice any trend for these values?**
```
SELECT order_id, runner_id, ROUND(AVG(60*distance/duration), 2) AS avg_speed
FROM runner_orders_temp
WHERE cancellation IS NULL
GROUP BY runner_id, order_id
ORDER BY runner_id, order_id;
```

**7. What is the successful delivery percentage for each runner?**
```
SELECT 
	runner_id,
    COUNT(pickup_time) AS success_delivery,
    COUNT(order_id) AS total_order,
    ROUND(100*COUNT(pickup_time)/COUNT(order_id),0) AS perc_delivery
FROM runner_orders_temp
GROUP BY runner_id;
```
