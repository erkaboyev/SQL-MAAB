/* ================================================
			Lesson-11: Homework Tasks
   ================================================ */

--/* -------------------- EASY -------------------- */

-- 1) Orders after 2022 with customer names
SELECT
    o.OrderID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    o.OrderDate
FROM Orders AS o
JOIN Customers AS c ON c.CustomerID = o.CustomerID
WHERE o.OrderDate > '2022-12-31'
ORDER BY o.OrderDate, o.OrderID;


-- 2) Employees in Sales or Marketing
SELECT
    e.Name AS EmployeeName,
    d.DepartmentName
FROM Employees AS e
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE d.DepartmentName IN ('Sales', 'Marketing')
ORDER BY d.DepartmentName, e.Name;


-- 3) Max salary per department (включая отделы без сотрудников)
SELECT
    d.DepartmentName,
    MAX(e.Salary) AS MaxSalary
FROM Departments AS d
LEFT JOIN Employees AS e ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName
ORDER BY MaxSalary DESC, d.DepartmentName;


-- 4) US customers who placed orders in 2023
SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    o.OrderID,
    o.OrderDate
FROM Customers AS c
JOIN Orders AS o ON o.CustomerID = c.CustomerID
WHERE c.Country = 'USA'
  AND YEAR(o.OrderDate) = 2023
ORDER BY o.OrderDate, o.OrderID;

--or
SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    o.OrderID,
    o.OrderDate
FROM Customers AS c
JOIN Orders AS o ON o.CustomerID = c.CustomerID
WHERE c.Country = 'USA'
  AND o.OrderDate >= '2023-01-01' 
  AND o.OrderDate < '2024-01-01'
ORDER BY o.OrderDate, o.OrderID;


-- 5) Orders count per customer
SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    COUNT(o.OrderID) AS TotalOrders
FROM Customers AS c
LEFT JOIN Orders AS o ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY TotalOrders DESC, CustomerName;


-- 6) Products supplied by Gadget Supplies or Clothing Mart
SELECT
    p.ProductName,
    sup.SupplierName
FROM Products AS p
JOIN Suppliers AS sup ON sup.SupplierID = p.SupplierID
WHERE sup.SupplierName IN ('Gadget Supplies', 'Clothing Mart')
ORDER BY sup.SupplierName, p.ProductName;


-- 7) Most recent order per customer (including customers without orders)
SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    MAX(o.OrderDate)                     AS MostRecentOrderDate
FROM Customers AS c
LEFT JOIN Orders    AS o ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY MostRecentOrderDate DESC, CustomerName;


--/* -------------------- MEDIUM -------------------- */


-- 8) Customers with an order TotalAmount > 500
SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    o.TotalAmount AS OrderTotal
FROM Orders AS o
JOIN Customers AS c ON c.CustomerID = o.CustomerID
WHERE o.TotalAmount > 500
ORDER BY o.TotalAmount DESC, CustomerName;


-- 9) Product sales in 2022 OR SaleAmount > 400
SELECT
    p.ProductName,
    s.SaleDate,
    s.SaleAmount
FROM Sales AS s
JOIN Products AS p ON p.ProductID = s.ProductID
WHERE YEAR(s.SaleDate) = 2022
   OR s.SaleAmount > 400
ORDER BY s.SaleDate, p.ProductName;

--or
SELECT
    p.ProductName,
    s.SaleDate,
    s.SaleAmount
FROM Sales AS s
JOIN Products AS p ON p.ProductID = s.ProductID
WHERE (s.SaleDate >= '2022-01-01' AND s.SaleDate < '2023-01-01')
   OR s.SaleAmount > 400
ORDER BY s.SaleDate, p.ProductName;


-- 10) Total sales amount per product (including unsold goods)
SELECT
    p.ProductName,
    COALESCE(SUM(s.SaleAmount), 0) AS TotalSalesAmount
FROM Products AS p
LEFT JOIN Sales AS s ON s.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalSalesAmount DESC, p.ProductName;


-- 11) HR employees with Salary > 60000
SELECT
    e.Name AS EmployeeName,
    d.DepartmentName,
    e.Salary
FROM Employees AS e
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE d.DepartmentName = 'Human Resources'
  AND e.Salary > 60000
ORDER BY e.Salary DESC, e.Name;


-- 12) Products sold in 2023 and with StockQuantity > 100 (по текущим остаткам)
SELECT
    p.ProductName,
    s.SaleDate,
    p.StockQuantity
FROM Sales AS s
JOIN Products AS p ON p.ProductID = s.ProductID
WHERE YEAR(s.SaleDate) = 2023
  AND p.StockQuantity > 100
ORDER BY s.SaleDate, p.ProductName;

--or
SELECT
    p.ProductName,
    s.SaleDate,
    p.StockQuantity
FROM Sales AS s
JOIN Products AS p ON p.ProductID = s.ProductID
WHERE s.SaleDate >= '2023-01-01' 
  AND s.SaleDate < '2024-01-01'
  AND p.StockQuantity > 100
ORDER BY s.SaleDate, p.ProductName;


-- 13) Employees in Sales OR hired after 2020
SELECT
    e.Name AS EmployeeName,
    d.DepartmentName,
    e.HireDate
FROM Employees AS e
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE d.DepartmentName = 'Sales'
   OR e.HireDate > '2020-12-31'
ORDER BY e.HireDate, e.Name;

--or
SELECT
    e.Name AS EmployeeName,
    d.DepartmentName,
    e.HireDate
FROM Employees AS e
INNER JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE d.DepartmentName = 'Sales'

UNION ALL

SELECT
    e.Name AS EmployeeName,
    COALESCE(d.DepartmentName, 'No Department') AS DepartmentName,
    e.HireDate
FROM Employees AS e
LEFT JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE e.HireDate > '2020-12-31'
  AND NOT EXISTS (
    SELECT 1 FROM Departments d2 
    WHERE d2.DepartmentID = e.DepartmentID 
    AND d2.DepartmentName = 'Sales'
  )
ORDER BY HireDate, EmployeeName;


 --/* -------------------- HARD -------------------- */


-- 14) USA orders where address starts with 4 digits
SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    o.OrderID,
    c.Address,
    o.OrderDate
FROM Customers AS c
JOIN Orders  AS o ON o.CustomerID = c.CustomerID
WHERE c.Country = 'USA'
  AND c.Address LIKE '[0-9][0-9][0-9][0-9]%'
ORDER BY o.OrderDate, o.OrderID;


-- 15) Product sales for Electronics OR SaleAmount > 350
SELECT
    p.ProductName,
    cat.CategoryName AS Category,
    s.SaleAmount
FROM Sales AS s
JOIN Products   AS p   ON p.ProductID   = s.ProductID
LEFT JOIN Categories AS cat ON cat.CategoryID = p.Category
WHERE cat.CategoryName = 'Electronics'
   OR s.SaleAmount > 350
ORDER BY s.SaleAmount DESC, p.ProductName;

--or
SELECT
    p.ProductName,
    cat.CategoryName AS Category,
    s.SaleAmount
FROM Sales AS s
JOIN Products   AS p   ON p.ProductID   = s.ProductID
LEFT JOIN Categories AS cat ON cat.CategoryID = p.Category
WHERE (cat.CategoryName = 'Electronics' OR cat.CategoryName IS NULL)
   OR s.SaleAmount > 350
ORDER BY s.SaleAmount DESC, p.ProductName;


-- 16) Product count per category (включая пустые категории)
SELECT
    cat.CategoryName,
    COUNT(p.ProductID) AS ProductCount
FROM Categories AS cat
LEFT JOIN Products AS p ON p.Category = cat.CategoryID
GROUP BY cat.CategoryName
ORDER BY ProductCount DESC, cat.CategoryName;


-- 17) LA orders with Amount > 300
SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    c.City,
    o.OrderID,
    o.TotalAmount AS Amount
FROM Customers AS c
JOIN Orders AS o ON o.CustomerID = c.CustomerID
WHERE c.City = 'Los Angeles'
  AND o.TotalAmount > 300
ORDER BY o.TotalAmount DESC, o.OrderID;


-- 18) Employees: HR or Finance OR name contains >= 4 vowels
SELECT
    e.Name AS EmployeeName,
    COALESCE(d.DepartmentName, 'No Department') AS DepartmentName
FROM Employees AS e
LEFT JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE d.DepartmentName IN ('Human Resources', 'Finance')
   OR (
    -- Подсчитываем гласные простым способом
    LEN(e.Name) - LEN(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        UPPER(e.Name), 'A', ''), 'E', ''), 'I', ''), 'O', ''), 'U', '')) >= 4
   )
ORDER BY d.DepartmentName, e.Name;

--or
SELECT
    e.Name AS EmployeeName,
    d.DepartmentName
FROM Employees AS e
LEFT JOIN Departments AS d
  ON d.DepartmentID = e.DepartmentID
CROSS APPLY (
    SELECT
      LEN(LOWER(e.Name)) -
      LEN(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(e.Name),
          'a',''),'e',''),'i',''),'o',''),'u','')) AS VowelCount
) v
WHERE d.DepartmentName IN ('Human Resources', 'Finance')
   OR v.VowelCount >= 4
ORDER BY d.DepartmentName, e.Name;


-- 19) Employees in Sales or Marketing with Salary > 60000
SELECT
    e.Name AS EmployeeName,
    d.DepartmentName,
    e.Salary
FROM Employees AS e
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE d.DepartmentName IN ('Sales', 'Marketing')
  AND e.Salary > 60000
ORDER BY e.Salary DESC, e.Name;
