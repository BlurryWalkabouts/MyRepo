SELECT
	Connector = 'leerlingen_vo_per_vestiging_en_bestuur_(vavo_apart)'
	, Jaar = REPLACE(j.Connector,'03.-leerlingen-vo-per-vestiging-en-bestuur-(vavo-apart)-','')
--	, JSON_VALUE(j.BulkColumn,'$."@id"')
--	, JSON_QUERY(j.BulkColumn,'$."@context"')
--	, JSON_QUERY(j.BulkColumn, 'lax $.results')
--	, ColumnName = RIGHT(w1.[value],CHARINDEX('/',REVERSE(w1.[value]))-1)
	, w2.*
FROM
	[Staging_Quadraam].setup.DataObjects j
--	CROSS APPLY OPENJSON(j.BulkColumn) k1
--	CROSS APPLY OPENJSON(k1.[value]) w1
	CROSS APPLY OPENJSON(j.BulkColumn, 'lax $.results') k2
	CROSS APPLY OPENJSON(k2.[value]) WITH
	(
	"BEVOEGD GEZAG NUMMER"								int
	, "BRIN NUMMER"										char(4)
	, "VESTIGINGSNUMMER"									char(6)
	, "TOTAAL AANTAL LEERLINGEN"						int
	, "AANTAL LEERLINGEN"								int
	, "AANTAL VO LEERLINGEN UITBESTEED AAN VAVO"	int
	, "INSTELLINGSNAAM VESTIGING"						varchar(100)
	, "GEMEENTENAAM"										varchar(50)
	, "GEMEENTENUMMER"									int
	, "PLAATSNAAM"											varchar(50)
	, "PROVINCIE"											varchar(50)
	) w2
WHERE 1=1
	AND j.DataSource = 'DUO'
	AND j.ContentType = 'Data'
	AND j.Connector LIKE '03.-leerlingen-vo-per-vestiging-en-bestuur-(vavo-apart)%'
--	AND k1.[key] = '@context'

SELECT
	Connector = 'leerlingen_vo_per_vestiging_naar_onderwijstype'
	, Jaar = REPLACE(j.Connector,'01.-leerlingen-vo-per-vestiging-naar-onderwijstype-','')
--	, JSON_VALUE(j.BulkColumn,'$."@id"')
--	, JSON_QUERY(j.BulkColumn,'$."@context"')
--	, JSON_QUERY(j.BulkColumn, 'lax $.results')
--	, ColumnName = RIGHT(w1.[value],CHARINDEX('/',REVERSE(w1.[value]))-1)
	, w2.*
FROM
	[Staging_Quadraam].setup.DataObjects j
--	CROSS APPLY OPENJSON(j.BulkColumn) k1
--	CROSS APPLY OPENJSON(k1.[value]) w1
	CROSS APPLY OPENJSON(j.BulkColumn, 'lax $.results') k2
	CROSS APPLY OPENJSON(k2.[value]) WITH
	(
	"AFDELING"													varchar(100)
	, "BRIN NUMMER"											char(4)
	, "ELEMENTCODE"											char(4)
	, "INSTELLINGSNAAM VESTIGING"							varchar(100)
	, "LEER- OF VERBLIJFSJAAR 1 - MAN"					int
	, "LEER- OF VERBLIJFSJAAR 1 - VROUW"				int
	, "LEER- OF VERBLIJFSJAAR 2 - MAN"					int
	, "LEER- OF VERBLIJFSJAAR 2 - VROUW"				int
	, "LEER- OF VERBLIJFSJAAR 3 - MAN"					int
	, "LEER- OF VERBLIJFSJAAR 3 - VROUW"				int
	, "LEER- OF VERBLIJFSJAAR 4 - MAN"					int
	, "LEER- OF VERBLIJFSJAAR 4 - VROUW"				int
	, "LEER- OF VERBLIJFSJAAR 5 - MAN"					int
	, "LEER- OF VERBLIJFSJAAR 5 - VROUW"				int
	, "LEER- OF VERBLIJFSJAAR 6 - MAN"					int
	, "LEER- OF VERBLIJFSJAAR 6 - VROUW"				int
	, "LWOO INDICATIE"										char(1)
	, "ONDERWIJSTYPE VO EN LEER- OF VERBLIJFSJAAR"	varchar(100)
	, "OPLEIDINGSNAAM"										varchar(100)
	, "PLAATSNAAM VESTIGING"								varchar(50)
	, "PROVINCIE VESTIGING"									varchar(50)
	, "VESTIGINGSNUMMER"										varchar(100)
	, "VMBO SECTOR"											varchar(50)
	) w2
WHERE 1=1
	AND j.DataSource = 'DUO'
	AND j.ContentType = 'Data'
	AND j.Connector LIKE '01.-leerlingen-vo-per-vestiging-naar-onderwijstype-%'
--	AND k1.[key] = '@context'

SELECT
	Connector = 'alle_vestigingen_vo'
	, Jaar = 'nvt'
--	, JSON_VALUE(j.BulkColumn,'$."@id"')
--	, JSON_QUERY(j.BulkColumn,'$."@context"')
--	, JSON_QUERY(j.BulkColumn, 'lax $.results')
--	, ColumnName = RIGHT(w1.[value],CHARINDEX('/',REVERSE(w1.[value]))-1)
	, w2.*
FROM
	[Staging_Quadraam].setup.DataObjects j
--	CROSS APPLY OPENJSON(j.BulkColumn) k1
--	CROSS APPLY OPENJSON(k1.[value]) w1
	CROSS APPLY OPENJSON(j.BulkColumn, 'lax $.results') k2
	CROSS APPLY OPENJSON(k2.[value]) WITH
	(
	"BEVOEGD GEZAG NUMMER"									varchar(100)
	, "BRIN NUMMER"											varchar(100)
	, "COROPGEBIED CODE"										varchar(100)
	, "COROPGEBIED NAAM"										varchar(100)
	, "DENOMINATIE"											varchar(100)
	, "GEMEENTENAAM"											varchar(100)
	, "GEMEENTENUMMER"										varchar(100)
	, "HUISNUMMER-TOEVOEGING"								varchar(100)
	, "HUISNUMMER-TOEVOEGING CORRESPONDENTIEADRES"	varchar(100)
	, "INTERNETADRES"											varchar(100)
	, "NODAAL GEBIED CODE"									varchar(100)
	, "NODAAL GEBIED NAAM"									varchar(100)
	, "ONDERWIJSGEBIED CODE"								varchar(100)
	, "ONDERWIJSGEBIED NAAM"								varchar(100)
	, "ONDERWIJSSTRUCTUUR"									varchar(100)
	, "PLAATSNAAM"												varchar(100)
	, "PLAATSNAAM CORRESPONDENTIEADRES"					varchar(100)
	, "POSTCODE"												varchar(100)
	, "POSTCODE CORRESPONDENTIEADRES"					varchar(100)
	, "PROVINCIE"												varchar(100)
	, "RMC-REGIO CODE"										varchar(100)
	, "RMC-REGIO NAAM"										varchar(100)
	, "RPA-GEBIED CODE"										varchar(100)
	, "RPA-GEBIED NAAM"										varchar(100)
	, "STRAATNAAM"												varchar(100)
	, "STRAATNAAM CORRESPONDENTIEADRES"					varchar(100)
	, "TELEFOONNUMMER"										varchar(100)
	, "VESTIGINGSNAAM"										varchar(100)
	, "VESTIGINGSNUMMER"										varchar(100)
	, "WGR-GEBIED CODE"										varchar(100)
	, "WGR-GEBIED NAAM"										varchar(100)
	) w2
WHERE 1=1
	AND j.DataSource = 'DUO'
	AND j.ContentType = 'Data'
	AND j.Connector LIKE '02.-alle-vestigingen-vo'
--	AND k1.[key] = '@context'