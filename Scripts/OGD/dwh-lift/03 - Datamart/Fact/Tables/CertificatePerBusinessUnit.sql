CREATE TABLE [Fact].[CertificatePerBusinessUnit]
(   BusinessUnit                     NVARCHAR(35)               NOT NULL,
    Team                             NVARCHAR(35)               NOT NULL,
	Diploma                          NVARCHAR(25)               NOT NULL,
	DiplomaKey                       INT                        NOT NULL,
	ExpirationDate                   DATE                       NOT NULL,
	DiplomaCount                     SMALLINT                   NOT NULL,	
	CONSTRAINT [FK_CertificatePerBusinessUnit_DiplomaKey] FOREIGN KEY ([DiplomaKey]) REFERENCES [Dim].[Diploma] ([DiplomaKey])
)
