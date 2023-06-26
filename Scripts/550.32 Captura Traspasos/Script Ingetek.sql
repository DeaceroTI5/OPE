USE Operacion
GO

	-- Obtener Plan de Carga del Viaje
	SELECT	@nIdPlanCarga = IdPlanCarga
	FROM	OpeSch.OpeTraViaje WITH(NOLOCK)
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		IdViaje		 = @pnIdViajeMod4

	-- Obtener Factura (IdDocumento) de un viaje
	SELECT	@nIdFactura = t2.IdFactura 	
	FROM	OpeSch.OpeTraViaje t1 WITH(NOLOCK)
	LEFT JOIN OpeSch.OpeTraMovEntSal t2 WITH(NOLOCK)
	ON		t1.ClaUbicacion = t2.ClaUbicacion
	AND		t1.IdViaje		= t2.IdViaje
	WHERE	t1.ClaUbicacion	= @pnClaUbicacion
	AND		t1.IdViaje		= @pnIdViajeMod
	AND		t1.ClaEstatus	= 3				-- cerrado

	--'%%estatus%'
	--SELECT * FROM dbo.TiCatEstatusVw WHERE ClaClasificacionEstatus = 1270003

	--SELECT * FROM dbo.TiCatClasificacionEstatusVw
	--OpeSch.OpeTiCatestatusVw
	--140001	Estatus de Facturas
	--1270002	Estatus de Orden de Carga
	--1270003	Estatus de Viaje
	--1270004	Estatus de Pedidos
	--1270005	Estatus de Entradas/Salidas

	-- Obtener Producto con base al Viaje y Pedido
	SELECT	Producto = CONVERT(VARCHAR(10),c.ClaveArticulo) + ' - ' + C.NomArticulo
	FROM	OpeSch.OpeTraViaje a WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTraPlanCargaDet b WITH(NOLOCK)
	ON		a.ClaUbicacion	= b.ClaUbicacion
	AND		a.IdPlanCarga	= b.IdPlanCarga
	INNER JOIN OpeSch.OpeArtCatArticuloVw c
	ON		b.ClaArticulo	= c.ClaArticulo
	WHERE	a.IdViaje = @pnIdViajeMod4
	AND		b.IdFabricacion = @pnClaFabricacion
	AND		b.IdFabricacionDet = @pnClaFabricacionDet


	-- Obtener Colada y Secuencia con base a la Remisión
	SELECT	DISTINCT HeatID
			, IdColada	= SUBSTRING(HeatID,1,CHARINDEX('-',HeatID)-1)
			, Secuencia	= SUBSTRING(HeatID,CHARINDEX('-',HeatID)+1,LEN(HeatID))
	FROM	OpeSch.OPEASAShippingTicketHeatData WITH(NOLOCK)
	WHERE	ShipID = @psShipIdMod4

	-- Catalogo de Tipo de Documento 
	SELECT * FROM opesch.OpeCatFormatoImpresion

	-- En que tablas se guarda el documento 
	SELECT * FROM OpeSch.OpeRelViajeDocumento

	--(2do Grid) Principal esta se relaciona mediante el IdViaje Y ClaUbicacion
	SELECT * FROM OpeSch.OpeRelViajeShipID			-- Relacion de Remisión por Viaje  
	SELECT * FROM opesch.OPEASAShippingTicket       --JOIN mediante ShipID
