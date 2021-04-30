CREATE TABLE [Dim].[ContactPerson]
(
	[CustomerKey]    INT            NOT NULL,
	[ContactPerson]  NVARCHAR (100) NULL,
	[Jobtitle]       NVARCHAR (50)  NULL,
	[Telephone_1]    NVARCHAR (25)  NULL,
	[Telephone_2]    NVARCHAR (25)  NULL,
	[Mail]           NVARCHAR (75)  NULL,
	[Department]     NVARCHAR (60)  NULL,
	[Responsibility] NVARCHAR (100) NULL,
	[Gender]         NVARCHAR (10)  NULL,
	[LinkedIN]       NVARCHAR (250) NULL,
	[#]              INT            NULL,
--	CONSTRAINT [FK_ContactPerson_CustomerKey] FOREIGN KEY ([CustomerKey]) REFERENCES Dim.[Customer] ([CustomerKey])
)