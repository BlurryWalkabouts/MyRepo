CREATE TABLE [FileImport_HPSM].[Incidents_Pepsico] (
    [Interaction ID (Interaction)]                   NVARCHAR (MAX) NULL,
    [Source (Interaction)]                           NVARCHAR (MAX) NULL,
    [Title (Interaction)]                            NVARCHAR (MAX) NULL,
    [Status (Interaction)]                           NVARCHAR (MAX) NULL,
    [Interaction Type (Interaction)]                 NVARCHAR (30)  NULL,
    [First Level Resolution Indicator (Interaction)] REAL           NULL,
    [Group Name (Owner Group)]                       NVARCHAR (MAX) NULL,
    [Owner Contact Name (Interaction)]               NVARCHAR (MAX) NULL,
    [CI Name (Service Component)]                    NVARCHAR (MAX) NULL,
    [Priority (Interaction)]                         REAL           NULL,
    [Escalated Indicator (Interaction)]              REAL           NULL,
    [Solution ID (Interaction)]                      NVARCHAR (MAX) NULL,
    [Knowledge Title (Interaction)]                  NVARCHAR (MAX) NULL,
    [Open Date GMT (Interaction)]                    DATETIME       NULL,
    [Open Date Calendar Month GMT (Interaction)]     REAL           NULL,
    [Close Date GMT (Interaction)]                   DATETIME       NULL,
    [Market Name (Reported By)]                      NVARCHAR (MAX) NULL,
    [AuditDWKey]                                     INT            NULL
);

