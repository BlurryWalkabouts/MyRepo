select 
	 tekst
	,unid
	,AADObjectId = ''
	,ADObjectId = ''
	,FunctionKey = ''
	,archief = case when archief < 0 then CONCAT('True', ' {1}') ELSE CONCAT('False', ' {0}') END
from 
	dbo.vrijopzoek 
where 
	kaartcode = 'TBL01EXVELD005' 
order by tekst