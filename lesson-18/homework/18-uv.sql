/* ================================================
	 Lesson-18: View, temp table, variable, functions
   ================================================ */

--1) Temp table for the current month #MonthlySales
DECLARE @start DATE = DATEADD(DAY, 1, EOMONTH(GETDATE(), -1)); -- 1st day of the current month
DECLARE @end   DATE = DATEADD(DAY, 1, EOMONTH(GETDATE()));     -- first day of the following month

DROP TABLE IF EXISTS #MonthlySales;
CREATE TABLE #MonthlySales (
    ProductID     INT        PRIMARY KEY,
    TotalQuantity INT        NOT NULL,
    TotalRevenue  DECIMAL(18,2) NOT NULL
);

INSERT INTO #MonthlySales (ProductID, TotalQuantity, TotalRevenue)
SELECT
    p.ProductID,
    SUM(s.Quantity)                            AS TotalQuantity,
    SUM(s.Quantity * p.Price)                  AS TotalRevenue
FROM Sales AS s
JOIN Products AS p ON p.ProductID = s.ProductID
WHERE s.SaleDate >= @start AND s.SaleDate < @end
GROUP BY p.ProductID;

-- Return result
SELECT ProductID, TotalQuantity, TotalRevenue
FROM #MonthlySales
ORDER BY ProductID;

--2) View vw_ProductSalesSummary
CREATE OR ALTER VIEW dbo.vw_ProductSalesSummary
AS
SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    COALESCE(SUM(s.Quantity), 0) AS TotalQuantitySold
FROM Products AS p
LEFT JOIN Sales AS s ON s.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName, p.Category;
GO

-- Example of verification
SELECT * FROM dbo.vw_ProductSalesSummary ORDER BY ProductID;

--3) Function fn_GetTotalRevenueForProduct(@ProductID)
CREATE OR ALTER FUNCTION dbo.fn_GetTotalRevenueForProduct (@ProductID INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @total DECIMAL(18,2);

    SELECT @total = COALESCE(SUM(s.Quantity * p.Price), 0)
    FROM Sales AS s
    JOIN Products AS p ON p.ProductID = s.ProductID
    WHERE s.ProductID = @ProductID;

    RETURN @total;
END;
GO

--4) Function fn_GetSalesByCategory(@Category)
CREATE OR ALTER FUNCTION dbo.fn_GetSalesByCategory (@Category VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.ProductName,
        SUM(COALESCE(s.Quantity, 0))                    AS TotalQuantity,
        SUM(COALESCE(s.Quantity, 0) * p.Price)          AS TotalRevenue
    FROM Products AS p
    LEFT JOIN Sales AS s ON s.ProductID = p.ProductID
    WHERE p.Category = @Category
    GROUP BY p.ProductName
);
GO

--5) Function fn_IsPrime(@Number) → ‘Yes’/'No'
CREATE OR ALTER FUNCTION dbo.fn_IsPrime (@Number INT)
RETURNS VARCHAR(3)
AS
BEGIN
    IF @Number IS NULL OR @Number <= 1      RETURN 'No';
    IF @Number IN (2,3)                     RETURN 'Yes';
    IF @Number % 2 = 0 OR @Number % 3 = 0   RETURN 'No';

    DECLARE @i INT = 5;
    WHILE (@i * @i) <= @Number
    BEGIN
        IF (@Number % @i = 0) OR (@Number % (@i + 2) = 0) RETURN 'No';
        SET @i += 6;
    END
    RETURN 'Yes';
END;
GO

--6) Table function fn_GetNumbersBetween(@Start, @End)
CREATE OR ALTER FUNCTION dbo.fn_GetNumbersBetween (@Start INT, @End INT)
RETURNS @Numbers TABLE (Number INT)
AS
BEGIN
    IF @Start IS NULL OR @End IS NULL RETURN;
    IF @Start > @End
    BEGIN
        DECLARE @t INT = @Start; SET @Start = @End; SET @End = @t;
    END;

    DECLARE @i INT = @Start;
    WHILE @i <= @End
    BEGIN
        INSERT INTO @Numbers(Number) VALUES (@i);
        SET @i += 1;
    END
    RETURN;
END;
GO

--7) Nth largest variable salary
DECLARE @N INT = 2;

SELECT
    (SELECT MIN(salary) -- MIN one element = the salary itself; if there are no rows → NULL
     FROM (
        SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS rk
        FROM Employee
     ) AS x
     WHERE x.rk = @N
    ) AS HighestNSalary;


--8) “Who has the most friends”
SELECT TOP (1)
       t.id,
       COUNT(DISTINCT t.friend) AS num
FROM (
    SELECT r.requester_id AS id, r.accepter_id AS friend FROM RequestAccepted AS r
    UNION ALL
    SELECT r.accepter_id  AS id, r.requester_id AS friend FROM RequestAccepted AS r
) AS t
GROUP BY t.id
ORDER BY COUNT(DISTINCT t.friend) DESC; -- guaranteed single maximum

--9) View «Customer Order Summary»
CREATE OR ALTER VIEW dbo.vw_CustomerOrderSummary
AS
SELECT
    c.customer_id,
    c.name,
    COUNT(o.order_id)                    AS total_orders,
    COALESCE(SUM(o.amount), 0)           AS total_amount,
    MAX(o.order_date)                    AS last_order_date
FROM Customers AS c
LEFT JOIN Orders    AS o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name;
GO


--10) “Fill in the gaps with the last non-zero value”
WITH M AS (
    SELECT
        g.RowNumber,
        g.TestCase,
        MAX(CASE WHEN g.TestCase IS NOT NULL THEN g.RowNumber END)
            OVER (ORDER BY g.RowNumber
                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS grpRow
    FROM Gaps AS g
)
SELECT
    m.RowNumber,
    (SELECT TOP(1) g2.TestCase
     FROM Gaps AS g2
     WHERE g2.RowNumber = m.grpRow) AS Workflow
FROM M AS m
ORDER BY m.RowNumber;
