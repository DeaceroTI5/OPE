GO
-- 'OpeSch.OPE_CU550_Pag31_Grid_GridFacturaDetArticulo_Sel'
GO
ALTER PROCEDURE [OpeSch].[OPE_CU550_Pag31_Grid_GridFacturaDetArticulo_Sel] 
    @pnClaUbicacion         INT, 
    @pnClaUsuarioMod        INT,
    @psNombrePcMod          VARCHAR(64),
    @pnActividad            INT,
    
    @pnFabricacionVenta     INT,
    @pnEstimacionFactura    INT,
    @pnFolioProforma        INT,
    @pnFolioFactura         INT
AS
BEGIN    
	SET NOCOUNT ON

    SELECT
            vtaTPD.IdRenglon AS ColNoRenglonDet,
            LTRIM(RTRIM(CONVERT(VARCHAR(150), art.ClaArticulo))) + ' - ' + art.NomArticulo AS ColArticuloDet,
            vwtd.NomProductoFacturar AS ColNomProductoDet,
            SUM(vtaTPD.CantidadSurtida) AS ColCantSurtidaDet,
            SUM(vtaTPD.KilosSurtidos) AS ColKilosSurtidosDet,
            SUM(vtaTPD.ImporteSubtotal) AS ColImporteDet,
            vwtd.ComentariosFacturaDet AS ColComentariosDet,
            br.IdFabricacion AS ColFabricacionDet,
            bdr.IdFabricacionDet AS ColFabDetalleDet,
            art.ClaArticulo AS ColClaArticuloDet
    FROM	(SELECT --DISTINCT ClaUbicacionEstimacion, idFabricacionEstimacion, ClaUbicacionVenta, idFabricacionVenta
                    idFabricacionVenta
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
    AND		vwtd.IdEstimacionFactura = @pnEstimacionFactura
    AND		vwtd.IdFabricacion = @pnFabricacionVenta 
    AND		vwt.IdProforma = @pnFolioProforma
    --AND		vtaTP.IdFacturaNueva = @pnFolioFactura
	GROUP BY vtaTPD.IdRenglon ,
            LTRIM(RTRIM(CONVERT(VARCHAR(150), art.ClaArticulo))) + ' - ' + art.NomArticulo ,
            vwtd.NomProductoFacturar ,
            vwtd.ComentariosFacturaDet ,
            br.IdFabricacion ,
            bdr.IdFabricacionDet ,
            art.ClaArticulo 

    ORDER BY
            br.IdFabricacion, bdr.IdFabricacionDet, art.ClaArticulo

	SET NOCOUNT OFF
END