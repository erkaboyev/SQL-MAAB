/* ================================================
				        	Lesson-10: Joins
   ================================================ */


--/* -------------------- EASY -------------------- */


-- 1) Employees with salaries > 50,000 and their departments
SELECT e.Name AS EmployeeName, e.Salary, d.DepartmentName
FROM Employees AS e
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE e.Salary > 50000
ORDER BY e.Salary DESC, e.Name;


-- 2) Customers and dates of orders placed in 2023
SELECT c.FirstName, c.LastName, o.OrderDate
FROM Customers AS c
JOIN Orders    AS o ON o.CustomerID = c.CustomerID
WHERE YEAR(o.OrderDate) = 2023
ORDER BY o.OrderDate, c.LastName, c.FirstName;


-- 3) All employees + department name, including those who do not have a department
SELECT e.Name AS EmployeeName, d.DepartmentName
FROM Employees  AS e
LEFT JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
ORDER BY e.Name;


-- 4) All suppliers and the goods they supply (suppliers without goods are also shown)
SELECT su.SupplierName, p.ProductName
FROM Suppliers AS su
LEFT JOIN Products  AS p ON p.SupplierID = su.SupplierID
ORDER BY su.SupplierName, p.ProductName;


-- 5) All orders and related payments,
--    including orders without payments and payments without orders
SELECT COALESCE(o.OrderID, pay.OrderID) AS OrderID,
       o.OrderDate,
       pay.PaymentDate,
       pay.Amount
FROM Orders   AS o
FULL OUTER JOIN Payments AS pay ON pay.OrderID = o.OrderID
ORDER BY COALESCE(o.OrderID, pay.OrderID);


-- 6) Employee and his manager (self join)
SELECT e.Name  AS EmployeeName,
       m.Name  AS ManagerName
FROM Employees AS e
LEFT JOIN Employees AS m ON m.EmployeeID = e.ManagerID
ORDER BY e.Name;


-- 7) Students enrolled in 'Math 101'
SELECT st.Name AS StudentName, co.CourseName
FROM Enrollments AS en
JOIN Students    AS st ON st.StudentID = en.StudentID
JOIN Courses     AS co ON co.CourseID  = en.CourseID
WHERE co.CourseName = 'Math 101'
ORDER BY st.Name;


-- 8) Customers who have placed an order with a quantity > 3 (we show each such order)
SELECT c.FirstName, c.LastName, o.Quantity
FROM Customers AS c
JOIN Orders    AS o ON o.CustomerID = c.CustomerID
WHERE o.Quantity > 3
ORDER BY o.Quantity DESC, c.LastName, c.FirstName;


-- 9) Employees from the Human Resources department
SELECT e.Name AS EmployeeName, d.DepartmentName
FROM Employees  AS e
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE d.DepartmentName = 'Human Resources'
ORDER BY e.Name;


--/* -------------------- MEDIUM -------------------- */


-- 10) Departments with > 5 employees
SELECT d.DepartmentName, COUNT(*) AS EmployeeCount
FROM Employees  AS e
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
GROUP BY d.DepartmentName
HAVING COUNT(*) > 5
ORDER BY EmployeeCount DESC, d.DepartmentName;


-- 11) Goods that have never been sold (no entries in Sales)
SELECT p.ProductID, p.ProductName
FROM Products AS p
LEFT JOIN Sales AS s ON s.ProductID = p.ProductID
WHERE s.ProductID IS NULL
ORDER BY p.ProductID;


-- 12) Customers who have placed >= 1 order (with number of orders)
SELECT c.FirstName, c.LastName, COUNT(*) AS TotalOrders
FROM Customers AS c
JOIN Orders    AS o ON o.CustomerID = c.CustomerID
GROUP BY c.FirstName, c.LastName
ORDER BY TotalOrders DESC, c.LastName, c.FirstName;


-- 13) Only rows where both the employee and the department exist (INNER)
SELECT e.Name AS EmployeeName, d.DepartmentName
FROM Employees  AS e
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
ORDER BY e.Name;


-- 14) Pairs of employees with one manager (no duplicates or themselves)
SELECT e1.Name AS Employee1, e2.Name AS Employee2, e1.ManagerID
FROM Employees AS e1
JOIN Employees AS e2
  ON e1.ManagerID = e2.ManagerID
 AND e1.EmployeeID < e2.EmployeeID
WHERE e1.ManagerID IS NOT NULL
ORDER BY e1.ManagerID, Employee1, Employee2;


-- 15) Orders for 2022 + customer's full name
SELECT o.OrderID, o.OrderDate, c.FirstName, c.LastName
FROM Orders    AS o
JOIN Customers AS c ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= '2022-01-01' AND o.OrderDate < '2023-01-01'
ORDER BY o.OrderDate, o.OrderID

--or
SELECT o.OrderID, o.OrderDate, c.FirstName, c.LastName
FROM Orders    AS o
JOIN Customers AS c ON c.CustomerID = o.CustomerID
WHERE YEAR(o.OrderDate) = 2022
ORDER BY o.OrderDate, o.OrderID;

-- 16) Sales department employees with a salary > 60,000
SELECT e.Name AS EmployeeName, e.Salary, d.DepartmentName
FROM Employees  AS e
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE d.DepartmentName = 'Sales' AND e.Salary > 60000
ORDER BY e.Salary DESC, e.Name;

-- 17) Only orders with payment
SELECT o.OrderID, o.OrderDate, pay.PaymentDate, pay.Amount
FROM Orders   AS o
JOIN Payments AS pay ON pay.OrderID = o.OrderID
ORDER BY o.OrderDate, o.OrderID;


-- 18) Products that have never been ordered (no references in Orders.ProductID)
SELECT p.ProductID, p.ProductName
FROM Products AS p
LEFT JOIN Orders AS o ON o.ProductID = p.ProductID
WHERE o.ProductID IS NULL
ORDER BY p.ProductID;


 --/* -------------------- HARD -------------------- */


-- 19) Employees with salaries above the average for their department
SELECT e.Name AS EmployeeName, e.Salary
FROM (
    SELECT e.*,
           AVG(e.Salary) OVER (PARTITION BY e.DepartmentID) AS DeptAvgSalary
    FROM Employees e
) e
WHERE e.Salary > e.DeptAvgSalary
ORDER BY e.DepartmentID, e.Salary DESC, e.Name;

-- or
SELECT e.Name AS EmployeeName, e.Salary
FROM Employees AS e
JOIN (
  SELECT DepartmentID, AVG(Salary) AS AvgSalary
  FROM Employees
  GROUP BY DepartmentID
) AS a ON a.DepartmentID = e.DepartmentID
WHERE e.Salary > a.AvgSalary
ORDER BY e.DepartmentID, e.Salary DESC, e.Name;


-- 20) Orders until 2020 without payment
SELECT o.OrderID, o.OrderDate
FROM Orders AS o
LEFT JOIN Payments AS pay ON pay.OrderID = o.OrderID
WHERE o.OrderDate < '2020-01-01' AND pay.OrderID IS NULL
ORDER BY o.OrderDate, o.OrderID;


 -- 21) Products without a corresponding category (incorrect/empty Category link)
SELECT p.ProductID, p.ProductName
FROM Products   AS p
LEFT JOIN Categories AS cat ON cat.CategoryID = p.Category
WHERE cat.CategoryID IS NULL
ORDER BY p.ProductID;


-- 22) Couples with one manager, both earning > 60,000.
--    In the Salary column, display the lower of the two salaries (one column on demand).
SELECT e1.Name AS Employee1,
       e2.Name AS Employee2,
       e1.ManagerID,
       CASE WHEN e1.Salary <= e2.Salary THEN e1.Salary ELSE e2.Salary END AS Salary
FROM Employees AS e1
JOIN Employees AS e2
  ON e1.ManagerID = e2.ManagerID
 AND e1.EmployeeID < e2.EmployeeID
WHERE e1.ManagerID IS NOT NULL
  AND e1.Salary > 60000
  AND e2.Salary > 60000
ORDER BY e1.ManagerID, Employee1, Employee2;


-- 23) Employees from departments whose names begin with 'M'
SELECT e.Name AS EmployeeName, d.DepartmentName
FROM Employees  AS e
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE d.DepartmentName LIKE 'M%'
ORDER BY d.DepartmentName, e.Name;


-- 24) Sales with a total amount > 500 + product names
SELECT s.SaleID, p.ProductName, s.SaleAmount
FROM Sales    AS s
JOIN Products AS p ON p.ProductID = s.ProductID
WHERE s.SaleAmount > 500
ORDER BY s.SaleAmount DESC, s.SaleID;


-- 25) Students NOT enrolled in ‘Math 101’ (anti-half-union via NOT EXISTS)
SELECT st.StudentID, st.Name AS StudentName
FROM Students AS st
WHERE NOT EXISTS (
  SELECT 1
  FROM Enrollments AS en
  JOIN Courses     AS co ON co.CourseID = en.CourseID
  WHERE en.StudentID = st.StudentID
    AND co.CourseName = 'Math 101'
)
ORDER BY st.StudentID;


-- 26) Orders with missing payment details
SELECT o.OrderID, o.OrderDate, pay.PaymentID
FROM Orders AS o
LEFT JOIN Payments AS pay ON pay.OrderID = o.OrderID
WHERE pay.PaymentID IS NULL
ORDER BY o.OrderDate, o.OrderID;


-- 27) Goods from the ‘Electronics’ or ‘Furniture’ categories
SELECT p.ProductID, p.ProductName, cat.CategoryName
FROM Products   AS p
JOIN Categories AS cat ON cat.CategoryID = p.Category
WHERE cat.CategoryName IN ('Electronics', 'Furniture')
ORDER BY cat.CategoryName, p.ProductName;

