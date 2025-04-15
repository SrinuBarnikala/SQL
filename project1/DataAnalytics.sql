-- change over time analysis
select 
	year(order_date) as Year_, 
	month(order_date) as month_, 
	sum(sales_amount) as total_sales,
	COUNT(DISTINCT CUSTOMER_KEY) AS TOTAL_CUSTOMERS,
	SUM(QUANTITY) AS TOTAL_QUANTITY
from gold.fact_sales 
where order_date is not null
group by year(order_date ),month(order_date)
order by year(order_date),month(order_date)

-- running total sales analysis and moving average of sales
select 
	date,
	total_sales,
	sum(total_sales)over(partition by year(date) order by date) as running_sales,
	avg(avg_sales)over(partition by year(date) order by date) as moving_average 
from (
		select 
			datetrunc(month,order_date) as date,
			sum(sales_amount) as total_sales,
			avg(sales_amount) as avg_sales
		from gold.fact_sales
		where order_date is not null
		group by datetrunc(month,order_date)
	 ) t

-- Analyze the yearly performance of products by comparing each product's sales to 
-- both its average sales performance and the previous year's sales.
WITH yearly_sales AS (
    SELECT 
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS total_sales
    FROM 
        gold.fact_sales f
    JOIN 
        gold.dim_products p ON f.product_key = p.product_key
    WHERE 
        f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date), p.product_name
)

SELECT 
    order_year,
    product_name,
    total_sales AS current_sales,
    
    AVG(total_sales) OVER (PARTITION BY product_name) AS avg_sales,
    total_sales - AVG(total_sales) OVER (PARTITION BY product_name) AS diff_avg,
    
    CASE 
        WHEN total_sales - AVG(total_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
        WHEN total_sales - AVG(total_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
        ELSE 'Average'
    END AS diff_avg_flag,

    LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS PY_sales,
    total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_PY,

    CASE 
        WHEN total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increasing'
        WHEN total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decreasing'
        ELSE 'No Change'
    END AS diff_py_flag

FROM 
    yearly_sales;

-- Segment products into cost ranges and count how many products fall into each segment.
WITH cte AS (
    SELECT 
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM 
        gold.dim_products
)

SELECT 
    cost_range,
    COUNT(product_key) AS product_count
FROM 
    cte 
GROUP BY 
    cost_range 
ORDER BY 
    product_count DESC;


/*Group customers into three segments based on their spending behavior:
- VIP: Customers with at least 12 months of history and spending more than €5,000.
- Regular: Customers with at least 12 months of history but spending €5,000 or less
- New: Customers with a lifespan less than 12 months.

And find the total number of customers by each group
*/
WITH cte AS (
    SELECT 
        c.customer_key,
        MIN(f.order_date) AS min_date,
        MAX(f.order_date) AS latest_date,
        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS months,
        SUM(f.sales_amount) AS total_sales,
        CASE 
            WHEN DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) >= 12 
                 AND SUM(f.sales_amount) > 5000 THEN 'VIP'
            WHEN DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) >= 12 
                 AND SUM(f.sales_amount) <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_group
    FROM 
        gold.dim_customers c
    JOIN 
        gold.fact_sales f ON c.customer_key = f.customer_key
    GROUP BY 
        c.customer_key
)

SELECT 
    customer_group,
    COUNT(customer_key) AS customer_count
FROM 
    cte 
GROUP BY 
    customer_group
ORDER BY 
    customer_count;











