CREATE VIEW [Quriuz].[BevoegdhedenMedewerkers]
AS

-- https://trello.com/c/uT1bYUJ6/256-dim-functie-dupliceert-records-door-join-met-formatieverdeling-kostendragers-bijvoorkeur-unieke-functie-records-in-dim-functie-e

SELECT DISTINCT
	kpl.KostenplaatsKey
	, mdw.MedewerkerKey
	, kpl.Instelling
	, kpl.KostenplaatsNaam
	, KostenplaatsWeergaveNaam = CONCAT(kpl.KostenplaatsCode,' ',kpl.KostenplaatsNaam)
	, MedewerkerCode = CAST(mdw.MedewerkerCode AS int)
	, mdw.MedewerkerNaam
	, mdw.Geslacht
	, mdw.Woonplaats
	, mdw.Email
	, mdw.Geboortedatum
	, Leeftijd = FLOOR(DATEDIFF(DD, mdw.Geboortedatum, GETDATE()) / 365.25)
	, f.FunctieType
	, f.FunctieOmschrijving
	, Dienstjaren_Quadraam = ROUND(DATEDIFF(YY, mdw.DatumInDienst, GETDATE()),0)
	, dv.Dienstbetrekking
	, bv.OmschrijvingOpleiding
	, bv.OpleidingsType
	, bv.VakBevoegdheid
	, bv.Bevoegdheidsgraad
	, Status_bevoegd = CASE WHEN bv.ResultaatOpleiding = 'Afgerond' AND bv.HeeftDiploma = 1 THEN 'Bevoegd' ELSE 'Onbevoegd' END
FROM
	Dim.Functie f
	LEFT OUTER JOIN Dim.Medewerker mdw ON f.MedewerkerKey = mdw.MedewerkerKey
	LEFT OUTER JOIN Dim.Kostenplaats kpl ON f.KostenplaatsKey = kpl.KostenplaatsKey
	LEFT OUTER JOIN Dim.Dienstverband dv ON f.DienstverbandKey = dv.DienstverbandKey
	LEFT OUTER JOIN Dim.Bevoegdheid bv ON mdw.MedewerkerKey = bv.MedewerkerKey
WHERE 1=1
	AND f.EinddatumFunctie > GETDATE() -- functie tabel filteren op alleen actieve functies (o.b.v. einddatum functie en huidige datum)
	AND mdw.MedewerkerKey <> -1