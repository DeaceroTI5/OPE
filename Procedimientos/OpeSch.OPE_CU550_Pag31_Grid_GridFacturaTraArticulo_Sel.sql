GO
-- 'OpeSch.OPE_CU550_Pag31_Grid_GridFacturaTraArticulo_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag31_Grid_GridFacturaTraArticulo_Sel 
    @pnClaUbicacion             INT, 
    @pnClaUsuarioMod            INT,
    @psNombrePcMod              VARCHAR(64),
    @pnActividad                INT,
    @pnEstimacionFactura        INT,
    @pnFabricacionVenta         INT,
    @pnFabricacionVentaDet      INT,
    @pnFabricacionDetVentaDet   INT,
    @pnArticuloDet              INT
AS
BEGIN      
	IF ( @pnActividad = 1 )
    BEGIN
        SELECT
                vwtrd.IdViaje AS ColViajeTra,
                vwtrd.RemisionAlfanumerico AS ColRemisionTra,
                art.ClaArticulo AS ColClaArticuloTra,
                SUM(vwtrd.CantSurtida) AS ColCantSurtidaTra,
                ROUND(SUM(ISNULL(( bdr.PrecioLista * vwtrd.CantSurtida ), 0.00)), 2) AS ColImporteTra,
                --ROUND(ISNULL(( bdr.PrecioLista * vwtrd.CantSurtida ), 0.00), 2) AS ColImporteTra,
                cu.NombreUsuario + ' ' + cu.ApellidoPaterno AS ColRealizadoPorTra,
                vwtrd.FechaUltimaMod AS ColFechaTra
        FROM		(SELECT DISTINCT --ClaUbicacionEstimacion, idFabricacionEstimacion, ClaUbicacionVenta, idFabricacionVenta
								idFabricacionVenta
					FROM	OpeSch.OpeTraFabricacionEspejoEstimacion WITH(NOLOCK)) a 
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
            --Tabla Tipo de Proyecto
            INNER JOIN	OpeSch.OpeRelProyectoEstimacionVw vw1 WITH(NOLOCK)
                        ON vw1.ClaCliente = er.ClaCliente AND vw1.ClaProyecto = dr.ClaProyecto           
            --Base Control de Facturación
            INNER JOIN	OpeSch.OpeTraFacturaEstimacionVw vwt WITH(NOLOCK)
                        ON vwt.IdFabricacion = br.IdFabricacion AND vwt.ClaCliente = er.ClaCliente AND vwt.ClaProyecto = dr.ClaProyecto
            INNER JOIN	OpeSch.OpeTraFacturaEstimacionDetVw vwtd WITH(NOLOCK)
                        ON vwtd.IdEstimacionFactura = vwt.IdEstimacionFactura AND vwtd.IdFabricacion = vwt.IdFabricacion AND vwtd.IdFabricacionDet = bdr.IdFabricacionDet AND vwtd.ClaArticulo = art.ClaArticulo
            INNER JOIN	OpeSch.OpeTraRelFacturaRemisionEstimacionDetVw vwtrd WITH(NOLOCK)
                        ON vwtrd.IdEstimacionFactura = vwtd.IdEstimacionFactura AND vwtrd.IdFabricacion = vwtd.IdFabricacion AND vwtrd.IdFabricacionDet = vwtd.IdFabricacionDet AND vwtrd.ClaArticulo = vwtd.ClaArticulo
            LEFT JOIN	OpeSch.TiCatUsuarioVw cu WITH(NOLOCK)
                        ON cu.ClaUsuario = vwtrd.ClaUsuarioMod     
            --Base Proforma / Factura       
            INNER JOIN	DEAOFINET05.Ventas.VtaSch.VtaTraProforma vtaTP WITH(NOLOCK)
                        ON vtaTP.IdProforma = vwt.IdProforma  
            INNER JOIN	DEAOFINET05.Ventas.VtaSch.VtaTraProformaDet vtaTPD WITH(NOLOCK)
                        ON vtaTPD.IdProforma = vtaTP.IdProforma AND vtaTPD.IdRenglon = vwtd.IdFabricacionDet AND vtaTPD.ClaArticulo = vwtd.ClaArticulo
        WHERE	br.ClaPlanta = 365
        AND     vw1.EsEstimacion = 1
        AND		vwtrd.IdEstimacionFactura = @pnEstimacionFactura
        AND		vwtrd.IdFabricacion = @pnFabricacionVenta 
        GROUP BY                vwtrd.IdViaje ,
                vwtrd.RemisionAlfanumerico ,
                art.ClaArticulo ,
                vwtrd.CantSurtida ,
                ROUND(ISNULL(( bdr.PrecioLista * vwtrd.CantSurtida ), 0.00), 2) ,
                cu.NombreUsuario + ' ' + cu.ApellidoPaterno,
                vwtrd.FechaUltimaMod
		ORDER BY
                vwtrd.IdViaje, vwtrd.RemisionAlfanumerico, art.ClaArticulo
    END

    ELSE
    BEGIN
        SELECT
                vwtrd.IdViaje AS ColViajeTra,
                vwtrd.RemisionAlfanumerico AS ColRemisionTra,
                art.ClaArticulo AS ColClaArticuloTra,
                SUM(vwtrd.CantSurtida) AS ColCantSurtidaTra,
                ROUND(SUM(ISNULL(( bdr.PrecioLista * vwtrd.CantSurtida ), 0.00)), 2) AS ColImporteTra,
                cu.NombreUsuario + ' ' + cu.ApellidoPaterno AS ColRealizadoPorTra,
                vwtrd.FechaUltimaMod AS ColFechaTra
        FROM	(	SELECT DISTINCT --ClaUbicacionEstimacion, idFabricacionEstimacion, ClaUbicacionVenta, idFabricacionVenta
								idFabricacionVenta
					FROM	OpeSch.OpeTraFabricacionEspejoEstimacion WITH(NOLOCK)) a 
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
            --Tabla Tipo de Proyecto
            INNER JOIN	OpeSch.OpeRelProyectoEstimacionVw vw1 WITH(NOLOCK)
                        ON vw1.ClaCliente = er.ClaCliente AND vw1.ClaProyecto = dr.ClaProyecto           
            --Base Control de Facturación
            INNER JOIN	OpeSch.OpeTraFacturaEstimacionVw vwt WITH(NOLOCK)
                        ON vwt.IdFabricacion = br.IdFabricacion AND vwt.ClaCliente = er.ClaCliente AND vwt.ClaProyecto = dr.ClaProyecto
            INNER JOIN	OpeSch.OpeTraFacturaEstimacionDetVw vwtd WITH(NOLOCK)
                        ON vwtd.IdEstimacionFactura = vwt.IdEstimacionFactura AND vwtd.IdFabricacion = vwt.IdFabricacion AND vwtd.IdFabricacionDet = bdr.IdFabricacionDet AND vwtd.ClaArticulo = art.ClaArticulo
            INNER JOIN	OpeSch.OpeTraRelFacturaRemisionEstimacionDetVw vwtrd WITH(NOLOCK)
                        ON vwtrd.IdEstimacionFactura = vwtd.IdEstimacionFactura AND vwtrd.IdFabricacion = vwtd.IdFabricacion AND vwtrd.IdFabricacionDet = vwtd.IdFabricacionDet AND vwtrd.ClaArticulo = vwtd.ClaArticulo
            LEFT JOIN	OpeSch.TiCatUsuarioVw cu WITH(NOLOCK)
                        ON cu.ClaUsuario = vwtrd.ClaUsuarioMod     
            --Base Proforma / Factura       
            INNER JOIN	DEAOFINET05.Ventas.VtaSch.VtaTraProforma vtaTP WITH(NOLOCK)
                        ON vtaTP.IdProforma = vwt.IdProforma  
            INNER JOIN	DEAOFINET05.Ventas.VtaSch.VtaTraProformaDet vtaTPD WITH(NOLOCK)
                        ON vtaTPD.IdProforma = vtaTP.IdProforma AND vtaTPD.IdRenglon = vwtd.IdFabricacionDet AND vtaTPD.ClaArticulo = vwtd.ClaArticulo
        WHERE	br.ClaPlanta = 365
        AND     vw1.EsEstimacion = 1
        AND		vwtrd.IdEstimacionFactura = @pnEstimacionFactura
        AND		vwtrd.IdFabricacion = @pnFabricacionVentaDet 
        AND		vwtrd.IdFabricacionDet = @pnFabricacionDetVentaDet
        AND		vwtrd.ClaArticulo = @pnArticuloDet
        GROUP BY                 vwtrd.IdViaje ,
                vwtrd.RemisionAlfanumerico ,
                art.ClaArticulo ,
                vwtrd.CantSurtida ,
                ROUND(ISNULL(( bdr.PrecioLista * vwtrd.CantSurtida ), 0.00), 2) ,
                cu.NombreUsuario + ' ' + cu.ApellidoPaterno ,
                vwtrd.FechaUltimaMod
		ORDER BY
                vwtrd.IdViaje, vwtrd.RemisionAlfanumerico, art.ClaArticulo
    END
END