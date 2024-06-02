# SQL Case Study #1 (Week 1) - Danny's Diner
Note: All source material and respected credit is from: https://8weeksqlchallenge.com/

## Table of contents:
1. [Dataset Structure](https://github.com/nivisdata-analysis/SQL-Code/blob/main/8%20Week%20SQL%20Challenge/Danny's%20Diner.md#dataset-structure)
2. Entity Relationship Diagram
3. Case Study Questions + Answers
4. Bonus Questions + Answers

## Dataset Structure:
Note: The original data was built around PostgreSQL, but was swapped to fit SQL Server syntax.

```
-- Create schema
CREATE SCHEMA dannys_diner;

-- Create sales table
CREATE TABLE dannys_diner.sales (
    customer_id CHAR(1),  -- Use CHAR(1) for fixed length
    order_date DATE,
    product_id INT  -- Use INT for integer type
);

-- Insert data into sales table
INSERT INTO dannys_diner.sales (customer_id, order_date, product_id)
VALUES
    ('A', '2021-01-01', 1),
    ('A', '2021-01-01', 2),
    ('A', '2021-01-07', 2),
    ('A', '2021-01-10', 3),
    ('A', '2021-01-11', 3),
    ('A', '2021-01-11', 3),
    ('B', '2021-01-01', 2),
    ('B', '2021-01-02', 2),
    ('B', '2021-01-04', 1),
    ('B', '2021-01-11', 1),
    ('B', '2021-01-16', 3),
    ('B', '2021-02-01', 3),
    ('C', '2021-01-01', 3),
    ('C', '2021-01-01', 3),
    ('C', '2021-01-07', 3);

-- Create menu table
CREATE TABLE dannys_diner.menu (
    product_id INT,
    product_name VARCHAR(5),
    price INT
);

-- Insert data into menu table
INSERT INTO dannys_diner.menu (product_id, product_name, price)
VALUES
    (1, 'sushi', 10),
    (2, 'curry', 15),
    (3, 'ramen', 12);

-- Create members table
CREATE TABLE dannys_diner.members (
    customer_id CHAR(1),
    join_date DATE
);

-- Insert data into members table
INSERT INTO dannys_diner.members (customer_id, join_date)
VALUES
    ('A', '2021-01-07'),
    ('B', '2021-01-09');
```  
## Entity Relationship Diagram View
![image](https://github.com/nivisdata-analysis/SQL-Code/assets/171444078/1d6eea93-2b15-4a38-9c8f-35ae4f28f090)

## Case Study Questions:

**1. What is the total amount each customer spent at the restaurant?**
```
SELECT customer_id, SUM(price) AS total_amount
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
GROUP BY customer_id;
```

**2. How many days has each customer visited the restaurant?**
```
SELECT customer_id, COUNT(DISTINCT order_date) AS total_visit_days
FROM sales
GROUP BY customer_id;
```

**3. What was the first item from the menu purchased by each customer?**
```
SELECT customer_id, product_name
FROM  
	(SELECT customer_id, product_name,
	ROW_NUMBER() OVER(Partition BY customer_id ORDER BY order_date) as row_num
	FROM sales s
	JOIN menu m
	ON s.product_id = m.product_id) AS tem
WHERE row_num = 1;
```

**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**
```
SELECT TOP 1 product_name, COUNT(s.product_id) as Number_of_times_purchased
FROM sales s 
JOIN menu m
	ON s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY COUNT(s.product_id) DESC
```

**5. Which item was the most popular for each customer?**
```
WITH item_count AS (
	SELECT customer_id, product_name,
	COUNT(*) as order_count,
	DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(*) DESC) as den_rnk 
	FROM sales s
	JOIN menu m
	ON s.product_id = m.product_id
	GROUP BY customer_id, product_name
)

SELECT customer_id, product_name
FROM item_count
WHERE den_rnk = 1
ORDER BY customer_id ;
```

**6. Which item was purchased first by the customer after they became a member?**
```
With first_item AS (
	SELECT s.customer_id, product_id,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date) as item_no
	FROM sales s
	JOIN members m
		ON s.customer_id = m.customer_id
	WHERE order_date > join_date
)

SELECT customer_id, product_name
FROM first_item f
JOIN menu m
	ON f.product_id = m.product_id
WHERE item_no = 1;
```

**7. Which item was purchased just before the customer became a member?**
```
With before_mem AS (
	SELECT s.customer_id, product_id, Order_date,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC) as item_no
	FROM sales s
	JOIN members m
		ON s.customer_id = m.customer_id
	WHERE order_date < join_date
)

SELECT customer_id, product_name
FROM before_mem b
JOIN menu m
	ON b.product_id = m.product_id
WHERE item_no = 1;
```

**8. What is the total items and amount spent for each member before they became a member?**
```
SELECT s.customer_id, SUM(m.price) as total_amount, COUNT(s.product_id) AS total_items
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
JOIN members mem
	ON s.customer_id = mem.customer_id
WHERE s.order_date < mem.join_date 
GROUP BY s.customer_id;
```

**9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier how many points would each customer have?**
```
WITH points_cte AS(
	SELECT s.customer_id,
	CASE
		WHEN product_name = 'sushi' THEN m.price*10*2 ELSE m.price * 10
	END as points_amt
	FROM sales s
	JOIN menu m
		ON s.product_id = m.product_id
)
SELECT customer_id, SUM(points_amt) AS total_points
FROM points_cte 
GROUP BY customer_id;
```

**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi -      how many points do customer A and B have at the end of January?**
```
WITH added_points AS(
	SELECT s.customer_id, s.product_id, m.price, s.order_date,  
	CASE when s.product_id=1 THEN m.price*10*2  
	WHEN s.order_date BETWEEN mem.join_date AND DATEADD(DAY, 6, mem.join_date) THEN m.price*10*2  
	ELSE m.price*10 END AS points  
	FROM sales s  
	JOIN menu m  
	ON s.product_id=m.product_id  
	JOIN members mem  
	ON s.customer_id=mem.customer_id  
	WHERE MONTH(order_date)= 1
)  

SELECT customer_id, SUM(points) AS total_points  
FROM added_points 
GROUP BY customer_id  
ORDER BY customer_id;  
```
