select distinct mbr.lob,
                case
                  when mbr.lob in ('720', '700', '2700') then
                   'SD'
                  else
                   'LA'
                end as "AREA",
                ccms.member_id,
                mbr.sex gender,
                trunc(months_between(ccms.row_created, mbr.birth_dt) / 12) AGE,
                case
                  when trunc(months_between(ccms.row_created, mbr.birth_dt) / 12) < 10 then
                   '0-9'
                  when trunc(months_between(ccms.row_created, mbr.birth_dt) / 12) between 10 and 19 then
                   '10-19'
                  when trunc(months_between(ccms.row_created, mbr.birth_dt) / 12) between 20 and 44 then
                   '20-40'
                  when trunc(months_between(ccms.row_created, mbr.birth_dt) / 12) between 45 and 64 then
                   '45-64'
                  when trunc(months_between(ccms.row_created, mbr.birth_dt) / 12) between 65 and 74 then
                   '65-74'
                  when trunc(months_between(ccms.row_created, mbr.birth_dt) / 12) between 75 and 84 then
                   '75-84'
                  when trunc(months_between(ccms.row_created, mbr.birth_dt) / 12) > 85 then
                   '85+'
                end as "AGE_GRP",
                ccms.case_type,
                ccms.case_type_desc,
                case
                  when ccms.case_type in ('CM1070') then
                   'Asthma Adult'
                  when ccms.case_type in ('CM1080') then
                   'Asthma Peds'
                  when ccms.case_type in ('CM1110', 'CM1114') then
                   'CHF'
                  when ccms.case_type in
                       ('CM1015', 'CM1221', 'CM1130', 'CM1131', 'CM1212') then
                   'CCM'
                end as "CM_TYPE",
                ccms.row_created,
                ccms.case_close_date,
                cs.case_status_desc,
                cr.close_reason_desc

  from apptest.ccms_cases_ca ccms
  left join apptest.ccms_zl_case_status cs on ccms.case_status =
                                              cs.case_status
  left join careware.members mbr on substr(ccms.member_id, 4, 10) =
                                    mbr.mem_no
  left join ccms_close_reason cr on ccms.close_reason = cr.close_reason

 where ccms.case_type in
       ('CM1015', 'CM1221', 'CM1130', 'CM1131', 'CM1212', 'CM1070', 'CM1116',
        'CM1080', 'CM1117', 'CM1110', 'CM1114')
   and ccms.row_created between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')
    or ccms.case_type in
       ('CM1015', 'CM1221', 'CM1130', 'CM1131', 'CM1212', 'CM1070', 'CM1116',
        'CM1080', 'CM1117', 'CM1110', 'CM1114')
   and ccms.case_close_date between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')
    or ccms.case_type in
       ('CM1015', 'CM1221', 'CM1130', 'CM1131', 'CM1212', 'CM1070', 'CM1116',
        'CM1080', 'CM1117', 'CM1110', 'CM1114')
   and ccms.case_close_date is null