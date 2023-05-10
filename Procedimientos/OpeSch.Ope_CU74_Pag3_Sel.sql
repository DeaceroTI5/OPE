CREATE PROCEDURE  OpeSch.Ope_CU74_Pag3_Sel
	@pnIdPlanCarga		int,
	@pnClaUbicacion		int			
AS
BEGIN 
	
	DECLARE @nEsTieneTransaccion	INT,
			@sErrorMsg				varchar(800)		
	
	DECLARE --@nPorcSemaforo				NUMERIC(22,8),
			@nTonsEmbarcadas			NUMERIC(22,8),
			@nPorcEficienciaCarga		NUMERIC(22,8),
			@nTonsCubicadas				NUMERIC(22,8),
			@nPorEficienciaCubicada		NUMERIC(22,8),
			@nClaTransporte				INT,
			@nCapacidadTransporte		NUMERIC(22,8),
			--@nCubicajeTransp			NUMERIC(22,8),
			@sTonsEmbarcadasChar		VARCHAR(30),
			@sTonsCubicadasChar			VARCHAR(30)
	
	--SELECT @nPorcSemaforo = PorcentajeSemaforo 
	--FROM PleSch.PleCfgPlaneacionEmbarque WITH(NOLOCK)
	--WHERE ClaUbicacion = @pnClaUbicacion 
	
	--set @nPorcSemaforo = isnull(@nPorcSemaforo, 3)  
	IF (@pnIdPlanCarga IS NOT NULL)
	BEGIN
		SELECT		@nClaTransporte			= transporte.ClaTransporte,
					@nCapacidadTransporte	= transporte.Capacidad / 1000.00--, @nCubicajeTransp		= cubicaje
		FROM		OpeSch.OpeTraPlanCarga			AS preplan		WITH(NOLOCK)
		LEFT JOIN	OpeSch.OPEFleCatTransporteVw	AS transporte	WITH(NOLOCK)	ON	(transporte.ClaTransporte = preplan.Clatransporte)
		WHERE		preplan.ClaUbicacion	= @pnClaUbicacion
		AND			preplan.IdPlanCarga		= @pnIdPlanCarga
		
		
		SELECT		@nTonsEmbarcadas			= SUM(PesoEmbarcado) / 1000.00,
					@nPorcEficienciaCarga		= CASE WHEN @nCapacidadTransporte > 0 THEN ((SUM(ISNULL(PesoEmbarcado / 1000.00,0) )    ) / @nCapacidadTransporte) * 100 ELSE 0 END,
					@nTonsCubicadas				= SUM(a.PesoCub),--/1000.00, --sum(a.PesoEmbarcado * isnull(b.FactorCubicaje, 1) ) --/1000.00,
					@nPorEficienciaCubicada		= CASE WHEN @nCapacidadTransporte > 0 THEN ((SUM(a.PesoCub) /*/1000.00*/    ) / @nCapacidadTransporte) * 100 ELSE 0 END     
													--CASE WHEN @nCubicajeTransp > 0 THEN ((SUM(a.PesoCub) /*/1000.00*/    ) / @nCubicajeTransp) * 100 ELSE 0 END     
													--CASE WHEN @nCapacidadTransporte > 0 THEN ((sum(a.PesoEmbarcado * isnull(b.FactorCubicaje, 1) ) /1000.00    ) / @nCapacidadTransporte) * 100 ELSE 0 END     
		from		OpeSch.OpeTraPlanCargaDet			as a with(nolock)  
		LEFT JOIN	OpeSch.OpeRelArtTranspCubicajeVw as b with(nolock) ON	b.ClaArticulo		= a.ClaArticulo  
																			and isnull(b.BajaLogica, 0) = 0
																			and b.ClaTransporte	  = @nClaTransporte
		WHERE		a.IdPlanCarga = @pnIdPlanCarga
		AND			a.ClaUbicacion = @pnClaUbicacion
			
		SELECT	@sTonsEmbarcadasChar	= CONVERT(VARCHAR(30), @nTonsEmbarcadas),
				@sTonsCubicadasChar		= CONVERT(VARCHAR(30), @nTonsCubicadas)
			
	
	--regresamos la información a la pantalla  

		SELECT	--IdPlanCarga,
				ClaRuta,
				preplan.ClaTransporte,
				ClaTipoViaje,
				FechaPlanEmbarque			=	FechaPlan,
				CapacidadTransporte			=	@nCapacidadTransporte,
				TonsEmbarcadas				=	SUBSTRING(@sTonsEmbarcadasChar, 1, CHARINDEX('.', @sTonsEmbarcadasChar) + 2),
				PorcEficienciaCarga			=	@nPorcEficienciaCarga,
				TonsCubicadas				=	SUBSTRING(@sTonsCubicadasChar, 1, CHARINDEX('.', @sTonsCubicadasChar) + 2),
				PorEficienciaCubicada		=	@nPorEficienciaCubicada,			
				preplan.ClaTransportista,
				NomEstatusPlanCarga			=	NombreEstatus,
				ClaOperadorPlanta			=	ClaOperador,
				ClaPlaca					=	ISNULL(bol.Placa, NULLIF(preplan.Placa,'')),
				TokenAcomodo				=	'',
				EsImprimirAut				=	0,
				TokenNuevoPlan				=	'',
				ClaTiempoObjetivo			=	TiempoObjetivo,
				ClaEstatusPlanCarga			
		FROM		OpeSch.OpeTraPlanCarga			AS preplan		WITH(NOLOCK)
		LEFT JOIN	OpeSch.OpetiCatEstatusvw		AS st			WITH (NOLOCK)	ON	(st.ClaEstatus					= preplan.ClaEstatusPlanCarga
																						AND st.claClasificacionEstatus	= 1270002)
		LEFT JOIN	OpeSch.OpeTraBoleta				AS bol			WITH (NOLOCK)	ON	(preplan.IdBoleta		= bol.IdBoleta
																						AND preplan.ClaUbicacion= bol.ClaUbicacion)																					
		LEFT JOIN	OpeSch.OpeLogPlanCarga			AS lo			WITH (NOLOCK)	ON (lo.ClaUbicacion			= preplan.ClaUbicacion
																						AND lo.IdPlanCarga		= preplan.IdPlanCarga
																						AND TipoRegistro		= 25	-- TIEMPO OBJETIVO
																						)
		WHERE		preplan.ClaUbicacion = @pnClaUbicacion
		AND			preplan.IdPlanCarga = @pnIdPlanCarga
	END
	ELSE
	BEGIN
		SELECT	--IdPlanCarga					= NULL,
				ClaRuta						= NULL,
				ClaTransporte				= NULL,
				ClaTipoViaje				= NULL,
				FechaPlanEmbarque			= CONVERT(DATETIME, CONVERT(VARCHAR, getdate(), 112)),
				CapacidadTransporte			= NULL,
				TonsEmbarcadas				= NULL,
				PorcEficienciaCarga			= NULL,
				TonsCubicadas				= NULL,
				PorEficienciaCubicada		= NULL,
				ClaTransportista			= NULL,
				NomEstatusPlanCarga			= NULL,
				ClaOperadorPlanta			= NULL,
				ClaPlaca					= NULL,
				TokenAcomodo				=	'',
				EsImprimirAut				= 0,
				TokenNuevoPlan				= NULL,
				ClaTiempoObjetivo			= NULL,
				ClaEstatusPlanCarga			= NULL
	END
END	
