ALTER PROCEDURE OPESch.OPE_CU444_Pag7_Grid_RelPlanCargaViajeOrigen_Sel
	  @pnClaUbicacion			INT
	, @pnClaPlanCargaAux		INT
	, @pnIdFabricacionRel		INT
	, @pnIdFabricacionDetRel	INT
	, @pnClaArticuloRel			INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	  a.IdPlanCargaViaje
			, b.IdPlanCargaViajeDet
			, a.ClaUbicacionOrigen	
			, NomUbicacionOrigen	= e.NombreUbicacion
			, ClaViajeOrigen		= a.IdViajeOrigen
			, NomViajeOrigen		= CONVERT(VARCHAR(20), a.IdViajeOrigen)
			, CantidadRecibida		= b.CantRecibida
			, PesoRecibido			= b.PesoRecibido
			, NomUnidad				= d.NomUnidad
			, CantidadDocumentada	= b.CantDocumentada
			, PesoDocumentado		= b.PesoDocumentado
	FROM	OpeSch.OpeRelPlanCargaViajeOrigen a WITH(NOLOCK)
	INNER JOIN OpeSch.OpeRelPlanCargaViajeOrigenDet b WITH(NOLOCK)
	ON		a.IdPlanCargaViaje		= b.IdPlanCargaViaje
	AND		a.ClaUbicacion			= b.ClaUbicacion
	LEFT JOIN OpeSch.OpeArtCatArticuloVw c WITH(NOLOCK)   
	ON		c.claTipoInventario		= 1 
	AND		b.ClaArticulo			= c.ClaArticulo 
	LEFT JOIN OpeSch.OpeArtCatUnidadVw d WITH(NOLOCK) 
	ON		d.claTipoInventario		= 1 
	AND		c.ClaUnidadBase			= d.claUnidad 
	LEFT JOIN OpeSch.OpeTiCatUbicacionVw e
	ON		a.ClaUbicacionOrigen	= e.ClaUbicacion
	WHERE	a.ClaUbicacion			= @pnClaUbicacion
	AND		a.IdPlanCarga			= @pnClaPlanCargaAux
	AND		b.IdFabricacion			= @pnIdFabricacionRel
	AND		b.IdFabricacionDet		= @pnIdFabricacionDetRel
	AND		b.ClaArticulo			= @pnClaArticuloRel
	AND		b.BajaLogica			= 0

	SET NOCOUNT OFF
END