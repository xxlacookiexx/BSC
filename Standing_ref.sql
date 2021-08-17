select distinct aut.mem_no,
                concat(concat(mbr.fname, ' '), mbr.lname) MBR_NAME,
                mbr.cin,
                mbr.sex,
                mbr.birth_dt,
                mbr.disenr,
                aut.aid_cd,
                aut.region,
                aut.auth_no,
                aut.diag_cd,
                diag.description DIAG_DESC,
                concat(concat(prov.fname, ' '), prov.lname) REFER_TO,
                aut.enter_dt,
                aut.refer_dt,
                aut.decision_dt,
                aut.letter_flag DECISION,
                aut.case_status,
                mbr.prov_id,
                aut.expire_dt,
                ap.line_no,
                ap.from_dt,
                ap.thru_dt,
                ap.proc_cd,
                proc.description PROC_DESC,
                ap.qty,
                aut.mhc_auth_type,
                aut.lob

  from careware.authorizations aut

  left join careware.auth_procedures ap on aut.auth_no = ap.auth_no
  left join careware.procedure_codes proc on ap.proc_cd = proc.proc_cd
  left join careware.diagnosis_codes diag on aut.diag_cd = diag.diag_cd
  left join careware.members mbr on aut.mem_no = mbr.mem_no
  left join careware.providers prov on aut.refer_to = prov.prov_id

 where aut.lob = '100'
   and aut.mhc_auth_type <> 'IH'
   and aut.case_status <> 'V'
   and aut.region in ('10', '11')
   and aut.diag_cd in
       ('O98.719', 'O98.7', 'O98.713', 'O98.712', 'O98.711', 'Z71.7',
        'O98.73', 'B97.35', 'B20', 'O98.71', 'O98.72')