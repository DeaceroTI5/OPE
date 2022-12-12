GO
-- 'OpeSch.OPE_CU550_Pag31_Grid_GridFacturaDetArticulo_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag31_Grid_GridFacturaDetArticulo_Sel
    @pnClaUbicacion         INT, 
    @pnActividad            INT,
    @pdFechaInicio          DATETIME, 
    @pdFechaFin             DATETIME,	
    @pnFabricacionVenta     INT,
    @pnEstimacionFactura    INT,
    @pnFolioProforma        INT,
    @pnFolioFactura         INT
AS
BEGIN    
	SET NOCOUNT ON

	DECLARE   @pnCmbCliente					INT
			, @pnCmbProyecto				INT
			, @pnCmbFactura					INT
			, @pnFabricacionDetVentaDet		INT
			, @pnArticuloDet				INT
			, @pnFabricacionVentaDet		INT
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



	
	--'OpeSch.OPE_CU550_Pag31_Grid_GridFacturaDetArticulo_Sel' (Grid 2)
    SELECT
              ColNoRenglonDet		= a.IdFabricacionDet
			, ColArticuloDet		= LTRIM(RTRIM(b.ClaveArticulo)) + ' - ' + b.NomArticulo 
            , ColNomProductoDet		= a.NomProductoFacturar
            , ColCantSurtidaDet		= a.CantidadSurtida	-- SUM(a.CantidadSurtida)	--a.CantidadSurtida		
            , ColKilosSurtidosDet	= a.KilosSurtidos	-- SUM(a.KilosSurtidos)		--a.KilosSurtidos		
            , ColImporteDet			= a.ImporteTotal	-- SUM(a.ImporteTotal)		--a.ImporteTotal		
            , ColComentariosDet		= a.ComentariosFacturaDet
            , ColFabricacionDet		= a.IdFabricacion
            , ColFabDetalleDet		= a.IdFabricacionDet
            , ColClaArticuloDet		= a.ClaArticulo
	FROM	#tbRemisionFactura a
	INNER JOIN  Opesch.OpeArtCatArticuloVw b WITH(NOLOCK)
    ON		a.ClaArticulo			= b.ClaArticulo
	WHERE	(IdEstimacionFactura	= @pnEstimacionFactura	OR @pnEstimacionFactura IS NULL)
    AND		(IdFabricacion			= @pnFabricacionVenta	OR @pnFabricacionVenta IS NULL)
    AND		(IdProforma				= @pnFolioProforma		OR @pnFolioProforma IS NULL)
    --AND		vtaTP.IdFacturaNueva = @pnFolioFactura
    GROUP BY  a.IdFabricacionDet 
			, LTRIM(RTRIM(b.ClaveArticulo)) + ' - ' + b.NomArticulo 
			, a.NomProductoFacturar	
			, a.CantidadSurtida	
			, a.KilosSurtidos	
			, a.ImporteTotal	
			, a.ComentariosFacturaDet
			, a.IdFabricacion
			, a.IdFabricacionDet
			, a.ClaArticulo
	ORDER BY
            a.IdFabricacion, a.IdFabricacionDet, a.ClaArticulo



	DROP TABLE #tbRemisionFactura	

	SET NOCOUNT OFF
END