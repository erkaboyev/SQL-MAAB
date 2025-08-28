/* ================================================
				   Lesson-12: Practice
   ================================================ */

--1) Combine Two Tables
SELECT 
    p.firstName,
    p.lastName,
    a.city,
    a.state
FROM Person AS p
LEFT JOIN Address AS a
  ON a.personId = p.personId
ORDER BY p.personId;


--2) Employees Earning More Than Their Managers
SELECT e.name AS Employee
FROM Employee AS e
JOIN Employee AS m
  ON m.id = e.managerId
WHERE e.salary > m.salary
ORDER BY e.name;


--3) Duplicate Emails
SELECT email AS Email
FROM Person
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY Email;


--4) Delete Duplicate Emails (keep the row with the lowest ID)
;WITH d AS
(
    SELECT 
        id,
        email,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS rn
    FROM Person
)
DELETE FROM d
WHERE rn > 1; 


--5) Parents who have only daughters (return only ParentName)
SELECT DISTINCT g.ParentName
FROM girls AS g
WHERE NOT EXISTS (
    SELECT 1
    FROM boys AS b
    WHERE b.ParentName = g.ParentName
)
ORDER BY g.ParentName;


--6) Total over 50 and least (TSQL2012.Sales.Orders)
SELECT 
    o.custid,
    SUM(CASE WHEN o.freight > 50 THEN o.freight END) AS TotalFreightOver50,
    MIN(o.freight)                                   AS LeastFreight
FROM TSQL2012.Sales.Orders AS o
GROUP BY o.custid
HAVING SUM(CASE WHEN o.freight > 50 THEN 1 ELSE 0 END) > 0   -- keep only those who had such orders
ORDER BY TotalFreightOver50 DESC, o.custid;


--7) Carts (FULL OUTER JOIN with alignment into two columns)
SELECT
    COALESCE(c1.Item, '') AS [Item Cart 1],
    COALESCE(c2.Item, '') AS [Item Cart 2]
FROM Cart1 AS c1
FULL OUTER JOIN Cart2 AS c2
  ON c2.Item = c1.Item
ORDER BY 
  CASE WHEN c1.Item IS NOT NULL AND c2.Item IS NOT NULL THEN 0
       WHEN c1.Item IS NOT NULL THEN 1
       ELSE 2 END,
  COALESCE(c1.Item, c2.Item)

  
--8) Customers Who Never Order
SELECT c.name AS Customers
FROM Customers AS c
LEFT JOIN Orders AS o
  ON o.customerId = c.id
WHERE o.id IS NULL
ORDER BY c.id;


--9) Students and Examinations (all students × all subjects + visit counter)
SELECT
    s.student_id,
    s.student_name,
    sub.subject_name,
    COUNT(e.subject_name) AS attended_exams
FROM Students AS s
CROSS JOIN Subjects AS sub
LEFT JOIN Examinations AS e
  ON e.student_id  = s.student_id
 AND e.subject_name = sub.subject_name
GROUP BY 
    s.student_id, 
    s.student_name, 
    sub.subject_name
ORDER BY s.student_id, sub.subject_name;
