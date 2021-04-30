CREATE TABLE [Fact].[Telefoniestoringen]
(
	[Code]               INT            NOT NULL,
	[StartDateKey]       INT            NOT NULL,
	[EndDateKey]         INT            NOT NULL,
	[StartTimeKey]       INT            NOT NULL,
	[EndTimeKey]         INT            NOT NULL,
	[Name]               NVARCHAR (250) NULL,
	[Classificatie_Name] NVARCHAR (250) NULL,
	[Oorzaak_Name]       NVARCHAR (250) NULL,
	[Start]              DATETIME2 (3)  NOT NULL,
	[Eind]               DATETIME2 (3)  NOT NULL,
	CONSTRAINT [PK_Telefoniestoringen] PRIMARY KEY CLUSTERED ([Code] ASC)
)