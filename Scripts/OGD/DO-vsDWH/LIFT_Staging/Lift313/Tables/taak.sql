CREATE TABLE [Lift313].[taak] (
    [unid]                     UNIQUEIDENTIFIER NULL,
    [dataanmk]                 DATETIME         NULL,
    [datwijzig]                DATETIME         NULL,
    [uidaanmk]                 UNIQUEIDENTIFIER NULL,
    [uidwijzig]                UNIQUEIDENTIFIER NULL,
    [status]                   INT              NULL,
    [sprocesid]                UNIQUEIDENTIFIER NULL,
    [procesid]                 UNIQUEIDENTIFIER NULL,
    [taaknr]                   NVARCHAR (8)     NULL,
    [looncomponent_urenid]     UNIQUEIDENTIFIER NULL,
    [taaknaam]                 NVARCHAR (30)    NULL,
    [iedereen]                 BIT              NULL,
    [system_task_type]         INT              NULL,
    [einddatum]                DATETIME         NULL,
    [available_for_employee]   INT              NULL,
    [available_for_contractor] INT              NULL,
    [hour_note_required]       BIT              NULL,
    [AuditDWKey]           INT              NULL
);

