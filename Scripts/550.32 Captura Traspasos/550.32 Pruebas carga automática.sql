DECLARE	@pnClaPedidoOrigen INT

	-- Pedidos Origen
	--SELECT ClaEstatus FROM OpeSch.OpeTraFabricacionVw where idfabricacion = 23047486

	-- Consulta Agregar Articulos 
	SELECT	  a.IdFabricacion
			, b.ClaArticulo
			, Producto = c.ClaveArticulo + ' - ' + c.NomArticulo
			, a.ClaEstatus
			, b.ClaEstatusFabricacion 
			, b.CantidadPedida
			, Corruga = ClaValor
	INTO	#Universo
	FROM    OpeSch.OpeTraFabricacionVw a WITH(NOLOCK)
	INNER  JOIN DEAOFINET05.Ventas.VtaSch.VtaTraFabricacionDetVw b
	ON		a.IdFabricacion		= b.IdFabricacion
	INNER JOIN  OpeSch.OpeArtCatArticuloVw c WITH(NOLOCK)  
	ON		b.ClaArticulo		= c.ClaArticulo AND c.ClaTipoInventario = 1
	INNER JOIN OpeSch.OpeArtCatUnidadVw d WITH(NOLOCK)  
	ON		c.ClaUnidadBase		= d.ClaUnidad AND d.ClaTipoInventario = 1
	INNER JOIN  OpeSch.OpeVtaRelFabricacionProyectoVw e WITH(NOLOCK)  
	ON		a.IdFabricacion		= e.IdFabricacion
	INNER JOIN  OpeSch.OpeVtaCatProyectoVw f WITH(NOLOCK)  
	ON		e.ClaProyecto		= f.ClaProyecto
	LEFT JOIN OpeSch.OpeArtRelArticuloCarValorVw as g		--Corruga
	ON		g.ClaTipoInventario = 1
	AND		b.ClaArticulo		= g.ClaArticulo
	AND		g.ClaCaracteristica = 1097
	AND		g.BajaLogica		= 0
	WHERE	1 = 1
--	AND		g.ClaValor			= 5 -- Corruga
	AND		b.ClaEstatusFabricacion IN (4,5)
--	AND		b.CantidadPedida	> 10000
	AND		a.ClaEstatus		= 1   

	SELECT	IdFabricacion, COUNT(1) Conteo 
	FROM	#Universo
	GROUP BY IdFabricacion
	HAVING COUNT(1) > 1
	ORDER BY Conteo DESC

	--- Actualizar Estatus (Activo)
	UPDATE	a
	SET		ClaEstatus = 1
--	SELECT	ClaEstatus
	FROM	OPESch.OpeTraFabricacion a 
	WHERE	IdFabricacion IN (24280918, 24283053, 24269340, 23954981,23984742,24237492)

	UPDATE	b
	SET		ClaEstatus = 1
--	SELECT	ClaEstatus
	FROM	OpeSch.OpeTraFabricacionDetVw b
	WHERE	IdFabricacion IN (24280918, 24283053, 24269340, 23954981,23984742,24237492)

	SELECT * FROM #Universo a
	WHERE EXISTS ( 
		SELECT	1
		FROM	#Universo b
		WHERE	a.IdFabricacion = b.IdFabricacion
		GROUP BY IdFabricacion
		HAVING COUNT(1) > 1
		)
	


	DROP TABLE #Universo

	SELECT	nChkPesoNormaPO = EsPesoNorma
	FROM	DEAOFINET05.Ventas.VtaSch.VtaTraFabricacionVw c WITH(NOLOCK)  
    WHERE	c.IdFabricacion = 24280918--@pnClaPedidoOrigen

/*
	-- ERROR CantidadDisponible = 0
	SELECT * FROM OpeSch.OpeTraSolicitudTraspasoEncVw WHERE ClaPedidoOrigen = 24237492

	DELETE FROM OpeSch.OpeTraSolicitudTraspasoDetVw WHERE IdSolicitudTraspaso = 27
	DELETE FROM OpeSch.OpeTraSolicitudTraspasoEncVw WHERE IdSolicitudTraspaso = 27
*/
	SELECT	IdFabricacion, CantPedida 
	FROM	OpeSch.OpeTraFabricacionDetVw a
	WHERE	EXISTS (	SELECT 1
						FROM #Universo b
						WHERE	a.IdFabricacion = b.IdFabricacion
					)



	----------------------------------------------
	

	-- Exportación
	SELECT	a.IdFabricacion
	INTO	#PedidosActivos
	FROM    DEAOFINET05.Ventas.VtaSch.VtaTraFabricacionVw a WITH(NOLOCK)
	WHERE	a.ClaEstatusFabricacion = 1   

	SELECT * FROM #PedidosActivos

	-- Clientes por relación de Ubicaciones
	SELECT	b.ClaUbicacionOrigen,
			b.ClaUbicacionDestino,
			a.ClaCliente,
            a.NomCliente     
    FROM	OpeSch.OpeVtaCatClienteVw a WITH(NOLOCK)  
    INNER JOIN  OpeSch.OpeCatClienteFilialVw b WITH(NOLOCK)  
        ON  a.ClaCliente = b.ClaClienteFilial
	ORDER BY b.ClaUbicacionOrigen DESC, b.ClaUbicacionDestino DESC

	-- Proyectos
    SELECT	DISTINCT
			a.ClaProyecto,
			a.NomProyecto,
			c.IdFabricacion
	INTO	#Proyectos
	FROM	OpeSch.OpeVtaCatProyectoVw a WITH(NOLOCK)  
	INNER JOIN	OpeSch.OpeVtaRelFabricacionProyectoVw b WITH(NOLOCK)  
		ON	a.ClaProyecto = b.ClaProyecto
	INNER JOIN	OpeSch.OpeTraFabricacionVw c WITH(NOLOCK)  
		ON	b.IdFabricacion = c.IdFabricacion
	INNER JOIN	(
		SELECT	ClaUbicacion
		FROM	OpeSch.OpeTiCatUbicacionVw WITH(NOLOCK)  
		WHERE	(ClaEmpresa IN (52)
		OR		ClaUbicacion IN (277,278,364))	
	) d
		ON	c.ClaPlanta = d.ClaUbicacion
	WHERE	1=1-- (c.IdFabricacion = @pnClaPedidoOrigen OR @pnClaPedidoOrigen = 0)
	AND		(	/*@pnTipo*/ 1 =99	
				OR	(	ISNULL(/*@pnBajasSn*/0,0) = 1	
						OR (	ISNULL(a.BajaLogica,0) = 0	-- Considerar los registros activos e inactivos que su fecha de Baja sea mayor a la fecha actual.
								OR (	ISNULL(a.BajaLogica,0) = 1 
										AND a.FechaBajaLogica IS NOT NULL 
										AND a.FechaBajaLogica >= GETDATE()	)
							)
					)
			)

	SELECT  DISTINCT
			FabricacionCPO      = a.IdFabricacion,
			NoRenglonCPO        = b.IdFabricacionDet,
			ClaProductoCPO      = c.ClaArticulo,
			UnidadCPO           = d.NomCortoUnidad,
			CantPedidaCPO       = ISNULL( b.CantPedida,0.00 ),
			PrecioListaCPO      = ISNULL( b.PrecioLista,0.00 ),
			PesoTeoricoCPO      = c.PesoTeoricoKgs,
			CantidadMinAgrupCPO = ISNULL( i.CantidadMinAgrup,0.00 ),
			EsMultiploCPO       = ISNULL( i.Multiplo,0 ),
			ClaProyecto			= e.ClaProyecto,
			ClaEstatusDet		= ISNULL(b.ClaEstatus,0)
	FROM    OpeSch.OpeTraFabricacionVw a WITH(NOLOCK)  
	INNER JOIN  OpeSch.OpeTraFabricacionDetVw b WITH(NOLOCK)  
       ON  a.IdFabricacion = b.IdFabricacion
	INNER JOIN  OpeSch.OpeArtCatArticuloVw c WITH(NOLOCK)  
       ON  b.ClaArticulo = c.ClaArticulo AND c.ClaTipoInventario = 1
	INNER JOIN  OpeSch.OpeArtCatUnidadVw d WITH(NOLOCK)  
       ON  c.ClaUnidadBase = d.ClaUnidad AND d.ClaTipoInventario = 1
	INNER JOIN  OpeSch.OpeVtaRelFabricacionProyectoVw e WITH(NOLOCK)  
       ON  a.IdFabricacion = e.IdFabricacion
	INNER JOIN  OpeSch.OpeVtaCatProyectoVw f WITH(NOLOCK)  
       ON  e.ClaProyecto = f.ClaProyecto
	LEFT JOIN   OpeSch.OpeManCatArticuloDimensionVw i WITH(NOLOCK)  
       ON  b.ClaArticulo = i.ClaArticulo
	LEFT JOIN #PedidosActivos g
	ON		a.IdFabricacion = g.IdFabricacion
	WHERE	b.ClaEstatus <> 1
--	WHERE  a.IdFabricacion = @pnClaPedidoOrigen

	



	-- otras solicitudes
	SELECT	  ClaPedido
			, b.ClaProducto
	FROM	OpeSch.OpeTraSolicitudTraspasoEnc a WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTraSolicitudTraspasoDet b WITH(NOLOCK)
	ON		a.IdSolicitudTraspaso	= b.IdSolicitudTraspaso
	WHERE	(193 IS NULL OR (a.IdSolicitudTraspaso <> 193))
	AND		a.ClaPedidoOrigen = 23047486
	AND		(0 = 0 OR(b.ClaProducto = 0))
	GROUP BY a.ClaPedido, b.ClaProducto

	-- otras solicitudes
	SELECT	  ClaPedido
			, b.ClaProducto
	FROM	OpeSch.OpeTraSolicitudTraspasoEnc a WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTraSolicitudTraspasoDet b WITH(NOLOCK)
	ON		a.IdSolicitudTraspaso	= b.IdSolicitudTraspaso
	WHERE	a.IdSolicitudTraspaso = 192



	-- ajuste de estatus activo
	UPDATE	a
	SET		ClaEstatus = 1
	FROM	OpeSch.OpeTraFabricacionDetVw a
	WHERE	IdFabricacion = 23047486	-- ClaPedidoOrigen
	AND		ClaEstatus = 3
	
	-- ajuste de estatus activo
	UPDATE	a
	SET		ClaEstatus = 1 --3
	FROM	OpeSch.OpeTraFabricacionDetVw a
	WHERE	IdFabricacion = 23047486	-- ClaPedidoOrigen
	AND		IdFabricacionDet in (3,5)


	-- actualizacion clapedido a solicitud
	UPDATE	a
	SET		ClaPedido = 23070186 -- null
--	SELECT	* 
	FROM	OpeSch.OpeTraSolicitudTraspasoEnc a
	WHERE	IdSolicitudTraspaso = 192