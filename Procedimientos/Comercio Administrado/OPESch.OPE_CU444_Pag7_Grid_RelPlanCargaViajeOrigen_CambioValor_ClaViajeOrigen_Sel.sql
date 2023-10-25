USE operacion
-- EXEC SP_HELPTEXT 'OPESch.OPE_CU444_Pag7_Grid_RelPlanCargaViajeOrigen_CambioValor_ClaViajeOrigen_Sel'
GO
ALTER PROCEDURE OPESch.OPE_CU444_Pag7_Grid_RelPlanCargaViajeOrigen_CambioValor_ClaViajeOrigen_Sel
	  @pnClaUbicacion			INT
	, @pnClaPlanCargaAux		INT		
	, @pnClaUbicacionOrigen		INT
	, @pnClaViajeOrigen			INT
	, @pnIdFabricacionRel		INT
	, @pnIdFabricacionDetRel	INT
	, @pnClaArticuloRel			INT
	, @pnCantPlanRel			NUMERIC(22,4)	= NULL
AS
BEGIN
	SET NOCOUNT ON

	IF @pnClaViajeOrigen IS NULL
	BEGIN
		RETURN
	END
	
	DECLARE	  @nCantDocumentada		NUMERIC(22,4)
			, @nTotalCantDoc		NUMERIC(22,4)
			, @nCantidadRecibida	NUMERIC(22,4)
			, @nPesoRecibido		NUMERIC(22,4)	
			, @nCantidadDisponible	NUMERIC(22,4)
			, @nCantidadDocumentada	NUMERIC(22,4)

	-- Calcula Cantidad Documentada a nivel de viaje/producto en otros diferentes Planes de Carga
	SELECT	@nCantDocumentada		= ISNULL(SUM(CantDocumentada),0) 
	FROM	OpeSch.OpeRelPlanCargaViajeOrigenDet a WITH(NOLOCK)
	WHERE	a.ClaUbicacion			= @pnClaUbicacion
	AND		a.IdPlanCarga			<> @pnClaPlanCargaAux
	AND		a.IdViajeOrigen			= @pnClaViajeOrigen
	AND		a.ClaArticulo			= @pnClaArticuloRel
	AND		a.BajaLogica			= 0

	-- Calcula Cantidad Total Documentada en el Plan de Carga sin considerar el Viaje a ingresar
	SELECT	@nTotalCantDoc = SUM(CantDocumentada) 
	FROM	OpeSch.OpeRelPlanCargaViajeOrigenDet WITH(NOLOCK) 
	WHERE	ClaUbicacion	= @pnClaUbicacion 
	AND		IdPlanCarga		= @pnClaPlanCargaAux
	AND		IdViajeOrigen	<> @pnClaViajeOrigen
	AND		ClaArticulo		= @pnClaArticuloRel
	AND		BajaLogica		= 0

	SELECT    @nCantDocumentada	= ISNULL(@nCantDocumentada,0) 
			, @nTotalCantDoc	= ISNULL(@nTotalCantDoc,0)

IF @@SERVERNAME = 'SRVLABUSA01'
	SELECT	  @nCantidadRecibida	= CantidadRecibida
			, @nPesoRecibido		= KilosPesados
			, @nCantidadDisponible	= (CantidadRecibida - @nCantDocumentada)
	FROM	OpeSch.OpeTraMovMciasTranEncVw a
	INNER JOIN OpeSch.OpeTraMovMciasTranDetVw b	
	ON		a.ClaUbicacionOrigen	= b.ClaUbicacion
	AND		a.ClaTipoInventario		= b.ClaTipoInventario
	AND		a.IdMovimiento			= b.IdMovimiento
	WHERE	a.ClaUbicacion				= @pnClaUbicacionOrigen
	AND		a.ClaUbicacionOrigen	= @pnClaUbicacionOrigen
	AND		a.NumViaje				= @pnClaViajeOrigen
	AND		b.ClaUbicacionDestino	= @pnClaUbicacion
	AND		b.ClaArticulo			= @pnClaArticuloRel

IF @@SERVERNAME <> 'SRVLABUSA01'
	SELECT	  @nCantidadRecibida	= CantRecibida
			, @nPesoRecibido		= PesoRecibido
			, @nCantidadDisponible	= CantRecibida - @nCantDocumentada
	FROM	OpeSch.OpeTraRecepTraspasoProdRecibido WITH(NOLOCK)
	WHERE	IdViajeOrigen		= @pnClaViajeOrigen
	AND		ClaUbicacionOrigen	= @pnClaUbicacionOrigen
	AND		ClaUbicacion		= @pnClaUbicacion
	AND		IdFabricacion		= @pnIdFabricacionRel
	AND		IdFabricacionDet	= @pnIdFabricacionDetRel
	AND		ClaArticuloRecibido	= @pnClaArticuloRel


	SELECT @nCantidadDocumentada = 
		CASE	WHEN ( (@nCantidadDisponible <= @pnCantPlanRel) AND (@nCantidadDisponible <= (@pnCantPlanRel-@nTotalCantDoc)) ) 
				THEN @nCantidadDisponible
				ELSE CASE	WHEN ( (@nCantidadDisponible <= @pnCantPlanRel) AND (@nCantidadDisponible > (@pnCantPlanRel-@nTotalCantDoc)) ) 
							THEN (@pnCantPlanRel-@nTotalCantDoc)
				ELSE CASE	WHEN ( (@nCantidadDisponible > @pnCantPlanRel) )  
							THEN (@pnCantPlanRel-@nTotalCantDoc)
		END END END

	SELECT	  CantidadRecibida		= ISNULL(@nCantidadRecibida,0)	
			, PesoRecibido			= ISNULL(@nPesoRecibido,0)		
			, CantidadDisponible	= ISNULL(@nCantidadDisponible,0)	
			, CantidadDocumentada	= ISNULL(@nCantidadDocumentada,0)	
			, TotalCantDoc			= ISNULL(@nTotalCantDoc,0)

	SET NOCOUNT OFF
END