/* ==============================================================
   	Lesson-23: SQL Puzzle Questions with Input and Output Tables
   ============================================================== */

--Puzzle 1 — month with leading zero
SELECT
  Id,
  Dt,
  RIGHT('0' + CAST(MONTH(Dt) AS varchar(2)), 2) AS MonthPrefixedWithZero
FROM Dates
ORDER BY Id;


--Puzzle 2 — unique Id and sum of maximums by (Id,rID)
WITH mx AS (
  SELECT Id, rID, MAX(Vals) AS MaxVals
  FROM MyTabel
  GROUP BY Id, rID
)
SELECT
  COUNT(DISTINCT Id) AS Distinct_Ids,
  rID,
  SUM(MaxVals)       AS TotalOfMaxVals
FROM mx
GROUP BY rID;


--Puzzle 3 — strings between 6 and 10 characters long
SELECT Id, Vals
FROM TestFixLengths
WHERE LEN(Vals) BETWEEN 6 AND 10
ORDER BY Id, Vals;


--Puzzle 4 — Item with maximum Vals for each ID
WITH r AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY ID ORDER BY Vals DESC, Item) AS rn
  FROM TestMaximum
)
SELECT ID, Item, Vals
FROM r
WHERE rn = 1
ORDER BY ID;


--Puzzle 5 — sum of maximums for DetailedNumber within Id
WITH mx AS (
  SELECT Id, DetailedNumber, MAX(Vals) AS MaxV
  FROM SumOfMax
  GROUP BY Id, DetailedNumber
)
SELECT Id, SUM(MaxV) AS SumofMax
FROM mx
GROUP BY Id
ORDER BY Id;

--Puzzle 6 — difference a−b; replace zeros with empty
SELECT
  Id, a, b,
  CASE WHEN a - b = 0 THEN ''          -- empty line
       ELSE CAST(a - b AS varchar(20)) -- otherwise the differencev
  END AS OUTPUT
FROM TheZeroPuzzle
ORDER BY Id;


--Sales unit (units and windows)

-- Task 7 - Total revenue:
SELECT SUM(QuantitySold * UnitPrice) AS TotalRevenue
FROM Sales;


-- Task 8 - Average price per unit:
SELECT AVG(UnitPrice) AS AvgUnitPrice
FROM Sales;


-- Task 9 - Number of transactions:
SELECT COUNT(*) AS TxCount
FROM Sales;


-- Task 10 - Maximum number of items per transaction:
SELECT MAX(QuantitySold) AS MaxUnits
FROM Sales;


-- Task 11 - How many items were sold in each category:
SELECT Category, SUM(QuantitySold) AS UnitsSold
FROM Sales
GROUP BY Category
ORDER BY Category;


-- Task 12 - Revenue by region:
SELECT Region, SUM(QuantitySold * UnitPrice) AS RegionRevenue
FROM Sales
GROUP BY Region
ORDER BY Region;


-- Task 13 - Product with maximum total revenue:
WITH r AS (
  SELECT Product, SUM(QuantitySold * UnitPrice) AS Revenue
  FROM Sales
  GROUP BY Product
)
SELECT TOP (1) WITH TIES Product, Revenue
FROM r
ORDER BY Revenue DESC;


-- Task 14 - Running total of revenue by sale date:
SELECT
  SaleID, SaleDate,
  QuantitySold * UnitPrice AS Revenue,
  SUM(QuantitySold * UnitPrice) OVER (
    ORDER BY SaleDate, SaleID
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS RunningRevenue
FROM Sales
ORDER BY SaleDate, SaleID;



-- Task 15 - Share of category in total revenue:
WITH cat AS (
  SELECT Category, SUM(QuantitySold * UnitPrice) AS CatRevenue
  FROM Sales
  GROUP BY Category
),
tot AS (SELECT SUM(CatRevenue) AS TotalRev FROM cat)
SELECT
  c.Category,
  c.CatRevenue,
  CAST(c.CatRevenue * 100.0 / NULLIF(t.TotalRev, 0) AS decimal(10,2)) AS PctOfTotal
FROM cat c CROSS JOIN tot t
ORDER BY c.Category;


--Customers block (connections to Sales)

-- Task 17 - All sales with customer names:
SELECT
  s.SaleID, s.SaleDate, s.Product, s.Category, s.QuantitySold, s.UnitPrice, s.Region,
  c.CustomerID, c.CustomerName
FROM Sales AS s
JOIN Customers AS c
  ON c.CustomerID = s.CustomerID
ORDER BY s.SaleID;


-- Task 18 - Customers without purchases:
SELECT c.CustomerID, c.CustomerName
FROM Customers AS c
WHERE NOT EXISTS (
  SELECT 1 FROM Sales AS s WHERE s.CustomerID = c.CustomerID
)
ORDER BY c.CustomerID;


-- Task 19 - Revenue per customer:
SELECT
  c.CustomerID, c.CustomerName,
  SUM(s.QuantitySold * s.UnitPrice) AS CustomerRevenue
FROM Customers AS c
JOIN Sales     AS s ON s.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CustomerName
ORDER BY CustomerRevenue DESC, c.CustomerID;


-- Task 20 - Client(s) with maximum revenue:

WITH r AS (
  SELECT
    c.CustomerID, c.CustomerName,
    SUM(s.QuantitySold * s.UnitPrice) AS CustomerRevenue
  FROM Customers c
  JOIN Sales s ON s.CustomerID = c.CustomerID
  GROUP BY c.CustomerID, c.CustomerName
)
SELECT TOP (1) WITH TIES *
FROM r
ORDER BY CustomerRevenue DESC;
-- WITH TIES will return all leaders in the event of a tie. 


-- Task 21 - Total sales per customer:
SELECT
  c.CustomerID, c.CustomerName,
  COUNT(s.SaleID) AS SalesCount
FROM Customers c
LEFT JOIN Sales s ON s.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CustomerName
ORDER BY SalesCount DESC, c.CustomerID;

--Products block

-- Task 22 - Items that have been sold at least once:
SELECT DISTINCT p.ProductID, p.ProductName
FROM Products p
JOIN Sales    s ON s.Product = p.ProductName;


-- Task 23 - The most expensive item:
SELECT TOP (1) WITH TIES ProductID, ProductName, SellingPrice
FROM Products
ORDER BY SellingPrice DESC;


-- Task 24 - Products with prices above the average for their category:
SELECT p.ProductID, p.ProductName, p.Category, p.SellingPrice
FROM Products p
WHERE p.SellingPrice > (
  SELECT AVG(p2.SellingPrice)
  FROM Products p2
  WHERE p2.Category = p.Category
)
ORDER BY p.Category, p.SellingPrice DESC;
