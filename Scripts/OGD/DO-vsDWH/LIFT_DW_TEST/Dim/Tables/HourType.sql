CREATE TABLE [Dim].[HourType]
(
	[HourTypeKey] INT           NOT NULL,
	[Percentage]  DECIMAL(19,4) NULL,
	[Billable]    BIT           NULL,
	[RateName]    NVARCHAR (30) NULL,
	CONSTRAINT [PK_HourType] PRIMARY KEY CLUSTERED (HourTypeKey)
)