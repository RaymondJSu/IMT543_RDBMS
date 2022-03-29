

/*
M5 13 No Scaffolding Lab 5 

Server: IS-HAY09.ischool.uw.edu 
Database: SampleSuperStore 

*/

-- Q1) Write the SQL to determine which customers meet all of the following conditions:
-- condition a) Purchased fewer than 3 units of products that are product type 'Electronics' before 2013 
-- condition b) Spent less than $30 on Kitchen products between 1999 and 2008

SELECT A.CustomerID, A.Fname, A.Lname
FROM
(SELECT C.CustomerID, C.Fname, C.Lname, SUM(OP.Quantity) AS UNIT
FROM tblCUSTOMER C
	JOIN tblORDER O ON O.CustomerID = C.CustomerID
	JOIN tblORDER_PRODUCT OP ON OP.OrderID = O.OrderID
	JOIN tblPRODUCT P ON P.ProductID = OP.ProductID
	JOIN tblPRODUCT_TYPE PT ON PT.ProdTypeID = P.ProdTypeID
WHERE PT.ProdTypeName = 'Electronics'
	AND  O.OrderDate < '2013'
GROUP BY C.CustomerID, C.Fname, C.Lname
HAVING SUM(OP.Quantity) < 3) A,

(SELECT C.CustomerID, C.Fname, C.Lname
FROM tblCUSTOMER C
	JOIN tblORDER O ON O.CustomerID = C.CustomerID
	JOIN tblORDER_PRODUCT OP ON OP.OrderID = O.OrderID
	JOIN tblPRODUCT P ON P.ProductID = OP.ProductID
	JOIN tblPRODUCT_TYPE PT ON PT.ProdTypeID = P.ProdTypeID
WHERE PT.ProdTypeName = 'Kitchen'
	AND O.OrderDate BETWEEN '1999' AND '2008'
GROUP BY C.CustomerID, C.Fname, C.Lname
HAVING SUM(OP.Calc_LineTotal) < 30) B

WHERE A.CustomerID = B.CustomerID
GROUP BY A.CustomerID, A.Fname, A.Lname

-- Q2) Write the SQL query to determine the top 6 states for total dollars spend on 
--products of type 'garden' for people younger than 33 years old at the time of purchase

SELECT TOP 6 C.CustState, SUM(O.Calc_OrderTotal) AS Money_Spent
FROM tblCUSTOMER C
	JOIN tblORDER O ON O.CustomerID = C.CustomerID
	JOIN tblORDER_PRODUCT OP ON OP.OrderID = O.OrderID
	JOIN tblPRODUCT P ON P.ProductID = OP.ProductID
	JOIN tblPRODUCT_TYPE PT ON PT.ProdTypeID = P.ProdTypeID
WHERE PT.ProdTypeName = 'Garden'
	AND DATEDIFF(YEAR, C.BirthDate, O.OrderDate) < 33
GROUP BY C.CustState
ORDER BY Money_Spent DESC


-- Q3) Write the SQL to label and count the number of customers that meet the following conditions:
--		a) Purchased fewer than 20 units of 'automotive' products lifetime AND spent less than $800 lifetime of product type 'kitchen', label them 'Blue'
--		b) Purchased between 20 and 30 units of 'automotive' products lifetime AND spent less than $800 lifetime of product type 'kitchen', label them 'Green'
--		c) Purchased between 31 and 45 units of 'automotive' products lifetime AND spent less than $800 lifetime of product type 'kitchen', label them 'Orange'
--		d) Purchased between 46 and 60 units of 'automotive' products lifetime AND spent BETWEEN $801 and $3000 lifetime of product type 'kitchen', label them 'Purple'
--		e) Else 'Unknown'
-- HINT: this is best written with a CASE statement drawing from 2 subqueries(!!) that each have an aggregated alias like 'AutoUnits' and 'TotalBucksKitchen'


SELECT (CASE
       WHEN A.AutoUnits < 20 AND B.TotalBucksKitchen < 800
       THEN 'Blue'
       WHEN (A.AutoUnits BETWEEN 20 AND 30) AND B.TotalBucksKitchen < 800
       THEN 'Green'
       WHEN (A.AutoUnits BETWEEN 31 AND 45) AND B.TotalBucksKitchen < 800
       THEN 'Orange'
       WHEN (A.AutoUnits BETWEEN 46 AND 60) AND B.TotalBucksKitchen BETWEEN 801 AND 3000
       THEN 'Purple'
       ELSE 'Unknown'
       END) AS LabelofKitchen, COUNT(*) AS NumOfPeop
FROM 
(SELECT C.CustomerID, SUM(OP.Quantity) AS AutoUnits
FROM tblCUSTOMER C
	JOIN tblORDER O ON O.CustomerID = C.CustomerID
	JOIN tblORDER_PRODUCT OP ON OP.OrderID = O.OrderID
	JOIN tblPRODUCT P ON P.ProductID = OP.ProductID
	JOIN tblPRODUCT_TYPE PT ON PT.ProdTypeID = P.ProdTypeID
WHERE PT.ProdTypeName = 'Automotive'
GROUP BY C.CustomerID) A,

(SELECT C.CustomerID, SUM(Calc_LineTotal) AS TotalBucksKitchen
FROM tblCUSTOMER C
	JOIN tblORDER O ON O.CustomerID = C.CustomerID
	JOIN tblORDER_PRODUCT OP ON OP.OrderID = O.OrderID
	JOIN tblPRODUCT P ON P.ProductID = OP.ProductID
	JOIN tblPRODUCT_TYPE PT ON PT.ProdTypeID = P.ProdTypeID
WHERE PT.ProdTypeName = 'Kitchen'
GROUP BY C.CustomerID) B

GROUP BY (CASE
       WHEN A.AutoUnits < 20 AND B.TotalBucksKitchen < 800
       THEN 'Blue'
       WHEN (A.AutoUnits BETWEEN 20 AND 30) AND B.TotalBucksKitchen < 800
       THEN 'Green'
       WHEN (A.AutoUnits BETWEEN 31 AND 45) AND B.TotalBucksKitchen < 800
       THEN 'Orange'
       WHEN (A.AutoUnits BETWEEN 46 AND 60) AND B.TotalBucksKitchen BETWEEN 801 AND 3000
       THEN 'Purple'
       ELSE 'Unknown'
       END)

-- Q4) Write the SQL to create a stored procedure to INSERT a new row into tblPRODUCT under the following conditions:
-- a) pass in parameters of @ProdName, @ProdTypeName, and @Price
-- b) DECLARE a variable to look-up the associated ProdTypeID for @ProdTypeName parameter (no error-handling required)
-- c) make the INSERT statement inside an explicit transaction
GO

CREATE PROCEDURE InsertProduct@ProdName varchar(100),@insertprice Numeric(8,2),@ProdTypeName varchar(50)ASDECLARE @CO_ID INTSET @CO_ID = (SELECT PT.ProdTypeID                from tblPRODUCT_TYPE PT                where PT.ProdTypeName = @ProdTypeName) INSERT INTO tblPRODUCT (ProdTypeID, ProductName, Price)VALUES (@CO_ID, @ProdName, @insertprice)GO




-- Q5) Write the SQL to create a stored procedure to UPDATE the price of a single product in SampleSuperStore database with the following conditions:
-- a) be sure to affect only a single row (hint: populate a variable and set that to the PK of tblPRODUCT)
-- b) make the UPDATE statement inside an explicit transaction
-- c) pass in parameters of @ProdName and @NewPrice

CREATE PROCEDURE UpdatePrice@ProdName varchar(100),@Oldprice Numeric(8,2),@NewPrice Numeric(8,2)ASDECLARE @DR_ID INT SET @DR_ID = (  SELECT P.ProductID                FROM  tblPRODUCT P                JOIN tblPRODUCT_TYPE PT on PT.ProdTypeID = P.ProdTypeID                WHERE P.ProductName = @ProdName                AND P.Price = @Oldprice            )IF @DR_ID IS NULL	BEGIN		PRINT 'there is a NULL value in the variable; terminating process';		THROW 54446, '@DR_ID cannot be NULL', 1;	ENDUPDATE tblPRODUCT SET Price = @NewPriceWHERE ProductID = @DR_IDGO