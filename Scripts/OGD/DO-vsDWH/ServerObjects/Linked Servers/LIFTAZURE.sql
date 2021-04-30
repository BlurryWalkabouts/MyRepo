EXEC sp_addlinkedserver
	@server = N'LIFTAZURE'
	, @srvproduct = N'SQL Server'
	, @provider = N'SQLNCLI11'
	, @datasrc = N'ogd-euw-sqi-ogd-prd-top-01.database.windows.net'
	, @provstr = N'ApplicationIntent=ReadOnly;Database=ogd_euw_sqd_ogd_prd_lft_01'
GO