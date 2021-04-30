CREATE PROCEDURE [etl].[LoadDimService]
AS
BEGIN

-- Test data: about 150 records which represent OGD departments. No need to anonymize anything here.

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE Dim.[Service]

INSERT INTO
	Dim.[Service]
	(
	ServiceKey
	, ProductNomination
	)
SELECT
	ServiceKey
   , ProductNomination
FROM
	[$(LIFTDW)].Dim.[Service]

EXEC etl.[Log] @@PROCID
COMMIT TRANSACTION

END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC etl.[Log] @@PROCID
END CATCH

END