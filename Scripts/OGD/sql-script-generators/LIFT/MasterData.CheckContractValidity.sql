CREATE FUNCTION [usr].[IsContractEnded] -- must be defined in usr schema
 (@Value DATETIME2) -- pass along an attribute of the datetime data type
RETURNS BIT
AS
BEGIN

	IF @Value < CONVERT(DATE, SWITCHOFFSET(SYSUTCDATETIME(), DATEPART(TZOFFSET,  SYSUTCDATETIME() AT TIME ZONE 'Central European Standard Time')))
	BEGIN
		RETURN 1;
	END
	RETURN 0; -- Contract is still valid
END