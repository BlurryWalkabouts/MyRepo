CREATE TABLE [Dim].[CallResponseSLA]
(
	[Code]                  INT            NOT NULL,
	[Name]                  NVARCHAR (250) NULL,
	[ServiceWindow]         NVARCHAR (50)  NULL,
	[DayOfWeek]             SMALLINT       NULL,
	[SLAStartTime]          TIME (0)       NULL,
	[SLAEndTime]            TIME (0)       NULL,
	[CallResponseTimeValue] DECIMAL (9, 2) NULL,
	[CallResponseTimeRate]  DECIMAL (9, 2) NULL,
	[CallDurationValue]     DECIMAL (9, 2) NULL,
	[CallDurationRate]      DECIMAL (9, 2) NULL,
	CONSTRAINT [PK_CallResponseSLA] PRIMARY KEY CLUSTERED ([Code] ASC)
)