  SELECT DISTINCT
  COALESCE(to_number(C.CLIENT_NUMBER), to_number(C.CLIENT_NUMBER), C.CLIENT_ID) AS CLIENT_NUMBER, 
  c.full_name_alternate,
  ao.ORGANIZATION_NAME,
  ao.parent_organization,
  rca."OTHER_ALLERGY" AS Allergen,
  to_char(nal.BEGIN_DATETIME, 'MM/DD/YYYY') AS BEGIN_DATE,
  to_char(nal.END_DATETIME, 'MM/DD/YYYY') AS END_DATE,
 -- ca.BEGIN_DATE,
  rca.TYPE,
  /* Sets Allergen to blank for client 42546; otherwise adjusts values 
  for specific clients or concatenates nal.NKA and nal.NKDA - RCN 11/11/2024*/
 /*CASE
 	WHEN c.client_number = 42546 THEN ''
 	ELSE
    CASE
    WHEN c.client_number IN (42547, 44088) AND nal.NKA = 'Y' THEN ''
    ELSE nal.NKA
  END || ', ' ||
  CASE
    WHEN c.client_number IN (42547, 44088) AND nal.NKA = 'Y' THEN 'Y'
    ELSE nal.NKDA
    END
  END AS Allergen*/


nal.NKA,
nal.NKDA,
rca.comments

FROM rpt_client c
--JOIN rpt_client_document cd ON cd.client_id = c.client_id
JOIN RPT_CLIENT_PROGRAMS cp ON cp.client_id = c.client_id    
JOIN rpt_admin_organization ao ON cp.organization_id = ao.organization_id
LEFT JOIN CLIENT_ALLERGY ca ON ca.client_id = c.client_id
JOIN no_allergy_log nal ON ca.client_allergy_id = nal.client_allergy_id
LEFT JOIN RPT_CLIENT_ALLERGIES rca ON rca.client_id = c.client_id



WHERE 
   --ca."OTHER_ALLERGY" IS NOT NULL
  --AND C.FULL_NAME_ALTERNATE NOT LIKE 'ZZZ%'
    
   ((-1 IN (${POrg})) OR (parent_org_id IN (${POrg})))
  AND ((-1 IN (${Orgname})) OR (cp.ORGANIZATION_ID IN (${Orgname})))
  AND ((-1 IN (${Client})) OR c.CLIENT_ID IN (${Client}))
  AND ((-1 IN (${Progname})) OR (cp.program_id IN (${Progname})))
 

when nal.NKA and nal.NKDA = Y then TYPE, ALLERGEN, BEGIN DATE, END DATE, COMMENTS columns should be blank

  










--V2

SELECT DISTINCT
  COALESCE(TO_NUMBER(C.CLIENT_NUMBER), TO_NUMBER(C.CLIENT_NUMBER), C.CLIENT_ID) AS CLIENT_NUMBER,
  c.full_name_alternate,
  ao.ORGANIZATION_NAME,
  ao.parent_organization,
  -- If nal.NKA and nal.NKDA are both 'Y', set Allergen to blank
  CASE
    WHEN nal.NKA = 'Y' AND nal.NKDA = 'Y' THEN ''
    ELSE rca."OTHER_ALLERGY"
  END AS Allergen,
  -- If nal.NKA and nal.NKDA are both 'Y', set BEGIN_DATE to blank
  CASE
    WHEN nal.NKA = 'Y' AND nal.NKDA = 'Y' THEN ''
    ELSE TO_CHAR(nal.BEGIN_DATETIME, 'MM/DD/YYYY')
  END AS BEGIN_DATE,
  -- If nal.NKA and nal.NKDA are both 'Y', set END_DATE to blank
  CASE
    WHEN nal.NKA = 'Y' AND nal.NKDA = 'Y' THEN ''
    ELSE TO_CHAR(nal.END_DATETIME, 'MM/DD/YYYY')
  END AS END_DATE,
  -- Logic to categorize ALLERGY_TYPE
  CASE
    WHEN nal.NKA = 'Y' AND nal.NKDA = 'Y' THEN ''
    ELSE 
      CASE 
        -- Convert each allergy type to its respective group
        WHEN rca.ALLERGY_TYPE IN ('Medication', 'Drug', 'MA---Medication Allergies and Medication Sensitivities (including OTC, herbal) (MSDP)') THEN 'Medication'
        WHEN rca.ALLERGY_TYPE IN ('Non-Medication', 'Food', 'Insect', 'Animal', 'Group') THEN 'Non-Medication'
        WHEN rca.ALLERGY_TYPE = 'Sensitivity' THEN 'Sensitivity'
        ELSE '' 
      END
  END AS TYPE,
  -- Modify nal.NKA and nal.NKDA to blank if c.client_number = 42546
  CASE
  WHEN c.client_number = 42546 THEN ''
  WHEN c.client_number IN (42547, 44088) AND nal.NKA = 'Y' THEN ''
  ELSE nal.NKA
END AS NKA,
  CASE 
    WHEN c.client_number = 42546 THEN ''
    WHEN c.client_number IN (42547, 44088) AND nal.NKA = 'Y' THEN 'Y'
    ELSE nal.NKDA
  END AS NKDA,
  -- If nal.NKA and nal.NKDA are both 'Y', set comments to blank
  CASE 
    WHEN nal.NKA = 'Y' AND nal.NKDA = 'Y' THEN ''
    ELSE rca.comments
  END AS comments

FROM rpt_client c
JOIN RPT_CLIENT_PROGRAMS cp ON cp.client_id = c.client_id    
JOIN rpt_admin_organization ao ON cp.organization_id = ao.organization_id
LEFT JOIN CLIENT_ALLERGY ca ON ca.client_id = c.client_id
JOIN no_allergy_log nal ON ca.client_allergy_id = nal.client_allergy_id
LEFT JOIN RPT_CLIENT_ALLERGIES rca ON rca.client_id = c.client_id

WHERE 
  ((-1 IN (${POrg})) OR (parent_org_id IN (${POrg})))
  AND ((-1 IN (${Orgname})) OR (cp.ORGANIZATION_ID IN (${Orgname})))
  AND ((-1 IN (${Client})) OR c.CLIENT_ID IN (${Client}))
  AND ((-1 IN (${Progname})) OR (cp.program_id IN (${Progname})))








--V3





SELECT DISTINCT
  COALESCE(TO_NUMBER(C.CLIENT_NUMBER), TO_NUMBER(C.CLIENT_NUMBER), C.CLIENT_ID) AS CLIENT_NUMBER,
  c.full_name_alternate,
  ao.ORGANIZATION_NAME,
  ao.parent_organization,
  
  CASE
    WHEN nal.NKA = 'Y' AND nal.NKDA = 'Y' THEN ''
    ELSE TRIM(REGEXP_SUBSTR(rca.OTHER_ALLERGY, '[^,]+', 1, LEVEL)) -- Seperating each allergy by the Comma delimited - RCN 11/14/2024
  END AS Allergen,
 
  CASE
    WHEN nal.NKA = 'Y' AND nal.NKDA = 'Y' THEN ''
    ELSE TO_CHAR(nal.BEGIN_DATETIME, 'MM/DD/YYYY')
  END AS BEGIN_DATE,
  
  CASE
    WHEN nal.NKA = 'Y' AND nal.NKDA = 'Y' THEN ''
    ELSE TO_CHAR(nal.END_DATETIME, 'MM/DD/YYYY')
  END AS END_DATE,
  -- Logic to categorize ALLERGY_TYPE -- RCN 11/14/2024
  CASE
    WHEN nal.NKA = 'Y' AND nal.NKDA = 'Y' THEN ''
    ELSE 
      CASE 
        -- Converted each allergy type to its respective group --RCN 11/14/2024
        WHEN rca.ALLERGY_TYPE IN ('Medication', 'Drug', 'Group', 'MA---Medication Allergies and Medication Sensitivities (including OTC, herbal) (MSDP)') THEN 'Medication'
        WHEN rca.ALLERGY_TYPE IN ('Non-Medication', 'Food', 'Insect', 'Animal') THEN 'Non-Medication'
        WHEN rca.ALLERGY_TYPE = 'Sensitivity' THEN 'Sensitivity'
        ELSE '' 
      END
  END AS TYPE,

  CASE
    WHEN c.client_number = 42546 THEN ''
    WHEN c.client_number IN (42547, 44088) AND nal.NKA = 'Y' THEN ''
    ELSE nal.NKA
  END AS NKA,
  CASE 
    WHEN c.client_number = 42546 THEN ''
    WHEN c.client_number IN (42547, 44088) AND nal.NKA = 'Y' THEN 'Y'
    ELSE nal.NKDA
  END AS NKDA,
 
  CASE 
    WHEN nal.NKA = 'Y' AND nal.NKDA = 'Y' THEN ''
    ELSE rca.comments 
  END AS comments

FROM rpt_client c
JOIN RPT_CLIENT_PROGRAMS cp ON cp.client_id = c.client_id    
JOIN rpt_admin_organization ao ON cp.organization_id = ao.organization_id
LEFT JOIN CLIENT_ALLERGY ca ON ca.client_id = c.client_id
JOIN no_allergy_log nal ON ca.client_allergy_id = nal.client_allergy_id
LEFT JOIN RPT_CLIENT_ALLERGIES rca ON rca.client_id = c.client_id

WHERE 
  ((-1 IN (${POrg})) OR (parent_org_id IN (${POrg})))
  AND ((-1 IN (${Orgname})) OR (cp.ORGANIZATION_ID IN (${Orgname})))
  AND ((-1 IN (${Client})) OR c.CLIENT_ID IN (${Client}))
  AND ((-1 IN (${Progname})) OR (cp.program_id IN (${Progname})))

  -- Using CONNECT BY to split allergen data into separate rows --RCN 11/14/2024
CONNECT BY LEVEL <= LENGTH(rca.OTHER_ALLERGY) - LENGTH(REPLACE(rca.OTHER_ALLERGY, ',', '')) + 1
AND PRIOR c.CLIENT_ID = c.CLIENT_ID
AND PRIOR SYS_GUID() IS NOT NULL

