/*
=============================================================
Cumulative Analysis
=============================================================
Script Purpose:
    This script calculates the total sales per mounth and the running total sales over 
	time to get a cumulative measure.
	Helps to undestand whether our business is growing or declining over time.
	
	SUM[Cumulative Measure] BY [Date Dimension].
		-Running Total Sales By Year
		-Moving Average Sales By Month
*/


USE [DataWarehouseAnalytics]
GO

-- Calculate the total sales per mounth
-- and the running total of sales over time [Cumulative Measure]
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM
(
	SELECT
		DATETRUNC(MONTH, order_date) AS order_date,
		SUM(sales_amount) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
) t




-- Calculate the total sales per mounth
-- and partition the running total of sales over each year [Cumulative Measure]
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (PARTITION BY DATETRUNC(YEAR, order_date) ORDER BY order_date) AS running_total_sales
FROM
(
	SELECT
		DATETRUNC(MONTH, order_date) AS order_date,
		SUM(sales_amount) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
) t




-- Calculate the total sales per mounth,
-- the running total of sales 
-- and moving average of price over time [Cumulative Measure]
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
	SELECT
		DATETRUNC(MONTH, order_date) AS order_date,
		SUM(sales_amount) AS total_sales,
		AVG(price) AS avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
) t




-- Calculate the total sales per mounth
-- and the running total of sales over time [Cumulative Measure]
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM
(
	SELECT
		DATETRUNC(MONTH, order_date) AS order_date,
		SUM(sales_amount) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
) t