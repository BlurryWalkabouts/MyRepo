CREATE VIEW dwh.[taak] AS
SELECT
    [unid],
    [dataanmk],
    [datwijzig],
    [uidaanmk],
    [uidwijzig],
    [status],
    [sprocesid],
    [procesid],
    [taaknr],
    [looncomponent_urenid],
    [taaknaam],
    [iedereen],
    [einddatum],
    [available_for_employee],
    [available_for_contractor],
    [hour_note_required],
    [system_task_type]
FROM dbo.[taak];
