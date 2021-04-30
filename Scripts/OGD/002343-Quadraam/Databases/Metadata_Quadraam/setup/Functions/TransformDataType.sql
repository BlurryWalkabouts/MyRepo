CREATE FUNCTION [setup].[TransformDataType]
(
	@DataType nvarchar(10)
	, @Length int
	, @Decimals int
)
RETURNS table
AS
RETURN
(

SELECT DataType = CASE @DataType
		WHEN 'blob' THEN 'nvarchar (max)'
		WHEN 'boolean' THEN 'bit'
		WHEN 'date' THEN CONCAT('datetime2 (', @Length, ')')
		WHEN 'decimal' THEN CONCAT('decimal (', @Length, ',', @Decimals, ')')
		WHEN 'int' THEN 'int'
		WHEN 'string' THEN CONCAT('nvarchar (', @Length, ')')
	END

)