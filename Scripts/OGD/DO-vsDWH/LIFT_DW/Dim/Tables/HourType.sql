CREATE TABLE [Dim].[HourType]
(
	[HourTypeKey] INT              IDENTITY (50000000, 1) NOT FOR REPLICATION,
	[Percentage]  DECIMAL(19,4)    NULL,
	[Billable]    BIT              NULL,
	[RateName]    NVARCHAR (30)    NULL, 
	CONSTRAINT [PK_HourType] PRIMARY KEY CLUSTERED (HourTypeKey)
)