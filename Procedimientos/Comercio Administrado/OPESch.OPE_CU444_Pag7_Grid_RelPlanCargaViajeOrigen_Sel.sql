USE operacion
-- EXEC SP_HELPTEXT 'OPESch.OPE_CU444_Pag7_Grid_RelPlanCargaViajeOrigen_Sel'
GO
ALTER PROCEDURE OPESch.OPE_CU444_Pag7_Grid_RelPlanCargaViajeOrigen_Sel
	  @pnClaUbicacion			INT
	, @pnClaPlanCargaAux		INT
	, @pnIdFabricacionRel		INT
	, @pnIdFabricacionDetRel	INT
	, @pnClaArticuloRel			INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @tbViajeCantDocumentada TABLE (
		  Id				INT IDENTITY(1,1)
		, IdViajeOrigen		INT
		, CantDocumentada	NUMERIC(22,4)
	)

	DECLARE @tbProductoASA TABLE (
		  Id				INT IDENTITY(1,1)
		, IdViajeOrigen		INT
		--, ClaArticulo		INT
		--, ClaArticuloASA	INT
	)

	-- Calcula Cantidad Documentada a nivel de viaje/producto en otros diferentes Planes de Carga
	INSERT INTO @tbViajeCantDocumentada (IdViajeOrigen, CantDocumentada)
	SELECT	  IdViajeOrigen
			, CantDocumentada		= ISNULL(SUM(CantDocumentada),0) 
	FROM	OpeSch.OpeRelPlanCargaViajeOrigenDet a WITH(NOLOCK)
	WHERE	a.ClaUbicacion			= @pnClaUbicacion
	AND		a.IdPlanCarga			<> @pnClaPlanCargaAux
	AND		a.ClaArticulo			= @pnClaArticuloRel
	AND		a.BajaLogica			= 0
	GROUP BY IdViajeOrigen



	DECLARE @sRutaImagen VARCHAR(200)
	SELECT @sRutaImagen = '..\Common\Images\WebToolImages'


	SELECT	  a.IdPlanCargaViaje
			, b.IdPlanCargaViajeDet
			, a.ClaUbicacionOrigen	
			, NomUbicacionOrigen	= e.NombreUbicacion
			, ClaViajeOrigen		= a.IdViajeOrigen
			, NomViajeOrigen		= CONVERT(VARCHAR(20), a.IdViajeOrigen)
			, CantidadRecibida		= b.CantRecibida
			, PesoRecibido			= b.PesoRecibido
			, NomUnidad				= d.NomUnidad
			, CantidadDisponible	= CASE WHEN (b.CantRecibida - ISNULL(f.CantDocumentada,0)) <= 0 
											THEN 0 ELSE (b.CantRecibida - ISNULL(f.CantDocumentada,0)) END
			, CantidadDocumentada	= b.CantDocumentada
			, PesoDocumentado		= b.PesoDocumentado
			, RelProductoAsa		= CASE WHEN h.IdViajeOrigen IS NULL 
											THEN '<img src="'+@sRutaImagen+'/Agregar16.png" />' 
											ELSE '<img src="'+@sRutaImagen+'/Pencil16.png" />' END
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
	LEFT JOIN @tbViajeCantDocumentada f
	ON		a.IdViajeOrigen			= f.IdViajeOrigen
	LEFT JOIN @tbProductoASA h
	ON		a.IdViajeOrigen			= h.IdViajeOrigen
	WHERE	a.ClaUbicacion			= @pnClaUbicacion
	AND		a.IdPlanCarga			= @pnClaPlanCargaAux
	AND		b.IdFabricacion			= @pnIdFabricacionRel
	AND		b.IdFabricacionDet		= @pnIdFabricacionDetRel
	AND		b.ClaArticulo			= @pnClaArticuloRel
	AND		b.BajaLogica			= 0

	SET NOCOUNT OFF
END