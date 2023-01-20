USE Operacion
GO
-- 'OpeSch.OPE_CU550_Pag32_Grid_GridTraspasoManualDet_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_Grid_GridTraspasoManualDet_Sel
	@pnClaUbicacion     INT,	
    @pnClaSolicitud	    INT = 0,
    @pnClaTipoTraspaso	INT = 0,
	@pnDebug			TINYINT = 0
AS
BEGIN
    
    SET NOCOUNT ON

	-- exec OPESch.OPE_CU550_Pag32_Grid_GridTraspasoManualDet_Sel @pnClaUbicacion=325,@pnClaSolicitud=56,@pnClaTipoTraspaso=3
	-- exec OPESch.OPE_CU550_Pag32_Grid_GridTraspasoManualDet_SelHv @pnClaUbicacion=325,@pnClaSolicitud=55,@pnClaTipoTraspaso=3, @pnDebug = 1

    --Inicialización de Proceso de Envio de Datos Nivel Detalle
    SELECT  @pnClaSolicitud = ISNULL( @pnClaSolicitud,0 )

	DECLARE @tbResultado TABLE (
		  ColIdIndice				INT IDENTITY(1,1)		
		, ClaPedido					INT
		, ColProducto				INT
		, ColNomProducto         	VARCHAR(300)
		, ColUnidad              	VARCHAR(20)
		, ColCantPedidaOrigen    	NUMERIC(22,4)
		, ColCantPedida          	NUMERIC(22,4)
		, ColKilosPedidos        	NUMERIC(22,4)
		, ColToneladasPedido     	NUMERIC(22,4)
		, ColCantSurtida         	NUMERIC(22,4)
		, ColKilosSurtidos       	NUMERIC(22,4)
		, ColPrecioListaOrigen   	NUMERIC(22,4)
		, ColPrecioListaMP       	NUMERIC(22,4)
		, ColPrecioLista         	NUMERIC(22,4)
		, ColPrecioKg				NUMERIC(22,4)
		, ColPesoTeorico         	NUMERIC(22,7)
		, ColCantidadMinAgrup    	NUMERIC(18,4)
		, ColEsMultiplo          	INT
		, ColEstatus             	VARCHAR(150)
		, ColMotivoRechazo       	VARCHAR(300)
		, ColNoRenglon           	INT
		, ColClaProducto         	INT
		, ColClaEstatus          	INT
		, ColClaMotivoRechazo    	INT
		, ColClaMotivoAutomatico 	INT
		, ColEsNoActualizable    	TINYINT
		, ColEsDatoNoActualizable	TINYINT
	)

	DECLARE @tbFabricacionDet TABLE(
		  Id				INT IDENTITY(1,1)
		, IdFabricacion		INT
		, ClaArticulo		INT
		, CantidadSurtida	NUMERIC(22,4)
	)


    --Captura de Información de Registro Existente de Traspaso a Nivel Encabezado
	INSERT INTO @tbResultado (
		  ClaPedido
		, ColProducto				
		, ColNomProducto         	
		, ColUnidad              	
		, ColCantPedidaOrigen    	
		, ColCantPedida          	
		, ColKilosPedidos        	
		, ColToneladasPedido     	      	
		, ColPrecioListaOrigen   	
		, ColPrecioListaMP       	
		, ColPrecioLista         	
		, ColPrecioKg				
		, ColPesoTeorico         	
		, ColCantidadMinAgrup    	
		, ColEsMultiplo          	
		, ColEstatus             	
		, ColMotivoRechazo       	
		, ColNoRenglon           	
		, ColClaProducto         	
		, ColClaEstatus          	
		, ColClaMotivoRechazo    	
		, ColClaMotivoAutomatico 	
		, ColEsNoActualizable    	
		, ColEsDatoNoActualizable		
	)
    SELECT
			a.ClaPedido,
            ColProducto				= e.ClaArticulo,
			ColNomProducto          = CONVERT(VARCHAR(10),e.ClaveArticulo) + ' - '  + LTRIM(RTRIM(e.NomArticulo)),
            ColUnidad               = f.NomCortoUnidad,
            ColCantPedidaOrigen     = ISNULL( ISNULL( h.CantPedida,b.CantidadPedidaOrigen ),0.00 ),
            ColCantPedida           = ISNULL( b.CantidadPedida,0.00 ),
            ColKilosPedidos         = ISNULL( (b.CantidadPedida*e.PesoTeoricoKgs), 0.00 ),
            ColToneladasPedido       = (ISNULL( (b.CantidadPedida*e.PesoTeoricoKgs), 0.00 )/1000.0), -- col. oculta para calcular total en Toneladas (pie de grid)
			ColPrecioListaOrigen    = ISNULL( ISNULL( h.PrecioLista,b.PrecioListaOrigen ),0.00 ),
			ColPrecioListaMP		= ISNULL(b.PrecioListaMP,0.00),
            ColPrecioLista          = b.PrecioLista,
            ColPrecioKg				= CASE WHEN ISNULL(e.PesoTeoricoKgs,0) <> 0 THEN  ISNULL( b.PrecioLista, 0.00 )/e.PesoTeoricoKgs ELSE 0 END,
            ColPesoTeorico          = e.PesoTeoricoKgs,
            ColCantidadMinAgrup     = ISNULL( i.CantidadMinAgrup,0.00 ),
            ColEsMultiplo           = ISNULL( i.Multiplo,0 ),
            ColEstatus              = ISNULL( m.NombreEstatus,'Por Capturar' ),
            ColMotivoRechazo        = l.NomMotivoRechazoSolTraspaso,
            ColNoRenglon            = b.IdRenglon,
            ColClaProducto          = e.ClaArticulo,
            ColClaEstatus           = b.ClaEstatus,
            ColClaMotivoRechazo     = b.ClaMotivoRechazo,
            ColClaMotivoAutomatico  = b.ClaMotivoAutomatico,
            ColEsNoActualizable     = ( CASE
                                            WHEN ISNULL( b.ClaEstatus,-1 ) IN (1,2,3)
                                            THEN 1
                                            ELSE 0
                                        END),
            ColEsDatoNoActualizable = ( CASE
                                            WHEN ISNULL( b.ClaEstatus,-1 ) = 0
                                            THEN 1
                                            ELSE 0
                                        END)
    FROM    OpeSch.OpeTraSolicitudTraspasoEncVw a WITH(NOLOCK)  
    INNER JOIN  OpeSch.OpeTraSolicitudTraspasoDetVw b WITH(NOLOCK)  
        ON  a.IdSolicitudTraspaso = b.IdSolicitudTraspaso
    INNER JOIN  OpeSch.OpeArtCatArticuloVw e WITH(NOLOCK)  
        ON  b.ClaProducto = e.ClaArticulo AND e.ClaTipoInventario = 1
    INNER JOIN  OpeSch.OpeArtCatUnidadVw f WITH(NOLOCK)  
        ON  e.ClaUnidadBase = f.ClaUnidad AND f.ClaTipoInventario = 1
    LEFT JOIN   OpeSch.OpeTraFabricacionVw g WITH(NOLOCK)  
        ON  a.ClaPedidoOrigen = g.IdFabricacion           
    LEFT JOIN   OpeSch.OpeTraFabricacionDetVw h WITH(NOLOCK)  
        ON  a.ClaPedidoOrigen = h.IdFabricacion AND b.ClaProducto = h.ClaArticulo 
    LEFT JOIN   OpeSch.OpeManCatArticuloDimensionVw i WITH(NOLOCK)  
        ON  b.ClaProducto = i.ClaArticulo
    LEFT JOIN   OpeSch.OpeCatMotivoRechazoSolTraspasoVw l WITH(NOLOCK)  
        ON  ISNULL( b.ClaMotivoRechazo,b.ClaMotivoAutomatico ) = l.ClaMotivoRechazoSolTraspaso
    LEFT JOIN   TiCatalogo.dbo.TiCatEstatus m WITH(NOLOCK)  
        ON  b.ClaEstatus = m.ClaEstatus AND m.ClaClasificacionEstatus = 1270105 AND ISNULL( m.BajaLogica,0 ) = 0
    WHERE   a.IdSolicitudTraspaso = @pnClaSolicitud


	INSERT INTO @tbFabricacionDet (IdFabricacion, ClaArticulo, CantidadSurtida)
	SELECT	  a.IdFabricacion 
			, a.ClaArticulo
			, a.CantidadSurtida
	FROM	OpeSch.OpeVtaTraFabricacionDetVw a WITH(NOLOCK) -- DEAOFINET05.Ventas.VtaSch.VtaTraFabricacionDet
	INNER JOIN (
			SELECT	DISTINCT 
					  ClaPedido
					, ColClaProducto
			FROM	@tbResultado
			) AS	b
	ON		a.IdFabricacion = b.ClaPedido
	AND		a.ClaArticulo	= b.ColClaProducto


	IF @pnDebug = 1
	BEGIN
		SELECT '' AS '@tbResultado', * FROM @tbResultado
		SELECT '' AS '@tbFabricacionDet', * FROM @tbFabricacionDet
	END

	UPDATE	a
	SET		  ColCantSurtida    = ISNULL(b.CantidadSurtida,0.00)
			, ColKilosSurtidos	= ISNULL((b.CantidadSurtida * a.ColPesoTeorico), 0.00 )
	FROM	@tbResultado a
	INNER JOIN @tbFabricacionDet b
	ON		a.ClaPedido			= b.IdFabricacion
	AND		a.ColClaProducto	= b.ClaArticulo



	/*Resultado*/
	SELECT	  ColIdIndice				
			, ColProducto				
			, ColNomProducto         	
			, ColUnidad              	
			, ColCantPedidaOrigen    	
			, ColCantPedida          	
			, ColKilosPedidos        	
			, ColToneladasPedido     	
			, ColCantSurtida         	
			, ColKilosSurtidos       	
			, ColPrecioListaOrigen   	
			, ColPrecioListaMP       	
			, ColPrecioLista         	
			, ColPrecioKg				
			, ColPesoTeorico         	
			, ColCantidadMinAgrup    	
			, ColEsMultiplo          	
			, ColEstatus             	
			, ColMotivoRechazo       	
			, ColNoRenglon           	
			, ColClaProducto         	
			, ColClaEstatus          	
			, ColClaMotivoRechazo    	
			, ColClaMotivoAutomatico 	
			, ColEsNoActualizable    	
			, ColEsDatoNoActualizable	
	FROM	@tbResultado 
	ORDER BY ColNomProducto ASC


    SET NOCOUNT OFF       

	RETURN
END