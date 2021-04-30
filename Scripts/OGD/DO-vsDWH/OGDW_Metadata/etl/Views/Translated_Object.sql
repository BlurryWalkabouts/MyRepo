CREATE VIEW [etl].[Translated_Object]
AS
SELECT
	SourceDatabaseKey
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
FROM
	etl.Translation_step1_Object T
	LEFT OUTER JOIN setup.SourceDefinition SD ON SD.Code = T.SourceDatabaseKey