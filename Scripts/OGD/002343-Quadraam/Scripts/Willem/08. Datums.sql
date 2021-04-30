SELECT * FROM Metadata_Quadraam.[log].ProcedureLog
SELECT BoekDatumKey, COUNT(*) FROM DWH_Quadraam.Fact.Mutatie GROUP BY BoekDatumKey ORDER BY BoekDatumKey
SELECT FactuurDatumKey, COUNT(*) FROM DWH_Quadraam.Fact.Mutatie GROUP BY FactuurDatumKey ORDER BY FactuurDatumKey
SELECT * FROM DWH_Quadraam.Dim.Datum
SELECT COALESCE(MAX(JaarNum),0) FROM DWH_Quadraam.Dim.Datum