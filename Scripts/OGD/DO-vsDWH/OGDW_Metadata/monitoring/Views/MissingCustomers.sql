CREATE VIEW [monitoring].[MissingCustomers]
AS

SELECT DISTINCT
	TranslatedValue
FROM
	setup.SourceTranslation
WHERE 1=1
	AND DWColumnName = 'CustomerName'
	AND TranslatedValue <> '[Onbekend]'
	AND TranslatedValue NOT IN (SELECT [Name] FROM setup.DimCustomer)