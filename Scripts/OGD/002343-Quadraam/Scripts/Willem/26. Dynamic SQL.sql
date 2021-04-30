DECLARE @custid   nchar(5)     = NULL
DECLARE @shipname nvarchar(40) = NULL
DECLARE @sql nvarchar(max)

SELECT @sql = ' SELECT 1 a ' +
              ' WHERE 1 = 1 '
IF @custid IS NOT NULL
   SELECT @sql = @sql + ' AND CustomerID LIKE ''' + @custid + ''''
IF @shipname IS NOT NULL
   SELECT @sql = @sql + ' AND ShipName LIKE ''' + @shipname + ''''
EXEC(@sql)
GO

DECLARE @custid   nchar(5) = 'x'
DECLARE @shipname nvarchar(40) = 'y'
DECLARE @sql nvarchar(max)
DECLARE @SQLString nvarchar(max)

SELECT @sql = 'SELECT @SQLString = N'' SELECT 1 a' +
              ' WHERE 1 = 1 '
IF @custid IS NOT NULL
   SELECT @sql = @sql + ' AND CustomerID LIKE @custid '
IF @shipname IS NOT NULL
   SELECT @sql = @sql + ' AND ShipName LIKE @shipname '''

EXEC sp_executesql @sql, N'@custid nchar(5), @shipname nvarchar(40), @SQLString nvarchar(max) OUTPUT',
                   @custid, @shipname, @SQLString OUTPUT

PRINT @SQLString