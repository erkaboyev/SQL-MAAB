/* ================================================
         Lesson-16: CTEs and Derived Tables
   ================================================ */


--/* -------------------- EASY -------------------- */

--1) Numbers 1–1000 (рекурсивный CTE)
;WITH Numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM Numbers
    WHERE n < 1000
)
SELECT n
FROM Numbers
OPTION (MAXRECURSION 1000);

--2) Total Sales per Employee (derived table)
SELECT e.EmployeeID, e.FirstName, e.LastName, s.TotalSales
FROM Employees AS e
JOIN (
    SELECT EmployeeID, SUM(SalesAmount) AS TotalSales
    FROM Sales
    GROUP BY EmployeeID
) AS s
  ON s.EmployeeID = e.EmployeeID
ORDER BY s.TotalSales DESC;

--3) Average Salary (CTE)
;WITH AvgSalary AS (
    SELECT AVG(Salary) AS AvgSal FROM Employees
)
SELECT e.EmployeeID, e.FirstName, e.LastName, e.Salary, a.AvgSal
FROM Employees AS e
CROSS JOIN AvgSalary AS a
ORDER BY e.Salary DESC;

--4) Highest Sales per Product (derived table)
SELECT p.ProductName, s.MaxSale
FROM Products AS p
JOIN (
    SELECT ProductID, MAX(SalesAmount) AS MaxSale
    FROM Sales
    GROUP BY ProductID
) AS s
  ON s.ProductID = p.ProductID
ORDER BY s.MaxSale DESC;

--5) Doubling until < 1,000,000 (recursive CTE)
;WITH Doubles AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n * 2
    FROM Doubles
    WHERE n * 2 < 1000000
)
SELECT n
FROM Doubles;

--6) Employees with >5 sales (CTE)
;WITH SalesCount AS (
    SELECT EmployeeID, COUNT(*) AS SalesCount
    FROM Sales
    GROUP BY EmployeeID
)
SELECT e.EmployeeID, e.FirstName, e.LastName, s.SalesCount
FROM Employees AS e
JOIN SalesCount AS s ON s.EmployeeID = e.EmployeeID
WHERE s.SalesCount > 5
ORDER BY s.SalesCount DESC;

--7) Products with total sales > $500 (CTE)
;WITH ProductSales AS (
    SELECT ProductID, SUM(SalesAmount) AS TotalSales
    FROM Sales
    GROUP BY ProductID
)
SELECT p.ProductName, ps.TotalSales
FROM Products AS p
JOIN ProductSales AS ps ON ps.ProductID = p.ProductID
WHERE ps.TotalSales > 500
ORDER BY ps.TotalSales DESC;

--8) Employees above average salary (CTE)
;WITH AvgSal AS (
    SELECT AVG(Salary) AS AvgSalary FROM Employees
)
SELECT e.EmployeeID, e.FirstName, e.LastName, e.Salary
FROM Employees AS e, AvgSal AS a
WHERE e.Salary > a.AvgSalary
ORDER BY e.Salary DESC;


--/* -------------------- MEDIUM -------------------- */

--9) Top 5 employees by number of orders (derived table)
SELECT TOP 5 e.EmployeeID, e.FirstName, e.LastName, s.OrderCount
FROM Employees AS e
JOIN (
    SELECT EmployeeID, COUNT(*) AS OrderCount
    FROM Sales
    GROUP BY EmployeeID
) AS s ON s.EmployeeID = e.EmployeeID
ORDER BY s.OrderCount DESC;

--10) Sales per Product Category (derived table)
SELECT p.CategoryID, SUM(s.SalesAmount) AS TotalSales
FROM Products AS p
JOIN Sales AS s ON s.ProductID = p.ProductID
GROUP BY p.CategoryID
ORDER BY TotalSales DESC;

--11) Factorial for each Number (recursive)
;WITH Factorial AS (
    SELECT Number, Number AS CurrentValue, 1 AS Factorial
    FROM Numbers1
    UNION ALL
    SELECT f.Number, f.CurrentValue - 1, f.Factorial * f.CurrentValue
    FROM Factorial AS f
    WHERE f.CurrentValue > 1
)
SELECT Number, MAX(Factorial) AS Factorial
FROM Factorial
GROUP BY Number
ORDER BY Number;

--12) Split string into rows (recursive)
;WITH SplitCTE AS (
    SELECT Id, 1 AS Position, SUBSTRING(String, 1, 1) AS CharPart
    FROM Example
    UNION ALL
    SELECT e.Id, s.Position + 1, SUBSTRING(e.String, s.Position + 1, 1)
    FROM Example AS e
    JOIN SplitCTE AS s ON e.Id = s.Id
    WHERE s.Position < LEN(e.String)
)
SELECT Id, CharPart
FROM SplitCTE
ORDER BY Id, Position
OPTION (MAXRECURSION 1000);

--13) Sales difference between months (CTE)
;WITH MonthlySales AS (
    SELECT 
        YEAR(SaleDate) AS Yr,
        MONTH(SaleDate) AS Mn,
        SUM(SalesAmount) AS TotalSales
    FROM Sales
    GROUP BY YEAR(SaleDate), MONTH(SaleDate)
)
SELECT 
    m1.Yr, m1.Mn,
    m1.TotalSales AS CurrentMonthSales,
    m1.TotalSales - ISNULL(LAG(m1.TotalSales) OVER (ORDER BY m1.Yr, m1.Mn), 0) AS DiffFromPrev
FROM MonthlySales AS m1
ORDER BY m1.Yr, m1.Mn;

--14) Employees with quarterly sales > 45000 (derived)
SELECT e.EmployeeID, e.FirstName, e.LastName, q.TotalSales, q.Quarter
FROM Employees AS e
JOIN (
    SELECT EmployeeID,
           DATEPART(QUARTER, SaleDate) AS Quarter,
           SUM(SalesAmount) AS TotalSales
    FROM Sales
    GROUP BY EmployeeID, DATEPART(QUARTER, SaleDate)
    HAVING SUM(SalesAmount) > 45000
) AS q ON q.EmployeeID = e.EmployeeID
ORDER BY q.Quarter, q.TotalSales DESC;


 --/* -------------------- HARD -------------------- */

--15) Fibonacci numbers (recursive)
;WITH Fibonacci AS (
    SELECT 1 AS n, 0 AS f
    UNION ALL
    SELECT n + 1, 
           CASE WHEN n = 1 THEN 1 
                ELSE (SELECT SUM(f) FROM Fibonacci WHERE n IN (n-1, n-2)) END
    FROM Fibonacci
    WHERE n < 20
)
SELECT * FROM Fibonacci;

--16) FindSameCharacters: строки, где все символы одинаковые
SELECT Id, Vals
FROM FindSameCharacters
WHERE LEN(Vals) > 1
  AND LEN(REPLACE(Vals, LEFT(Vals,1), '')) = 0;

--17) Sequence 1, 12, 123, …, 12345 (n = 5)
DECLARE @n INT = 5;

;WITH Seq AS (
    SELECT 1 AS num, CAST('1' AS VARCHAR(10)) AS seq
    UNION ALL
    SELECT num + 1, seq + CAST(num + 1 AS VARCHAR(10))
    FROM Seq
    WHERE num < @n
)
SELECT seq
FROM Seq;

--18) Employees with most sales in last 6 months
;WITH RecentSales AS (
    SELECT EmployeeID, SUM(SalesAmount) AS TotalSales
    FROM Sales
    WHERE SaleDate >= DATEADD(MONTH, -6, GETDATE())
    GROUP BY EmployeeID
)
SELECT TOP 1 e.EmployeeID, e.FirstName, e.LastName, r.TotalSales
FROM Employees AS e
JOIN RecentSales AS r ON r.EmployeeID = e.EmployeeID
ORDER BY r.TotalSales DESC;

--19) Remove duplicate integer digits in string
UPDATE RemoveDuplicateIntsFromNames
SET Pawan_slug_name = (
    SELECT STRING_AGG(DISTINCT value, '') 
    FROM STRING_SPLIT(REPLACE(Pawan_slug_name, '-', ''), '')
    WHERE ISNUMERIC(value) = 0
);
