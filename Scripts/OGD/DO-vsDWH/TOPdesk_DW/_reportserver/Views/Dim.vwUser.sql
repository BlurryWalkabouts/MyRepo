CREATE VIEW [dbo].[Dim.vwUser]
AS
     SELECT Name
		  , SecurityClearance
     FROM Dim.Users;