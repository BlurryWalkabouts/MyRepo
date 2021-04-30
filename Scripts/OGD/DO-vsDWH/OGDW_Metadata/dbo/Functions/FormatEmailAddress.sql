CREATE FUNCTION [dbo].[FormatEmailAddress]
(
	@EmailAddress nvarchar(255)
)
RETURNS nvarchar(255)
AS
BEGIN

IF @EmailAddress NOT LIKE '%_@__%.__%'
	RETURN NULL

RETURN @EmailAddress

END