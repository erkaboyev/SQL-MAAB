-- Level 1 – Basic Subqueries
-- 1) Employees with Minimum Salary
SELECT id, name, salary
FROM employees
WHERE salary = (SELECT MIN(salary) FROM employees);

-- 2) Products Above Average Price
SELECT id, product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- Level 2 – Nested Subqueries with Conditions
-- 3) Employees in Sales Department
SELECT id, name
FROM employees
WHERE department_id = (
    SELECT id FROM departments WHERE department_name = 'Sales'
);

-- 4) Customers with No Orders
SELECT c.customer_id, c.name
FROM customers AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders AS o
    WHERE o.customer_id = c.customer_id
);

-- Level 3 – Aggregation and Grouping in Subqueries
-- 5) Products with Max Price per Category
SELECT p.id, p.product_name, p.price, p.category_id
FROM products AS p
WHERE p.price = (
    SELECT MAX(price)
    FROM products AS x
    WHERE x.category_id = p.category_id
);

--6) Employees in Department with Highest Average Salary
SELECT e.id, e.name, e.salary, e.department_id
FROM employees AS e
WHERE e.department_id = (
    SELECT TOP 1 department_id
    FROM employees
    GROUP BY department_id
    ORDER BY AVG(salary) DESC
);


-- Level 4 – Correlated Subqueries
--7) Employees Earning Above Department Average
SELECT e.id, e.name, e.salary, e.department_id
FROM employees AS e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees AS d
    WHERE d.department_id = e.department_id
);


--8) Students with Highest Grade per Course
SELECT g.course_id, s.student_id, s.name, g.grade
FROM grades AS g
JOIN students AS s ON s.student_id = g.student_id
WHERE g.grade = (
    SELECT MAX(x.grade)
    FROM grades AS x
    WHERE x.course_id = g.course_id
);

-- Level 5 – Subqueries with Ranking and Complex Conditions
--9) Third-Highest Price per Category
SELECT id, product_name, price, category_id
FROM products AS p
WHERE 2 = (
    SELECT COUNT(DISTINCT x.price)
    FROM products AS x
    WHERE x.category_id = p.category_id
      AND x.price > p.price
);


--10) Employees with Salary Between Company Average and Department Max
SELECT e.id, e.name, e.salary, e.department_id
FROM employees AS e
WHERE e.salary > (SELECT AVG(salary) FROM employees)
  AND e.salary < (
      SELECT MAX(x.salary)
      FROM employees AS x
      WHERE x.department_id = e.department_id
  );
