--/* ==========================================================
--   Lesson 7 — Aggregate Functions (MIN, MAX, COUNT, AVG, SUM)
--	 Filtering Aggregated Data with HAVING
--   ========================================================== */

--/* -------------------- EASY -------------------- */

-- Task 1: Find the minimum price of a product in the Products table
SELECT MIN(Price) AS MinPrice
FROM Products;

-- Task 2: Find the maximum Salary from the Employees table
SELECT MAX(Salary) AS MaxSalary
FROM Employees;

-- Task 3: Count the number of rows in the Customers table
SELECT COUNT(*) AS CustomerCount
FROM Customers;

-- Task 4: Count the number of unique product categories from the Products table
SELECT COUNT(DISTINCT Category) AS DistinctCategoryCount
FROM Products;

-- Task 5: Find the total sales amount for the product with id 7 in the Sales table
SELECT SUM(SaleAmount) AS TotalSales_Product7
FROM Sales
WHERE ProductID = 7;

-- Task 6: Calculate the average age of employees in the Employees table
SELECT AVG(Age) AS AvgAge
FROM Employees;
 
 -- or a more accurate option with the DECIMAL command
SELECT AVG(CAST(Age AS DECIMAL(10,2))) AS AvgAge
FROM Employees;

-- Task 7: Count the number of employees in each department
SELECT DepartmentName, COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY DepartmentName
ORDER BY DepartmentName;

-- Task 8: Show the minimum and maximum Price of products grouped by Category
SELECT Category,
       MIN(Price) AS MinPrice,
       MAX(Price) AS MaxPrice
FROM Products
GROUP BY Category
ORDER BY Category;

-- Task 9: Calculate the total sales per Customer in the Sales table
SELECT CustomerID, SUM(SaleAmount) AS TotalSales
FROM Sales
GROUP BY CustomerID
ORDER BY CustomerID;

-- Task 10: Filter departments having more than 5 employees
SELECT DepartmentName, COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY DepartmentName
HAVING COUNT(*) > 5
ORDER BY EmployeeCount DESC, DepartmentName;

--/* ------------------ MEDIUM ------------------ */
-- Task 11: Calculate the total sales and average sales for each product category
SELECT p.Category,
       SUM(s.SaleAmount) AS TotalSales,
       AVG(s.SaleAmount) AS AvgSale
FROM Sales AS s
JOIN Products AS p ON p.ProductID = s.ProductID
GROUP BY p.Category
ORDER BY p.Category;

-- Task 12: Count the number of employees from the Department HR
SELECT COUNT(*) AS HrEmployees
FROM Employees
WHERE DepartmentName = 'HR';

-- Task 13: Find the highest and lowest Salary by department
SELECT DepartmentName,
       MIN(Salary) AS MinSalary,
       MAX(Salary) AS MaxSalary
FROM Employees
GROUP BY DepartmentName
ORDER BY DepartmentName;

-- Task 14: Calculate the average salary per Department
SELECT DepartmentName,
       AVG(Salary) AS AvgSalary
FROM Employees
GROUP BY DepartmentName
ORDER BY DepartmentName;

-- Task 15: Show the AVG salary and COUNT(*) of employees working in each department
SELECT DepartmentName,
       AVG(Salary) AS AvgSalary,
       COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY DepartmentName
ORDER BY DepartmentName;

-- Task 16: Filter product categories with an average price greater than 400
SELECT Category,
       AVG(Price) AS AvgPrice
FROM Products
GROUP BY Category
HAVING AVG(Price) > 400
ORDER BY AvgPrice DESC;

-- Task 17: Calculate the total sales for each year in the Sales table
SELECT YEAR(SaleDate) AS SalesYear,
       SUM(SaleAmount) AS TotalSales
FROM Sales
GROUP BY YEAR(SaleDate)
ORDER BY SalesYear;

-- Task 18: Show the list of customers who placed at least 3 orders
SELECT CustomerID, COUNT(*) AS OrderCount
FROM Orders
GROUP BY CustomerID
HAVING COUNT(*) >= 3
ORDER BY OrderCount DESC, CustomerID;

-- Task 19: Filter out Departments with average salary expenses greater than 60000
SELECT DepartmentName,
       AVG(Salary) AS AvgSalary
FROM Employees
GROUP BY DepartmentName
HAVING AVG(Salary) > 60000
ORDER BY AvgSalary DESC;

--/* -------------------- HARD -------------------- */
-- Task 20: Show average price for each product category, filter categories with avg price > 150
SELECT Category,
       AVG(Price) AS AvgPrice
FROM Products
GROUP BY Category
HAVING AVG(Price) > 150
ORDER BY AvgPrice DESC;

-- Task 21: Calculate total sales for each Customer, filter customers with total sales > 1500
SELECT CustomerID,
       SUM(SaleAmount) AS TotalSales
FROM Sales
GROUP BY CustomerID
HAVING SUM(SaleAmount) > 1500
ORDER BY TotalSales DESC, CustomerID;

-- Task 22: Find total and average salary of employees in each department, 
-- filter departments with average salary > 65000
SELECT DepartmentName,
       SUM(Salary) AS TotalSalary,
       AVG(Salary) AS AvgSalary
FROM Employees
GROUP BY DepartmentName
HAVING AVG(Salary) > 65000
ORDER BY AvgSalary DESC;

-- Task 23: Find total amount for orders which weights more than $50 for each customer 
-- along with their least purchases
  SELECT
    o.custid AS CustomerID,
	SUM(CASE WHEN o.freight > 50 THEN o.freight END) AS TotalFreight,
MIN(o.freight) AS LeastPurchase
FROM TSQL2012.Sales.Orders AS o
GROUP BY o.custid
HAVING SUM(CASE WHEN o.freight > 50 THEN o.freight END) IS NOT NULL
ORDER BY TotalFreight DESC, CustomerID;

-- Task 24: Calculate total sales and count unique products sold in each month of each year,
-- filter months with at least 2 products sold
SELECT YEAR(OrderDate)  AS [Year],
       MONTH(OrderDate) AS [Month],
       SUM(TotalAmount) AS TotalSales,
       COUNT(DISTINCT ProductID) AS UniqueProducts
FROM Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
HAVING COUNT(DISTINCT ProductID) >= 2
ORDER BY [Year], [Month];


-- Task 25: Find the MIN and MAX order quantity per Year from orders table
SELECT
    YEAR(OrderDate) AS OrderYear,
    MIN(Quantity)   AS MinQty,
    MAX(Quantity)   AS MaxQty
FROM Orders
GROUP BY YEAR(OrderDate)
ORDER BY OrderYear;
