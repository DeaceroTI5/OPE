	DECLARE   @pnNumViaje			INT = 248907
			, @pnClaUbicacion		INT = 22
			, @pnClaUbicacioOrigen	INT = 22

		CREATE TABLE #Producto (
			  Id			INT IDENTITY(1,1)
			, ClaArticulo	INT
		)


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
		WHERE	a.ClaUbicacion = @pnClaUbicacion
		and		a.ClaUbicacionOrigen = @pnClaUbicacioOrigen
		AND		a.NumViaje = @pnNumViaje


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
		AND		b.ClaArticulo	= c.ClaArticulo
		WHERE	a.ClaUbicacion = @pnClaUbicacion
		and		a.ClaUbicacionOrigen = @pnClaUbicacioOrigen
		AND		a.NumViaje = @pnNumViaje


		SELECT	  b.ClaArticulo
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
		WHERE   a.ClaUbicacion = @pnClaUbicacion
		AND		a.IdViaje = @pnNumViaje


		INSERT INTO #Producto (ClaArticulo)
			SELECT DISTINCT ClaArticulo FROM #Planta
			UNION	SELECT DISTINCT ClaArticulo FROM #Central
			UNION	SELECT DISTINCT ClaArticulo FROM #Ventas

		--SELECT * FROM DEAOFINET05.Ventas.VtaSch.VtaTraFabricacionDetVw WHERE IdFabricacion = 24245817

		IF NOT EXISTS (
			SELECT	1
			FROM	#Central a
			INNER JOIN #Planta b
			ON		a.ClaArticulo = b.ClaArticulo
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
			FROM	#Producto a
			LEFT JOIN #Planta b
			ON		a.ClaArticulo	= b.ClaArticulo
			LEFT JOIN #Ventas c
			ON		a.ClaArticulo			= c.ClaArticulo
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
			SELECT 'Hay diferencias en Planta y Central. Viaje: ' + CONVERT(VARCHAR(10),@pnNumViaje) 
		END

		--- mostrar ubicacion del registro y la ubicacion Origen, Destino , Viaje Origen (aceria)





	--CREATE TABLE @tbViajes(
	--	  Id	INT IDENTITY(1,1)
	--	, Viaje	INT
	--)

	--DECLARE @nViaje INT	


	--WHILE @nViaje IS NOT NULL
	--BEGIN
			
		
	--END

	DROP TABLE #Planta,#Central, #Ventas, #Producto