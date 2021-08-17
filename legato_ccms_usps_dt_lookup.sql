-- provide auth number without '*' and join to field4 and grap field3
-- Take field3 and link in Access DB to careware.mail_log to get USPS_DT
select * 
from   sysop.ae_dt26@legato l
where l."field2" = 'UM'

--------------------------------------------

select * from sysop.ae_apps@legato

--------------------------------------------
--Legato view from PL/SQL
select b."field5" as AUTH_NO,
       a."field2" as REC_DT
from   sysop.ae_dt10@legato a,
       sysop.ae_rf10@legato b
where a."field14" = b."field14"
and b."field5" in ('2381395*PAN')

------------------------------------------------
--CCMS views from PL/SQL

select *
from notes@ccms