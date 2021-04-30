CREATE PROCEDURE [etl].[LoadDimAccountManager]
AS
BEGIN

-- Test data: about 100 records which represent OGD employees. No need to anonymize anything here.

BEGIN TRY

BEGIN TRANSACTION

TRUNCATE TABLE Dim.AccountManager

INSERT INTO
	Dim.AccountManager
	(
	AccountManagerKey
	, unid
	, AccountManagerName
	, Archive
	, [Status]
	, CreationDate
	, ChangeDate
	)
SELECT
	AccountManagerKey
	, unid
	, AccountManagerName
	, Archive
	, [Status]
	, CreationDate
	, ChangeDate
FROM
	[$(LIFTDW)].Dim.AccountManager

EXEC etl.[Log] @@PROCID
COMMIT TRANSACTION

END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC etl.[Log] @@PROCID
END CATCH

END