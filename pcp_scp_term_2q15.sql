select distinct
careware.providers.lname,
careware.providers.fname,
careware.prov_regions.region,
careware.providers.p_s_flag Type,
careware.providers.license_no,
careware.providers.prov_id SITE_ID,
careware.prov_regions.reg_eff_dt,
careware.prov_regions.reg_dis_dt,
careware.providers.sex

from careware.providers

inner join careware.prov_regions
on careware.providers.prov_id=careware.prov_regions.prov_id

where careware.prov_regions.lob='100'
and careware.prov_regions.reg_dis_dt between to_date('03/31/2015','mm/dd/yyyy') 
and to_date('05/31/2015','mm/dd/yyyy')
and careware.providers.p_s_flag in ('P','S')
and careware.providers.sex is not null

order by reg_dis_dt;
