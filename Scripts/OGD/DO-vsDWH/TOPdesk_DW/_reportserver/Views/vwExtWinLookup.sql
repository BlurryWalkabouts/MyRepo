
CREATE view Dim.vwExtWinLookup as
/*View voor het ExtensionWindow van Anywhere365 om inkomende telefoongesprekken te matchen met customers of callers uit het OGDW
De kolom CustomerFlag wordt toegevoegd omdat als medewerkers van een klant met een algemeen nummer naar buiten bellen de naam van
de klant zichtbaar moet zijn en niet de eeste persoon die gevonden wordt met het nummer.

Geschreven voor Wouter Gielen 15-10-15*/

select
	Fullname as Displayname
	,TelephoneNumber
	,null as MobileNumber
	,null as Email
	,1 as CustomerFlag
	from Dim.Customer 

Union

Select
	CallerName
	,CallerTelephoneNumberSTD
	,CallerMobileNumberSTD
	,CallerEmail
	,0 as CustomerFlag
	from Dim.[Caller]

--select * from dim.vwExtWinLookup order by CustomerFlag desc, Displayname

