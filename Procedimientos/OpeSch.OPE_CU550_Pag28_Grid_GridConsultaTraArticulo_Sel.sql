USE Operacion
GO
-- EXEC SP_HELPTEXT 'OpeSch.OPE_CU550_Pag28_Grid_GridConsultaTraArticulo_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag28_Grid_GridConsultaTraArticulo_Sel
    @pnClaUbicacion         INT,       
    @pnIdFabVentaDet        INT,
    @pnIdFabDetVentaDet     INT,
    @pnArticuloDet          INT,
    @pnViajeDet             INT,
    @psRemisionDet          VARCHAR(20)
AS
BEGIN    	
	
    ;WITH   EstimacionesGeneradas AS
	(SELECT	T2.IdFabricacion							AS FabricacionFactura,
			T2.FechaFactura								AS FechaFactura,
			T2.IdProforma								AS Factura,
			T1.IdFabricacionDet							AS RenglonFactura,
			T1.ClaArticulo								AS ArticuloFactura,
			T0.CantSurtida								AS CantidadFactura,
			T1.PrecioLista								AS PrecioFactura,
			T0.IdViaje									AS ViajeFactura,
			T0.RemisionAlfanumerico						AS RemisionFactura,
			T3.NombreUsuario + ' ' + T3.ApellidoPaterno	AS UsuarioFactura
	FROM	OpeSch.OpeTraRelFacturaRemisionEstimacionDetVw T0 WITH(NOLOCK)
    LEFT JOIN	OpeSch.OpeTraFacturaEstimacionDetVw T1 WITH(NOLOCK)
        ON T0.IdEstimacionFactura = T1.IdEstimacionFactura AND T0.IdFabricacion = T1.IdFabricacion AND T0.IdFabricacionDet = T1.IdFabricacionDet AND T0.ClaArticulo = T1.ClaArticulo
    LEFT JOIN	OpeSch.OpeTraFacturaEstimacionVw T2 WITH(NOLOCK)
        ON T1.IdEstimacionFactura = T2.IdEstimacionFactura AND T0.IdFabricacion = T2.IdFabricacion
    LEFT JOIN	OpeSch.TiCatUsuarioVw T3 WITH(NOLOCK)
        ON	T0.ClaUsuarioMod = T3.ClaUsuario
	WHERE	T0.IdViaje = @pnViajeDet
	AND		T0.RemisionAlfanumerico = @psRemisionDet
	AND		T0.ClaArticulo = @pnArticuloDet)

    SELECT	--ColFacturaTra
			T1.Factura AS ColFacturaTra,
			T4.IdFacturaAlfanumerico AS ColProforma,
			--ColKilosFacturadosTra
			ISNULL( (T1.CantidadFactura * T2.PesoTeoricoKgs) , 0.00) AS ColKilosFacturadosTra,
			--ColImporteTra
			ROUND(ISNULL(( T1.CantidadFactura * ISNULL( T1.PrecioFactura, T2.PrecioListaVenta ) ), 0.00), 2) AS ColImporteTra,
			--ColPrecioLista
			ISNULL( T1.PrecioFactura, T2.PrecioListaVenta ) AS ColPrecioLista,
			--ColRealizadoPor
			T1.UsuarioFactura AS ColRealizadoPor,
			--ColFechaTra
			T1.FechaFactura AS ColFechaTra,
			--ColFabricacionTra
			T1.FabricacionFactura AS ColFabricacionTra,
			--ColClaArticuloTra
			T1.ArticuloFactura AS ColClaArticuloTra
    FROM	EstimacionesGeneradas T1
		--Información de Embarques
	INNER JOIN	OpeSch.OpeRelEmbarqueEstimacionVw T2 WITH(NOLOCK)
		ON	T1.ViajeFactura = T2.IdViajeVenta AND T1.RemisionFactura = T2.FacturaAlfanumericoVenta AND T1.ArticuloFactura = T2.ClaArticulo
	LEFT JOIN OpeSch.OpeVtaTraProformaVw T3 
	ON		T1.Factura	= T3.IdProforma
	LEFT JOIN OpeSch.OpeVtaCTraFacturaVw T4
	ON		T3.IdFacturaNueva = T4.IdFactura    
	WHERE	T2.PlantaVirtualAgrupador IN (365)	
    ORDER BY T1.FechaFactura DESC, T1.Factura

END