USE Operacion
GO
	-- 'OpeSch.OPE_CU444_Pag1_Boton_BtnIgualar_Proc'
GO
CREATE PROCEDURE OpeSch.OPE_CU444_Pag1_Boton_BtnIgualar_Proc
--DECLARE 
	  @pnClaUbicacion	INT
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

	CREATE TABLE #ProductoConReferencia (ClaArticulo INT, ClaFamilia INT, ClaSubFamilia INT, EsRequerida INT)


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


	CREATE TABLE #MciasTran
	(
		  ID				INT IDENTITY(1,1)
		, ClaUbicacion		INT
		, ClaveArticulo		VARCHAR(20)
		, ClaArticulo		INT
		, OPM				VARCHAR(20)
		, Rollo				VARCHAR(20)
		, CantRemisionada	NUMERIC(22,4)
	)

	-- SE CARGAN DE MERCANCÍAS EN TRÁNSITO AGRUPADOS POR CLAVE Y REFERENCIAS
	INSERT INTO #MciasTran
	SELECT 
		  ClaUbicacion		= ClaUbicacion
		, ClaveArticulo		= ClaveArticulo
		, ClaArticulo		= det.ClaArticulo
		, OPM				= CASE WHEN IsNull(pr.EsRequerida, 0) = 1 THEN CampoTexto1 ELSE '' END
		, Rollo				= CASE WHEN IsNull(pr.EsRequerida, 0) = 1 THEN CampoTexto2 ELSE '' END
		, CantRemisionada	= SUM(CantidadEnviada)
	FROM OpeSch.OpeTraMovMciasTranDet det
	INNER JOIN OpeSch.OpeArtCatArticuloVw art ON art.ClaTipoInventario = 1 AND art.ClaArticulo = det.ClaArticulo
	LEFT OUTER JOIN #ProductoConReferencia pr ON pr.ClaArticulo = det.ClaArticulo
	WHERE IdMovimiento = @nIdMovimiento 
	AND ClaUbicacionDestino = @pnClaUbicacion 
	AND	ClaUbicacion = @nClaUbicacionOrigen
	GROUP BY ClaUbicacion, det.ClaArticulo, ClaveArticulo, CASE WHEN IsNull(pr.EsRequerida, 0) = 1 THEN CampoTexto1 ELSE '' END, CASE WHEN IsNull(pr.EsRequerida, 0) = 1 THEN CampoTexto2 ELSE '' END
	
	
--	SELECT * FROM #MciasTran
	
--- select ClaFamilia, ClaSubFamilia, ClaArticulo from opesch.opeartcatarticulovw where clavearticulo = '4116522470'		--'3233200970'
-- 55	2	1564
-- 168	2	301358
-- DELETE OpeSch.OpeRelTipoRefArticulo WHERE ClaUbicacion = 153 AND ClaFamilia = 168

	SELECT * FROM #MciasTran

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
					@sRollo				= Rollo
			FROM	#MciasTran
			WHERE	Id = @nIndice


			EXEC OpeSch.OPE_CU444_Pag1_IU
				@pnClaUbicacion				= @pnClaUbicacion,
				@psPlaca					= @psPlaca,
				@pnIdViajeOrigen			= @pnIdViajeOrigen,
				@psEtiqueta					= @sClaveArticulo,
				@pnEsModificaCantidad		= 1,
				@pnClaArticuloAux			= @nClaArticulo,
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