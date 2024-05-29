/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/
CREATE TABLE #temp (id int);

INSERT INTO Sales.Customers(CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, PrimaryContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, AccountOpenedDate
			, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode
			, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy)
OUTPUT inserted.CustomerID INTO #temp
VALUES
	 (DEFAULT, 'New Customer 01', 1, 3, 1001, 3, '19586', '19586', getdate(), 0, 0, 0, 0, '(999)999', '(999)999', 'ya.ru','Shop','Shop','000001','000001','000001','000001',1)
	,(DEFAULT, 'New Customer 02', 1, 3, 1001, 3, '19586', '19586', getdate(), 0, 0, 0, 0, '(999)999', '(999)999', 'ya.ru','Shop','Shop','000001','000001','000001','000001',1)
	,(DEFAULT, 'New Customer 03', 1, 3, 1001, 3, '19586', '19586', getdate(), 0, 0, 0, 0, '(999)999', '(999)999', 'ya.ru','Shop','Shop','000001','000001','000001','000001',1)
	,(DEFAULT, 'New Customer 04', 1, 3, 1001, 3, '19586', '19586', getdate(), 0, 0, 0, 0, '(999)999', '(999)999', 'ya.ru','Shop','Shop','000001','000001','000001','000001',1)
	,(DEFAULT, 'New Customer 05', 1, 3, 1001, 3, '19586', '19586', getdate(), 0, 0, 0, 0, '(999)999', '(999)999', 'ya.ru','Shop','Shop','000001','000001','000001','000001',1)

SELECT id FROM #temp

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE FROM Sales.Customers
WHERE CustomerID = (SELECT TOP (1) id FROM #temp);

DELETE FROM #temp
WHERE id = (SELECT TOP (1) id FROM #temp);

/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE Sales.Customers
SET CustomerName = 'New Customer 99'
WHERE CustomerID = (SELECT TOP (1) id FROM #temp);


/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/


CREATE TABLE #temp2 (DeletedCustomerID int, Action varchar(10), InsertedCustomerID int);

MERGE Sales.Customers AS target
USING
(
	SELECT TOP 1 * FROM Sales.Customers ORDER BY CustomerID DESC
) AS source
ON (target.CustomerID = source.CustomerID)
WHEN MATCHED
	THEN UPDATE
	SET
		CustomerName = 'New Customer 06'
WHEN NOT MATCHED
	THEN INSERT (CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, PrimaryContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, AccountOpenedDate
			, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode
			, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy)
	VALUES (DEFAULT, 'New Customer 07', 1, 3, 1001, 3, '19586', '19586', getdate(), 0, 0, 0, 0, '(999)999', '(999)999', 'ya.ru','Shop','Shop','000001','000001','000001','000001',1)
OUTPUT deleted.CustomerID, $action, inserted.CustomerID
INTO #temp2;

SELECT * 
FROM #temp2

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bcp in
*/
--bcp WideWorldImporters.Warehouse.Colors OUT "C:\Otus\Otus-mssql-KomisarchukSV\HW8\demo.txt" -T -S MSK-WKS-00899\SQLEXPRESS -c

EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE; 

EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE; 
GO  

SELECT @@SERVERNAME;

DECLARE @out varchar(250);
set @out = 'bcp WideWorldImporters.Sales.Invoices OUT "C:\Otus\Otus-mssql-KomisarchukSV\HW8\demo.txt" -T -S ' + @@SERVERNAME + ' -c';
PRINT @out;

EXEC master..xp_cmdshell @out

DROP TABLE IF EXISTS WideWorldImporters.Sales.Invoices_Copy;
SELECT * INTO WideWorldImporters.Sales.Invoices_Copy FROM WideWorldImporters.Sales.Invoices
WHERE 1 = 2; 


DECLARE @in varchar(250);
set @in = 'bcp WideWorldImporters.Sales.Invoices_Copy IN "C:\Otus\Otus-mssql-KomisarchukSV\HW8\demo.txt" -T -S ' + @@SERVERNAME + ' -c';

EXEC master..xp_cmdshell @in;

SELECT *
FROM WideWorldImporters.Sales.Invoices_Copy;