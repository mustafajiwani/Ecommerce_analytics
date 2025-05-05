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

