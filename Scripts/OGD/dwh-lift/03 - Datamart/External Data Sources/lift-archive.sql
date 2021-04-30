CREATE EXTERNAL DATA SOURCE [lift-archive]
WITH (
    TYPE = RDBMS,
    LOCATION = '$(ArchiveServer)',
    DATABASE_NAME = '$(Archive)',
    CREDENTIAL = [archive-credential]
);
