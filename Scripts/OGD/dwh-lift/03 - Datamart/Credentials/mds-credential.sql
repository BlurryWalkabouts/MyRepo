CREATE DATABASE SCOPED CREDENTIAL [mds-credential]
WITH
    IDENTITY = N'$(mds_source_user)',
    SECRET = N'$(mds_source_password)';
