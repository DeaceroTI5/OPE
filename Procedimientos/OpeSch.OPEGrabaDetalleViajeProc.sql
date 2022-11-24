GO
-- 'OpeSch.OPEGrabaDetalleViajeProc'
GO
ALTER PROCEDURE OpeSch.OPEGrabaDetalleViajeProc
--DECLARE 
	  @pnClaUbicacion	INT
	, @pnClaUbicacionOrigen INT
	, @psPlaca			VARCHAR(20)
	, @pnIdViajeOrigen	INT
	, @psNombrePcMod	VARCHAR(64)
	, @pnClaUsuarioMod	INT
AS
BEGIN
--	SELECT @pnClaUbicacion = 197, @psPlaca = 'CAJA408', @pnIdViajeOrigen = 217471, @psNombrePcMod = '100VSALINAS', @pnClaUsuarioMod = 4
	

	SET NOCOUNT ON
	DECLARE @sErrorMsg	VARCHAR(200)

	DECLARE	@nIndice INT, @sClaveArticulo VARCHAR(20), @nCantRemisionada	NUMERIC(22,4), @nCantDescargada	NUMERIC(22,4), @sOPM VARCHAR(20), @sRollo VARCHAR(20)
	DECLARE @nIdBoleta INT, @nIdMovimiento INT, @nMuestraNumPad INT, @nClaUbicacionOrigen INT, @nClaArticulo INT, @nCantidad NUMERIC(22,4), @nKgsTeorico NUMERIC(22,4), @nClaFamilia INT, @nClaSubFamilia INT, @nEsRecepcionTerminada INT
	DECLARE @nIdViajeOrigen INT, @nClaEstatusPlaca INT
	DECLARE @nIdFabricacion INT, @nIdFabricacionDet INT

	CREATE TABLE #MciasTran
	(
		  ID				INT IDENTITY(1,1)
		, ClaUbicacion		INT
		, ClaveArticulo		VARCHAR(20)
		, ClaArticulo		INT
		, OPM				VARCHAR(20)
		, Rollo				VARCHAR(20)
		, CantRemisionada	NUMERIC(22,4)
		, IdFabricacion		INT
		, IdFabricacionDet	INT
	)

	CREATE TABLE #ProductoConReferencia (ClaArticulo INT, ClaFamilia INT, ClaSubFamilia INT, EsRequerida INT)

	-- BUSCA EN UBICACION
	SELECT	@nIdBoleta = IdBoleta, @nIdViajeOrigen = IdViajeOrigen, @nClaUbicacionOrigen = ClaUbicacionOrigen, @nClaEstatusPlaca = ClaEstatusPlaca
	FROM	OpeSch.OPETraBoleta WITH(NOLOCK)
	WHERE	ClaUbicacion = @pnClaUbicacion 
	AND		Placa = @psPlaca
	AND		IdViajeOrigen = @pnIdViajeOrigen
	-- BUSCAR EN EL HISTORICO 
	IF @nIdBoleta IS NULL AND @pnIdViajeOrigen IS NOT NULL
		SELECT	@nIdBoleta = IdBoleta, @nIdViajeOrigen = IdViajeOrigen, @nClaUbicacionOrigen = ClaUbicacionOrigen, @nClaEstatusPlaca = ClaEstatusPlaca
		FROM	OpeSch.OPETraBoletaHis WITH(NOLOCK)
		WHERE	ClaUbicacion = @pnClaUbicacion 
		AND		Placa = @psPlaca
		AND		IdViajeOrigen = @pnIdViajeOrigen

	SELECT @nIdMovimiento = IdMovimiento
	FROM OpeSch.OpeTraMovMciasTranEnc
	WHERE NumViaje = @pnIdViajeOrigen
	AND Placas = @psPlaca		
	AND ClaUbicacion = @nClaUbicacionOrigen
		
	-- REVISAMOS SI LA DESCARGA YA ESTÁ FINALIZADA 
	SELECT @nEsRecepcionTerminada = EsRecepcionTerminada
	FROM OpeSch.OpeTraRecepTraspaso 
	WHERE	IdViajeOrigen		=	@nIdViajeOrigen
	AND		ClaUbicacionOrigen	=	@nClaUbicacionOrigen
	AND		ClaUbicacion		=	@pnClaUbicacion

--	SELECT IdMovimiento = @nIdMovimiento, ClaUbicacion = @nClaUbicacionOrigen,  IdViajeOrigen = @pnidViajeOrigen, Placas = @psPlaca

	IF @nEsRecepcionTerminada = 1
	BEGIN
		SELECT @sErrorMsg = 'No se puede modificar una descarga finalizada.'
		GOTO ERROR		
	END	

	IF @nIdBoleta IS NULL 
	BEGIN
		SELECT @sErrorMsg = 'La placas no se encuentran en ubicación.'
		GOTO ERROR
	END


	INSERT INTO #ProductoConReferencia (ClaArticulo, ClaFamilia, ClaSubFamilia)
	SELECT DISTINCT d.ClaArticulo, a.ClaFamilia, a.ClaSubFamilia
	FROM OpeSch.OpeTraMovMciasTranDet d
	INNER JOIN OpeSch.OpeArtCatArticuloVw a ON a.ClaTipoInventario = 1 AND a.ClaArticulo = d.ClaArticulo
	WHERE IdMovimiento = @nIdMovimiento 
	AND ClaUbicacionDestino = @pnClaUbicacion 
	AND	ClaUbicacion = @nClaUbicacionOrigen
	AND (CampoTexto1 IS NOT NULL OR CampoTexto2 IS NOT NULL)

	UPDATE #ProductoConReferencia
	SET EsRequerida = 1
	FROM #ProductoConReferencia pr
	INNER JOIN OpeSch.OpeRelTipoRefArticulo	ref 
		ON ref.ClaTipoInventario = 1 
		AND ref.ClaFamilia = pr.ClaFamilia 
		AND (
				IsNull(ref.ClaSubFamilia, -1) = -1
				OR (ref.ClaSubFamilia = pr.ClaSubFamilia AND IsNull(ref.ClaArticulo,-1) = -1) 
				OR (ref.ClaSubFamilia = pr.ClaSubFamilia AND ref.ClaArticulo = pr.ClaArticulo)
			)
	WHERE ref.ClaUbicacion = @pnClaUbicacion 
	AND ref.BajaLogica = 0

	SELECT * FROM #ProductoConReferencia


	-- SE CARGAN DE MERCANCÍAS EN TRÁNSITO AGRUPADOS POR CLAVE Y REFERENCIAS
	INSERT INTO #MciasTran
	SELECT 
		  ClaUbicacion		= ClaUbicacion
		, ClaveArticulo		= ClaveArticulo
		, ClaArticulo		= det.ClaArticulo
		, OPM				= CASE WHEN IsNull(pr.EsRequerida, 0) = 1 THEN CampoTexto1 ELSE '' END
		, Rollo				= CASE WHEN IsNull(pr.EsRequerida, 0) = 1 THEN CampoTexto2 ELSE '' END
		, CantRemisionada	= SUM(CantidadEnviada)
		, det.NumericoExtra2 
		 , det.NumericoExtra3
	FROM OpeSch.OpeTraMovMciasTranDet det
	INNER JOIN OpeSch.OpeArtCatArticuloVw art ON art.ClaTipoInventario = 1 AND art.ClaArticulo = det.ClaArticulo
	LEFT OUTER JOIN #ProductoConReferencia pr ON pr.ClaArticulo = det.ClaArticulo
	WHERE IdMovimiento = @nIdMovimiento 
	AND ClaUbicacionDestino = @pnClaUbicacion 
	AND	ClaUbicacion = @nClaUbicacionOrigen
	GROUP BY ClaUbicacion, det.ClaArticulo, ClaveArticulo,det.NumericoExtra2 , det.NumericoExtra3,
	 CASE WHEN IsNull(pr.EsRequerida, 0) = 1 THEN CampoTexto1 ELSE '' END, CASE WHEN IsNull(pr.EsRequerida, 0) = 1 THEN CampoTexto2 ELSE '' END
	
	
	--SELECT @pnClaUbicacion ClaUbicacion, @pnIdViajeOrigen IdViaje, @pnClaUbicacionOrigen ClaUbicacionOrigen
	
	;WITH CTE_DATOS
	AS
	(SELECT 
		  ClaUbicacion		= det.ClaUbicacionOrigen
		, ClaArticulo		= det.ClaArticulo
		, OPM				= CASE WHEN IsNull(pr.EsRequerida, 0) = 1 THEN det.Referencia1 ELSE '' END
		, Rollo				= CASE WHEN IsNull(pr.EsRequerida, 0) = 1 THEN det.Referencia1 ELSE '' END
		, CantRemisionada	= SUM(det.Cantidad)
		, det.IdFabricacion
		, det.IdFabricacionDet
	FROM OpeSch.OpeTraInfoViajeEstimacionDet det
	LEFT OUTER JOIN #ProductoConReferencia pr ON pr.ClaArticulo = det.ClaArticulo
	WHERE det.ClaUbicacion = @pnClaUbicacion
	AND	det.ClaUbicacionOrigen = @pnClaUbicacionOrigen 
	AND  det.IdViajeOrigen = @pnIdViajeOrigen
	GROUP BY det.ClaUbicacion, det.ClaUbicacionOrigen, det.IdViajeOrigen, det.IdFabricacion, det.IdFabricacionDet, det.ClaArticulo,
	CASE WHEN IsNull(pr.EsRequerida, 0) = 1 THEN det.Referencia1 ELSE '' END, 
	CASE WHEN IsNull(pr.EsRequerida, 0) = 1 THEN det.Referencia2 ELSE '' END
	
	)
	
	UPDATE t1
	SET	t1.CantRemisionada = t2.CantRemisionada
	FROM #MciasTran t1
		INNER JOIN CTE_DATOS t2
		ON t2.ClaUbicacion = t1.ClaUbicacion 
		AND t2.ClaArticulo = t1.ClaArticulo 
		AND t2.OPM = t1.OPM 
		AND t2.Rollo = t1.Rollo
		AND t2.IdFabricacion = t1.IdFabricacion
		AND t2.IdFabricacionDet = t1.IdFabricacionDet
	
--	SELECT * FROM #MciasTran
	
--- select ClaFamilia, ClaSubFamilia, ClaArticulo from opesch.opeartcatarticulovw where clavearticulo = '4116522470'		--'3233200970'
-- 55	2	1564
-- 168	2	301358
-- DELETE OpeSch.OpeRelTipoRefArticulo WHERE ClaUbicacion = 153 AND ClaFamilia = 168

	--SELECT * FROM #MciasTran

/*

select * from opesch.opetraboleta where placa = '12864A'

select * from opesch.opetrareceptraspasoprodaux where idBoleta = 151910002
select * from opesch.opetrareceptraspasoprodrecibido where idboleta = 151910002
claubicacion = 
*/

	

	BEGIN TRY
		BEGIN TRAN
		

		SELECT	@nIndice = MIN(Id)
		FROM	#MciasTran

		WHILE (@nIndice IS NOT NULL)
		BEGIN
	
			SELECT	@nClaArticulo		= ClaArticulo,
					@sClaveArticulo		= ClaveArticulo,
					@nCantRemisionada	= CantRemisionada,
					@nCantDescargada	= CantRemisionada,
					@sOPM				= OPM,
					@sRollo				= Rollo,
					@nIdFabricacion     = IdFabricacion,
					@nIdFabricacionDet     = IdFabricacionDet
			FROM	#MciasTran
			WHERE	Id = @nIndice


			EXEC OpeSch.OPE_CU444_Pag1_IU_V2
				@pnClaUbicacion				= @pnClaUbicacion,
				@psPlaca					= @psPlaca,
				@pnIdViajeOrigen			= @pnIdViajeOrigen,
				@psEtiqueta					= @sClaveArticulo,
				@pnEsModificaCantidad		= 1,
				@pnClaArticuloAux			= @nClaArticulo,
				@pnIdFabricacion			= @nIdFabricacion,
				@pnIdFabricacionDet         = @nIdFabricacionDet,
				@psOPM						= @sOPM,
				@psRollo					= @sRollo,
				@pnCantidadAux				= @nCantRemisionada,
				@pnCantidadEsc				= @nCantRemisionada,
				@psNombrePcMod				= @psNombrePcMod,
				@pnClaUsuarioMod			= @pnClaUsuarioMod,
				@pnEsAgregar				= 0

			SELECT	@nIndice = MIN(Id)
			FROM	#MciasTran
			WHERE	Id > @nIndice
		END
				
		DROP TABLE #MciasTran

		COMMIT TRAN
	END TRY
	BEGIN CATCH  
		IF @@TRANCOUNT > 0 
		BEGIN 
			SET @sErrorMsg = ERROR_MESSAGE()
			RAISERROR( @sErrorMsg, 16, 1 )
			ROLLBACK TRANSACTION 				
			RETURN 
		END
	END CATCH
	

	RETURN 	
ERROR:
	DROP TABLE #ProductoConReferencia
	DROP TABLE #MciasTran
	RAISERROR( @sErrorMsg, 16, 1 )


	
END