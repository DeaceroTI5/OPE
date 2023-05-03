USE Operacion
GO
-- 'OpeSch.OpeScriptRevisionPesajeBasculaProc'
CREATE PROCEDURE OpeSch.OpeScriptRevisionPesajeBasculaProc
	  @pnClaUbicacion		INT = NULL
	, @pnClaUbicacionOrigen	INT = NULL
	, @dFechaHoraMovimiento	DATE = '20221001'
	, @pnDebug				INT = 0
	, @pnNumViaje			INT = NULL
AS
BEGIN
	SET NOCOUNT ON

	/*
	 EXEC OpeSch.OpeScriptRevisionPesajeBasculaProc 
		  @pnClaUbicacion		= NULL
		, @pnClaUbicacionOrigen	= NULL
		, @dFechaHoraMovimiento	= '20221001'
		, @pnDebug				= 0
		, @pnNumViaje			= NULL
	*/


	DECLARE @tbViajesPlanta TABLE (
			  Id					INT IDENTITY(1,1)
			, ClaUbicacion			INT
			, ClaUbicacionOrigen	INT
			, NumViaje				INT
			, ClaUbicacionDestino	INT
			, ClaArticulo			INT
			, IdMovimiento			INT
			, IdRenglon				INT
	--		, Placas				VARCHAR(12)
			, PesoEntrada			NUMERIC(22,4)
			, PesoNeto				NUMERIC(22,4)
			, PesoSalida			NUMERIC(22,4)
			, CantidadEnviada		NUMERIC(22,4)
			, CantidadRecibida		NUMERIC(22,4)
			, EntradaSalida			INT
			, KilosPesados			NUMERIC(22,4)
			, KilosTeoricos			NUMERIC(22,4)
			, PesoTeorico			NUMERIC(22,4)
			, ManPesoTeoricoKgs		NUMERIC(22,4)
			, IdFabricacion			INT
			, ClaTipoInventario		INT
	)

	DECLARE @tbDiferenciasPlantaCentral TABLE(
		  ClaUbicacion					INT
		, ClaTipoInventario				INT
		, ClaUbicacionOrigen			INT
		, ClaUbicacionDestino			INT
		, ClaArticulo					INT
		, NumViaje						INT
		, KilosPesadosPlanta			NUMERIC(22,4)
		, KilosPesadosCental			NUMERIC(22,4)
		, CantidadEnviadaPlanta			NUMERIC(22,4)
		, CantidadEnviadaCentral		NUMERIC(22,4)
		, PesoTeoricoPlanta				NUMERIC(22,4)
		, PesoTeoricoCentral			NUMERIC(22,4)
		, PesoTeoricoManufacturaP		NUMERIC(22,4)
		, PesoTeoricoManufacturaC		NUMERIC(22,4)
		, IdMovimiento					INT
		, IdRenglon						INT
		, IdFabricacion					INT
	)

	DECLARE @tbProducto			TABLE (
		  Id					INT IDENTITY(1,1)
		, ClaUbicacion			INT
		, ClaUbicacionOrigen	INT
		, NumViaje				INT
		, ClaArticulo			INT
	)


	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----/* Planta */
	INSERT INTO @tbViajesPlanta ( 
		  ClaUbicacion			
		, ClaUbicacionOrigen	
		, NumViaje				
		, ClaUbicacionDestino	
		, ClaArticulo			
		, IdMovimiento			
		, IdRenglon				
	--	, Placas				
		, PesoEntrada			
		, PesoNeto				
		, PesoSalida			
		, CantidadEnviada		
		, CantidadRecibida		
		, EntradaSalida			
		, KilosPesados			
		, KilosTeoricos			
		, PesoTeorico
		, ManPesoTeoricoKgs
		, IdFabricacion
		, ClaTipoInventario
	)
	SELECT	DISTINCT 
			  a.ClaUbicacion				
			, a.ClaUbicacionOrigen
			, a.NumViaje	
			, b.ClaUbicacionDestino
			, b.claArticulo
			, a.IdMovimiento
			, b.IdRenglon
	--		, a.Placas
			, a.PesoEntrada
			, a.PesoNeto
			, a.PesoSalida
			, b.CantidadEnviada 
			, b.CantidadRecibida
			, b.EntradaSalida
			, b.KilosPesados
			, b.KilosTeoricos
			, b.PesoTeorico
			, ManPesoTeoricoKgs = e.PesoTeoricoKgs
			, b.ReferenciaCompras
			, a.ClaTipoInventario
	FROM	OpeSch.OpeTraMovMciasTranEnc a WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTraMovMciasTranDet	b WITH(NOLOCK)
	ON		a.ClaUbicacion		= b.ClaUbicacion		
	AND		a.ClaTipoInventario	= b.ClaTipoInventario	
	AND		a.IdMovimiento		= b.IdMovimiento
	INNER JOIN OpeSch.OpeTiCatUbicacionVw c
	ON		a.ClaUbicacionOrigen	= c.ClaUbicacion
	INNER JOIN OpeSch.OpeTiCatUbicacionVw d
	ON		b.ClaUbicacionDestino	= d.ClaUbicacion
	LEFT JOIN opesch.ArtCatArticuloVw e
	ON		e.ClaTipoInventario		= 1
	AND		b.ClaArticulo			= e.ClaArticulo	
	WHERE	(@pnClaUbicacion IS NULL OR (a.ClaUbicacion = @pnClaUbicacion))
	AND		(@pnClaUbicacionOrigen IS NULL OR (a.ClaUbicacionOrigen = @pnClaUbicacionOrigen))
	AND		(@pnNumViaje IS NULL OR (a.NumViaje = @pnNumViaje))
	AND		a.FechaHoraMovimiento	>= @dFechaHoraMovimiento
	AND		a.ClaUbicacion			<> b.ClaUbicacionDestino
	AND		a.EstatusTransito		=  0	-- En tránsito
	AND		c.ClaTipoUbicacion		=  2	-- Acerías
	AND		d.ClaEmpresa			=  52	-- INGETEK


	/*Central*/
	SELECT    a.PesoEntrada
			, a.PesoNeto
			, a.PesoSalida
			, a.NumViaje
			, a.ClaTransporte
			, a.ClaTransportista
			, b.ClaArticulo
			, b.CantidadEnviada 
			, b.CantidadRecibida
			, b.EntradaSalida
			, b.KilosPesados
			, b.KilosTeoricos
			, b.PesoTeorico
			, ManPesoTeoricoKgs = c.PesoTeoricoKgs
			, a.ClaUbicacionOrigen
			, b.ClaUbicacionDestino
			, a.ClaUbicacion
			, a.ClaTipoInventario
			, b.IdRenglon
			, a.IdMovimiento
	INTO	#Central
	FROM	DEAOFINET04.Operacion.InvSch.InvTraMovMciasTranEnc a WITH(NOLOCK)
	INNER JOIN DEAOFINET04.Operacion.InvSch.InvTraMovMciasTranDet	b WITH(NOLOCK)
	ON		a.ClaUbicacion		= b.ClaUbicacion		
	AND		a.ClaTipoInventario	= b.ClaTipoInventario	
	AND		a.IdMovimiento		= b.IdMovimiento
	INNER JOIN @tbViajesPlanta d
	ON		a.ClaUbicacion			= d.ClaUbicacion
	AND		a.ClaTipoInventario		= d.ClaTipoInventario
	AND		b.IdRenglon				= d.IdRenglon
	AND		a.IdMovimiento			= d.IdMovimiento
	LEFT JOIN opesch.ArtCatArticuloVw c
	ON		c.ClaTipoInventario = 1
	AND		b.ClaArticulo		= c.ClaArticulo

	/*Ventas*/
	SELECT	DISTINCT
			  a.ClaUbicacion
			, d.NumViaje
			, b.ClaArticulo
			, a.IdFabricacion
			, b.CantidadSurtida
			, KilosSurtidosDet	= b.KilosSurtidos
	INTO	#Ventas
	FROM    DEAOFINET05.Ventas.VtaSch.VtaTraFacturaVw a WITH(NOLOCK)
	INNER JOIN DEAOFINET05.Ventas.VtaSch.VtaTraFacturaDetVw b WITH(NOLOCK)
	ON		a.IdFactura			= b.IdFactura
	INNER JOIN @tbViajesPlanta d
	ON		a.ClaUbicacion		= d.ClaUbicacion
	AND		a.IdViaje			= d.NumViaje
	AND		a.IdFabricacion		= d.IdFabricacion
	AND		b.ClaArticulo		= d.ClaArticulo


	---- /* Revisar Diferencias Planta Vs. Central */
	IF EXISTS (
		SELECT	1
		FROM	@tbViajesPlanta a
		INNER JOIN #Central b
		ON		a.ClaUbicacion		= b.ClaUbicacion
		AND		a.ClaTipoInventario = b.ClaTipoInventario
		AND		a.IdRenglon			= b.IdRenglon
		AND		a.IdMovimiento		= b.IdMovimiento
		WHERE	((a.PesoEntrada		<> b.PesoEntrada)
		OR		(a.PesoNeto			<> b.PesoNeto)
		OR		(a.PesoSalida		<> b.PesoSalida)
		OR		(a.CantidadEnviada	<> b.CantidadEnviada)
		OR		(a.KilosPesados		<> b.KilosPesados)
		OR		(a.PesoTeorico		<> b.PesoTeorico))
	)
	BEGIN
		INSERT INTO @tbDiferenciasPlantaCentral(
			  ClaUbicacion
			, ClaTipoInventario
			, ClaUbicacionOrigen		
			, ClaUbicacionDestino		
			, ClaArticulo				
			, NumViaje					
			, KilosPesadosPlanta		
			, KilosPesadosCental		
			, CantidadEnviadaPlanta		
			, CantidadEnviadaCentral	
			, PesoTeoricoPlanta			
			, PesoTeoricoCentral		
			, PesoTeoricoManufacturaP	
			, PesoTeoricoManufacturaC
			, IdMovimiento	
			, IdRenglon		
			, IdFabricacion
		)
		SELECT	DISTINCT
				  a.ClaUbicacion
				, a.ClaTipoInventario
				, a.ClaUbicacionOrigen
				, b.ClaUbicacionDestino
				, a.ClaArticulo
				, a.NumViaje
				, KilosPesadosPlanta		= b.KilosPesados
				, KilosPesadosCental		= a.KilosPesados
				, CantidadEnviadaPlanta		= b.CantidadEnviada
				, CantidadEnviadaCentral	= a.CantidadEnviada
				, PesoTeoricoPlanta			= b.PesoTeorico
				, PesoTeoricoCentral		= a.PesoTeorico
				, PesoTeoricoManufacturaP	= a.PesoTeorico
				, PesoTeoricoManufacturaC	= b.ManPesoTeoricoKgs
				, a.IdMovimiento	
				, a.IdRenglon		
				, a.IdFabricacion
		FROM	@tbViajesPlanta a
		INNER JOIN #Central b
		ON		a.ClaUbicacion		= b.ClaUbicacion
		AND		a.ClaTipoInventario = b.ClaTipoInventario
		AND		a.IdRenglon			= b.IdRenglon
		AND		a.IdMovimiento		= b.IdMovimiento
		WHERE	((a.PesoEntrada		<> b.PesoEntrada)
		OR		(a.PesoNeto			<> b.PesoNeto)
		OR		(a.PesoSalida		<> b.PesoSalida)
		OR		(a.CantidadEnviada	<> b.CantidadEnviada)
		OR		(a.KilosPesados		<> b.KilosPesados)
		OR		(a.PesoTeorico		<> b.PesoTeorico))
	END

	
	IF EXISTS(	SELECT	1
				FROM	@tbDiferenciasPlantaCentral
	)
	BEGIN	---- /*Resultado de diferencias Planta Vs Central */
		SELECT 'Diferencias Planta Vs Central'
		SELECT '' AS 'Diferencias' , * FROM @tbDiferenciasPlantaCentral
	END



	---- /*Resultado*/
	SELECT	  [Ubicacion Planta]		= CONVERT(VARCHAR(10),a.ClaUbicacion) + ' - ' + LTRIM(RTRIM(e.NomUbicacion))
			, [Ubicacion Origen]		= CONVERT(VARCHAR(10),a.ClaUbicacionOrigen) + ' - ' +LTRIM(RTRIM(f.NomUbicacion))
			, [Ubicacion Destino]		= CONVERT(VARCHAR(10),a.ClaUbicacionDestino) + ' - ' + LTRIM(RTRIM(g.NomUbicacion))
			, [Num Viaje]				= a.NumViaje
			, [Fabricacion]				= c.IdFabricacion
			, Producto					=  d.ClaveArticulo + ' - '+ d.NomArticulo
			, [Kilos Surtidos Factura]	= c.KilosSurtidosDet
			, [Kilos Pesados Cental]	= a.KilosPesados
			, [Cantidad Surtida Factura]= c.CantidadSurtida
			, [Cantidad Enviada Central]= a.CantidadEnviada
			, [Peso Teorico Central]	= a.PesoTeorico
			, [Peso Teorico MAN.]		= a.ManPesoTeoricoKgs
			, [Hay dif. Peso]			= CASE WHEN (c.KilosSurtidosDet <> a.KilosPesados) THEN 1 ELSE 0 END
			, [Hay dif. Cantidad]		= CASE WHEN (c.CantidadSurtida	<> a.CantidadEnviada) THEN 1 ELSE 0 END
			, [Hay Diferencia Peso Teorico] = CASE WHEN (a.PesoTeorico <> a.ManPesoTeoricoKgs) THEN 1 ELSE 0 END	
	FROM	@tbViajesPlanta a
	LEFT JOIN #Ventas c
	ON		a.ClaUbicacion			= c.ClaUbicacion
	AND		a.NumViaje				= c.NumViaje
	AND		a.IdFabricacion			= c.IdFabricacion
	AND		a.ClaArticulo			= c.ClaArticulo
	INNER JOIN OpeSch.OpeArtCatArticuloVw d
	ON		a.ClaArticulo			= d.ClaArticulo
	LEFT JOIN OpeSch.OpeTiCatUbicacionVw e
	ON		a.ClaUbicacion			= e.ClaUbicacion
	LEFT JOIN OpeSch.OpeTiCatUbicacionVw f
	ON		a.ClaUbicacionOrigen	= f.ClaUbicacion
	LEFT JOIN OpeSch.OpeTiCatUbicacionVw g
	ON		a.ClaUbicacionDestino	= g.ClaUbicacion
	WHERE	(
				(c.KilosSurtidosDet <> a.KilosPesados)
		OR		(c.CantidadSurtida	<> a.CantidadEnviada)
		OR		(a.PesoTeorico		<> a.ManPesoTeoricoKgs)
	) 
	AND	NOT EXISTS (
		SELECT	1
		FROM	@tbDiferenciasPlantaCentral h
		WHERE	a.ClaUbicacion		 = h.Claubicacion
		AND		a.ClaTipoInventario	 = h.ClaTipoInventario
		AND		a.IdMovimiento		 = h.IdMovimiento
		AND		a.IdRenglon			 = h.IdRenglon
	)



	IF @pnDebug = 1
	BEGIN
		SELECT '' AS '@tbViajesPlanta', * FROM @tbViajesPlanta
		SELECT '' AS '#Central',* FROM #Central
		SELECT '' AS '#Ventas', * FROM #Ventas	
	END
	
	DROP TABLE #Central, #Ventas

	SET NOCOUNT OFF
END
