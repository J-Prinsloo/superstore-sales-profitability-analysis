alter table factsales
add constraint FK_FactSales_DumCustomer
foreign key (Customer_Key)
references dimcustomer(customerkey);

ALTER TABLE dbo.FactSales
ADD CONSTRAINT FK_FactSales_DimProducts
FOREIGN KEY (Product_Key)
REFERENCES dbo.DimProducts(Product_Key);

ALTER TABLE dbo.FactSales
ADD CONSTRAINT FK_FactSales_DimLocation
FOREIGN KEY (Location_Key)
REFERENCES dbo.DimLocation(Location_Key);

ALTER TABLE dbo.FactSales
ADD CONSTRAINT FK_FactSales_OrderDate
FOREIGN KEY (Order_Date_Key)
REFERENCES dbo.DimDate(Date_Key);

ALTER TABLE dbo.FactSales
ADD CONSTRAINT FK_FactSales_ShipDate
FOREIGN KEY (Ship_Date_Key)
REFERENCES dbo.DimDate(Date_Key);

EXEC sp_helpconstraint 'dbo.FactSales';