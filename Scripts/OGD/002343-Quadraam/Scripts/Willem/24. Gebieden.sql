SELECT DISTINCT
	Plaatsnaam = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."PLAATSNAAM"')))
	, Gemeentenaam = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."GEMEENTENAAM"')))
	, Gemeentenummer = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."GEMEENTENUMMER"')))
	, Provincie = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."PROVINCIE"')))
	, OnderwijsGebiedCode = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."ONDERWIJSGEBIED CODE"')))
	, OnderwijsGebiedNaam = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."ONDERWIJSGEBIED NAAM"')))
	, CoropGebiedCode = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."COROPGEBIED CODE"')))
	, CoropGebiedNaam = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."COROPGEBIED NAAM"')))
	, RmcRegioCode = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."RMC-REGIO CODE"')))
	, RmcRegioNaam = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."RMC-REGIO NAAM"')))
	, RpaGebiedCode = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."RPA-GEBIED CODE"')))
	, RpaGebiedNaam = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."RPA-GEBIED NAAM"')))
	, WgrGebiedCode = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."WGR-GEBIED CODE"')))
	, WgrGebiedNaam = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."WGR-GEBIED NAAM"')))
	, NodaalGebiedCode = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."NODAAL GEBIED CODE"')))
	, NodaalGebiedNaam = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."NODAAL GEBIED NAAM"')))
FROM
	[Staging_Quadraam].setup.DataObjects j
	CROSS APPLY OPENJSON(j.BulkColumn, 'lax $.results') k
	CROSS APPLY setup.TransformTableNameDUO(j.Connector)
WHERE 1=1
	AND j.DataSource = 'DUO'
	AND j.ContentType = 'Data'
	AND j.Connector = '01.-hoofdvestigingen-vo'
ORDER BY
	Provincie
	, Plaatsnaam

SELECT DISTINCT
	Gemeentenaam = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."GEMEENTENAAM"')))
	, Gemeentenummer = LTRIM(RTRIM(JSON_VALUE(k.[value], '$."GEMEENTENUMMER"')))
	, Jaar
FROM
	[Staging_Quadraam].setup.DataObjects j
	CROSS APPLY OPENJSON(j.BulkColumn, 'lax $.results') k
	CROSS APPLY setup.TransformTableNameDUO(j.Connector)
WHERE 1=1
	AND j.DataSource = 'DUO'
	AND j.ContentType = 'Data'
	AND j.Connector LIKE '%leerlingen%po%per%gemeente%schoolgaand%in%en%buiten%de%gemeente%'
ORDER BY
	Gemeentenaam