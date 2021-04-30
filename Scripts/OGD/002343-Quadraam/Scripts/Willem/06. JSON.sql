/*
type
0 = null
1 = string
2 = number
3 = boolean
4 = array
5 = object
*/

/*
SELECT @field = [value] FROM OPENJSON(@fields) WHERE [key] = 0

SELECT
	*
FROM
	OPENJSON(@field)
*/

DECLARE @json nvarchar(max)
DECLARE @rows nvarchar(max)
DECLARE @row nvarchar(max)

SELECT @json = BulkColumn FROM OPENROWSET (BULK 'F:\JSON\Profit_Journals.json', SINGLE_NCLOB) j

SELECT
	*
FROM
	OPENJSON(@json)

SELECT @rows = [value] FROM OPENJSON(@json) WHERE [key] = 'rows'

SELECT
	*
FROM
	OPENJSON(@rows)
/*WITH
	(
	Medewerker   varchar(200) '$.Medewerker'
	, Naam       varchar(200) ''
	, "Geslacht": "Man"
	,      "Geboortejaar": 1958
	,      "Geboortemaand": 10
	,      "Geboortedag": 16
	,      "Postcode": "6836 KV"
	,      "Woonplaats": "Arnhem"
	,      "In_dienst_dienstjaren": "1987-05-19T00:00:00Z"
	,      "Werkgever": "13554"
	,      "Achternaam": "Aa"
	,      "Achternaam__init_voorvoegsel__voornaam_": "Aa, C.G. van der (Christiaan Geurt)"
	,      "Volledige_achternaam": "van der Aa"
	,      "Initialen___volledige_achternaam": "C.G. van der Aa"
	,      "Naamregel_t.b.v._adressering": "De heer C.G. van der Aa"
	,      "Zoeknaam": "Aa"
	,      "Achternaam__init_voorvoegsel__roepnaam_": "Aa, C.G. van der (Erik)"
	,      "Initialen_voorvoegsel_achternaam__voornaam_": "C.G. van der Aa (Christiaan Geurt)"
	,      "Initialen_voorvoegsel_achternaam__roepnaam_": "C.G. van der Aa (Erik)"
	,      "Initialen_voorvoegsel_achternaam": "C.G. van der Aa"
	,      "In_dienst__i.v.m._signalering_": "1987-05-19T00:00:00Z"
	,      "In_dienst__incl._rechtsvoorganger_": "1987-05-19T00:00:00Z"
	,      "Burgerservicenr.": "089548863"
	,      "Cao": "VO"
	,      "Omschrijving": "Voortgezet Onderwijs"
	,      "Cao-type": "Overig"
	,      "Straat": "Fridtjof Nansenstraat"
	,      "Huisnummer": 79
	,      "Toev._aan_huisnr.": null
	,      "Telefoonnr._werk": null
	,      "E-mail_werk": "e.vanderaa@gymnasiumarnhem.nl"
	,      "Telefoonnr._prive": "026-3274509"
	,      "Mobiel_prive": null
	,      "E-mail_prive": null
	)
*/

SELECT @row = [value] FROM OPENJSON(@rows) WHERE [key] = 0

SELECT
	*
FROM
	OPENJSON(@row)