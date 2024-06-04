# Ingredient Optimisation

**1. What are the standard ingredients for each pizza?**
```
SELECT pizza_id, STRING_AGG(topping_name, ', ') AS standard_ingredients
FROM pizza_recipes_temp
GROUP BY pizza_id;
```
 
**2. What was the most commonly added extra?**
```
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
```

**3. What was the most common exclusion?**
```
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
```

**4. Generate an order item for each record in the customers_orders table in the format of one of the following:**
**Meat Lovers**
**Meat Lovers - Exclude Beef**
**Meat Lovers - Extra Bacon**
**Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers**
```
SELECT
	co.order_id,
	co.customer_id,
    co.pizza_id,
    pn.pizza_name,
    co.exclusions,
    co.extras,
    CASE
		WHEN co.pizza_id = 1 AND co.exclusions IS NULL AND co.extras IS NULL THEN 'Meat Lovers'
        WHEN co.pizza_id = 2 AND co.exclusions IS NULL AND co.extras IS NULL THEN 'Vegetarian'
        WHEN co.pizza_id = 1 AND co.exclusions = '4' AND co.extras IS NULL THEN 'Meat Lovers - Exclude Cheese'
        WHEN co.pizza_id = 2 AND co.exclusions = '4' AND co.extras IS NULL THEN 'Vegetarian - Exclude Cheese'
        WHEN co.pizza_id = 1 AND co.exclusions IS NULL AND co.extras = '1' THEN 'Meat Lovers - Extra Bacon'
        WHEN co.pizza_id = 2 AND co.exclusions IS NULL AND co.extras = '1' THEN 'Vegetarian - Extra Bacon'
        WHEN co.pizza_id = 1 AND co.exclusions = '4' AND co.extras = '1, 5' THEN 'Meat Lovers - Exclude Cheese - Extra Bacon and Chicken'
        WHEN co.pizza_id = 1 AND co.exclusions = '2, 6' AND co.extras = '1, 4' THEN 'Meat Lovers - Exclude BBQ Sauce and Mushroom - Extra Bacon and Cheese'
	END AS order_item
FROM customer_orders_temp co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id;
```

**5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"**
```
WITH extra_top AS (
	SELECT record_id,p.pizza_id, 
       TRIM(topping_id.value) as topping_id
	FROM customer_orders_temp as p
	CROSS APPLY string_split(p.exclusions, ',') as topping_id
	LEFT JOIN pizza_toppings p2 ON TRIM(topping_id.value) = p2.topping_id
),
exclude_top AS (
	SELECT record_id,p.pizza_id, 
       TRIM(topping_id.value) as topping_id
	FROM customer_orders_temp as p
	CROSS APPLY string_split(p.extras, ',') as topping_id
	LEFT JOIN pizza_toppings p2 ON TRIM(topping_id.value) = p2.topping_id
),

INGREDIENT_CTE AS (SELECT record_id,order_id,
                                pizza_name,
                                CASE WHEN pr.topping_id in (
                                                  SELECT topping_id
                                                  FROM extra_top et
                                                  WHERE co.record_id = et.record_id
                                                 ) 
                                      THEN '2x' + pr.topping_name
                                      ELSE pr.topping_name
                                      END AS topping
                        FROM customer_orders_temp co
                        JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
                        JOIN pizza_recipes_temp pr ON co.pizza_id = pr.pizza_id
                        WHERE pr.topping_id NOT IN (SELECT topping_id 
                                                 FROM exclude_top ex 
                                                 WHERE ex.record_id = co.record_id)
)

SELECT record_id, 
      CONCAT(pizza_name +':' ,STRING_AGG(topping, ',' ) WITHIN GROUP (ORDER BY topping ASC)) AS ingredient_list, order_id
FROM INGREDIENT_CTE
GROUP BY record_id,pizza_name, order_id
ORDER BY 1;
```
