create table #nsi(id int primary key, names nvarchar(45), zn int)

insert into #nsi(id, names, zn) values
 (1,'Set diagnostik ON\OF',1)
,(2,'Set visible Col',4)
,(3,'Set visible NULL ',1)

select * from #nsi

select --'AVGkol' as NameAVGCol --���������� ������ ������� � ����������� ������ ������(������ ������� �������� ������ = ������� ����������)
      [1], [2], [3]
from
(select id, zn from #nsi) --�� ��� �������� �������� ����� ������
as SourceTable
pivot
(
max(zn) --��������� � �������� ������ ����������� ����� ������ ���� ������, �.�. ���������� �� primary key, �� ����� ������������ ����� �-�
for id  --� ���� ������� �� SourceTable ���� �������� ������� ��� ������� ����������� �������
in ([1], [2], [3]) --������ ��� �������� ������� ��� ������� ����������� ������� ����� �� ����� � ������� fio
)
as PivotTable

drop table #nsi