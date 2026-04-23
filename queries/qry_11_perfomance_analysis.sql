/*
=============================================================
Perfomance Analysis
=============================================================
Script Purpose:
    This script compares the current value to a target value.
	Helps measure success and compare perfomance.
	
	Current[Measure] - Target[Measure]
		-Current Sales - Average Sales
		-Current Year Sales - Previous Year Sales --> YoY Analysis
*/

USE [DataWarehouseAnalytics]
GO


-- Analyze the yearly perfomance of each product by comparing their sales
-- to both the average sales perfomance of the product and the previous year's sales
WITH cte_yearly_product_sales AS (
	SELECT
		YEAR(f.order_date) AS order_date,
		p.product_name,
		SUM(f.sales_amount) AS current_sales
	FROM gold.fact_sales f
		INNER JOIN gold.dim_products p
		ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
	GROUP BY 
		YEAR(f.order_date),
		p.product_name
),
cte_py_avg_sales AS (
	SELECT
		order_date,
		product_name,
		current_sales,
		LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_date) AS previous_sales,
		current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_date) AS diff_sales,
		AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
		current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg
	FROM cte_yearly_product_sales
)
SELECT
	order_date,
	product_name,
	current_sales,
	previous_sales,
	diff_sales,
	CASE
		WHEN diff_sales > 0 THEN 'Increase'
		WHEN diff_sales < 0 THEN 'Decrease'
		ELSE 'No Change'
	END AS sales_change,
	avg_sales,
	diff_avg,
	CASE
		WHEN diff_avg > 0 THEN 'Above Avg'
		WHEN diff_avg < 0 THEN 'Below Avg'
		ELSE 'Avg'
	END AS avg_change
FROM cte_py_avg_sales
ORDER BY product_name, order_date

