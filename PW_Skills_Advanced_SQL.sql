-- PW Skills SQL Advance
-- 1- What is a Common Table Expression (CTE), and how does it improve SQL query readability?
-- Ans- A Common Table Expression (CTE) is a temporary, named result set you define using WITH.
-- It exists only for that one query and helps you break big, ugly SQL into clean, readable steps.
-- Syntax:-
-- WITH cte_name AS (
--     SELECT column1, column2
--     FROM table_name
--     WHERE condition
-- )
-- SELECT *
-- FROM cte_name;

-- 2- Why are some views updatable while others are read-only? Explain with an example.
-- Ans- A view is updatable only when the database can clearly map each row in the view back to exactly one row in one base table.
-- If that mapping gets blurry → view becomes read-only.
--  Example:-
-- CREATE VIEW HighSalaryEmployees AS
-- SELECT employee_id, employee_name, salary
-- FROM Employees
-- WHERE salary > 60000;

-- 3- What advantages do stored procedures offer compared to writing raw SQL queries repeatedly?
-- Ans- a- Better performance 
-- SQL gets precompiled
-- Execution plans are reused
-- Less parsing every time
-- Especially clutch when the same logic runs a lot.

-- b- Security boost 
-- Users can get permission to execute a procedure
-- Without access to the actual tables
-- This reduces SQL injection risk big time.

-- c- Centralized business logic
-- Logic stays in one place (the database), not scattered across apps.
-- Change it once → affects all applications using it.
-- Super maintainable.

-- d- Reduced network traffic 📉
-- Instead of sending multiple SQL statements from the app, you:
-- send one procedure call
-- DB handles the rest internally
-- Faster, cleaner.

-- 4-  What is the purpose of triggers in a database? Mention one use case where a trigger is essential.
-- Ans- A trigger is a special database object that automatically executes when a specific event happens on a table.
-- Events can be :- 
-- INSERT, UPDATE, DELETE.
-- Scenario:-
-- You want to track salary changes for employees — who changed it, and when.
-- This cannot rely on application code alone (too risky).
-- CREATE TRIGGER salary_audit_trigger
-- AFTER UPDATE ON Employees
-- FOR EACH ROW
-- BEGIN
--     INSERT INTO Salary_Audit (
--         employee_id,
--         old_salary,
--         new_salary,
--         changed_on
--     )
--     VALUES (
--         OLD.employee_id,
--         OLD.salary,
--         NEW.salary,
--         CURRENT_TIMESTAMP
--     );
-- END;


-- 5-  Explain the need for data modelling and normalization when designing a database.
-- Ans-  Data modelling is basically the blueprint of your database.
-- It defines what data to store, how tables relate, and how data flows.
-- Why it matters
-- Avoids messy, inconsistent data
-- Makes relationships clear (PK–FK vibes)
-- Helps devs + analysts speak the same language
-- Saves you from painful redesigns later

-- Why normalization is needed
-- Normalization is the process of organizing data to:
-- reduce redundancy
-- prevent data anomalies
-- maintain data integrity

-- Creating Database 
create database marketing_db;
-- Creating Table
create table products (
Product_id int primary key,
Product_Name varchar(100),
Category varchar(50),
Price Decimal (10, 2)
);

-- Inserting Data
Insert into products
Values 
(1,'Keyboard','Electronics',1200),
(2,'Mouse','Electronics',800),
(3,'Chair','Furniture',2500),
(4,'Desk','Furniture',5500);

Create table sales (
sales_id int Primary Key,
Product_id int,
Quantity int,
Sale_Date Date,
foreign key (Product_id) references products (Product_id)
);

-- Inserting Data
Insert into sales
Values 
(1,1,4,'2024-01-05'),
(2,2,10,'2024-01-06'),
(3,3,2,'2024-01-10'),
(4,4,1,'2024-01-11');

-- Q6. Write a CTE to calculate the total revenue for each product.
--  (Revenues = Price × Quantity), and return only products where  revenue > 3000.
WITH ProductRevenue AS (
    SELECT
        p.Product_id,
        p.Product_Name,
        SUM(p.Price * s.Quantity) AS Total_Revenue
    FROM products p
    JOIN sales s
        ON p.Product_id = s.Product_id
    GROUP BY
        p.Product_id,
        p.Product_Name
)
SELECT
    Product_id,
    Product_Name,
    Total_Revenue
FROM ProductRevenue
WHERE Total_Revenue > 3000;

-- Q7. Create a view named vw_CategorySummary that shows:
--  Category, TotalProducts, AveragePrice.
CREATE VIEW vw_CategorySummary AS
SELECT
    Category,
    COUNT(Product_id) AS TotalProducts,
    AVG(Price) AS AveragePrice
FROM products
GROUP BY Category;

-- Q8. Create an updatable view containing ProductID, ProductName, and Price.
--  Then update the price of ProductID = 1 using the view.
CREATE VIEW vw_ProductPrice AS
SELECT
    Product_id,
    Product_Name,
    Price
FROM products;

UPDATE vw_ProductPrice
SET Price = 1500
WHERE Product_id = 1;

-- Q9. Create a stored procedure that accepts a category name and returns all products belonging to that
-- category.
DELIMITER $$

CREATE PROCEDURE GetProductsByCategory (
    IN p_category VARCHAR(50)
)
BEGIN
    SELECT
        Product_id,
        Product_Name,
        Category,
        Price
    FROM products
    WHERE Category = p_category;
END $$

DELIMITER ;

CALL GetProductsByCategory('Electronics');

-- Q10. Create an AFTER DELETE trigger on the table that archives deleted product rows into a new table ProductArchieve. The archive should store ProductID, ProductName, Category, Price, and DeletedAt
-- timestamp.
CREATE TABLE ProductArchieve (
    ProductID INT,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    DeletedAt TIMESTAMP
);

DELIMITER $$

CREATE TRIGGER trg_after_product_delete
AFTER DELETE ON products
FOR EACH ROW
BEGIN
    INSERT INTO ProductArchieve (
        ProductID,
        ProductName,
        Category,
        Price,
        DeletedAt
    )
    VALUES (
        OLD.Product_id,
        OLD.Product_Name,
        OLD.Category,
        OLD.Price,
        CURRENT_TIMESTAMP
    );
END $$

DELIMITER ;

