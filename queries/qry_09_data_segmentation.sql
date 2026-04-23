/*
=============================================================
Data Segmentation
=============================================================
Script Purpose:
    This script segment products into cost ranges and count how many products fall into each segment.
	Group/Categorize/Segment the data based on a specific range to understand the correlation between two measures.
	
	[Measure] By [Measure]
		-Total Products By Sales range
		-Total Customers By Age
*/

/*
	Group customers into segments based on their spending behavior
		- VIP: Customers with at least 6 months of history and spending more than $5,000
		- Regular: Customers with at least 6 months of history but spending $5000 or less
		- New: Customers with a lifespan less than 12 months
	And find the total number of customers by each group
*/
WITH customer_behavior AS (
	SELECT
		c.customer_key,
		SUM(f.sales_amount) AS total_spending,
		MIN(f.order_date) AS first_order,
		MAX(f.order_date) AS last_order
	FROM gold.dim_customers c
		LEFT JOIN gold.fact_sales f
		ON c.customer_key = f.customer_key
	GROUP BY c.customer_key
), 
customer_segment AS (
	SELECT
		customer_key,
		CASE	
			WHEN DATEDIFF(MONTH, first_order, last_order) >= 12 AND total_spending > 5000 THEN 'VIP'
			WHEN DATEDIFF(MONTH, first_order, last_order) >= 12 AND total_spending < 5000 THEN 'Regular'
			ELSE 'New'
		END AS customer_group
	FROM customer_behavior
)
SELECT
	customer_group,
	COUNT(customer_group) AS total_customers
FROM customer_segment
GROUP BY customer_group