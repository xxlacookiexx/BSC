select distinct aut.auth_no,
                aut.lob,
                aut.letter_flag,
                aut.decision_dt,
                aut.mhc_auth_type,
                grp.grp,
                grp.grp2,
                pcl.auth_no as CL_AUTH_NO,
                pcl.cl_status,
                pcl.region

  from careware.authorizations aut

  left join mbrs_grp grp on aut.aid_cd = grp.group_no
  left join (select distinct cl.lob,
                             cl.region,
                             concat(concat(cl.auth_no, '*'), cl.type) AUTH_NO,
                             cl.cl_status,
                             cl.dos,
                             cl.pay_amt
             
               from careware.claims cl
             
              where cl.lob in ('100', '700')
                and cl.cl_status = 'P'
                and cl.type in ('PAN', 'PMD')
                and cl.dos between to_date('&START_DT', 'mm/dd/yyyy') and
                    to_date('&END_DT', 'mm/dd/yyyy')) pcl on aut.auth_no =
                                                                pcl.auth_no

 where aut.lob in ('100', '700')
   and aut.letter_flag = 'A'
   and aut.decision_dt between to_date('&START_DT', 'mm/dd/yyyy') and
       to_date('&END_DT', 'mm/dd/yyyy')
   and aut.mhc_auth_type in ('PAN', 'PMD')
   