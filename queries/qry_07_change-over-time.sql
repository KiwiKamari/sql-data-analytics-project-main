/*
=============================================================
Change-Over-Time
=============================================================
Script Purpose:
    This script shows how to make a querie that gives the changes in sales, customers and
	quantity of a a specific time in a order_date. 
	It's an analyze of how a measure evolves over time. Helps tracking trends,
	identifing seasonality in your data and to understand how your business is
	perfoming over time.
	
	SUM[Measure] BY [Date Dimension]
		-Total Sales By Year
		-Total Customers BY Month
*/

USE [DataWarehouseAnalytics]
GO

SELECT
	YEAR(order_date) AS order_year,
	SUM(sales_amount) AS total_Sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM [gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY YEAR (order_date)
ORDER BY order_year



SELECT
	MONTH(order_date) AS order_month,
	SUM(sales_amount) AS total_Sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM [gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY MONTH (order_date)
ORDER BY order_month




SELECT
	YEAR(order_date) AS order_year,
	MONTH (order_date) AS order_month,
	SUM(sales_amount) AS total_Sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM [gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY YEAR (order_date), MONTH (order_date)
ORDER BY order_year, order_month



SELECT
	DATETRUNC(YEAR, order_date) AS order_date,
	SUM(sales_amount) AS total_Sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM [gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR, order_date)
ORDER BY DATETRUNC(YEAR, order_date)



SELECT
	DATETRUNC(MONTH, order_date) AS order_date,
	SUM(sales_amount) AS total_Sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM [gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date)