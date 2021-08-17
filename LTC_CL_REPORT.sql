select distinct auth.lob,
auth.region,
auth.auth_no,
auth.a_type,
cl.type CL_TYPE,
auth.bed_type,
auth.interviewer,
auth.interview_dt

from careware.authorizations auth

left join careware.claims cl
on auth.mem_no=cl.mem_no

where auth.lob='100'
and auth.region not in ('10','13','12')
and cl.dos BETWEEN TO_DATE('01/01/2016', 'MM/DD/YYYY') AND TO_DATE('01/31/2016', 'MM/DD/YYYY')
and auth.interviewer in ('T01','M5','CD','SF')
and cl.type in ('PMD','MD','PAN','AN','POH','OH','PTR','TR','PHH','HH')
and auth.bed_type in ('CST','LTS')
