/*

heaps get rowids instead of PK, that are not visiable
pages link to next with pointer
-	can be used in staging tables 
-	scan only tables (fact tables)
BUT
updating recs to become wider (fill a null ) cant fit on page, get moved , leaving pointer behind. (forward fetches)
delete do not give up space. Still points to location

heaps are for fast inserts
lower keylookup speeds

SUNE principals to clustered index
- static
- unique (otherwise sql adds it for you, costs psace)
- narrow and small (added to non clustered keys)
- ever increasssing to make sure last page is in memory. Sql does not have to look for it
*/


