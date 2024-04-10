use WideWorldImporters

-- ������ + � ����� ������� SQL ��������� ���������?
select CityName as city, count(*) as qty
from Application.Cities as c
where LastEditedBy = 1
group by CityName
having count(*) > 25
order by count(*) desc

-- ������������������ ���������� Ctrl + M
select c.CityName as city, count(*) as qty
from Application.Cities as c
where c.LastEditedBy = 1 
	and city = 'Ashport' --error
group by c.CityName
having qty > 25 --error
order by qty desc --ok

-- ��� ����� ������
select c.CityName as city1
	, city2 = c.CityName
	, c.CityName city3
	, c.CityName as [city 4]
	, c.CityName as 'city 5'
	, 'city 6' = c.CityName
from Application.Cities as c

--�������� ��� ��������� �������� ����� ��������
select c1.CityName, c2.CityName 
from Application.Cities as c1
cross join Application.Cities as c2


