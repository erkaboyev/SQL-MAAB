/* ================================================
		     Lesson 22: Aggregated Window Functions
   ================================================ */

--/* -------------------- EASY -------------------- */
--1) Running total sales per customer
SELECT
  sale_id, customer_id, customer_name, order_date, total_amount,
  SUM(total_amount) OVER (
    PARTITION BY customer_id
    ORDER BY order_date, sale_id
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_total_customer
FROM sales_data
ORDER BY customer_id, order_date, sale_id;


--2) Number of orders per product category 
SELECT
  product_category,
  COUNT(*) OVER (PARTITION BY product_category) AS orders_in_category
FROM sales_data
GROUP BY product_category, sale_id;  -- чтобы вывести по одной строке на категорию, можно заменить на DISTINCT


--3) Max total_amount per product category (оконно)
SELECT DISTINCT
  product_category,
  MAX(total_amount) OVER (PARTITION BY product_category) AS max_total_amount
FROM sales_data
ORDER BY product_category;


--4) Min unit_price per product category
SELECT DISTINCT
  product_category,
  MIN(unit_price) OVER (PARTITION BY product_category) AS min_unit_price
FROM sales_data
ORDER BY product_category;


--5) Moving average (3 days: prev, curr, next)
SELECT
  sale_id, order_date, total_amount,
  AVG(total_amount) OVER (
    ORDER BY order_date, sale_id
    ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
  ) AS movavg_3
FROM sales_data
ORDER BY order_date, sale_id;

--6) Total sales per region
SELECT DISTINCT
  region,
  SUM(total_amount) OVER (PARTITION BY region) AS region_total
FROM sales_data
ORDER BY region;

--7) Rank customers by total purchase
SELECT DISTINCT
  customer_id, customer_name,
  SUM(total_amount) OVER (PARTITION BY customer_id) AS customer_total,
  DENSE_RANK() OVER (
    ORDER BY SUM(total_amount) OVER (PARTITION BY customer_id) DESC
  ) AS spend_rank
FROM sales_data
ORDER BY spend_rank, customer_id;

--8) Diff current vs previous sale (по клиенту)
SELECT
  sale_id, customer_id, order_date, total_amount,
  total_amount - LAG(total_amount) OVER (
    PARTITION BY customer_id
    ORDER BY order_date, sale_id
  ) AS diff_from_prev
FROM sales_data
ORDER BY customer_id, order_date, sale_id;


--9) Top 3 most expensive products in each category
WITH base AS (
  SELECT DISTINCT product_category, product_name, unit_price
  FROM sales_data
),
r AS (
  SELECT *,
         DENSE_RANK() OVER (
           PARTITION BY product_category
           ORDER BY unit_price DESC, product_name
         ) AS rk
  FROM base
)
SELECT product_category, product_name, unit_price
FROM r
WHERE rk <= 3
ORDER BY product_category, unit_price DESC, product_name;


--10) Cumulative sum per region by order date
SELECT
  region, order_date, sale_id, total_amount,
  SUM(total_amount) OVER (
    PARTITION BY region
    ORDER BY order_date, sale_id
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS region_running_total
FROM sales_data
ORDER BY region, order_date, sale_id;


--/* -------------------- MEDIUM -------------------- */
--11) Cumulative revenue per product category
SELECT
  product_category, order_date, sale_id, total_amount,
  SUM(total_amount) OVER (
    PARTITION BY product_category
    ORDER BY order_date, sale_id
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS category_cum_revenue
FROM sales_data
ORDER BY product_category, order_date, sale_id;


--12) Sum of previous values → sample “ID”
-- For an arbitrary table with ascending IDs:
SELECT ID,
       SUM(ID) OVER (
         ORDER BY ID
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS SumPreValues
FROM (VALUES (1),(2),(3),(4),(5)) t(ID);


--13) OneColumn: cumulative sum (including current)
SELECT
  Value,
  SUM(Value) OVER (
    ORDER BY (SELECT 1)
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS [Sum of Previous]
FROM OneColumn;


--14) Customers who purchased in >1 product_category
WITH distinct_pairs AS (
  SELECT DISTINCT customer_id, customer_name, product_category
  FROM sales_data
),
cnt AS (
  SELECT *,
         COUNT(*) OVER (PARTITION BY customer_id) AS cat_cnt
  FROM distinct_pairs
)
SELECT DISTINCT customer_id, customer_name
FROM cnt
WHERE cat_cnt > 1
ORDER BY customer_id;


--15) Customers with above-average spending in their region
WITH totals AS (
  SELECT region, customer_id, customer_name,
         SUM(total_amount) AS cust_total
  FROM sales_data
  GROUP BY region, customer_id, customer_name
),
scored AS (
  SELECT *,
         AVG(cust_total) OVER (PARTITION BY region) AS region_avg_total
  FROM totals
)
SELECT region, customer_id, customer_name, cust_total, region_avg_total
FROM scored
WHERE cust_total > region_avg_total
ORDER BY region, cust_total DESC;


--16) Rank customers by total spending in the region (tai = overall rank)
WITH totals AS (
  SELECT region, customer_id, customer_name,
         SUM(total_amount) AS cust_total
  FROM sales_data
  GROUP BY region, customer_id, customer_name
)
SELECT
  region, customer_id, customer_name, cust_total,
  DENSE_RANK() OVER (PARTITION BY region ORDER BY cust_total DESC) AS spend_rank_in_region
FROM totals
ORDER BY region, spend_rank_in_region, customer_id;


--17) Running total per customer by order_date
SELECT
  customer_id, customer_name, order_date, sale_id, total_amount,
  SUM(total_amount) OVER (
    PARTITION BY customer_id
    ORDER BY order_date, sale_id
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cumulative_sales
FROM sales_data
ORDER BY customer_id, order_date, sale_id;


--18) Monthly sales growth rate vs previous month
WITH monthly AS (
  SELECT
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start,
    SUM(total_amount) AS month_sales
  FROM sales_data
  GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
),
x AS (
  SELECT month_start, month_sales,
         LAG(month_sales) OVER (ORDER BY month_start) AS prev_sales
  FROM monthly
)
SELECT month_start, month_sales, prev_sales,
       CASE WHEN prev_sales IS NULL OR prev_sales = 0 THEN NULL
            ELSE (month_sales - prev_sales) * 100.0 / prev_sales
       END AS growth_rate_pct
FROM x
ORDER BY month_start;


--19) Orders where total_amount > last order’s total_amount (per customer)
SELECT
  sale_id, customer_id, order_date, total_amount,
  LAG(total_amount) OVER (
    PARTITION BY customer_id
    ORDER BY order_date, sale_id
  ) AS last_amount
FROM sales_data
WHERE total_amount >
      LAG(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date, sale_id)
ORDER BY customer_id, order_date, sale_id;

 --/* -------------------- HARD -------------------- */

--20) Products with price above average product price
SELECT DISTINCT product_name, product_category, unit_price
FROM sales_data
WHERE unit_price > AVG(unit_price) OVER ()
ORDER BY unit_price DESC, product_name;


--21) MyData: display the sum (Val1+Val2) in the first row of the group
SELECT
  Id, Grp, Val1, Val2,
  CASE
    WHEN Id = MIN(Id) OVER (PARTITION BY Grp)
    THEN SUM(Val1 + Val2) OVER (PARTITION BY Grp)
    ELSE NULL
  END AS Tot
FROM MyData
ORDER BY Grp, Id;



--22) TheSumPuzzle: Cost — regular amount; Quantity — DISTINCT amount
SELECT
  ID AS Id,
  SUM(Cost)                AS Cost,
  SUM(DISTINCT Quantity)   AS Quantity
FROM TheSumPuzzle
GROUP BY ID
ORDER BY Id;


--23) Seats: find gaps (Gap Start / Gap End)
WITH s AS (
  SELECT SeatNumber,
         LAG(SeatNumber) OVER (ORDER BY SeatNumber) AS prev_seat
  FROM Seats
),
gaps AS (
  SELECT
    CASE WHEN prev_seat IS NULL THEN 1 ELSE prev_seat + 1 END AS GapStart,
    SeatNumber - 1 AS GapEnd
  FROM s
  WHERE prev_seat IS NULL OR SeatNumber - prev_seat > 1
)
SELECT GapStart, GapEnd
FROM gaps
WHERE GapStart <= GapEnd
ORDER BY GapStart;
