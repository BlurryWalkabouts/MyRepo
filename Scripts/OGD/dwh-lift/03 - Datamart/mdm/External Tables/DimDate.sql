CREATE EXTERNAL TABLE [mdm].[DimDate]
(
    [ID] int NOT NULL,
    [Code] nvarchar(250) NOT NULL,
    [Holiday] decimal(38,0) NULL
)
WITH (
    DATA_SOURCE = [mds-source],
    SCHEMA_NAME = N'mdm',
    OBJECT_NAME = N'DimDate'
);
