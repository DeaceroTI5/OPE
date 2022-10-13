CREATE PROCEDURE OpeSch.OpeScriptRevisionPesajeBasculaProc
AS
BEGIN
	SET NOCOUNT ON
	
	/*Parámetros*/	-------------------------------------
	DECLARE	  @pnClaUbicacion		INT = 22
			, @pnClaUbicacioOrigen	INT = 22
			, @pnDebug				INT = 0

	DECLARE @tbViajes TABLE (
			  Id		INT IDENTITY(1,1)
			, NumViaje	INT
	)

		/*Viajes a revisar*/	-------------------------------------
	INSERT INTO @tbViajes (NumViaje)
	VALUES	  (248789)
			, (248785)
			, (248867)
			, (248878)
			, (248853)
			, (248871)
			, (248883)
			, (248876)
			, (248862)
			, (248907)

	----------------------------------------------------------------------------------------------------

		DECLARE @tbProducto TABLE (
			  Id			INT IDENTITY(1,1)
			, NumViaje		INT
			, ClaArticulo	INT
		)

		/*Planta*/
		SELECT    a.EstatusTransito
				, a.PesoEntrada
				, a.PesoNeto
				, a.PesoSalida
				, a.NumViaje
				, a.Placas 
				, a.ClaTransporte
				, a.ClaTransportista
				, b.ClaArticulo
				, b.CantidadEnviada 
				, b.CantidadRecibida
				, b.EntradaSalida
				, EstatusTransitoDet = b.EstatusTransito
				, b.KilosPesados
				, b.KilosTeoricos
				, b.PesoTeorico
				, ManPesoTeoricoKgs = c.PesoTeoricoKgs
				, a.ClaUbicacion
				, a.ClaUbicacionOrigen
				, b.ClaUbicacionDestino
		INTO	#Planta
		FROM	OpeSch.OpeTraMovMciasTranEnc a WITH(NOLOCK)
		INNER JOIN OpeSch.OpeTraMovMciasTranDet	b WITH(NOLOCK)
		ON		a.ClaUbicacion		= b.ClaUbicacion		
		AND		a.ClaTipoInventario	= b.ClaTipoInventario	
		AND		a.IdMovimiento		= b.IdMovimiento
		LEFT JOIN opesch.opeartcatarticulovw c
		ON		b.ClaArticulo	= c.ClaArticulo
		INNER JOIN @tbViajes d
		ON		a.NumViaje			= d.NumViaje
		WHERE	a.ClaUbicacion		= @pnClaUbicacion
		and		a.ClaUbicacionOrigen = @pnClaUbicacioOrigen

		/*Central*/
		SELECT    a.EstatusTransito
				, a.PesoEntrada
				, a.PesoNeto
				, a.PesoSalida
				, a.NumViaje
				, a.Placas 
				, a.ClaTransporte
				, a.ClaTransportista
				, b.ClaArticulo
				, b.CantidadEnviada 
				, b.CantidadRecibida
				, b.EntradaSalida
				, EstatusTransitoDet = b.EstatusTransito
				, b.KilosPesados
				, b.KilosTeoricos
				, b.PesoTeorico
				, ManPesoTeoricoKgs = c.PesoTeoricoKgs
				, a.ClaUbicacion
				, a.ClaUbicacionOrigen
				, b.ClaUbicacionDestino
		INTO	#Central
		FROM	DEAOFINET04.Operacion.InvSch.InvTraMovMciasTranEnc a WITH(NOLOCK)
		INNER JOIN DEAOFINET04.Operacion.InvSch.InvTraMovMciasTranDet	b WITH(NOLOCK)
		ON		a.ClaUbicacion		= b.ClaUbicacion		
		AND		a.ClaTipoInventario	= b.ClaTipoInventario	
		AND		a.IdMovimiento		= b.IdMovimiento
		LEFT JOIN opesch.ArtCatArticuloVw c
		ON		c.ClaTipoInventario = 1
		AND		b.ClaArticulo		= c.ClaArticulo
		INNER JOIN @tbViajes d
		ON		a.NumViaje			= d.NumViaje
		WHERE	a.ClaUbicacion		= @pnClaUbicacion
		and		a.ClaUbicacionOrigen = @pnClaUbicacioOrigen

		/*Ventas*/
		SELECT	  d.NumViaje
				, b.ClaArticulo
				, ClaArticuloFab = c.ClaArticulo
				, c.NumeroRenglon
				, a.IdFactura
				, a.IdFabricacion
				, a.ClaClienteCuenta
				, a.ClaConsignado
				, a.KilosSurtidos
				, a.IdFacturaAlfanumerico
				, a.PlacasCamion
				, a.ClaPedidoCliente
				, a.ClaCliente
				, b.CantidadSurtida
				, KilosSurtidosDet = b.KilosSurtidos
				, c.CantidadPedida
				, CantidadSurtidaPedido = c.CantidadSurtida
				, c.ClaEstatusFabricacion
		INTO	#Ventas
		FROM    DEAOFINET05.Ventas.VtaSch.VtaTraFacturaVw a WITH(NOLOCK)
		INNER JOIN DEAOFINET05.Ventas.VtaSch.VtaTraFacturaDetVw b WITH(NOLOCK)
		ON		a.IdFactura = b.IdFactura
		LEFT JOIN DEAOFINET05.Ventas.VtaSch.VtaTraFabricacionDetVw c WITH(NOLOCK)
		ON		b.IdFabricacion = c.IdFabricacion 
		INNER JOIN @tbViajes d
		ON		a.IdViaje			= d.NumViaje
		WHERE   a.ClaUbicacion		= @pnClaUbicacion


		/*Productos x Viaje*/
		INSERT INTO @tbProducto (NumViaje, ClaArticulo)
			SELECT DISTINCT NumViaje, ClaArticulo FROM #Planta
			UNION	SELECT DISTINCT NumViaje, ClaArticulo FROM #Central
			UNION	SELECT DISTINCT NumViaje, ClaArticulo FROM #Ventas


		IF NOT EXISTS (
			SELECT	1
			FROM	#Central a
			INNER JOIN #Planta b
			ON		a.NumViaje = b.NumViaje
			AND		a.ClaArticulo = b.ClaArticulo
			WHERE	(a.PesoEntrada <> b.PesoEntrada)
			OR		(a.PesoNeto	<> b.PesoNeto
			OR		(a.PesoSalida <> b.PesoSalida)
			OR		(a.CantidadEnviada <> b.CantidadEnviada)
			OR		(a.KilosPesados <> b.KilosPesados)
			OR		(a.PesoTeorico <> b.PesoTeorico)
			)
		)
		BEGIN
			SELECT	  UbicacionPlanta	= LTRIM(RTRIM(e.NomUbicacion))
					, UbicacionOrigen	= LTRIM(RTRIM(f.NomUbicacion))
					, UbicacionDestino	= LTRIM(RTRIM(g.NomUbicacion))
					, b.NumViaje
					, c.IdFabricacion
					, Producto =  d.ClaveArticulo + ' - '+ d.NomArticulo
					, KilosSurtidosFactura		= c.KilosSurtidosDet
					, KilosPesadosCental		= b.KilosPesados
					, CantidadSurtidaFactura	= c.CantidadSurtida
					, CantidadEnviadaCentral	= b.CantidadEnviada
					, PesoTeoricoCentral		= b.PesoTeorico
					, PesoTeoricoManufactura	= b.ManPesoTeoricoKgs
					--, pesoteoricokgs Central y Man
			FROM	@tbProducto a
			LEFT JOIN #Planta b
			ON		a.numViaje		= b.NumViaje
			AND		a.ClaArticulo	= b.ClaArticulo
			LEFT JOIN #Ventas c
			ON		a.NumViaje		= c.NumViaje
			AND		a.ClaArticulo			= c.ClaArticulo
			INNER JOIN OpeSch.OpeArtCatArticuloVw d
			ON		a.ClaArticulo			= d.ClaArticulo
			LEFT JOIN OpeSch.OpeTiCatUbicacionVw e
			ON		b.ClaUbicacion			= e.ClaUbicacion
			LEFT JOIN OpeSch.OpeTiCatUbicacionVw f
			ON		b.ClaUbicacionOrigen	= f.ClaUbicacion
			LEFT JOIN OpeSch.OpeTiCatUbicacionVw g
			ON		b.ClaUbicacionDestino	= g.ClaUbicacion
		END
		ELSE
		BEGIN
			SELECT 'Hay diferencias en Planta y Central. Viaje: ' 

			SELECT	  UbicacionPlanta	= LTRIM(RTRIM(e.NomUbicacion))
					, UbicacionOrigen	= LTRIM(RTRIM(f.NomUbicacion))
					, UbicacionDestino	= LTRIM(RTRIM(g.NomUbicacion))
					, a.NumViaje
					, c.IdFabricacion
					, Producto =  d.ClaveArticulo + ' - '+ d.NomArticulo
					, KilosSurtidosFactura		= c.KilosSurtidosDet
					, KilosPesadosPlanta		= b.KilosPesados
					, KilosPesadosCental		= h.KilosPesados
					, CantidadSurtidaFactura	= c.CantidadSurtida
					, CantidadEnviadaPlanta		= b.CantidadEnviada
					, CantidadEnviadaCentral	= h.CantidadEnviada
					, PesoTeoricoPlanta			= b.PesoTeorico
					, PesoTeoricoCentral		= h.PesoTeorico
					, PesoTeoricoManufacturaP	= b.ManPesoTeoricoKgs
					, PesoTeoricoManufacturaC	= h.ManPesoTeoricoKgs
					--, pesoteoricokgs Central y Man
			FROM	@tbProducto a
			LEFT JOIN #Planta b
			ON		a.numViaje		= b.NumViaje
			AND		a.ClaArticulo	= b.ClaArticulo
			LEFT JOIN #Central h
			ON		a.numViaje		= h.NumViaje
			AND		a.ClaArticulo	= h.ClaArticulo
			LEFT JOIN #Ventas c
			ON		a.NumViaje		= c.NumViaje
			AND		a.ClaArticulo	= c.ClaArticulo
			INNER JOIN OpeSch.OpeArtCatArticuloVw d
			ON		a.ClaArticulo			= d.ClaArticulo
			LEFT JOIN OpeSch.OpeTiCatUbicacionVw e
			ON		b.ClaUbicacion			= e.ClaUbicacion
			LEFT JOIN OpeSch.OpeTiCatUbicacionVw f
			ON		b.ClaUbicacionOrigen	= f.ClaUbicacion
			LEFT JOIN OpeSch.OpeTiCatUbicacionVw g
			ON		b.ClaUbicacionDestino	= g.ClaUbicacion
		END

	IF @pnDebug = 1
	BEGIN
		SELECT '' AS '#Central',* FROM #Central
		SELECT '' AS '#Planta', * FROM #Planta
		SELECT '' AS '#Ventas', * FROM #Ventas
	END
	
	DROP TABLE #Planta,#Central, #Ventas

	SET NOCOUNT OFF
END