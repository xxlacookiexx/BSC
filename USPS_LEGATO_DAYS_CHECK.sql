select aut.auth_no,
       aut.remarks,
       leg.RCV_DT,
       trunc(usps.usps_dt) USPS_DT,
       aut.enter_type,
       aut.review_type,
       aut.letter_flag

  from careware.authorizations aut
  left join (SELECT a.auth_no, B.batch_no, B.print_dt, B.usps_dt
               FROM CAREWARE.AUTHORIZATIONS A, VU_CA_PA_MAIL_LOG@LEGATO B
              WHERE B.AUTH_NO = replace(A.auth_no, '*')
                and b.usps_dt between sysdate - 500 and sysdate) usps on aut.auth_no =
                                                                         usps.auth_no
  left join (select distinct auth.auth_no,
                             auth.enter_type,
                             case
                               when legato.rec_dt is null then
                                auth.refer_dt
                               else
                                to_date(substr(legato.rec_dt, 0, 10),
                                        'yyyy/mm/dd')
                             end as "RCV_DT",
                             substr(legato.rec_dt, -8, 8) RCV_TIME
             
               from careware.authorizations auth
               left join (select b."field5" as AUTH_NO,
                                min(a."field2") as REC_DT
                           from sysop.ae_dt10@legato a,
                                sysop.ae_rf10@legato b
                          where a."field14" = b."field14"
                            and b."field5" is not null
                            and b."field5" not like '%,%'
                            and b."field5" like '%*%'
                            and a."field2" >
                                to_date('12/1/2017', 'mm/dd/yyyy')
                          group by b."field5") legato on auth.auth_no =
                                                         legato.auth_no) leg on aut.auth_no =
                                                                                leg.auth_no

 where aut.auth_no in ('2461779*IH', '2612855*IH', '2234526*IH',
        '2284295*IH', '2011988*IH', '2271201*IH')