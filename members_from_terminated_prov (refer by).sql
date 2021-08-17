select distinct prov.prov_id,
                concat(concat(prov.lname, ' '), prov.fname) PCP_NAME,
                aut.mem_no,
                concat(concat(mbr.fname, ' '), mbr.lname) MBR_NAME,
                aut.auth_no,
                aut.refer_dt,
                aut.refer_to,
                concat(concat(prov2.lname, ' '), prov2.fname) Refer_TO_Name,
                spec_cd.description PROV_SPEC,
                case
                  when aut.expire_dt < sysdate then
                   'expired'
                  else
                   'not_expired'
                end as "AUTH_STATUS"

  from careware.providers prov
 inner join careware.authorizations aut on prov.prov_id = aut.refer_by
 inner join careware.providers prov2 on aut.refer_to = prov2.prov_id
 inner join careware.specialty_codes spec_cd on prov2.spec_cd1 =
                                                spec_cd.spec_cd
 inner join careware.members mbr on aut.mem_no = mbr.mem_no

 where prov.license_no = 'A87833'
   and aut.refer_dt > to_date('2/23/2017', 'mm/dd/yyyy')
   and aut.region='10'
   and aut.lob='100'