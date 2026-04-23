/*
=============================================================
Reporting
=============================================================
Script Purpose:
    This report consolidates key customers metrics and behaviors
	
Highlights:
	1. Gathers essential fields such as names, ages, and transaction details.
	2. Aggregates customer-level metrics:
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in months)
	3. Segments customers into categories (VIP, Regular, New)) and age groups.
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- average monthly spend
*/

USE [DataWarehouseAnalytics]
GO

CREATE VIEW gold.report_customers AS
-- 1. 
WITH cte_custome_info AS (
	SELECT
		c.customer_key,
		CONCAT(c.first_name, ' ', c.last_name) AS full_name,
		DATEDIFF(year, c.birthdate, GETDATE()) AS age,
		COUNT(DISTINCT f.order_number) AS total_orders,
		SUM(f.sales_amount) AS total_spending,
		COUNT(DISTINCT p.product_key) AS total_products,
		SUM(f.quantity) AS total_quantity,
		MIN(order_date) AS first_order,
		MAX(order_date) AS last_order,
		DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
	FROM gold.dim_customers c
		LEFT JOIN gold.fact_sales f
		ON c.customer_key = f.customer_key
		INNER JOIN gold.dim_products p
		ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
	GROUP BY
		c.customer_key,
		CONCAT(c.first_name, ' ', c.last_name),
		DATEDIFF(year, c.birthdate, GETDATE())
), -- 2.
cte_customer_segments AS (
	SELECT
		customer_key,
		CASE 
			WHEN lifespan > 12 AND total_spending >= 5000 THEN 'VIP'
			WHEN lifespan > 12 AND total_spending < 5000 THEN 'Regular'
			ELSE 'New'
		END AS behavior_group,
		CASE
			WHEN age BETWEEN 18 AND 24 THEN '18 - 24'
			WHEN age BETWEEN 25 AND 35 THEN '25 - 35'
			WHEN age BETWEEN 36 AND 50 THEN '36 - 50'
			ELSE 'Above 50'
		END AS age_group
	FROM cte_custome_info
)
SELECT
	i.customer_key,
	full_name,
	age,
	age_group,
	total_orders,
	total_spending,
	behavior_group,
	total_products,
	total_quantity,
	lifespan,

	-- Calculate recency (months since last order
	DATEDIFF(MONTH, last_order, GETDATE()) AS recency,

	-- Calculate average order value (AVO)
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE (total_spending / total_orders)
	END AS avg_order_value,

	-- Calculate average monthly spend
	CASE
		WHEN lifespan = 0 THEN total_spending
		ELSE (total_spending / lifespan)
	END AS avg_monthly_spend
FROM cte_custome_info i
	INNER JOIN cte_customer_segments s
	ON i.customer_key = s.customer_key