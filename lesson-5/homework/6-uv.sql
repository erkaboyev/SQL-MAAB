/* ===================
   Lesson-6: Practice
   ==================== */

/*  Puzzle 1: Finding Distinct Values  */
SELECT DISTINCT
  CASE WHEN col1 <= col2 THEN col1 ELSE col2 END AS col1,
  CASE WHEN col1 <= col2 THEN col2 ELSE col1 END AS col2
FROM InputTbl
ORDER BY col1, col2;

--or
SELECT col1, col2
FROM InputTbl
WHERE col1 <= col2
UNION
SELECT col2, col1
FROM InputTbl
WHERE col2 < col1;

/*  Puzzle 2: Removing Rows with All Zeroes  */
SELECT *
FROM TestMultipleZero
WHERE NOT (A = 0 AND B = 0 AND C = 0 AND D = 0);

/*  Puzzle 3: Find Those with Odd IDs  */
SELECT *
FROM section1
WHERE id % 2 <> 0;

/*  Puzzle 4: Person with the Smallest ID  */
SELECT TOP (1) *
FROM section1
ORDER BY id ASC;

--or
SELECT id, name 
FROM section1 
WHERE id = (SELECT MIN(id) FROM section1);

/*  Puzzle 5: Person with the Highest ID  */
SELECT TOP (1) *
FROM section1
ORDER BY id DESC;

--or
SELECT *
FROM section1
WHERE id = (SELECT MAX(id) FROM section1);

/*  Puzzle 6: People Whose Name Starts with 'b'  */
SELECT *
FROM section1
WHERE name LIKE '[bB]%';

/*  Puzzle 7: Find Rows with Literal Underscore  */
SELECT *
FROM ProductCodes
WHERE Code LIKE '%[_]%';
