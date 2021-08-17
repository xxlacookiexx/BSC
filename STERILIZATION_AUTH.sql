select aut.lob,
       aut.region,
       ap.auth_no,
       ap.line_no,
       ap.proc_cd,
       proc.description PROC_DESC,
       ap.pr_decision,
       ap.qty,
       ap.from_dt,
       ap.thru_dt,
       aut.mem_no,
       concat(concat(mbr.fname,' '), mbr.lname) MBR_NAME,
       aut.refer_dt,
       mbr.birth_dt,
       mbr.sex,
       mbr.cin,
       aut.diag_cd,
       diag.description DIAG_DESC,
       aut.case_status,
       aut.pos,
       aut.tos

  from careware.auth_procedures ap
 inner join careware.authorizations aut on ap.auth_no = aut.auth_no
 inner join careware.procedure_codes proc on ap.proc_cd = proc.proc_cd
 inner join careware.diagnosis_codes diag on aut.diag_cd = diag.diag_cd
 inner join careware.members mbr on aut.mem_no = mbr.mem_no

 where ap.proc_cd in ('55250', '55450', '58600', '58605', '58611', '58615',
        '58661', '58670', '58671', '58700')
      and aut.refer_dt between to_date('7/1/2016', 'mm/dd/yyyy') and
       to_date('3/31/2017', 'mm/dd/yyyy')
       and aut.lob='100'