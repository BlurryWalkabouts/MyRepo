CREATE MASTER KEY;
GO

CREATE DATABASE SCOPED CREDENTIAL sa_ogd_aanvragen
WITH IDENTITY = 'sa_ogd_aanvragen', 
SECRET = '347y9teohrkvnergy8345othagw4o7n38!!e324r2rfewf324';
GO

CREATE EXTERNAL DATA SOURCE [LIFT]
WITH
(
	TYPE=RDBMS,
	LOCATION='ogd-replica-001013.database.windows.net',
	DATABASE_NAME='lift',
	CREDENTIAL=sa_ogd_aanvragen
);

create schema LIFT;
GO

IF OBJECT_ID('LIFT.open_aanvragen') IS NOT NULL DROP EXTERNAL TABLE [LIFT].[open_aanvragen]
GO
CREATE EXTERNAL TABLE [LIFT].[open_aanvragen]
(
	[unid] [uniqueidentifier] NOT NULL,
	[aanvraagnr] [nvarchar](20)  NOT NULL,
	[dataanmk] [datetime] NULL,
	[datwijzig] [datetime] NULL,
	[AanvraagStatus] [int] NOT NULL,
	[VerwachteWinkans] [int]NULL,
	[IsVervolgAanvraag] [bit] NOT NULL,
	[Werktitel] [nvarchar](70) NULL,
	[Functie] [nvarchar](30) NULL,
	[StartDatum] [datetime] NULL,
	[EindDatum] [datetime] NULL,
	[ChangeDate] [datetime] NULL,
	[Projectstatus] [int]NULL,
	[BusinessUnit] [nvarchar](30) NULL,
	[omzetdoel_project] [money]NULL,
	[omzetdoel_aanvraag] [money] NOT NULL,
	[Behandelaar] [nvarchar](62) NULL,
	[BehandelaarEmail] [nvarchar](75) NULL,
	[BehandelaarTelefoon] [nvarchar](25) NULL,
	[Klantnaam] [nvarchar](60) NULL,
	[LocatieKlant] [nvarchar](30) NULL,
	[Opdracht] [nvarchar](MAX) NULL,
	[Projectaanpak] [nvarchar](MAX) NULL,
	[Aanvraagaanpak] [nvarchar](MAX) NULL
)
WITH (DATA_SOURCE = [LIFT], Schema_name='aanvragen_ogd_nl', object_name='open_aanvragen')

