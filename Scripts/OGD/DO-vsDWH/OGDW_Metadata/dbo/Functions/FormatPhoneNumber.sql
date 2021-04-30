CREATE FUNCTION [dbo].[FormatPhoneNumber]
(
	@PhoneNumber varchar(32)
)
RETURNS varchar(32)
AS
BEGIN

DECLARE @Phone char(32)

SET @Phone = @PhoneNumber
	
-- Negeer lege velden
IF @PhoneNumber IS NULL OR @PhoneNumber = ''
	RETURN NULL

-- Gedeelte achter [/\|;,] verwijderen (eventueel later aanpassen zodat we hier wat mee doen)
IF PATINDEX('%[/\|;,]%', @PhoneNumber) > 0
	SET @PhoneNumber = LEFT(@PhoneNumber, PATINDEX('%[/\|;,]%', @PhoneNumber) - 1)

-- Negeer te korte nummers
IF LEN(@PhoneNumber) < 10 AND LEN(@PhoneNumber) NOT IN (3,4,5)
	RETURN NULL

-- Gedeelte tussen haakjes verwijderen indien aan het eind
IF CHARINDEX('(', @PhoneNumber) > 0 AND CHARINDEX(')', @PhoneNumber) = LEN(@PhoneNumber) AND LEN(@PhoneNumber) > 13
	SET @PhoneNumber = LEFT(@PhoneNumber, CHARINDEX('(', @PhoneNumber) - 1)

-- Alle niet-numerieke tekens verwijderen
WHILE PATINDEX('%[^0-9+]%', @PhoneNumber) > 0
	SET @PhoneNumber = REPLACE(@PhoneNumber, SUBSTRING(@PhoneNumber, PATINDEX('%[^0-9+]%', @PhoneNumber), 1), '')

-- Negeer buitenlandse nummers
IF SUBSTRING(@PhoneNumber,1,2) = '00' AND SUBSTRING(@PhoneNumber,1,4) <> '0031'
	RETURN NULL
IF SUBSTRING(@PhoneNumber,1,1) = '+' AND SUBSTRING(@PhoneNumber,1,3) <> '+31' AND SUBSTRING(@PhoneNumber,1,4) <> '+ 31'
	RETURN NULL

-- Landcode verwijderen
IF SUBSTRING(@PhoneNumber,1,3) = '+31'
	SET @PhoneNumber = RIGHT(@PhoneNumber, LEN(@PhoneNumber) - 3)
IF SUBSTRING(@PhoneNumber,1,4) = '+ 31'
	SET @PhoneNumber = RIGHT(@PhoneNumber, LEN(@PhoneNumber) - 4)
IF SUBSTRING(@PhoneNumber,1,4) = '0031'
	SET @PhoneNumber = RIGHT(@PhoneNumber, LEN(@PhoneNumber) - 4)
IF SUBSTRING(@PhoneNumber,1,2) = '31' AND LEN(@PhoneNumber) > 10
	SET @PhoneNumber = RIGHT(@PhoneNumber, LEN(@PhoneNumber) - 2)
IF SUBSTRING(@PhoneNumber,1,3) = '031' AND LEN(@PhoneNumber) > 11
	SET @PhoneNumber = RIGHT(@PhoneNumber, LEN(@PhoneNumber) - 3)

-- Verkorte nummers cq doorkiesnummers (zie ook TODO)
IF LEN(@PhoneNumber) IN (3,4,5) AND SUBSTRING(@PhoneNumber,1,1) <> '0'
	RETURN @PhoneNumber

-- Indien er geen numerieke tekens overblijven NULL teruggeven
IF @PhoneNumber = ''
	RETURN NULL

-- Aangepast: we geven +31 terug ipv 0031, want zo staat het in de sips opgezocht moeten worden
-- +31 toevoegen, evt extra 0 verwijderen
IF SUBSTRING(@PhoneNumber,1,1) = '0'
	SET @PhoneNumber = '+31' + RIGHT(@PhoneNumber, LEN(@PhoneNumber) - 1)
ELSE
	SET @PhoneNumber = '+31' + RIGHT(@PhoneNumber, LEN(@PhoneNumber))

-- Negeer foute resultaten
IF LEN(@PhoneNumber) <> 12
	RETURN NULL

RETURN @PhoneNumber

END

/*
SELECT * FROM Dim.[Caller] WHERE ISNULL(CallerTelephoneNumber,'') <> '' AND CallerTelephoneNumberSTD IS NULL
SELECT COUNT(*) FROM Dim.[Caller]

TODO:
- 4 cijferige nummers omschrijven aan de hand van bekende Source / customer.
- buitenlandse nummers?
*/

-- SELECT *, [dbo].[FormatTelefoonNummer](CallerTelephoneNumber) FROM dim.caller
-- SELECT *, [dbo].[FormatTelefoonNummer](CallerMobileNumber) FROM dim.caller