select OrderId
      ,UnitPrice
	  ,PickedQuantity
	  ,UnitPrice*PickedQuantity as cost
	  --����� �� ��������� ������ ������, ������ 1=����� ������� �������
	  ,rank() over (partition by OL.OrderId order by UnitPrice*PickedQuantity desc) as NumberPos_rank
	  ,row_number() over (partition by OL.OrderId order by UnitPrice*PickedQuantity desc) as NumberPos_rownumber

	  ,������������   = last_value (PickedQuantity) over  (partition by OL.OrderId order by UnitPrice*PickedQuantity desc rows between unbounded preceding and unbounded following)
	  ,������������2  = last_value (PickedQuantity) over  (partition by OL.OrderId order by UnitPrice*PickedQuantity desc rows between 1 preceding and 1 following)

	  ,������������   = first_value (PickedQuantity) over  (partition by OL.OrderId order by UnitPrice*PickedQuantity desc rows between unbounded preceding and unbounded following)
	  ,������������2  = first_value (PickedQuantity) over  (partition by OL.OrderId order by UnitPrice*PickedQuantity desc rows between 1 preceding and 1 following)

from sales.OrderLines OL 
where OrderID = 2090 or OrderID = 8
order by OrderID, NumberPos_rownumber

--update o
--set o.PickedQuantity = 1
--from sales.OrderLines o 
--where OrderID = 8 and UnitPrice=13

select OrderId
      ,UnitPrice
	  ,PickedQuantity
	  ,UnitPrice*PickedQuantity as cost
	
	  ,��������� = last_value (PickedQuantity) over  (partition by OL.OrderId order by UnitPrice*PickedQuantity rows between 1 following and 1 following)
	  ,���������� = last_value (PickedQuantity) over  (partition by OL.OrderId order by UnitPrice*PickedQuantity rows between 1 preceding and 1 preceding)

from sales.OrderLines OL 
where OrderID = 2090 or OrderID = 8
order by OrderID, cost


--RANGE
select OrderId
      ,UnitPrice
	  ,PickedQuantity
	  ,UnitPrice*PickedQuantity as cost
	  --����� �� ��������� ������ ������, ������ 1=����� ������� �������
	  ,rank() over (partition by OL.OrderId order by UnitPrice*PickedQuantity desc) as NumberPos_rank
	  ,row_number() over (partition by OL.OrderId order by UnitPrice*PickedQuantity desc) as NumberPos_rownumber
	  --������� ������� RANGE ������� ��� ������ � ����������� "UnitPrice*PickedQuantity"
	  ,�����  = sum(PickedQuantity) over  (partition by OL.OrderId order by UnitPrice*PickedQuantity desc range CURRENT ROW)

from sales.OrderLines OL 
where OrderID = 2090 or OrderID = 8
order by OrderID, NumberPos_rownumber