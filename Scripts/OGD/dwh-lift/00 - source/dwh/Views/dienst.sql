CREATE VIEW dwh.[dienst] AS
SELECT
    [unid],
    [archief],
    [rang],
    [budgethouderid],
    [grootboekid],
    [btwid],
    [naam],
    [omschrijving],
    [afkorting]  = null
FROM dbo.[dienst];
