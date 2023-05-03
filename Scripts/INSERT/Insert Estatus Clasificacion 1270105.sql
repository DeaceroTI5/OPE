USE TiCatalogo
GO

BEGIN TRAN
----/*TiCatClasificacionEstatus*/
INSERT INTO dbo.TiCatClasificacionEstatus(ClaClasificacionEstatus, NombreClasificacionEstatus, BajaLogica, FechaBajaLogica, FechaUltimaMod, NombrePcMod, ClaUsuarioMod, FechaIns, ClaUsuarioIns)
	VALUES (
	  1270105													-- ClaClasificacionEstatus	
	, 'Estatus de Solicitudes de Captura de Traspasos.'			-- NombreClasificacionEstatus
	, 0															-- BajaLogica				
	, NULL														-- FechaBajaLogica			
	, GETDATE()													-- FechaUltimaMod			
	, 'CargaInicial'											-- NombrePcMod				
	, 1															-- ClaUsuarioMod				
	, GETDATE()													-- FechaIns					
	, 1															-- ClaUsuarioIns				
	)

----/*TiCatEstatus*/
INSERT INTO dbo.TiCatEstatus (ClaClasificacionEstatus, ClaEstatus, NombreEstatus, BajaLogica, FechaBajaLogica, FechaUltimaMod, NombrePcMod, ClaUsuarioMod, FechaIns, ClaUsuarioIns, NombreIngles) 
	VALUES (
	  1270105			-- ClaClasificacionEstatus	
	, 0					-- ClaEstatus				
	, 'Capturada'		-- NombreEstatus				
	, 0					-- BajaLogica				
	, NULL				-- FechaBajaLogica			
	, GETDATE()			-- FechaUltimaMod			
	, 'CargaInicial'	-- NombrePcMod				
	, 1					-- ClaUsuarioMod				
	, GETDATE()			-- FechaIns					
	, 1					-- ClaUsuarioIns				
	, 'Captured'		-- NombreIngles				
)

----/*TiCatEstatus*/
INSERT INTO dbo.TiCatEstatus (ClaClasificacionEstatus, ClaEstatus, NombreEstatus, BajaLogica, FechaBajaLogica, FechaUltimaMod, NombrePcMod, ClaUsuarioMod, FechaIns, ClaUsuarioIns, NombreIngles) 
	VALUES (
	  1270105			-- ClaClasificacionEstatus	
	, 1					-- ClaEstatus				
	, 'Aprobada'		-- NombreEstatus				
	, 0					-- BajaLogica				
	, NULL				-- FechaBajaLogica			
	, GETDATE()			-- FechaUltimaMod			
	, 'CargaInicial'	-- NombrePcMod				
	, 1					-- ClaUsuarioMod				
	, GETDATE()			-- FechaIns					
	, 1					-- ClaUsuarioIns				
	, 'Approved'		-- NombreIngles				
)

----/*TiCatEstatus*/
INSERT INTO dbo.TiCatEstatus (ClaClasificacionEstatus, ClaEstatus, NombreEstatus, BajaLogica, FechaBajaLogica, FechaUltimaMod, NombrePcMod, ClaUsuarioMod, FechaIns, ClaUsuarioIns, NombreIngles) 
	VALUES (
	  1270105			-- ClaClasificacionEstatus	
	, 2					-- ClaEstatus				
	, 'Cancelada'		-- NombreEstatus				
	, 0					-- BajaLogica				
	, NULL				-- FechaBajaLogica			
	, GETDATE()			-- FechaUltimaMod			
	, 'CargaInicial'	-- NombrePcMod				
	, 1					-- ClaUsuarioMod				
	, GETDATE()			-- FechaIns					
	, 1					-- ClaUsuarioIns				
	, 'Canceled'		-- NombreIngles				
)

----/*TiCatEstatus*/
INSERT INTO dbo.TiCatEstatus (ClaClasificacionEstatus, ClaEstatus, NombreEstatus, BajaLogica, FechaBajaLogica, FechaUltimaMod, NombrePcMod, ClaUsuarioMod, FechaIns, ClaUsuarioIns, NombreIngles) 
	VALUES (
	  1270105			-- ClaClasificacionEstatus	
	, 3					-- ClaEstatus				
	, 'Rechazada'		-- NombreEstatus				
	, 0					-- BajaLogica				
	, NULL				-- FechaBajaLogica			
	, GETDATE()			-- FechaUltimaMod			
	, 'CargaInicial'	-- NombrePcMod				
	, 1					-- ClaUsuarioMod				
	, GETDATE()			-- FechaIns					
	, 1					-- ClaUsuarioIns				
	, 'Rejected'		-- NombreIngles				
)

SELECT * FROM  dbo.TiCatClasificacionEstatus WHERE ClaClasificacionEstatus = 1270105
SELECT * FROM  dbo.TiCatEstatus WHERE ClaClasificacionEstatus = 1270105

COMMIT TRAN