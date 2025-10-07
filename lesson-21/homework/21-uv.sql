/* ================================================
		          Lesson 21 WINDOW FUNCTIONS
   ================================================ */

--1) Number sales by date (ROW_NUMBER)
SELECT
  SaleID, ProductName, SaleDate, SaleAmount, Quantity, CustomerID,
  ROW_NUMBER() OVER (ORDER BY SaleDate, SaleID) AS RowNumByDate
FROM ProductSales
ORDER BY SaleDate, SaleID;


--2) Product ranking by total quantity (without gaps in the ranks)
SELECT
  ProductName,
  SUM(Quantity) AS TotalQty,
  DENSE_RANK() OVER (ORDER BY SUM(Quantity) DESC) AS QtyRank
FROM ProductSales
GROUP BY ProductName
ORDER BY QtyRank, ProductName;


--3) Top sales by amount for each customer
WITH ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY CustomerID
           ORDER BY SaleAmount DESC, SaleDate DESC, SaleID DESC
         ) AS rn
  FROM ProductSales
)
SELECT SaleID, CustomerID, SaleDate, SaleAmount, ProductName, Quantity
FROM ranked
WHERE rn = 1
ORDER BY CustomerID;


--4) Current amount and next amount (by date) — LEAD
SELECT
  SaleID, SaleDate, SaleAmount,
  LEAD(SaleAmount) OVER (ORDER BY SaleDate, SaleID) AS NextSaleAmount
FROM ProductSales
ORDER BY SaleDate, SaleID;


--5) Current amount and previous amount — LAG
SELECT
  SaleID, SaleDate, SaleAmount,
  LAG(SaleAmount) OVER (ORDER BY SaleDate, SaleID) AS PrevSaleAmount
FROM ProductSales
ORDER BY SaleDate, SaleID;


--6) Sales where the amount is greater than the previous one
WITH x AS (
  SELECT
    *,
    LAG(SaleAmount) OVER (ORDER BY SaleDate, SaleID) AS PrevAmt
  FROM ProductSales
)
SELECT SaleID, SaleDate, ProductName, SaleAmount, PrevAmt
FROM x
WHERE PrevAmt IS NOT NULL AND SaleAmount > PrevAmt
ORDER BY SaleDate, SaleID;


--7) Difference from previous sale within the product
SELECT
  ProductName, SaleID, SaleDate, SaleAmount,
  SaleAmount
    - LAG(SaleAmount) OVER (
        PARTITION BY ProductName
        ORDER BY SaleDate, SaleID
      ) AS DiffFromPrevInProduct
FROM ProductSales
ORDER BY ProductName, SaleDate, SaleID;


--8) % change to next sale (by date)
WITH x AS (
  SELECT
    SaleID, SaleDate, SaleAmount,
    LEAD(SaleAmount) OVER (ORDER BY SaleDate, SaleID) AS NextAmt
  FROM ProductSales
)
SELECT
  SaleID, SaleDate, SaleAmount, NextAmt,
  CASE WHEN NextAmt IS NULL OR SaleAmount = 0 THEN NULL
       ELSE (NextAmt - SaleAmount) * 100.0 / SaleAmount
  END AS PctChangeToNext
FROM x
ORDER BY SaleDate, SaleID;


--9) Ratio of current amount to previous amount within the product
WITH x AS (
  SELECT *,
         LAG(SaleAmount) OVER (
           PARTITION BY ProductName
           ORDER BY SaleDate, SaleID
         ) AS PrevAmt
  FROM ProductSales
)
SELECT
  ProductName, SaleID, SaleDate, SaleAmount, PrevAmt,
  CASE WHEN PrevAmt IS NULL OR PrevAmt = 0 THEN NULL
       ELSE SaleAmount / PrevAmt
  END AS RatioToPrev
FROM x
ORDER BY ProductName, SaleDate, SaleID;


--10) Difference from the very first sale of the product
SELECT
  ProductName, SaleID, SaleDate, SaleAmount,
  FIRST_VALUE(SaleAmount) OVER (
      PARTITION BY ProductName
      ORDER BY SaleDate, SaleID
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS FirstAmt,
  SaleAmount -
  FIRST_VALUE(SaleAmount) OVER (
      PARTITION BY ProductName
      ORDER BY SaleDate, SaleID
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS DiffFromFirst
FROM ProductSales
ORDER BY ProductName, SaleDate, SaleID;


--11) Products where sales are strictly increasing (each > previous)
WITH x AS (
  SELECT
    ProductName, SaleDate, SaleAmount,
    LAG(SaleAmount) OVER (
      PARTITION BY ProductName
      ORDER BY SaleDate, SaleID
    ) AS PrevAmt
  FROM ProductSales
)
SELECT ProductName
FROM x
GROUP BY ProductName
HAVING SUM(CASE WHEN PrevAmt IS NOT NULL AND SaleAmount <= PrevAmt THEN 1 ELSE 0 END) = 0;


--12) Closing balance: cumulative total amount
SELECT
  SaleID, SaleDate, SaleAmount,
  SUM(SaleAmount) OVER (ORDER BY SaleDate, SaleID
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM ProductSales
ORDER BY SaleDate, SaleID;



--13) Moving average for the last 3 sales
SELECT
  SaleID, SaleDate, SaleAmount,
  AVG(SaleAmount) OVER (
    ORDER BY SaleDate, SaleID
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ) AS MovingAvg3
FROM ProductSales
ORDER BY SaleDate, SaleID;


--14) Deviation from the average check for all sales
SELECT
  SaleID, SaleDate, SaleAmount,
  AVG(SaleAmount) OVER () AS AvgAll,
  SaleAmount - AVG(SaleAmount) OVER () AS DiffFromAvg
FROM ProductSales
ORDER BY SaleDate, SaleID;



--15) Employees with the same salary rank (there is “tai”)
WITH r AS (
  SELECT *,
         DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalRank
  FROM Employees1
)
SELECT EmployeeID, Name, Department, Salary, SalRank
FROM r
WHERE COUNT(*) OVER (PARTITION BY SalRank) > 1
ORDER BY SalRank, Salary DESC, EmployeeID;


--16) Top 2 salaries in each department (including “taj”)
WITH r AS (
  SELECT *,
         DENSE_RANK() OVER (
           PARTITION BY Department
           ORDER BY Salary DESC
         ) AS rk
  FROM Employees1
)
SELECT EmployeeID, Name, Department, Salary
FROM r
WHERE rk <= 2
ORDER BY Department, Salary DESC, EmployeeID;


--17) The lowest paid in the department (including “taj”)
WITH r AS (
  SELECT *,
         DENSE_RANK() OVER (
           PARTITION BY Department
           ORDER BY Salary ASC
         ) AS rk
  FROM Employees1
)
SELECT EmployeeID, Name, Department, Salary
FROM r
WHERE rk = 1
ORDER BY Department, EmployeeID;


--18) Cumulative total of salaries in the department (by date of hire)
SELECT
  EmployeeID, Name, Department, HireDate, Salary,
  SUM(Salary) OVER (
    PARTITION BY Department
    ORDER BY HireDate, EmployeeID
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS DeptRunningTotal
FROM Employees1
ORDER BY Department, HireDate, EmployeeID;



--19) Total salary for the department without GROUP BY
SELECT DISTINCT
  Department,
  SUM(Salary) OVER (PARTITION BY Department) AS DeptTotalSalary
FROM Employees1
ORDER BY Department;


--20) Average salary per department without GROUP BY
SELECT DISTINCT
  Department,
  AVG(Salary) OVER (PARTITION BY Department) AS DeptAvgSalary
FROM Employees1
ORDER BY Department;


--21) Salary deviation from the department average
SELECT
  EmployeeID, Name, Department, Salary,
  AVG(Salary) OVER (PARTITION BY Department) AS DeptAvgSalary,
  Salary - AVG(Salary) OVER (PARTITION BY Department) AS DiffFromDeptAvg
FROM Employees1
ORDER BY Department, Salary DESC, EmployeeID;



--22) Moving average salary per department for 3 employees (previous-current-next)
SELECT
  EmployeeID, Name, Department, HireDate, Salary,
  AVG(Salary) OVER (
    PARTITION BY Department
    ORDER BY HireDate, EmployeeID
    ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
  ) AS DeptMovingAvg3
FROM Employees1
ORDER BY Department, HireDate, EmployeeID;



--23) Total salaries of the last three hires (across the entire company)
WITH seq AS (
  SELECT *,
         ROW_NUMBER() OVER (ORDER BY HireDate DESC, EmployeeID DESC) AS rn
  FROM Employees1
)
SELECT SUM(Salary) AS SumOfLast3Hires
FROM seq
WHERE rn <= 3;
