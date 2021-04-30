USE Metadata_Quadraam;
GO

/*
EXEC shared.DisableVersioning 'Metadata_Quadraam','setup','MetadataAfas'
TRUNCATE TABLE setup.MetadataAfas
TRUNCATE TABLE history.MetadataAfas
EXEC shared.EnableVersioning 'Metadata_Quadraam','setup','MetadataAfas'

EXEC setup.LoadMetadataAfas @debug = 1
EXEC setup.CreateStagingTablesAfas @debug = 1
SELECT * FROM setup.MetadataAfas
--*/

SELECT
	*
	, ValidFrom = ValidFrom AT TIME ZONE 'UTC' AT TIME ZONE 'Central Europe Standard Time'
	, ValidTo = CASE
			WHEN ValidTo = '9999-12-31 23:59:59' THEN ValidTo AT TIME ZONE 'UTC'
			ELSE ValidTo AT TIME ZONE 'UTC' AT TIME ZONE 'Central Europe Standard Time'
		END
FROM
	setup.MetadataAfas FOR SYSTEM_TIME ALL
ORDER BY
	Connector
	, ID
	, ValidFrom