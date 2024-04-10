use WideWorldImporters --выбор базы

--варианты обращения к таблице
select * from WideWorldImporters.Application.People
select * from Application.People
select * from People --если схема != dbo

-- * с осторожностью на больших таблицах, лучше указать нужные колонки
set statistics time, io on

select * from Sales.OrderLines       --CPU time = 453 ms,  elapsed time = 4488 ms.
select OrderID from Sales.OrderLines --CPU time = 157 ms,  elapsed time = 2216 ms.

set statistics time, io off

-- без дублей
select CityName from Application.Cities
select distinct CityName from Application.Cities

-- ****************************************
-- ограничение кол-ва строк
-- ****************************************

select top 10 * from Application.Cities --быстро

-- без сортировки порядок не гарантирован - см Abbott
select top 10 CityID, CityName, StateProvinceID from Application.Cities
select top 10 CityID, CityName, StateProvinceID from Application.Cities order by CityName --будет другая информация 

-- сортировка по нескольким полям
select top 10 CityID, CityName, StateProvinceID from Application.Cities order by CityName asc, StateProvinceID asc
select top 10 CityID, CityName, StateProvinceID from Application.Cities order by 2, 3 desc
--сортировка изменится при добавлении колонок => сортировать лучше по названию
select top 10 CityName, StateProvinceID, LastEditedBy from Application.Cities order by 2, 3 desc


--кол-во строк - через переменную
DECLARE @n INT = 5
SELECT (TOP @n) * FROM Application.Cities

-- ****************************************
-- Постраничная выборка
-- ****************************************

DECLARE @m INT = 5
SELECT *
FROM Application.Cities as c
ORDER BY c.CityName ASC OFFSET 0 ROWS -- сортировка обязательна 
FETCH NEXT @m ROWS ONLY

-- общая формула
DECLARE @pagesize BIGINT = 10, -- Размер страницы
	@pagenum BIGINT = 1;-- Номер страницы

SELECT StockItemID, StockItemName, UnitPrice
FROM Warehouse.StockItems
ORDER BY UnitPrice DESC OFFSET(@pagenum - 1) * @pagesize ROWS -- сортировка обязательна 
FETCH NEXT @pagesize ROWS ONLY

-- ****************************************
-- вывод граничных значений
-- ****************************************
-- SELECT TOP N WITH TIES ... - выводит N строк + все строки с граничным значением столбцов сортировки


--товары по убыванию цены
SELECT StockItemID, StockItemName, UnitPrice
FROM Warehouse.StockItems
ORDER BY UnitPrice DESC

--товары, входящие в 3ку самых дорогих на складе => потеря 1 товара с граничной ценой (285.00)
SELECT TOP 3 StockItemID, StockItemName, UnitPrice
FROM Warehouse.StockItems
ORDER BY UnitPrice DESC

-- выводит строки с граничным значением столбцов сортировки
-- граница по столбцу сортировки - UnitPrice = 285.00 => 2 строки с UnitPrice = 285.00
SELECT TOP 3 WITH TIES StockItemID, StockItemName, UnitPrice
FROM Warehouse.StockItems
ORDER BY UnitPrice DESC -- сортировка обязательна!!


-- 3 строки:  граница по столбцам сортировки  - UnitPrice = 285.00, StockItemID = 73 => только 1 строка
SELECT TOP 3 WITH TIES StockItemID, StockItemName, UnitPrice
FROM Warehouse.StockItems
ORDER BY UnitPrice DESC,  StockItemID -- сортировка обязательна!!