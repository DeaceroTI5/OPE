'%Clasi%Estatus%'
'%Estatus%Plan%'
USE Operacion
GO
SELECT * FROM dbo.TiCatClasificacionEstatusVw where NombreClasificacionEstatus LIKE '%Plan%'
SELECT * FROM dbo.TiCatClasificacionEstatusVw  WHERE ClaClasificacionEstatus IN (1270004, 1270009)
SELECT * FROM OpeSch.OpeTiCatestatusVw WHERE ClaClasificacionEstatus IN (1270004, 1270009)


SELECT * FROM OpeSch.OpeTiCatEstatusPlanCargaVw
SELECT * FROM  OpeSch.OpeVtaCatProyectoVw WHERE ClaProyecto =  21728
SELECT * FROM  OpeSch.OpeVtaRelFabricacionProyectoVw WHERE ClaProyecto =  21728

SELECT * FROM Ventas.VtaSch.VtaRelFabricacionProyectoVw WHERE ClaProyecto =  21728

USE Ventas
go

SP_HELPTEXT 'VtaSch.VtaRelFabricacionProyectoVw'
SELECT * FROM VtaSch.VtaRelFabricacionProyectoVw WHERE ClaProyecto =  21728
'VtaSch.VtaRelFabricacionProyectoVw'