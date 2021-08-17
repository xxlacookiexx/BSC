select leg."filename",
       leg."Recv_Dt",
       case
         when leg."CCSID" in ('PA6506', 'PA0970') then
          'San Diego'
         when leg."CCSID" in ('PA6577', 'PA6505', 'PA6504', 'PA6509') then
          'Los Angeles'
         when leg."CCSID" in ('PA3306') then
          'LA + SD'
         else
          'Other'
       End as "County",
       leg."Mem_no",
       leg."Provider",
       leg."Auth_NO"

  from dbo."vu_CA_Patient_Auth"@legato leg

 where leg."Auth_NO" = '123456'
   and leg."Recv_Dt" > '2018-05-31'