/* =====================================================
   Lesson 5 — Aliases, Unions, and Conditional columns
   ===================================================== */

/* -------------------- EASY -------------------- */

-- 1. Alias for the ProductName column
SELECT ProductName AS Name
FROM Products;

--2.Table alias Customers → Client
SELECT Client.CustomerID, Client.FirstName, Client.LastName
FROM Customers AS Client;

--3. UNION of product names from Products and Products_Discounted
SELECT ProductName FROM Products
UNION
SELECT ProductName FROM Products_Discounted;

--4. Intersection (INTERSECT) by product names
SELECT ProductName FROM Products
INTERSECT
SELECT ProductName FROM Products_Discounted;

--5. Unique customer names and their country
SELECT DISTINCT
       CONCAT(FirstName, ' ', LastName) AS FullName,
       Country
FROM Customers
ORDER BY Country, FullName;

--6. CASE: Price > 1000 → 'High', otherwise 'Low'
SELECT ProductID, ProductName, Price,
       CASE WHEN Price > 1000 THEN 'High' ELSE 'Low' END AS PriceTier
FROM Products;

--7. IIF: StockQuantity > 100 → 'Yes', иначе 'No' (Products_Discounte
SELECT ProductID, ProductName, StockQuantity,
       IIF(StockQuantity > 100, 'Yes', 'No') AS Over100
FROM Products_Discounted;

/* ------------------ MEDIUM ------------------ */

-- 8. UNION of product names (repeat task with Medium requirement)
SELECT ProductName FROM Products
UNION
SELECT ProductName FROM Products_Discounted
ORDER BY ProductName;

--9. EXCEPT: products that exist in Products but are not present in Products_Discounted (by name)
SELECT ProductName FROM Products
EXCEPT
SELECT ProductName FROM Products_Discounted;

--10. IF: ‘Expensive’ if Price > 1000, otherwise 'Affordable'
SELECT ProductID, ProductName, Price,
       IIF(Price > 1000, 'Expensive', 'Affordable') AS PriceClass
FROM Products;

--11. Employees: Age < 25 OR Salary > 60,000
SELECT *
FROM Employees
WHERE Age < 25 OR Salary > 60000;

--12. Update salary: +10% if DepartmentName = ‘HR’ OR EmployeeID = 5
UPDATE Employees
SET Salary = Salary * 1.10
WHERE DepartmentName = 'HR' OR EmployeeID = 5;

-- Checking the result
SELECT EmployeeID, FirstName, LastName, DepartmentName, Salary
FROM Employees
WHERE DepartmentName = 'HR' OR EmployeeID = 5
ORDER BY EmployeeID;

/* -------------------- HARD -------------------- */

--13. CASE by sales amount (Sales)
SELECT SaleID, ProductID, CustomerID, SaleAmount,
       CASE
         WHEN SaleAmount > 500 THEN 'Top Tier'
         WHEN SaleAmount BETWEEN 200 AND 500 THEN 'Mid Tier'
         ELSE 'Low Tier'
       END AS SaleTier
FROM Sales
ORDER BY SaleAmount DESC, SaleID;

--14. EXCEPT: IDs of customers who have orders but no entries in Sales
SELECT DISTINCT CustomerID FROM Orders
EXCEPT
SELECT DISTINCT CustomerID FROM Sales;

--15. CASE on discount (Orders): show CustomerID, Quantity, and discount percentage
SELECT
    CustomerID,
    Quantity,
    CASE 
           WHEN Quantity = 1 THEN '3%'
           WHEN Quantity > 1 AND Quantity <= 3 THEN '5%'
           ELSE '7%'
       END AS DiscountPercentage
FROM Orders
ORDER BY Quantity DESC;
