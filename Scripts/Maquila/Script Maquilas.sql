--USE Operacion
--GO

--SELECT	* FROM OpeSch.OpeTraContratoMaquila WITH(NOLOCK)
--WHERE	ClaUbicacion = 12 
--AND		IdContrato = 71

--SELECT	* 
--FROM	Opesch.OpeTraOrdenMaquilaDet WITH(NOLOCK)
--WHERE	ClaUbicacion = 12 
--AND		IdContratoMaquila IS NULL
--ORDER BY FechaUltimaMod DESC

---------------------------------
USE Operacion
GO

SELECT * FROM OpeSch.OpetraboletaHisVw WHERE IdBoleta = 230540014

-- REVISION POR CONTRATO
SELECT	* FROM OpeSch.OpeTraOrdenMaquilaDet a WITH(NOLOCK)
--LEFT JOIN OpeSch.OpeArtCatArticuloVw b ON 
WHERE	ClaUbicacion = 326 
AND		IdOrdenMaquila = 60

-- REVISION POR CONTRATO
SELECT	* FROM OpeSch.OpeTraContratoMaquila WITH(NOLOCK)
WHERE	ClaUbicacion = 326 
AND		IdContrato IN (91, 97, 99)

SELECT	b.BajaLogica, b.ClaveArticulo,b.NomArticulo, * 
FROM	Opesch.OpeTraOrdenMaquilaDet a WITH(NOLOCK)
LEFT JOIN OpeSch.OpeArtCatArticuloVw b
ON		a.ClaTipoInventario = b.ClaTipoInventario
AND		a.ClaArticulo = b.ClaArticulo
WHERE	ClaUbicacion = 326
AND		IdOrdenMaquila = 60


	select * from OpeSch.OpeTraArticuloComposicion where claubicacion = 326 and claarticulo in (250590, 524319, 524316)
	select * from OpeSch.OpeTraArticuloComposicionDet  where claubicacion = 326 and idarticulocomposicion IN (30, 34, 32)

	SELECT * FROM OpeSch.OpeArtCatArticuloVw WHERE ClaveArticulo = '14901'
	SELECT * FROM OpeSch.OpeArtCatArticuloVw WHERE ClaArticulo = 14901

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