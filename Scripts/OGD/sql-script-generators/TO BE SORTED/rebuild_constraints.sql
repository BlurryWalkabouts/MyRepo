select 
     [Table]     = o2.name, 
     [Constraint] = o.name, 
     [Enabled]   = case when ((C.Status & 0x4000)) = 0 then 1 else 0 end,
	 'Enable' = 'ALTER TABLE [' + o2.name + '] CHECK CONSTRAINT ' + o.name + ';'
from sys.sysconstraints C
     inner join sys.sysobjects o on  o.id = c.constid -- and o.xtype='F'
     inner join sys.sysobjects o2 on o2.id = o.parent_obj
WHERE (case when ((C.Status & 0x4000)) = 0 then 1 else 0 end) = 0