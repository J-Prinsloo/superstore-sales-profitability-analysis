--1. Overall business performance
select sum(f.sales) as Total_Sales,
sum(f.profit) as Total_Profit,
sum(f.quantity) as Quantity_Sold,
count(distinct f.order_id) as Number_of_orders,
(sum(f.profit)/sum(f.sales))*100 as Profit_margin
from factsales as f;

--2. Which categories are good or bad for business?
select p.category, sum(f.sales) as Total_Sales,sum(f.profit) as Total_profit,(sum(f.profit)/sum(f.sales))*100 as Profit_Margin
from factsales as f
join dimproducts as p
on f.product_key=p.product_key
group by p.category
order by total_profit desc;
-- Tech and office supplies have a very similar profit margin of 17%, however furniture has a very poor margin of around 2.6%.

--3. Why is Furniture profit margin so low? What's causing the issue?
select p.Sub_Category, sum(f.sales) as Total_Sales,sum(f.profit) as Total_profit,(sum(f.profit)/sum(f.sales))*100 as Profit_Margin
from factsales as f
join dimproducts as p
on f.product_key=p.product_key
where p.Category='Furniture'
group by p.Sub_Category
order by Profit_Margin;
-- Tables have the biggest loss by far of 17,753.

--4. Which indivual products within the tables category are causing such significant losses?
select p.product_name, sum(f.sales) as Total_sales,sum(f.profit) as Total_profit,(sum(f.profit)/sum(f.sales))*100 as Profit_Margin
from FactSales as f
join DimProducts as p
on f.product_key=p.Product_Key
where p.Sub_Category='Tables'
group by p.Product_Name
having sum(f.profit)<0
order by Total_profit;
-- The loss is widespread, meaning its caused by many products within the table category.

--5. Could there be a relationship with this loss and discount?
select f.discount,count(*) as Number_of_sales,sum(f.sales) as Total_sales,sum(f.profit) as Total_profit,(sum(f.profit)/sum(f.sales))*100 as Profit_margin
from FactSales as f
join DimProducts as p
on f.product_key=p.Product_Key
where sub_category='tables'
group by f.discount
order by f.discount;
-- There is a strong negative correlation between profit margin and discount level, and a high number of transactions at higher discount levels such as 75 transactions at discount of 0.4 is resulting in the biggest losses

--6. Do the worst performing products have high discount rates?
select p.product_name, f.discount, sum(f.sales) as Total_sales,sum(f.profit) as Total_profit
from FactSales as f
join DimProducts as p
on f.product_key=p.Product_Key
where p.Sub_Category='Tables'
group by p.Product_Name, f.discount
order by Total_profit;
-- Almost all of the worst performing table products have a discount rate of 0.4 or above.

--7. Are the discounts making the products unprofitable or are they already unprofitable?
select p.product_name,f.discount,sum(f.sales) as total_sales,sum(f.profit) as total_profit, (sum(f.profit)/sum(f.sales))*100 as profit_margin
from FactSales as f
join DimProducts as p
on f.product_key=p.Product_Key
where p.Product_Name in(
select top 5 p.product_name
from FactSales as f
join DimProducts as p
on f.product_key=p.Product_Key
where Sub_Category='tables'
group by p.Product_Name
order by sum(f.profit))
group by p.Product_Name,f.discount
order by product_name;
-- Table products are generally profitable when sold without discounts, but profitability declines sharply at higher discount levels.
--This suggests that aggressive discounting is a key driver of the Table category's poor profitability.

--1st recommendation: Review or restrict discounts on Table products, particularly discounts of 30%+ where margins become severely negative.

--8. Performance per region
select l.region, sum(f.sales) as total_sales,sum(f.profit) as total_profit,(sum(f.profit)/sum(f.sales))*100 as profit_margin
from FactSales as f
join DimLocation as l
on f.location_key=l.Location_Key
group by l.region
order by total_sales desc;
--The West and East regions are the strongest performers, combining high sales with healthy profit margins.
--Central generates significantly more sales than South but produces less profit, resulting in the lowest regional profit margin at 7.9%.

--9. Lets see what could be causing Central's lower profit margin
select p.sub_category,sum(f.sales) as total_sales,sum(f.profit) as total_profit,(sum(f.profit)/sum(f.sales))*100 as profit_margin
from FactSales as f
join DimProducts as p
on f.product_key=p.Product_Key
join DimLocation as l
on f.location_key=l.Location_Key
where l.region='central'
group by p.Sub_Category
order by total_profit desc;
-- The underperformance is concentrated in several sub-categories, particularly Furnishings, which generates a -25.6% margin in Central despite being profitable overall.
-- This suggests that certain product categories may perform substantially differently depending on region.

--10. Lets compare furnishings in other regions
select l.region, sum(f.sales) as total_sales,sum(f.profit) as total_profit,(sum(f.profit)/sum(f.sales))*100 as profit_margin
from FactSales as f
join DimLocation as l
on f.location_key=l.Location_Key
join DimProducts as p
on f.product_key=p.Product_Key
where p.Sub_Category='furnishings'
group by l.region
order by total_profit;
-- Furnishings is performing well in the other 3 regions but poorly in central only.

--11. Is this due to higher discounts in central or another issue?
select l.region, f.discount, count(*) as Number_of_sales, sum(f.sales) as total_sales,sum(f.profit) as total_profit,(sum(f.profit)/sum(f.sales))*100 as profit_margin
from FactSales as f
join DimLocation as l
on f.location_key=l.Location_Key
join DimProducts as p
on f.product_key=p.Product_Key
where p.Sub_Category='furnishings'
group by l.region, f.discount
order by region,f.discount;
--Central Furnishings' poor profitability is driven almost entirely by the unusually high volume of 60%-discounted sales.
-- One possible explanation is weaker demand for Furnishings in Central, leading to aggressive discounting to stimulate sales. Further investigation would be required to confirm this.

--Recommendation 2: Review 60% discounts on Central Furnishings and investigate whether the resulting sales volume justifies the substantial margin loss.
-- If demand is weak, alternative strategies such as targeted promotions or improved pricing should be considered.
-- Or, improve inventory planning and reduce stock levels for weak-demand products rather than relying on extreme discounts to clear excess stock.

--12. Customer distribution:Percentage of sales by top ten customers
with customer_sales as(select c.customer_name,sum(f.sales) as total_sales
from FactSales as f
join DimCustomer as c
on f.customer_key=c.CustomerKey
group by c.Customer_Name)
select top 10 customer_name, total_sales,(total_sales/sum(total_sales)over())*100 as percent_of_total
from customer_sales
order by percent_of_total desc;
--The top customer only contributes to 1% of total sales, so the distribution is fairly even. Losing one of the top 10 customers would not have a major impact.

--13. Purchase frequency vs sale amount
select c.customer_name,count(distinct order_id)as number_of_orders,sum(f.sales) as total_sales, (sum(f.sales)/count(distinct order_id)) as AOV
from FactSales as f
join DimCustomer as c
on f.customer_key=c.CustomerKey
group by c.Customer_Name
order by AOV desc;
-- It looks like there is no relationship between number of orders and total sales, however we will need to plot this data on a scatter graph to confirm.

--14. How do sales and profit change by month, and is there evidence of seasonal patterns?
select month(od.fulldate)as 'Month',sum(f.sales) as total_sales,sum(f.profit) as total_profit,(sum(f.profit)/sum(f.sales))*100 as profit_margin
from FactSales as f
join DimDate as od
on f.order_date_key=od.Date_Key
group by month(od.fulldate)
order by month;
-- from a glance it doesnt look like there is much seasonality. Some months are more profitable then others but it looks quite sporadic.

--15. Performance over years
select year(od.fulldate) as 'Year',sum(f.sales) as total_sales,sum(f.profit) as total_profit,(sum(f.profit)/sum(f.sales))*100 as profit_margin
from FactSales as f
join DimDate as od
on f.order_date_key=od.Date_Key
group by year(od.fulldate)
order by year;
-- The business has experienced strong growth, with sales increasing by approximately 51% and profit by approximately 86% between 2023 and 2026.
-- Profit margin has also improved from 10.5% to 12.9%, indicating that profitability has generally improved alongside revenue growth.

-- Recommendation: Continue the strategies driving revenue and profit growth while monitoring the slight decline in profit margin in 2026 to ensure profitability remains aligned with sales growth.

--16. After doing some exploratory analysis on Tableau, I discovered that Central was the only region selling at an 80% discount rate, leading to significant losses. 
-- Lets have a look closer look at this data.
select p.sub_category, l.region, sum(f.sales) as Total_Sales, sum(f.profit) as Total_profit, (sum(f.profit)/sum(f.sales))*100 as Profit_margin, count(distinct order_id) as Number_of_orders
from FactSales as f
join DimProducts as p
on f.product_key=p.Product_Key
join DimLocation as l
on f.location_key=l.Location_Key
where f.discount=0.8
group by p.Sub_Category,l.region;

SELECT
    f.order_id,
    p.sub_category,
    l.region,
    f.sales,
    f.profit,
    f.discount,
    f.quantity
FROM FactSales AS f
JOIN DimProducts AS p
    ON f.product_key = p.Product_Key
JOIN DimLocation AS l
    ON f.location_key = l.Location_Key
WHERE f.discount = 0.8
  AND l.region = 'Central';

  --Centrals Totals for python code
  SELECT
    l.region,
    SUM(f.sales) AS Total_Sales,
    SUM(f.profit) AS Total_Profit,
    (SUM(f.profit) / SUM(f.sales)) * 100 AS Profit_Margin
FROM FactSales AS f
JOIN DimLocation AS l
    ON f.location_key = l.location_key
WHERE l.region = 'Central'
GROUP BY l.region;

--Investigating why South has low profit despite healthy margins
select
p.sub_category,
sum(f.sales) as total_sales,
sum(f.profit) as total_profit,
(sum(f.profit)/sum(f.sales))*100 as profit_margin,
sum(f.quantity) as total_quantity
from FactSales as f
join DimProducts as p
on f.product_key=p.Product_Key
join DimLocation as l
on f.location_key=l.Location_Key
where l.Region='South'
group by p.Sub_Category
order by total_profit desc;

-- Lets compare total sales to other regions to see if its just lower sales or a worse product mix
select
    l.Region,
    sum(f.sales) as total_sales,
    sum(f.profit) as total_profit,
    (sum(f.profit)/sum(f.sales))*100 as profit_margin,
    sum(f.quantity) as total_quantity
from FactSales as f
join DimLocation as l
    on f.location_key = l.Location_Key
group by l.Region
order by total_profit desc;
