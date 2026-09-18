create table DimLocation
(Location_Key int identity(1,1) primary key,
Country nvarchar(50),
City nvarchar(50),
State_Province nvarchar(50),
Postal_Code nvarchar(50),
Region nvarchar(50));

Insert into DimLocation
(Country,City,State_Province,Postal_Code,Region)
select distinct
Country_Region,city,state_province,postal_code,region
from Raw_Superstore;

select count(*)
from DimLocation;

select top 10*
from DimLocation;

SELECT
    City,
    State_Province,
    Postal_Code,
    COUNT(*) AS NumberOfRows
FROM dbo.DimLocation
GROUP BY
    City,
    State_Province,
    Postal_Code
HAVING COUNT(*) > 1;