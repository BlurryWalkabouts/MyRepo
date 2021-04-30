CREATE FUNCTION setup.RemoveNonAlphaCharacters
(
	@String varchar(1000)
)
RETURNS varchar(1000)
AS
BEGIN

DECLARE @KeepValues AS varchar(10) = '%[^a-z]%'

WHILE PATINDEX(@KeepValues, @String) > 0
	SET @String = STUFF(@String, PATINDEX(@KeepValues, @String), 1, '')

RETURN @String
END