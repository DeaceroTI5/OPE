USE Operacion
GO
	-- 'OpeSch.OPE_CU550_Pag32_Grid_GridCargaPartidasOrigenDet_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_Grid_GridCargaPartidasOrigenDet_Sel
	@pnClaUbicacion     INT,	
    @pnClaSolicitud	    INT = 0,
    @pnClaPedidoOrigen	INT = 0,
    @pnClaTipoTraspaso	INT,
	@pnDebug			TINYINT = 0
AS
BEGIN
    
    SET NOCOUNT ON

	-- exec OPESch.OPE_CU550_Pag32_Grid_GridCargaPartidasOrigenDet_Sel @pnClaUbicacion=325,@pnClaSolicitud=291,@pnClaPedidoOrigen=24391091,@pnClaTipoTraspaso=3,@pnDebug=1

    --Inicialización de Proceso de Envio de Datos Nivel Detalle
    SELECT  @pnClaSolicitud     = ISNULL( @pnClaSolicitud,0 ),
            @pnClaPedidoOrigen  = ISNULL( @pnClaPedidoOrigen,0 )


	DECLARE @tbFabricacionOrigen TABLE(
		  Id						INT IDENTITY(1,1)
		, ColSeleccionCPD			TINYINT                       
		, ColProductoCPD			VARCHAR(300)
		, ColUnidadCPD				VARCHAR(20)
		, ColCantPedidaCPD			NUMERIC(22,4)
		, ColKilosPedidosCPD		NUMERIC(22,4)
		, ColCantSurtidaCPD			NUMERIC(22,4)
		, ColKilosSurtidosCPD		NUMERIC(22,4)
		, ColPrecioListaMPCPD		NUMERIC(25,4)
		, ColPrecioListaCPD			NUMERIC(22,4)
		, ColPesoTeoricoCPD			NUMERIC(22,7)
		, ColCantidadMinAgrupCPD	NUMERIC(18,4)
		, ColEsMultiploCPD			INT
		, ColEstatusCPD				VARCHAR(150)
		, ColNoRenglonCPD			INT
		, ColClaProductoCPD			INT
		, ColClaEstatusCPD        	INT
		, ClaProyecto				INT
		, ClaEstatusDet				INT
	)

	DECLARE @tbOtrasSolicitudes TABLE(
		  Id					INT IDENTITY(1,1)
		, ClaPedido				INT
		, ClaProducto			INT
		, ClaEstatus			INT
		, CantidadFabricacion	NUMERIC(22,4)
		, CantidadSolicitada	NUMERIC(22,4)
		, CantidadDisponible	NUMERIC(22,4)
	)

	DECLARE @tbCantidadProducto TABLE(
		  Id					INT IDENTITY(1,1)
		, ClaProducto			INT
		, CantidadSolicitada	NUMERIC(22,4)
		, CantidadDisponible	NUMERIC(22,4)
	)

	IF @pnClaTipoTraspaso <> 4 -- Consulta desde comercial si es Exportación
	BEGIN
		--Captura de Información de Registro Existente de Traspaso a Nivel Encabezado
		INSERT INTO @tbFabricacionOrigen (
			  ColSeleccionCPD			
			, ColProductoCPD			
			, ColUnidadCPD				
			, ColCantPedidaCPD			
			, ColKilosPedidosCPD		
			, ColCantSurtidaCPD			
			, ColKilosSurtidosCPD		
			, ColPrecioListaCPD			
			, ColPesoTeoricoCPD			
			, ColCantidadMinAgrupCPD	
			, ColEsMultiploCPD			
			, ColEstatusCPD				
			, ColNoRenglonCPD			
			, ColClaProductoCPD			
			, ColClaEstatusCPD
			, ClaProyecto
			, ClaEstatusDet
		)
		SELECT  DISTINCT
				ColSeleccionCPD         = ( CASE
												WHEN ISNULL( h.ClaProducto,0 ) > 0
												THEN 1
												ELSE 0
											END ),
				ColProductoCPD          = CONVERT(VARCHAR(10),c.ClaveArticulo) + ' - '  + LTRIM(RTRIM(c.NomArticulo)),
				ColUnidadCPD            = d.NomCortoUnidad,
				ColCantPedidaCPD        = ISNULL( b.CantPedida,0.00 ),
				ColKilosPedidosCPD      = ISNULL( (b.CantPedida*c.PesoTeoricoKgs), 0.00 ),
				ColCantSurtidaCPD       = ISNULL( b.CantSurtida,0.00 ),
				ColKilosSurtidosCPD     = ISNULL( (b.CantSurtida*c.PesoTeoricoKgs), 0.00 ),
				ColPrecioListaCPD       = ISNULL( b.PrecioLista,0.00 ),
				ColPesoTeoricoCPD       = c.PesoTeoricoKgs,
				ColCantidadMinAgrupCPD  = ISNULL( i.CantidadMinAgrup,0.00 ),
				ColEsMultiploCPD        = ISNULL( i.Multiplo,0 ),
				ColEstatusCPD           = ISNULL( l.NombreEstatus,'Por Capturar' ),
				ColNoRenglonCPD         = b.IdFabricacionDet,
				ColClaProductoCPD       = c.ClaArticulo,
				ColClaEstatusCPD        = h.ClaEstatus,
				e.ClaProyecto,
				ClaEstatusDet			= b.ClaEstatus
		FROM    OpeSch.OpeTraFabricacionVw a WITH(NOLOCK)  
		INNER JOIN  OpeSch.OpeTraFabricacionDetVw b WITH(NOLOCK)  
			ON  a.IdFabricacion = b.IdFabricacion
		INNER JOIN  OpeSch.OpeArtCatArticuloVw c WITH(NOLOCK)  
			ON  b.ClaArticulo = c.ClaArticulo AND c.ClaTipoInventario = 1
		INNER JOIN  OpeSch.OpeArtCatUnidadVw d WITH(NOLOCK)  
			ON  c.ClaUnidadBase = d.ClaUnidad AND d.ClaTipoInventario = 1
		INNER JOIN  OpeSch.OpeVtaRelFabricacionProyectoVw e WITH(NOLOCK)  
			ON  a.IdFabricacion = e.IdFabricacion
		INNER JOIN  OpeSch.OpeVtaCatProyectoVw f WITH(NOLOCK)  
			ON  e.ClaProyecto = f.ClaProyecto
		LEFT JOIN   OpeSch.OpeTraSolicitudTraspasoEncVw g WITH(NOLOCK)  
			ON  a.IdFabricacion = g.ClaPedidoOrigen AND g.IdSolicitudTraspaso = @pnClaSolicitud
		LEFT JOIN   OpeSch.OpeTraSolicitudTraspasoDetVw h WITH(NOLOCK)  
			ON  g.IdSolicitudTraspaso = h.IdSolicitudTraspaso AND b.ClaArticulo = h.ClaProducto  
		LEFT JOIN   OpeSch.OpeManCatArticuloDimensionVw i WITH(NOLOCK)  
			ON  b.ClaArticulo = i.ClaArticulo
		LEFT JOIN   TiCatalogo.dbo.TiCatEstatus l WITH(NOLOCK)  
			ON  h.ClaEstatus = l.ClaEstatus AND l.ClaClasificacionEstatus = 1270105 AND ISNULL( l.BajaLogica,0 ) = 0
		WHERE   a.IdFabricacion = @pnClaPedidoOrigen
	END	
	ELSE
	BEGIN
		--Captura de Información de Registro Existente de Traspaso a Nivel Encabezado
		INSERT INTO @tbFabricacionOrigen (
			  ColSeleccionCPD			
			, ColProductoCPD			
			, ColUnidadCPD				
			, ColCantPedidaCPD			
			, ColKilosPedidosCPD		
			, ColCantSurtidaCPD			
			, ColKilosSurtidosCPD		
			, ColPrecioListaCPD			
			, ColPesoTeoricoCPD			
			, ColCantidadMinAgrupCPD	
			, ColEsMultiploCPD			
			, ColEstatusCPD				
			, ColNoRenglonCPD			
			, ColClaProductoCPD			
			, ColClaEstatusCPD
			, ClaProyecto
			, ClaEstatusDet
		)
		SELECT  DISTINCT
				ColSeleccionCPD         = ( CASE
												WHEN ISNULL( h.ClaProducto,0 ) > 0
												THEN 1
												ELSE 0
											END ),
				ColProductoCPD          = CONVERT(VARCHAR(10),c.ClaveArticulo) + ' - '  + LTRIM(RTRIM(c.NomArticulo)),
				ColUnidadCPD            = d.NomCortoUnidad,
				ColCantPedidaCPD        = ISNULL( b.CantidadPedida,0.00 ),
				ColKilosPedidosCPD      = ISNULL( (b.CantidadPedida*c.PesoTeoricoKgs), 0.00 ),
				ColCantSurtidaCPD       = ISNULL( b.CantidadSurtida,0.00 ),
				ColKilosSurtidosCPD     = ISNULL( (b.CantidadSurtida*c.PesoTeoricoKgs), 0.00 ),
				ColPrecioListaCPD       = ISNULL( b.PrecioLista,0.00 ),
				ColPesoTeoricoCPD       = c.PesoTeoricoKgs,
				ColCantidadMinAgrupCPD  = ISNULL( i.CantidadMinAgrup,0.00 ),
				ColEsMultiploCPD        = ISNULL( i.Multiplo,0 ),
				ColEstatusCPD           = ISNULL( l.NombreEstatus,'Por Capturar' ),
				ColNoRenglonCPD         = b.NumeroRenglon,
				ColClaProductoCPD       = c.ClaArticulo,
				ColClaEstatusCPD        = h.ClaEstatus,
				ClaProyecto				= ISNULL(e.ClaProyecto,a.ClaProyecto),
				ClaEstatusDet			= CASE WHEN ISNULL(b.ClaEstatusFabricacion,0) IN (4,5)
												THEN 1 ELSE 0 END
		FROM    DEAOFINET05.Ventas.VtaSch.VtaTraFabricacion a WITH(NOLOCK)  
		INNER JOIN  DEAOFINET05.Ventas.VtaSch.VtaTraFabricacionDetVw b WITH(NOLOCK)  
			ON  a.IdFabricacion = b.IdFabricacion
		INNER JOIN  OpeSch.OpeArtCatArticuloVw c WITH(NOLOCK)  
			ON  b.ClaArticulo = c.ClaArticulo AND c.ClaTipoInventario = 1
		INNER JOIN  OpeSch.OpeArtCatUnidadVw d WITH(NOLOCK)  
			ON  c.ClaUnidadBase = d.ClaUnidad AND d.ClaTipoInventario = 1
		LEFT JOIN  OpeSch.OpeVtaRelFabricacionProyectoVw e WITH(NOLOCK)  
			ON  a.IdFabricacion = e.IdFabricacion
		LEFT JOIN   OpeSch.OpeTraSolicitudTraspasoEncVw g WITH(NOLOCK)  
			ON  a.IdFabricacion = g.ClaPedidoOrigen AND g.IdSolicitudTraspaso = @pnClaSolicitud
		LEFT JOIN   OpeSch.OpeTraSolicitudTraspasoDetVw h WITH(NOLOCK)  
			ON  g.IdSolicitudTraspaso = h.IdSolicitudTraspaso AND b.ClaArticulo = h.ClaProducto  
		LEFT JOIN   OpeSch.OpeManCatArticuloDimensionVw i WITH(NOLOCK)  
			ON  b.ClaArticulo = i.ClaArticulo
		LEFT JOIN   TiCatalogo.dbo.TiCatEstatus l WITH(NOLOCK)  
			ON  h.ClaEstatus = l.ClaEstatus AND l.ClaClasificacionEstatus = 1270105 AND ISNULL( l.BajaLogica,0 ) = 0
		WHERE   a.IdFabricacion = @pnClaPedidoOrigen
	END

	IF ISNULL(@pnClaTipoTraspaso,0) IN (3,4)
	BEGIN
		UPDATE	a
		SET		ColPrecioListaMPCPD     = ISNULL( ISNULL( j.PrecioMP,k.PrecioMP ),0.00 )
		FROM	@tbFabricacionOrigen a
		OUTER APPLY (
			SELECT	TOP 1 jj.PrecioMP
			FROM	DEAOFINET05.Ventas.VtaSch.VtaTraControlProyectoDet jj WITH(NOLOCK)
			WHERE	a.ClaProyecto		= jj.ClaProyecto 
			AND		a.ColClaProductoCPD = jj.ValorLlaveCriterio
			ORDER BY jj.FechaUltimaMod DESC
		) j
		OUTER APPLY (
			SELECT	TOP 1 kk.PrecioMP
			FROM	DEAOFINET05.Ventas.VtaSch.VtaTraControlProyectoDet kk WITH(NOLOCK)  
			WHERE	a.ClaProyecto		= kk.ClaProyecto 
			AND		a.ColPrecioListaCPD = kk.Precio
			ORDER BY kk.FechaUltimaMod DESC
		) k
	END
	ELSE
	BEGIN
		UPDATE	a
		SET		ColPrecioListaMPCPD     = 0.00
		FROM	@tbFabricacionOrigen a
	END


	IF @pnClaPedidoOrigen IS NOT NULL -- AND @pnClaTipoTraspaso = 3
	BEGIN
		---- CANTIDAD
		INSERT INTO @tbOtrasSolicitudes (ClaPedido, ClaProducto, ClaEstatus, CantidadFabricacion, CantidadSolicitada, CantidadDisponible)
		EXEC OpeSch.OPE_CU550_Pag32_ValidaCantidadPedidoOrigenProc
			  @pnClaPedidoOrigen	= @pnClaPedidoOrigen
			, @pnClaSolicitud		= @pnClaSolicitud
			, @pnClaArticulo		= NULL	
	END


	INSERT INTO @tbCantidadProducto (ClaProducto, CantidadSolicitada, CantidadDisponible)
		SELECT  
				  ClaProducto
				, CantidadSolicitada = SUM(CantidadSolicitada)
				, CantidadDisponible
		FROM	@tbOtrasSolicitudes
		GROUP BY ClaProducto,CantidadDisponible


	/*Resultado*/
	SELECT	  ColSeleccionCPD			
			, ColProductoCPD			
			, ColUnidadCPD				
			, ColCantPedidaCPD			
			, ColKilosPedidosCPD		
			, ColCantSurtidaCPD			
			, ColKilosSurtidosCPD		
			, ColPrecioListaMPCPD		
			, ColPrecioListaCPD			
			, ColPesoTeoricoCPD			
			, ColCantidadMinAgrupCPD	
			, ColEsMultiploCPD			
			, ColEstatusCPD				
			, ColNoRenglonCPD			
			, ColClaProductoCPD			
			, ColClaEstatusCPD
			, ColCantidadDisponible = ISNULL(b.CantidadDisponible,ColCantPedidaCPD)
			, ColCantidadSolicitada = ISNULL(b.CantidadSolicitada,0)
			, ColEstatusDet			= c.NombreEstatus
	FROM	@tbFabricacionOrigen a
	LEFT JOIN @tbCantidadProducto b
	ON		a.ColClaProductoCPD = b.ClaProducto
	LEFT JOIN OPESch.OPETiCatEstatusVw c WITH(NOLOCK)
	ON		a.ClaEstatusDet			  = c.ClaEstatus
	AND		c.ClaClasificacionEstatus = 1270004

    SET NOCOUNT OFF       

	RETURN
END