CREATE DATABASE SCOPED CREDENTIAL [archive-credential]
WITH
    IDENTITY = N'$(lift_archive_user)',
    SECRET = N'$(lift_archive_password)';
