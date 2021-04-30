CREATE PROCEDURE [etl].[LoadDimContactPerson]
AS
BEGIN

-- Testdata: phone, mail, # randomized; linkedin deleted
-- Select only contactpersons from the customers in the test set

BEGIN TRY

BEGIN TRANSACTION

TRUNCATE TABLE Dim.ContactPerson

INSERT INTO
	Dim.ContactPerson
	(
	CustomerKey
	, ContactPerson
	, Jobtitle
	, Telephone_1
	, Telephone_2
	, Mail
	, Department
	, Responsibility
	, Gender
	, LinkedIN
	, #
	)
SELECT
	cp.CustomerKey
	, cp.ContactPerson
	, cp.Jobtitle
	, Telephone_1 = RIGHT('0000000000' + CAST (ABS(CHECKSUM(NEWID()) % 1000000000) AS varchar(9)), 10)
	, Telephone_2 = RIGHT('0000000000' + CAST (ABS(CHECKSUM(NEWID()) % 1000000000) AS varchar(9)), 10)
	, Mail = CAST(ABS(CHECKSUM(NEWID()) % 10000000) AS varchar(7)) + '@ogd.nl'
	, cp.Department
	, cp.Responsibility
	, cp.Gender
	, LinkedIN = ''
	, # = ABS(CHECKSUM(NEWID()) % 60)
FROM
	[$(LIFTDW)].Dim.ContactPerson cp
	INNER JOIN Dim.Customer c ON cp.CustomerKey = c.CustomerKey

EXEC etl.[Log] @@PROCID
COMMIT TRANSACTION

END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC etl.[Log] @@PROCID
END CATCH

END