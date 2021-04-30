CREATE PROCEDURE [etl].[ReplaceEmptyStrings]
(
	@debug bit = 0
)
AS

EXEC etl.ReplaceEmptyString 'Fact', 'Incident',      'Category',      'Geen',     @debug
EXEC etl.ReplaceEmptyString 'Fact', 'Incident',      'Subcategory',   'Geen',     @debug
EXEC etl.ReplaceEmptyString 'Fact', 'Incident',      'Status',        'Geen',     @debug
EXEC etl.ReplaceEmptyString 'Dim',  'OperatorGroup', 'OperatorGroup', 'Geen',     @debug
EXEC etl.ReplaceEmptyString 'Dim',  'Caller',        'CallerBranch',  'Onbekend', @debug
EXEC etl.ReplaceEmptyString 'Dim',  'Caller',        'CallerGender',  'Onbekend', @debug

RETURN 0

/*
EXEC [etl].[ReplaceEmptyStrings] 1
*/