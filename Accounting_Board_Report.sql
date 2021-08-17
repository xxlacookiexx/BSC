-- Create Bed Day Table
drop table BD_ACCT;
create table BD_ACCT
as (select days.lob,
       case
         when days.lob = 100 then
          'Medi-Cal LA'
         when days.lob = 700 then
          'Medi-Cal SD'
         when days.lob = 120 then
          'CMC LA'
         when days.lob = 720 then
          'CMC SD'
         when days.lob = 2400 then
          'Medicare LA'
         when days.lob = 2700 then
          'Medicare SD'
         when days.lob = 2800 then
          'Medicare Riverside'
         when days.lob = 2600 then
          'Medicare San Bernadino'
         when days.lob = 2500 then
          'Medicare Orange County'
         when days.lob = 2416 then
          'Medicare Santa Clara'
         when days.lob = 2446 then
          'Medicare Merced'
         when days.lob = 2438 then
          'Medicare El Paso'
         when days.lob = 2422 then
          'Medicare Stanislaus'
         when days.lob = 2437 then
          'Medicare Fresno'
       end as "LOB_DESC",
       days.category,
       days.ccs_in_auth,
       days.bed_type,
       sum(days.admit) admit,
       sum(days.days) BED_DAYS,
       sum(days.los_admits) LOS_ADMITS,
       sum(days.los_days) LOS_DAYS,
       days.mo,
       days.yr,
       days.yr_mo,
       days.load_dt

  from um_days_tbl days

 where days.ccs_in_auth = 0
   and days.yr_mo between
       to_char(to_date('&start_dt', 'mm/dd/yyyy'), 'yyyymm') and
       to_char(to_date('&end_dt', 'mm/dd/yyyy'), 'yyyymm')

 group by days.lob,
          days.category,
          days.ccs_in_auth,
          days.bed_type,
          days.mo,
          days.yr,
          days.yr_mo,
          days.load_dt);

-- Create member table          
drop table MBR_ACCT;
create table MBR_ACCT
as (select mbr.lob,
       case
         when mbr.lob = 100 then
          'Medi-Cal LA'
         when mbr.lob = 700 then
          'Medi-Cal SD'
         when mbr.lob = 120 then
          'CMC LA'
         when mbr.lob = 720 then
          'CMC SD'
         when mbr.lob = 2400 then
          'Medicare LA'
         when mbr.lob = 2700 then
          'Medicare SD'
         when mbr.lob = 2800 then
          'Medicare Riverside'
         when mbr.lob = 2600 then
          'Medicare San Bernadino'
         when mbr.lob = 2500 then
          'Medicare Orange County'
         when mbr.lob = 2416 then
          'Medicare Santa Clara'
         when mbr.lob = 2446 then
          'Medicare Merced'
         when mbr.lob = 2438 then
          'Medicare El Paso'
         when mbr.lob = 2422 then
          'Medicare Stanislaus'
         when mbr.lob = 2437 then
          'Medicare Fresno'
       end as "LOB_DESC",
       sum(mbr.mbrs) MBR_CNT,
       mbr.mo,
       mbr.yr,
       mbr.yr_mo
  from um_mbrs_tbl mbr
  left join careware.lob_codes lob on to_char(mbr.lob) = lob.lob_cd

 where mbr.yr_mo between
       to_char(to_date('&start_dt', 'mm/dd/yyyy'), 'yyyymm') and
       to_char(to_date('&end_dt', 'mm/dd/yyyy'), 'yyyymm')

 group by mbr.lob, lob.description, mbr.mo, mbr.yr, mbr.yr_mo);
 
 -- ACCOUNTING
 select mbr.lob_desc,
       bd.bed_type,
       bd.category,
       mbr.mbr_cnt,
       bd.bed_days,
       round(sum(bd.bed_days) / sum(mbr.mbr_cnt) * 12000, 2) as "DAYS/1000",
       bd.admit,
       round(sum(bd.admit) / sum(mbr.mbr_cnt) * 12000, 2) as "ADMITS/1000",
       case
         when bd.los_admits = 0 then
          0
         else
          round(sum(bd.los_days) / sum(bd.los_admits), 2)
       end as "ALOS"
  from BD_ACCT bd
  left join MBR_ACCT mbr on bd.lob_desc = mbr.lob_desc
                        and bd.yr_mo = mbr.yr_mo

 group by mbr.lob_desc,
          bd.category,
          bd.bed_type,
          mbr.mbr_cnt,
          bd.bed_days,
          bd.admit,
          bd.los_admits,
          bd.los_days
 
