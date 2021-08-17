select distinct t.lob,
                t.region,
                t.auth_no,
                cl.document,
                cl.dos,
                cl.cl_status,
                t.mem_no,
                regexp_replace(t.auth_no, '[^[:digit:]]') AS AUTH,
                regexp_replace(t.auth_no, '[^[:alpha:]]') AS A_TYPE,
                proc.proc_cd,
                case
                  when proc.proc_cd = 'A0426' then
                   'ALS1'
                  when proc.proc_cd = 'A0427' then
                   'ALS1'
                  when proc.proc_cd = 'A0428' then
                   'BLS'
                  when proc.proc_cd = 'A0429' then
                   'BLS-Emergency'
                  when proc.proc_cd = 'A0433' then
                   'ALS2'
                  else
                   'SCT'
                end as "Service_Type"

  from careware.authorizations t

  left join careware.claims cl on regexp_replace(t.auth_no, '[^[:digit:]]') =
                                  cl.auth_no
  left join careware.cl_procedures proc on cl.document = proc.document

 where t.lob in ('100', '120', '2400')
   AND CL.DOS between to_date('1/1/2015', 'mm/dd/yyyy') and
       to_date('12/31/2015', 'mm/dd/yyyy')
   and cl.cl_status = 'P'
   and t.letter_flag in ('M','A')
   and proc.proc_cd in ('A0426', 'A0427', 'A0428', 'A0429', 'A0433', 'A0434')
   and regexp_replace(t.auth_no, '[^[:alpha:]]')='PTR'