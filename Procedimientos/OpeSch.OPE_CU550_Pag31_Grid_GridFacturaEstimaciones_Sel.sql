GO
-- 'OpeSch.OPE_CU550_Pag31_Grid_GridFacturaEstimaciones_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag31_Grid_GridFacturaEstimaciones_Sel 
    @pnClaUbicacion         INT, 
    @pnClaUsuarioMod        INT,
    @psNombrePcMod          VARCHAR(64),

    @pdFechaInicio          DATETIME, 
    @pdFechaFin             DATETIME,     
    @pnCmbCliente           INT, 
    @pnCmbProyecto          INT, 
    @pnCmbFactura           INT
AS
BEGIN      
	DECLARE	@CmbCliente     INT, 
            @CmbProyecto    INT,
			@CmbFactura     INT
	
	SELECT	@CmbCliente     = (CASE WHEN (@pnCmbCliente = -1 OR @pnCmbCliente IS NULL) THEN 1 ELSE 0 END),
			@CmbProyecto    = (CASE WHEN (@pnCmbProyecto = -1 OR @pnCmbProyecto IS NULL) THEN 1 ELSE 0 END),
            @CmbFactura     = (CASE WHEN (@pnCmbFactura = -1 OR @pnCmbFactura IS NULL) THEN 1 ELSE 0 END)

    SELECT
            CASE    WHEN vtaTP.IdFacturaNueva IS NULL
                    THEN NULL
                    ELSE 'QH' + CONVERT(VARCHAR(15), ( vtaTP.IdFacturaNueva - ( 1000000 * 1028 ) )) 
            END AS ColFacturaNueva,
            LTRIM(RTRIM(CONVERT(VARCHAR(150), er.ClaCliente))) + ' - ' + er.NomCliente AS ColNomCliente,
            LTRIM(RTRIM(CONVERT(VARCHAR(150), dr.ClaProyecto))) + ' - ' + dr.NomProyecto AS ColNomProyecto,
            br.IdFabricacion AS ColFabricacionVenta,
            SUM( vtaTPD.KilosSurtidos ) AS ColKilosSurtidos,
            SUM( vtaTPD.ImporteSubtotal ) AS ColImporteSubtotal,
            SUM( vtaTPD.IVA ) AS ColIVA,
            SUM( vtaTPD.Total ) AS ColImporteTotal,
            CONVERT(VARCHAR, vwt.Estatus) + ' ' + CASE vwt.Estatus WHEN 0 THEN 'Nuevo' WHEN 1 THEN 'Alta' WHEN 3 THEN 'Facturado' WHEN 5 THEN 'Cancelado' END AS ColEstatus, --0 Nuevo, 1 Alta, 3 Facturado, 5 Cancelado
            vwt.ObservacionEstimacion AS ColObservaciones,
            vwt.ComentariosFactura AS ColComentarios,
            vtaTP.FechaUltimaMod AS ColFechaFactura,
            er.ClaCliente AS ColClaCliente,
            dr.ClaProyecto AS ColClaProyecto,
            vwt.IdEstimacionFactura AS ColEstimacionFactura,
            vtaTP.IdProforma AS ColFolioProforma,
            vtaTP.IdFacturaNueva AS ColFolioFactura
    FROM	(SELECT DISTINCT ClaUbicacionEstimacion, idFabricacionEstimacion, ClaUbicacionVenta, idFabricacionVenta
                    FROM OpeSch.OpeTraFabricacionEspejoEstimacion WITH(NOLOCK)) a 
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
        --Base Proforma / Factura       
        INNER JOIN	DEAOFINET05.Ventas.VtaSch.VtaTraProforma vtaTP WITH(NOLOCK)
                    ON vtaTP.IdProforma = vwt.IdProforma  
        INNER JOIN	DEAOFINET05.Ventas.VtaSch.VtaTraProformaDet vtaTPD WITH(NOLOCK)
                    ON vtaTPD.IdProforma = vtaTP.IdProforma AND vtaTPD.IdRenglon = vwtd.IdFabricacionDet AND vtaTPD.ClaArticulo = vwtd.ClaArticulo
    WHERE	br.ClaPlanta = 365
    AND     vw1.EsEstimacion = 1
    AND		( er.ClaCliente = @pnCmbCliente OR @CmbCliente = 1 )  
    AND		( dr.ClaProyecto = @pnCmbProyecto OR @CmbProyecto = 1 ) 
    AND		( vtaTP.IdFacturaNueva = @pnCmbFactura OR @CmbFactura = 1 ) 
    AND		( (vtaTP.FechaUltimaMod >= DATEADD(DAY,0,@pdFechaInicio)) AND (vtaTP.FechaUltimaMod <= DATEADD(DAY,1,@pdFechaFin)) )
    GROUP BY
            CASE    WHEN vtaTP.IdFacturaNueva IS NULL
                    THEN NULL
                    ELSE 'QH' + CONVERT(VARCHAR(15), ( vtaTP.IdFacturaNueva - ( 1000000 * 1028 ) )) 
            END, 
            er.ClaCliente, er.NomCliente, dr.ClaProyecto, dr.NomProyecto, br.IdFabricacion, vwt.Estatus, vwt.ObservacionEstimacion, vwt.ComentariosFactura,
            vtaTP.FechaUltimaMod, vwt.IdEstimacionFactura, vtaTP.IdProforma, vtaTP.IdFacturaNueva
    ORDER BY
            er.ClaCliente, dr.ClaProyecto
END