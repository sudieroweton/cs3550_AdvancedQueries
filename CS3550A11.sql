--Sudie Roweton
--CS3550 Spring 2016
--Assignment 11 : Pivot Queries

USE AdventureWorks2008R2;
-------------------------------------------------------------
--1 Display the name of the day, the average online
-- order sales subtotal and the in-store sales subtotal 
-- for each day of the week
--------------------------------------------------------------
SELECT [Date], [1] AS "Average Online Orders", [0] AS "Average In-store Orders"
FROM
(SELECT DATENAME(weekday, OrderDate) AS "Date" , OnlineOrderFlag, AVG(SubTotal) AS Average
FROM Sales.SalesOrderHeader
GROUP BY DATENAME(weekday, OrderDate), OnlineOrderFlag)sq1
PIVOT
(
	SUM(Average)
	FOR sq1.OnlineOrderFlag IN
	([1], [0])

)AS pvt;

---------------------------------------------------------------------
--2 List each product category and the number of units sold by month.
--STATIC
---------------------------------------------------------------------
SELECT [Date], [Accessories],[Bikes],[Clothing],[Components]
FROM
	(SELECT DATENAME(month,sh.OrderDate) AS "Date", sd.OrderQty, pc.Name
	FROM Production.ProductCategory pc INNER JOIN Production.ProductSubcategory ps
		 ON pc.ProductCategoryID = ps.ProductCategoryID
		 INNER JOIN Production.Product pr
		 ON ps.ProductSubcategoryID = pr.ProductSubcategoryID
		 INNER JOIN Sales.SalesOrderDetail sd
		 ON pr.ProductID = sd.ProductID
		 INNER JOIN Sales.SalesOrderHeader sh
		 ON sd.SalesOrderID = sh.SalesOrderID)sq1
PIVOT
(
	SUM(sq1.OrderQty)
	FOR sq1.Name IN
	(
		[Accessories],[Bikes],[Clothing],[Components]
	)

)AS pvt;


	
---------------------------------------------------------------------
--3 List each product category and the number of units sold by month.
--DYNAMIC
---------------------------------------------------------------------


DECLARE @columns NVARCHAR(MAX), @sql NVARCHAR(MAX);
SET @columns = N'';
SELECT @columns += N', ' + QUOTENAME(Name)
	FROM Production.ProductCategory AS x;
SET @columns = STUFF(@columns,1,1,'');

SET @sql = N'SELECT [Date],' + @columns + N'
FROM 	(SELECT DATENAME(month, sh.OrderDate) AS "Date", sd.OrderQty, pc.Name
	FROM Production.ProductCategory pc INNER JOIN Production.ProductSubcategory ps
		 ON pc.ProductCategoryID = ps.ProductCategoryID
		 INNER JOIN Production.Product pr
		 ON ps.ProductSubcategoryID = pr.ProductSubcategoryID
		 INNER JOIN Sales.SalesOrderDetail sd
		 ON pr.ProductID = sd.ProductID
		 INNER JOIN Sales.SalesOrderHeader sh
		 ON sd.SalesOrderID = sh.SalesOrderID)sq1

PIVOT
(
	SUM(sq1.OrderQty)
	FOR sq1.Name IN
	(' + @columns + N')
	
	) pvt';

EXEC sp_executesql @sql;