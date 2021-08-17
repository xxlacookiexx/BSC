select distinct auth.lob,
                auth.region,
                auth.auth_no,
                auth.mem_no,
                concat(concat(members.fname, ' '), members.lname) MBR_NAME,
                members.birth_dt,
                trunc(months_between(auth.admit_dt, members.birth_dt) / 12) AGE,
                auth.refer_to Facility,
                CONCAT(PROV.LNAME, CONCAT(' ', PROV.FNAME)) FACILITY_NAME,
                PROV.NPI,
                case
                  when reason_cd in ('EE', 'MM', 'LL', 'LLL', 'FF') then
                   'TRUE'
                  when reason_cd2 in ('EE', 'MM', 'LL', 'LLL', 'FF') then
                   'TRUE'
                  when reason_cd3 in ('EE', 'MM', 'LL', 'LLL', 'FF') then
                   'TRUE'
                  when reason_cd4 in ('EE', 'MM', 'LL', 'LLL', 'FF') then
                   'TRUE'
                  when reason_cd5 in ('EE', 'MM', 'LL', 'LLL', 'FF') then
                   'TRUE'
                  else
                   'FALSE'
                End as "CCS_STATUS",
                auth.aid_cd,
                GRP.GRP2 PLAN_TYPE,
                auth.a_type,
                auth.admit_type,
                auth.bed_type,
                auth.admit_dt,
                auth.disch_dt,
                
                case
                  when auth.admit_dt between
                       to_date('&start_dt', 'mm/dd/yyyy') and
                       to_date('&end_dt', 'mm/dd/yyyy') then
                   1
                  else
                   0
                End as "ADMIT",
                
                case
                  when auth.disch_dt is null and
                       auth.admit_dt < to_date('&start_dt', 'mm/dd/yyyy') then
                   add_months(trunc(to_date('&start_dt', 'mm/dd/yyyy'), 'MM'),
                              1) -
                   trunc(to_date('&start_dt', 'mm/dd/yyyy'), 'MM')
                
                  when auth.disch_dt is null and
                       auth.admit_dt between
                       to_date('&start_dt', 'mm/dd/yyyy') and
                       to_date('&end_dt', 'mm/dd/yyyy') then
                   to_date('&end_dt', 'mm/dd/yyyy') - auth.admit_dt
                
                  when auth.disch_dt between
                       to_date('&start_dt', 'mm/dd/yyyy') and
                       to_date('&end_dt', 'mm/dd/yyyy') and
                       auth.admit_dt < to_date('&start_dt', 'mm/dd/yyyy') then
                   auth.disch_dt - to_date('&start_dt', 'mm/dd/yyyy')
                
                  when auth.disch_dt > to_date('&end_dt', 'mm/dd/yyyy') and
                       auth.admit_dt between
                       to_date('&start_dt', 'mm/dd/yyyy') and
                       to_date('&end_dt', 'mm/dd/yyyy') then
                   to_date('&end_dt', 'mm/dd/yyyy') - auth.admit_dt
                
                  else
                   auth.disch_dt - auth.admit_dt
                End as "DAYS",
                
                case
                  when auth.disch_dt is null then
                   0
                  when auth.disch_dt > to_date('&end_dt', 'mm/dd/yyyy') then
                   0
                  else
                   1
                End as "LOS_ADMITS",
                
                case
                  when auth.admit_dt between
                       to_date('&start_dt', 'mm/dd/yyyy') and
                       to_date('&end_dt', 'mm/dd/yyyy') and
                       auth.disch_dt is null then
                   0
                
                  when auth.admit_dt between
                       to_date('&start_dt', 'mm/dd/yyyy') and
                       to_date('&end_dt', 'mm/dd/yyyy') and
                       auth.disch_dt between
                       to_date('1/1/2015', 'mm/dd/yyyy') and
                       to_date('&end_dt', 'mm/dd/yyyy') then
                   auth.disch_dt - auth.admit_dt
                
                  when auth.admit_dt < to_date('&start_dt', 'mm/dd/yyyy') and
                       auth.disch_dt is null then
                   0
                
                  when auth.disch_dt > to_date('&end_dt', 'mm/dd/yyyy') then
                   0
                
                  else
                   auth.disch_dt - auth.admit_dt
                End as "LOS_DAYS",
                
                auth.case_status,
                auth.letter_flag,
                cl.diag_cd,
                cl.drg

  from careware.authorizations auth

  LEFT JOIN CAREWARE.PROVIDERS PROV ON AUTH.REFER_TO = PROV.PROV_ID
  LEFT JOIN MBRS_GRP GRP ON AUTH.AID_CD = GRP.GROUP_NO
  LEFT JOIN CAREWARE.MEMBERS MEMBERS ON AUTH.MEM_NO = MEMBERS.MEM_NO
  left join careware.claims cl on auth.auth_no =
                                  concat(concat(cl.auth_no, '*'), cl.type)

 where case_status not in ('V', 'D')
   and auth.region not in ('12')
   and admit_type not in ('DLOG')
   and auth.lob = '100'
   and auth.in_out = 'I'
   and auth.refer_to in ('6229', '16454', '65782', '3046', '3209', '3223',
        '4747', '5541', '5038', '6959', '6070')
   and ((auth.admit_dt between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')) or
       (auth.disch_dt is null and
       auth.admit_dt < to_date('&end_dt', 'mm/dd/yyyy')) or
       (auth.disch_dt between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')));