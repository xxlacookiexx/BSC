select distinct aut.lob,
                aut.region,
                aut.mem_no,
                concat(concat(mbr.fname, ' '), mbr.lname) MBR_NAME,
                mbr.birth_dt,
                trunc(months_between(sysdate, mbr.birth_dt) / 12) AGE,
                aut.enter_type,
                aut.auth_no,
                aut.refer_dt,
                aut.refer_to,
                concat(concat(prov.lname, ' '), prov.fname) RFR_TO_NAME,
                concat(concat(prov.spec_cd1, ' - '), spec_cd.description) RFR_TO_SPEC,
                aut.refer_by,
                concat(concat(prov2.lname, ' '), prov2.fname) RFR_BY_NAME,
                concat(concat(aut.tos, ' - '), tos.description) TOS,
                concat(concat(aut.diag_cd, ' - '), diag_cd.description) DIAG_DESC,
                aut_proc.line_no,
                concat(concat(aut_proc.proc_cd, ' - '), proc_cd.description) PROCEDURE,
                aut_proc.pr_decision,
                aut_proc.pr_decision_dt

  from careware.authorizations aut

 inner join careware.providers prov on aut.refer_to = prov.prov_id
 inner join careware.providers prov2 on aut.refer_by = prov2.prov_id
 inner join careware.specialty_codes spec_cd on prov.spec_cd1 =
                                                spec_cd.spec_cd
 inner join careware.members mbr on aut.mem_no = mbr.mem_no
 inner join careware.diagnosis_codes_icd10 diag_cd on aut.diag_cd =
                                                      diag_cd.diag_cd
 inner join careware.auth_service_types tos on aut.tos = tos.service_type
 inner join careware.auth_procedures aut_proc on aut.auth_no =
                                                 aut_proc.auth_no
 inner join careware.procedure_codes proc_cd on aut_proc.proc_cd =
                                                proc_cd.proc_cd

 where prov.spec_cd1 in
       ('09', '15', '16', '26', '36', '61', '71', '73', '77', '86', '90',
        '112', '121', '126', '127', '129', '132', '146', '151', '161', '162',
        '163', '171', '173', '178', '180', 'HIV', 'MHT')
   and aut.refer_dt = trunc(sysdate - 1)
   and aut_proc.pr_decision <>'V01'

 order by aut.mem_no, aut.refer_to, aut_proc.line_no