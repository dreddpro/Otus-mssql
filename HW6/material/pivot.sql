create table #t(mes int, fio nvarchar(45), kol int)

insert into #t(mes, fio, kol) values
 (1,'IvanovII',200)
,(1,'IvanovII',100)
,(1,'PetrovPP',100)
,(1,'PetrovPP',90)
,(1,'SidorovVV',600)
,(1,'VasilevMM',600)
,(2,'IvanovII',99)
,(2,'PetrovPP',88)
,(2,'SidorovVV',77)
,(2,'VasilevMM',60)

select * from #t order by fio


select 'AVGkol' as NameAVGCol --���������� ������ ������� � ����������� ������ ������(������ ������� �������� ������ = ������� ����������)
      ,IvanovII ,PetrovPP
from
(select fio, kol from #t) --�� ��� �������� �������� ����� ������
as SourceTable
pivot
(
avg(kol) --����� ������� �� ����� �������
for fio  --� ���� ������� �� SourceTable ���� �������� ������� ��� ������� ����������� �������
in (IvanovII ,PetrovPP) --������ ��� �������� ������� ��� ������� ����������� ������� ����� �� ����� � ������� fio
)
as PivotTable

select fio,avg(kol) from #t where fio in ('IvanovII' ,'PetrovPP')  group by fio 

--drop table #t



--������, ������������, ��� ������ PIVOT ���������� ���������� �� ���� ����� ������������� � �������� ������ ������ ����� ���� ���������� � ������� �������������(kol)
--��� ��������� ���� ���������� ��� ������������ ����� � �������� ������ � �� ������������ *
select * from #t order by mes, fio

select 'AVGkol' as NameAVGCol --���������� ������ ������� � ����������� ������ ������(������ ������� �������� ������ = ������� ����������)
      ,IvanovII ,PetrovPP
from
(select mes,fio, kol from #t) -- !!! �������� mes !!! -> ����������� ����������  �� ���� ����� ������������� � �������� ������ ������ ����� ���� ���������� � ������� �������������(kol)
as SourceTable
pivot
(
avg(kol) --����� ������� �� ����� �������
for fio  --� ���� ������� �� SourceTable ���� �������� ������� ��� ������� ����������� �������
in (IvanovII ,PetrovPP) --������ ��� �������� ������� ��� ������� ����������� ������� ����� �� ����� � ������� fio
)
as PivotTable

select mes,fio,avg(kol) from #t where fio in ('IvanovII' ,'PetrovPP')  group by mes,fio 



--���� ������ ����������, ��� ����� ��������� ������ � ��� 3-� �������, ���� �������� ������������� ������ ������ � �������������� ������
select * from #t order by mes, fio

select mes --'AVGkol' as NameAVGCol --���������� ������ ������� � ����������� ������ ������(������ ������� �������� ������ = ������� ����������)
      ,IvanovII ,PetrovPP
from
(select mes,fio, kol from #t) --�� ��� �������� �������� ����� ������  !!! �������� mes !!!
as SourceTable
pivot
(
avg(kol) --����� ������� �� ����� �������
for fio  --� ���� ������� �� SourceTable ���� �������� ������� ��� ������� ����������� �������
in (IvanovII ,PetrovPP) --������ ��� �������� ������� ��� ������� ����������� ������� ����� �� ����� � ������� fio
)
as PivotTable



--���� ������ ����������, ��� ����� ������������ �� ������������ � �������� ������ �������� ��� ������������ �������
select * from #t order by mes, fio

select 'AVGkol' as NameAVGCol --���������� ������ ������� � ����������� ������ ������(������ ������� �������� ������ = ������� ����������)
      ,IvanovII ,PetrovPP, VasechkinKK -- !!! �������� VasechkinKK !!! -> ���� ����� ����� ������ ��������������� ���� ������� � PIVOT IN
from
(select fio, kol from #t) --�� ��� �������� �������� ����� ������ 
as SourceTable
pivot
(
avg(kol) --����� ������� �� ����� �������
for fio  --� ���� ������� �� SourceTable ���� �������� ������� ��� ������� ����������� �������
in (IvanovII ,PetrovPP, VasechkinKK) --������ ��� �������� ������� ��� ������� ����������� ������� ����� �� ����� � ������� fio !!! �������� VasechkinKK !!!
)
as PivotTable


--���� ������ ����������, ��� ����� ������������(PivotTable) ����� ������������ ��� ���������� ����� JOIN
select 'AVGkol' as NameAVGCol --���������� ������ ������� � ����������� ������ ������(������ ������� �������� ������ = ������� ����������)
      ,IvanovII ,PetrovPP, VasechkinKK -- ���� ����� ����� ������ ��������������� ���� ������� � PIVOT IN
	  ,t.* --!!! �������� ������ ����� �� �������������� ������� !!!
from
(select mes,fio, kol from #t) --�� ��� �������� �������� ����� ������ 
as SourceTable 
pivot
(
avg(kol) --����� ������� �� ����� �������
for fio  --� ���� ������� �� SourceTable ���� �������� ������� ��� ������� ����������� �������
in (IvanovII ,PetrovPP, VasechkinKK) --������ ��� �������� ������� ��� ������� ����������� ������� ����� �� ����� � ������� fio
)
as PivotTable
inner join #t t on t.kol = PivotTable.IvanovII --!!! �������� inner join !!!


--������ �� �������� FROM c �������� PIVOT(��� ��������� ������� ������� ������������ ��� ������ � PIVOT)
https://learn.microsoft.com/ru-ru/sql/t-sql/queries/from-transact-sql?view=sql-server-ver16

drop table #t