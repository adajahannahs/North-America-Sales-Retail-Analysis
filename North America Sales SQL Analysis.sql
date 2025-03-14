SELECT * FROM [Sales Retail]

--To create a DimCustomer table from the Sales Retail table
 SELECT * INTO DimCustomer
 FROM
	(SELECT Customer_ID, Customer_Name, Segment FROM [Sales Retail])
 AS DimC

--To remove duplicate from the DimCustomer
 WITH CTE_DimC
 AS 
 (SELECT Customer_ID, Customer_Name, Segment, ROW_NUMBER() OVER (PARTITION BY Customer_ID, Customer_Name, Segment ORDER BY Customer_ID ASC) AS RowNum
 FROM DimCustomer
 )

 DELETE FROM CTE_DimC
 WHERE RowNum > 1

 --To create a DimLocation table from the Sales Retail table
 SELECT * INTO DimLocation
 FROM
	(SELECT Postal_Code, Country, City, State, Region FROM [Sales Retail])
 AS DimL

 --SELECT * FROM DimLocation

 --To remove duplicate from the DimLocation
 WITH CTE_DimL
 AS 
 (SELECT  Postal_Code, Country, City, State, Region, ROW_NUMBER() OVER (PARTITION BY  Postal_Code, Country, City, State, Region ORDER BY Postal_Code ASC) AS RowNum
 FROM DimLocation
 )

 DELETE FROM CTE_DimL
 WHERE RowNum > 1

 --To create a DimProduct table from the Sales Retail table
 SELECT * INTO DimProduct
 FROM
	(SELECT Product_ID, Category, Sub_Category, Product_Name FROM [Sales Retail])
 AS DimP

  --To remove duplicate from the DimProduct
 WITH CTE_DimP
 AS 
 (SELECT  Product_ID, Category, Sub_Category, Product_Name, ROW_NUMBER() OVER (PARTITION BY  Product_ID, Category, Sub_Category, Product_Name ORDER BY Product_ID ASC) AS RowNum
 FROM DimProduct
 )

 DELETE FROM CTE_DimP
 WHERE RowNum > 1

 --To create the SalesFactTable
 SELECT * INTO OrdersFactTable
 FROM
	(SELECT Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Postal_Code, Retail_Sales_People, Product_ID, Returned, Sales, Quantity, Discount, Profit FROM [Sales Retail])
 AS OrderFact

  WITH CTE_OrderFact
 AS 
 (SELECT  Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Postal_Code, Retail_Sales_People, Product_ID, Returned, Sales, Quantity, Discount, Profit, ROW_NUMBER() OVER (PARTITION BY 
 Order_ID,
 Order_Date,
 Ship_Date,
 Ship_Mode,
 Customer_ID,
 Postal_Code,
 Retail_Sales_People,
 Product_ID, Returned,
 Sales, Quantity,
 Discount,
 Profit ORDER BY Order_ID ASC)
 AS RowNum
 FROM OrdersFactTable
 )

  DELETE FROM CTE_OrderFact
 WHERE RowNum > 1
 
 SELECT * FROM DimProduct
 WHERE Product_ID = 'FUR-FU-10004091'

 --To add a surrogate key called productkey to serve as a unique identifier for the table DimProduct

 ALTER TABLE DimProduct 
 ADD ProductKey INT IDENTITY(1,1) PRIMARY KEY

 -- To add the productkey to the OrdersFactTable
 ALTER TABLE OrdersFactTable
 ADD ProductKey INT 

 
 UPDATE OrdersFactTable
 SET ProductKey = DimProduct.ProductKey
 FROM OrdersFactTable 
 JOIN DimProduct
 ON OrdersFactTable.Product_ID = DimProduct.Product_ID


 --To drop the Product_ID in the OrdersFactTable and DimProduct Table
 ALTER TABLE DimProduct
 DROP COLUMN Product_ID

 ALTER TABLE OrdersFactTable
 DROP COLUMN Product_ID

 SELECT * FROM OrdersFactTable
 WHERE Order_ID = 'CA-2014-102652'

 --To add a unique identifier to the OrderFactTable.
 ALTER TABLE OrdersFactTable 
 ADD Row_ID INT IDENTITY(1,1)



 --EXPLORATORY ANALYSIS
 --What is the Average Delivery days for different product subcategory
 SELECT * FROM OrdersFactTable
 SELECT * FROM DimProduct
 
 SELECT Sub_Category, DATEDIFF(DAY, Order_Date, Ship_Date) AS DeliveryDays
 FROM OrdersFactTable
 LEFT JOIN DimProduct
 ON OrdersFactTable.ProductKey = DimProduct.ProductKey

 --Another way to write the above using Alias 
 SELECT dp.Sub_Category, AVG(DATEDIFF(DAY, oft.Order_Date, oft.Ship_Date)) AS DeliveryDays
 FROM OrdersFactTable AS oft
 LEFT JOIN DimProduct AS dp
 ON oft.ProductKey = dp.ProductKey
 GROUP BY dp.Sub_Category

 /* it takes an average of 32 days to delivery products in the chairs and bookcases subcategory
  an average of 34 days to deliver products in the furnishing subcategory
  an average of 36 days to deliver products in the tables subcategory */

  --What is the Average Delivery days for each segment
 SELECT dc.Segment, AVG(DATEDIFF(DAY, oft.Order_Date, oft.Ship_Date)) AS AvgDeliveryDays
 FROM OrdersFactTable AS oft
 LEFT JOIN DimCustomer AS dc
 ON oft.Customer_ID = dc.Customer_ID
 GROUP BY dc.Segment
 ORDER BY 2 DESC

  /* it takes an average of 35 delivery days to get products to the corporate customer  segment,
  an average of 34 delivery days to get products to the consumer customer segment,
  an average of 31 delivery days to get products to the Home Office customer segment */


  -- What are the Top 5 Fastest delivered products and Top 5 slowest delivered products?
  SELECT TOP 5(dp.Product_Name), DATEDIFF(DAY, oft.Order_Date, oft.Ship_Date) AS DeliveryDays
 FROM OrdersFactTable AS oft
 LEFT JOIN DimProduct AS dp
 ON oft.ProductKey = dp.ProductKey
 ORDER BY 2 ASC

 /* the top fastest delivered products with 0 delivery days are
Sauder Camden County Barrister Bookcase, Planked Cherry Finish
Sauder Inglewood Library Bookcases
O'Sullivan 2-Shelf Heavy-Duty Bookcases
O'Sullivan Plantations 2-Door Library in Landvery Oak
O'Sullivan Plantations 2-Door Library in Landvery Oak */

 SELECT TOP 5(dp.Product_Name), DATEDIFF(DAY, oft.Order_Date, oft.Ship_Date) AS DeliveryDays
 FROM OrdersFactTable AS oft
 LEFT JOIN DimProduct AS dp
 ON oft.ProductKey = dp.ProductKey
 ORDER BY 2 DESC

 /* the top 5 slowest delivered products with 214 delivery days are 
Bush Mission Pointe Library
Hon Multipurpose Stacking Arm Chairs
Global Ergonomic Managers Chair
Tensor Brushed Steel Torchiere Floor Lamp
Howard Miller 11-1/2" Diameter Brentwood Wall Clock */


--which product subcategory generate most profit
SELECT dp.Sub_Category, ROUND(SUM(oft.Profit),2) AS TotalProfit
 FROM OrdersFactTable AS oft
 LEFT JOIN DimProduct AS dp
 ON oft.ProductKey = dp.ProductKey
 WHERE oft.Profit > 0
 GROUP BY dp.Sub_Category
 ORDER BY 2 DESC

 /* The subCategory chairs generates the highest profit with a total of $36471.1,
 while the least comes from table */


 --which segment generate most profit
 SELECT dc.Segment, ROUND(SUM(oft.Profit),2) AS TotalProfit
 FROM OrdersFactTable AS oft
 LEFT JOIN DimCustomer AS dc
 ON oft.Customer_ID = dc.Customer_ID
 WHERE oft.Profit > 0
 GROUP BY dc.Segment
 ORDER BY 2 DESC

 /* The Consumer customer segment generates the highest profit with a total of $35427.03,
 while the least comes from Home Office customer segment*/

 --Which Top 5 Customers made the most Profit
 SELECT TOP 5(dc.Customer_Name), ROUND(SUM(oft.Profit),2) AS TotalProfit
 FROM OrdersFactTable AS oft
 LEFT JOIN DimCustomer AS dc
 ON oft.Customer_ID = dc.Customer_ID
 WHERE oft.Profit > 0
 GROUP BY dc.Customer_Name
 ORDER BY 2 DESC

/* The top 5 customers that brought in the most profits are
Laura Armstrong
Joe Elijah
Seth Vernon
Quincy Jones
Maria Etezadi */

--what is the total number of product by Subcategory
SELECT Sub_category, COUNT(Product_Name) AS TotalProduct
FROM DimProduct
GROUP BY Sub_Category
ORDER BY 2 DESC

/* the total number of product by Subcategory are 186, 87, 48, 34 for Furnishings, chairs , Bookcases, tables respectively
*/

--what are the Key Performance Indicators (KPIs)
-- TOTAL SALES
SELECT * FROM OrdersFactTable

SELECT ROUND(SUM(Sales),2) AS TotalSales
FROM OrdersFactTable

/* The total sales is $645451.33 */

--TOTAL PROFITS
SELECT ROUND(SUM(Profit),2) AS TotalProfits
FROM OrdersFactTable
WHERE Profit > 0

/* The total profits is $72740.03 */

--TOTAL CUSTOMERS
SELECT * FROM DimCustomer
SELECT COUNT(Customer_ID) AS TotalCustomers
FROM DimCustomer

/* The total number of customers is 693 */

--TOTAL DISCOUNT
SELECT ROUND(SUM(Discount),2) AS TotalDiscounts
FROM OrdersFactTable
WHERE Discount > 0

/* The total amount of discount given is 335.24 */

SELECT * FROM DimLocation