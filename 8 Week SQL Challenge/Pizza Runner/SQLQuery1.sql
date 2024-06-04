--Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

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
SELECT *
FROM customer_orders_temp;



--Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH group_cte AS (
SELECT pr.pizza_id, CONCAT(pizza_name, ': ' , STRING_AGG(topping_name, ', ')) AS Ingredients_list
FROM pizza_recipes_temp pr
JOIN pizza_names pn ON pr.pizza_id = pn.pizza_id
GROUP BY pr.pizza_id,pizza_name
)

SELECT order_id, customer_id,co.pizza_id, exclusions, extras, Ingredients_list,record_id
FROM customer_orders_temp co
JOIN group_cte gc ON co.pizza_id = gc.pizza_id
ORDER BY order_id

-------------------------------------------------------
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
--------------------------------
WITH extra_table AS (
	SELECT record_id, p.order_id,
       TRIM(extras_cleaned.value) as extras_cleaned
	FROM customer_orders_temp as p
	CROSS APPLY string_split(p.extras, ',') as extras_cleaned
)
SELECT *,
	CASE WHEN pizza_id = 1 THEN 12
	ELSE 10 END AS total_amount
FROM customer_orders_temp co 
LEFT JOIN extra_table et ON co.record_id = et.record_id