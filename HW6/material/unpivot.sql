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

select mes --'AVGkol' as NameAVGCol --���������� ������ ������� � ����������� ������ ������(������ ������� �������� ������ = ������� ����������)
      ,IvanovII ,PetrovPP
into #tt	  
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

select * from #tt

--������ ��� ������������ ������� �� #tt
select columnname, valuekol
from #tt
unpivot
(
valuekol for columnname in (IvanovII)
) as T_unpivot

--������ C ������������ �������� �� #tt
select mes, columnname, valuekol
from #tt
--from (select * from #tt) as a
unpivot
(
valuekol for columnname in (IvanovII)
) as T_unpivot


--��������� ������ ��������� �������������
--���� �� ���������� �� ����� ��������:
create table #svod([2020] int, [2021] int, [2022] int, [2023] int)

insert into #svod([2020], [2021], [2022], [2023]) values
 (1024,560,200,444)

select * from #svod

--��� ������������ ��������
select  columnname, kol
from #svod
unpivot
(
kol for columnname in ([2020],[2021],[2022],[2023])
) as T_unpivot

--����� ������������ SQL c ������� PIVOT � ������ ���� ��������� VIEW ��������������� �������� �������

 drop table #svod