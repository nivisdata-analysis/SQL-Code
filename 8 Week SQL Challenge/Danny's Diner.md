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
