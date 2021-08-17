select aut.lob,
       aut.region,
       aut.auth_no,
       case
         when aut.expire_dt < sysdate then
          'expired'
         else
          'not_expired'
       end as "AUTH_STATUS",
       aut.mem_no,
       concat(concat(mbr.fname,' '),mbr.lname) MBR_NAME,
       prov.prov_id VENDOR_ID,
       concat(concat(prov.lname, ' '), prov.fname) VENDOR_NAME,
       aut.refer_dt,
       concat(concat(aut.diag_cd,' - '),diag.description) DIAG,
       aut.letter_flag DECISION,
       aut.case_status

  from careware.providers prov

 inner join careware.authorizations aut on prov.prov_id = aut.vendor_id
 inner join careware.members mbr on aut.mem_no=mbr.mem_no
 inner join careware.diagnosis_codes diag on aut.diag_cd=diag.diag_cd
 
 where aut.lob in ('&LOB1','&LOB2')
 and aut.vendor_id='&Vendor_id'
 and aut.region in ('&reg1','&reg2')
 and aut.refer_dt between add_months(to_date('&term_dt', 'mm/dd/yyyy'), -6) and
       add_months(to_date('&term_dt', 'mm/dd/yyyy'), +6)