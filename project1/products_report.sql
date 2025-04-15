/*
=================================================================================================
Product Report
=================================================================================================
	Purpose:
		- This report consolidates key product metrics and behaviors.
	Highlights:
		1. Gathers essential fields such as product name, category, subcategory, and cost.
		2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
		3. Aggregates product-level metrics:
			- total orders
			- total sales
			- total quantity sold
			- total customers (unique)
			- lifespan (in months)
		4. Calculates valuable KPIs:
			- recency (months since last sale)
			- average order revenue (AOR)
			- average monthly revenue
=================================================================================================
*/

CREATE VIEW gold.report_products AS

/*===============================================================================================
1) Base Query : Retrieving core columns from sales and product dimension.
===============================================================================================*/
WITH base_query AS (
    SELECT 
        s.order_number,
        s.customer_key,
        s.order_date,
        s.sales_amount,
        s.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM 
        gold.dim_products p
    JOIN 
        gold.fact_sales s ON p.product_key = s.product_key
    WHERE 
        s.order_date IS NOT NULL
),

/*===============================================================================================
2) Product Aggregation Query : Summarizes key metrics at the product level.
===============================================================================================*/
product_aggregation AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        MAX(order_date) AS last_order_date,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM 
        base_query
    GROUP BY 
        product_key, product_name, category, subcategory, cost
)

/*===============================================================================================
3) Final Query : Bringing all key product-level metrics into a single view.
===============================================================================================*/
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_order_date,
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,

    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales BETWEEN 10000 AND 50000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    total_orders,
    total_quantity,
    total_customers,
    total_sales,
    avg_selling_price,
    lifespan,

    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue

FROM 
    product_aggregation;

