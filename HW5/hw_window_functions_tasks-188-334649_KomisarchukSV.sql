/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

SELECT CAST(lastEditedWhen AS DATE),
		(SELECT SUM(ExtendedPrice) FROM Sales.InvoiceLines t2 WHERE EOMONTH(CAST(t1.lastEditedWhen AS DATE)) >= CAST(t2.lastEditedWhen AS DATE) AND YEAR(lastEditedWhen)> 2014) AS RunningTotal
FROM Sales.InvoiceLines t1
GROUP BY lastEditedWhen
HAVING YEAR(lastEditedWhen)> 2014
ORDER BY lastEditedWhen

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

SELECT t1.LastEditedWhen,
		sum(t1.ExtendedPrice) over(ORDER BY EOMONTH(t1.lastEditedWhen))
FROM (SELECT CAST(lastEditedWhen AS DATE) AS LastEditedWhen, SUM(ExtendedPrice) AS ExtendedPrice FROM Sales.InvoiceLines GROUP BY lastEditedWhen HAVING YEAR(lastEditedWhen)> 2014) t1
ORDER BY t1.lastEditedWhen


/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/,

SELECT *
FROM 
(SELECT i.ГОД, 
       i.Месяц, 
       i.Description, 
       i.SUM, 
       ROW_NUMBER() OVER(PARTITION BY i.Месяц ORDER BY SUM DESC) AS [Num]
FROM (SELECT YEAR(LastEditedWhen) as ГОД, MONTH(LastEditedWhen) AS Месяц, Description, SUM(Quantity) AS SUM
	FROM Sales.InvoiceLines
	GROUP BY Description, YEAR(LastEditedWhen), MONTH(LastEditedWhen)
	HAVING YEAR(LastEditedWhen) = 2016) AS i) AS p
WHERE p.Num <= 2


/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT s.StockItemID, 
    s.StockItemName, 
    s.Brand, 
    ROW_NUMBER() OVER(PARTITION BY LEFT(s.StockItemName, 1) ORDER BY s.StockItemName) [FirstChar], 
    COUNT(*) OVER() [TotalCount], 
    COUNT(*) OVER(PARTITION BY LEFT(s.StockItemName, 1)) [TotalCount], 
    LEAD(s.StockItemID) OVER(ORDER BY s.StockItemName) [NextId], 
    LAG(s.StockItemID) OVER(ORDER BY s.StockItemName) [PrevId], 
    LAG(s.StockItemName, 2, 'No items') OVER(ORDER BY s.StockItemName) [Prevx2Name],
    NTILE(30) OVER(ORDER BY s.TypicalWeightPerUnit) [GroupWeight]
FROM Warehouse.StockItems s
ORDER BY s.StockItemName;

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

SELECT p.PersonID, 
       p.FullName, 
       c.CustomerID, 
       c.CustomerName, 
       r.TransactionDate, 
       r.TransactionAmount
FROM
(
    SELECT ct.CustomerID, 
           i.SalespersonPersonID, 
           ct.TransactionDate, 
           ct.TransactionAmount, 
           ROW_NUMBER() OVER(PARTITION BY SalespersonPersonID ORDER BY TransactionDate DESC) AS [Num]
    FROM Sales.CustomerTransactions ct
         INNER JOIN Sales.Invoices i ON ct.InvoiceID = i.InvoiceID
) AS r
INNER JOIN Application.People p ON r.SalespersonPersonID = p.PersonID
INNER JOIN Sales.Customers c ON r.CustomerID = c.CustomerID
WHERE r.[num] = 1;

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT c.CustomerID, 
       c.CustomerName, 
       subq.StockItemID, 
       subq.StockItemName, 
       subq.UnitPrice, 
       subq.InvoiceDate
FROM
(
    SELECT i.CustomerID, 
           il.StockItemID, 
           si.StockItemName, 
           si.UnitPrice, 
           i.InvoiceDate, 
           ROW_NUMBER() OVER(PARTITION BY i.CustomerID ORDER BY si.UnitPrice DESC) AS [Num]
    FROM Sales.InvoiceLines il
         INNER JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
         INNER JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
) AS subq
INNER JOIN Sales.Customers c ON subq.CustomerID = c.CustomerID
WHERE subq.Num <= 2;

Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 