/*
=============================================================
Part-To-Whole
=============================================================
Script Purpose:
    This script analyze how an individual part (category total sales) is perfoming compared to the overall (overall sales).
	Allows to understand which category has the greatest impact on the business.
	
	( [Measure] / Total[Measure] ) * 100 By [Dimension]
		-(Sales/TotalSales) * 100 By Category
		-(Quantity/TotalQuantity) * 100 By Country
*/

USE [DataWarehouseAnalytics]
GO


-- Which categories contribute the most to overall sales?
WITH category_sales AS (
	SELECT
		category,
		SUM(sales_amount) AS total_sales
	FROM gold.fact_sales f
		INNER JOIN gold.dim_products p
		ON f.product_key = p.product_key
	GROUP BY category
)

SELECT
	category,
	total_sales,
	SUM(total_sales) OVER () AS overall_sales,
	CONCAT(ROUND((CAST (total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC


