select distinct concat(concat(mbr.fname, ' '), mbr.lname) MEMBER_NAME,
                t.mem_no,
                mbr.birth_dt MEMBER_DOB,
                aut.aid_cd MCAL_AIDCODE,
                'SAN DIEGO' COUNTY,
                t.auth_no PA_NUMBER,
                'MEDI-CAL' PRODUCT_LINE,
                t.refer_dt PA_DATE,
                concat(concat(aut_proc.proc_cd, ' - '), proc_cd.description) PROC_REQ,
                concat(concat(prov.spec_cd1, ' - '), spec_cd.description) SPECIALTY,
                concat(concat(t.diag_cd, ' - '), diag.description) DIAGNOSIS,
                t.rcv_dt DATE_RECEIVED,
                aut_proc.pr_decision_dt DATE_OF_ACTION,
                aut.letter_flag ACTION,
                case
                  when aut.letter_flag in ('D', 'M') then
                   md.md_decision_by
                  else
                   ' '
                end as "DCSN_MAKER",
                case
                  when aut.letter_flag in ('D', 'M') then
                   aut_proc.decision_reason
                  else
                   ' '
                end as "DENIAL_REASON"

  from dhcs_preauth_2016 t

 inner join careware.authorizations aut on t.auth_no = aut.auth_no
 inner join mbrs_grp grp on aut.aid_cd = grp.group_no
 inner join careware.members mbr on t.mem_no = mbr.mem_no
 inner join careware.auth_procedures aut_proc on t.auth_no =
                                                 aut_proc.auth_no
 inner join careware.procedure_codes proc_cd on aut_proc.proc_cd =
                                                proc_cd.proc_cd
 inner join careware.diagnosis_codes_icd10 diag on t.diag_cd = diag.diag_cd
 inner join careware.providers prov on aut.refer_to = prov.prov_id
 inner join careware.specialty_codes spec_cd on prov.spec_cd1 =
                                                spec_cd.spec_cd
 inner join careware.auth_md_log md on aut.auth_no=md.auth_no

 where grp.grp2 <> 'SPD'
   and aut.letter_flag in ('A', 'M', 'D')
   and aut.letter_flag <> ' '