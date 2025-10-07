/* ================================================
		               Lesson-20: Practice
   ================================================ */

--1) Customers with at least one purchase in March 2024 (use EXISTS)
SELECT DISTINCT s.CustomerName
FROM #Sales AS s
WHERE EXISTS (
    SELECT 1
    FROM #Sales AS m
    WHERE m.CustomerName = s.CustomerName
      AND m.SaleDate >= '2024-03-01'
      AND m.SaleDate <  '2024-04-01'
)
ORDER BY s.CustomerName;
--EXISTS checks whether there are strings that satisfy the subquery.

--2) Product with the highest total revenue (subquery)
WITH Totals AS (
  SELECT Product, SUM(Quantity * Price) AS TotalRevenue
  FROM #Sales
  GROUP BY Product
)
SELECT Product, TotalRevenue
FROM Totals
WHERE TotalRevenue = (SELECT MAX(TotalRevenue) FROM Totals);

--3) Second highest sale amount (subquery)
WITH A AS (
  SELECT SaleID, CAST(Quantity * Price AS DECIMAL(18,2)) AS Amount
  FROM #Sales
)
SELECT MAX(Amount) AS SecondHighestAmount
FROM A
WHERE Amount < (SELECT MAX(Amount) FROM A);

--4) total quantity per month (subquery)
-- Month = first day of the month
WITH Months AS (
  SELECT DISTINCT DATEFROMPARTS(YEAR(SaleDate), MONTH(SaleDate), 1) AS MonthStart
  FROM #Sales
)
SELECT m.MonthStart,
       (SELECT SUM(s2.Quantity)
        FROM #Sales AS s2
        WHERE DATEFROMPARTS(YEAR(s2.SaleDate), MONTH(s2.SaleDate), 1) = m.MonthStart
       ) AS TotalQuantity
FROM Months AS m
ORDER BY m.MonthStart;

--5) Customers who bought same products as another customer (use EXISTS)
SELECT DISTINCT s1.CustomerName
FROM #Sales AS s1
WHERE EXISTS (
  SELECT 1
  FROM #Sales AS s2
  WHERE s2.Product = s1.Product
    AND s2.CustomerName <> s1.CustomerName
)
ORDER BY s1.CustomerName;

--6) Fruits — counts per person (Apple / Orange / Banana)
SELECT
  f.Name,
  SUM(CASE WHEN f.Fruit = 'Apple'  THEN 1 ELSE 0 END)  AS Apple,
  SUM(CASE WHEN f.Fruit = 'Orange' THEN 1 ELSE 0 END)  AS Orange,
  SUM(CASE WHEN f.Fruit = 'Banana' THEN 1 ELSE 0 END)  AS Banana
FROM Fruits AS f
GROUP BY f.Name
ORDER BY f.Name;

--7) Family — all older/younger pairs (транзитивное замыкание)
WITH R AS (
  SELECT ParentId, ChildID
  FROM Family
  UNION ALL
  SELECT r.ParentId, f.ChildID
  FROM R
  JOIN Family AS f ON f.ParentId = R.ChildID
)
SELECT DISTINCT
  ParentId AS PID,
  ChildID  AS CHID
FROM R
ORDER BY PID, CHID
OPTION (MAXRECURSION 0);

--8) Orders to TX only for customers who had a delivery to CA
SELECT o.CustomerID, o.OrderID, o.DeliveryState, o.Amount
FROM #Orders AS o
WHERE o.DeliveryState = 'TX'
  AND EXISTS (
    SELECT 1
    FROM #Orders AS i
    WHERE i.CustomerID = o.CustomerID
      AND i.DeliveryState = 'CA'
  )
ORDER BY o.CustomerID, o.OrderID;

--9) Fill missing resident fullname from address (name=...)
-- Fill in fullname with the value from the fragment name=... if fullname is empty/NULL
UPDATE r
SET fullname = SUBSTRING(r.address, pos.name_pos + 5, nxt.next_space - (pos.name_pos + 5))
FROM #residents AS r
CROSS APPLY (SELECT CHARINDEX('name=', r.address) AS name_pos) AS pos
CROSS APPLY (SELECT CHARINDEX(' ', r.address + ' ', CASE WHEN pos.name_pos > 0 THEN pos.name_pos + 5 ELSE 1 END) AS next_space) AS nxt
WHERE (r.fullname IS NULL OR r.fullname = '')
  AND pos.name_pos > 0;

-- Проверка
SELECT * FROM #residents ORDER BY resid;

--10) Routes Tashkent → Khorezm (cheapest & most expensive)
WITH Paths AS (
  -- starting from Tashkent
  SELECT
      r.RouteID,
      r.DepartureCity,
      r.ArrivalCity,
      CAST('Tashkent' + ' - ' + r.ArrivalCity AS VARCHAR(200)) AS RouteText,
      CAST(r.Cost AS MONEY) AS TotalCost
  FROM #Routes AS r
  WHERE r.DepartureCity = 'Tashkent'

  UNION ALL
  -- continue to any cities, avoiding cycles
  SELECT
      n.RouteID,
      n.DepartureCity,
      n.ArrivalCity,
      CAST(p.RouteText + ' - ' + n.ArrivalCity AS VARCHAR(200)) AS RouteText,
      p.TotalCost + n.Cost AS TotalCost
  FROM Paths AS p
  JOIN #Routes AS n
    ON n.DepartureCity = p.ArrivalCity
  WHERE CHARINDEX(' - ' + n.ArrivalCity + ' - ', p.RouteText + ' - ') = 0
)
, Finished AS (
  SELECT RouteText AS [Route], TotalCost AS Cost
  FROM Paths
  WHERE ArrivalCity = 'Khorezm'
)
-- two lines: minimum and maximum cost
SELECT TOP (1) [Route], Cost
FROM Finished
ORDER BY Cost ASC
UNION ALL
SELECT TOP (1) [Route], Cost
FROM Finished
ORDER BY Cost DESC;

--11) Rank products by insertion blocks
WITH Blocks AS (
  SELECT
    rp.ID,
    rp.Vals,
    SUM(CASE WHEN rp.Vals = 'Product' THEN 1 ELSE 0 END)
      OVER (ORDER BY rp.ID ROWS UNBOUNDED PRECEDING) AS BlockNo
  FROM #RankingPuzzle AS rp
)
SELECT
  ID, Vals,
  BlockNo,
  CASE WHEN Vals = 'Product'
       THEN 0
       ELSE ROW_NUMBER() OVER (PARTITION BY BlockNo ORDER BY ID)
  END AS RankInBlock
FROM Blocks
ORDER BY ID;

--12) Employees with sales above department average
WITH S AS (
  SELECT *,
         AVG(SalesAmount) OVER (PARTITION BY Department) AS DeptAvg
  FROM #EmployeeSales
)
SELECT EmployeeName, Department, SalesAmount, SalesMonth, SalesYear
FROM S
WHERE SalesAmount > DeptAvg
ORDER BY Department, SalesYear, SalesMonth, EmployeeName;

--13) Employees with the highest sales in any given month (use EXISTS)
WITH Mx AS (
  SELECT SalesYear, SalesMonth, MAX(SalesAmount) AS MaxAmt
  FROM #EmployeeSales
  GROUP BY SalesYear, SalesMonth
)
SELECT e.EmployeeName, e.SalesAmount, e.SalesMonth, e.SalesYear
FROM #EmployeeSales AS e
WHERE EXISTS (
  SELECT 1
  FROM Mx
  WHERE Mx.SalesYear  = e.SalesYear
    AND Mx.SalesMonth = e.SalesMonth
    AND Mx.MaxAmt     = e.SalesAmount
)
ORDER BY e.SalesYear, e.SalesMonth, e.EmployeeName;

--14) Employees who made sales in every month (use NOT EXISTS)
WITH AllMonths AS (
  SELECT DISTINCT SalesYear, SalesMonth FROM #EmployeeSales
)
SELECT DISTINCT e.EmployeeName
FROM #EmployeeSales AS e
WHERE NOT EXISTS (
  SELECT 1
  FROM AllMonths AS m
  WHERE NOT EXISTS (
    SELECT 1
    FROM #EmployeeSales AS x
    WHERE x.EmployeeName = e.EmployeeName
      AND x.SalesYear    = m.SalesYear
      AND x.SalesMonth   = m.SalesMonth
  )
)
ORDER BY e.EmployeeName;

--15) Names of products more expensive than average price
SELECT Name
FROM Products
WHERE Price > (SELECT AVG(Price) FROM Products)
ORDER BY Name;

--16) roducts with stock < highest stock
SELECT ProductID, Name, Category, Price, Stock
FROM Products
WHERE Stock < (SELECT MAX(Stock) FROM Products)
ORDER BY Stock, ProductID;

--17) Names of products in the same category as 'Laptop'
SELECT Name
FROM Products
WHERE Category = (SELECT Category FROM Products WHERE Name = 'Laptop')
ORDER BY Name;

--18) Products with price greater than the lowest in Electronics
SELECT ProductID, Name, Category, Price, Stock
FROM Products
WHERE Price > (
    SELECT MIN(Price) FROM Products WHERE Category = 'Electronics'
)
ORDER BY Price, ProductID;

--19) Products priced above their category average
SELECT p.ProductID, p.Name, p.Category, p.Price, p.Stock
FROM Products AS p
WHERE p.Price > (
  SELECT AVG(p2.Price) FROM Products AS p2 WHERE p2.Category = p.Category
)
ORDER BY p.Category, p.Price DESC, p.ProductID;

--20) Products that have been ordered at least once
SELECT DISTINCT p.ProductID, p.Name
FROM Products AS p
WHERE EXISTS (
  SELECT 1 FROM Orders AS o WHERE o.ProductID = p.ProductID
)
ORDER BY p.ProductID;

--21) Names of products whose total ordered qty > average total ordered qty
WITH Totals AS (
  SELECT o.ProductID, SUM(o.Quantity) AS TotalQty
  FROM Orders AS o
  GROUP BY o.ProductID
),
AvgQty AS (
  SELECT AVG(CAST(TotalQty AS FLOAT)) AS AvgTotal FROM Totals
)
SELECT p.Name
FROM Products AS p
JOIN Totals  AS t ON t.ProductID = p.ProductID
CROSS JOIN AvgQty AS a
WHERE t.TotalQty > a.AvgTotal
ORDER BY p.Name;

--22) Products that have never been ordered
SELECT p.ProductID, p.Name
FROM Products AS p
WHERE NOT EXISTS (SELECT 1 FROM Orders AS o WHERE o.ProductID = p.ProductID)
ORDER BY p.ProductID;

--23) Product with the highest total quantity ordered
WITH T AS (
  SELECT o.ProductID, SUM(o.Quantity) AS TotalQty
  FROM Orders AS o
  GROUP BY o.ProductID
)
SELECT TOP (1) WITH TIES
       p.ProductID, p.Name, T.TotalQty
FROM T
JOIN Products AS p ON p.ProductID = T.ProductID
ORDER BY T.TotalQty DESC, p.ProductID;
