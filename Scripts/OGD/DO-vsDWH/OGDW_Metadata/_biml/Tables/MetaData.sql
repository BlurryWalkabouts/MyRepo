CREATE TABLE [FileImport].[MetaData]
(
	[MetaDataID]       INT            IDENTITY (1,1) NOT FOR REPLICATION,
	[AuditDWKey]       INT            NOT NULL,
	[ColumnName]       NVARCHAR (255) NOT NULL,
	[DataType]         NVARCHAR (255) NULL,
	[CharacterLength]  INT            NULL,
	[NumericPrecision] INT            NULL,
	[OrdinalPosition]  INT            NULL,
	[TableName]        NVARCHAR (255) NULL,
	[ExcelFilePath]    NVARCHAR (255) NULL,
	CONSTRAINT [PK_MetaData] PRIMARY KEY CLUSTERED ([AuditDWKey] DESC, [ColumnName] ASC, [MetaDataID] ASC)
)