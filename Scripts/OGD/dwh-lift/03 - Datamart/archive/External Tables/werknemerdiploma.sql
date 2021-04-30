CREATE EXTERNAL TABLE [archive].[werknemerdiploma] (
    [unid]            uniqueidentifier                                  NOT NULL,
    [werknemerid]     uniqueidentifier                                  NULL,
    [diplomaid]       uniqueidentifier                                  NULL,
    [expiration_date] datetime                                          NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'werknemerdiploma'
);
