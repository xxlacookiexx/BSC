select distinct mbr.mem_no,
                'CA_' || mbr.mem_no ccms_ID,
                mbr.zip,
                ccms.case_type,
                ccms.case_type_desc,
                ccms.row_created,
                ccms.case_close_date,
                cs.case_status_desc,
                cr.close_reason_desc
  from careware.members mbr
 right join apptest.ccms_cases_ca ccms on 'CA_' || mbr.mem_no =
                                          ccms.member_id
  left join ccms_close_reason cr on ccms.close_reason = cr.close_reason
  left join apptest.ccms_zl_case_status cs on ccms.case_status =
                                              cs.case_status

 where mbr.zip in ('96095', '96033', '96051', '96019', '96001', '96087',
        '96002', '96003', '96052', '96093', '95482', '95485',
        '95453', '95979', '95423', '95449', '92530','92679','96013')