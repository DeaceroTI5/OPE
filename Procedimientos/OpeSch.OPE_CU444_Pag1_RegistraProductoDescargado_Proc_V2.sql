USE Operacion
GO
-- 'OpeSch.OPE_CU444_Pag1_RegistraProductoDescargado_Proc_V2'
GO
ALTER PROCEDURE OpeSch.OPE_CU444_Pag1_RegistraProductoDescargado_Proc_V2
	  @pnClaUbicacion		INT
	, @psPlaca				VARCHAR(20)
	, @pnIdViajeOrigen		INT
	, @psEtiqueta			VARCHAR(20)
	, @pnCantidad			NUMERIC(22, 4)
	, @pnClaArticulo		INT
	, @pnIdFabricacion		INT
	, @pnIdFabricacionDet	INT
	, @psOPM				VARCHAR(20)
	, @psRollo				VARCHAR(20)
	, @pnEsModificaCantidad INT
	, @psNombrePcMod		VARCHAR(64)
	, @pnClaUsuarioMod		INT
	, @pnEsAgregar			INT = 1
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @nClaArticulo INT, @nPesoTeoricoKgs NUMERIC(22,4), @nIdBoleta INT, @nIdViajeOrigen INT, @nClaUbicacionOrigen INT
	DECLARE @nErrorNum INT, @sErrorMsg VARCHAR(500)

	SELECT @nClaArticulo = @pnClaArticulo

	DECLARE @ClaFamilia INT, @ClaSubFamilia INT
	
	IF IsNULL(@psEtiqueta, '') != ''
	BEGIN
		SET @nClaArticulo = -1

		SELECT	@nClaArticulo = ClaArticulo, @ClaFamilia = ClaFamilia, @ClaSubFamilia = ClaSubFamilia, @nPesoTeoricoKgs = PesoTeoricoKgs
		FROM	ArtSch.ArtCatArticuloVw WITH (NOLOCK)
		WHERE	ClaveArticulo = @psEtiqueta 
		AND ClaTipoInventario = 1
		
		SELECT	@ClaFamilia = ClaFamilia, @ClaSubFamilia = ClaSubFamilia, @nPesoTeoricoKgs = PesoTeoricoKgs
		FROM	ArtSch.ArtCatArticuloVw WITH (NOLOCK)
		WHERE	ClaArticulo = @nClaArticulo
		AND		ClaTipoInventario = 1
	END
	ELSE
	BEGIN
		SELECT	@ClaFamilia = ClaFamilia, @ClaSubFamilia = ClaSubFamilia, @nPesoTeoricoKgs = PesoTeoricoKgs
		FROM	ArtSch.ArtCatArticuloVw WITH (NOLOCK)
		WHERE	ClaArticulo = @nClaArticulo 
		AND		ClaTipoInventario = 1	
	END
	
	--Validar si el producto existe para le recepcion de Traspaso
	IF NOT EXISTS 
		(	
			SELECT	1
			FROM	OpeSch.OPETraBoleta b WITH (NOLOCK)
			INNER JOIN OpeSch.OpeTraRecepTraspaso t WITH (NOLOCK) ON	b.IdBoleta = t.IdBoleta AND b.ClaUbicacion = t.ClaUbicacion AND b.ClaUbicacionOrigen = t.ClaUbicacionOrigen AND b.IdViajeOrigen= t.IdViajeOrigen
			INNER JOIN OpeSch.OpeTraRecepTraspasoProd tp with (nolock) ON	b.ClaUbicacion = tp.ClaUbicacion AND b.IdViajeOrigen= tp.IdViajeOrigen		
			WHERE	b.Placa = @psPlaca 
			AND b.IdViajeOrigen = @pnIdViajeOrigen
			AND b.ClaUbicacion = @pnClaUbicacion 
			AND ClaArticuloRemisionado = @nClaArticulo
		)
	BEGIN 
		SELECT @sErrorMsg = 'Error, el Producto Seleccionado no es valido para la Recepcion del traspaso'
		GOTO FINERROR
	END
		 
	
	/*Se verifica que el producto sea el correcto*/
	IF (@nClaArticulo = -1)
	BEGIN
		SELECT @sErrorMsg = 'Etiqueta de producto no encontrada'
		GOTO FINERROR
	END
		
	
	--Validar si existe en la recepcion de traspaso el articulo
	SELECT	
		b.ClaUbicacion
		, b.IdBoleta
		, b.IdViajeOrigen
		, b.PesoEntrada
		, t.Placa
		, tp.IdFabricacion
		, tp.IdFabricacionDet
		, ClaArticuloRemisionado
		, CantRemisionada
		, PesoRemisionado
	INTO	#OpmRolloPorArticulo
	FROM	OpeSch.OPETraBoleta b WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTraRecepTraspaso t WITH(NOLOCK)		ON		b.ClaUbicacion = t.ClaUbicacion  AND b.ClaUbicacionOrigen = t.ClaUbicacionOrigen  AND b.IdViajeOrigen= t.IdViajeOrigen AND b.IdBoleta = t.IdBoleta 
	INNER JOIN OpeSch.OpeTraRecepTraspasoFab tf WITH(NOLOCK)	ON		b.ClaUbicacion = tf.ClaUbicacion AND b.ClaUbicacionOrigen = tf.ClaUbicacionOrigen AND b.IdViajeOrigen= tf.IdViajeOrigen 
	INNER JOIN OpeSch.OpeTraRecepTraspasoProd tp WITH(NOLOCK)	ON		b.ClaUbicacion = tp.ClaUbicacion AND b.ClaUbicacionOrigen = tp.ClaUbicacionOrigen AND b.IdViajeOrigen= tp.IdViajeOrigen		
	INNER JOIN  opeSch.OpeArtCatArticuloVw  art WITH(NOLOCK)	ON		tp.ClaArticuloRemisionado = art.ClaArticulo AND art.claTipoInventario = 1	
	INNER JOIN opeSch.OpeArtCatUnidadVw u WITH(NOLOCK)			ON		u.claTipoInventario = 1 AND	u.claUnidad = art.ClaUnidadBase		
	WHERE	b.ClaUbicacion = @pnClaUbicacion 
	AND		b.Placa = @psPlaca	
	AND		b.IdViajeOrigen = @pnIdViajeOrigen
	AND		tp.ClaArticuloRemisionado = @nClaArticulo
				
	IF NOT EXISTS (SELECT * FROM #OpmRolloPorArticulo )
	BEGIN 		
			SELECT @sErrorMsg = 'No Existe informacion para el producto en la Recepcion de Traspasos de las Placas'
			GOTO FINERROR
	END		
	
	
	-- AQUI NOS CICLAREMOS CON MCIATRAN PARA CARGAR LOS QUE TENGAN REFERENCIAS.
	/*Se verifica que el producto no tenga referencias para ser capturado manualmete*/
	IF EXISTS (	SELECT 1
				FROM OpeSch.OpeRelTipoRefArticulo	ref WITH (NOLOCK)
				WHERE ref.ClaTipoInventario = 1 
				AND ref.ClaUbicacion = @pnClaUbicacion 
				AND ref.ClaFamilia = @ClaFamilia 
				AND ref.BajaLogica = 0
				AND (
					IsNull(ref.ClaSubFamilia, -1) = -1
					OR (ref.ClaSubFamilia = @ClaSubFamilia AND IsNull(ref.ClaArticulo,-1) = -1) 
					OR (ref.ClaSubFamilia = @ClaSubFamilia AND ref.ClaArticulo = @nClaArticulo)
					)
				)				
				
	BEGIN
		SELECT @sErrorMsg = 'Scaneo equivocado, favor de ingresar manualmente la OPM-Rollo (el producto ' + CAST(@nClaArticulo AS VARCHAR) + ' esta configurado como que las requiere)'
		GOTO FINERROR
	END
	
	/*Si existe el producto y puede ser agragado para la recepcion de traspaso por medio de scaner*/
	-- Print 'Existe el Producto para las Placas de la Recepcion de Traspaso'
	
	SELECT	@nIdBoleta = b.IdBoleta, @nIdViajeOrigen = b.IdViajeOrigen, @nClaUbicacionOrigen = b.ClaUbicacionOrigen
	FROM	OpeSch.OPETraBoleta b WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTraRecepTraspaso t WITH(NOLOCK) ON	b.IdBoleta = t.IdBoleta AND b.ClaUbicacion = t.ClaUbicacion AND b.IdViajeOrigen= t.IdViajeOrigen AND b.ClaUbicacionOrigen = t.ClaUbicacionOrigen
	INNER JOIN OpeSch.OpeTraRecepTraspasoFab tf WITH(NOLOCK) ON	b.ClaUbicacion = tf.ClaUbicacion AND b.IdViajeOrigen= tf.IdViajeOrigen AND b.ClaUbicacionOrigen = tf.ClaUbicacionOrigen 
	INNER JOIN OpeSch.OpeTraRecepTraspasoProd tp WITH(NOLOCK) ON b.ClaUbicacion = tp.ClaUbicacion and b.ClaUbicacionOrigen = tp.ClaUbicacionOrigen AND b.IdViajeOrigen= tp.IdViajeOrigen
	INNER JOIN  opeSch.OpeArtCatArticuloVw  art WITH(NOLOCK) ON	tp.ClaArticuloRemisionado = art.ClaArticulo AND art.claTipoInventario = 1 
	INNER JOIN opeSch.OpeArtCatUnidadVw u WITH(NOLOCK) ON u.claTipoInventario = 1 AND u.claUnidad = art.ClaUnidadBase		
	WHERE	b.ClaUbicacion = @pnClaUbicacion 
	AND		b.Placa = @psPlaca	
	AND		b.IdViajeOrigen = @pnIdViajeOrigen
	AND		tp.ClaArticuloRemisionado = @nClaArticulo
	

	--SELECT @pnClaUbicacion AS '@pnClaUbicacion', @nIdBoleta as '@nIdBoleta', @nClaUbicacionOrigen as '@nClaUbicacionOrigen', @nIdViajeOrigen as '@nIdViajeOrigen', @psPlaca AS '@psPlaca', @pnIdViajeOrigen AS '@pnIdViajeOrigen', @pnCantidad AS '@pnCantidad', @pnClaArticulo AS '@pnClaArticulo', @pnIdFabricacion AS '@pnIdFabricacion', 
	--		@psOPM AS '@psOPM', @psRollo AS '@psRollo', @pnEsModificaCantidad AS '@pnEsModificaCantidad'


	IF NOT EXISTS(	
			SELECT	1
			FROM	OpeSch.OpeTraPlanCargaRemisionEstimacion WITH(NOLOCK)
			WHERE	ClaUbicacionVenta		= @pnClaUbicacion
			AND		ClaUbicacionEstimacion	= @nClaUbicacionOrigen
			AND		IdViajeEstimacion		= @pnIdViajeOrigen
	)
	BEGIN
		SELECT @sErrorMsg = 'Existe una incidencia en el registro de la evidencia de POD Estimaciones, favor de contactar a su administrador de sistemas.'
		GOTO FINERROR
	END

	--ACTUALIZAR DATOS
	IF NOT EXISTS(	SELECT	1  
				FROM	OpeSch.OpeTraRecepTraspasoProdAuxV2
				WHERE	ClaUbicacion = @pnClaUbicacion AND
						IdViajeOrigen = @nIdViajeOrigen AND
						ClaUbicacionOrigen = @nClaUbicacionOrigen AND
						ClaArticulo = @pnClaArticulo AND
						IdFabricacion = @pnIdFabricacion AND
						IdFabricacionDet = @pnIdFabricacionDet AND
						Referencia3 = IsNull(@psOPM, '') AND 
						Referencia4 = IsNull(@psRollo, '')
						) AND @pnCantidad <> 0
	BEGIN
		INSERT INTO OpeSch.OpeTraRecepTraspasoProdAuxV2(ClaUbicacion, IdViajeOrigen, ClaUbicacionOrigen, ClaArticulo, IdFabricacion, IdFabricacionDet, Referencia3, Referencia4, Cantidad, Kgs, IdBoleta, FechaUltimaMod, NombrePcMod, ClaUsuarioMod)
		VALUES(@pnClaUbicacion, @nIdViajeOrigen,  @nClaUbicacionOrigen, @nClaArticulo, @pnIdFabricacion, @pnIdFabricacionDet, IsNull(@psOPM, ''), IsNull(@psRollo, ''), @pnCantidad, (@pnCantidad * @nPesoTeoricoKgs),  @nIdBoleta, GETDATE(), @psNombrePcMod, @pnClaUsuarioMod) 
	END
	ELSE
	BEGIN
		IF @pnCantidad = 0
		BEGIN
			DELETE OpeSch.OpeTraRecepTraspasoProdAuxV2 
			WHERE ClaUbicacion = @pnClaUbicacion 
			AND	IdViajeOrigen = @nIdViajeOrigen
			AND ClaUbicacionOrigen = @nClaUbicacionOrigen 
			AND ClaArticulo = @nClaArticulo 
			AND	IdFabricacion = @pnIdFabricacion
			AND IdFabricacionDet = @pnIdFabricacionDet
			AND referencia3 = @psOpm 
			AND referencia4 = @psRollo
		
		END
		ELSE
		BEGIN
			IF @pnEsAgregar = 1
				UPDATE	t1
				SET		t1.Cantidad = CASE WHEN ISNULL(@pnCantidad, 0) = 0 THEN  0 ELSE Cantidad + @pnCantidad END,
						t1.Kgs = CASE WHEN ISNULL(@pnCantidad, 0) = 0  THEN 0 ELSE Kgs + (@pnCantidad * t2.PesoTeoricoKgs) END,
						t1.FechaUltimaMod = GETDATE(),
						t1.ClaUsuarioMOd = @pnClaUsuarioMod,
						t1.NombrePcMod = @psNombrePcMod
				FROM	OpeSch.OpeTraRecepTraspasoProdAuxV2 t1
						INNER JOIN OpeSch.OpeArtCatArticuloVw t2
				ON		t2.ClaTipoInventario = 1 AND
						t2.ClaArticulo = t1.ClaArticulo
				WHERE	t1.ClaUbicacion = @pnClaUbicacion AND
						t1.IdViajeOrigen = @nIdViajeOrigen AND
						t1.ClaUbicacionOrigen = @nClaUbicacionOrigen AND
						t1.ClaArticulo = @nClaArticulo AND
						t1.IdFabricacion = @pnIdFabricacion AND
						t1.IdFabricacionDet = @pnIdFabricacionDet AND
						Referencia3 = @psOPM AND 
						Referencia4 = @psRollo 
						
			ELSE
				UPDATE	t1
				SET		t1.Cantidad = CASE WHEN ISNULL(@pnCantidad, 0) = 0 THEN  0 ELSE @pnCantidad END,
						t1.Kgs = CASE WHEN ISNULL(@pnCantidad, 0) = 0  THEN 0 ELSE (@pnCantidad * t2.PesoTeoricoKgs) END,
						t1.FechaUltimaMod = GETDATE(),
						t1.ClaUsuarioMOd = @pnClaUsuarioMod,
						t1.NombrePcMod = @psNombrePcMod
				FROM	OpeSch.OpeTraRecepTraspasoProdAuxV2 t1
						INNER JOIN OpeSch.OpeArtCatArticuloVw t2
				ON		t2.ClaTipoInventario = 1 AND
						t2.ClaArticulo = t1.ClaArticulo
				WHERE	t1.ClaUbicacion = @pnClaUbicacion AND
						t1.IdViajeOrigen = @nIdViajeOrigen AND
						t1.ClaUbicacionOrigen = @nClaUbicacionOrigen AND
						t1.ClaArticulo = @nClaArticulo AND
						t1.IdFabricacion = @pnIdFabricacion AND
						t1.IdFabricacionDet = @pnIdFabricacionDet AND
						Referencia3 = @psOPM AND 
						Referencia4 = @psRollo 
		END						
					
	END
	
	
	-- GUARDAR EN REGISTRO DE ETAPAS DE DESCARGA (INICIO DE DESCARGA)
	IF (ISNULL(@pnClaUbicacion, -1) > 0 AND ISNULL(@nClaUbicacionOrigen, -1) > 0 AND ISNULL(@nIdViajeOrigen, -1) > 0) 
		IF NOT EXISTS (SELECT 1 FROM OpeSch.OpeLogDescarga WHERE ClaUbicacion = @pnClaUbicacion AND ClaUbicacionOrigen = @nClaUbicacionOrigen AND NumViaje = @nIdViajeOrigen AND TipoRegistro = 30)
			IF EXISTS (SELECT 1 FROM OpeSch.OpeTraRecepTraspasoProdAux WHERE ClaUbicacion = @pnClaUbicacion AND ClaUbicacionOrigen = @nClaUbicacionOrigen AND IdViajeOrigen = @nIdViajeOrigen )
				INSERT INTO OpeSch.OpeLogDescarga (ClaUbicacion, ClaUbicacionOrigen, NumViaje, TipoRegistro, FechaUltimaMod, ClaUsuarioMod, NombrePcMod)
				SELECT @pnClaUbicacion, @nClaUbicacionOrigen, @nIdViajeOrigen, 30, GETDATE(), @pnClaUsuarioMod, @psNombrePcMod
	
	
	 RETURN	 
	
	FINERROR:	
		
	SELECT 
		NULL AS IdViajeOrigen,
		NULL AS IdFabricacion,
		NULL AS IdFabricacionDet,
		NULL AS ClaArticulo,
		NULL AS KilosTara, 
		NULL AS Cantidad,
		NULL AS Kilos,
		NULL AS OPM,
		NULL AS Rollo,
		NULL AS	ClaError,
		@sErrorMsg AS ErrorMsg
	
		
	RAISERROR(@sErrorMsg,16,1)
		
	SET NOCOUNT OFF
END