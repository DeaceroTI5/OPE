ALTER PROCEDURE OPESch.OPE_CU550_Pag32_Grid_CarCatClienteFilial_Sel
	  @pnClaUbicacion	INT
	, @pnClaPlantaPide	INT	= NULL
	, @pnClaPlantaSurte	INT	= NULL
	, @pnClaCliente		INT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT    Origen			= CONVERT(VARCHAR(10),a.ClaUbicacionOrigen)+ ' - ' + b.NomUbicacion
			, Destino			= CONVERT(VARCHAR(10),a.claUbicacionDestino)+ ' - ' + c.NomUbicacion
			, Empresa			= d.NomEmpresa
			, ClienteFilial		= CONVERT(VARCHAR(10),a.ClaClienteFilial) +' - '+ e.NomCliente
			, Consignado		= CONVERT(VARCHAR(10),a.ClaConsignado) +' - '+ f.NombreConsignado
			, PrecioLista		= a.claListaPrecio
	FROM	TiCatalogo.dbo.CarCatClienteFilial a WITH(NOLOCK)
	INNER JOIN OpeSch.TiCatUbicacionvw b
	ON		a.claUbicacionOrigen	= b.ClaUbicacion
	INNER JOIN opeSch.TiCatUbicacionvw c
	ON		a.ClaUbicacionDestino	= c.ClaUbicacion
	INNER JOIN opeSch.OpetiCatEmpresaVW d 
	ON		a.ClaEmpresaDestino		= d.ClaEmpresa
	LEFT JOIN OpeSch.OpeVtaCatClienteVw e
	ON		a.ClaClienteFilial		= e.ClaCliente
	LEFT JOIN OpeSch.OpeVtaCatConsignadoVw f
	ON		a.ClaConsignado			= f.ClaConsignado
	WHERE	EXISTS (	SELECT	1 
						FROM	OpeSch.TicatUbicacionvw h
						WHERE	h.ClaEmpresa = 52
						AND		(a.ClaUbicacionDestino	= h.ClaUbicacion 
								 OR a.ClaUbicacionOrigen = h.ClaUbicacion
								)							
					)
	AND		(@pnClaPlantaPide IS NULL OR (a.ClaUbicacionDestino = @pnClaPlantaPide))
	AND		(@pnClaPlantaSurte IS NULL OR (a.ClaUbicacionOrigen = @pnClaPlantaSurte))
	AND		(@pnClaCliente IS NULL OR (a.ClaClienteFilial = @pnClaCliente))
	AND		a.BajaLogica = 0
	ORDER BY a.ClaUbicacionOrigen, ClaEmpresaDestino, a.ClaUbicacionDestino
	
	SET NOCOUNT OFF
END