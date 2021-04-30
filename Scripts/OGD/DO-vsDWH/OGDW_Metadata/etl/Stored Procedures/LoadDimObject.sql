CREATE PROCEDURE [etl].[LoadDimObject]
AS
BEGIN

/***************************************************************************************************
* Dim.Object
****************************************************************************************************
* 2017-01-13 * WvdS	* 
***************************************************************************************************/

SET NOCOUNT ON

BEGIN TRY

-- Declare variables for logging
DECLARE @newLogID int
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID
DECLARE @newMessage nvarchar(max) = 'Loading in progress...'
DECLARE @newRowCount int = 0

-- Start logging
EXEC [log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

DELETE FROM [$(OGDW)].Dim.[Object]
DBCC CHECKIDENT ('[$(OGDW)].Dim.[Object]', RESEED, 0)

-- Insert default line
SET IDENTITY_INSERT [$(OGDW)].Dim.[Object] ON
INSERT INTO
	[$(OGDW)].Dim.[Object] (ObjectKey, CallerKey, CustomerKey, SourceDatabaseKey, ObjectID)
VALUES
	(-1, -1, -1, -1, '[Onbekend]')
SET @newRowCount += @@ROWCOUNT
SET IDENTITY_INSERT [$(OGDW)].Dim.[Object] OFF

INSERT INTO
	[$(OGDW)].Dim.[Object]
	(
	CallerKey
	, CustomerKey
	, SourceDatabaseKey
	, ChangeDate
	, ChangeTime
	, ObjectID
	, Class
	, ObjectType
	, Model
	, PurchasePrice
	, PurchaseDate
	, PurchaseTime
	, Budgetholder
	, Supplier
	, SerialNumber
	, Contact
	, Attention
	, [Configuration]
	, [User]
	, [Group]
	, Hostname
	, IPAddress
	, LeaseStartDate
	, LeaseStartTime
	, LeaseContractNumber
	, LeaseEndDate
	, LeaseEndTime
	, LeasePeriod
	, LeasePrice
	, LicentieType
	, Comments
	, OrderNumber
	, Person
	, Staffgroup
	, City
	, ResidualValue
	, Room
	, Specification
	, [Status]
	, Branch
	)
SELECT
	CallerKey = -1 -- ISNULL(OB_CA.Caller_by_Id,-1)

	-- Voor Multi-klant topdesk in de FileImport staat de Customer in de kolom [CustomerName], deze staat in CH.CustomerName in het Anchormodel
	-- Voor Multi-klant topdesk in de database staat de Customer in [vestiging].[naam], deze staat in CH.CustomerName in het Anchormodel
	-- Voor Single-klant topdesk in de FileImport is de kolom [CustomerName] = NULL en wordt de naam dus opgehaald via SourceDefinition
	-- Voor Single-klant topdesk in de database bevat de kolom [vestiging].[naam] daadwerkelijk de vestiging; halen we de Customer dus op via SourceDefinition
	-- Via onderstaande regel zou altijd een CustomerKey gevonden moeten worden, tenzij er geen vertaling gedefinieerd is
	, CustomerKey = ISNULL(CAST(CASE
			WHEN SD.MultipleCustomers = 0 THEN C1.Code -- Klantnaam via SourceDefinition
			ELSE -1 -- ISNULL(C2.Code,-1) -- Klantnaam uit CustomerName veld, vertaald via SourceTranslation naar CustomerKey
		END AS int),-1) -- Bij gegevens uit de database moet deze key op een andere manier worden bepaald

	, OB.SourceDatabaseKey
	, OB.ChangeDate
	, OB.ChangeTime
	, OB.ObjectID
	, OB.Class
	, OB.ObjectType
	, OB.Model
	, OB.PurchasePrice
	, OB.PurchaseDate
	, OB.PurchaseTime
	, OB.Budgetholder
	, OB.Supplier
	, OB.SerialNumber
	, OB.Contact
	, OB.Attention
	, OB.[Configuration]
	, OB.[User]
	, OB.[Group]
	, OB.Hostname
	, OB.IPAddress
	, OB.LeaseStartDate
	, OB.LeaseStartTime
	, OB.LeaseContractNumber
	, OB.LeaseEndDate
	, OB.LeaseEndTime
	, OB.LeasePeriod
	, OB.LeasePrice
	, OB.LicentieType
	, OB.Comments
	, OB.OrderNumber
	, OB.Person
	, OB.Staffgroup
	, OB.City
	, OB.ResidualValue
	, OB.Room
	, OB.Specification
	, OB.[Status]
	, OB.Branch
FROM
	etl.Translated_Object OB
--	LEFT OUTER JOIN OGDW_AM.dbo.Current_Object_used_Caller_by OB_CA on OB.Object_Id = OB_CA.Object_used_Id	
--	OperatorKey volgt direct uit AM:
--	LEFT OUTER JOIN OGDW_AM.dbo.Current_Problem_handled_Operator_by OB_OP on OB.Object_Id = OB_OP.Object_handled_Id
	
--	CustomerKey
	LEFT OUTER JOIN setup.SourceDefinition SD ON OB.SourceDatabaseKey = SD.Code
	LEFT OUTER JOIN setup.DimCustomer C1 ON SD.DatabaseLabel = C1.[Name]

--	er zit geen [CustomerName] in Problem, waar halen we deze dan vandaan? (voor multi-klant-databases)
--	LEFT OUTER JOIN setup.SourceTranslation ST on OB.CustomerName = ST.SourceValue and ST.DWColumnName_Name = 'CustomerName' and TranslatedColumnName = 'CustomerAbbreviation' and SD.DatabaseLabel = ST.SourceName
--	LEFT OUTER JOIN setup.DimCustomer C2 on ST.TranslatedValue = C2.[Name]

-- TODO - Add indices:
	
SET @newRowCount += @@ROWCOUNT
COMMIT TRANSACTION

-- Logging of success
SET @newMessage = 'Loading successful...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = 'Loading FAILED...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END