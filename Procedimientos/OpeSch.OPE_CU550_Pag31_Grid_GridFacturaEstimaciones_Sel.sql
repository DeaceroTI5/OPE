GO
-- 'OpeSch.OPE_CU550_Pag31_Grid_GridFacturaEstimaciones_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag31_Grid_GridFacturaEstimaciones_Sel 
    @pnClaUbicacion         INT, 
    @pdFechaInicio          DATETIME, 
    @pdFechaFin             DATETIME,     
    @pnCmbCliente           INT, 
    @pnCmbProyecto          INT, 
    @pnCmbFactura           INT,
	@pnDebug				TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	DECLARE	@CmbCliente     INT, 
            @CmbProyecto    INT,
			@CmbFactura     INT
	
	SELECT	@CmbCliente     = (CASE WHEN (@pnCmbCliente = -1 OR @pnCmbCliente IS NULL) THEN 1 ELSE 0 END),
			@CmbProyecto    = (CASE WHEN (@pnCmbProyecto = -1 OR @pnCmbProyecto IS NULL) THEN 1 ELSE 0 END),
            @CmbFactura     = (CASE WHEN (@pnCmbFactura = -1 OR @pnCmbFactura IS NULL) THEN 1 ELSE 0 END)

	DECLARE   @pnEstimacionFactura			INT
			, @pnFabricacionVenta			INT
			, @pnFabricacionDetVentaDet		INT
			, @pnArticuloDet				INT
			, @pnFolioProforma				INT
			, @pnFolioFactura				INT
			, @pnFabricacionVentaDet		INT

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

	;WITH RemisionFactura AS (
		SELECT    ColFacturaNueva		= a.FacturaNueva
				, ColNomCliente			= LTRIM(RTRIM(CONVERT(VARCHAR(150), a.ClaCliente))) + ' - ' + b.NomCliente
				, ColNomProyecto		= LTRIM(RTRIM(CONVERT(VARCHAR(150), a.ClaProyecto))) + ' - ' + c.NomProyecto
				, ColFabricacionVenta	= a.IdFabricacion
				, ColKilosSurtidos		= a.KilosSurtidos	--SUM(a.KilosSurtidos)
				, ColImporteSubtotal	= a.ImporteSubtotal	--SUM(a.ImporteSubtotal)
				, ColIVA				= a.IVA				--SUM(a.IVA)
				, ColImporteTotal		= a.ImporteTotal	--SUM(a.ImporteTotal)
				, ColEstatus			= a.Estatus
				, ColObservaciones		= a.ObservacionEstimacion
				, ColComentarios		= a.ComentariosFactura
				, ColFechaFactura		= a.FechaFactura
				, ColClaCliente			= a.ClaCliente
				, ColClaProyecto		= a.ClaProyecto
				, ColEstimacionFactura	= a.IdEstimacionFactura
				, ColFolioProforma		= a.IdProforma
				, ColFolioFactura		= a.IdFacturaNueva
		FROM	#tbRemisionFactura a
		LEFT JOIN OpeSch.OpeVtaCatClienteVw b WITH(NOLOCK)
		ON		a.ClaCliente	= b.ClaCliente
		LEFT JOIN OpeSch.OpeVtaCatProyectoVw c WITH(NOLOCK)
		ON		a.ClaProyecto	= c.ClaProyecto	
		WHERE	( a.ClaCliente		= @pnCmbCliente		OR @CmbCliente = 1 )  
		AND		( a.ClaProyecto		= @pnCmbProyecto	OR @CmbProyecto = 1 ) 
		AND		( a.IdFacturaNueva	= @pnCmbFactura		OR @CmbFactura = 1 ) 
		GROUP BY    a.FacturaNueva
				  , LTRIM(RTRIM(CONVERT(VARCHAR(150), a.ClaCliente))) + ' - ' + b.NomCliente
				  , LTRIM(RTRIM(CONVERT(VARCHAR(150), a.ClaProyecto))) + ' - ' + c.NomProyecto
				  , a.IdFabricacion
				  , a.KilosSurtidos	
				  , a.ImporteSubtotal	
				  , a.IVA				
				  , a.ImporteTotal	
				  , a.Estatus
				  , a.ObservacionEstimacion
				  , a.ComentariosFactura
				  , a.FechaFactura
				  , a.ClaCliente
				  , a.ClaProyecto
				  , a.IdEstimacionFactura
				  , a.IdProforma
				  , a.IdFacturaNueva
	)
		SELECT		  ColFacturaNueva		
					, ColNomCliente			
					, ColNomProyecto		
					, ColFabricacionVenta	
					, ColKilosSurtidos		= SUM(ColKilosSurtidos)
					, ColImporteSubtotal	= SUM(ColImporteSubtotal)
					, ColIVA				= SUM(ColIVA)
					, ColImporteTotal		= SUM(ColImporteTotal)
					, ColEstatus			
					, ColObservaciones		
					, ColComentarios		
					, ColFechaFactura		
					, ColClaCliente			
					, ColClaProyecto		
					, ColEstimacionFactura	
					, ColFolioProforma		
					, ColFolioFactura		
		FROM		RemisionFactura 
		GROUP BY    ColFacturaNueva		
				  , ColNomCliente			
				  , ColNomProyecto		
				  , ColFabricacionVenta		
				  , ColEstatus			
				  , ColObservaciones		
				  , ColComentarios		
				  , ColFechaFactura		
				  , ColClaCliente			
				  , ColClaProyecto		
				  , ColEstimacionFactura	
				  , ColFolioProforma		
				  , ColFolioFactura		
		ORDER BY ColFacturaNueva, ColFabricacionVenta


	DROP TABLE #tbRemisionFactura

	SET NOCOUNT OFF
END