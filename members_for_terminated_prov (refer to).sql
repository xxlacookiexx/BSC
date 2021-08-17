Select Distinct t.LOB,
                t.REGION,
                t.AUTH_NO,
                Case
                  When t.EXPIRE_DT < SysDate Then
                   'expired'
                  Else
                   'not_expired'
                End As AUTH_STATUS,
                t.EXPIRE_DT,
                t.MEM_NO,
                Concat(Concat(member.FNAME, ' '), member.LNAME) MBR_NAME,
                t.REFER_TO,
                Concat(Concat(prov.LNAME, ' '), prov.FNAME) Provider_name,
                t.REFER_DT,
                Concat(Concat(t.DIAG_CD, ' - '), diag.DESCRIPTION) DIAG,
                t.LETTER_FLAG decision,
                t.CASE_STATUS
  From CAREWARE.PROVIDERS prov
  Left Join CAREWARE.AUTHORIZATIONS t
    On t.REFER_TO = prov.PROV_ID
  Left Join CAREWARE.MEMBERS member
    On t.MEM_NO = member.MEM_NO
 Left Join CAREWARE.DIAGNOSIS_CODES_ICD10 diag
    On t.DIAG_CD = diag.DIAG_CD
 Where t.LOB In ('&LOB1', '&LOB2', '&LOB3', '&LOB4')
   And t.REGION In
       ('&reg1', '&reg2', '&reg3', '&reg4', '&reg5', '&reg6', '&reg7')
   And t.REFER_DT Between Add_Months(To_Date('&term_dt', 'mm/dd/yyyy'), -6) And
       Add_Months(To_Date('&term_dt', 'mm/dd/yyyy'), +6)
   And prov.LICENSE_NO = '&License_NO'
