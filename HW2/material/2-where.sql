use WideWorldImporters;

-------------
-- where - фильтрация строк по условию 
-- условие принимает 3 значения: true, false, unknown (неопределено - если в поле null)
-- в итог попадут строки, у которых условие выполнено ( = true )-------------
select Size, * from Warehouse.StockItems where 0=1 --сколько строк?
select Size, * from Warehouse.StockItems where 1=1 --сколько строк? 229

select Size, * from Warehouse.StockItems where Size = '1/12 scale' --9 строк
select Size, * from Warehouse.StockItems where Size != '1/12 scale' --154 строки  Size <> '1/12 scale'
--остальные: Size = null
select Size, * from Warehouse.StockItems where Size = null --логическое выражение != TRUE


-- null в where: is null, is not null
select Size, * from Warehouse.StockItems where Size is null

-- null в колонке: isnull(), coalesce()
-- coalisce () - вывод первого не null-значения
select Size, ColorId, isnull(Size, 0) as [isnull], coalesce(Size, ColorId, -10) as [coalesce]
from Warehouse.StockItems 
where Size is null


-- isnull() - преобразование к типу 1го параметра 
-- coalesce() - тип данных сохраняется
select val, isnull(val, 1.4) as [isnull], coalesce(val, 1.4) as [coalesce]
from (
	select 1 as val
	union all 
	select null
) t

-------------
-- Функции в WHERE
-------------

SELECT OrderID, OrderDate, year(OrderDate)
FROM Sales.Orders o
WHERE year(OrderDate) = 2013
-- Но так лучше не писать (не может использоваться индекс (если он когда-нибудь появится)).

-- Лучше через BETWEEN
SELECT OrderDate, OrderID
FROM Sales.Orders o
WHERE OrderDate BETWEEN '2013-01-01' AND '2013-12-31'

-- WHERE по выражению
SELECT  OrderLineID AS [Order Line ID], Quantity, UnitPrice, (Quantity * UnitPrice) AS [TotalCost]
FROM Sales.OrderLines
WHERE (Quantity * UnitPrice) > 1000

--like 
select * from Warehouse.StockItems where StockItemName like 'USB%' -- начинается
select * from Warehouse.StockItems where StockItemName like '%USB%' --где угодно USB
select * from Warehouse.StockItems where StockItemName like '%USB' -- заканчиввется

-------------
-- несколько условий: AND, OR, NOT
-------------
-- вывести StockItems, где цена от 350 до 500 и название начинается с USB или Ride

-- почему попали строки с ценой < 350? 
select RecommendedRetailPrice, *
from Warehouse.StockItems
where
    RecommendedRetailPrice between 350 and 500 --цена от 350 до 500
	AND StockItemName like 'USB%' --название начинается с USB
 	OR StockItemName like 'Ride%' --название начинается с Ride


--pgdn







-- AND, OR - есть очередность выполнения - вначале все AND, затем OR
-- смена приоритета - скобки
select RecommendedRetailPrice, *
from Warehouse.StockItems
where
    RecommendedRetailPrice between 350 and 500 --цена от 350 до 500
	and (StockItemName like 'USB%' --название начинается с USB
    or StockItemName like 'Ride%') --название начинается с Ride

-------------
--работа с датами
-------------
declare @dt datetime = getdate()
select year(@dt) as [Год]  
	, [Месяц] = month(@dt)
	, datepart(quarter, @dt) as 'Квартал'
	, datename(month, @dt) as "Месяц "
	, FORMAT(@dt, 'MMMM', 'ru-ru') as [Месяц Ru]
	, FORMAT(@dt, 'D', 'ru-ru') as 'Russian'
	, FORMAT(@dt, 'D', 'en-US' ) 'US English'  
	, convert(varchar, @dt, 104) as [Дата] 
	, datetrunc(month, @dt) as begin_of_month  --c SQL2022
	, eomonth(@dt) as end_of_month

--дата в условии where - удобен формат 'yyyyMMdd' или 'yyyy-mm-dd'
select OrderDate from Sales.Orders where OrderDate = '20150502'
select OrderDate from Sales.Orders where OrderDate = '02.05.2015' --почему разное кол-во?


select @@language, FORMAT(cast('02.05.2015' as date), 'D', 'ru-ru') 

SET LANGUAGE 'Russian' --на уровне сеанса
select @@language, FORMAT(cast('02.05.2015' as date), 'D', 'ru-ru') 

SET LANGUAGE 'English' --верну обратно
select @@language, FORMAT(cast('02.05.2015' as date), 'D', 'ru-ru') 

-- используем универсальный формат 'yyyyMMdd' или 'yyyy-mm-dd'