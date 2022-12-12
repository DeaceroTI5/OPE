GO
-- 'OpeSch.OPE_CU550_Pag31_Grid_GridFacturaTraArticulo_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag31_Grid_GridFacturaTraArticulo_Sel 
    @pnClaUbicacion             INT, 
    @pnActividad                INT,
    @pdFechaInicio				DATETIME, 
    @pdFechaFin					DATETIME,
    @pnEstimacionFactura        INT,
    @pnFabricacionVenta         INT,
    @pnFabricacionVentaDet      INT,
    @pnFabricacionDetVentaDet   INT,
    @pnArticuloDet              INT,
	@pnDebug					TINYINT = 0
AS
BEGIN      
	SET NOCOUNT ON

	DECLARE   @pnCmbCliente					INT
			, @pnCmbProyecto				INT
			, @pnCmbFactura					INT
			, @pnFolioProforma				INT
			, @pnFolioFactura				INT
			, @CmbCliente					INT
			, @CmbProyecto 					INT
			, @CmbFactura					INT

	CREATE TABLE #tbRemisionFactura (
		  Id						INT IDENTITY(1,1)
		, ClaCliente				INT
		, ClaProyecto 				INT
		, IdViaje					INT
		, Remision					VARCHAR(20)
		, ClaArticulo				INT
		, NomProductoFacturar		VARCHAR(100)
		, ComentariosFacturaDet		VARCHAR(8000)
		-- FacturaRemision
		, IdEstimacionFactura 		INT
		, IdFabricacion 			INT
		, IdFabricacionDet 			INT
		, ClaUsuarioTra				INT
		, FechaTra					DATETIME
		, CantSurtidaTra			NUMERIC(22,4)		
		, IdProforma  				INT
		, Estatus					VARCHAR(20)
		, ObservacionEstimacion		VARCHAR(250)
		, ComentariosFactura		VARCHAR(800)
		-- Proforma
		, FacturaNueva				VARCHAR(20)
		, FechaFactura				DATETIME
		, IdFacturaNueva			INT
		, CantidadSurtida			NUMERIC(22,4)
		, KilosSurtidos				NUMERIC(22,4)          
		, ImporteSubtotal			NUMERIC(22,2)
		, IVA						NUMERIC(22,2) 
		, ImporteTotal				NUMERIC(22,4) 
	)


	INSERT INTO #tbRemisionFactura
	EXEC OpeSch.OpeRemisionFacturaEstimacionSel
		  @pdFechaInicio				= @pdFechaInicio
		, @pdFechaFin					= @pdFechaFin
		, @pnCmbCliente					= @pnCmbCliente
		, @pnCmbProyecto				= @pnCmbProyecto
		, @pnCmbFactura					= @pnCmbFactura
		, @pnEstimacionFactura			= @pnEstimacionFactura
		, @pnFabricacionVenta			= @pnFabricacionVenta
		, @pnFabricacionDetVentaDet		= @pnFabricacionDetVentaDet
		, @pnArticuloDet				= @pnArticuloDet
		, @pnFolioProforma				= @pnFolioProforma
		, @pnFolioFactura				= @pnFolioFactura


	
	IF @pnDebug = 1
		SELECT '' AS '#tbRemisionFactura', * FROM #tbRemisionFactura

	-- OpeSch.OPE_CU550_Pag31_Grid_GridFacturaTraArticulo_Sel (GRID 3)
    SELECT
              ColViajeTra			= a.IdViaje
            , ColRemisionTra		= a.Remision
            , ColClaArticuloTra		= d.ClaveArticulo
            , ColCantSurtidaTra		= a.CantSurtidaTra
            , ColImporteTra			= ROUND(ISNULL(( b.PrecioLista * a.CantSurtidaTra ), 0.00), 2)
            , ColRealizadoPorTra	= c.NombreUsuario + ' ' + c.ApellidoPaterno 
            , ColFechaTra			= a.FechaTra
			, a.ClaArticulo
			, b.PrecioLista
	FROM	#tbRemisionFactura a
	INNER JOIN	OpeSch.OpeTraFabricacionDetVw b WITH(NOLOCK)
    ON		a.IdFabricacion		= b.IdFabricacion 
	AND		a.IdFabricacionDet	= b.IdFabricacionDet
    LEFT JOIN	OpeSch.TiCatUsuarioVw c WITH(NOLOCK)
    ON		a.ClaUsuarioTra			= c.ClaUsuario 
	INNER JOIN  Opesch.OpeArtCatArticuloVw d WITH(NOLOCK)
    ON		a.ClaArticulo			= d.ClaArticulo	
	WHERE	(a.IdEstimacionFactura	= @pnEstimacionFactura		OR @pnEstimacionFactura IS NULL)
    AND		(a.IdFabricacion		= @pnFabricacionVentaDet	OR @pnFabricacionVentaDet IS NULL)
    AND		(a.IdFabricacionDet		= @pnFabricacionDetVentaDet	OR @pnFabricacionDetVentaDet IS NULL)
    AND		(a.ClaArticulo			= @pnArticuloDet			OR @pnArticuloDet IS NULL)

    ORDER BY
           a.IdViaje, a.Remision

	DROP TABLE #tbRemisionFactura
	
	SET NOCOUNT OFF
END