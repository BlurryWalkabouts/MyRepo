CREATE TABLE [Dim].[Customer]
(
	[CustomerKey]               INT            NOT NULL,
	[DebitNumber]               NVARCHAR (10)  NULL,
	[Fullname]                  NVARCHAR (100) NULL,
	[CustomerSector]            NVARCHAR (100) NULL,
	[CustomerGroup]             NVARCHAR (250) NULL,
	[SLA]                       NVARCHAR (250) NULL,
	[EndUserServiceType]        NVARCHAR (250) NULL,
	[SysAdminServiceType]       NVARCHAR (250) NULL,
	[SysAdminTeam]              NVARCHAR (250) NULL,
	[OutsourcingType]           NVARCHAR (100) NULL,
	[ServicesType]              NVARCHAR (100) NULL,
	[ExpIncLoad]                DECIMAL (38)   NULL,
	[ExpChaLoad]                DECIMAL (38)   NULL,
	[ExpCallLoad]               DECIMAL (38)   NULL,
	[SupportWeekend]            DECIMAL (38)   NULL,
	[RequiredSecurityClearance] NVARCHAR (250) NULL,
	[Postcode]                  NVARCHAR (100) NULL,
	[SupportWindow]             NVARCHAR (250) NULL,
	[SupportWindow_ID]          INT            NULL,
	[TelephoneNumber]           NVARCHAR (100) NULL,
	[AantalGebruikers]          SMALLINT       NULL,
	[AantalWerkplekken]         SMALLINT       NULL,
	[Piketdienst]               BIT            NULL,
	[Archived]                  DECIMAL (38)   NULL,
	[OnBoardDate]               DATETIME2 (3)  NULL,
	[OffBoardDate]              DATETIME2 (3)  NULL,
	[ValidFrom]                 DATETIME2 (3)  NULL,
	[ValidTo]                   DATETIME2 (3)  NULL,
	CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED ([CustomerKey] ASC)
)
GO

CREATE NONCLUSTERED INDEX [IX_Customer_CustomerGroup]
	ON [Dim].[Customer] ([CustomerGroup] ASC)
GO