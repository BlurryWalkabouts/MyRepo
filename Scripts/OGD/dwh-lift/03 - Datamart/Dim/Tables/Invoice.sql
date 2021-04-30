CREATE TABLE [Dim].[Invoice]
(
	[InvoiceKey]					INT					IDENTITY (15000000, 1) NOT FOR REPLICATION,
	[InvoiceSourceId]				UNIQUEIDENTIFIER	NULL,
	[InvoiceNumber]					NVARCHAR (20)		NOT NULL, -- Datatype is the same as in source
	[InvoiceCustomerKey]			INT					NOT NULL,
	[InvoiceProjectKey]				INT					NOT NULL,
	[InvoiceAmountExVat]			DECIMAL (19, 2)		NOT NULL, -- needs to be at least DECIMAL (11, 2). This uses the same amount of storage.
	[InvoiceVat]					DECIMAL (19, 2)		NOT NULL, -- needs to be at least DECIMAL (10, 2). This uses the same amount of storage.
	[InvoiceAmountIncVat]			DECIMAL (19, 2)		NOT NULL, -- needs to be at least DECIMAL (11, 2). This uses the same amount of storage.
	[InvoiceDatePeriodStarted]		DATE				NOT NULL,
	[InvoiceDatePeriodEnded]		DATE				NOT NULL,
	[InvoiceDateDocumentCreated]	DATE				NOT NULL,
	[InvoiceDueTermInDays]			SMALLINT			NOT NULL,
	[InvoiceDocumentId]				UNIQUEIDENTIFIER	NULL,
	CONSTRAINT [PK_Invoice]						PRIMARY KEY CLUSTERED	([InvoiceKey] ASC),
	CONSTRAINT [FK_Invoice_CustomerKey]			FOREIGN KEY				([InvoiceCustomerKey])			REFERENCES [Dim].[Customer]	([CustomerKey]),
	CONSTRAINT [FK_Invoice_ProjectKey]			FOREIGN KEY				([InvoiceProjectKey])			REFERENCES [Dim].[Project]	([ProjectKey]),
	CONSTRAINT [FK_Invoice_DatePeriodStarted]	FOREIGN KEY				([InvoiceDatePeriodStarted])	REFERENCES [Dim].[Date]	([Date]),
	CONSTRAINT [FK_Invoice_DatePeriodEnded]		FOREIGN KEY				([InvoiceDatePeriodEnded])		REFERENCES [Dim].[Date]	([Date]),
	CONSTRAINT [FK_Invoice_DateDocumentBooked]	FOREIGN KEY				([InvoiceDateDocumentCreated])	REFERENCES [Dim].[Date]	([Date])
)