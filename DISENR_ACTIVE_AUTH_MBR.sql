select distinct
careware.members.lob,
careware.disenroll.mem_no,
careware.authorizations.auth_no,
careware.authorizations.expire_dt,
careware.disenroll.reg_at_disenr REGION,
careware.disenroll.group_cd,
mbr_grp.grp2,
careware.authorizations.admit_dt,
careware.authorizations.disch_dt,
careware.members.prov_id,
concat(careware.providers.fname,careware.providerS.lname) PROVIDERS,
careware.authorizations.tos,
careware.auth_service_types.description,
careware.disenroll.begin_dt ENR_DT,
careware.disenroll.end_dt DISENR_DT,
careware.disenroll.disenr_reason,
careware.disenroll.disenr_rsns

from careware.disenroll

inner join careware.members
on careware.disenroll.mem_no=careware.members.mem_no
inner join mbr_grp
on careware.disenroll.group_cd=mbr_grp.group_no
inner join careware.providers
on careware.members.prov_id=careware.providers.prov_id
inner join careware.authorizations
on careware.disenroll.mem_no=careware.authorizations.mem_no
left join careware.auth_service_types
on careware.authorizations.tos=careware.auth_service_types.service_type

where careware.members.lob='100'
and end_dt between to_date('09/01/2015','mm/dd/yyyy')+1 and to_date('09/30/2015','mm/dd/yyyy')
and careware.authorizations.expire_dt > to_date('10/01/2015','mm/dd/yyyy')
order by mem_no;