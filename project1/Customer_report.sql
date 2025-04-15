/*
============================================================================
Customer Report
============================================================================
Purpose:
	- This report consolidates key customer metrics and behaviors

Highlights:
	1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in months
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value 
		- average monthly spend
============================================================================
*/

CREATE VIEW gold.report_customers AS

/*===============================================================================================
1) Base Query : Retrieving core columns from the tables
===============================================================================================*/
WITH base_query AS (
    SELECT 
        f.order_number,
        f.product_key,
        f.order_date,
        f.quantity,
        f.sales_amount,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
    FROM 
        gold.fact_sales f
    JOIN 
        gold.dim_customers c ON f.customer_key = c.customer_key
    WHERE 
        f.order_date IS NOT NULL
),

/*===============================================================================================
2) Customer Aggregation : Summarizing key metrics at the customer level
===============================================================================================*/
customer_aggregation AS (
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT product_key) AS total_products,
        SUM(quantity) AS total_qty,
        SUM(sales_amount) AS total_sales,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM 
        base_query
    GROUP BY 
        customer_key, customer_number, customer_name, age
)

/*===============================================================================================
3) Final Query : Categorizing and enriching customer data
===============================================================================================*/
SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,

    CASE
        WHEN age < 20 THEN 'Below 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,

    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segments,

    total_orders,
    total_products,
    total_qty,
    total_sales,
    last_order_date,
    lifespan,
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,

    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders 
    END AS avg_order_value,

    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend

FROM 
    customer_aggregation;

