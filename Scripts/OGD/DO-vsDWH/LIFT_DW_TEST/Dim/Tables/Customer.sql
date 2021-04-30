CREATE TABLE [Dim].[Customer]
(
	[CustomerKey]            INT              NOT NULL,
	[AccountManagerKey]      INT              NOT NULL,
	[unid]                   UNIQUEIDENTIFIER NULL,
	[CustomerDebitNumber]    NVARCHAR (25)    NULL,
	[CustomerFullname]       NVARCHAR (60)    NULL,
	[CustomerPostcode]       NVARCHAR (15)    NULL,
	[CustomerAddress]        NVARCHAR (70)    NULL,
	[CustomerCity]           NVARCHAR (30)    NULL,
	[CustomerCountry]        NVARCHAR (30)    NULL,
	[CustomerCompanySize]    NVARCHAR (25)    NULL,
	[ServiceDeliveryManager] NVARCHAR (100)   NULL,
	[CustomerActive]         BIT              NULL,
	CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED ([CustomerKey] ASC),
--	CONSTRAINT [FK_Customer_AccountManager] FOREIGN KEY ([AccountManagerKey]) REFERENCES Dim.[AccountManager] ([AccountManagerKey])
)