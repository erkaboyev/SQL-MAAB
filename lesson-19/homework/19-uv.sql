/* ================================================
	 Lesson-19: Stored procedures, Merge and Practice
   ================================================ */

-- Part 1 — Stored Procedures
-- Task 1 — #EmployeeBonus
DROP PROCEDURE IF EXISTS dbo.usp_BuildEmployeeBonus;
GO
CREATE OR ALTER PROCEDURE dbo.usp_BuildEmployeeBonus
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#EmployeeBonus') IS NOT NULL
        DROP TABLE #EmployeeBonus;

    CREATE TABLE #EmployeeBonus (
        EmployeeID   INT        NOT NULL PRIMARY KEY,
        FullName     NVARCHAR(120) NOT NULL,
        Department   NVARCHAR(50)  NOT NULL,
        Salary       DECIMAL(10,2) NOT NULL,
        BonusAmount  DECIMAL(12,2) NOT NULL
    );

    INSERT INTO #EmployeeBonus (EmployeeID, FullName, Department, Salary, BonusAmount)
    SELECT
        e.EmployeeID,
        LTRIM(RTRIM(CONCAT(e.FirstName, ' ', e.LastName))) AS FullName,
        e.Department,
        e.Salary,
        ROUND(e.Salary * b.BonusPercentage / 100.0, 2)     AS BonusAmount
    FROM dbo.Employees AS e
    JOIN dbo.DepartmentBonus AS b
      ON b.Department = e.Department;

    SELECT EmployeeID, FullName, Department, Salary, BonusAmount
    FROM #EmployeeBonus
    ORDER BY EmployeeID;
END
GO

--Task 2 — Raising salaries in the department
DROP PROCEDURE IF EXISTS dbo.usp_UpdateDepartmentSalary;
GO
CREATE OR ALTER PROCEDURE dbo.usp_UpdateDepartmentSalary
    @Department   NVARCHAR(50),
    @IncreasePct  DECIMAL(9,4)  -- For example, 7.5 means +7.5%.
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE e
    SET e.Salary = ROUND(e.Salary * (1 + @IncreasePct / 100.0), 2)
    FROM dbo.Employees AS e
    WHERE e.Department = @Department;

    SELECT e.EmployeeID, e.FirstName, e.LastName, e.Department, e.Salary
    FROM dbo.Employees AS e
    WHERE e.Department = @Department
    ORDER BY e.EmployeeID;
END
GO

-- Part 2 — MERGE
-- Task 3 — Synchronization of Products_Current from Products_New
MERGE dbo.Products_Current WITH (HOLDLOCK) AS tgt
USING dbo.Products_New AS src
   ON tgt.ProductID = src.ProductID
WHEN MATCHED THEN
    UPDATE SET
        tgt.ProductName = src.ProductName,
        tgt.Price       = src.Price
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ProductID, ProductName, Price)
    VALUES (src.ProductID, src.ProductName, src.Price)
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;

-- Result:
SELECT ProductID, ProductName, Price
FROM dbo.Products_Current
ORDER BY ProductID;

-- Task 4 — Tree Node (Root / Inner / Leaf)
IF OBJECT_ID('dbo.Tree','U') IS NOT NULL DROP TABLE dbo.Tree;
CREATE TABLE dbo.Tree (id INT PRIMARY KEY, p_id INT NULL);

INSERT INTO dbo.Tree(id, p_id) VALUES
(1,NULL),(2,1),(3,1),(4,2),(5,2);

SELECT
    t.id,
    CASE
        WHEN t.p_id IS NULL THEN 'Root'
        WHEN EXISTS (SELECT 1 FROM dbo.Tree AS c WHERE c.p_id = t.id) THEN 'Inner'
        ELSE 'Leaf'
    END AS [type]
FROM dbo.Tree AS t
ORDER BY t.id;

-- Task 5 — Confirmation Rate
IF OBJECT_ID('dbo.Signups','U')      IS NOT NULL DROP TABLE dbo.Signups;
IF OBJECT_ID('dbo.Confirmations','U') IS NOT NULL DROP TABLE dbo.Confirmations;

CREATE TABLE dbo.Signups (user_id INT PRIMARY KEY, time_stamp DATETIME);
CREATE TABLE dbo.Confirmations (
    user_id    INT,
    time_stamp DATETIME,
    [action]   NVARCHAR(10) CHECK ([action] IN ('confirmed','timeout'))
);

INSERT INTO dbo.Signups(user_id, time_stamp) VALUES
(3,'2020-03-21T10:16:13'),(7,'2020-01-04T13:57:59'),(2,'2020-07-29T23:09:44'),(6,'2020-12-09T10:39:37');

INSERT INTO dbo.Confirmations(user_id, time_stamp, [action]) VALUES
(3,'2021-01-06T03:30:46','timeout'),
(3,'2021-07-14T14:00:00','timeout'),
(7,'2021-06-12T11:57:29','confirmed'),
(7,'2021-06-13T12:58:28','confirmed'),
(7,'2021-06-14T13:59:27','confirmed'),
(2,'2021-01-22T00:00:00','confirmed'),
(2,'2021-02-28T23:59:59','timeout');

SELECT
    s.user_id,
    CAST(COALESCE(
        1.0 * SUM(CASE WHEN c.[action] = 'confirmed' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(c.[action]), 0), 0.0
    ) AS DECIMAL(3,2)) AS confirmation_rate
FROM dbo.Signups AS s
LEFT JOIN dbo.Confirmations AS c
  ON c.user_id = s.user_id
GROUP BY s.user_id
ORDER BY s.user_id;  -- If desired, you can repeat the exact order of the example output.

-- Task 6 — Employees with minimum wage (subquery)
-- Test table for task 6
IF OBJECT_ID('dbo.employees','U') IS NOT NULL DROP TABLE dbo.employees;
CREATE TABLE dbo.employees (
    id INT PRIMARY KEY,
    name   VARCHAR(100),
    salary DECIMAL(10,2)
);
INSERT INTO dbo.employees(id, name, salary) VALUES
(1,'Alice',50000),(2,'Bob',60000),(3,'Charlie',50000);

-- Solution:
SELECT id, name, salary
FROM dbo.employees
WHERE salary = (SELECT MIN(salary) FROM dbo.employees)
ORDER BY id;

-- Task 7 — GetProductSalesSummary (stored procedure)
DROP PROCEDURE IF EXISTS dbo.GetProductSalesSummary;
GO
CREATE OR ALTER PROCEDURE dbo.GetProductSalesSummary
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.ProductName,
        SUM(s.Quantity)                     AS TotalQuantitySold,
        SUM(s.Quantity * p.Price)           AS TotalSalesAmount,
        MIN(s.SaleDate)                     AS FirstSaleDate,
        MAX(s.SaleDate)                     AS LastSaleDate
    FROM dbo.Products AS p
    LEFT JOIN dbo.Sales    AS s
      ON s.ProductID = p.ProductID
    WHERE p.ProductID = @ProductID
    GROUP BY p.ProductName;
END
GO
