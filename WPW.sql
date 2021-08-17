select distinct mbr.lob,
                mbr.mem_no,
                mbr.lname,
                mbr.fname,
                mbr.birth_dt DOB,
                mbr.sex GENDER,
                eth.ethnic_desc ETHNIC,
                concat(concat(mbr.address1, ' '), mbr.address2) ADDRESS,
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
                cl.drg DRG_CD,
                rev.rev_cd,
                clp.proc_cd,
                cl.admit_dt,
                cl.disch_dt,
                cl.disposition,
                cl.dos,
                clt.cl_type_desc SERVICE_TYPE,
                clp.pay_amt,
                case
                  when clp.proc_cd in
                       ('Q5001', 'Q5002', 'Q5003', 'Q5004', 'Q5005', 'Q5006',
                        'Q5007', 'Q5008', 'Q5009') then
                   'Y'
                  else
                   'N'
                end as "HOSPICE_FLAG",
                max(elig.trans_dt) DATE_LAST_ENROLLMENT,
                spec.description SPECILATY

  from careware.members mbr
  left join careware.claims cl on mbr.mem_no = cl.mem_no
  left join careware.cl_diagnoses cld on cl.document = cld.document
  left join careware.cl_procedures clp on cl.document = clp.document
  left join careware.cl_ub92_rev_codes rev on clp.document = rev.document
                                          and clp.proc_cd = rev.hcpcs
  left join careware.mem_elig_hist elig on mbr.mem_no = elig.mem_no
  left join careware.ethnic_codes eth on mbr.ethnic = eth.ethnic_cd
  left join careware.cl_types clt on cl.type = clt.cl_type
  left join careware.providers prov on cl.prov_id = prov.prov_id
  left join careware.specialty_codes spec on prov.spec_cd1 = spec.spec_cd

 where cl.dos between to_date('1/1/2018', 'mm/dd/yyyy') and
       to_date('7/31/2018', 'mm/dd/yyyy')
   and mbr.mem_no in
       ('1883755*01', '1561611*01', '1004536*01', '1705693*01', '862530*01',
        '1805646*01', '1571828*01', '1954984*01', '2167625*01', '2186841*01',
        '1292017*01', '1561422*01', '1601888*01', '1973458*01', '1794270*01',
        '1267996*01')
 group by mbr.lob,
          mbr.mem_no,
          mbr.lname,
          mbr.fname,
          mbr.birth_dt,
          mbr.sex,
          eth.ethnic_desc,
          mbr.address1,
          mbr.address2,
          mbr.city,
          mbr.zip,
          mbr.ssn,
          mbr.cin,
          cl.document,
          cl.aid_cd,
          cl.cl_form,
          clp.line_no,
          clp.line_diag1,
          clp.line_diag2,
          clp.line_diag3,
          clp.line_diag4,
          cl.drg,
          rev.rev_cd,
          clp.proc_cd,
          cl.admit_dt,
          cl.disch_dt,
          cl.disposition,
          cl.dos,
          clt.cl_type_desc,
          clp.pay_amt,
          spec.description
 order by mbr.mem_no, cl.document, cl.dos