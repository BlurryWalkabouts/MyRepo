CREATE PROCEDURE [monitoring].[uspCheckMissingAnywhereCustomerIds]
(
	@recipients nvarchar(max) = 'arnold.alberts@ogd.nl;yakup.cekici@ogd.nl' --'arnold.alberts@ogd.nl;sabine.verdaasdonk@ogd.nl;rapportage@ogd.nl'
)
AS

BEGIN

-- DECLARE @recordCount int 
-- COUNTER -- IF (@recordCount > 0)

DECLARE @body nvarchar(max)

;WITH neg_custkey AS
(
SELECT
	OGDWtable = 'Fact.call'
	, id = x.CallSummaryID
	, SourceDatabaseKey = sdk.CA_SDK_Caller_SourceDatabaseKey
	, x.CustomerKey
FROM
	[$(OGDW)].Fact.[Call] x
	JOIN [$(OGDW_AM)].dbo.CA_SDK_Caller_SourceDatabaseKey sdk ON sdk.CA_SDK_CA_ID = x.CallSummaryID
WHERE 1=1
	AND x.customerkey = '-1'
)

SELECT @body = '
<table cellpadding="5" cellspacing="0" border="1">
	<tr>
		<th>OGDWtable</th>
		<th>Customer</th>
		<th>SourceDatabaseKey</th>
		<th>CustumorKey_cnt</th>
	</tr>
	' + (
	SELECT
		OGDWtable
		, Customer = SD.DatabaseLabel
		, SourceDatabaseKey
		, CustomerKey_cnt = SUM(CustomerKey *-1)
	FROM
		neg_custkey
		LEFT JOIN setup.SourceDefinition SD ON SD.Code = neg_custkey.SourceDatabaseKey
	GROUP BY
		OGDWtable
		, SD.DatabaseLabel
		, SourceDatabaseKey
	ORDER BY
		OGDWtable
		, SourceDatabaseKey
	FOR XML RAW('tr'), ELEMENTS
	) + '
</table>'

EXEC msdb.dbo.sp_send_dbmail
	@profile_name = 'DBA Alerts'
	, @recipients = @recipients
	, @subject = 'MissingCustomerkeys'
	, @body = @body
	, @body_format = 'HTML'

END