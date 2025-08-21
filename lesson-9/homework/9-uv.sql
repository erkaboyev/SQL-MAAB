/* ================================================
 Lesson-9: Joins (Only inner with table relationships)
   ================================================ */

--/* -------------------- EASY -------------------- */

--1) Products × Suppliers — all combinations (Cartesian product)
SELECT p.ProductName, s.SupplierName
FROM Products AS p
CROSS JOIN Suppliers AS s;


--2) Departments × Employees — all combinations
SELECT d.DepartmentName, e.Name AS EmployeeName
FROM Departments AS d
CROSS JOIN Employees AS e;


--3) Only real pairs of “supplier — his goods”
SELECT s.SupplierName, p.ProductName
FROM Suppliers AS s
INNER JOIN Products  AS p
  ON p.SupplierID = s.SupplierID;


--4) Customers × Orders — customer name and order ID
SELECT c.FirstName + ' ' + c.LastName AS CustomerName, o.OrderID
FROM Customers AS c
INNER JOIN Orders    AS o
  ON o.CustomerID = c.CustomerID;


--5) Students × Courses — all combinations
SELECT st.Name AS StudentName, c.CourseName
FROM Students AS st
CROSS JOIN Courses  AS c;


--6) Products × Orders — matching ProductID
SELECT p.ProductName, o.OrderID
FROM Products AS p
INNER JOIN Orders   AS o
  ON o.ProductID = p.ProductID;


--7) Employees in their departments
SELECT e.EmployeeID, e.Name, d.DepartmentName
FROM Employees  AS e
INNER JOIN Departments AS d
  ON d.DepartmentID = e.DepartmentID;


--8) Students × Enrollments — student and their CourseID
SELECT st.Name AS StudentName, en.CourseID
FROM Students    AS st
INNER JOIN Enrollments AS en
  ON en.StudentID = st.StudentID;


--9) Payments × Orders — orders that have a payment
SELECT o.OrderID, p.PaymentID, p.Amount
FROM Orders   AS o
INNER JOIN Payments AS p
  ON p.OrderID = o.OrderID;


--10) Orders × Products — orders with a product price > 100
SELECT o.OrderID, p.ProductName, p.Price
FROM Orders   AS o
INNER JOIN Products AS p
  ON p.ProductID = o.ProductID
WHERE p.Price > 100;


--/* -------------------- MEDIUM -------------------- */

--11) Employees × Departments — all mismatched pairs
SELECT e.Name AS EmployeeName, d.DepartmentName
FROM Employees  AS e
INNER JOIN Departments AS d
  ON e.DepartmentID <> d.DepartmentID; 


--12) Orders × Products — the quantity in the order exceeds the stock balance
SELECT o.OrderID, p.ProductName, o.Quantity, p.StockQuantity
FROM Orders   AS o
INNER JOIN Products AS p
  ON p.ProductID = o.ProductID
WHERE o.Quantity > p.StockQuantity;


--13) Customers × Sales — customers and ProductID with sales amount ≥ 500
SELECT c.FirstName + ' ' + c.LastName AS CustomerName, s.ProductID, s.SaleAmount
FROM Customers AS c
INNER JOIN Sales     AS s
  ON s.CustomerID = c.CustomerID
WHERE s.SaleAmount >= 500;


--14) Courses × Enrollments × Students — who studies where
SELECT st.Name AS StudentName, c.CourseName
FROM Enrollments AS en
INNER JOIN Students AS st ON st.StudentID = en.StudentID
INNER JOIN Courses  AS c  ON c.CourseID  = en.CourseID;


--15) Products × Suppliers — where the supplier name contains “Tech”
SELECT p.ProductName, s.SupplierName
FROM Products  AS p
INNER JOIN Suppliers AS s
  ON s.SupplierID = p.SupplierID
WHERE s.SupplierName LIKE '%Tech%';


--16) Orders × Payments — the total amount of payments is less than the total order amount
SELECT o.OrderID, o.TotalAmount, SUM(p.Amount) AS Paid
FROM Orders   AS o
INNER JOIN Payments AS p
  ON p.OrderID = o.OrderID
GROUP BY o.OrderID, o.TotalAmount
HAVING SUM(p.Amount) < o.TotalAmount;


--17) Employees → Departments — department name for each employee
SELECT e.EmployeeID, e.Name, d.DepartmentName
FROM Employees  AS e
INNER JOIN Departments AS d
  ON d.DepartmentID = e.DepartmentID;


--18) Products × Categories — only Electronics or Furniture
SELECT p.ProductName, c.CategoryName
FROM Products   AS p
INNER JOIN Categories AS c
  ON c.CategoryID = p.Category
WHERE c.CategoryName IN ('Electronics', 'Furniture');


--19) Sales × Customers — all sales to customers from the USA
SELECT s.SaleID, s.ProductID, s.SaleAmount, c.CustomerID
FROM Sales     AS s
INNER JOIN Customers AS c
  ON c.CustomerID = s.CustomerID
WHERE c.Country = 'USA';


--10) Orders × Customers — customer orders from Germany with Total > 100
SELECT o.OrderID, c.CustomerID, o.TotalAmount
FROM Orders    AS o
INNER JOIN Customers  AS c
  ON c.CustomerID = o.CustomerID
WHERE c.Country = 'Germany'
  AND o.TotalAmount > 100;


  --/* -------------------- HARD -------------------- */

--21) All pairs of employees from different departments (no duplicate pairs)
SELECT e1.EmployeeID AS Emp1ID, e1.Name AS Emp1Name,
       e2.EmployeeID AS Emp2ID, e2.Name AS Emp2Name
FROM Employees AS e1
INNER JOIN Employees AS e2
  ON e1.EmployeeID <  e2.EmployeeID     -- unique pairs
 AND e1.DepartmentID <> e2.DepartmentID; -- different departments


--22) Payments × Orders × Products — payment ≠ (Quantity × Price)
SELECT p.PaymentID, o.OrderID, pr.ProductName,
       p.Amount AS PaidAmount,
       (o.Quantity * pr.Price) AS ExpectedAmount
FROM Payments AS p
INNER JOIN Orders   AS o  ON o.OrderID   = p.OrderID
INNER JOIN Products AS pr ON pr.ProductID = o.ProductID
WHERE p.Amount <> (o.Quantity * pr.Price);


--23) Students who are not enrolled in any courses (without OUTER JOIN)
SELECT s.StudentID, s.Name
FROM Students AS s
WHERE NOT EXISTS (
  SELECT 1
  FROM Enrollments AS en
  WHERE en.StudentID = s.StudentID
);


--24) Managers whose salary is ≤ that of their subordinates
SELECT m.EmployeeID AS ManagerID, m.Name AS ManagerName, m.Salary AS ManagerSalary,
       e.EmployeeID AS EmployeeID, e.Name AS EmployeeName, e.Salary AS EmployeeSalary
FROM Employees AS e
INNER JOIN Employees AS m
  ON m.EmployeeID = e.ManagerID
WHERE m.Salary <= e.Salary;


--25) Customers with orders for which no payment has been made
SELECT DISTINCT c.CustomerID, c.FirstName + ' ' + c.LastName AS CustomerName
FROM Customers AS c
INNER JOIN Orders    AS o
  ON o.CustomerID = c.CustomerID
WHERE NOT EXISTS (
  SELECT 1
  FROM Payments AS p
  WHERE p.OrderID = o.OrderID
);
