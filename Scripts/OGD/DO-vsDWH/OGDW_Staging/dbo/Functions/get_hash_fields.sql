CREATE function [dbo].[get_hash_fields] (@p_schema_name VARCHAR(20), @p_table_name VARCHAR(100))
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @sqlString as varchar(max)
    SET @sqlString = ''

    
    SELECT @sqlString = @sqlString +
      CASE DATA_TYPE 
      WHEN 'int' THEN 'ISNULL(RTRIM(CONVERT(varchar(10),' + COLUMN_NAME + ')),'''')'
      WHEN 'datetime' THEN 'ISNULL(RTRIM(CONVERT(varchar(10),' + COLUMN_NAME + ',112)),'''')'  
      WHEN 'datetime2' THEN 'ISNULL(RTRIM(CONVERT(varchar(10),' + COLUMN_NAME + ',112)),'''')'
      WHEN 'date' THEN 'ISNULL(RTRIM(CONVERT(varchar(10),' + COLUMN_NAME + ',112)),'''')' 
      WHEN 'bit' THEN 'ISNULL(RTRIM(CONVERT(varchar(1),' + COLUMN_NAME + ')),'''')'  
      WHEN 'decimal' THEN 'ISNULL(RTRIM(CONVERT(varchar('+ CONVERT(varchar(2),NUMERIC_PRECISION) +'),' + COLUMN_NAME + ')),'''')' 
      ELSE 'ISNULL(RTRIM(' + COLUMN_NAME + '),'''') collate Latin1_General_CI_AS '
      END + '+'
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @p_schema_name and TABLE_NAME = @p_table_name
    AND COLUMN_NAME NOT IN ('load_dts','load_cycle_id','period','checksum')

                                
    RETURN LEFT(ISNULL(@sqlString, ''),LEN(@sqlString)-1)
END  
