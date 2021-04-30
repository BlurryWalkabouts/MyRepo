CREATE EXTERNAL TABLE [archive].[werknemer] (
    [unid]                        uniqueidentifier                                  NOT NULL,
    [status]                      int                                               NULL,
    [inits]                       nvarchar(10)                                      NULL,
    [geboortejaar]                int                                               NULL,
    [rijbewijs]                   bit                                               NULL,
    [auto]                        bit                                               NULL,
    [persnr]                      nvarchar(6)                                       NULL,
    [stdbeschikbaarheid]          int                                               NULL,
    [datumindienst]               datetime                                          NULL,
    [HR_ContactPersoon]           nvarchar(35)                                      NULL,
    [Leidinggevende]              nvarchar(35)                                      NULL,
    [anaam]                       nvarchar(30)                                      NULL,
    [rnaam]                       nvarchar(20)                                      NULL,
    [tussen]                      nvarchar(10)                                      NULL,
    [plaats1]                     nvarchar(30)                                      NULL,
    [postcode1]                   nvarchar(15)                                      NULL,
    [tel1]                        nvarchar(25)                                      NULL,
    [email]                       nvarchar(75)                                      NULL,
    [functie]                     nvarchar(35)                                      NULL,
    [business_unit]               nvarchar(35)                                      NULL,
    [extra_team]                  nvarchar(35)                                      NULL,
    [nextappointment_jaar]        nvarchar(35)                                      NULL,
    [nextappointment_maand]       nvarchar(35)                                      NULL,
    [vestiging]                   nvarchar(40)                                      NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'werknemer'
);
