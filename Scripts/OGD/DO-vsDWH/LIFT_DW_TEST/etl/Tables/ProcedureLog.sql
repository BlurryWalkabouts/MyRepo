CREATE TABLE [etl].[ProcedureLog]
(
	[Batch]   SMALLINT     NULL,
	[Time]    DATETIME2    NOT NULL,
	[Script]  VARCHAR(40)  NOT NULL,
	[Success] BIT          NOT NULL,
	[Message] VARCHAR(200) NOT NULL
)