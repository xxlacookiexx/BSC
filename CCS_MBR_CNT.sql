select distinct ccs.lob,
                ccs.reg,
                ccs.mem_no,
                ccs.age,
                ccs.status_dt,
                ccs."CCS_Status"

  from (select distinct mbr.lob,
                        mbr.region || ' - ' || reg.description REG,
                        elig.mem_no,
                        trunc(months_between(elig.trans_dt, mbr.birth_dt) / 12) AGE,
                        elig.status_dt,
                        case
                          when ccs.auth_no is not NULL then
                           'TRUE'
                          else
                           'FALSE'
                        End as "CCS_Status"
        
          from careware.mem_elig_hist elig
          left join careware.members mbr on elig.mem_no = mbr.mem_no
          left join careware.region_codes reg on mbr.region = reg.region_cd
          left join careware.authorizations aut on elig.mem_no = aut.mem_no
          left join (select auth_no,
                           reason_cd,
                           reason_cd2,
                           reason_cd3,
                           reason_cd4,
                           reason_cd5
                      from careware.authorizations
                     where reason_cd in ('EE', 'MM', 'LL', 'LLL', 'FF')
                        or reason_cd2 in ('EE', 'MM', 'LL', 'LLL', 'FF')
                        or reason_cd3 in ('EE', 'MM', 'LL', 'LLL', 'FF')
                        or reason_cd4 in ('EE', 'MM', 'LL', 'LLL', 'FF')
                        or reason_cd5 in ('EE', 'MM', 'LL', 'LLL', 'FF')) ccs on aut.auth_no =
                                                                                 ccs.auth_no
        
         where elig.trans_dt between to_date('&start_dt', 'mm/dd/yyyy') and
               to_date('&end_dt', 'mm/dd/yyyy')) ccs

 where ccs."CCS_Status" = 'TRUE'
   and ccs.age < 21