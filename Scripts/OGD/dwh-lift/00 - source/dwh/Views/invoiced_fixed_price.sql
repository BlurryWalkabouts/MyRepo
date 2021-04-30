CREATE VIEW dwh.[invoiced_fixed_price] AS
SELECT [unid],
       [dataanmk],
       [datwijzig],
       [invoiceid],
       [price_ex_vat],
       [vatid],
       [project_id],
       [booking_date],
       [correctedid]
  FROM [dbo].[invoiced_fixed_price];