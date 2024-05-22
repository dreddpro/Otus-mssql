/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

SELECT 
    InvoiceMonth, 
	[Peeples Valley, AZ],
	[Medicine Lodge, KS],
	[Gasport, NY],
    [Sylvanite, MT],  
    [Jessie, ND]
FROM
    (SELECT 
         Dates.InvoiceMonth, 
         SName.SpecName, 
         I.InvoiceID
     FROM Sales.Customers AS C
     INNER JOIN Sales.Invoices AS I
          ON I.CustomerID = C.CustomerID
     CROSS APPLY
         (
          SELECT 
              FirstBracket = CHARINDEX('(', C.CustomerName)
          ) AS FB
     CROSS APPLY
         (
          SELECT 
              LastBracket = CHARINDEX(')', C.CustomerName, FirstBracket + 1)
          ) AS LB
     CROSS APPLY
         (
          SELECT 
              SpecName = SUBSTRING(C.CustomerName, FirstBracket + 1, LastBracket - FirstBracket - 1)
          ) AS SName
     CROSS APPLY
         (
          SELECT 
              InvoiceMonth = FORMAT(DATEADD([Month], DATEDIFF([Month], 0, I.InvoiceDate), 0), 'dd.MM.yyyy')
          ) AS Dates
     WHERE C.CustomerID BETWEEN 2 AND 6
     ) AS D 
	 PIVOT(COUNT(D.[InvoiceID]) FOR D.SpecName IN(
    [Sylvanite, MT], 
    [Peeples Valley, AZ], 
    [Medicine Lodge, KS], 
    [Gasport, NY], 
    [Jessie, ND])) AS P
ORDER BY 
    CAST(P.InvoiceMonth AS DATE);

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

SELECT CustomerName, AddressLine
FROM(
	SELECT CustomerName,  DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2
	FROM Sales.Customers
	WHERE CustomerName LIKE 'Tailspin Toys%'
	) as t1
unpivot
(
AddressLine for [Address] in ([DeliveryAddressLine1], [DeliveryAddressLine2], [PostalAddressLine1], [PostalAddressLine2])
) as T_unpivot


/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

SELECT CountryId, CountryName, Code
FROM
	(SELECT CountryId, CountryName, CAST(IsoAlpha3Code AS NVARCHAR) IsoAlpha3Code, CAST(IsoNumericCode AS NVARCHAR) IsoNumericCode
	FROM Application.Countries) as t1
unpivot
(
Code for Codes in ([IsoAlpha3Code], [IsoNumericCode])
) as T_unpivot
/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT c.CustomerID, 
	c.CustomerName, 
	TopProducts.StockItemID, 
	TopProducts.StockItemName, 
	TopProducts.UnitPrice, 
(
	SELECT TOP 1 I1.InvoiceDate 
	FROM Sales.InvoiceLines AS IL1
	INNER JOIN Sales.Invoices AS I1 ON I1.InvoiceID=IL1.InvoiceLineID
	WHERE IL1.StockItemID=TopProducts.StockItemID AND I1.CustomerID=c.CustomerID
) [Date]
FROM  Sales.Customers c
CROSS APPLY 
(
	SELECT DISTINCT TOP 2 
		il.StockItemID, 
		wsi.StockItemName, 
		wsi.UnitPrice
	FROM Sales.InvoiceLines il
	INNER JOIN Sales.Invoices i
		ON i.InvoiceID=il.InvoiceLineID
	INNER JOIN Warehouse.StockItems wsi
		ON il.StockItemID=wsi.StockItemID
	WHERE i.CustomerID=c.CustomerID
	ORDER BY wsi.UnitPrice DESC
) AS TopProducts
