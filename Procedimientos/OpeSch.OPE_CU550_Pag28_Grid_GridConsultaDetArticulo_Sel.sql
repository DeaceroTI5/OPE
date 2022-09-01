USE Operacion
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag28_Grid_GridConsultaDetArticulo_Sel 
    @pnClaUbicacion         INT,

    @pnFabricacionVenta     INT,
    @pnViajeVenta           INT,
    @psRemision             VARCHAR(20)
AS
BEGIN      
    ------Inicio: Proceso PreEjecucion de Consulta------
    ;WITH	PedidosEstimaciones AS
    (SELECT	a.IdFabriacionUnificado, 365 AS ClaUbicacionVenta, a.IdFabricacionOriginal AS idFabricacionVenta, a.ClaUbicacion AS ClaUbicacionEstimacion, a.IdFabricacionEstimacion AS idFabricacionEstimacion
    FROM	OpeSch.OpeRelFabricacionbUnificadasVw a WITH(NOLOCK)
    WHERE	a.IdControlUnificacion IN (SELECT MAX(IdControlUnificacion)
                                            FROM OpeSch.OpeRelFabricacionbUnificadasVw 
                                            GROUP BY ClaUbicacion, IdFabricacionOriginal, IdFabricacionEstimacion)
    UNION
    SELECT DISTINCT
            NULL AS IdFabriacionUnificado, b.ClaUbicacionVenta, b.idFabricacionVenta, b.ClaUbicacionEstimacion, b.idFabricacionEstimacion
    FROM	OpeSch.OpeTraFabricacionEspejoEstimacion b WITH(NOLOCK)
    WHERE	b.idFabricacionVenta NOT IN (SELECT DISTINCT IdFabriacionUnificado
                                            FROM OpeSch.OpeRelFabricacionbUnificadasVw)),
            PedidoAgrupadoEncabezado AS
    (SELECT	er.ClaCliente AS ClaCliente,
            ltrim(rtrim(convert(varchar(150), er.ClaCliente))) + ' - ' + er.NombreCliente AS Cliente,
            dr.ClaProyecto AS ClaProyecto,
            ltrim(rtrim(convert(varchar(150), dr.ClaProyecto))) + ' - ' + dr.NomProyecto AS Proyecto,
            a.ClaUbicacionVenta AS Planta_VO,
            ur.IdFabricacion AS Pedido_Unificado,	
            br.IdFabricacion AS Pedido_Venta_Original,
            SUM(bdr.CantPedida) AS Cantidad_Pedida_Venta_Enc,
            SUM(bdr.CantSurtida) AS Cantidad_Surtida_Venta_Enc,
            a.ClaUbicacionEstimacion AS Planta_E,
            be.IdFabricacion AS Pedido_Espejo,
            SUM(bde.CantPedida) AS Cantidad_Pedida_Espejo_Enc,
            SUM(bde.CantSurtida) AS Cantidad_Surtida_Espejo_Enc
    FROM	PedidosEstimaciones a 
        --Flujo de Remision / Venta
        INNER JOIN	OpeSch.OpeTraFabricacionVw br WITH(NOLOCK)
                    ON br.IdFabricacion = a.idFabricacionVenta
        INNER JOIN	OpeSch.OpeVtaRelFabricacionProyectoVw cr WITH(NOLOCK)
                    ON cr.IdFabricacion = br.IdFabricacion
        INNER JOIN	OpeSch.OpeVtaCatProyectoVw dr WITH(NOLOCK)
                    ON dr.ClaProyecto = cr.ClaProyecto
        INNER JOIN	OpeSch.OpeVtaCatClienteVw er WITH(NOLOCK)
                    ON er.ClaCliente = dr.ClaClienteCuenta
        INNER JOIN	OpeSch.OpeTraFabricacionDetVw bdr WITH(NOLOCK)
                    ON bdr.IdFabricacion = br.IdFabricacion 
        INNER JOIN  Opesch.OpeArtCatArticuloVw art WITH(NOLOCK)
                    ON art.ClaArticulo = bdr.ClaArticulo
        --Flujo de Estimaciones / Traspaso
        INNER JOIN	OpeSch.OpeTraFabricacionVw be WITH(NOLOCK)
                    ON be.IdFabricacion = a.idFabricacionEstimacion
        INNER JOIN	OpeSch.OpeTraFabricacionDetVw bde WITH(NOLOCK)
                    ON bde.IdFabricacion = be.IdFabricacion AND bde.ClaArticulo = bdr.ClaArticulo
        --Tabla Tipo de Proyecto
        INNER JOIN	OpeSch.OpeRelProyectoEstimacionVw vw1 WITH(NOLOCK)
                    ON vw1.ClaCliente = er.ClaCliente AND vw1.ClaProyecto = dr.ClaProyecto
        --Flujo de Unificacion
        LEFT JOIN	OpeSch.OpeTraFabricacionVw ur WITH(NOLOCK)
                    ON ur.IdFabricacion = a.IdFabriacionUnificado
        LEFT JOIN	OpeSch.OpeTraFabricacionDetVw udr WITH(NOLOCK)
                    ON udr.IdFabricacion = ur.IdFabricacion AND udr.ClaArticulo = bdr.ClaArticulo
    WHERE   br.IdFabricacion = @pnFabricacionVenta
    GROUP BY
            er.ClaCliente,
            ltrim(rtrim(convert(varchar(150), er.ClaCliente))) + ' - ' + er.NombreCliente,
            dr.ClaProyecto,		
            ltrim(rtrim(convert(varchar(150), dr.ClaProyecto))) + ' - ' + dr.NomProyecto,
            a.ClaUbicacionVenta,
            a.ClaUbicacionEstimacion,
            ur.IdFabricacion,
            br.IdFabricacion,
            be.IdFabricacion),

            PedidoAgrupadoDetalle AS
    (SELECT	a.ClaCliente,
            a.Cliente,
            a.ClaProyecto,
            a.Proyecto,
            a.Planta_VO,
            a.Pedido_Unificado,
            udr.IdFabricacionDet AS No_Renglon_PU,	
            a.Pedido_Venta_Original,
            a.Cantidad_Pedida_Venta_Enc,
            a.Cantidad_Surtida_Venta_Enc,
            bdr.IdFabricacionDet AS No_Renglon_PVO,
            SUM(bdr.CantPedida) AS Cantidad_Pedida_Venta_Det,
            SUM(bdr.CantSurtida) AS Cantidad_Surtida_Venta_Det,
            a.Planta_E,
            a.Pedido_Espejo,
            a.Cantidad_Pedida_Espejo_Enc,
            a.Cantidad_Surtida_Espejo_Enc,
            bdr.IdFabricacionDet AS No_Renglon_PE,
            SUM(bde.CantPedida) AS Cantidad_Pedida_Espejo_Det,
            SUM(bde.CantSurtida) AS Cantidad_Surtida_Espejo_Det,
            art.ClaArticulo AS Articulo,
            ltrim(rtrim(convert(varchar(150), art.ClaArticulo))) + ' - ' + art.NomArticulo AS Producto,
            bdr.PrecioLista AS Precio_Lista,
            art.PesoTeoricoKgs AS Peso_Teorico_Kgs
    FROM	PedidoAgrupadoEncabezado a 
        --Flujo de Remision / Venta
        INNER JOIN	OpeSch.OpeTraFabricacionDetVw bdr WITH(NOLOCK)
                    ON bdr.IdFabricacion = a.Pedido_Venta_Original
        INNER JOIN  Opesch.OpeArtCatArticuloVw art WITH(NOLOCK)
                    ON art.ClaArticulo = bdr.ClaArticulo
        --Flujo de Estimaciones / Traspaso
        INNER JOIN	OpeSch.OpeTraFabricacionDetVw bde WITH(NOLOCK)
                    ON bde.IdFabricacion = a.Pedido_Espejo AND bde.ClaArticulo = bdr.ClaArticulo
        --Flujo de Unificacion
        LEFT JOIN	OpeSch.OpeTraFabricacionDetVw udr WITH(NOLOCK)
                    ON udr.IdFabricacion = a.Pedido_Unificado AND udr.ClaArticulo = bdr.ClaArticulo
    GROUP BY
            a.ClaCliente,
            a.Cliente,
            a.ClaProyecto,
            a.Proyecto,
            a.Planta_VO,
            a.Pedido_Unificado,
            udr.IdFabricacionDet,	
            a.Pedido_Venta_Original,
            a.Cantidad_Pedida_Venta_Enc,
            a.Cantidad_Surtida_Venta_Enc,
            bdr.IdFabricacionDet,
            a.Planta_E,
            a.Pedido_Espejo,
            a.Cantidad_Pedida_Espejo_Enc,
            a.Cantidad_Surtida_Espejo_Enc,
            bdr.IdFabricacionDet,
            art.ClaArticulo,
			art.NomArticulo,
            bdr.PrecioLista,
            art.PesoTeoricoKgs) 

    SELECT	a.ClaCliente,
            a.Cliente,
            a.ClaProyecto,
            a.Proyecto,
            a.Planta_E,
            a.Pedido_Unificado,
            a.No_Renglon_PU,
            a.Pedido_Venta_Original,
            a.No_Renglon_PVO,            
            a.Cantidad_Pedida_Venta_Enc,
            a.Cantidad_Surtida_Venta_Enc,
            a.Cantidad_Pedida_Venta_Det,
            a.Cantidad_Surtida_Venta_Det,
            a.Pedido_Espejo,
            a.No_Renglon_PE,            
            a.Articulo,
            a.Producto,
            a.Precio_Lista,
            a.Peso_Teorico_Kgs,
            a.Cantidad_Pedida_Espejo_Enc,
            a.Cantidad_Surtida_Espejo_Enc,
            a.Cantidad_Pedida_Espejo_Det,
            a.Cantidad_Surtida_Espejo_Det,            
            gr.IdBoleta AS Boleta_VO,
            hr.IdPlanCarga AS Plan_Carga_VO,
            ir.IdViaje AS Viaje_VO,
            fr.IdFacturaAlfanumerico AS Remision,
            fr.FechaEntSal AS FechaRemision,
            ge.IdBoleta AS Boleta_PE,
            he.IdPlanCarga AS Plan_Carga_PE,
            ie.IdViaje AS Viaje_PE,
            ie.FechaViaje AS Fecha_Viaje_PE,
            DATEDIFF(DAY, ie.FechaViaje, GETDATE()) AS Dias_Viaje_PE,
            fe.IdEntSal AS Mov_Embarque,
            --Detalle Embarque
            fd.CantEmbarcada AS Cantidad_Embarcada_VO,		
            fd.PesoEmbarcado AS Kilos_Embarcada_VO,
            --Detalle Recepcion Mercancia
            z.CantRecibida AS Cantidad_Recibida_PE,
            z.PesoRecibido AS Kilos_Recibidos_PE,
            --Detalle POD Estimaciones
            CASE u.EsEntregado WHEN 0 THEN 'No Entregado' WHEN 1 THEN 'Entregado' ELSE 'No Entregado' END AS Estatus_Evidencia,
            CASE WHEN ev.IdViajeOrigen IS NOT NULL THEN 'Ver Factura' ELSE '' END AS Evidencia_POD,
            ISNULL(u.EsRecibido, 0) AS Estatus_Autorizacion,
            CASE u.EsRecibido WHEN 0 THEN NULL WHEN 1 THEN cu.NombreUsuario + ' ' + cu.ApellidoPaterno ELSE NULL END AS Autorizado_Por,
            CASE u.EsRecibido WHEN 0 THEN NULL WHEN 1 THEN u.ComentarioRecepcion  ELSE NULL END AS Comentarios_Autorizacion,
            --Detalle Disponibilidad Factura
            CASE WHEN ISNULL(u.EsRecibido,0) = 1 THEN fd.CantEmbarcada ELSE 0.00 END AS Cant_Disponible_Facturar,
            CASE WHEN ISNULL(u.EsRecibido,0) = 1 THEN fd.PesoEmbarcado ELSE 0.00 END AS Kilos_Disponible_Facturar,
            CASE WHEN ISNULL(u.EsRecibido,0) = 0 THEN fd.CantEmbarcada ELSE 0.00 END AS Cant_Pendiente_Aurotizacion,	
            CASE WHEN ISNULL(u.EsRecibido,0) = 0 THEN fd.PesoEmbarcado ELSE 0.00 END AS Kilos_Pendiente_Aurotizacion
    INTO	#TempVistaEstimacionesDetalleRemision
    FROM	PedidoAgrupadoDetalle a 
        --Flujo de Remision / Venta
        INNER JOIN	OpeSch.OpeTraMovEntSal fr WITH(NOLOCK)
                    ON fr.ClaUbicacion = a.Planta_VO AND fr.IdFabricacion = a.Pedido_Venta_Original
        INNER JOIN	OpeSch.OpeTraBoleta gr WITH(NOLOCK)
                    ON gr.ClaUbicacion = fr.ClaUbicacion AND gr.IdBoleta = fr.IdBoleta
        INNER JOIN	OpeSch.OpeTraPlanCarga hr WITH(NOLOCK)
                    ON hr.ClaUbicacion = gr.ClaUbicacion AND hr.IdBoleta = gr.IdBoleta
        INNER JOIN	OpeSch.OpeTraViaje ir WITH(NOLOCK)
                    ON ir.ClaUbicacion = hr.ClaUbicacion AND ir.IdBoleta = hr.IdBoleta
        --Flujo de Estimaciones / Traspaso
        INNER JOIN	OpeSch.OpeTraMovEntSal fe WITH(NOLOCK)
                    ON fe.ClaUbicacion = a.Planta_E AND fe.IdFabricacion = a.Pedido_Espejo
        INNER JOIN	OpeSch.OpeTraBoletaHis ge WITH(NOLOCK)
                    ON ge.ClaUbicacion = fe.ClaUbicacion AND ge.IdBoleta = fe.IdBoleta
        INNER JOIN	OpeSch.OpeTraPlanCarga he WITH(NOLOCK)
                    ON he.ClaUbicacion = ge.ClaUbicacion AND he.IdBoleta = ge.IdBoleta
        INNER JOIN	OpeSch.OpeTraViaje ie WITH(NOLOCK)
                    ON ie.ClaUbicacion = he.ClaUbicacion AND ie.IdBoleta = he.IdBoleta
        --Tabla Relación de Estimacion - Remision
        INNER JOIN	OpeSch.OpeTraPlanCargaRemisionEstimacion o WITH(NOLOCK)  
                    ON o.ClaUbicacionEstimacion = fe.ClaUbicacion AND o.ClaUbicacionVenta = fr.ClaUbicacion AND o.IdBoletaEstimacion = ge.IdBoleta AND o.IdBoletaVenta = gr.IdBoleta
        --Base Remisionado 
        INNER JOIN	OpeSch.OpeTraMovEntSalDet fd WITH(NOLOCK)
                    ON fd.ClaUbicacion = fr.ClaUbicacion AND fd.IdMovEntSal = fr.IdMovEntSal AND fd.IdFabricacion = a.Pedido_Venta_Original AND fd.IdFabricacionDet = a.No_Renglon_PVO
        --Base POD
        LEFT JOIN	OpeSch.OpeTraInfoViajeEstimacion u WITH(NOLOCK)
                    ON u.ClaUbicacionOrigen = ie.ClaUbicacion AND u.IdViajeOrigen = ie.IdViaje AND u.Remision = fr.IdFacturaAlfanumerico
        LEFT JOIN	OpeSch.OpeTraInfoViajeEstimacionDet v WITH(NOLOCK)
                    ON v.ClaUbicacionOrigen = u.ClaUbicacionOrigen AND v.IdViajeOrigen = u.IdViajeOrigen AND v.IdFabricacion = a.Pedido_Espejo AND v.IdFabricacionDet = a.No_Renglon_PE
        LEFT JOIN   OpeSch.OpeTraEvidenciaViajeEstimacion ev WITH(NOLOCK)
                    ON ev.ClaUbicacion = u.ClaUbicacion AND ev.ClaUbicacionOrigen = u.ClaUbicacionOrigen AND ev.IdViajeOrigen = u.IdViajeOrigen AND ev.Remision = u.Remision
        LEFT JOIN	OpeSch.TiCatUsuarioVw cu WITH(NOLOCK)
                    ON cu.ClaUsuario = u.ClaUsuarioMod            
        --Base Recepcion Traspaso
        LEFT JOIN	OpeSch.OpeTraRecepTraspaso w WITH(NOLOCK)
                    ON w.ClaUbicacionOrigen = ie.ClaUbicacion AND w.IdViajeOrigen = ie.IdViaje --AND w.IdBoleta = ie.IdBoleta
        LEFT JOIN	Opesch.OpeTraRecepTraspasoFab x WITH(NOLOCK)
                    ON x.ClaUbicacionOrigen = w.ClaUbicacionOrigen AND x.IdViajeOrigen = w.IdViajeOrigen AND x.IdFabricacion = a.Pedido_Espejo AND x.IdEntSalOrigen = fe.IdEntSal
        LEFT JOIN	Opesch.OpeTraRecepTraspasoProd y WITH(NOLOCK)
                    ON y.ClaUbicacionOrigen = x.ClaUbicacionOrigen AND y.IdViajeOrigen = x.IdViajeOrigen AND y.IdFabricacion = x.IdFabricacion AND y.IdFabricacionDet = v.IdFabricacionDet
        LEFT JOIN	Opesch.OpeTraRecepTraspasoProdRecibido z WITH(NOLOCK)   
                    ON z.ClaUbicacionOrigen = y.ClaUbicacionOrigen AND z.IdViajeOrigen = y.IdViajeOrigen AND z.IdFabricacion = y.IdFabricacion AND z.IdFabricacionDet = y.IdFabricacionDet 
    WHERE   ir.IdViaje = @pnViajeVenta
    AND     fr.IdFacturaAlfanumerico = @psRemision
    ------Fin: Proceso PreEjecucion de Consulta------

    ------Inicio: Proceso de Consulta Encabezado------
    ;WITH	ControlRemisionFactura AS
    (SELECT	a.ClaCliente,
            a.ClaProyecto,
            a.Pedido_Unificado,
            a.Pedido_Venta_Original,
            a.Pedido_Espejo,
            a.No_Renglon_PE,
            a.Articulo,
            a.Viaje_PE,
            a.Remision,
            a.Mov_Embarque,
            ISNULL(SUM(cfd.CantSurtidaFact),0) AS Cant_Facturada
    FROM	#TempVistaEstimacionesDetalleRemision a
        LEFT JOIN OpeSch.OpeControlFacturaRemisionEstimacionVw cf WITH(NOLOCK)
            ON cf.ClaCliente = a.ClaCliente AND cf.ClaProyecto = a.ClaProyecto AND cf.IdViaje = a.Viaje_VO AND cf.RemisionAlfanumerico = a.Remision
        LEFT JOIN OpeSch.OpeControlFacturaRemisionEstimacionDetVw cfd WITH(NOLOCK)
            ON cfd.IdContFacturaRemision = cf.IdContFacturaRemision AND cfd.ClaArticulo = a.Articulo
    GROUP BY 
            a.ClaCliente,
            a.ClaProyecto,
            a.Pedido_Unificado,
            a.Pedido_Venta_Original,
            a.Pedido_Espejo,
            a.No_Renglon_PE,
            a.Articulo,
            a.Viaje_PE,
            a.Remision,
            a.Mov_Embarque)

    SELECT	a.No_Renglon_PVO AS ColFabricacionDet,
            a.Producto AS ColProductoDet,
            a.Kilos_Embarcada_VO AS ColKilosRemisionadosDet,
            a.Kilos_Recibidos_PE AS ColKilosRecibidosDet,
            ISNULL(SUM(b.Cant_Facturada),0) * a.Peso_Teorico_Kgs AS ColKilosFacturadosDet,
            ROUND(ISNULL(( a.Precio_Lista * a.Cantidad_Embarcada_VO ), 0.00), 2) AS ColImporteTotalDet,
            a.Viaje_VO AS ColViajeDet,
            a.Remision AS ColRemisionDet,
            a.Pedido_Venta_Original AS ColFabricacion,
            a.Articulo AS ColClaArticuloDet
			,a.Precio_Lista AS ColPrecioLista
    FROM	#TempVistaEstimacionesDetalleRemision a
        LEFT JOIN ControlRemisionFactura b WITH(NOLOCK)
            ON b.ClaCliente = a.ClaCliente AND b.ClaProyecto = a.ClaProyecto AND b.Viaje_PE = a.Viaje_PE AND b.Remision = a.Remision AND b.Articulo = a.Articulo
    GROUP BY 
            a.ClaCliente,
            a.ClaProyecto,
            a.Pedido_Unificado,
            a.Pedido_Venta_Original,
            a.Pedido_Espejo,
            a.No_Renglon_PE,
            a.No_Renglon_PVO,
            a.Articulo,
            a.Producto,
            a.Peso_Teorico_Kgs,
            a.Precio_Lista,
            a.Viaje_VO,
            a.Viaje_PE,
            a.Remision,
            a.Cantidad_Embarcada_VO,
            a.Kilos_Embarcada_VO,
            a.Kilos_Recibidos_PE
    ORDER BY
			a.Viaje_PE, a.Pedido_Venta_Original, a.Articulo
    ------Fin: Proceso de Consulta Encabezado------

    DROP TABLE #TempVistaEstimacionesDetalleRemision
END