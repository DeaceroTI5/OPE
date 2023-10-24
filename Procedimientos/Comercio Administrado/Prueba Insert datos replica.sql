
--SELECT * FROM OpeSch.OpeRelPlanCargaShipID
--SELECT * FROM OpeSch.OpeRelPlanCargaShipIDDet
--SELECT * FROM OpeSch.OpeTraControlPlanCargaDocumentado
--SELECT * FROM OpeSch.opeRelEstudioArticulosASAOPE 
--SELECT * FROM OpeSch.OpeRelProyectoVtaProyectoASA
SELECT * FROM OpeSch.OpeCtsCatProyectoASAVw

--'OpeSch.OpeCtsCatProyectoASAVw'


--insert into OpeSch.OpeRelPlanCargaShipID VALUES (369,1,1,1,'Prueba',getdate())
--insert into OpeSch.OpeRelPlanCargaShipIDDet (
-- ClaUbicacion		
--,IdPlanCarga		
--,IdFabricacion		
--,IdFabricacionDet	
--,ClaArticulo		
--,ControlCode		
--,OrderId			
--,ShipId				
--,ShipKey			
--,ShipItemAccumKey	
--,Product			
--,NombrePcMod		
--,FechaUltimaMod
--)
--SELECT
-- ClaUbicacion		= 369
--,IdPlanCarga		= 1
--,IdFabricacion		= 1
--,IdFabricacionDet	= 1
--,ClaArticulo		= 1
--,ControlCode		= '1'
--,OrderId			= '1'
--,ShipId				= '1'
--,ShipKey			= 1
--,ShipItemAccumKey	= 1
--,Product			= 'Producto'
--,NombrePcMod		= 'Prueba'
--,FechaUltimaMod		= GETDATE()



--INSERT INTO OpeSch.OpeTraControlPlanCargaDocumentado (
-- ClaUbicacion
--,IdPlanCarga
--,IdFabricacion
--,IdFabricacionDet
--,ClaArticulo
--,ClaveArticulo
--,NombrePcMod
--,FechaUltimaMod
--) SELECT
-- ClaUbicacion			= 369
--,IdPlanCarga			= 1
--,IdFabricacion			= 1
--,IdFabricacionDet		= 1
--,ClaArticulo			= 1
--,ClaveArticulo			= 'C'
--,NombrePcMod			= 'Prueba'
--,FechaUltimaMod			= GETDATE()

--INSERT INTO OpeSch.OpeRelProyectoVtaProyectoASA(
-- ClaUbicacion
--,ClaProyectoVta
--,ClaProyectoAsa
--,BajaLogica
--,FechaBajaLogica
--,FechaUltimaMod
--,NombrePcMod
--,ClaUsuarioMod
--)
--SELECT 
-- ClaUbicacion		= 369
--,ClaProyectoVta		= 1
--,ClaProyectoAsa		= 1
--,BajaLogica			= 0
--,FechaBajaLogica	= NULL
--,FechaUltimaMod		= GETDATE()
--,NombrePcMod		= 'Prueba'
--,ClaUsuarioMod		= 1


GRANT SELECT ON OpeSch.OpeCtsCatProyectoASAVw TO transfer