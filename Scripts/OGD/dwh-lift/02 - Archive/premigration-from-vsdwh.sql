USE [DWHPROD01_LIFT_Archive];

ALTER TABLE [dbo].[aanvraag]
DROP
    COLUMN [aanpak];

ALTER TABLE [dbo].[contactpersoon]
DROP
    COLUMN [aantekening],
    COLUMN [extramemo],
    COLUMN [memop];

ALTER TABLE [dbo].[dienst]
DROP
    COLUMN [stdopdracht];
    
ALTER TABLE [dbo].[gebruiker]
DROP
    COLUMN [groepoms];
    
ALTER TABLE [dbo].[klant]
DROP
    COLUMN [aantekeningen],
    COLUMN [extramemo],
    COLUMN [invoice_attention],
    COLUMN [invoice_mail_salutation],
    COLUMN [notitie];

ALTER TABLE [dbo].[project]
DROP
    COLUMN [aanpak],
    COLUMN [cafspraak],
    COLUMN [copdracht],
    COLUMN [extramemo],
    COLUMN [ffactxt],
    COLUMN [invoice_attention],
    COLUMN [invoice_mail_salutation],
    COLUMN [opdracht],
    COLUMN [veranderingen];

ALTER TABLE [dbo].[projectgroep]
DROP
    COLUMN [veranderingen];

ALTER TABLE [dbo].[task_assignment_hour]
DROP
    COLUMN [aantekeningen];

ALTER TABLE [dbo].[voordracht]
DROP
    COLUMN [extramemo],
    COLUMN [regelingen],
    COLUMN [urenmemo];

ALTER TABLE [dbo].[wcontract]
DROP
    COLUMN [bonusregeling_regeling],
    COLUMN [extramemo],
    COLUMN [onkostenvergoeding_regeling],
    COLUMN [oplbudget_regeling],
    COLUMN [reiskosten_regeling];

ALTER TABLE [dbo].[werknemer]
DROP
    COLUMN [las_memo],
    COLUMN [extra_team],
    COLUMN [extra_niveau];
