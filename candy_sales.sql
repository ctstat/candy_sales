-- create tables
CREATE TABLE IF NOT EXISTS candy_sales (
	row_id INT,
	order_id VARCHAR(255),
	order_date DATE,
	ship_date DATE,
	ship_mode VARCHAR(255),
	customer_id INT,
	country_region VARCHAR(255),
	city VARCHAR(255),
	state_providence VARCHAR(255),
	postal_code VARCHAR(255),
	division VARCHAR(255),
	region VARCHAR(255),
	product_id VARCHAR(255),
	product_name VARCHAR(255),
	sales NUMERIC,
	units INT,
	gross_profit NUMERIC,
	cost NUMERIC
);


CREATE TABLE IF NOT EXISTS candy_products(
	division VARCHAR(255),
	product_name VARCHAR (255),
	factory VARCHAR(255),
	product_id VARCHAR(255),
	unit_price NUMERIC,
	unit_cost NUMERIC
);


-- import csv file
COPY candy_sales
FROM 'C:/Users/ctsta/Desktop/candy_distributor/candy_sales.csv'
WITH (FORMAT CSV, HEADER TRUE)

COPY candy_products
FROM 'C:/Users/ctsta/Desktop/candy_distributor/candy_products.csv'
WITH (FORMAT CSV, HEADER TRUE)

-- verify import csv
SELECT * 
FROM candy_sales
LIMIT 5;

SELECT * 
FROM candy_products
LIMIT 5;

-- check # of unique candy distributor (factory)
SELECT DISTINCT factory
FROM candy_products

-- count # of products of each factory makes
SELECT factory, COUNT(product_name) AS num_products
FROM candy_products
GROUP BY factory
ORDER BY num_products DESC

-- order & ship dates 
SELECT 
	MIN(order_date) AS min_order_date, 
	MAX(order_date) AS max_order_date,
	MIN(ship_date) AS min_ship_date,
	MAX(ship_date) AS max_ship_date
FROM candy_sales


-- Which factory has the most revenue across product?
WITH cte AS (SELECT *, (unit_price-unit_cost) AS unit_revenue
				FROM candy_products)

SELECT factory, ROUND(AVG(unit_revenue),2) AS avg_revenue_per_unit
FROM cte
GROUP BY factory
ORDER BY avg_revenue_per_unit DESC



-- Which product of each factory makes the most revenue?
WITH cte AS (SELECT *, (unit_price-unit_cost) AS unit_revenue
				FROM candy_products),
	 cte2 AS(SELECT cte.*,
		     DENSE_RANK() OVER(PARTITION BY factory ORDER BY unit_revenue DESC) AS revenue_rank
             FROM cte)

SELECT t2.factory, t2.product_name, t2.unit_revenue
FROM cte2 AS t2
WHERE t2.revenue_rank = 1
ORDER BY t2.unit_revenue DESC

-- join two tables & write into another table
WITH cte AS (SELECT t1.*, t2.factory, t2.unit_price, t2.unit_cost
FROM candy_sales AS t1
JOIN candy_products AS t2
ON t1.product_id = t2.product_id)

SELECT * 
INTO profit_cte
FROM cte

SELECT * 
FROM profit_cte
LIMIT 3

-- which factory makes the most avg_gross profit?
SELECT factory, ROUND(AVG(gross_profit),2) AS avg_profit
FROM profit_cte 
GROUP BY factory
ORDER BY avg_profit DESC

-- select orders between two dates
SELECT *
FROM profit_cte
WHERE order_date BETWEEN '2021-03-31' AND '2021-09-15'









