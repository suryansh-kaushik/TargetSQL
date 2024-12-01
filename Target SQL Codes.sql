-- Q1 Checking the Data

-- Customer Table
SELECT * FROM `business-case-study-sql.Target_dataset.customers` LIMIT 1000;

-- Geo Location Table
SELECT * FROM `business-case-study-sql.Target_dataset.geolocation` LIMIT 1000;

--Orders Item Table
SELECT * FROM `business-case-study-sql.Target_dataset.order_items` LIMIT 1000;

-- Orders Table
SELECT * FROM `business-case-study-sql.Target_dataset.orders` LIMIT 1000;

-- Payments
SELECT * FROM `business-case-study-sql.Target_dataset.payments` LIMIT 1000;

-- Products
SELECT * FROM `business-case-study-sql.Target_dataset.products` LIMIT 1000;

-- Sellers
SELECT * FROM `business-case-study-sql.Target_dataset.sellers` LIMIT 1000;


-- Q2 Time Period for which Data is given

SELECT MIN(order_purchase_timestamp) AS start_date,
MAX(order_purchase_timestamp) AS end_date
FROM `business-case-study-sql.Target_dataset.orders`;

-- Q3 Cities and States of customers ordered during the given period
    --A 
    SELECT DISTINCT customer_city, customer_state
    FROM `business-case-study-sql.Target_dataset.customers` AS c
    JOIN `business-case-study-sql.Target_dataset.orders` AS o
    ON c.customer_id = o.customer_id;

    --B 
    SELECT DISTINCT geolocation_city, geolocation_state
    FROM `business-case-study-sql.Target_dataset.geolocation`;
    --C
    SELECT DISTINCT customer_city, customer_state
    FROM `business-case-study-sql.Target_dataset.customers`;

-- `Q4 Is there a growing trend on e-commerce in Brazil? How can we describe a complete scenario? 
-- Can we see some seasonality with peaks at specific months? 
    --A
    SELECT
    EXTRACT(MONTH FROM order_purchase_timestamp) AS order_month,
    EXTRACT(YEAR FROM order_purchase_timestamp) AS order_year,
    COUNT(DISTINCT order_id) AS order_count,
    SUM(DISTINCT(order_id)) AS total_sales
    FROM `business-case-study-sql.Target_dataset.orders`
    GROUP BY order_month, order_year
    ORDER BY order_year, order_month;

    --B 
    SELECT
    EXTRACT(MONTH FROM order_purchase_timestamp) AS order_month,
    EXTRACT(YEAR FROM order_purchase_timestamp) AS order_year,
    COUNT(DISTINCT c.order_id) AS order_count,
    SUM(p.payment_value) AS total_sales
    FROM `business-case-study-sql.Target_dataset.orders` AS c
    JOIN `business-case-study-sql.Target_dataset.payments` AS p
    ON c.order_id = p.order_id
    GROUP BY
    order_month, order_year
    ORDER BY
    order_year, order_month;


--Q5 What time do Brazilian customers tend to buy (Dawn - 12am-6am, Morning 6am-12pm, Afternoon - 12 noon to 6pm,or Night 6-pm - 12am)?
    --A 
    SELECT
    CASE
    WHEN EXTRACT(hour FROM timestamp(order_purchase_timestamp)) BETWEEN 0 AND 6 THEN 'dawn'
    WHEN EXTRACT(hour FROM timestamp(order_purchase_timestamp)) BETWEEN 7 AND 12 THEN 'morning'
    WHEN EXTRACT(hour FROM timestamp(order_purchase_timestamp)) BETWEEN 13 AND 18 THEN 'afternoon'
    WHEN EXTRACT(hour FROM timestamp(order_purchase_timestamp)) BETWEEN 19 AND 23 THEN 'night'
    END AS time_of_day,
    COUNT(DISTINCT order_id) AS counter
    FROM `business-case-study-sql.Target_dataset.orders`
    GROUP BY 1
    ORDER BY 2 DESC;
    
    --B
    SELECT
    CASE
    WHEN TIME(order_purchase_timestamp) BETWEEN '00:00:00' AND '06:59:59' THEN 'Dawn'
    WHEN TIME(order_purchase_timestamp) BETWEEN '07:00:00' AND '12:59:59' THEN 'Morning'
    WHEN TIME(order_purchase_timestamp) BETWEEN '13:00:00' AND '18:59:59' THEN 'Afternoon'
    ELSE 'Night'
    END AS TIME_OF_PURCHASE,
    COUNT(DISTINCT order_id) AS num_orders
    FROM `business-case-study-sql.Target_dataset.orders`
    GROUP BY TIME_OF_PURCHASE
    order by num_orders;


--Q6 Evolution of E-commerce orders in the Brazil region:
    --A Get month on month orders by states
    SELECT
    EXTRACT(month FROM timestamp(order_purchase_timestamp)) AS month,
    g.geolocation_state,
    COUNT(1) AS num_orders
    FROM `business-case-study-sql.Target_dataset.orders` o
    INNER JOIN `business-case-study-sql.Target_dataset.customers` c
    ON o.customer_id = c.customer_id
    INNER JOIN `business-case-study-sql.Target_dataset.geolocation` g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
    GROUP BY g.geolocation_state, month
    ORDER BY geolocation_state DESC, month ASC;
    
    --B Distribution of customers across the states in Brazil

    SELECT g.geolocation_state, COUNT(DISTINCT (c.customer_unique_id)) AS num_customers
    FROM `business-case-study-sql.Target_dataset.customers` as c
    INNER JOIN `business-case-study-sql.Target_dataset.geolocation` as g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
    GROUP BY g.geolocation_state
    ORDER BY num_customers DESC;
    
--Q7 Payment type analysis:
    --A Month over Month count of orders for different payment types
    WITH
    cte_table AS 
    (
    SELECT
    EXTRACT(month FROM timestamp(o.order_purchase_timestamp)) AS month,
    EXTRACT(year FROM timestamp(o.order_purchase_timestamp)) AS year,
    (sum(price) / COUNT( distinct o.order_id)) AS price_per_order,
    (sum(freight_value) / COUNT(distinct o.order_id)) AS freight_per_order
    FROM `business-case-study-sql.Target_dataset.orders` o
    INNER JOIN `business-case-study-sql.Target_dataset.order_items` i
    ON o.order_id = i.order_id
    GROUP BY year, month
    )
    SELECT (price_per_order), (freight_per_order), month, year
    FROM cte_table
    order by payment_type, year asc, month asc ;

    -- B Count of orders based on the no. of payment installments

    SELECT
    payment_installments,
    COUNT(DISTINCT order_id) AS count_of_orders
    FROM
    `business-case-study-sql.Target_dataset.payments`
    GROUP BY
    payment_installments

