1. What is BULK INSERT and why is it needed?
BULK INSERT is an SQL Server command designed for highly efficient loading of large volumes of data from external files 
(e.g., .txt, .csv) directly into database tables. It significantly speeds up importing compared to row-by-row insertion, 
especially when working with millions of records. BULK INSERT is useful for automating data loading from files using ETL processes, 
during data migration, and when building analytical dashboards.

Example:
BULK INSERT employees_lesson3
FROM 'C:\Users\User\Downloads\Telegram Desktop\employees_.csv'
WITH (
	FIRSTROW = 2,						-- Skip headers - start from the 2nd row
	FIELDTERMINATOR = ',',				-- Field separator (comma for CSV)
	ROWTERMINATOR = '\n',				-- Line separator (line break)
	ERRORFILE = 'C:\temp\errors.txt',	-- File for recording problematic lines
	MAXERRORS = 100,					-- Maximum number of errors before stopping the process
	TABLOCK								-- Table locking for better performance
);

2. Four file formats for importing into SQL Server:
CSV (Comma-Separated Values) can be compared to a universal translator. This format is understood by virtually all systems, 
is human-readable, and can be easily created in Excel. It is ideal for tabular data, exporting from other systems, 
and exchanging data between different platforms.

TXT (text files with separators) are similar to CSV, but use tabs or other characters as separators. 
They are often found in legacy systems and when exporting from older ERP systems.

XML (eXtensible Markup Language) can be thought of as a structured document with a clear hierarchy. 
It is ideal for complex data with a nested structure, configuration files, and data exchange between web services.

JSON (JavaScript Object Notation) is a modern standard for APIs and web applications. If XML is like a formal letter, 
then JSON is like an SMS—compact, fast, and efficient.

3. Creating the Products table: choosing the right data types
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,          
    ProductName VARCHAR(50) NOT NULL,             
    Price DECIMAL(10,2) NOT NULL                  
);

4.Data insertion: three ways to add records
INSERT INTO Products (ProductID, ProductName, Price)
VALUES 
    (1, 'ASUS laptop', 75000.00),
    (2, 'Wireless mouse', 2500.00),
    (3, 'Mechanical keyboard', 6500.00);

5. Differences between NULL and NOT NULL:
In SQL, NULL denotes the absence of a value — not “zero,” not “empty string,” but specifically unknown. 
This is used when the value is unknown, not applicable, or has not yet been entered.

NOT NULL is a constraint that prohibits storing NULL in a field. 
It ensures that the value will be filled in (for example, for mandatory fields involved in calculations or relationships).

Example:
Price DECIMAL(10,2) NULL     -- it is assumed that the price is unknown
Price DECIMAL(10,2) NOT NULL -- price is required

6. Adding a UNIQUE constraint:
ALTER TABLE Products
ADD CONSTRAINT UK_Products_ProductName UNIQUE (ProductName);

7.Comments in SQL:
In SQL, there are two ways to add a comment directly to the command line: using the symbols -- or /* ... */.
Example of a single-line comment:
 -- Select all products priced above 10,000 for analysis of the premium segment.
SELECT ProductID, ProductName, Price
FROM Products
WHERE Price > 10000;

Example of a multi-line comment:
/*
This query is used to generate a warehouse report.
It returns all items whose price is above average.
*/
SELECT ProductID, ProductName, Price
FROM Products
WHERE Price > (SELECT AVG(Price) FROM Products);

8. Adding the CategoryID column:
ALTER TABLE Products
ADD CategoryID INT;

9.  Creating the Categories table:
	CREATE TABLE Categories (
	CategoryID INT PRIMARY KEY, 
	CategoryName VARCHAR(50) UNIQUE NOT NULL
	);


10. IDENTITY column: 
IDENTITY is a property of a numeric column in SQL Server that allows you to automatically generate unique sequential values 
when inserting new rows. It eliminates the need to manually manage identifiers.

Syntax:
OrderID INT IDENTITY(seed, increment)

Example:
OrderID INT IDENTITY(1,1)  -- start with 1, increase by 1 with each insertion

It is typically used for primary keys (PRIMARY KEY) in tables where uniqueness and 
order of records are important (e.g., orders, transactions, event logs).


11. Using BULK INSERT to load from a file
/*
To complete task 11 from the third homework assignment, I cleared the Products table of old data using the 
TRUNCATE TABLE Products command (step 1).
Then I checked the result using the 
SELECT * FROM Products command (step 2). 
Using AI Claude.ai, I generated a data catalog for the query “Create a product catalog for a computer store containing 500 items. 
The file format is TXT, and the language is English. 
The table should contain the following columns: ProductID, ProductName, Price, and CategoryID. 
ProductID must be a unique identifier consisting only of numbers (INT PRIMARY KEY). 
Each product name must be unique (UNIQUE). 
ProductName must correspond to CategoryID. For example, 
all monitors belong to CategoryID with the identifier 8, 
all modems to CategoryID with the identifier 2, and so on.” and downloaded it to my laptop (step 3). 
*/
-- After that, I imported data from a text file into the Products table using the BULK INSERT command:
BULK INSERT Products
FROM 'C:\Users\User\Downloads\computer_store_catalog_2.txt'
WITH (
    FIRSTROW = 2,                    
    FIELDTERMINATOR = ',',           
    ROWTERMINATOR = '0x0a',            -- Standard end-of-line character
    ERRORFILE = 'C:\temp\errors.txt', 
    MAXERRORS = 100,                 
    CODEPAGE = '1252',               -- Windows Latin-1 for English text
    KEEPNULLS,                       -- We store empty values as NULL
    TABLOCK                          
);

--In the final stage of the task, I checked the download result. To do this, I used the following query (step 5):
SELECT COUNT(*) AS LoadedRecords FROM Products;

12. Creating a FOREIGN KEY: 
--For the FOREIGN KEY command to work correctly, you must first populate the Categories table with values (step 1):
	INSERT INTO Categories (CategoryID, CategoryName)
VALUES 
(1, 'Processors'),
(2, 'Modems'),
(3, 'Graphics Cards'),
(4, 'Motherboards'),
(5, 'Memory'),
(6, 'Storage'),
(7, 'Power Supplies'),
(8, 'Monitors'),
(9, 'Keyboards'),
(10, 'Mice'),
(11, 'Cases'),
(12, 'Cooling'),
(13, 'Networking'),
(14, 'Laptops'),
(15, 'Printers'),
(16, 'Speakers'),
(17, 'Webcams'),
(18, 'Cables & Adapters'),
(19, 'Software'),
(20, 'Accessories');

--Then link the Products and Categories tables (step 2)
ALTER TABLE Products
ADD CONSTRAINT FK_Products_Categories 
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID);

13. The difference between PRIMARY KEY and UNIQUE KEY
PRIMARY KEY:
Ensures the uniqueness and identifiability of each row.
There can only be one per table.
Fields cannot contain NULL values.
Automatically creates a clustered index if no other is specified.
Most often used in relationships via FOREIGN KEY.

UNIQUE KEY:
Ensures uniqueness, but does not necessarily identify a row.
You can have multiple UNIQUE constraints in a table.
Allows NULL (in SQL Server — only one NULL per constraint).
Creates a non-clustered index.
Used for business keys (e.g., Email, PassportNumber).

14. CHECK price limit:
-- Checking the existence of a restriction (Step 1)
IF EXISTS (SELECT * FROM sys.check_constraints 
           WHERE name = 'CK_Products_Price_Positive')
    ALTER TABLE Products DROP CONSTRAINT CK_Products_Price_Positive;

-- We're creating a new constraint with a new name CK_Products_Price_Positive_2 (Step 2)
ALTER TABLE Products
ADD CONSTRAINT CK_Products_Price_Positive_2 CHECK (Price > 0)

15. Adding a Stock column
ALTER TABLE Products
ADD Stock INT NOT NULL DEFAULT 0;

16. ISNULL function:
SELECT 
    ProductID,
    ProductName,
    ISNULL(Price, 0) AS SafePrice,      -- NULL is replaced with 0
    CategoryID
FROM Products;

17. FOREIGN KEY constraints: a detailed look 
A FOREIGN KEY is a constraint that ensures referential integrity between two tables.
It guarantees that values in the child table (Products.CategoryID) exist in the parent table (Categories.CategoryID).

Key features:
Protects against inserting “non-existent references”
Can be cascading (ON DELETE, ON UPDATE)
Can only refer to a PRIMARY KEY or UNIQUE field

Example:
--First, I'll remove the existing restriction (step 1):
ALTER TABLE Products
DROP CONSTRAINT FK_Products_Categories;

--Then add it again with the necessary cascade options: (step 2):
ALTER TABLE Products
ADD CONSTRAINT FK_Products_Categories
FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
ON DELETE CASCADE
ON UPDATE CASCADE;

18. Customers table with age verification
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Age INT,
    CONSTRAINT CK_Customers_Age_Adult CHECK (Age >= 18),
    DateOfBirth DATE,
    RegistrationDate DATETIME DEFAULT GETDATE(),
    PhoneNumber VARCHAR(20)
);

19. Create a table with an IDENTITY column
CREATE TABLE SpecialOrders (
    OrderID INT IDENTITY(1000, 10) PRIMARY KEY,  -- We start with 1000, step 10
    CustomerID INT NOT NULL,
    OrderValue DECIMAL(12,2),
    OrderDate DATETIME DEFAULT GETDATE(),
    Priority VARCHAR(20) DEFAULT 'Standard'
);

20. Composite PRIMARY KEY in the OrderDetails table
CREATE TABLE OrderDetails (
    OrderID INT,
    ProductID INT,
    Quantity INT NOT NULL DEFAULT 1,
    Price DECIMAL(10,2) NOT NULL,
    Discount DECIMAL(3,2) DEFAULT 0.00,
    CONSTRAINT PK_OrderDetails PRIMARY KEY (OrderID, ProductID)
);

21.The difference between ISNULL and COALESCE in SQL Server
ISNULL(expr, replacement)
Specific to SQL Server, not part of the ANSI standard.
Accepts exactly two arguments: if expr is NULL, replacement is returned.
The return type is determined by the first argument, which can lead to unexpected type casting.
Performs faster than COALESCE in simple expressions.
Not portable to other DBMS (does not work in PostgreSQL, MySQL, etc.).

COALESCE(expr1, expr2, ..., exprN)
Part of the ANSI SQL standard — works in all modern DBMS.
Accepts an unlimited number of arguments and returns the first NON-NULL value from left to right.
The result type is determined by the highest priority type among the arguments.
Internally converted by SQL Server to a CASE expression:

Comparison example:
-- ISNULL
SELECT ISNULL(NULL, 'Default')         -- → 'Default'

-- COALESCE
SELECT COALESCE(NULL, NULL, 'X', 'Y')  -- → 'X'

Practical conclusion:
Use ISNULL for simple two-argument replacements in SQL Server.

Use COALESCE when:
compatibility between DBMSs is required;
more than 2 values are needed;
it is important to flexibly manage the types and priorities of values.

22. Employees table with multiple constraints
CREATE TABLE Employees (
    EmpID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email NVARCHAR(255) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    Gender CHAR(1),
    DepartmentID INT,
    Salary DECIMAL(10,2),
    HireDate DATE DEFAULT GETDATE()
);

23. FOREIGN KEY with cascading operations

-- First, we create a parent table of departments.
CREATE TABLE Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName VARCHAR(100) UNIQUE NOT NULL,
    Budget DECIMAL(15,2),
    IsActive BIT DEFAULT 1
);

ALTER TABLE Employees
ADD CONSTRAINT FK_Employees_Department
    FOREIGN KEY (DepartmentID) 
    REFERENCES Departments(DepartmentID)
    ON DELETE CASCADE           -- Delete employees when deleting a department
    ON UPDATE CASCADE;          -- Update links when department ID changes
