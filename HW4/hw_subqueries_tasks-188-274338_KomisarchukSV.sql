/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

SELECT FullName, PersonID
FROM Application.People
WHERE IsSalesPerson = 1
AND PersonID NOT IN (SELECT DISTINCT SalespersonPersonID
	FROM Sales.Invoices
	WHERE InvoiceDate = '2015-07-04')

SELECT FullName, PersonID
FROM Application.People Peop
LEFT JOIN (SELECT DISTINCT SalespersonPersonID
	FROM Sales.Invoices
	WHERE InvoiceDate = '2015-07-04') P ON P.SalespersonPersonID = Peop.PersonID
WHERE Peop.IsSalesPerson = 1 AND P.SalespersonPersonID IS NULL

;WITH SalespersonCTE (SalespersonPersonID) AS (
	SELECT DISTINCT SalespersonPersonID
	FROM Sales.Invoices
	WHERE InvoiceDate = '2015-07-04'
	)
SELECT P.FullName, P.PersonID
FROM Application.People AS P
LEFT JOIN SalespersonCTE AS I ON P.PersonID = I.SalespersonPersonID
WHERE P.IsSalesPerson = 1 AND I.SalespersonPersonID IS NULL

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

SELECT DISTINCT StockItemID, Description, UnitPrice
FROM Sales.InvoiceLines
WHERE UnitPrice = (SELECT MIN(UnitPrice)
					FROM Sales.InvoiceLines)

SELECT DISTINCT StockItemID, Description, UnitPrice
FROM Sales.InvoiceLines
WHERE UnitPrice = (SELECT TOP 1 UnitPrice
					FROM Sales.InvoiceLines
					ORDER BY UnitPrice)

SELECT StockItemID, StockItemName, UnitPrice 
FROM Warehouse.StockItems
WHERE UnitPrice <= ALL /*любой*/(SELECT UnitPrice FROM Warehouse.StockItems)


;WITH SalesCTE (SalesMIN) AS (
	SELECT MIN(UnitPrice)
	FROM Sales.InvoiceLines
	)
SELECT DISTINCT StockItemID, Description, UnitPrice
FROM Sales.InvoiceLines AS I
LEFT JOIN SalesCTE AS S ON I.UnitPrice = S.SalesMIN
WHERE S.SalesMIN IS NOT NULL


/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

SELECT *
FROM Sales.Customers
WHERE CustomerID IN (SELECT TOP 5 CustomerID
							FROM Sales.CustomerTransactions
							ORDER BY TransactionAmount DESC)

;WITH SalesCTE (SalesMIN) AS (
	SELECT TOP 5 CustomerID
	FROM Sales.CustomerTransactions
	ORDER BY TransactionAmount DESC
	)
SELECT *
FROM Sales.Customers AS I
LEFT JOIN SalesCTE AS S ON I.CustomerID = S.SalesMIN
WHERE S.SalesMIN IS NOT NULL


/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

SELECT DISTINCT Cit.CityID, CityName, 
	(SELECT FullName
	FROM Application.People 
	WHERE People.PersonID = I.PackedByPersonID) AS FullName
FROM Sales.Invoices I
LEFT JOIN Sales.InvoiceLines IL ON I.InvoiceID = IL.InvoiceID
LEFT JOIN Sales.Customers C ON I.CustomerID = C.CustomerID
LEFT JOIN Application.Cities Cit ON C.DeliveryCityID = Cit.CityID
WHERE IL.UnitPrice IN (SELECT DISTINCT TOP 3 UnitPrice
						FROM Sales.InvoiceLines
						ORDER BY UnitPrice DESC)

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SET STATISTICS IO, TIME ON

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC



-- --

TODO: напишите здесь свое решение
