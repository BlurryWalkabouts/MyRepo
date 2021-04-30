CREATE TABLE [Dim].[ContactPerson]
(
	[ContactPersonKey] INT              IDENTITY (140000000, 1) NOT FOR REPLICATION,
	[unid]             UNIQUEIDENTIFIER NULL,
	[CustomerKey]      INT              NOT NULL,
	[ContactPerson]    NVARCHAR (100)   NULL,
	[Jobtitle]         NVARCHAR (50)    NULL,
	[Telephone_1]      NVARCHAR (25)    NULL,
	[Telephone_2]      NVARCHAR (25)    NULL,
	[Mail]             NVARCHAR (75)    NULL,
	[Department]       NVARCHAR (60)    NULL,
	[Responsibility]   NVARCHAR (100)   NULL,
	[Gender]           NVARCHAR (10)    NULL,
	[LinkedIN]         NVARCHAR (250)   NULL,
	[#]                INT              NULL,
	[Role]             NVARCHAR (30)    NULL,
	CONSTRAINT [PK_ContactPerson] PRIMARY KEY CLUSTERED ([ContactPersonKey]),
	CONSTRAINT [FK_ContactPerson_CustomerKey] FOREIGN KEY ([CustomerKey]) REFERENCES [Dim].[Customer] ([CustomerKey])
)