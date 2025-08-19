/* ================================================
				   Lesson-8: Practice
   ================================================ */

--/* -------------------- EASY -------------------- */

--1) Number of products in each category (Products)
SELECT Category, COUNT(*) AS ProductCount
FROM Products
GROUP BY Category
ORDER BY Category;

--2) Average price in the ‘Electronics’ category (Products)
SELECT AVG(Price) AS AvgPrice_Electronics
FROM Products
WHERE Category = 'Electronics';

--3) Customers from cities beginning with the letter ‘L’ (Customers)
SELECT *
FROM Customers
WHERE City LIKE 'L%';

--4) Names of products ending in ‘er’ (Products)
SELECT ProductName
FROM Products
WHERE ProductName LIKE '%er';

--5) Customers from countries ending in ‘A’ (Customers)
SELECT *
FROM Customers
WHERE Country LIKE '%A';

--6) Highest price among all products
SELECT MAX(Price) AS MaxPrice
FROM Products;

--7) Mark the balance: ‘Low Stock’ if < 30, otherwise ‘Sufficient’ (Products)
SELECT ProductID, ProductName, StockQuantity,
       CASE WHEN StockQuantity < 30 THEN 'Low Stock'
            ELSE 'Sufficient'
       END AS StockLabel
FROM Products
ORDER BY ProductID;

--8) Number of customers by country (Customers)
SELECT Country, COUNT(*) AS CustomerCount
FROM Customers
GROUP BY Country
ORDER BY Country;

--9) Min/max ordered quantity (Orders)
SELECT MIN(Quantity) AS MinQty, MAX(Quantity) AS MaxQty
FROM Orders;

--/* -------------------- MEDIUM -------------------- */
--10) Customers with orders in January 2023 who do not have invoices
-- Option “no invoice for January 2023”:
SELECT DISTINCT o.CustomerID
FROM Orders AS o
WHERE o.OrderDate >= '2023-01-01' AND o.OrderDate < '2023-02-01'
  AND NOT EXISTS (
      SELECT 1
      FROM Invoices AS i
      WHERE i.CustomerID = o.CustomerID
        AND i.InvoiceDate >= '2023-01-01' AND i.InvoiceDate < '2023-02-01'
  )
ORDER BY o.CustomerID;

--Option “no invoice at all”:
SELECT DISTINCT o.CustomerID
FROM Orders AS o
WHERE o.OrderDate >= '2023-01-01' AND o.OrderDate < '2023-02-01'
EXCEPT
SELECT DISTINCT i.CustomerID
FROM Invoices AS i;

-- Alternative approach using LEFT JOIN
SELECT DISTINCT o.CustomerID
FROM Orders o
LEFT JOIN Invoices i 
    ON o.CustomerID = i.CustomerID 
    AND i.InvoiceDate >= '2023-01-01' 
    AND i.InvoiceDate < '2023-02-01'
WHERE o.OrderDate >= '2023-01-01' 
    AND o.OrderDate < '2023-02-01'
    AND i.InvoiceID IS NULL
ORDER BY o.CustomerID;


--11) Merge product names from Products and Products_Discounted, with duplicates
SELECT ProductName FROM Products
UNION ALL
SELECT ProductName FROM Products_Discounted;

--12) The same, but without duplicates
SELECT ProductName FROM Products
UNION
SELECT ProductName FROM Products_Discounted;

--13) Average order size by year (Orders)
SELECT YEAR(OrderDate) AS OrderYear,
       AVG(TotalAmount) AS AvgOrderAmount
FROM Orders
GROUP BY YEAR(OrderDate)
ORDER BY OrderYear;

--14) Price groups (Products): Low (<100), Mid (100–500), High (>500)
SELECT ProductName,
       CASE
         WHEN Price < 100 THEN 'Low'
         WHEN Price <= 500 THEN 'Mid'
         ELSE 'High'
       END AS PriceGroup
FROM Products
ORDER BY ProductName;

--or with explicitly specified ranges
SELECT ProductName,
       CASE
         WHEN Price < 100 THEN 'Low'
         WHEN Price >= 100 AND Price <= 500 THEN 'Mid'
         WHEN Price > 500 THEN 'High'
       END AS PriceGroup
FROM Products
ORDER BY ProductName;

--15) PIVOT by year with preservation in a new table Population_Each_Year**
SELECT district_id,
       district_name,
       [2012], [2013]
INTO Population_Each_Year
FROM (
    SELECT district_id, district_name, population, [year]
    FROM city_population
) AS src
PIVOT (
    SUM(population) FOR [year] IN ([2012],[2013])
) AS p;

--16) Total sales by product (Sales)
SELECT ProductID, SUM(SaleAmount) AS TotalSales
FROM Sales
GROUP BY ProductID
ORDER BY ProductID;

--17) Search for products with ‘oo’ in the title (Products)
SELECT ProductName
FROM Products
WHERE ProductName LIKE '%oo%';

--18) PIVOT by city (Bektemir, Chilonzor, Yakkasaroy) into new Population_Each_City
SELECT [year] AS [Year],
       [Bektemir], [Chilonzor], [Mirobod], [Yashnobod], [Yakkasaroy]
INTO Population_Each_City
FROM (
    SELECT [year], district_name, population
    FROM city_population
) AS src
PIVOT (
    SUM(population) FOR district_name IN ([Bektemir],[Chilonzor],[Mirobod],[Yashnobod],[Yakkasaroy])
) AS p
ORDER BY [Year];

--/* -------------------- HARD -------------------- */

--19) Top 3 customers by total invoice amounts (Invoices)
SELECT TOP (3) WITH TIES
       CustomerID,
       SUM(TotalAmount) AS TotalSpent
FROM Invoices
GROUP BY CustomerID
ORDER BY TotalSpent DESC;

--20) Convert Population_Each_Year back to the “narrow” format (like city_population)
SELECT
    district_id,
    district_name,
    [year]       AS [year],
    population   AS population
FROM Population_Each_Year
UNPIVOT (
    population FOR [year] IN ([2012],[2013])
) AS u
ORDER BY district_id, district_name, [year];

--21) How many times each product was sold (Products × Sales)
--— Only products with sales:
SELECT p.ProductName,
       COUNT(s.SaleID) AS TimesSold
FROM Sales AS s
JOIN Products AS p ON p.ProductID = s.ProductID
GROUP BY p.ProductName
ORDER BY TimesSold DESC, p.ProductName;

--Including goods without sales (zero):
SELECT p.ProductName,
       COUNT(s.SaleID) AS TimesSold
FROM Products AS p
LEFT JOIN Sales AS s ON s.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TimesSold DESC, p.ProductName;

-- Extended version with additional analytics
SELECT 
    p.ProductName,
    COUNT(s.SaleID) AS TimesSold,
    COALESCE(SUM(s.SaleAmount), 0) AS TotalRevenue,
    COALESCE(AVG(s.SaleAmount), 0) AS AvgSaleAmount
FROM Products p
LEFT JOIN Sales s ON s.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TimesSold DESC, TotalRevenue DESC, p.ProductName;

--22) Convert Population_Each_City back to the “narrow” format (part of city_population)
SELECT
    [Year]       AS [year],
    district_name,
    population
FROM Population_Each_City
UNPIVOT (
    population FOR district_name IN ([Bektemir],[Chilonzor],[Mirobod],[Yashnobod],[Yakkasaroy])
) AS u
ORDER BY [Year], district_name;


