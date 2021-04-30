alter Procedure [Load].[usp_LoadUserList] (
	@CustomerNumber nvarchar(6)
) AS
BEGIN

	DECLARE @SQL nvarchar(max) = '
	INSERT INTO [dbo].[UserList] (CustomerNumber, GivenName, Surname, UserPrincipalName, Enabled, Name)
	SELECT ' + @CustomerNumber + ', j.*
	FROM OPENROWSET(
		BULK ''administratoraccounts/' + @CustomerNumber + '-userlist.json'' ,
		DATA_SOURCE = ''BlobStorage'',
		SINGLE_NCLOB
	) AS data
	CROSS APPLY OPENJSON(BulkColumn)
	WITH (
		[GivenName] nvarchar(255),
		[Surname] nvarchar(255),
		[UserPrincipalName] nvarchar(255),
		[Enabled] bit,
		[Name] nvarchar(255)
		--[LastLogonDate] datetime
	) j;' 
END

EXEC(@SQL)

/*
alter DATABASE SCOPED CREDENTIAL [BlobCredential] WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
	SECRET = 'sv=2017-11-09&ss=b&srt=sco&sp=rl&se=2019-10-19T00:04:14Z&st=2018-10-18T16:04:14Z&spr=https&sig=zPLiPYn0YuBPgAgJKqEMhHotvatErcSLDpLai8rY%2FDA%3D';

CREATE EXTERNAL DATA SOURCE BlobStorage
WITH (	TYPE = BLOB_STORAGE, 
		LOCATION = 'https://ogdeuwstaogdgplraudit01.blob.core.windows.net', 
		CREDENTIAL = [BlobCredential]
);
*/