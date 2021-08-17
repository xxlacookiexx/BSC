--drop existing legato_days_wiki table
drop table legato_days_wiki3;

--create legato_days_wiki table
--Add legato receive days and usps date
--turn around calculation for decision and notification
create table legato_days_wiki3
as (select distinct aut2.lob,
       case
         when aut2.lob in ('100', '700') then
          'MCAL'
         when aut2.lob in ('120', '720') then
          'CMC'
         else
          'MCARE'
       end as "TYPE",
       aut2.auth_no,
       leg.RCV_DT,
       leg.rcv_time,
       aut2.decision_dt,
       case
          when aut2.enter_type in ('ROUT') then
           (TRUNC(aut2.decision_dt) - TRUNC(leg.rcv_dt)) -
           ((((TRUNC(aut2.decision_dt, 'D')) - (TRUNC(leg.rcv_dt, 'D'))) / 7) * 2) - (CASE
          WHEN TO_CHAR(leg.rcv_dt, 'DY', 'nls_date_language=english') = 'SUN' THEN
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
       trunc(usps.usps_dt) USPS_DT,
       case
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
                END) else trunc(usps.usps_dt) - aut2.decision_dt end as "LTTR_DAYS"

  from careware.authorizations aut2
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
                   to_date(substr(legato.rec_dt, 0, 10), 'yyyy/mm/dd')
                end as "RCV_DT",
                substr(legato.rec_dt, -8, 8) RCV_TIME

  from careware.authorizations auth
  left join (select b."field5" as AUTH_NO, min(a."field2") as REC_DT
               from sysop.ae_dt10@legato a, sysop.ae_rf10@legato b
              where a."field14" = b."field14"
                and b."field5" is not null
                and b."field5" not like '%,%'
                and b."field5" like '%*%'
                and a."field2" > to_date('12/1/2017', 'mm/dd/yyyy')
              group by b."field5") legato on auth.auth_no = legato.auth_no) leg on aut2.auth_no =leg.auth_no

 where aut2.refer_dt between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')
   and aut2.mhc_auth_type in ('PAN', 'PMD', 'POH','PHH')
   and aut2.letter_flag in ('A', 'M', 'P','D')
   and aut2.enter_type in ('URG', 'ROUT', 'URGC')
   and aut2.tos not in ('CLM','IPA')
   and aut2.admit_type <>'DLOG');

--drop legato comp table   
drop table legato_comp3;

--add compliance indicator 'Y' or 'N' to decision and notification TAT
create table legato_comp3 
as (select distinct tad.auth_no,
                tad.ta_days,
                case
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

  from legato_days_wiki3 tad
  left join careware.authorizations aut on tad.auth_no = aut.auth_no);

 --compile TAT report  
 select distinct aut.lob,
                 mbr.mem_no,
                 aut.auth_no,
                 concat(concat(aut.mhc_auth_type,' - '),clt.cl_type_desc) AUTH_TYPE,
                 tad.rcv_dt,
                 tad.rcv_time,
                 aut.decision_dt,
                 tad.batch_no,
                 trunc(tad.usps_dt) USPS_DT,
                 tac.ta_days,
                 tac.ta_comp,
                 tac.lttr_days,
                 tac.lttr_comp,
                 case
                   when aut.letter_flag = 'A' then
                    'Approved'
                   when aut.letter_flag = 'D' then
                    'Denied'
                   when aut.letter_flag = 'P' then
                    'Pending'
                   when aut.letter_flag = 'M' then
                    'Partial Modification'
                   else
                    ''
                 end as "DECISION",
                 case
                   when aut.case_status = 'C' then
                    'Closed'
                   when aut.case_status = 'D' then
                    'Denied'
                   when aut.case_status = 'P' then
                    'Pending'
                   when aut.case_status = 'O' then
                    'Open'
                   when aut.case_status = 'V' then
                    'Void'
                   when aut.case_status = 'PLOA' then
                    'Pending LOA'
                   when aut.case_status = 'PIPA' then
                    'Pending IPA'
                   else
                    ''
                 end as "CASE_STATUS",
                 to_char(tad.rcv_dt, 'yyyy-mm') Month
 
   from careware.authorizations aut
   left join careware.members mbr on aut.mem_no = mbr.mem_no
   left join careware.cl_types clt on aut.mhc_auth_type=clt.cl_type
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
   left join legato_days_wiki3 tad on aut.auth_no = tad.auth_no
   left join legato_comp3 tac on aut.auth_no = tac.auth_no
 
  where aut.lob = '100'
    and aut.region in ('10', '11', '310')
    and tad.rcv_dt between to_date('&start_dt', 'mm/dd/yyyy') and
        to_date('&end_dt', 'mm/dd/yyyy')
    and aut.mhc_auth_type in ('PAN', 'PMD', 'POH', 'PHH')
    and aut.letter_flag in ('A', 'M', 'P', 'D')
    and aut.enter_type in ('URG', 'ROUT', 'URGC')
    and aut.tos not in ('CLM', 'IPA')
    and aut.admit_type <> 'DLOG'
     OR aut.lob = '700'
    and aut.region <> '7740'
    and tad.rcv_dt between to_date('&start_dt', 'mm/dd/yyyy') and
        to_date('&end_dt', 'mm/dd/yyyy')
    and aut.mhc_auth_type in ('PAN', 'PMD', 'POH', 'PHH')
    and aut.letter_flag in ('A', 'M', 'P', 'D')
    and aut.enter_type in ('URG', 'ROUT', 'URGC')
    and aut.tos not in ('CLM', 'IPA')
    and aut.admit_type <> 'DLOG'
     OR aut.lob not in ('100', '700', '120', '720')
    and aut.region in
        ('110', '140', '2290', '2290', '230', '2300', '2310', '2321', '2520',
         '2525', '2525', '270', '280', '290', '310', '3122', '3130', '3140',
         '3150', '3201', '3202', '3203', '3204', '3205', '3206', '3207',
         '3208', '3209', '3210', '3211', '3600', '3710', '3711', '3730',
         '3731', '3755', '3790', '3800', '3801', '3802', '3803', '511',
         '540', '541', '590', '591', '7100', '7101', '730', '740', '770',
         '7710', '7711', '7712', '7722', '7725', '7740', '7742', '775',
         '7770', '7780', '7790', '7805', '7810', '7820', '7825', '7840',
         '7855', '7880', '7890', '80', '8000', '85', '850', '851', '852',
         '853')
    and tad.rcv_dt between to_date('&start_dt', 'mm/dd/yyyy') and
        to_date('&end_dt', 'mm/dd/yyyy')
    and aut.mhc_auth_type in ('PAN', 'PMD', 'POH', 'PHH')
    and aut.letter_flag in ('A', 'M', 'P', 'D')
    and aut.enter_type in ('URG', 'ROUT', 'URGC')
    and aut.tos not in ('CLM', 'IPA')
    and aut.admit_type <> 'DLOG'
     OR aut.lob = '120'
    and aut.region in ('10', '130', '270', '280', '290', '310', '3620')
    and tad.rcv_dt between to_date('&start_dt', 'mm/dd/yyyy') and
        to_date('&end_dt', 'mm/dd/yyyy')
    and aut.mhc_auth_type in ('PAN', 'PMD', 'POH', 'PHH')
    and aut.letter_flag in ('A', 'M', 'P', 'D')
    and aut.enter_type in ('URG', 'ROUT', 'URGC')
    and aut.tos not in ('CLM', 'IPA')
    and aut.admit_type <> 'DLOG'
     OR aut.lob = '720'
    and aut.region in ('10', '7742', '7770', '7805', '7810', '7825', '7855',
         '7900', '7930')
    and tad.rcv_dt between to_date('&start_dt', 'mm/dd/yyyy') and
        to_date('&end_dt', 'mm/dd/yyyy')
    and aut.mhc_auth_type in ('PAN', 'PMD', 'POH', 'PHH')
    and aut.letter_flag in ('A', 'M', 'P', 'D')
    and aut.enter_type in ('URG', 'ROUT', 'URGC')
    and aut.tos not in ('CLM', 'IPA')
    and aut.admit_type <> 'DLOG'