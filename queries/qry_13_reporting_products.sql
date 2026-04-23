/*
=============================================================
Produucts Reporting
=============================================================
Script Purpose:
    This report consolidates key product metrics and behaviors
	
Highlights:
	1. Gathers essential fields such as product name, category, subcategory and cost.
	2. Aggregates product-level metrics:
		- total orders
		- total sales
		- total quantity sold
		- total customers (unique)
		- lifespan (in months)
	3. Segments products into categories (High-Performers, Mid-Range, Low-Performers) by revenue.
	4. Calculates valuable KPIs:
		- recency (months since last sale)
		- average order value (AOR)
		- average monthly revenue
*/

CREATE VIEW gold.report_products AS
WITH cte_product_info AS
(
	SELECT
		p.product_key,
		product_number,
		product_name,
		category,
		subcategory,
		cost,
		COUNT(DISTINCT f.order_number) AS total_orders,
		SUM(f.sales_amount) AS total_sales,
		SUM(f.quantity) AS quantity_sold,
		MIN(f.order_date) AS first_order,
		MAX(f.order_date) AS last_order,
		DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan
	FROM gold.dim_products p
		LEFT JOIN gold.fact_sales f
		ON p.product_key = f.product_key
	WHERE order_date IS NOT NULL
	GROUP BY 
		p.product_key,
		product_number,
		product_name,
		category,
		subcategory,
		cost	
), 
cte_product_segments AS (
	SELECT 
		product_key,
		CASE 
			WHEN lifespan > 12 AND total_sales > 2500 THEN 'High-Performers'
			WHEN lifespan > 12 AND total_sales < 2500 THEN 'Mid-Range'
			ELSE 'Low-Performers'
		END AS product_perfomance
	FROM cte_product_info
)

SELECT
	i.product_key
	product_number,
	product_name,
	category,
	subcategory,
	cost,
	total_orders,
	total_sales,
	quantity_sold,
	lifespan,
	product_perfomance,

	--Calculate KPI Recency by months
	DATEDIFF(MONTH, last_order, GETDATE()) AS recency,

	--Calculate KPI Average order value (AOV)
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE (total_sales / total_orders) 
	END AS avg_order_value, 

	--Calculate KPI Average monthly revenue
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE (total_sales / lifespan)
	END AS avg_monthly_revenue
FROM cte_product_info i
	INNER JOIN cte_product_segments s
	ON i.product_key = s.product_key
