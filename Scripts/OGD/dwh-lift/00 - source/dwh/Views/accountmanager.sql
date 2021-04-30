CREATE VIEW dwh.[accountmanager] AS
SELECT
    [unid],
    [archief],
    [rang],
    [gebruikerid],
   [afkorting] = null,
    [signer]
FROM dbo.[accountmanager];
