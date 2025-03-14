# North America Sales Retail Optimization Analysis

## Project Overview
As a data analyst, I'll be delving into North America Retail's sales data to uncover valuable insights about their business performance across multiple locations. My analysis will focus on understanding profitability patterns, product performance, and customer behavior within this major retail company that serves diverse customer segments.

I'll be working with a comprehensive dataset containing detailed information on products, customers, sales figures, profit margins, and returns. By examining these data points, I'll identify key trends and opportunities that can help North America Retail enhance their renowned customer service and streamline the shopping experience they provide.

## Data Source
The dataset is a Retail Supply Chain Sales Analysis.CSV file

## Tool Used
-SQL

## Data Cleaning and Preparation
1. Data importation and inspection
2. Splitted table into facts and dimension table
3. Created a ERD diagram

## Objectives
1. What was the Average delivery days for different product subcategory?
2. What was the Average delivery days for each segment ?
3. What are the Top 5 Fastest delivered products and Top 5 slowest delivered products?
4. Which product Subcategory generate most profit?
5. Which segment generates the most profit?
6. Which Top 5 customers made the most profit?
7. What is the total number of products by Subcategory

## Data Analysis
1. What was the Average delivery days for different product subcategory?
```sql
 SELECT dp.Sub_Category, AVG(DATEDIFF(DAY, oft.Order_Date, oft.Ship_Date)) AS DeliveryDays
 FROM OrdersFactTable AS oft
 LEFT JOIN DimProduct AS dp
 ON oft.ProductKey = dp.ProductKey
 GROUP BY dp.Sub_Category

 /* it takes an average of 32 days to delivery products in the chairs and bookcases subcategory
  an average of 34 days to deliver products in the furnishing subcategory
  an average of 36 days to deliver products in the tables subcategory */
 ```

2. What was the Average delivery days for each segment ?
```sql
 SELECT dc.Segment, AVG(DATEDIFF(DAY, oft.Order_Date, oft.Ship_Date)) AS AvgDeliveryDays
 FROM OrdersFactTable AS oft
 LEFT JOIN DimCustomer AS dc
 ON oft.Customer_ID = dc.Customer_ID
 GROUP BY dc.Segment
 ORDER BY 2 DESC

  /* it takes an average of 35 delivery days to get products to the corporate customer  segment,
  an average of 34 delivery days to get products to the consumer customer segment,
  an average of 31 delivery days to get products to the Home Office customer segment */
```

3. What are the Top 5 Fastest delivered products and Top 5 slowest delivered products?
```sql
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
```

4. Which product Subcategory generate most profit?
```sql
 SELECT dp.Sub_Category, ROUND(SUM(oft.Profit),2) AS TotalProfit
 FROM OrdersFactTable AS oft
 LEFT JOIN DimProduct AS dp
 ON oft.ProductKey = dp.ProductKey
 WHERE oft.Profit > 0
 GROUP BY dp.Sub_Category
 ORDER BY 2 DESC

 /* The subCategory chairs generates the highest profit with a total of $36471.1,
 while the least comes from table */
```

5. Which segment generates the most profit?
```sql
 SELECT dc.Segment, ROUND(SUM(oft.Profit),2) AS TotalProfit
 FROM OrdersFactTable AS oft
 LEFT JOIN DimCustomer AS dc
 ON oft.Customer_ID = dc.Customer_ID
 WHERE oft.Profit > 0
 GROUP BY dc.Segment
 ORDER BY 2 DESC

 /* The Consumer customer segment generates the highest profit with a total of $35427.03,
 while the least comes from Home Office customer segment*/
```

6. Which Top 5 customers made the most profit?
```sql
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
```

7. What is the total number of products by Subcategory
```sql
SELECT Sub_category, COUNT(Product_Name) AS TotalProduct
FROM DimProduct
GROUP BY Sub_Category
ORDER BY 2 DESC

/* the total number of product by Subcategory are 186, 87, 48, 34 for Furnishings, chairs , Bookcases, tables respectively
*/
```

## Key Performance Indicators (KPIs)
1. Total Sales
```sql
SELECT ROUND(SUM(Sales),2) AS TotalSales
FROM OrdersFactTable

/* The total sales is $645451.33 */
```
2. Total Profits
```sql
SELECT ROUND(SUM(Profit),2) AS TotalProfits
FROM OrdersFactTable
WHERE Profit > 0

/* The total profits is $72740.03 */
```
3. Total No. of Customer
```sql
SELECT * FROM DimCustomer
SELECT COUNT(Customer_ID) AS TotalCustomers
FROM DimCustomer

/* The total number of customers is 693 */
```
4. Total Discount Given
```sql
SELECT ROUND(SUM(Discount),2) AS TotalDiscounts
FROM OrdersFactTable
WHERE Discount > 0

/* The total amount of discount given is $335.24 */
```

## Result and Findings
1. tables subcategory have the longest average delivery time of 36 days
2. Tables have the least amount of products and also generates the least profit
3. Home Office segment has the fastest delivery times (31 days) but generates the least profit while Consumer segment (34 days) has the middle delivery time but generates the highest profit
4. Chairs have less products (87) than Furnishings (186) but generate the highest profit
5. The dramatic difference between fastest delivered (0 days) and slowest delivered (214 days) products suggests significant supply chain inconsistencies

## Recommendations
1. Since tables have the longest delivery time (36 days), prioritize supply chain optimizations for this subcategory
2. Apply successful logistics practices from the chairs/bookcases subcategory to the other subcategories
3. Offer expedited shipping options for customers willing to pay more, particularly for the slower-to-deliver subcategories
4. Prioritize improving delivery times for the Consumer segment, which generates the highest profit
5. Consider dropping underperforming products from the Furnishings subcategory
6. Create special services and benefits for the top profitable customers
7. Increase production levels of chair products to ensure availability

## Challenges
While creating the ERD diagram, I encountered a problem where there were duplicate keys in my product dimension table, I had to create a surrogate key that served as a unique identifier for that table.
