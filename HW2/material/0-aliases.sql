use WideWorldImporters

-- алиасы + В каком порядке SQL выполняет операторы?
select CityName as city, count(*) as qty
from Application.Cities as c
where LastEditedBy = 1
group by CityName
having count(*) > 25
order by count(*) desc

-- последовательность выполнения Ctrl + M
select c.CityName as city, count(*) as qty
from Application.Cities as c
where c.LastEditedBy = 1 
	and city = 'Ashport' --error
group by c.CityName
having qty > 25 --error
order by qty desc --ok

-- как можно задать
select c.CityName as city1
	, city2 = c.CityName
	, c.CityName city3
	, c.CityName as [city 4]
	, c.CityName as 'city 5'
	, 'city 6' = c.CityName
from Application.Cities as c

--получить все возможные маршруты между городами
select c1.CityName, c2.CityName 
from Application.Cities as c1
cross join Application.Cities as c2


