--drop existing legato_days_wiki table
drop table legato_days_wiki4;

--create legato_days_wiki table
--Add legato receive days and usps date
--turn around calculation for decision and notification
create table legato_days_wiki4
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
                trunc(sysdate) TODAY_DATE,
                case
                   when aut2.enter_type in ('ROUT') then
                    (TRUNC(sysdate) - TRUNC(leg.rcv_dt)) -
                    ((((TRUNC(sysdate, 'D')) - (TRUNC(leg.rcv_dt, 'D'))) / 7) * 2) - (CASE
                   WHEN TO_CHAR(leg.rcv_dt, 'DY', 'nls_date_language=english') =
                        'SUN' THEN
                    1
                   ELSE
                    0
                 END) - (CASE
                  WHEN TO_CHAR(sysdate,
                               'DY',
                               'nls_date_language=english') = 'SAT' THEN
                   1
                  ELSE
                   0
                END) else trunc(sysdate) - leg.rcv_dt end as "TA_DAYS"

  from careware.authorizations aut2
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
drop table legato_comp4;

--add compliance indicator 'Y' or 'N' to decision and notification TAT
create table legato_comp4
as (select distinct tad.auth_no,
                tad.ta_days,
                case
                 when aut.enter_type = 'RETRO' and aut.reason_cd='EHH' then 
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
                end as "TA_COMP"

  from legato_days_wiki4 tad
  left join careware.authorizations aut on tad.auth_no = aut.auth_no);

 --compile TAT report  
  select distinct aut.lob,
                case
                  when aut.lob in ('100') then
                   'MediCal LA'
                  when aut.lob in ('700') then
                   'MediCal SD'
                  when aut.lob in ('120') then
                   'CMC LA'
                  when aut.lob in ('720') then
                   'CMC SD'
                  else
                   'Medicare'
                end as "LOB_TYPE",
                case
                  when aut.mhc_auth_type = 'PHH' and
                       spec.spec_cd in ('166', '125', '72') then
                   'Home Health'
                  when aut.tos in ('PDME', 'RDME') then
                   'DME'
                  when aut.mhc_auth_type = 'CBA' then
                   'CBAS'
                  when aut.prov_id in ('09CST','09LTC') or aut.aid_cd in
                       ('13D', '002L2LA*63', '13D', '002L3LA*13', '53*700',
                        '13*700', '63*700', '63D', '002L2LA*13', '002L3LA*63',
                        '001L3SD*63', '001L3SD*13', '002L3LA*13',
                        '001L3SD*63', '002L3LA*63', '001L2SD*13', '63',
                        '13*700', '002L2LA*13', '13D*700', '13', '63D', '63', '23', '13',
                        '63D*700', '002L3LA*23', '001L3SD*13', '13D*700',
                        '63*700') then
                   'LTC'
                  else
                   'Pre-Service'
                end as "CATEGORY",
                mbr.mem_no,
                aut.aid_cd,
                mbr.sex,
                trunc(months_between(aut.refer_dt, mbr.birth_dt) / 12) AGE,
                aut.auth_no,
                case
                  when aut.tos in ('PDME', 'RDME') or aut.letter_flag = 'P' or
                       aut.proc_cd1 in
                       ('88321', '88323', '76140', '90605', '77370', '99241',
                        '99242', '99243', '99244', '99245', '99251', '99252',
                        '99253', '99254', '99255', '80500', '80502') or
                       aut.proc_cd2 in
                       ('88321', '88323', '76140', '90605', '77370', '99241',
                        '99242', '99243', '99244', '99245', '99251', '99252',
                        '99253', '99254', '99255', '80500', '80502') or
                       aut.proc_cd3 in
                       ('88321', '88323', '76140', '90605', '77370', '99241',
                        '99242', '99243', '99244', '99245', '99251', '99252',
                        '99253', '99254', '99255', '80500', '80502') or
                       aut.proc_cd4 in
                       ('88321', '88323', '76140', '90605', '77370', '99241',
                        '99242', '99243', '99244', '99245', '99251', '99252',
                        '99253', '99254', '99255', '80500', '80502') or
                       aut.proc_cd5 in
                       ('88321', '88323', '76140', '90605', '77370', '99241',
                        '99242', '99243', '99244', '99245', '99251', '99252',
                        '99253', '99254', '99255', '80500', '80502') then
                   'Pended'
                  else
                   'Non-Pend'
                end as "PEND?",
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
                concat(concat(aut.tos, ' - '), tos.description) TOS,
                concat(concat(aut.pos, ' - '), pos.description) POS,
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
                trunc(sysdate) TODAY_DT,
                tac.ta_days,
                tac.ta_comp,
                aut.case_status,
                aut.letter_flag DECISION,
                case
                  when aut.letter_flag = 'P' and aut.case_status = 'C' then
                   'Y'
                  when aut.letter_flag = 'P' and aut.case_status = 'D' then
                   'Y'
                  else
                   'N'
                end as "ERROR? (Y/N)",
                aut.reason_cd,
                to_char(tad.rcv_dt, 'yyyy-mm') Month

  from careware.authorizations aut
  left join apptest.lookup_pos pos on aut.pos = pos.pos
  left join careware.auth_service_types tos on aut.tos = tos.service_type
  left join careware.members mbr on aut.mem_no = mbr.mem_no
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
  left join legato_days_wiki4 tad on aut.auth_no = tad.auth_no
  left join legato_comp4 tac on aut.auth_no = tac.auth_no

 where aut.lob = '100'
   and aut.region in ('10', '11', '310')
   and tad.rcv_dt between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')
   and aut.mhc_auth_type in ('PAN', 'PMD', 'POH', 'PHH', 'CBA')
   and aut.letter_flag in ('P')
   and aut.enter_type in ('URG', 'ROUT', 'URGC', 'RETRO', 'CBAS')
   and aut.tos not in ('CLM', 'IPA')
   and aut.admit_type <> 'DLOG'
   and aut.case_status <> 'V'
    OR aut.lob = '700'
   and aut.region <> '7740'
   and tad.rcv_dt between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')
   and aut.mhc_auth_type in ('PAN', 'PMD', 'POH', 'PHH', 'CBA')
   and aut.letter_flag in ('P')
   and aut.enter_type in ('URG', 'ROUT', 'URGC', 'RETRO', 'CBAS')
   and aut.tos not in ('CLM', 'IPA')
   and aut.admit_type <> 'DLOG'
   and aut.case_status <> 'V'
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
   and aut.mhc_auth_type in ('PAN', 'PMD', 'POH', 'PHH', 'CBA')
   and aut.letter_flag in ('P')
   and aut.enter_type in ('URG', 'ROUT', 'URGC', 'RETRO', 'CBAS')
   and aut.tos not in ('CLM', 'IPA')
   and aut.admit_type <> 'DLOG'
   and aut.case_status <> 'V'
    OR aut.lob = '120'
   and aut.region in ('10', '130', '270', '280', '290', '310', '3620')
   and tad.rcv_dt between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')
   and aut.mhc_auth_type in ('PAN', 'PMD', 'POH', 'PHH', 'CBA')
   and aut.letter_flag in ('P')
   and aut.enter_type in ('URG', 'ROUT', 'URGC', 'RETRO', 'CBAS')
   and aut.tos not in ('CLM', 'IPA')
   and aut.admit_type <> 'DLOG'
   and aut.case_status <> 'V'
    OR aut.lob = '720'
   and aut.region in
       ('10', '7742', '7770', '7805', '7810', '7825', '7855', '7900', '7930')
   and tad.rcv_dt between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')
   and aut.mhc_auth_type in ('PAN', 'PMD', 'POH', 'PHH', 'CBA')
   and aut.letter_flag in ('P')
   and aut.enter_type in ('URG', 'ROUT', 'URGC', 'RETRO', 'CBAS')
   and aut.tos not in ('CLM', 'IPA')
   and aut.admit_type <> 'DLOG'
   and aut.case_status <> 'V'
   
   order by tad.rcv_dt