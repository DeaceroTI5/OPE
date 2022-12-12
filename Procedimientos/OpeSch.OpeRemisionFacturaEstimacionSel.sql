USE Operacion
GO
	-- 'OpeSch.OpeRemisionFacturaEstimacionSel'
GO
ALTER PROCEDURE OpeSch.OpeRemisionFacturaEstimacionSel
	  @pdFechaInicio			DATETIME	= NULL
    , @pdFechaFin				DATETIME    = NULL
    , @pnCmbCliente				INT			= NULL
    , @pnCmbProyecto			INT			= NULL
    , @pnCmbFactura				INT			= NULL
    , @pnEstimacionFactura		INT			= NULL
	, @pnFabricacionVenta		INT			= NULL
    , @pnFabricacionDetVentaDet INT			= NULL
    , @pnArticuloDet            INT			= NULL
    , @pnFolioProforma			INT			= NULL
    , @pnFolioFactura			INT			= NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT @pdFechaFin = DATEADD(DAY,1,@pdFechaFin)
	
	CREATE TABLE #tbRemisionFactura (
		  Id						INT IDENTITY(1,1)
		, ClaCliente				INT
		, ClaProyecto 				INT
		, IdViaje					INT
		, Remision					VARCHAR(20)
		, ClaArticulo				INT
		-- FacturaRemision
		, NomProductoFacturar		VARCHAR(100)
		, ComentariosFacturaDet		VARCHAR(8000)
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

	
	INSERT INTO #tbRemisionFactura (
		  ClaCliente				, ClaProyecto 				, IdViaje					, Remision					
		, ClaArticulo				, NomProductoFacturar		, ComentariosFacturaDet		, IdEstimacionFactura 		
		, IdFabricacion 			, IdFabricacionDet 			, ClaUsuarioTra				, FechaTra					
		, CantSurtidaTra			, IdProforma  				, Estatus					, ObservacionEstimacion		
		, ComentariosFactura
	)
	SELECT
			  ClaCliente				= a.ClienteProyectoAgp
			, ClaProyecto 				= a.ProyectoAgrupador
			, IdViaje					= a.IdViajeVenta				
			, Remision					= a.FacturaAlfanumericoVenta	
			, ClaArticulo				= a.ClaArticulo	
			, NomProductoFacturar		= c.NomProductoFacturar
			, ComentariosFacturaDet		= c.ComentariosFacturaDet
			, IdEstimacionFactura 		= b.IdEstimacionFactura
			, IdFabricacion 			= b.IdFabricacion
			, IdFabricacionDet 			= b.IdFabricacionDet
			, ClaUsuarioTra				= b.ClaUsuarioMod
			, FechaTra					= b.FechaUltimaMod
			, CantSurtidaTra			= b.CantSurtida
			, IdProforma  				= d.IdProforma
			, Estatus					= CONVERT(VARCHAR, d.Estatus) + ' - ' + 
														CASE d.Estatus WHEN 0 THEN 'Nuevo' WHEN 1 THEN 'Alta' WHEN 3 THEN 'Facturado' WHEN 5 THEN 'Cancelado' END
			, ObservacionEstimacion		= d.ObservacionEstimacion
			, ComentariosFactura		= d.ComentariosFactura
	FROM	OpeSch.OpeRelEmbarqueEstimacionVw a
	INNER JOIN OpeTraRelFacturaRemisionEstimacionDetVw b
	ON		a.IdViajeVenta				= b.IdViaje
	AND		a.FacturaAlfanumericoVenta	= b.RemisionAlfanumerico
	AND		a.ClaArticulo				= b.ClaArticulo
	INNER JOIN OpeSch.OpeTraFacturaEstimacionDetVw c
	ON		b.IdEstimacionFactura		= c.IdEstimacionFactura	
	AND		b.IdFabricacion				= c.IdFabricacion			
	AND		b.IdFabricacionDet			= c.IdFabricacionDet		
	AND		b.ClaArticulo				= c.ClaArticulo			
	INNER JOIN OpeSch.OpeTraFacturaEstimacionVw  d
	ON		b.IdEstimacionFactura		= d.IdEstimacionFactura
	AND		b.IdFabricacion				= d.IdFabricacion
	INNER JOIN DEAOFINET05.Ventas.VtaSch.VtaRelProformaFabricacion e
	ON		d.IdProforma				= e.IdProforma
	AND		d.IdFabricacion				= e.IdFabricacion
	WHERE	(@pnCmbCliente			IS NULL OR (@pnCmbCliente = a.ClienteProyectoAgp))
	AND		(@pnCmbProyecto			IS NULL OR (@pnCmbProyecto = a.ProyectoAgrupador))
	AND		(@pnFabricacionVenta	IS NULL OR (@pnFabricacionVenta = b.IdFabricacion))
	AND		(@pnEstimacionFactura	IS NULL OR (@pnEstimacionFactura = b.IdEstimacionFactura))
	AND		(@pnFolioProforma		IS NULL OR (@pnFolioProforma = d.IdProforma))
	AND		(@pnArticuloDet			IS NULL OR (@pnArticuloDet = a.ClaArticulo))


	UPDATE	a
	SET		FacturaNueva =
				CASE    WHEN f.IdFacturaNueva IS NULL
						THEN NULL
						ELSE 'QH' + CONVERT(VARCHAR(15), ( f.IdFacturaNueva - ( 1000000 * 1028 ) )) 
				END
			, FechaFactura		= f.FechaUltimaMod
			, IdFacturaNueva	= f.IdFacturaNueva
	FROM	#tbRemisionFactura a
	INNER JOIN DEAOFINET05.Ventas.VtaSch.VtaTraProforma f WITH(NOLOCK)		-- 
	ON		a.IdProforma			= f.IdProforma



	UPDATE	a
	SET		
			  CantidadSurtida	= g.CantidadSurtida
			, KilosSurtidos		= g.KilosSurtidos
			, ImporteSubtotal	= g.ImporteSubtotal
			, ImporteTotal		= g.Total
			, IVA				= g.IVA
	FROM	#tbRemisionFactura a
	INNER JOIN DEAOFINET05.Ventas.VtaSch.VtaTraProformaDet g WITH(NOLOCK)		-- IdProforma, IdRenglon
	ON		a.IdProforma			= g.IdProforma
	AND		a.IdFabricacionDet		= g.IdRenglon
	AND		a.ClaArticulo			= g.ClaArticulo




	/*Resultado*/
	SELECT	  ClaCliente			
			, ClaProyecto 			
			, IdViaje				
			, Remision				
			, ClaArticulo	
			, NomProductoFacturar
			, ComentariosFacturaDet
			-- FacturaRemision
			, IdEstimacionFactura 	
			, IdFabricacion 		
			, IdFabricacionDet 		
			, ClaUsuarioTra			
			, FechaTra				
			, CantSurtidaTra		
			, IdProforma  			
			, Estatus				
			, ObservacionEstimacion	
			, ComentariosFactura	
			-- Proforma
			, FacturaNueva			
			, FechaFactura			
			, IdFacturaNueva		
			, CantidadSurtida		
			, KilosSurtidos			
			, ImporteSubtotal		
			, IVA					
			, ImporteTotal			
	FROM	#tbRemisionFactura 
	WHERE	(FechaFactura > @pdFechaInicio AND FechaFactura <= @pdFechaFin)
	AND		(@pnCmbFactura IS NULL OR (@pnCmbFactura = IdFacturaNueva))
	
	
	DROP TABLE #tbRemisionFactura

	SET NOCOUNT OFF
END