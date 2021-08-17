select distinct enc.enc_id,
                enc.i_mem_no,
                t.age,
                t.age_range,
                t.age_group,
                t.sex,
                t.lang_desc,
                t.language_grp,
                t.lob,
                CD.DX_CODE,
                enc.diag_cd1,
                cd.condition,
                enc.admission_dt,
                enc.prov_id1,
                t.mem_county,
                t.grp2

  from mcal_pop_assessment_2016_tbl t

 inner join careware.encounters enc on t.mem_no = enc.i_mem_no
 inner join chronic_mcal_diag cd on enc.diag_cd1 = cd.diag