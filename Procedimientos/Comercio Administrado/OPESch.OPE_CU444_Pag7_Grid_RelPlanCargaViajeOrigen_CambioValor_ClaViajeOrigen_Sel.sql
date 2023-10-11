ALTER PROCEDURE OPESch.OPE_CU444_Pag7_Grid_RelPlanCargaViajeOrigen_CambioValor_ClaViajeOrigen_Sel
	  @pnClaUbicacion		INT
	, @pnClaUbicacionOrigen	INT
	, @pnClaViajeOrigen		INT
	, @pnClaArticuloRel		INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	  CantidadRecibida
			, PesoRecibido			= KilosPesados
			, d.NomUnidad
			, CantidadDocumentada	= CantidadEnviada	-- Sugerencia (Editable)
	FROM	OpeSch.OpeTraMovMciasTranEncVw a
	INNER JOIN OpeSch.OpeTraMovMciasTranDetVw b	
	ON		a.ClaUbicacionOrigen	= b.ClaUbicacion
	AND		a.ClaTipoInventario		= b.ClaTipoInventario
	AND		a.IdMovimiento			= b.IdMovimiento
	LEFT JOIN OpeSch.OpeArtCatArticuloVw (NOLOCK) c   
	ON		c.claTipoInventario = 1 
	AND		b.claArticulo		= c.ClaArticulo 
	LEFT JOIN OpeSch.OpeArtCatUnidadVw (NOLOCK) d    
	ON		d.claTipoInventario = 1 
	AND		c.ClaUnidadBase		= d.claUnidad 
	WHERE	a.ClaUbicacion			= @pnClaUbicacionOrigen
	AND		a.ClaUbicacionOrigen	= @pnClaUbicacionOrigen
	AND		a.NumViaje				= @pnClaViajeOrigen
	AND		b.ClaUbicacionDestino	= @pnClaUbicacion
	AND		b.ClaArticulo			= @pnClaArticuloRel

	SET NOCOUNT OFF
END