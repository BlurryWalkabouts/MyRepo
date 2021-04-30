﻿CREATE TABLE [Dim].[Diploma]
(
	[DiplomaKey] INT              IDENTITY (90000000, 1) NOT FOR REPLICATION,
	[unid]       UNIQUEIDENTIFIER NULL,
	[Diploma]    NVARCHAR (25)    NULL,
	CONSTRAINT [PK_Diploma] PRIMARY KEY CLUSTERED ([DiplomaKey] ASC)
)