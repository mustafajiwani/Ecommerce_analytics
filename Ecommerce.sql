CREATE DATABASE ecommerce_project;
USE ecommerce_project;

CREATE TABLE ecommerce_dataset (
	order_id INT,
    user_id INT,
    order_number INT,
    order_dow INT,
    order_hour_of_day INT,
    days_since_prior_order INT,
    product_id INT,
    add_to_cart_order INT,
    reordered INT,
    department_id INT,
    department VARCHAR(100),
    product_name VARCHAR(100)
    );

SELECT COUNT(*) FROM ecommerce_dataset;

-- User Behavior Analysis

-- Total Orders per User
SELECT user_id, COUNT(DISTINCT order_id) AS num_of_orders
FROM ecommerce_dataset
GROUP BY user_id
ORDER BY num_of_orders DESC;

-- Average Time Between Orders
SELECT user_id, AVG(days_since_prior_order) AS avg_days_between_orders
FROM ecommerce_dataset
WHERE days_since_prior_order IS NOT NULL
GROUP BY user_id;

-- Most Active Users
SELECT user_id, COUNT(*) AS total_products_purchased
FROM ecommerce_dataset
GROUP BY user_id
ORDER BY total_products_purchased DESC
LIMIT 10;

-- Product Analysis

-- Most Popular Products
SELECT product_name, COUNT(*) AS times_ordered
FROM ecommerce_dataset
GROUP BY product_name
ORDER BY times_ordered DESC
LIMIT 10;

-- Most Reordered Products
SELECT product_name, SUM(reordered) AS total_reorders
FROM ecommerce_dataset
GROUP BY product_name
ORDER BY total_reorders DESC
LIMIT 10;

-- Cart Behavior

-- Average Position in Cart
SELECT product_name, COUNT(*) AS total_orders, AVG(add_to_cart_order) AS avg_position
FROM ecommerce_dataset
GROUP BY product_name
ORDER BY avg_position;

-- First Item in Cart Frequency
SELECT product_name, COUNT(*) AS times_first_in_cart
FROM ecommerce_dataset
WHERE add_to_cart_order=1
GROUP BY product_name
ORDER BY times_first_in_cart DESC
LIMIT 10;

-- Temporal Patterns

-- Orders by Day of Week
SELECT order_dow, COUNT(DISTINCT order_id) AS total_orders
FROM ecommerce_dataset
GROUP BY order_dow
ORDER BY order_dow;

-- Orders by Hour
SELECT order_hour_of_day, COUNT(DISTINCT order_id) AS total_orders
FROM ecommerce_dataset
GROUP BY order_hour_of_day
ORDER BY order_hour_of_day;

-- Department-Level Analysis

-- Most Ordered Departments
SELECT department, COUNT(*) AS total_orders
FROM ecommerce_dataset
GROUP BY department
ORDER BY total_orders DESC;

-- Reorder Rate by Department
SELECT department, ROUND(SUM(reordered)/COUNT(*),2) AS reorder_rate
FROM ecommerce_dataset
GROUP BY department
ORDER BY reorder_rate DESC;

-- Reorder Patterns

-- Reorder Rate per Product
SELECT product_name, 
       COUNT(*) AS total_orders, 
       SUM(reordered) AS total_reorders, 
       ROUND(SUM(reordered)/COUNT(*),2) AS reorder_rate
FROM ecommerce_dataset
GROUP BY product_name
HAVING total_orders > 50
ORDER BY reorder_rate DESC
LIMIT 10;

-- First vs Repeat Order Analysis
SELECT reordered, COUNT(*) AS total_items
FROM ecommerce_dataset
GROUP BY reordered;

-- More complex:

-- User Reorder Tendencies by Department (Which users are most likely to reorder products in a specific department?)
SELECT 
    user_id, 
    department,
    COUNT(*) AS total_items,
    SUM(reordered) AS total_reorders,
    ROUND(SUM(reordered)/COUNT(*), 2) AS reorder_ratio
FROM ecommerce_dataset
GROUP BY user_id, department
HAVING COUNT(*) > 10
ORDER BY reorder_ratio DESC
LIMIT 20;

-- Department Activity by Day of Week
SELECT 
    department, 
    order_dow,
    COUNT(DISTINCT order_id) AS total_orders
FROM ecommerce_dataset
GROUP BY department, order_dow
ORDER BY department, order_dow;

-- Time Between Reorders for Users (How many days does it typically take users to reorder the same product?)
WITH reordered_data AS (
	SELECT 
		user_id,
		product_id,
		order_id,
		order_number,
		days_since_prior_order
	FROM ecommerce_dataset
	WHERE reordered=1
),
lagged_orders AS (
	SELECT
		user_id,
        	product_id,
        	order_number,
        	SUM(days_since_prior_order) OVER (
			PARTITION BY user_id, product_id
            		ORDER BY order_number
		) AS days_since_first_order
	FROM reordered_data
)
SELECT
	user_id,
	product_id,
	AVG(days_since_first_order) AS avg_days_between_reorders
FROM lagged_orders
GROUP BY user_id, product_id
HAVING COUNT(*) > 1
ORDER BY avg_days_between_reorders DESC
LIMIT 20;

-- User Segmentation Based on Order Habits (Group users into buckets based on average days between orders and average order size)
WITH user_metrics AS (	
	SELECT
		user_id, 
		AVG(days_since_prior_order) AS avg_days_between_orders, 
		COUNT(DISTINCT order_id) AS total_orders,
		COUNT(*)/COUNT(DISTINCT order_id) AS avg_items_per_order
	FROM ecommerce_dataset
	WHERE days_since_prior_order IS NOT NULL
	GROUP BY user_id
)
SELECT 
	*,
    	CASE
		WHEN avg_days_between_orders <= 5 AND avg_items_per_order >= 10 THEN 'Frequent & Bulk'
        	WHEN avg_days_between_orders > 5 AND avg_items_per_order < 5 THEN 'Occasional & Light'
        	ELSE 'Moderate User'
	END AS user_segment
FROM user_metrics;

-- Time-of-Day Purchase Preferences by Department (Analyze which departments are most active at different hours)
SELECT 
    department,
    order_hour_of_day,
    COUNT(*) AS total_orders
FROM ecommerce_dataset
GROUP BY department, order_hour_of_day
ORDER BY department, order_hour_of_day;

-- Product Pair Affinity Analysis (Identify which products are often bought together (i.e., in the same cart))
WITH filtered_orders AS (
    SELECT order_id
    FROM ecommerce_dataset
    GROUP BY order_id
    HAVING COUNT(*) <= 10
)							-- Limit to smaller orders (≤10 items) to reduce join complexity and improve performance
SELECT 
    a.product_name AS product_1,
    b.product_name AS product_2,
    COUNT(*) AS times_bought_together
FROM ecommerce_dataset a
JOIN ecommerce_dataset b 
    ON a.order_id = b.order_id 
    AND a.product_id < b.product_id
    AND a.order_id IN (SELECT order_id FROM filtered_orders)
GROUP BY a.product_name, b.product_name
HAVING COUNT(*) > 20
ORDER BY times_bought_together DESC
LIMIT 20;

-- User Churn Risk (Users' churn risk based on the gap between their last order and their average order gap)
WITH user_order_gaps AS (
    SELECT 
        user_id,
        MAX(order_number) AS last_order_number, -- Last order number placed by user
        AVG(days_since_prior_order) AS avg_order_gap -- User's typical ordering gap
    FROM ecommerce_dataset
    WHERE days_since_prior_order IS NOT NULL
    GROUP BY user_id
),
last_order_gaps AS (
    SELECT 
        t.user_id,
       MAX(t.days_since_prior_order) AS last_order_gap -- Take max to get single value per user
    FROM ecommerce_dataset t
    INNER JOIN (
        SELECT user_id, MAX(order_number) AS last_order_number
        FROM ecommerce_dataset
        GROUP BY user_id
    ) sub
    ON t.user_id = sub.user_id AND t.order_number = sub.last_order_number
    GROUP BY t.user_id -- Ensure one row per user
),
churn_risk AS (
    SELECT 
        u.user_id,
        u.avg_order_gap,
        l.last_order_gap,
        CASE 
            WHEN l.last_order_gap <= u.avg_order_gap * 1.2 THEN 'Low'
            WHEN l.last_order_gap <= u.avg_order_gap * 1.5 THEN 'Medium'
            ELSE 'High'
        END AS churn_risk_level
    FROM user_order_gaps u
    JOIN last_order_gaps l ON u.user_id = l.user_id
)
SELECT * FROM churn_risk
ORDER BY 
	CASE churn_risk_level
    WHEN 'High' THEN 3
    WHEN 'Medium' THEN 2
    WHEN 'Low' THEN 1
  END DESC;

-- Average Cart Size Over Time per User (tracking the change in average cart size of unique items per user by order number)
WITH cart_size_per_order AS (
	SELECT
		user_id,
		order_id,
        	order_number,
		COUNT(DISTINCT product_id) AS total_items
	FROM ecommerce_dataset
	GROUP BY user_id, order_id, order_number
)
SELECT 
	user_id,
    order_number,
    AVG(total_items) OVER (
			PARTITION BY user_id 
			ORDER BY order_number 
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
			) AS running_avg_cart_size
FROM cart_size_per_order
ORDER BY user_id, order_number;

