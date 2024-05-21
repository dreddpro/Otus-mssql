# Подзапросы, CTE, временные таблицы. ДЗ
___
## Цели занятия
писать запросы с использованием подзапросов;
рассказать, что будет в результате выполнения запроса, без его запуска;
создавать временные таблицы и табличные переменные;
объяснять разницу между этими объектами.
___
## Краткое содержание
операторы IN, EXISTS, NOT EXISTS, ANY, SOME, ALL;
выборки из подзапросов;
WITH табличные выражения (в том числе рекурсивные);
представления и материализованные представления;
анализируем получающиеся планы и сравниваем их;
временные таблицы и табличные переменные;
в чем разница между ними и когда что нужно выбрать?
___
## Результаты
скрипты с условиями для выборки из БД проекта WWI.
___
## Преподаватель
Людмила Громницкая
___
## Дата и время
11 апреля, четверг в 20:00
Длительность занятия: 90 минут
___
## Материалы
___
# Домашнее задание
___
## Цель:
В этом ДЗ вы научитесь писать подзапросы и CTE.
___

## Описание/Пошаговая инструкция выполнения домашнего задания:

Для всех заданий, где возможно, сделайте два варианта запросов:

через вложенный запрос  
через WITH (для производных таблиц)  

Напишите запросы:  
Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), и не сделали ни одной продажи 04 июля 2015 года. Вывести ИД сотрудника и его полное имя. Продажи смотреть в таблице Sales.Invoices.  
Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. Вывести: ИД товара, наименование товара, цена.  
Выберите информацию по клиентам, которые перевели компании пять максимальных платежей из Sales.CustomerTransactions. Представьте несколько способов (в том числе с CTE).  
Выберите города (ид и название), в которые были доставлены товары, входящие в тройку самых дорогих товаров, а также имя сотрудника, который осуществлял упаковку заказов (PackedByPersonID).  

Опционально:  
Объясните, что делает и оптимизируйте запрос:  
SELECT  
Invoices.InvoiceID,  
Invoices.InvoiceDate,  
(SELECT People.FullName  
FROM Application.People  
WHERE People.PersonID = Invoices.SalespersonPersonID  
) AS SalesPersonName,  
SalesTotals.TotalSumm AS TotalSummByInvoice,  
(SELECT SUM(OrderLines.PickedQuantityOrderLines.UnitPrice)  
FROM Sales.OrderLines  
WHERE OrderLines.OrderId = (SELECT Orders.OrderId  
FROM Sales.Orders  
WHERE Orders.PickingCompletedWhen IS NOT NULL  
AND Orders.OrderId = Invoices.OrderId)  
) AS TotalSummForPickedItems  
FROM Sales.Invoices  
JOIN  
(SELECT InvoiceId, SUM(QuantityUnitPrice) AS TotalSumm  
FROM Sales.InvoiceLines  
GROUP BY InvoiceId  
HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals  
ON Invoices.InvoiceID = SalesTotals.InvoiceID  
ORDER BY TotalSumm DESC  

Можно двигаться как в сторону улучшения читабельности запроса, так и в сторону упрощения плана\ускорения. Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). Напишите ваши рассуждения по поводу оптимизации.
___
# Решение
[Здесь](homework_group_by-188-f40326_KomisarchukSV.sql)