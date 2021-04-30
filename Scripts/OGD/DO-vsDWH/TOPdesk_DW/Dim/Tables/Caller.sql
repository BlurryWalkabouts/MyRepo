CREATE TABLE [Dim].[Caller]
(
	[CallerKey]                INT            IDENTITY (1,1) NOT FOR REPLICATION,
	[SourceDatabaseKey]        INT            NOT NULL,
	[CallerName]               NVARCHAR (255) MASKED WITH (FUNCTION = 'default()') NULL,
	[CallerEmail]              NVARCHAR (255) MASKED WITH (FUNCTION = 'email()') NULL,
	[CallerTelephoneNumber]    NVARCHAR (255) MASKED WITH (FUNCTION = 'partial(3,"XXXXXXX",0)') NULL,
	[CallerTelephoneNumberSTD] VARCHAR (32)   NULL,
	[CallerMobileNumber]       NVARCHAR (255) NULL,
	[CallerMobileNumberSTD]    VARCHAR (32)   NULL,
	[Department]               NVARCHAR (255) NULL,
	[CallerBranch]             NVARCHAR (255) NULL,
	[CallerCity]               NVARCHAR (255) NULL,
	[CallerLocation]           NVARCHAR (255) NULL,
	[CallerRegion]             NVARCHAR (255) NULL,
	[CallerGender]             NVARCHAR (255) NULL,
	CONSTRAINT [PK_Caller] PRIMARY KEY CLUSTERED ([CallerKey] ASC)
)