create table DimDate
(Date_Key int identity(1,1) Primary key,
FullDate Date,
Calendar_Year int,
Calendar_Quarter int,
Calendar_Month int,
Month_Name nvarchar(20),
Day_of_Month int,
Day_of_week nvarchar(20));

INSERT INTO dbo.DimDate
(FullDate)
SELECT TRY_CONVERT(date, Order_Date, 101) AS FullDate
FROM dbo.Raw_Superstore
UNION
SELECT TRY_CONVERT(date, Ship_Date, 101)
FROM dbo.Raw_Superstore;

UPDATE dbo.DimDate
SET
    Calendar_Year = YEAR(FullDate),
    Calendar_Quarter = DATEPART(QUARTER, FullDate),
    Calendar_Month = MONTH(FullDate),
    Month_Name = DATENAME(MONTH, FullDate),
    Day_of_Month = DAY(FullDate),
    Day_of_week = DATENAME(WEEKDAY, FullDate);

SELECT *
FROM dbo.DimDate
ORDER BY FullDate;