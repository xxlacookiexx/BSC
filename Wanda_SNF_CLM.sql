--Update SNF_CLM table
drop table SNF_CLM;
create table SNF_CLM
as(select aut.lob,
       aut.mem_no,
       aut.auth_no,
       aut.refer_to,
       prov.lname||' '||prov.fname FACILITY,
       aut.bed_type,
       aut.admit_dt,
       aut.disch_dt,
       1 ADMIT,
       aut.disch_dt - aut.admit_dt DAYS,
       aut.case_status,
       sum(cl.pay_amt) TTL_CLAIM

  from careware.authorizations aut
  left join careware.claims cl on aut.auth_no =
                                  cl.auth_no || '*' || cl.type
  left join careware.providers prov on aut.refer_to = prov.prov_id

 where aut.lob in ('100', '700')
   and aut.admit_dt between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')
   and aut.bed_type in ('SN1', 'SN2', 'SN3', 'SN4', 'SN5', 'CST', 'LTS')
   and aut.case_status <> 'V'

 group by aut.lob,
          aut.mem_no,
          aut.auth_no,
          aut.refer_to,
          prov.lname||' '||prov.fname,
          aut.bed_type,
          aut.admit_dt,
          aut.disch_dt,
          aut.disch_dt - aut.admit_dt,
          aut.case_status);
          
-- Count ALOS
select snf.lob,
       snf.mem_no,
       snf.auth_no,
       snf.refer_to,
       snf.facility,
       snf.bed_type,
       case when snf.bed_type in ('CST','LTS') then 'LTC' 
       else 'SNF'
       end as "BED_GRP",
       case
         when snf.disch_dt is null then
          null
         else
          snf.days / snf.admit
       end as "ALOS",
       case when snf.disch_dt is null then 'N'
       else 'Y'
       end as "DISCHARGE_STATUS",
       snf.ttl_claim,
         to_char(snf.admit_dt, 'yyyy') YR,
         to_char(snf.admit_dt, 'Q') QTR,
         concat(to_char(snf.admit_dt, 'yyyy'),concat('-',to_char(snf.admit_dt, 'Q'))) YR_QTR

  from snf_clm snf;
  
-- POH -> IH auth
select aut.lob,
       to_char(aut.refer_dt, 'YYYY-MM') MONTH,
       aut.mem_no,
       concat(concat(mbr.fname, ' '), mbr.lname) MBR_NAME,
       aut.region,
       UPPER(reg.description) REG_DESC,
       aut.auth_no,
       aut.refer_to,
       concat(concat(prov.lname, ' '), prov.fname) FACILITY,
       aut.diag_cd,
       diag.description DIAG_DESC,
       case
         when diag.description LIKE '%DIABETES%' THEN
          'DIABETES'
         when diag.description LIKE '%SYNCOPE%' THEN
          'SYNCOPE'
         when diag.description LIKE '%CHEST PAIN%' THEN
          'CHEST PAIN'
         when diag.description LIKE '%URINARY TRACT INFECTION%' THEN
          'URINARY TRACT INFECTION'
         ELSE
          '-'
       end as "DIAGNOSIS GROUP",
       aut.admit_dt,
       aut.case_status,
       IH.auth_no IH_AUTH,
       IH.lob,
       IH.region,
       IH.diag_cd,
       IH.DIAG_DESC,
       IH.admit_dt,
       IH.disch_dt,
       case
         when IH.admit_dt between to_date('&start_dt', 'mm/dd/yyyy') and
              to_date('&end_dt', 'mm/dd/yyyy') and IH.disch_dt is null then
          0
         when IH.admit_dt between to_date('&start_dt', 'mm/dd/yyyy') and
              to_date('&end_dt', 'mm/dd/yyyy') and
              IH.disch_dt between to_date('&start_dt', 'mm/dd/yyyy') and
              to_date('&end_dt', 'mm/dd/yyyy') then
          IH.disch_dt - IH.admit_dt
         when IH.admit_dt < to_date('&start_dt', 'mm/dd/yyyy') and
              IH.disch_dt is null then
          0
         when IH.disch_dt > to_date('&end_dt', 'mm/dd/yyyy') then
          0
         else
          IH.disch_dt - IH.admit_dt
       End as "LOS_DAYS",
       case
         when IH.disch_dt is null then
          0
         when IH.disch_dt > to_date('&end_dt', 'mm/dd/yyyy') then
          0
         else
          1
       End as "LOS_ADMITS",
       case
         when IH.DIAG_DESC LIKE '%DIABETES%' THEN
          'Y'
         when IH.DIAG_DESC LIKE '%SYNCOPE%' THEN
          'Y'
         when IH.DIAG_DESC LIKE '%CHEST PAIN%' THEN
          'Y'
         when IH.DIAG_DESC LIKE '%URINARY TRACT INFECTION%' THEN
          'Y'
         ELSE
          'N'
       end as "LIKE ADMIT DX",
       IH.Decision,
       IH.case_status

  from careware.authorizations aut
  left join careware.members mbr on aut.mem_no = mbr.mem_no
  left join careware.region_codes reg on aut.region = reg.region_cd
  left join careware.diagnosis_codes diag on aut.diag_cd = diag.diag_cd
  left join careware.providers prov on aut.refer_to = prov.prov_id
  left join dbo."Lookup Medical Groups Care1st"@caredb reg_grp on aut.region =
                                                                  reg_grp."REG"
 inner join (select distinct auth.lob,
                             auth.region,
                             auth.auth_no,
                             auth.diag_cd,
                             d.description DIAG_DESC,
                             auth.admit_dt,
                             auth.disch_dt,
                             auth.mem_no,
                             auth.case_status,
                             auth.decision_dt,
                             auth.letter_flag Decision,
                             substr(auth.auth_no, 1, 7) ID,
                             auth.mhc_auth_type
               FROM careware.authorizations auth
               LEFT JOIN careware.diagnosis_codes d ON auth.diag_cd =
                                                       d.diag_cd
              WHERE auth.admit_dt > to_date('&start_dt', 'mm/dd/yyyy')
                and auth.mhc_auth_type in ('IH')) IH ON substr(aut.auth_no,
                                                               1,
                                                               7) = IH.ID
                                                    AND aut.mem_no =
                                                        IH.mem_no

 where aut.mhc_lob not IN ('120', '720')
   and aut.admit_dt between to_date('&start_dt', 'mm/dd/yyyy') and
       to_date('&end_dt', 'mm/dd/yyyy')
   and aut.a_type in ('OH')
   and aut.lob is not null
   and aut.region <> '12'
   and IH.decision in ('A','P')
   and (diag.description LIKE '%DIABETES%' OR
       diag.description LIKE '%SYNCOPE%' OR
       diag.description LIKE '%CHEST PAIN%' OR
       diag.description LIKE '%URINARY TRACT INFECTION%')