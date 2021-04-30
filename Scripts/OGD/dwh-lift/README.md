# OGD LIFT-datawarehouse (v2.0 beta-ish)

## Inleiding

*For an English version of this document, ask me for one*

Lift is een database met een hoop gevoelige persoonsgebonden info erin. We maken hier een flink aantal rapporten over. Om de hele solution voor het dwh wat draagbaarder en makkelijker te onderhouden te maken (en dus ook hopelijk makkelijker bij klanten uit te rollen), hebben we besloten het los op te slaan en in een soort standaardvorm te gieten. Op het moment (13 juli 2018) is waar mogelijk nog grotendeels de oude structuur gebruikt. De belangrijkste verschillen ten opzichte van vsDWH:

- Brondata komt uit een (vooral theoretische) Source, en wordt dan uniform (in het geval van meerdere bronnen) ingeladen in Transform. In vsDWH heet de database met die functie "Staging".
- De logica (voornamelijk **Stored Procedures** (sprocs)) staat zoveel mogelijk in de database waarop het betrekking heeft. Er is dus geen aparte database MetaData.

We streven ernaar om (zover het van toepassing is) per database hetzelfde schema aan te houden:

- **Load** bevat de sprocs waarmee data wordt ingeladen
- **Stage** bevat views waarin data wordt aangeboden aan het volgende stadium

Voor de **Datamart** gebruiken we een Dim-Fact structuur. De intentie is momenteel om dat zoveel mogelijk in een star-model te houden en snowflake te voorkomen.

De structuur van het DWH is als volgt:

- 00-Source
- 01-Transform
- 02-Archive
- 03-Datamart
- 04-Developer

## 00-Source

Voorheen was de brondata direct de LIFT-database. Dit is vervangen door Views op een linked server die alleen de data aanbieden die wij dienen te verwerken (althans voor testdoeleinden). Belangrijkste verschil is het schema van de brondata: dat is in de nieuwe situatie [dwh].
De bronserver is op de servers bereikbaar via de linked server `replica_001013_lift`.
De brondatabase heet `lift-test` voor testomgevingen, in de productieomgeving heet deze database `lift`

Een tweede externe bron is de MDS database (Master Data Services).
Deze bron is bereikbaar via de linked server `source_mds`, database `mdscloud`.

## 01-Transform

Omdat er maar één bron is doet Transform niet echt iets. Data wordt vanuit de bron ingeladen. Dit moet worden beschouwd als een staging-omgeving die dus wordt leeggegooid iedere keer dat data wordt ingeladen.

Het inladen van de data verloopt via de `[load].[LoadStagingTables]` stored procedure.

## 02-Archive

In Archive wordt data vanuit Transform gekopiëerd naar **system versioned temporal tables**, voor retentie. Het enige verschil met vsDWH is eigenlijk dat er minder data binnenkomt omdat we niet langer alles overkopiëren (wellicht anders in Productie?). De data wordt opgehaald door sprocs die **dynamic SQL** genereren, omdat de namen van brontabellen kunnen veranderen.

Het inladen van de data verloopt via de `[load].[ArchiveLift]` stored procedure.

## 03-Datamart

De Dim-Fact structuur uit vsDWH is direct overgenomen. De sproc die data inlaadt (`[load].[LoadLiftDW]`) is (op verzoek) uit elkaar getrokken. Het idee is om de sprocs los aan te roepen in aparte jobs, zodat bij een fout niet de hele ETL opnieuw moet worden doorlopen. Dit brengt enige replicatie van code met zich mee, maar bevordert de modulariteit. 

Bij een aantal tabellen is een testversie aangemaakt met het suffix _TEMPORAL. Deze zijn voor Type 4 Temporal tables die incrementeel kunnen worden ingeladen. Na dit te hebben getest gaat mijn voorkeur uit naar Type 2, dus zie dit voor wat het is: een test.

## (04-Developer)

Developer is een kopie van Datamart met automatisch gegenereerde testgegevens, voor ontwikkeldoeleinden. Als het dat niet is loopt het achter.
 xx
## Verdere ontwikkeling (voel je vrij om dingen toe te voegen)

