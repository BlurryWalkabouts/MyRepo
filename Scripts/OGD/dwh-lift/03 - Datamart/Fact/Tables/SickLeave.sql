CREATE TABLE [Fact].[SickLeave]
(
	[BusinessUnit]                   NVARCHAR(35)               NULL,
	[Function]                       NVARCHAR(35)               NULL,
	[LedgerNumber]                   NVARCHAR(10)               NULL,	
	[Ledger]                         NVARCHAR(30)               NULL,	
	[Office]                         NVARCHAR(40)               NULL,	
	[ProductGroup]                   NVARCHAR(30)               NULL,	
	[UurtypeSTD]                     NVARCHAR(70)               NULL,	
	[DWMonthNumber]                  SMALLINT                   NULL,
	[EmpCount]                       SMALLINT                   NOT NULL,
	[HoursWritten]                   DECIMAL(12,8)              NOT NULL,
)
