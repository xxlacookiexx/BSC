select t.lob,
       t.region,
       t.mem_no,
       GRP.GRP2 PLAN_TYPE,
       t.auth_no,
       t.expire_dt AUTH_EXP_DT,
       claims.document,
       claims.dos,
       claims.cl_status,
       claims.invoice_dt,
       claims.pay_dt,
       t.refer_dt,
       t.refer_to,
       T.ADMIT_DT,
       T.DISCH_DT,
       t.diag_cd,
       t.case_status,
       t.aid_cd,
       t.letter_flag DECISION

  from careware.authorizations t

 left join careware.claims claims on substr(t.AUTH_NO, 1, 7) =
                                      claims.auth_no
                                  and t.mem_no = claims.mem_no and t.mhc_auth_type=claims.type
                                  
                                  LEFT JOIN MBRS_GRP GRP ON T.AID_CD=GRP.GROUP_NO
 
 where t.refer_to = '3207'
   and t.refer_dt between to_date('1/1/2016', 'mm/dd/yyyy') and
       to_date('6/8/2016', 'mm/dd/yyyy')
   and t.lob = '100'
   and t.letter_flag not in ('V')