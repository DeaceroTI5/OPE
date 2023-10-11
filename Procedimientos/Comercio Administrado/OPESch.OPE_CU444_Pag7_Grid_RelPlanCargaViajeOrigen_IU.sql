ALTER PROCEDURE OPESch.OPE_CU444_Pag7_Grid_RelPlanCargaViajeOrigen_IU
	  @pnClaUbicacion			INT
	, @pnIdPlanCargaViaje		INT
	, @pnIdPlanCargaViajeDet	INT
	, @pnClaPlanCargaAux		INT
	, @pnClaArticuloRel			INT
	, @pnIdFabricacionRel		INT
	, @pnIdFabricacionDetRel	INT
	, @pnClaUbicacionOrigen		INT				= NULL
	, @pnClaViajeOrigen			INT				= NULL
	, @pnCantidadRecibida		NUMERIC(22,4)	= NULL
	, @pnPesoRecibido			NUMERIC(22,4)	= NULL
	, @pnCantidadDocumentada	NUMERIC(22,4)	= NULL
	, @pnClaUsuarioMod			INT
	, @psNombrePCMod			VARCHAR(64)
	, @pnBajaLogica				INT = 0  
	, @pnAccionSp				TINYINT = -1  
AS
BEGIN
	SET NOCOUNT ON

	IF 0 >= ISNULL(@pnCantidadDocumentada,0)
	BEGIN
		RAISERROR ('La Cantidad a documentar debe ser mayor a cero. Favor de verificar.',16,1)
		RETURN
	END

	DECLARE   @sPlaca				VARCHAR(12)
			, @sPlacaOrigen			VARCHAR(12)
			, @nEsRecepTraspaso		TINYINT
			, @nCantRemisionada		NUMERIC(22,4)
			, @nPesoRemisionado		NUMERIC(22,4)
			, @nPesoTaraRemisionado	NUMERIC(22,4)
			, @nCantRecibida		NUMERIC(22,4)
			, @nPesoRecibido		NUMERIC(22,4)
			, @nPesoDocumentado		NUMERIC(22,4)

	SELECT	  @sPlacaOrigen		= Placa
			, @nEsRecepTraspaso	= CASE WHEN ISNULL(EsRecepcionTerminada,0) = 0 THEN 0 ELSE 1 END 
	FROM	OpeSch.OpeRelMovMciasTranMxUsaVw
	WHERE	ClaUbicacionOrigen	= @pnClaUbicacionOrigen
	AND		IdViajeOrigen		= @pnClaViajeOrigen
	AND		ClaUbicacionDestino	= @pnClaUbicacion

	SELECT	@sPlaca			= Placa
	FROM	OpeSch.OpeTraPlanCarga WITH(NOLOCK)
	WHERE	ClaUbicacion	= @pnClaUbicacion
	AND		IdPlanCarga		= @pnClaPlanCargaAux

	SELECT    @nCantRemisionada			= CantRemisionada			
			, @nPesoRemisionado			= PesoRemisionado		
			, @nPesoTaraRemisionado		= PesoTaraRemisionado		
	FROM	OpeSch.OpeTraRecepTraspasoProdVw 
	WHERE	ClaUbicacion		= @pnClaUbicacion
	AND		IdViajeOrigen		= @pnClaViajeOrigen
	AND		ClaUbicacionOrigen	= @pnClaUbicacionOrigen
	AND		ClaArticuloRemisionado	= @pnClaArticuloRel	
	AND		IdFabricacion		= @pnIdFabricacionRel
	AND		IdFabricacionDet	= @pnIdFabricacionDetRel

	SELECT	@nPesoDocumentado = (PesoTeoricoKgs *  @pnCantidadDocumentada)
	FROM	OpeSch.OpeArtCatArticuloVw 
	WHERE	ClaTipoInventario	= 1
	AND		ClaArticulo			= @pnClaArticuloRel

	IF NOT EXISTS(
		SELECT	1 
		FROM	OpeSch.OpeRelPlanCargaViajeOrigen WITH(NOLOCK)
		WHERE	ClaUbicacion = @pnClaUbicacion
		AND		IdPlanCargaViaje = @pnIdPlanCargaViaje
	)
	BEGIN
		IF NOT EXISTS(
			SELECT	1 
			FROM	OpeSch.OpeRelPlanCargaViajeOrigen WITH(NOLOCK)
			WHERE	ClaUbicacion		= @pnClaUbicacion
			AND		IdPlanCarga			= @pnClaPlanCargaAux
			AND		ClaUbicacionOrigen	= @pnClaUbicacionOrigen
			AND		IdViajeOrigen		= @pnClaViajeOrigen
		)
		BEGIN
			SELECT	@pnIdPlanCargaViaje = ISNULL(MAX(IdPlanCargaViaje),0) + 1  
			FROM	OpeSch.OpeRelPlanCargaViajeOrigen WITH(NOLOCK) 
			WHERE	ClaUbicacion = @pnClaUbicacion

			INSERT INTO OpeSch.OpeRelPlanCargaViajeOrigen(
				  ClaUbicacion
				, IdPlanCargaViaje
				, IdPlanCarga
				, ClaUbicacionOrigen
				, IdViajeOrigen
				, Placa
				, PlacaOrigen
				, EsRecepTraspaso
				, BajaLogica
				, FechaBajaLogica
				, ClaUsuarioMod
				, FechaUltimaMod
				, NombrePcMod
			)
			SELECT	  @pnClaUbicacion
					, @pnIdPlanCargaViaje
					, @pnClaPlanCargaAux
					, @pnClaUbicacionOrigen
					, @pnClaViajeOrigen
					, @sPlaca
					, @sPlacaOrigen
					, @nEsRecepTraspaso
					, BajaLogica			= 0
					, FechaBajaLogica		= NULL
					, ClaUsuarioMod			= @pnClaUsuarioMod
					, FechaUltimaMod		= GETDATE()
					, NombrePcMod			= @psNombrePCMod

		END
		ELSE
		BEGIN
			SELECT	@pnIdPlanCargaViaje	= IdPlanCargaViaje
			FROM	OpeSch.OpeRelPlanCargaViajeOrigen WITH(NOLOCK)
			WHERE	ClaUbicacion		= @pnClaUbicacion
			AND		IdPlanCarga			= @pnClaPlanCargaAux
			AND		ClaUbicacionOrigen	= @pnClaUbicacionOrigen
			AND		IdViajeOrigen		= @pnClaViajeOrigen
		END
	END

	IF NOT EXISTS(
		SELECT	1 
		FROM	OpeSch.OpeRelPlanCargaViajeOrigenDet WITH(NOLOCK)
		WHERE	ClaUbicacion		= @pnClaUbicacion
		AND		IdPlanCargaViaje	= @pnIdPlanCargaViaje
		AND		IdPlanCargaViajeDet	= @pnIdPlanCargaViajeDet
	)
	BEGIN
		SELECT	@pnIdPlanCargaViajeDet = ISNULL(MAX(IdPlanCargaViajeDet),0) + 1  
		FROM	OpeSch.OpeRelPlanCargaViajeOrigenDet WITH(NOLOCK) 
		WHERE	ClaUbicacion = @pnClaUbicacion
		AND		@pnIdPlanCargaViaje = @pnIdPlanCargaViaje

		INSERT INTO OpeSch.OpeRelPlanCargaViajeOrigenDet(
			  ClaUbicacion
			, IdPlanCargaViaje
			, IdPlanCargaViajeDet
			, IdPlanCarga
			, ClaUbicacionOrigen
			, IdViajeOrigen
			, IdFabricacion
			, IdFabricacionDet
			, ClaArticulo
			, CantRemisionada
			, PesoRemisionado
			, PesoTaraRemisionado
			, CantRecibida
			, PesoRecibido
			, CantDocumentada
			, PesoDocumentado
			, BajaLogica
			, FechaBajaLogica
			, ClaUsuarioMod
			, FechaUltimaMod
			, NombrePcMod
		)
		SELECT 
			  ClaUbicacion				= @pnClaUbicacion
			, IdPlanCargaViaje			= @pnIdPlanCargaViaje
			, IdPlanCargaViajeDet		= @pnIdPlanCargaViajeDet
			, IdPlanCarga				= @pnClaPlanCargaAux
			, ClaUbicacionOrigen		= @pnClaUbicacionOrigen
			, IdViajeOrigen				= @pnClaViajeOrigen
			, IdFabricacion				= @pnIdFabricacionRel
			, IdFabricacionDet			= @pnIdFabricacionDetRel
			, ClaArticulo				= @pnClaArticuloRel
			, CantRemisionada			= 0--@nCantRemisionada		
			, PesoRemisionado			= 0--@nPesoRemisionado		
			, PesoTaraRemisionado		= 0--@nPesoTaraRemisionado	
			, CantRecibida				= @pnCantidadRecibida	
			, PesoRecibido				= @pnPesoRecibido		
			, CantDocumentada			= @pnCantidadDocumentada
			, PesoDocumentado			= @nPesoDocumentado
			, BajaLogica				= 0
			, FechaBajaLogica			= NULL
			, ClaUsuarioMod				= @pnClaUsuarioMod
			, FechaUltimaMod			= GETDATE()
			, NombrePcMod				= @psNombrePCMod

	END
	ELSE
	BEGIN
		IF @pnAccionSp = 3
			SELECT @pnBajaLogica = 1

		UPDATE	OpeSch.OpeRelPlanCargaViajeOrigenDet WITH(ROWLOCK)
		SET		  CantDocumentada		= @pnCantidadDocumentada
				, PesoDocumentado		= @nPesoDocumentado
				, BajaLogica			= @pnBajaLogica  
				, FechaBajaLogica		= CASE WHEN @pnBajaLogica = 1 
											THEN GETDATE() ELSE NULL END 
				, NombrePcMod			= @psNombrePcMod  
				, ClaUsuarioMod			= @pnClaUsuarioMod  
				, FechaUltimaMod		= GETDATE()
		WHERE	ClaUbicacion			= @pnClaUbicacion
		AND		IdPlanCargaViaje		= @pnIdPlanCargaViaje
		AND		IdPlanCargaViajeDet		= @pnIdPlanCargaViajeDet
	END

	SET NOCOUNT OFF
END