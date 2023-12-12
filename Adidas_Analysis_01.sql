-- 제품별 판매량
SELECT Product, SUM(UnitsSold) AS Units_Sold 
FROM adidas.adidas
GROUP BY Product
ORDER BY Units_Sold DESC;

-- 제품별 매출액
SELECT Product, SUM(TotalSales) AS Total_Sales 
FROM adidas.adidas
GROUP BY Product
ORDER BY Total_Sales DESC;

-- 각 도시 별 가장 많이 팔린 제품
WITH city_product AS(
	SELECT City, Product, AVG(UnitsSold) AS UnitsSold
    FROM adidas.adidas
    GROUP BY City, Product
)

SELECT cp.City, cp.Product, cp.UnitsSold 
FROM (
	SELECT City, Product, UnitsSold, 
    row_number() over (partition by City order by UnitsSold desc) as rnk
    FROM city_product
)cp
where cp.rnk = 1
order by cp.UnitsSold desc;

-- 각 주 별 가장 많이 팔린 제품
WITH state_product AS(
	SELECT State, Product, AVG(UnitsSold) AS UnitsSold
    FROM adidas.adidas
    GROUP BY State, Product
)

SELECT sp.State, sp.Product, sp.UnitsSold 
FROM (
	SELECT State, Product, UnitsSold, 
    row_number() over (partition by State order by UnitsSold desc) as rnk
    FROM State_product
)sp
where sp.rnk = 1
order by sp.UnitsSold desc;

-- 각 주 별 가장 매출이 많은 도시
WITH state_sales AS(
	SELECT State, City, AVG(TotalSales) AS TotalSales
    FROM adidas.adidas
    GROUP BY State, City
)

SELECT ss.State, ss.City, ss.TotalSales 
FROM (
	SELECT State, City, TotalSales, 
    row_number() over (partition by State order by TotalSales desc) as rnk
    FROM state_sales
)ss
where ss.rnk = 1
order by ss.TotalSales desc;

-- 블랙프라이데이 + 추수감사절 기간 : 2020-11-23 ~ 2020-11-27
-- 11월달만 비교
select coalesce(avg(TotalSales),0) as BF2020
from adidas.adidas
where InvoiceDate between '2020.11.23' and '2020.11.27';

select coalesce(avg(TotalSales),0) as BF2020
from adidas.adidas
where month(InvoiceDate) = 11 and (InvoiceDate < '2020.11.23' or InvoiceDate >'2020.11.27');

-- 블랙프라이데이 + 추수감사절 기간 : 2021-11-22 ~ 2021-11-26
-- 11월달만 비교
select coalesce(avg(TotalSales),0) as BF2021
from adidas.adidas
where InvoiceDate between '2021.11.22' and '2021.11.26';

select coalesce(avg(TotalSales),0) as BF2020
from adidas.adidas
where month(InvoiceDate) = 11 and (InvoiceDate < '2021.11.22' or InvoiceDate >'2021.11.26');

-- 2020&2021 합친거
select '2020' as year , coalesce(avg(TotalSales),0) as BF
from adidas.adidas
where InvoiceDate between '2020.11.23' and '2020.11.27'
union all
select '2021' as year, coalesce(avg(TotalSales),0) as BF
from adidas.adidas
where InvoiceDate between '2021.11.22' and '2021.11.26';

select '2020' as year , coalesce(avg(TotalSales),0) as BF
from adidas.adidas
where month(InvoiceDate) = 11 and (InvoiceDate < '2020.11.23' or InvoiceDate >'2020.11.27')
union all
select '2021' as year, coalesce(avg(TotalSales),0) as BF
from adidas.adidas
where month(InvoiceDate) = 11 and (InvoiceDate < '2021.11.22' or InvoiceDate >'2021.11.26');

-- 크리스마스 기간과 그 외 날의 매출차이
-- 2020-12-18 ~ 2020-12-24
-- 2021-12-18 ~ 2021-12-24
select '2020' as year , coalesce(avg(TotalSales),0) as CM
from adidas.adidas
where InvoiceDate between '2020.12.18' and '2020.12.24'
union all
select '2021' as year, coalesce(avg(TotalSales),0) as CM
from adidas.adidas
where InvoiceDate between '2021.12.18' and '2021.12.24';

select '2020' as year , coalesce(avg(TotalSales),0) as NCM
from adidas.adidas
where month(InvoiceDate) = 12 and (InvoiceDate < '2020.12.18' or InvoiceDate >'2020.12.24')
union all
select '2021' as year, coalesce(avg(TotalSales),0) as NCM
from adidas.adidas
where month(InvoiceDate) = 12 and (InvoiceDate < '2021.12.18' or InvoiceDate >'2021.12.24');

-- 블랙프라이데이+추수감사절이 있는 11월달과 크리스마스 있는 12월달,  그 외의 달 매출 량 비교
select '2020' as year,
	case 
		when month(InvoiceDate) = 11 then '11'
        when month(InvoiceDate) = 12 then '12'
        else 'other'
	end as month,
    avg(UnitsSold) as UnitsSold
from adidas.adidas
where year(InvoiceDate) = 2020
group by month
union all
select '2021' as year,
	case 
		when month(InvoiceDate) = 11 then '11'
        when month(InvoiceDate) = 12 then '12'
        else 'other'
	end as month,
    avg(UnitsSold) as UnitsSold
from adidas.adidas
where year(InvoiceDate) = 2021
group by month;
