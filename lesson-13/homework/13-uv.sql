/* ================================================
		Lesson-13: Practice: String Functions,
				Mathematical Functions
   ================================================ */

/* -------------------- EASY -------------------- */

--1) “100-Steven King” (generalized for all)
SELECT CONCAT(EMPLOYEE_ID, '-', FIRST_NAME, ' ', LAST_NAME) AS EmpLabel
FROM Employees;


--2) Replace 124 → 999 in PHONE_NUMBER
UPDATE Employees
SET PHONE_NUMBER = REPLACE(PHONE_NUMBER, '124', '999');


--3) Names starting with A/J/M + name length, sorted by name
SELECT FIRST_NAME,
       LEN(FIRST_NAME) AS FirstNameLength
FROM Employees
WHERE FIRST_NAME LIKE '[AJM]%'
ORDER BY FIRST_NAME;


--4) Total salary for each MANAGER_ID
SELECT MANAGER_ID, SUM(SALARY) AS TotalSalary
FROM Employees
GROUP BY MANAGER_ID
ORDER BY MANAGER_ID;


--5) For each line, TestMax is the maximum of Max1/Max2/Max3.
SELECT  t.Year1,
        MAX(v.Val) AS RowMax
FROM TestMax AS t
CROSS APPLY (VALUES(t.Max1),(t.Max2),(t.Max3)) AS v(Val)
GROUP BY t.Year1;


--6) Odd films and descriptions that are not “boring”
SELECT id, movie, [description], rating
FROM cinema
WHERE id % 2 = 1
  AND [description] <> 'boring';


--7) Sort SingleOrder by Id, but Id=0 — always at the bottom (one column in ORDER BY)
SELECT Id, Vals
FROM SingleOrder
ORDER BY CASE WHEN Id=0 THEN 1 ELSE 0 END, Id;


--8) The first non-zero of several columns (person)
SELECT id,
       COALESCE(ssn, passportid, itin) AS first_non_null
FROM person;



/* -------------------- MEDIUM -------------------- */

--9) Split Students.FullName into First/Middle/Last
SELECT  s.StudentID,
        s.FullName,
        -- first
        LEFT(s.FullName, CHARINDEX(' ', s.FullName + ' ') - 1)				AS FirstName,
        -- last
        RIGHT(s.FullName, CHARINDEX(' ', REVERSE(s.FullName + ' ')) - 1)	AS LastName,
        -- middle (everything between the first and last word; can be NULL)
        NULLIF(
          LTRIM(RTRIM(
            SUBSTRING(
              s.FullName,
              CHARINDEX(' ', s.FullName + ' ') + 1,
              LEN(s.FullName)
              - (CHARINDEX(' ', s.FullName + ' ') )
              - (CHARINDEX(' ', REVERSE(s.FullName + ' ')) - 1)
            )
          )),
        '') AS MiddleName
FROM Students AS s;


--10) Customers who had deliveries to CA and their orders with deliveries to TX
SELECT o.*
FROM Orders AS o
WHERE o.DeliveryState = 'TX'
  AND EXISTS (
        SELECT 1
        FROM Orders AS i
        WHERE i.CustomerID = o.CustomerID
          AND i.DeliveryState = 'CA'
      );


--11) “Glue” rows from DMLTable by SequenceNumber
SELECT STRING_AGG([String], ' ') WITHIN GROUP (ORDER BY SequenceNumber) AS ReconstructedQuery
FROM DMLTable;


--12) The name contains the letter a ≥ 3 times (case-insensitive)
SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME
FROM Employees
WHERE
  (LEN(LOWER(FIRST_NAME) + LOWER(LAST_NAME))
 - LEN(REPLACE(LOWER(FIRST_NAME) + LOWER(LAST_NAME), 'a', ''))) >= 3;



/* -------------------- HARD -------------------- */

--13) By department: total number of employees and percentage with > 3 years of service
DECLARE @s varchar(100) = 'tf56sd#%OqH';

;WITH Tally(n) AS (
    SELECT TOP (LEN(@s))
           ROW_NUMBER() OVER (ORDER BY (SELECT 1))
    FROM sys.all_objects
),
Chars AS (
    SELECT SUBSTRING(@s, n, 1) AS ch
    FROM Tally
)
SELECT
  STRING_AGG(CASE WHEN ch COLLATE Latin1_General_CS_AS BETWEEN 'A' AND 'Z' THEN ch END, '')		AS UppercaseLetters,
  STRING_AGG(CASE WHEN ch COLLATE Latin1_General_CS_AS BETWEEN 'a' AND 'z' THEN ch END, '')		AS LowercaseLetters,
  STRING_AGG(CASE WHEN ch BETWEEN '0' AND '9' THEN ch END, '')									AS Digits,
  STRING_AGG(CASE WHEN NOT (
                         ch BETWEEN '0' AND '9'
                         OR ch COLLATE Latin1_General_CS_AS BETWEEN 'A' AND 'Z'
                         OR ch COLLATE Latin1_General_CS_AS BETWEEN 'a' AND 'z'
                       )
                  THEN ch END, '')																AS Others
FROM Chars;


--16) “Cumulative” amount for students (the current and all previous lines are added together)
SELECT StudentID, FullName, Grade,
       SUM(Grade) OVER (ORDER BY StudentID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningGradeTotal
FROM Students
ORDER BY StudentID;


--17) Calculate the expressions in Equations and write them down in TotalSum.
;WITH Parts AS (
    SELECT  e.Equation,
            s.value
    FROM Equations AS e
    CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(e.Equation, '-', '+-'), '++', '+'), '+') AS s
)
UPDATE e
SET TotalSum = x.SumVal
FROM Equations AS e
JOIN (
    SELECT Equation,
           SUM(CAST(value AS int)) AS SumVal
    FROM Parts
    WHERE value <> ''   -- отсекаем пустые куски
    GROUP BY Equation
) AS x
  ON x.Equation = e.Equation;

SELECT * FROM Equations ORDER BY Equation;


--18) Students with the same birthday
SELECT StudentName, Birthday
FROM Student
WHERE Birthday IN (
    SELECT Birthday
    FROM Student
    GROUP BY Birthday
    HAVING COUNT(*) > 1
)
ORDER BY Birthday, StudentName;


--19) Total score for unique pairs of players (A,B) == (B,A)
WITH Norm AS (
    SELECT  CASE WHEN PlayerA < PlayerB THEN PlayerA ELSE PlayerB END AS A,
            CASE WHEN PlayerA < PlayerB THEN PlayerB ELSE PlayerA END AS B,
            Score
    FROM PlayerScores
)
SELECT A AS PlayerA, B AS PlayerB, SUM(Score) AS TotalScore
FROM Norm
GROUP BY A, B
ORDER BY A, B;
