--1. Top 5 employees
SELECT TOP (5) *
FROM Employees;

--2. Unique categories from Products
SELECT DISTINCT Category
FROM Products;

--3. Products with Price > 100
SELECT *
FROM Products
WHERE Price > 100;

--4. Customers with FirstName starting with 'A'
SELECT *
FROM Customers
WHERE FirstName LIKE 'A%';

--5. Order Products by Price ascending
SELECT *
FROM Products
ORDER BY Price ASC;

--6. Employees with Salary >= 60000 and Department = 'HR'
SELECT *
FROM Employees
WHERE Salary >= 60000 
AND DepartmentName = 'HR';

--7. Replace NULL emails with default text
SELECT EmployeeID,
ISNULL(Email, 'noemail@example.com') AS EmailFixed
FROM Employees;

--8. Products with Price between 50 and 100
SELECT *
FROM Products
WHERE Price BETWEEN 50 AND 100;

--9. DISTINCT on two columns
SELECT DISTINCT Category, ProductName
FROM Products;

--10. DISTINCT with ordering
SELECT DISTINCT Category, ProductName
FROM Products
ORDER BY ProductName DESC;

--11. Top 10 products ordered by Price DESC
SELECT TOP 10 *
FROM Products
ORDER BY Price DESC;

--12. COALESCE for first non-NULL name
SELECT EmployeeID,
       COALESCE(FirstName, LastName) AS PreferredName
FROM Employees;

--13. Distinct Category and Price
SELECT DISTINCT Category, Price
FROM Products;

--14. Complex filtering with OR
SELECT *
FROM Employees
WHERE (Age BETWEEN 30 AND 40) OR DepartmentName = 'Marketing';

--15. OFFSET-FETCH for pagination
SELECT *
FROM Employees
ORDER BY Salary DESC
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY;

--16. Multiple conditions with sorting
SELECT *
FROM Products
WHERE Price <= 1000 AND StockQuantity > 50
ORDER BY StockQuantity;

--17. LIKE with pattern in middle
SELECT *
FROM Products
WHERE ProductName LIKE '%e%';

--18. IN operator for multiple values
SELECT *
FROM Employees
WHERE DepartmentName IN ('HR', 'IT', 'Finance');

--19. Multi-column ordering
SELECT *
FROM Customers
ORDER BY City ASC, PostalCode DESC;

--20. Top 5 products by sales amount
SELECT TOP (5)
       p.ProductID,
       p.ProductName,
       SUM(s.SaleAmount) AS TotalSales
FROM Sales AS s
JOIN Products AS p
  ON p.ProductID = s.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalSales DESC;

-- We check that we really have the aggregated amounts.
SELECT COUNT(DISTINCT ProductID) as UniqueProducts,
       COUNT(*) as TotalSalesRecords
FROM Sales;

--21. Combine FirstName and LastName
SELECT EmployeeID,
       LTRIM(RTRIM(ISNULL(FirstName,'') + ' ' + ISNULL(LastName,''))) AS FullName,
       DepartmentName, Salary
FROM Employees;

--22. Three-column DISTINCT with price filter
SELECT DISTINCT Category, ProductName, Price
FROM Products
WHERE Price > 50;

--23. Products less than 10% of average price
SELECT *
FROM Products
WHERE Price < 0.1 * (SELECT AVG(Price) FROM Products);

--24. Age and department filtering
SELECT *
FROM Employees
WHERE Age < 30 AND DepartmentName IN ('HR', 'IT');

--25. Email domain filtering
SELECT *
FROM Customers
WHERE Email LIKE '%@gmail.com';

--26. ALL operator for salary comparison
SELECT *
FROM Employees
WHERE Salary > ALL (
    SELECT Salary 
    FROM Employees 
    WHERE DepartmentName = 'Sales'
);

--27. Orders in last 180 days
DECLARE @LatestDate date = (SELECT MAX(OrderDate) FROM Orders);
SELECT *
FROM Orders
WHERE OrderDate BETWEEN DATEADD(DAY, -180, @LatestDate) AND @LatestDate
ORDER BY OrderDate DESC;


