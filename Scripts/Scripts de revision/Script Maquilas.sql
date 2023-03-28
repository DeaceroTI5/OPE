USE Operacion
GO

SELECT	* FROM OpeSch.OpeTraContratoMaquila WITH(NOLOCK)
WHERE	ClaUbicacion = 12 
AND		IdContrato = 71

SELECT	* 
FROM	Opesch.OpeTraOrdenMaquilaDet WITH(NOLOCK)
WHERE	ClaUbicacion = 12 
AND		IdContratoMaquila IS NULL
ORDER BY FechaUltimaMod DESC



--SELECT * FROM OpeSch.OpeTraRecepTraspasoVw WHERE IdSol
--SELECT * FROM OpeSch.OpeTraRecepTraspasoBoletaVw
--SELECT * FROM OpeSch.OpeTraRecepTraspasoFabVw
--89126

	-----------------------------------------------------------------------------------
	/*
	ClaClasificacionEstatus	NombreClasificacionEstatus
	390001	Maquila - Estatus de Contrato de Maquilas
	390002	Maquila - Estatus Orden de Salida
	390003	Maquila - Estatus de Cotizaciones
	390004	Maquila - Estatus de Recepciones para Proveedores
	390005	Maquila - Estatus de Recepciones de Factura de Maquilador
	390006	Maquila - Estatus de Cancelación de Saldos a Maquiladores
	390007	Maquila - Estatus de Tramites para Maquiladores
	390008	Maquila - Estatus de Deducciones para Maquiladores
	390010	Maquila - Estatus de Recepcion Material para Maquilar
	390011	Maquila - Estatus de Ajuste de Saldo
	390012	Maquila - Estatus de Orden de Maquila
	390013	Maquila - Estatus de Detalle de Orden de Maquila

	SELECT * FROM OpeSch.OpeTiCatestatusVw WHERE ClaClasificacionEstatus = 390001
	*/
	-----------------------------------------------------------------------------------

	SELECT	* 
	FROM	Opesch.OpeTraOrdenMaquila WITH(NOLOCK)
	WHERE	ClaUbicacion = 12 
	AND		IdOrdenMaquila = 136

	SELECT	IdFabricacion, * 
	FROM	Opesch.OpeTraOrdenMaquilaDet WITH(NOLOCK)
	WHERE	ClaUbicacion = 12 
	AND		IdOrdenMaquila	IN (136, 137)
	ORDER BY FechaUltimaMod DESC


	SELECT	IdOrdenSalidaMaquila, * 
	FROM	OpeSch.OpeTraOrdenSalidaMaquilaDet WITH(NOLOCK) 
	WHERE	ClaUbicacion	= 12		
	AND		IdOrdenMaquila	IN (136, 137)
--	AND		IdContrato IS NULL


	SELECT	IdBoleta, *
	FROM	OpeSch.OpeTraOrdenSalidaMaquila WITH(NOLOCK) 
	WHERE	ClaUbicacion = 12  
	AND		ClaMaquilador = 2 
	AND		IdOrdenSalidaMaquila = 122

	SELECT	* 
	FROM	OpeSch.OpeTraBoletaHis WITH(NOLOCK) 
	WHERE	ClaUbicacion = 12 
	AND		IdBoleta = 230390016



	-- Pedido
	SELECT	ClaEstatusFabricacion, * 
	FROM	DEAOFINET05.Ventas.VtaSch.VtaTraFabricacionVw 
	WHERE	IdFabricacion IN (24458473, 24458277)

	SELECT	ClaEstatusFabricacion, * 
	FROM	DEAOFINET05.Ventas.VtaSch.VtaTraFabricacionDetVw 
	WHERE	IdFabricacion IN (24458473, 24458277)



----------------------------------------------------
	--BEGIN TRAN
		--UPDATE Opesch.OpeTraOrdenMaquilaDet
		--SET IdContratoMaquila = 71
		--where ClaUbicacion = 54 and IdOrdenMaquila = 1243

		--select * from Opesch.OpeTraOrdenMaquilaDet
		--where ClaUbicacion = 54 and IdOrdenMaquila = 1243
	--ROLLBACK TRAN
----------------------------------------------------