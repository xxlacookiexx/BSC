select distinct wpw.mem_no,
                mbr.lname,
                mbr.fname,
                mbr.birth_dt DOB,
                mbr.sex GENDER,
                mbr.address2,
                mbr.city,
                mbr.zip,
                mbr.ssn,
                mbr.cin,
                cl.document,
                case
                  when cl.cl_form = 'U' then
                   'UB-92'
                  else
                   'CMS-1500'
                end as "CLAIM_FORM",
                clp.line_no,
                clp.line_diag1 DIAG_CD1,
                clp.line_diag2 DIAG_CD2,
                clp.line_diag3 DIAG_CD3,
                clp.line_diag4 DIAG_CD4,
                rev.rev_cd,
                clp.proc_cd,
                cl.admit_dt,
                cl.disch_dt,
                cl.dos,
                clp.pay_amt

  from wpw_table_2017 wpw
 inner join careware.claims cl on wpw.mem_no = cl.mem_no
 inner join careware.members mbr on wpw.mem_no = mbr.mem_no
  left join careware.cl_procedures clp on cl.document = clp.document
  left join careware.cl_ub92_rev_codes rev on clp.document = rev.document
                                          and clp.proc_cd = rev.hcpcs

 where wpw.cl_paid >= 20000
   and cl.dos between to_date('1/1/2017', 'mm/dd/yyyy') and
       to_date('12/31/2017', 'mm/dd/yyyy')
   and mbr.lob = '700'

 order by wpw.mem_no, cl.document, cl.dos