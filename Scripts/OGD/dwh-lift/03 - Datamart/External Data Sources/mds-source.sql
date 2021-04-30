CREATE EXTERNAL DATA SOURCE [mds-source]
WITH (
    TYPE = RDBMS,
    LOCATION = '$(MDSServer)',
    DATABASE_NAME = '$(MDS)',
    CREDENTIAL = [mds-credential]
);
