/* ================================================
                 Lesson-17: Practice
   ================================================ */

--1) “Fill in missing sales figures for regions with zeros”
WITH R AS (SELECT DISTINCT Region      FROM #RegionSales),
     D AS (SELECT DISTINCT Distributor FROM #RegionSales)
SELECT 
    R.Region,
    D.Distributor,
    COALESCE(S.Sales, 0) AS Sales
FROM R
CROSS JOIN D
LEFT JOIN #RegionSales AS S
    ON S.Region = R.Region
   AND S.Distributor = D.Distributor
ORDER BY 
    D.Distributor,
    CASE R.Region WHEN 'North' THEN 1 WHEN 'South' THEN 2 
                  WHEN 'East'  THEN 3 WHEN 'West'  THEN 4 ELSE 5 END;

--2) “Managers with ≥5 direct reports”
SELECT m.name
FROM Employee AS m
JOIN Employee AS e
  ON e.managerId = m.id
GROUP BY m.name
HAVING COUNT(*) >= 5;

--3) “Products with orders totaling ≥100 in February 2020”
SELECT 
    p.product_name, 
    SUM(o.unit) AS unit
FROM Products AS p
JOIN Orders   AS o
  ON o.product_id = p.product_id
WHERE o.order_date >= '2020-02-01'
  AND o.order_date <  '2020-03-01'
GROUP BY p.product_name
HAVING SUM(o.unit) >= 100
ORDER BY p.product_name;

--4) “Vendor with the highest number of orders per customer”
WITH S AS (
  SELECT CustomerID, Vendor, SUM([Count]) AS total_cnt
  FROM Orders
  GROUP BY CustomerID, Vendor
),
R AS (
  SELECT S.*,
         ROW_NUMBER() OVER (PARTITION BY CustomerID 
                            ORDER BY total_cnt DESC, Vendor) AS rn
  FROM S
)
SELECT CustomerID, Vendor
FROM R
WHERE rn = 1
ORDER BY CustomerID;

--5) “Checking a prime number using WHILE”
DECLARE @Check_Prime INT = 91;  -- пример
DECLARE @i INT = 2, @isPrime BIT = 1;

IF @Check_Prime < 2 
    SET @isPrime = 0;
ELSE
BEGIN
    WHILE @i <= FLOOR(SQRT(@Check_Prime)) AND @isPrime = 1
    BEGIN
        IF @Check_Prime % @i = 0 
            SET @isPrime = 0;
        SET @i += 1;
    END
END

SELECT CASE WHEN @isPrime = 1 
            THEN 'This number is prime' 
            ELSE 'This number is not prime' 
       END AS Result;

--6) “By device: number of locations, leading location, and total signals”
WITH C AS (  -- counts per device/location
  SELECT Device_id, Locations, COUNT(*) AS cnt
  FROM Device
  GROUP BY Device_id, Locations
),
A AS (  -- aggregates per device
  SELECT Device_id,
         COUNT(DISTINCT Locations) AS no_of_location,
         SUM(cnt)                  AS no_of_signals
  FROM C
  GROUP BY Device_id
),
Pick AS ( -- pick top location per device
  SELECT Device_id, Locations,
         ROW_NUMBER() OVER (PARTITION BY Device_id 
                            ORDER BY cnt DESC, Locations) AS rn
  FROM C
)
SELECT 
  A.Device_id,
  A.no_of_location,
  P.Locations AS max_signal_location,
  A.no_of_signals
FROM A
JOIN Pick AS P
  ON P.Device_id = A.Device_id AND P.rn = 1
ORDER BY A.Device_id;

--7) “Employees with salaries above the department average”
WITH X AS (
  SELECT *, AVG(Salary) OVER (PARTITION BY DeptID) AS dept_avg
  FROM Employee
)
SELECT EmpID, EmpName, Salary
FROM X
WHERE Salary > dept_avg
ORDER BY EmpID;

--8) “Lottery: calculate the total winnings ($10 for an incomplete match, $100 for a complete match)”
WITH W AS (SELECT COUNT(*) AS win_cnt FROM Numbers),
M AS (
  SELECT t.TicketID, COUNT(n.Number) AS match_cnt
  FROM Tickets AS t
  LEFT JOIN Numbers AS n
    ON n.Number = t.Number
  GROUP BY t.TicketID
),
Payout AS (
  SELECT m.TicketID,
         CASE 
           WHEN m.match_cnt = w.win_cnt THEN 100
           WHEN m.match_cnt BETWEEN 1 AND w.win_cnt - 1 THEN 10
           ELSE 0
         END AS prize
  FROM M AS m
  CROSS JOIN W AS w
)
SELECT SUM(prize) AS Total_Winnings
FROM Payout;

--9) “User Purchase Platform: Mobile, Desktop, and Both for each date”
WITH Base AS (
  SELECT 
    Spend_date,
    Platform,
    SUM(Amount)              AS Total_Amount,
    COUNT(DISTINCT User_id)  AS Total_users
  FROM Spending
  GROUP BY Spend_date, Platform
),
BothRows AS (
  SELECT 
    Spend_date,
    'Both' AS Platform,
    SUM(Amount)              AS Total_Amount,
    COUNT(DISTINCT User_id)  AS Total_users
  FROM Spending
  GROUP BY Spend_date
),
AllRows AS (
  SELECT * FROM Base
  UNION ALL
  SELECT * FROM BothRows
)
SELECT 
  ROW_NUMBER() OVER (
    ORDER BY Spend_date,
             CASE Platform WHEN 'Mobile' THEN 1 WHEN 'Desktop' THEN 2 ELSE 3 END
  ) AS Row,
  Spend_date, Platform, Total_Amount, Total_users
FROM AllRows
ORDER BY Spend_date,
         CASE Platform WHEN 'Mobile' THEN 1 WHEN 'Desktop' THEN 2 ELSE 3 END;


--10) “Ungroup (spread out) the quantity in the row”
;WITH N AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1
  FROM N
  WHERE n < (SELECT MAX(Quantity) FROM Grouped)
)
SELECT g.Product, 1 AS Quantity
FROM Grouped AS g
JOIN N 
  ON N.n <= g.Quantity
ORDER BY g.Product
OPTION (MAXRECURSION 0);
