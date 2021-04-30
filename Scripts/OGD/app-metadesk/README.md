LET OP: De initiele sync is in batches van 1500 records. 
Dit is om te zorgen dat de logic apps geen timeout geven bij het mergen. 
Na een aantal runs is de boel gesynchroniseerd. 1500 lijkt een optimimum te zijn.

Prepwork TOPdesk DB:
1.  Maak servicebus login aan:

        CREATE SCHEMA metadesk;
        CREATE ROLE metadesk;
        GRANT EXECUTE ON SCHEMA::metadesk TO metadesk;
        CREATE USER sa_metadesk WITH PASSWORD='<password>';
        EXEC sp_addrolemember 'metadesk', 'sa_metadesk';
2.  Maak de SPROCs metadesk.* aan

Prepwork Metadesk DB:
1.  Maak klant aan in `dim.customer`.
    CustomerKey = CustomerNumber zonder leading 00
2.  Maak servicebus login aan:

        CREATE ROLE sbs;
        GRANT EXECUTE ON SCHEMA::fact TO sbs;
        GRANT EXECUTE ON SCHEMA::dim TO sbs;
        CREATE USER sa_sbs WITH PASSWORD='<Password>';
        EXEC sp_addrolemember 'sbs', 'sa_sbs';
2.  Maak applicatielogin aan:

        CREATE ROLE metadesk;
        GRANT SELECT ON SCHEMA::dim TO metadesk;
        GRANT SELECT ON SCHEMA::fact TO metadesk;
        GRANT SELECT ON SCHEMA::security TO metadeskl
        CREATE USER sa_metadesk WITH PASSWORD='<password>';
        EXEC sp_addrolemember 'metadesk', 'sa_metadesk';

Azure:

1.  Deploy logic app naar OGD-EUW-RGR-PRD-OGD-DTF-01
2.  Logica:
    1.  Trigger 5 min
    2.  Init variable CustomerNumber <- Dan is de rest dynamisch
    3.  Metadesk sproc fetchLastModified gebruiken met als input customernumber variable
    4.  Source fetch_Inc/Chang/Prob/Acti. Sproc gebruiken, met last modified als input
    5.  Json output from d gebruiken als input samen met customernumber
    6.  ???
    7.  PROFIT!
