-- refresh WPW_TABLE_2017
drop table WPW_TABLE_2017;
create table WPW_TABLE_2017
as (select distinct cl.mem_no,
                case
                  when cl.cl_form = 'U' then
                   'UB-92'
                  else
                   'CMS-1500'
                end as "CLAIM_FORM",
                sum(clp.pay_amt) CL_PAID
                
  from careware.claims cl
  left join careware.members mbr on cl.mem_no = mbr.mem_no
  left join careware.cl_procedures clp on cl.document = clp.document
  left join careware.mem_elig_hist elig on cl.mem_no = elig.mem_no
  
  where cl.dos between to_date('1/1/2017', 'mm/dd/yyyy') and
       to_date('12/31/2017', 'mm/dd/yyyy')
   and mbr.birth_dt < to_date('1/1/1999', 'mm/dd/yyyy')
   and elig.status_dt = '201804'
   and elig.phys not in ('09CST', '09LTS')
   
   group by cl.mem_no,cl.cl_form);

