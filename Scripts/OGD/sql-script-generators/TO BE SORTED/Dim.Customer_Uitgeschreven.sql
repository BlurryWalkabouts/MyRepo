USE [OGDW]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Dim].[Customer](
	[CustomerKey] [int] NOT NULL, -- <-- Moet dit niet CustomerId zijn?
	-- Customernumber  vanuit LIFT
	[CustomerNumber] [nvarchar](10) NULL, -- LIFT
	-- Customer FullName
	[Fullname] [nvarchar](100) NULL, -- LIFT
	-- Customer actief in LIFT
	[CustomerActive] [bit] NULL, -- LIFT
	-- Klant TOPdeskkoppeling actief?
	[TOPdeskActive] [bit] NULL, -- MDS
	-- Adresgegevens
	[Postcode] [nvarchar](15) NULL, -- LIFT
	[Address] [nvarchar](70) NULL, -- LIFT
	[City] [nvarchar](30) NULL, -- LIFT
	[Country] [nvarchar](30) NULL, -- LIFT
	[TelephoneNumber] [nvarchar](100) NULL, -- LIFT
	-- Sector/Branche waarin de klant actief is
	[Sector] [nvarchar](100) NULL, -- MDS
	[SubSector] [nvarchar](100) NULL, -- MDS
	-- Grootte van de klant
	[CustomerCompanySize] [nvarchar](25) NULL,
	-- Regiemodel
	[ServiceDeliveryManager] [nvarchar](100) NULL, -- LIFT / CM Sharepoint
	[AccountManagerKey] [int] NOT NULL, -- LIFT
	[AccountManager] [nvarchar](255) NULL, -- LIFT
	[OutsourcingType] [nvarchar](100) NULL, -- Welke Type Outsourcing wordt afgenomen (EO, MKBO, 1CT, etc.)
	[ServicesType] [nvarchar](100) NULL, -- Welke service type <-- Enterprise / MKB <-- MDS
	[ServiceDeskServiceType] [nvarchar](250) NULL, -- SSD / SOL?
	[SysAdminServiceType] [nvarchar](250) NULL, -- Beheerteam?
	[CustomerTeam] [nvarchar](255) NULL, -- Klantenteam
	[SysAdminTeam] [nvarchar](255) NULL, -- Beheerteam
	[ServiceDeskTeam] [nvarchar](255) NULL, -- SSD Team
	[SLA] [nvarchar](250) NULL, -- SLA Naam
	-- Vanuit Contract Management
	[Service_SSD] [bit] NULL, -- Neemt SSD af
	[Service_EO] [bit] NULL, -- Neemt Enterprise Outsourcing af
	[Service_Connectivity] [bit] NULL, -- Neemt connectiviteit af
	[Service_Dev] [bit] NULL, -- Neemt BUS af
	[Service_Consultancy] [bit] NULL, -- Neemt Advies af
	[Service_Detachering] [bit] NULL, -- Neemt Deta af
	[Service_CoSo] [bit] NULL, -- Neemt Co-Sourcing af
	[Service_MKBO] [bit] NULL, -- Neemt MKBO
	[Service_1CT] [bit] NULL, -- Neemt 1ICT af
	[Service_Reselling] [bit] NULL, -- Neem THS af
	[Service_Projects] [bit] NULL, -- Neemt BTP af
	[Service_IaaS] [bit] NULL, -- Neemt IAAS af
	[Service_SOL] [bit] NULL, -- Neemt Servicedesk op Locatie af
	[Service_ConfigManagement] [bit] NULL, -- Neem ITAM af
	-- Compliancy vereisten
	[Compliance_ISO27001] [bit] NULL,
	[Compliance_ISAE3000] [bit] NULL,
	[Compliance_TPM] [bit] NULL,
	[Compliance_COBIT] [bit] NULL,

	[ManagementModel] [bit] NULL,
	-- Vanuit CM/LIFT
	[ContractManager] [nvarchar](255) NULL,
	[ContractOwner] [nvarchar](255) NULL,
	-- Vanuit MDS
	[ExpIncLoad] [int] NULL,
	[ExpChaLoad] [int] NULL,
	[ExpCallLoad] [int] NULL,
	-- Weekend piketdienst
	[SupportWeekend] [bit] NULL,
	-- Van BI&R
	[RequiredSecurityClearance] [nvarchar](250) NULL,
	[SupportWindow] [nvarchar](250) NULL,
	[SupportWindow_ID] [int] NULL,
	-- FTE waarden, MDS
	[Contract_Users] [int] NULL,
	[Contract_FTE] [int] NULL,
	[Contract_Seats] [smallint] NULL,
	[HasOnCallService] [bit] NULL, -- Piketdienst
	[IsArchived] [bit] NULL, -- Gearchiveerd in DWH
	[OnBoardDate] [datetime2](3) NULL,
	[OffBoardDate] [datetime2](3) NULL,
	[LIFT_unid] [uniqueidentifier] NULL,
	[ValidFrom] [datetime2](3) NULL,
	[ValidTo] [datetime2](3) NULL,
	[IsCurrent]  AS (case when [ValidFrom]<=getutcdate() AND [ValidTo]>=getutcdate() then (1) else (0) end),
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[CustomerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO

ALTER TABLE [Dim].[Customer] ADD  CONSTRAINT [DF__Customer__Custom__208CD6FA]  DEFAULT ((0)) FOR [CustomerActive]
GO


