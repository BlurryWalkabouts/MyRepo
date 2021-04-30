SET STATISTICS IO ON

EXEC setup.LoadDataIntoStaging @patDataSource = 'DUO', @patConnector = '%leerlingen%bo%en%sbo%leerlingenprognoses%', @debug = 1

SELECT
	*
FROM
	setup.vwMetadataTables
WHERE 1=1
	AND TABLE_SCHEMA = 'DUO'
/*
besturen_swv_en_passend_onderwijs
instellingen_per_samenwerkingsverband_passend_onderwijs_po
instellingen_per_samenwerkingsverband_passend_onderwijs_vo
leerlingen_bo_en_sbo_leerlingenprognoses
leerlingen_bo_gewicht_leeftijd
leerlingen_po_soort_po_cluster_leeftijd
leerlingen_po_totaaloverzicht
leerlingenprognoses_vo
po_fte_owtype_bestuur_brin_functie
samenwerkingsverbanden_passend_onderwijs_po
samenwerkingsverbanden_passend_onderwijs_vo
toegestaan_onderwijs

%besturen%swv%en%passend%onderwijs -- 0 items
%instellingen%per%samenwerkingsverband%passend%onderwijs%po -- 0 items
%instellingen%per%samenwerkingsverband%passend%onderwijs%vo -- 0 items
%leerlingen%bo%en%sbo%leerlingenprognoses% -- Deadlock
%leerlingen%bo%gewicht%leeftijd% -- Deadlock
%leerlingen%po%soort%po%cluster%leeftijd% -- Deadlock
%leerlingen%po%totaaloverzicht% -- Deadlock
%leerlingenprognoses%vo% -- Deadlock
%po%fte%owtype%bestuur%brin%functie -- Deadlock
%samenwerkingsverbanden%passend%onderwijs%po -- 0 items
%samenwerkingsverbanden%passend%onderwijs%vo -- 0 items
%toegestaan%onderwijs% -- 0 items
*/