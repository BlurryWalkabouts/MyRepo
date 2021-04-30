-- https://www.red-gate.com/simple-talk/sql/t-sql-programming/patindex-workbench/

DECLARE @string varchar(50)
DECLARE @where int

-- Put in some sample text
SELECT @string=' " well, this is a surprise!" said Gertie. "Is it?"  '
SELECT @where = PATINDEX ('%[^A-Z]%', @string)

WHILE @where > 0 -- Not executed if no characters to remove
BEGIN
	SELECT @string = STUFF(@string, @where, 1, '') -- Remove trhe character
	SELECT @where = PATINDEX('%[^A-Z]%', @string)
END

SELECT @string
--wellthisisasurprisesaidGertieIsit