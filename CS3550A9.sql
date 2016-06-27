--Sudie Roweton6
--CS 3550 Spring 2016
--Assignment #9

--1 List the first name, last name, gender, age, and job title of the oldest employee

SELECT p.FirstName, p.LastName, e.Gender, DATEDIFF(day,e.BirthDate,GETDATE())/365 AS Age, e.JobTitle
FROM HumanResources.Employee e INNER JOIN
	 Person.Person p
	 ON e.BusinessEntityID = p.BusinessEntityID
WHERE DATEDIFF(day,e.BirthDate, GETDATE())/365.0 =
		(SELECT MAX(Age)
		FROM
		(SELECT BusinessEntityID, DATEDIFF(day, BirthDate,GETDATE())/365.0 AS Age
		FROM HumanResources.Employee)ay);

--2 Display the employee male to female ratio
SELECT  CAST((CAST((SELECT COUNT(*) FROM HumanResources.Employee WHERE Gender = 'M')AS decimal (6,2)))/(SELECT COUNT(*)
			FROM HumanResources.Employee
			WHERE Gender = 'F') AS decimal (18,2)); 

	--There are 2.45 men for every 1 woman

--3 What is the most ordered item for each customer?
SELECT sq10.CustomerID, sq10.ProductID
FROM
	(SELECT c.CustomerID, d.ProductID, SUM(d.OrderQty) AS ItemsOrdered
	FROM Sales.SalesOrderHeader h
	INNER JOIN Sales.SalesOrderDetail d
		ON h.SalesOrderID = d.SalesOrderID
	INNER JOIN Sales.Customer c
		ON h.CustomerID = c.CustomerID
	GROUP BY c.CustomerID, d.ProductID)sq10
INNER JOIN
	(SELECT sq1.CustomerID, MAX(sq1.ItemsOrdered) AS HighestOrdered
		FROM
		(SELECT c.CustomerID, d.ProductID, SUM(d.OrderQty) AS ItemsOrdered
		FROM Sales.SalesOrderHeader h
			INNER JOIN Sales.SalesOrderDetail d
				ON h.SalesOrderID = d.SalesOrderID
			INNER JOIN Sales.Customer c
				ON h.CustomerID = c.CustomerID
		GROUP BY c.CustomerID, d.ProductID)sq1
	GROUP BY sq1.CustomerID)sq11
ON sq10.CustomerID = sq11.CustomerID
WHERE sq10.ItemsOrdered = sq11.HighestOrdered;


--4 Show the states(s) with the most online orders

SELECT sp.Name, COUNT(*) AS NumOnlineOrders
FROM Sales.SalesOrderHeader so INNER JOIN
	 Sales.SalesTerritory st 
	 ON so.TerritoryID = st.TerritoryID
	 INNER JOIN
	 Person.StateProvince sp
	 ON st.TerritoryID = sp.TerritoryID
WHERE sp.CountryRegionCode = 'US'
	AND so.OnlineOrderFlag = 1
GROUP BY sp.Name
HAVING COUNT(*) =

(SELECT MAX(NumOnline)
FROM
(SELECT sp.Name, COUNT(*) AS NumOnline
FROM Sales.SalesOrderHeader so INNER JOIN
	 Sales.SalesTerritory st 
	 ON so.TerritoryID = st.TerritoryID
	 INNER JOIN
	 Person.StateProvince sp
	 ON st.TerritoryID = sp.TerritoryID
WHERE sp.CountryRegionCode = 'US'
	AND so.OnlineOrderFlag = 1
GROUP BY sp.Name)no);


--5 Display the vendorID, credit rating, and address for vendors that have a credit rating higher than 3
-- NOTE: vendorID == BusinessEntityID
SELECT ve.BusinessEntityID, ve.Name, ve.CreditRating, a.AddressLine1, a.City, sp.Name, a.PostalCode
FROM Purchasing.Vendor ve INNER JOIN Person.BusinessEntity be
	 ON ve.BusinessEntityID = be.BusinessEntityID
	 INNER JOIN Person.BusinessEntityAddress ba
	 ON be.BusinessEntityID = ba.BusinessEntityID
	 INNER JOIN Person.Address a 
	 ON ba.AddressID = a.AddressID
	 INNER JOIN Person.StateProvince sp
	 ON a.StateProvinceID = sp.StateProvinceID
WHERE ve.CreditRating > 3
ORDER BY ve.CreditRating DESC;

--6 Display the territory (ID, Name, CountryRegionCode, Group, and Count)
--  of the territory that has the most customers

SELECT sc.TerritoryID, st.Name, st.CountryRegionCode,st."Group", COUNT(*) AS "Count"
FROM Sales.SalesTerritory st INNER JOIN Sales.Customer sc
	ON st.TerritoryID = sc.TerritoryID
GROUP BY sc.TerritoryID, st.Name, st.CountryRegionCode, st."Group"
HAVING COUNT(*) =

(SELECT MAX(NumCust)
FROM
(SELECT sc.TerritoryID, COUNT(*) AS NumCust
FROM Sales.SalesTerritory st INNER JOIN Sales.Customer sc
	ON st.TerritoryID = sc.TerritoryID
GROUP BY sc.TerritoryID)tcn);

--7 List the first employee hired in each department, in alphabetical order
--  by department

SELECT sq10.FirstName, sq10.LastName, sq10.Name, sq10.HireDate
FROM
	(SELECT pe.FirstName, pe.LastName, de.Name, em.HireDate
	 FROM  Person.Person pe INNER JOIN HumanResources.Employee em
		  ON pe.BusinessEntityID = em.BusinessEntityID
		  INNER JOIN HumanResources.EmployeeDepartmentHistory ed
		  ON em.BusinessEntityID = ed.BusinessEntityID 
		  INNER JOIN HumanResources.Department de
		  ON ed.DepartmentID = de.DepartmentID)sq10
INNER JOIN
		(SELECT hdm.Name, MIN(hdm.HireDate) AS MinHireDate
		FROM
		(SELECT	pe.FirstName, pe.LastName, de.Name, em.HireDate
		  FROM	Person.Person pe INNER JOIN HumanResources.Employee em 
				ON pe.BusinessEntityID = em.BusinessEntityID
				INNER JOIN HumanResources.EmployeeDepartmentHistory ed
				ON em.BusinessEntityID = ed.BusinessEntityID
				INNER JOIN HumanResources.Department de
				ON ed.DepartmentID = de.DepartmentID)hdm
		GROUP BY hdm.Name)sq11
ON sq10.Name = sq11.Name
WHERE sq10.HireDate = sq11.MinHireDate
ORDER BY sq10.Name;

--8 List the first and last name and curent pay rate of employees who have 
--  above average YTD sales

SELECT pe.FirstName, pe.LastName, ep.Rate
FROM Sales.SalesPerson sp INNER JOIN HumanResources.Employee em
	 ON sp.BusinessEntityID = em.BusinessEntityID 
	 INNER JOIN Person.Person pe
	 ON em.BusinessEntityID = pe.BusinessEntityID
	 INNER JOIN HumanResources.EmployeePayHistory ep
	 ON em.BusinessEntityID = ep.BusinessEntityID
WHERE sp.SalesYTD >
		(SELECT AVG(SalesYTD)
		 FROM Sales.SalesPerson);

--9 Identify the currency of the country with the highest number of orders
SELECT cur.Name, COUNT(*) AS NumOrders
FROM Person.CountryRegion cr INNER JOIN Person.StateProvince sp
	 ON cr.CountryRegionCode = sp.CountryRegionCode
	 INNER JOIN Person.[Address] ad
	 ON sp.StateProvinceID = ad.StateProvinceID
	 INNER JOIN Sales.SalesOrderHeader so
	 ON ad.AddressID = so.ShipToAddressID
	 INNER JOIN Sales.CountryRegionCurrency crc
	 ON cr.CountryRegionCode = crc.CountryRegionCode
	 INNER JOIN Sales.Currency cur
	 ON crc.CurrencyCode = cur.CurrencyCode
GROUP BY cur.Name
HAVING COUNT(*) =
(SELECT MAX(NumOrders)
FROM
(SELECT cr.Name, COUNT(*) AS NumOrders
FROM Person.CountryRegion cr INNER JOIN Person.StateProvince sp
	 ON cr.CountryRegionCode = sp.CountryRegionCode
	 INNER JOIN Person.[Address] ad
	 ON sp.StateProvinceID = ad.StateProvinceID
	 INNER JOIN Sales.SalesOrderHeader so
	 ON ad.AddressID = so.ShipToAddressID
	 INNER JOIN Sales.CountryRegionCurrency crc
	 ON cr.CountryRegionCode = crc.CountryRegionCode
	 INNER JOIN Sales.Currency cur
	 ON crc.CurrencyCode = cur.CurrencyCode
GROUP BY cr.Name)sq1);


--10 Display the average amount of markup(standard cost vs. unit price) on 
--   bikes sold during June of 2008
SELECT
(SELECT SUM(Diffe)
FROM
((SELECT sql1.ProductID, sql1.Name, sql1.ListPrice, sql1.StandardCost, sql1.ListPrice - sql1.StandardCost AS Diffe
FROM
(SELECT pr.ProductID, pc.Name, pr.StandardCost, pr.ListPrice
FROM  Production.ProductCategory pc INNER JOIN Production.ProductSubcategory ps
	  ON pc.ProductCategoryID = ps.ProductCategoryID
	  INNER JOIN Production.Product pr
	  ON ps.ProductSubcategoryID = pr.ProductSubcategoryID)sql1
INNER JOIN
(SELECT sod.ProductID, soh.OrderDate
FROM Sales.SalesOrderDetail sod INNER JOIN Sales.SalesOrderHeader soh
	ON sod.SalesOrderID = soh.SalesOrderID
WHERE (soh.OrderDate >= '2008-06-01') AND (soh.OrderDate < '2008-07-01'))sql2
ON sql1.ProductID = sql2.ProductID
WHERE sql1.Name = 'Bikes'))sql3) / 

(SELECT COUNT(*)
FROM
(SELECT pr.ProductID, pc.Name, pr.StandardCost
FROM  Production.ProductCategory pc INNER JOIN Production.ProductSubcategory ps
	  ON pc.ProductCategoryID = ps.ProductCategoryID
	  INNER JOIN Production.Product pr
	  ON ps.ProductSubcategoryID = pr.ProductSubcategoryID)sql1
INNER JOIN
(SELECT sod.ProductID, soh.OrderDate, sod.UnitPrice
FROM Sales.SalesOrderDetail sod INNER JOIN Sales.SalesOrderHeader soh
	ON sod.SalesOrderID = soh.SalesOrderID
WHERE (soh.OrderDate >= '2008-06-01') AND (soh.OrderDate < '2008-07-01'))sql2
ON sql1.ProductID = sql2.ProductID
WHERE sql1.Name = 'Bikes')
