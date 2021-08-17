-- Refresh SUM_MBRS table
drop table SUM_MBRS;
create table SUM_MBRS
as (select mbr.PLAN_TYPE, mbr.YR_MO, sum(mbr.MBRS) MBRS

  from (select distinct case
                          when mbrs.plan_type = 'Medi-Cal' then
                           'Medi-Cal'
                          when mbrs.plan_type in ('MMP') then
                           'MMP'
                          else
                           'Medicare'
                        end as "PLAN_TYPE",
                        mbrs.yr_mo,
                        sum(mbrs.mbrs) MBRS
        
          from um_mbrs_tbl mbrs
          
          where  mbrs.yr_mo between to_char(sysdate,'yyyymm')-6 and to_char(sysdate,'yyyymm')
        
         group by mbrs.plan_type, mbrs.yr_mo) mbr

 group by mbr.PLAN_TYPE, mbr.YR_MO);
 
 -- Refresh SUM_DAYS table
Drop table SUM_DAYS;
create table SUM_DAYS
as (select days.plan_types,
       days.yr_mo,
       days.category,
       days.ccs_in_auth,
       days.bed_type,
       sum(days.admit) ADMIT,
       sum(days.days) DAYS,
       sum(days.los_days) LOS_DAYS,
       sum(days.los_admits) LOS_ADMIT,
       sum(days.readmits) READMITS

  from um_days_tbl days

 where days.bed_type <> 'OB'
  and days.yr_mo between to_char(sysdate,'yyyymm')-6 and to_char(sysdate,'yyyymm')

 group by days.plan_types,
       days.yr_mo,
       days.category,
       days.ccs_in_auth,
       days.bed_type);
       
-- Membership count per Plan Type
select * from sum_mbrs t
order by  t.plan_type,t.yr_mo;

-- Compile Per Thousand calculations for Medi-Cal ACute
select mbrs.plan_type ACUTE_PLAN_TYPE,
       mbrs.yr_mo,
       round(sum(days.admit) / mbrs.mbrs * 12000, 2) "ADM/K",
       round(sum(days.days) / mbrs.mbrs * 12000, 2) "BD/K",
       concat(round(sum(days.readmits) / sum(days.admit) * 100, 1), '%') "READMIT_RATE",
       round(sum(days.los_days) / sum(days.los_admit), 2) ALOS

  from sum_mbrs mbrs
 inner join sum_days days on mbrs.plan_type = days.plan_types
                         and mbrs.yr_mo = days.yr_mo
                         
 where mbrs.plan_type = 'Medi-Cal'
 and days.category = 'ACUTE'
   and days.ccs_in_auth = 0
 group by mbrs.plan_type, mbrs.yr_mo, mbrs.mbrs
 order by yr_mo;
 
 -- Compile Per Thousand calculations for Medi-Cal SNF
select mbrs.plan_type SNF_PLAN_TYPE,
       mbrs.yr_mo,
       round(sum(days.admit) / mbrs.mbrs * 12000, 2) "ADM/K",
       round(sum(days.days) / mbrs.mbrs * 12000, 2) "BD/K",
       concat(round(sum(days.readmits) / sum(days.admit) * 100, 1), '%') "READMIT_RATE",
       round(sum(days.los_days) / sum(days.los_admit), 2) ALOS

  from sum_mbrs mbrs
 inner join sum_days days on mbrs.plan_type = days.plan_types
                         and mbrs.yr_mo = days.yr_mo
                         
 where mbrs.plan_type = 'Medi-Cal'
   and days.category = 'SNF'
   and days.ccs_in_auth = 0
 group by mbrs.plan_type, mbrs.yr_mo, mbrs.mbrs
 order by yr_mo;
 
-- Compile Per Thousand calculations for Medicare ACute
select distinct days.plan_types ACUTE_PLAN_TYPE,
                mbrs.yr_mo,
                round(sum(days.admit) / mbrs.mbrs * 12000, 2) "ADM/K",
                round(sum(days.days) / mbrs.mbrs * 12000, 2) "BD/K",
                concat(round(sum(days.readmits) / sum(days.admit) * 100, 1),
                       '%') "READMIT_RATE",
                round(sum(days.los_days) / sum(days.los_admit), 2) ALOS

  from sum_mbrs mbrs
 inner join sum_days days on mbrs.plan_type = days.plan_types
                         and mbrs.yr_mo = days.yr_mo

 where mbrs.plan_type = 'Medicare'
   and days.category = 'ACUTE'
   and days.ccs_in_auth = 0
 group by days.plan_types, mbrs.yr_mo, mbrs.mbrs
 order by yr_mo;
 
-- Compile Per Thousand calculations for Medicare SNF
select distinct days.plan_types SNF_PLAN_TYPE,
                mbrs.yr_mo,
                round(sum(days.admit) / mbrs.mbrs * 12000, 2) "ADM/K",
                round(sum(days.days) / mbrs.mbrs * 12000, 2) "BD/K",
                concat(round(sum(days.readmits) / sum(days.admit) * 100, 1),
                       '%') "READMIT_RATE",
                round(sum(days.los_days) / sum(days.los_admit), 2) ALOS

  from sum_mbrs mbrs
 inner join sum_days days on mbrs.plan_type = days.plan_types
                         and mbrs.yr_mo = days.yr_mo

 where mbrs.plan_type = 'Medicare'
   and days.category = 'CNF'
   and days.ccs_in_auth = 0
 group by days.plan_types, mbrs.yr_mo, mbrs.mbrs
 order by yr_mo;
 
-- Compile Per Thousand calculations for CMC Acute
select distinct days.plan_types ACUTE_PLAN_TYPE,
                mbrs.yr_mo,
                round(sum(days.admit) / mbrs.mbrs * 12000, 2) "ADM/K",
                round(sum(days.days) / mbrs.mbrs * 12000, 2) "BD/K",
                concat(round(sum(days.readmits) / sum(days.admit) * 100, 1),
                       '%') "READMIT_RATE",
                round(sum(days.los_days) / sum(days.los_admit), 2) ALOS

  from sum_mbrs mbrs
 inner join sum_days days on mbrs.plan_type = days.plan_types
                         and mbrs.yr_mo = days.yr_mo

 where mbrs.plan_type = 'MMP'
   and days.category = 'ACUTE'
   and days.ccs_in_auth = 0
 group by days.plan_types, mbrs.yr_mo, mbrs.mbrs
 order by yr_mo;
 
-- Compile Per Thousand calculations for CMC SNF
select distinct days.plan_types SNF_PLAN_TYPE,
                mbrs.yr_mo,
                round(sum(days.admit) / mbrs.mbrs * 12000, 2) "ADM/K",
                round(sum(days.days) / mbrs.mbrs * 12000, 2) "BD/K",
                concat(round(sum(days.readmits) / sum(days.admit) * 100, 1),
                       '%') "READMIT_RATE",
                round(sum(days.los_days) / sum(days.los_admit), 2) ALOS

  from sum_mbrs mbrs
 inner join sum_days days on mbrs.plan_type = days.plan_types
                         and mbrs.yr_mo = days.yr_mo

 where mbrs.plan_type = 'MMP'
   and days.category = 'CNF'
   and days.ccs_in_auth = 0
 group by days.plan_types, mbrs.yr_mo, mbrs.mbrs
 order by yr_mo;
 
-- Referrals Count
select distinct OP.PLAN_TYPE,
                OP."QTR-YR",
                OP.MONTH,
                OP.ENTER_TYPE,
                OP.DECISION,
                sum(OP.PAN) PAN,
                sum(OP.PMD) PMD,
                sum(OP.POH) POH,
                sum(OP.PHH) PHH,
                sum(OP.AN) AN

  from (select case
                 when aut.lob in ('100', '700') then
                  'Medi-Cal'
                 when aut.lob in ('120', '720') then
                  'CMC'
                 else
                  'Medicare'
               end as "PLAN_TYPE",
               concat(to_char(aut.refer_dt, 'Q-'),
                      extract(year from to_date('&start_dt', 'mm/dd/yyyy'))) as "QTR-YR",
               case
                 when extract(month from aut.refer_dt) = '01' then
                  '01January'
                 when extract(month from aut.refer_dt) = '02' then
                  '02February'
                 when extract(month from aut.refer_dt) = '03' then
                  '03March'
                 when extract(month from aut.refer_dt) = '04' then
                  '04April'
                 when extract(month from aut.refer_dt) = '05' then
                  '05May'
                 when extract(month from aut.refer_dt) = '06' then
                  '06June'
                 when extract(month from aut.refer_dt) = '07' then
                  '07July'
                 when extract(month from aut.refer_dt) = '08' then
                  '08August'
                 when extract(month from aut.refer_dt) = '09' then
                  '09September'
                 when extract(month from aut.refer_dt) = '10' then
                  '10October'
                 when extract(month from aut.refer_dt) = '11' then
                  '11November'
                 when extract(month from aut.refer_dt) = '12' then
                  '12December'
               End as "MONTH",
               aut.enter_type,
               aut.letter_flag DECISION,
               count(case
                       when aut.mhc_auth_type = 'PAN' then
                        1
                       else
                        null
                     end) "PAN",
               count(case
                       when aut.mhc_auth_type = 'PMD' then
                        1
                       else
                        null
                     end) "PMD",
               count(case
                       when aut.mhc_auth_type = 'POH' then
                        1
                       else
                        null
                     end) "POH",
               count(case
                       when aut.mhc_auth_type = 'PHH' then
                        1
                       else
                        null
                     end) "PHH",
               count(case
                       when aut.mhc_auth_type = 'AN' then
                        1
                       else
                        null
                     end) "AN"
        
          from careware.authorizations aut
        
         where aut.refer_dt between to_date('&start_dt', 'mm/dd/yyyy') and
               to_date('&end_dt', 'mm/dd/yyyy')
           and aut.enter_type in ('URG', 'ROUT', 'URGC', 'RETRO')
           and aut.letter_flag <> 'V'
           and aut.in_out = 'O'
           and aut.mhc_auth_type in ('PAN', 'AN', 'OH', 'POH', 'PHH', 'PMD')
        
         group by aut.lob,
                  aut.enter_type,
                  aut.mhc_auth_type,
                  concat(to_char(aut.refer_dt, 'Q-'),
                         extract(year from to_date('&start_dt', 'mm/dd/yyyy'))),
                  extract(month from aut.refer_dt),
                  aut.letter_flag
         order by concat(to_char(aut.refer_dt, 'Q-'),
                         extract(year from to_date('&start_dt', 'mm/dd/yyyy'))),
                  extract(month from aut.refer_dt)) OP

 group by OP.PLAN_TYPE, OP."QTR-YR", OP.MONTH, OP.ENTER_TYPE, OP.DECISION

 order by OP."QTR-YR", OP.MONTH, OP.PLAN_TYPE;
 
 --drop existing legato_days_wiki table
drop table legato_days_wiki_ice;

--create legato_days_wiki table
--Add legato receive days and usps date
--turn around calculation for decision and notification
create table legato_days_wiki_ice
as (select distinct aut2.lob,
                case
                  when aut2.lob in ('100', '700') then
                   'MCAL'
                  when aut2.lob in ('120', '720') then
                   'CMC'
                  else
                   'MCARE'
                end as "TYPE",
                case
          when aut2.proc_cd1 in
               ('88321', '88323', '76140', '90605', '77370', '99241',
                '99242', '99243', '99244', '99245', '99251', '99252',
                '99253', '99254', '99255', '80500', '80502') then
           'TRUE'
          when aut2.proc_cd2 in
               ('88321', '88323', '76140', '90605', '77370', '99241',
                '99242', '99243', '99244', '99245', '99251', '99252',
                '99253', '99254', '99255', '80500', '80502') then
           'TRUE'
          when aut2.proc_cd3 in
               ('88321', '88323', '76140', '90605', '77370', '99241',
                '99242', '99243', '99244', '99245', '99251', '99252',
                '99253', '99254', '99255', '80500', '80502') then
           'TRUE'
          when aut2.proc_cd4 in
               ('88321', '88323', '76140', '90605', '77370', '99241',
                '99242', '99243', '99244', '99245', '99251', '99252',
                '99253', '99254', '99255', '80500', '80502') then
           'TRUE'
          when aut2.proc_cd5 in
               ('88321', '88323', '76140', '90605', '77370', '99241',
                '99242', '99243', '99244', '99245', '99251', '99252',
                '99253', '99254', '99255', '80500', '80502') then
           'TRUE'
          else
           'FALSE'
       end as "CONSULTATION",
--moved the PEND? and CONSULTATION flag to legato_days table 
--in order to incorporate into "DAYS_OVER" calculation 05.24.18       
       case
          when aut2.case_status like 'P%' then
           'Pended'
          else
           'Non-Pend'
       end as "PEND?",
                aut2.auth_no,
                leg.RCV_DT,
                leg.rcv_time,
                aut2.decision_dt,
                case
                   when aut2.enter_type in ('ROUT') then
                    (TRUNC(aut2.decision_dt) - TRUNC(leg.rcv_dt)) -
                    ((((TRUNC(aut2.decision_dt, 'D')) -
                    (TRUNC(leg.rcv_dt, 'D'))) / 7) * 2) - (CASE
                   WHEN TO_CHAR(leg.rcv_dt, 'DY', 'nls_date_language=english') =
                        'SUN' THEN
                    1
                   ELSE
                    0
                 END) - (CASE
                  WHEN TO_CHAR(aut2.decision_dt,
                               'DY',
                               'nls_date_language=english') = 'SAT' THEN
                   1
                  ELSE
                   0
                END) else aut2.decision_dt - leg.rcv_dt end as "TA_DAYS",
                usps.batch_no,
                case
                  when aut2.letter_flag = 'D' then
                   trunc(cits.printed_on)
                  else
                   trunc(usps.usps_dt)
                end as "USPS_DT",
                case when aut2.letter_flag='D' then case
                   when aut2.enter_type in ('ROUT', 'URG', 'URGC') then
                    (TRUNC(cits.printed_on) - TRUNC(aut2.decision_dt)) -
                    ((((TRUNC(cits.printed_on, 'D')) -
                    (TRUNC(aut2.decision_dt, 'D'))) / 7) * 2) - (CASE
                   WHEN TO_CHAR(aut2.decision_dt,
                                'DY',
                                'nls_date_language=english') = 'SUN' THEN
                    1
                   ELSE
                    0
                 END) - (CASE
                  WHEN TO_CHAR(cits.printed_on,
                               'DY',
                               'nls_date_language=english') = 'SAT' THEN
                   1
                  ELSE
                   0
                END) else trunc(cits.printed_on) - aut2.decision_dt END
                else case
                   when aut2.enter_type in ('ROUT', 'URG', 'URGC') then
                    (TRUNC(usps.usps_dt) - TRUNC(aut2.decision_dt)) -
                    ((((TRUNC(usps.usps_dt, 'D')) -
                    (TRUNC(aut2.decision_dt, 'D'))) / 7) * 2) - (CASE
                   WHEN TO_CHAR(aut2.decision_dt,
                                'DY',
                                'nls_date_language=english') = 'SUN' THEN
                    1
                   ELSE
                    0
                 END) - (CASE
                  WHEN TO_CHAR(usps.usps_dt,
                               'DY',
                               'nls_date_language=english') = 'SAT' THEN
                   1
                  ELSE
                   0
                END) else trunc(usps.usps_dt) - aut2.decision_dt END
                end as "LTTR_DAYS"

  from careware.authorizations aut2
  left join careweb.ltr_print_letter CITS on aut2.auth_no = cits.data_key2
  left join (SELECT a.auth_no, B.batch_no, B.print_dt, B.usps_dt
               FROM CAREWARE.AUTHORIZATIONS A, VU_CA_PA_MAIL_LOG@LEGATO B
              WHERE B.AUTH_NO = replace(A.auth_no, '*')
                and b.usps_dt between sysdate - 500 and sysdate) usps on aut2.auth_no =
                                                                         usps.auth_no
  left join (select distinct auth.auth_no,
                             auth.enter_type,
                             case
                               when legato.rec_dt is null then
                                auth.refer_dt
                               else
                                to_date(substr(legato.rec_dt, 0, 10),
                                        'yyyy/mm/dd')
                             end as "RCV_DT",
                             substr(legato.rec_dt, -8, 8) RCV_TIME
             
               from careware.authorizations auth
               left join (select b."field5" as AUTH_NO,
                                min(a."field2") as REC_DT
                           from sysop.ae_dt10@legato a,
                                sysop.ae_rf10@legato b
                          where a."field14" = b."field14"
                            and b."field5" is not null
                            and b."field5" not like '%,%'
                            and b."field5" like '%*%'
                            and a."field2" >
                                to_date('12/1/2017', 'mm/dd/yyyy')
                          group by b."field5") legato on auth.auth_no =
                                                         legato.auth_no) leg on aut2.auth_no =
                                                                                leg.auth_no

 where aut2.refer_dt between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')
   and aut2.mhc_auth_type in ('PAN', 'PMD', 'POH', 'PHH')
   and aut2.letter_flag in ('A', 'M', 'P', 'D')
   and aut2.enter_type in ('URG', 'ROUT', 'URGC', 'RETRO')
   and aut2.tos not in ('CLM', 'IPA')
   and aut2.admit_type <> 'DLOG');

--drop legato comp table   
drop table legato_comp_ice;

--add compliance indicator 'Y' or 'N' to decision and notification TAT
create table legato_comp_ice 
as (select distinct tad.auth_no,
                tad.ta_days,
                 case
                when aut.enter_type = 'RETRO' and aut.reason_cd='EHH' then 
                   'Y'
                  when aut.enter_type IN ('URG', 'ROUT') and
                       tad.type in ('MCAL', 'CMC') and
                       (aut.case_status LIKE 'P__%' and aut.case_status LIKE 'P___%') and
                       aut.decision_dt >= tad.rcv_dt and tad.ta_days < 14 then
                   'Y' 
                  when aut.enter_type IN ('URG', 'ROUT') and
                       tad.type in ('MCAL', 'CMC') and
                       aut.reason_cd = 'EDME' and
                       aut.decision_dt >= tad.rcv_dt and tad.ta_days < 14 then
                   'Y'  
                  when aut.enter_type IN ('URG', 'ROUT') and
                       tad.type in ('MCAL', 'CMC') and
                       tad.CONSULTATION = 'TRUE' and
                       aut.decision_dt >= tad.rcv_dt and tad.ta_days < 14 then
                   'Y' 
                  when aut.enter_type = 'ROUT' and
                       tad.type in ('MCAL', 'CMC') and
                       aut.decision_dt >= tad.rcv_dt and tad.ta_days < 6 then
                   'Y'
                  when aut.enter_type = 'URG' and
                       tad.type in ('MCAL', 'CMC') and
                       aut.decision_dt >= tad.rcv_dt and tad.ta_days < 4 then
                   'Y'
                  when aut.enter_type = 'ROUT' and
                       tad.type in ('MCAL', 'CMC') and
                       aut.decision_dt >= tad.rcv_dt and tad.ta_days > 5 then
                   'N'
                  when aut.enter_type = 'URG' and
                       tad.type in ('MCAL', 'CMC') and
                       aut.decision_dt >= tad.rcv_dt and tad.ta_days > 3 then
                   'N'
                  when aut.enter_type = 'URGC' and
                       tad.type in ('MCAL', 'CMC') and
                       aut.decision_dt >= tad.rcv_dt and tad.ta_days < 2 then
                   'Y'
                  when aut.enter_type = 'URGC' and
                       tad.type in ('MCAL', 'CMC') and
                       aut.decision_dt >= tad.rcv_dt and tad.ta_days > 1 then
                   'N'
                  when aut.enter_type = 'ROUT' and
                       tad.type not in ('MCAL', 'CMC') and
                       aut.decision_dt >= tad.rcv_dt and tad.ta_days <= 14 then
                   'Y'
                   when aut.enter_type = 'ROUT' and
                       tad.type not in ('MCAL', 'CMC') and
                       aut.decision_dt >= tad.rcv_dt and tad.ta_days > 14 then
                   'N'
                  when aut.enter_type = 'URG' and
                       tad.type not in ('MCAL', 'CMC') and
                       aut.decision_dt >= tad.rcv_dt and tad.ta_days <= 3 then
                   'Y'
                   when aut.enter_type = 'URG' and
                       tad.type not in ('MCAL', 'CMC') and
                       aut.decision_dt >= tad.rcv_dt and tad.ta_days > 3 then
                   'N'
                   when aut.enter_type = 'RETRO' and
                       aut.decision_dt >= tad.rcv_dt and tad.ta_days <= 30 then
                   'Y'
                   when aut.enter_type = 'RETRO' and
                       aut.decision_dt >= tad.rcv_dt and tad.ta_days > 30 then
                   'N' 
                  else
                   '-'
                end as "TA_COMP",
                tad.lttr_days,
                case
                  when aut.mhc_auth_type = 'POH' or
                       aut.prov_id in ('09CST', '09LTC') then
                   'Y'
                  when tad.lttr_days < 0 then
                   '-'
                  when tad.lttr_days > 2 then
                   'N'
                  when tad.usps_dt is null and aut.mhc_auth_type <> 'POH' or
                       tad.usps_dt is null and
                       aut.prov_id not in ('09CST', '09LTS') then
                   ''
                  else
                   'Y'
                end as "LTTR_COMP"

  from legato_days_wiki_ice tad
  left join careware.authorizations aut on tad.auth_no = aut.auth_no);

 --Refresh TAT Table
drop table TAT;
 create table TAT as  
  (select distinct aut.lob,
  case when aut.lob in ('100','700') then 'Medi-Cal'
  when aut.lob in ('120','720') then 'CMC'
  else 'Medicare'
  end as "LOB_TYPE",
  mbr.mem_no,
  mbr.sex,
  trunc(months_between(aut.refer_dt,mbr.birth_dt)/12) AGE,
                aut.auth_no,
                1 CNT,
                tad."PEND?",
                aut.mhc_auth_type AUTH_TYPE,
                aut.enter_type,
                grp.grp2 PLAN_TYPE,
                aut.diag_cd,
                aut.proc_cd1 PROC_CD,
                case
                  when ccs.mem_no is not NULL then
                   'TRUE'
                  else
                   'FALSE'
                End as "CCS",
                aut.tos,
                case
                  when aut.proc_cd1 in
                       ('88321', '88323', '76140', '90605', '77370', '99241',
                        '99242', '99243', '99244', '99245', '99251', '99252',
                        '99253', '99254', '99255', '80500', '80502') then
                   'TRUE'
                  when aut.proc_cd2 in
                       ('88321', '88323', '76140', '90605', '77370', '99241',
                        '99242', '99243', '99244', '99245', '99251', '99252',
                        '99253', '99254', '99255', '80500', '80502') then
                   'TRUE'
                  when aut.proc_cd3 in
                       ('88321', '88323', '76140', '90605', '77370', '99241',
                        '99242', '99243', '99244', '99245', '99251', '99252',
                        '99253', '99254', '99255', '80500', '80502') then
                   'TRUE'
                  when aut.proc_cd4 in
                       ('88321', '88323', '76140', '90605', '77370', '99241',
                        '99242', '99243', '99244', '99245', '99251', '99252',
                        '99253', '99254', '99255', '80500', '80502') then
                   'TRUE'
                  when aut.proc_cd5 in
                       ('88321', '88323', '76140', '90605', '77370', '99241',
                        '99242', '99243', '99244', '99245', '99251', '99252',
                        '99253', '99254', '99255', '80500', '80502') then
                   'TRUE'
                  else
                   'FALSE'
                end as "CONSULTATION",
                case
                  when aut.refer_to in
                       ('67906', '68676', '72982', '78467', '80069', '80074',
                        '80076', '80106', '82104', '82182', '82183', '82717',
                        '82916', '82953', '82955', '82956', '83174') and
                       aut.proc_cd1 in
                       ('99420', 'T1019', 'T1028', 'T2022', 'T2023', 'Z6900',
                        'Z6902', 'Z6904', 'Z6906', 'Z6908', 'Z6910', 'Z6914',
                        'Z8550', 'Z8560', 'Z8562', 'Z8568', 'Z8575', 'Z8576',
                        'Z8581', 'Z8588', 'Z8589') then
                   'CPO'
                  else
                   'Non-CPO'
                end as "CPO",
                aut.prov_id,
                aut.refer_to,
                concat(concat(spec.spec_cd, ' - '), spec.description) RFR_TO_SPEC,
                case
                  when spec.spec_cd in
                       ('09', '15', '16', '26', '36', '61', '71', '73', '77', '86', '90',
                        '112', '121', '126', '127', '129', '132', '146',
                        '151', '161', '162', '163', '173', '178', '180',
                        'HIV', 'MHT', '171') then
                   'Sensitive'
                  else
                   'Non-Sensitive'
                end as "SENSITIVE_SERV",
                aut.refer_by,
                tad.rcv_dt,
                tad.rcv_time,
                aut.decision_dt,
                tad.batch_no,
                trunc(tad.usps_dt) USPS_DT,
                tac.ta_days,
                tac.ta_comp,
                case when tac.ta_comp='Y' then 1
                else 0
                end as "Y_CNT",
                tac.lttr_days,
                tac.lttr_comp,
                aut.case_status,
                aut.letter_flag DECISION,
                case
                  when aut.reason_cd is null then
                   aut.reason_cd2
                  when aut.reason_cd is null and aut.reason_cd2 is null then
                   aut.reason_cd3
                  when aut.reason_cd is null and aut.reason_cd2 is null and
                       aut.reason_cd3 is null then
                   aut.reason_cd4
                  when aut.reason_cd is null and aut.reason_cd2 is null and
                       aut.reason_cd3 is null and aut.reason_cd4 is null then
                   aut.reason_cd5
                  else
                   aut.reason_cd
                end as "REASON_CD",
                case
                  when aut.reason_cd is null then
                   rc2.description
                  when aut.reason_cd is null and aut.reason_cd2 is null then
                   rc3.description
                  when aut.reason_cd is null and aut.reason_cd2 is null and
                       aut.reason_cd3 is null then
                   rc4.description
                  when aut.reason_cd is null and aut.reason_cd2 is null and
                       aut.reason_cd3 is null and aut.reason_cd4 is null then
                   rc5.description
                  else
                   rc.description
                end as "DESCRIPTION",
                to_char(tad.rcv_dt, 'yyyy-mm') Month

  from careware.authorizations aut
  left join careware.members mbr on aut.mem_no=mbr.mem_no
  left join mbrs_grp grp on aut.aid_cd = grp.group_no
  left join (select mem_no,
                    reason_cd,
                    reason_cd2,
                    reason_cd3,
                    reason_cd4,
                    reason_cd5
               from careware.authorizations
              where reason_cd in ('EE', 'MM', 'LL', 'LLL', 'FF')
                 or reason_cd2 in ('EE', 'MM', 'LL', 'LLL', 'FF')
                 or reason_cd3 in ('EE', 'MM', 'LL', 'LLL', 'FF')
                 or reason_cd4 in ('EE', 'MM', 'LL', 'LLL', 'FF')
                 or reason_cd5 in ('EE', 'MM', 'LL', 'LLL', 'FF')) ccs on aut.mem_no =
                                                                          ccs.mem_no
  left join careware.providers prov on aut.refer_to = prov.prov_id
  left join careware.specialty_codes spec on prov.spec_cd1 = spec.spec_cd
  left join careware.auth_reason_codes rc on aut.reason_cd = rc.reason_cd
  left join careware.auth_reason_codes rc2 on aut.reason_cd2 =
                                              rc2.reason_cd
  left join careware.auth_reason_codes rc3 on aut.reason_cd3 =
                                              rc3.reason_cd
  left join careware.auth_reason_codes rc4 on aut.reason_cd4 =
                                              rc4.reason_cd
  left join careware.auth_reason_codes rc5 on aut.reason_cd5 =
                                              rc5.reason_cd
  left join legato_days_wiki_ice tad on aut.auth_no = tad.auth_no
  left join legato_comp_ice tac on aut.auth_no=tac.auth_no

 where aut.lob = '100'
   and aut.region in ('10', '11', '310')
   and tad.rcv_dt between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')
   and aut.mhc_auth_type in ('PAN', 'PMD', 'POH','PHH')
   and aut.letter_flag in ('A', 'M', 'P','D')
   and aut.enter_type in ('URG', 'ROUT', 'URGC','RETRO')
   and aut.tos not in ('CLM','IPA')
   and aut.admit_type <>'DLOG'
    OR aut.lob = '700'
   and aut.region <> '7740'
   and tad.rcv_dt between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')
   and aut.mhc_auth_type in ('PAN', 'PMD', 'POH','PHH')
   and aut.letter_flag in ('A', 'M', 'P','D')
   and aut.enter_type in ('URG', 'ROUT', 'URGC','RETRO')
   and aut.tos not in ('CLM','IPA')
   and aut.admit_type <>'DLOG'
    OR aut.lob not in ('100', '700', '120', '720')
   and aut.region in
       ('110', '140', '2290', '2290', '230', '2300', '2310', '2321', '2520',
        '2525', '2525', '270', '280', '290', '310', '3122', '3130', '3140',
        '3150', '3201', '3202', '3203', '3204', '3205', '3206', '3207',
        '3208', '3209', '3210', '3211', '3600', '3710', '3711', '3730',
        '3731', '3755', '3790', '3800', '3801', '3802', '3803', '511', '540',
        '541', '590', '591', '7100', '7101', '730', '740', '770', '7710',
        '7711', '7712', '7722', '7725', '7740', '7742', '775', '7770',
        '7780', '7790', '7805', '7810', '7820', '7825', '7840', '7855',
        '7880', '7890', '80', '8000', '85', '850', '851', '852', '853')
   and tad.rcv_dt between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')
   and aut.mhc_auth_type in ('PAN', 'PMD', 'POH','PHH')
   and aut.letter_flag in ('A', 'M', 'P','D')
   and aut.enter_type in ('URG', 'ROUT', 'URGC','RETRO')
   and aut.tos not in ('CLM','IPA')
   and aut.admit_type <>'DLOG'
    OR aut.lob = '120'
   and aut.region in ('10', '130', '270', '280', '290', '310', '3620')
   and tad.rcv_dt between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')
   and aut.mhc_auth_type in ('PAN', 'PMD', 'POH','PHH')
   and aut.letter_flag in ('A', 'M', 'P','D')
   and aut.enter_type in ('URG', 'ROUT', 'URGC','RETRO')
   and aut.tos not in ('CLM','IPA')
   and aut.admit_type <>'DLOG'
    OR aut.lob = '720'
   and aut.region in
       ('10', '7742', '7770', '7805', '7810', '7825', '7855', '7900', '7930')
   and tad.rcv_dt between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')
   and aut.mhc_auth_type in ('PAN', 'PMD', 'POH','PHH')
   and aut.letter_flag in ('A', 'M', 'P','D')
   and aut.enter_type in ('URG', 'ROUT', 'URGC','RETRO')
   and aut.tos not in ('CLM','IPA')
   and aut.admit_type <>'DLOG');

--Create pivot for TAT  
select *
  from (select t.month, t.lob_type, t.enter_type, t.ta_comp
          from tat t
         where t.ccs = 'FALSE'
           and t.sensitive_serv = 'Non-Sensitive')
       
       pivot(count(ta_comp) for ta_comp in ('Y', 'N', '-'));
       
-- CITS Monthly Denial
select denial.description as "NON-CCS_DENIAL_REASON",
count(denial.auth_no) COUNT from 
(select distinct aut.lob,
                aut.mem_no,
                aut.auth_no,
                aut.refer_dt,
                aut.admit_type,
                aut.review_type,
                aut.letter_flag,
                ap.decision_reason,
                rc.description,
                aut.case_status,
                ap.pr_decision_dt,
                cits.printed_on,
                to_char(cits.printed_on, 'yyyy-mm') YR_MO,
                case
                   when aut.enter_type in ('ROUT', 'URG', 'URGC') then
                    (TRUNC(cits.printed_on) - TRUNC(ap.pr_decision_dt)) -
                    ((((TRUNC(cits.printed_on, 'D')) -
                    (TRUNC(ap.pr_decision_dt, 'D'))) / 7) * 2) - (CASE
                   WHEN TO_CHAR(ap.pr_decision_dt,
                                'DY',
                                'nls_date_language=english') = 'SUN' THEN
                    1
                   ELSE
                    0
                 END) - (CASE
                  WHEN TO_CHAR(cits.printed_on,
                               'DY',
                               'nls_date_language=english') = 'SAT' THEN
                   1
                  ELSE
                   0
                END) else trunc(cits.printed_on) - ap.pr_decision_dt end as "LTTR_DAYS",
                cits.created_by,
                cits.printed_by

  from careware.auth_procedures ap
  left join careware.authorizations aut on ap.auth_no = aut.auth_no
  left join careware.auth_reason_codes rc on ap.decision_reason =
                                             rc.reason_cd
  left join careweb.ltr_print_letter cits on aut.auth_no = cits.data_key2
 
 where cits.printed_on between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')
   and aut.letter_flag in ('M', 'D')
   and aut.case_status in ('C', 'D')
   and aut.mhc_auth_type <> 'POH'
   and cits.data_key3 = 'Member'
   and ap.decision_reason not in ('EE', 'MM', 'LL', 'LLL', 'FF')) denial
   
   group by denial.description
   order by count(denial.auth_no) desc;
 