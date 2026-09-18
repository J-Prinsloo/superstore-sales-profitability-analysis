create table FactSales
(Sales_Key int identity(1,1) primary key,
order_id nvarchar(50),
customer_key int,
product_key int,
location_key int,
order_date_key int,
ship_date_key int,
sales float,
quantity int,
discount float,
profit float);

INSERT INTO dbo.FactSales
(
    Order_ID,
    Customer_Key,
    Product_Key,
    Location_Key,
    Order_Date_Key,
    Ship_Date_Key,
    Sales,
    Quantity,
    Discount,
    Profit
)
select
r.order_id,
c.customerkey,
p.product_key,
l.location_key,
od.date_key as order_date_key,
sd.date_key as ship_date_key,
r.sales,
r.quantity,
r.discount,
r.profit
from raw_superstore as r
join dimcustomer as c
on r.customer_id=c.customer_id
join dimproducts as p
on r.product_id=p.product_id
and r.Product_Name=p.Product_Name
join dimlocation as l
on r.city=l.city
and r.state_province=l.state_province
and r.postal_code=l.postal_code
join dimdate as od
on r.order_date=od.fulldate
join dimdate as sd
on r.ship_date=sd.fulldate;

SELECT COUNT(*)
FROM dbo.Raw_Superstore;

SELECT COUNT(*)
FROM dbo.FactSales;

SELECT COUNT(*)
FROM dbo.Raw_Superstore AS r
JOIN dbo.DimCustomer AS c
    ON r.Customer_ID = c.Customer_ID;

SELECT COUNT(*)
FROM dbo.Raw_Superstore AS r
JOIN dbo.DimProducts AS p
    ON r.Product_ID = p.Product_ID;

TRUNCATE TABLE dbo.FactSales;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(Customer_Key) AS Customer_Keys,
    COUNT(Product_Key) AS Product_Keys,
    COUNT(Location_Key) AS Location_Keys,
    COUNT(Order_Date_Key) AS Order_Date_Keys,
    COUNT(Ship_Date_Key) AS Ship_Date_Keys
FROM dbo.FactSales;

SELECT
    name
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('dbo.FactSales');