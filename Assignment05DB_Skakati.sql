--*************************************************************************--
-- Title: Assignment05
-- Author: Shruti Kakati
-- Desc: This file demonstrates how to use Joins and Subqueiers
-- Change Log: 
-- 11-12-2021, Shruti Kakati : Created Database with name as 'Assignment05DB_ShrutiKakati'
-- 11-12-2021, Shruti Kakati : Created 3 tables as Categories, Products, Inventories, Employees
-- 11-12-2021, Shruti Kakati : Inserted Data into all 4 above mentioned tables
-- 11-15-2021, Shruti Kakati : Answered all the database questions
--**************************************************************************--
Use Master;
go

If Exists(Select Name From SysDatabases Where Name = 'Assignment05DB_ShrutiKakati')
 Begin 
  Alter Database [Assignment05DB_ShrutiKakati] set Single_user With Rollback Immediate;
  Drop Database Assignment05DB_ShrutiKakati;
 End
go

Create Database Assignment05DB_ShrutiKakati;
go

Use Assignment05DB_ShrutiKakati;
go

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go


Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
-- Question 1 (10 pts): 
-- How can you show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product?

SELECT      c.CategoryName, 
            p.ProductName, 
            p.UnitPrice
FROM        Categories c 
INNER JOIN  Products p
ON          c.CategoryID = p.CategoryID
ORDER BY    c.CategoryName, p.ProductName ASC
GO

-- Question 2 (10 pts): How can you show a list of Product name 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Date, Product,  and Count!

SELECT      p.ProductName, 
            i.InventoryDate,
            i.Count
FROM        Products p
INNER JOIN  Inventories i 
ON          p.ProductID = i.ProductID
GROUP BY    i.InventoryDate, p.ProductName, i.Count
ORDER BY    i.InventoryDate, p.ProductName, i.Count ASC
GO

-- Question 3 (10 pts): How can you show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

SELECT  DISTINCT    i.InventoryDate,
                    e.EmployeeFirstName + ' '+
                    e.EmployeeLastName as Employee_Name
FROM                Inventories i
INNER JOIN          Employees e
ON                  i.EmployeeID = e.EmployeeID
WHERE               e.EmployeeID IN (SELECT DISTINCT EmployeeID FROM Inventories)
ORDER BY            i.InventoryDate ASC
GO

-- Question 4 (10 pts): How can you show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
SELECT      c.CategoryName,
            p.ProductName,
            i.InventoryDate,
            i.Count

FROM        Categories c 
INNER JOIN  Products p
ON          p.CategoryID = c.CategoryID
INNER JOIN  Inventories i 
ON          p.ProductID = i.ProductID
ORDER BY    c.CategoryName,
            p.ProductName,
            i.InventoryDate,
            i.Count
            ASC
GO
-- Question 5 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

SELECT      c.CategoryName,
            p.ProductName,
            i.InventoryDate,
            i.Count,
            e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee_Name
FROM        Categories c 
INNER JOIN  Products p
ON          p.CategoryID = c.CategoryID
INNER JOIN  Inventories i 
ON          p.ProductID = i.ProductID
INNER JOIN  Employees e 
ON          e.EmployeeID = i.EmployeeID
ORDER BY    i.InventoryDate,
            c.CategoryName,
            p.ProductName,
            e.EmployeeFirstName + ' ' + e.EmployeeLastName 
            ASC
GO

-- Question 6 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
-- For Practice; Use a Subquery to get the ProductID based on the Product Names 
-- and order the results by the Inventory Date, Category, and Product!

--NOTE: As i assume that order by clause was to apply for both the queries (question and practise) 
--so applying order by for both queries

SELECT      c.CategoryName,
            p.ProductName,
            i.InventoryDate,
            i.Count,
            e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee_Name
FROM        Categories c 
INNER JOIN  Products p
ON          p.CategoryID = c.CategoryID
INNER JOIN  Inventories i 
ON          p.ProductID = i.ProductID
INNER JOIN  Employees e 
ON          e.EmployeeID = i.EmployeeID
WHERE       p.ProductName = 'Chai' OR ProductName = 'Chang'
ORDER BY    i.InventoryDate, 
            c.CategoryName, 
            p.ProductName
            ASC
GO

-- Practise Query : Use a Subquery to get the ProductID based on the Product Names 
-- and order the results by the Inventory Date, Category, and Product!

SELECT      c.CategoryName,
            p.ProductID,
            p.ProductName,
            i.InventoryDate,
            i.Count,
            e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee_Name
FROM        Categories c 
INNER JOIN  Products p
ON          p.CategoryID = c.CategoryID
INNER JOIN  Inventories i 
ON          p.ProductID = i.ProductID
INNER JOIN  Employees e 
ON          e.EmployeeID = i.EmployeeID
WHERE       p.ProductID  IN ( SELECT ProductID 
                                FROM    Products
                                WHERE   ProductName = 'Chai'
                                OR      ProductName = 'Chang'
                                )
ORDER BY    i.InventoryDate, 
            c.CategoryName, 
            p.ProductName
            ASC
GO
-- Question 7 (20 pts): How can you show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

WITH CTE AS
(
    SELECT DISTINCT m.ManagerID as manager_id, 
                    e.Employeefirstname+ ' ' +e.EmployeeLastName AS Manager_Name
    FROM            Employees e, Employees m
    WHERE           e.EmployeeID = m.ManagerID
),
CTE1 AS
(
    SELECT      b.ManagerID AS manager1_id, 
                b.EmployeeFirstName+ ' ' +b.EmployeeLastName AS Employee_Name
    FROM        Employees b
    WHERE       b.ManagerID IN (SELECT ManagerID FROM Employees)
)
SELECT      a.Manager_Name, b.Employee_Name
FROM        cte a 
INNER JOIN  cte1 b 
ON          a.manager_id = b.manager1_id
ORDER BY    a.Manager_Name ASC
GO

/***************************************************************************************/