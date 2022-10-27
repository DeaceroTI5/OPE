Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE OpeSch.OPE_CU550_Pag32_Grid_GridTraspasoManualDet_Sel
	@pnClaUbicacion     INT,	
    @pnClaSolicitud	    INT = 0,
    @pnClaTipoTraspaso	INT
AS
BEGIN
    
    SET NOCOUNT ON

    --Inicialización de Proceso de Envio de Datos Nivel Detalle
    SELECT  @pnClaSolicitud = ISNULL( @pnClaSolicitud,0 )

    --Captura de Información de Registro Existente de Traspaso a Nivel Encabezado
    SELECT  DISTINCT
            ColProducto				= e.ClaArticulo,
			ColNomProducto          = CONVERT(VARCHAR(10),e.ClaveArticulo) + ' - '  + LTRIM(RTRIM(e.NomArticulo)),
            ColUnidad               = f.NomCortoUnidad,
            ColCantPedidaOrigen     = ISNULL( ISNULL( h.CantPedida,b.CantidadPedidaOrigen ),0.00 ),
            ColCantPedida           = ISNULL( b.CantidadPedida,0.00 ),
            ColKilosPedidos         = ISNULL( (b.CantidadPedida*e.PesoTeoricoKgs), 0.00 ),
            ColToneladasPedido       = (ISNULL( (b.CantidadPedida*e.PesoTeoricoKgs), 0.00 )/1000.0), -- col. oculta para calcular total en Toneladas (pie de grid)
            ColCantSurtida          = ISNULL( d.CantidadSurtida,0.00 ),
            ColKilosSurtidos        = ISNULL( (d.CantidadSurtida*e.PesoTeoricoKgs), 0.00 ),
            ColPrecioListaOrigen    = ISNULL( ISNULL( h.PrecioLista,b.PrecioListaOrigen ),0.00 ),
            ColPrecioListaMP        = ( CASE
                                            WHEN ISNULL( @pnClaTipoTraspaso,0 ) = 3
                                            THEN ISNULL( ISNULL( ISNULL( j.PrecioMP,k.PrecioMP ),b.PrecioListaMP ),0.00 )
                                            ELSE 0.00
                                        END),
            ColPrecioLista          = b.PrecioLista,
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
    LEFT JOIN   DEAOFINET05.Ventas.VtaSch.VtaTraFabricacion c WITH(NOLOCK)  
        ON  a.ClaPedido = c.IdFabricacion AND a.ClaUbicacionSurte = c.ClaUbicacion
    LEFT JOIN   DEAOFINET05.Ventas.VtaSch.VtaTraFabricacionDet d WITH(NOLOCK)  
        ON  a.ClaPedido = d.IdFabricacion AND b.ClaProducto = d.ClaArticulo
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
    LEFT JOIN   DEAOFINET05.Ventas.VtaSch.VtaTraControlProyectoDet j WITH(NOLOCK)  
        ON  a.ClaProyecto = j.ClaProyecto AND b.ClaProducto = j.ValorLlaveCriterio 
    LEFT JOIN   DEAOFINET05.Ventas.VtaSch.VtaTraControlProyectoDet k WITH(NOLOCK)  
        ON  a.ClaProyecto = k.ClaProyecto AND h.PrecioLista = k.Precio 
    LEFT JOIN   OpeSch.OpeCatMotivoRechazoSolTraspasoVw l WITH(NOLOCK)  
        ON  ISNULL( b.ClaMotivoRechazo,b.ClaMotivoAutomatico ) = l.ClaMotivoRechazoSolTraspaso
    LEFT JOIN   TiCatalogo.dbo.TiCatEstatus m WITH(NOLOCK)  
        ON  b.ClaEstatus = m.ClaEstatus AND m.ClaClasificacionEstatus = 1270105 AND ISNULL( m.BajaLogica,0 ) = 0
    WHERE   a.IdSolicitudTraspaso = @pnClaSolicitud

    SET NOCOUNT OFF       

	RETURN
END
