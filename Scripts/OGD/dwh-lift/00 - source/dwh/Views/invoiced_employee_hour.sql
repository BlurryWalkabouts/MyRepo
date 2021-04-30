CREATE VIEW dwh.[invoiced_employee_hour] AS
SELECT [unid],
       [dataanmk],
       [datwijzig],
       [invoiceid],
       [price_ex_vat],
       [percentage],
       [vatid],
       [employee_assignment_id],
       [hourtype_id],
       [booking_date],
       [employee_id],
       [job_description_id],
       [product_id],
       [hour_id],
       [correctedid],
	   [seconds]
  FROM [dbo].[invoiced_employee_hour];