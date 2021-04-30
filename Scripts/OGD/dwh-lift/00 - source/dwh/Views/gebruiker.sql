CREATE VIEW dwh.[gebruiker] AS
SELECT
    [unid],
    [dataanmk],
    [datwijzig],
    [uidaanmk],
    [uidwijzig],
    [status],
    [naam],
    [inlognaam],
    [email],
    [license_key],
    [is_template],
    [employeeid],
    [support_account],
    [mergefield_jobdescription],
    [mergefield_availablility],
    [mergefield_footer],
    [mergefield_phonenumber],
    [pass_last_set]
FROM dbo.[gebruiker];
