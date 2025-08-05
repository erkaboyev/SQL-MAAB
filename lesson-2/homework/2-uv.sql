1. Creating the Employees Table
CREATE TABLE Employees (
    EmpID INT,
    Name VARCHAR(50),
    Salary DECIMAL(10,2)
);

2. Inserting recordings in different ways
INSERT INTO Employees (EmpID, Name, Salary) 
VALUES (1, 'Abdulaziz', 7692000.00);

INSERT INTO Employees 
VALUES (2, 'Ботиржон', 8648000.50);


INSERT INTO Employees (EmpID, Name, Salary) 
VALUES 
    (3, 'Дилшод', 5200000.85),
    (4, 'Илхом', 5200000.85),
    (5, 'Дилмурод', 26000000.00);

3. Updating an Employee's Salary
UPDATE Employees 
SET Salary = 7000.00 
WHERE EmpID = 1;

4. Deleting a recording
DELETE FROM Employees 
WHERE EmpID = 2;


5. The Differences Among DELETE, TRUNCATE, and DROP
DELETE - Selective deletion
- Deletes specific records based on a condition
- Records each deletion in the transaction log
- Can be rolled back using ROLLBACK
- Slower for large volumes of data
- Doesn't reset IDENTITY counters

TRUNCATE - Rapid clearing
- Deletes ALL records from the table
- Very fast operation
- Preserves the table structure
- Resets IDENTITY counters to their initial value
- Cannot be used with a WHERE condition

DROP - Complete removal
- Deletes the entire table (structure + data)
- Irreversible operation
- After this, the table ceases to exist

6. Resizing the Name column
ALTER TABLE Employees 
ALTER COLUMN Name VARCHAR(100);

7. Adding a New Department Column
ALTER TABLE Employees 
ADD Department VARCHAR(50);

8. Changing the data type of the Salary column
ALTER TABLE Employees 
ALTER COLUMN Salary FLOAT

9. Creating the Departments Table
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(50)
);

10. Deleting all records while preserving the structure
TRUNCATE TABLE Employees;

11. Insertion using INSERT INTO SELECT
INSERT INTO Departments (DepartmentID, DepartmentName)
SELECT DeptID, DeptName
FROM (VALUES 
    (206, 'Operations'),
    (207, 'Research'),
    (208, 'Quality Assurance'),
    (209, 'Customer Service'),
    (210, 'Legal')
) AS NewDepts(DeptID, DeptName);

12. Department update for high-paid employees
UPDATE Employees 
SET Department = 'Management' 
WHERE Salary > 5000;

13. Deleting all records while preserving the structure
TRUNCATE TABLE Employees

14. Delete the Department column from the Employees table
ALTER TABLE Employees 
DROP COLUMN Department;

15. Rename the "Employees" table to "StaffMembers"
EXEC sp_rename 'Employees', 'StaffMembers';

16. Delete the Departments table entirely
DROP TABLE Departments;

17. Create a Products table with 5 columns
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    DateAdded DATETIME DEFAULT GETDATE()
);

18. Adding a CHECK constraint for Price
ALTER TABLE Products
ADD CONSTRAINT CK_Products_Price_Positive 
CHECK (Price > 0);

19. Adding a StockQuantity column with a default value
ALTER TABLE Products
ADD StockQuantity INT DEFAULT 50;

20. Renaming the Category Column
EXEC sp_rename 'Products.Category', 'ProductCategory', 'COLUMN';

21. Inserting Data into the Products Table
INSERT INTO Products (ProductID, ProductName, ProductCategory, Price, StockQuantity)
VALUES 
	(1, 'ASUS ProBook Laptop', 'Electronics', 45999.99, 15),
	(2, 'Logitech Wireless Mouse', 'Accessories', 1299.50, 120),
	(3, 'Ergonomic Office Desk', 'Furniture', 12500.00, 8),
	(4, 'Samsung Monitor 27', 'Electronics', 18999.99, 25),
	(5, 'RGB Mechanical Keyboard', 'Accessories', 3499.00, 250);

22. Creating a Backup Using SELECT INTO
SELECT * 
INTO Products_Backup
FROM Products;

23. Renaming the "Products" table to "Inventory"
EXEC sp_rename 'Products', 'Inventory';

24. Changing the Price data type from DECIMAL to FLOAT
--First, remove the CHECK constraint
ALTER TABLE Inventory
DROP CONSTRAINT CK_Products_Price_Positive;
--I only changed the data type afterwards
ALTER TABLE Inventory
ALTER COLUMN Price FLOAT;
--Reinstated the CHEK restriction conditions
ALTER TABLE Inventory
ADD CONSTRAINT CK_Products_Price_Positive CHECK (Price > 0);

25. Adding a ProductCode column with the IDENTITY attribute
ALTER TABLE Inventory
ADD ProductCode INT IDENTITY(1000, 5) NOT NULL;
