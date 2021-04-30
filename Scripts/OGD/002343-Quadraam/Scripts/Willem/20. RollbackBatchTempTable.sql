BEGIN TRANSACTION
EXEC Metadata_Quadraam.shared.DisableVersioning 'Metadata_Quadraam','setup','MetadataAfas'

INSERT INTO Metadata_Quadraam.setup.MetadataAfas
SELECT * FROM Metadata_Quadraam.history.MetadataAfas WHERE ValidTo = '2017-10-23 10:01:01'
DELETE FROM Metadata_Quadraam.history.MetadataAfas WHERE ValidTo = '2017-10-23 10:01:01'
UPDATE Metadata_Quadraam.setup.MetadataAfas SET ValidTo = '9999-12-31 23:59:59' WHERE ValidTo = '2017-10-23 10:01:01'

SELECT *, ValidFrom, ValidTo FROM Metadata_Quadraam.setup.MetadataAfas --FOR SYSTEM_TIME ALL
ORDER BY ValidFrom DESC

EXEC Metadata_Quadraam.shared.EnableVersioning 'Metadata_Quadraam','setup','MetadataAfas'
ROLLBACK TRANSACTION
COMMIT TRANSACTION