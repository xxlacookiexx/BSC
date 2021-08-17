select distinct aut.lob,
                aut.region,
                aut.mem_no,
                aut.auth_no,
                aut.mhc_auth_type,
                aut.refer_dt,
                aut.enter_type,
                aut.review_type,
                aut.tos,
                aut.diag_cd,
                aut.refer_to,
                aut.admit_dt,
                aut.disch_dt,
                aut.case_status,
                aut.letter_flag,
                aut_proc.line_no,
                aut_proc.qty,
                concat(concat(aut_proc.proc_cd, ' - '), proc_cd.description) PROCEDURE,
                aut_proc.pr_decision,
                aut_proc.pr_decision_dt,
                concat(concat(aut_proc.decision_reason, ' - '),
                       reason_cd.description) DECISION_REASON

  from careware.authorizations aut

  left join careware.auth_procedures aut_proc on aut.auth_no =
                                                 aut_proc.auth_no
  left join careware.auth_reason_codes reason_cd on aut_proc.decision_reason =
                                                    reason_cd.reason_cd
  left join careware.procedure_codes proc_cd on aut_proc.proc_cd =
                                                proc_cd.proc_cd

 where aut.lob = '100'
   and aut_proc.pr_decision_dt between to_date('04/04/2016', 'mm/dd/yyyy') and
       to_date('3/3/2017', 'mm/dd/yyyy')
   and aut_proc.pr_decision = 'D'
   and aut.in_out = 'O'
   and aut.enter_type <> 'DLOG'
 order by aut.auth_no, aut_proc.line_no