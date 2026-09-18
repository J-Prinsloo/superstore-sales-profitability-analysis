create table dbo.DimProducts
(Product_Key int identity(1,1) primary key,
Product_ID nvarchar(50),
Category nvarchar(50),
Sub_Category nvarchar(50),
Product_Name nvarchar(200));

Insert into dbo.DimProducts
(Product_ID,Category,Sub_Category,Product_Name)
select distinct
Product_ID,Category,Sub_Category,Product_Name
from Raw_Superstore;

select count(*) as TotalProducts
from DimProducts;

select top 10 *
from DimProducts;

SELECT
    Product_ID,
    COUNT(*) AS NumberOfRows
FROM dbo.DimProducts
GROUP BY Product_ID
HAVING COUNT(*) > 1;

SELECT
    Product_ID,
    Category,
    Sub_Category,
    Product_Name
FROM dbo.DimProducts
WHERE Product_ID = 'FUR-BO-10002213';

SELECT
    Product_ID,
    Product_Name,
    COUNT(*) AS NumberOfSales
FROM dbo.Raw_Superstore
WHERE Product_ID = 'FUR-BO-10002213'
GROUP BY
    Product_ID,
    Product_Name;

SELECT COUNT(*)
FROM dbo.Raw_Superstore AS r
JOIN dbo.DimProducts AS p
    ON r.Product_ID = p.Product_ID
    AND r.Product_Name = p.Product_Name;