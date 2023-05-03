CREATE  PROCEDURE OpeSch.OPE_CU445_Pag18_Grid_Boletas_Sel
@pnClaUbicacion INT
,@pnClaMaquilador INT
,@pnIdRecepFacturaMaquilador INT = null
AS BEGIN
SET NOCOUNT ON
-- cmqConsultarBoletasFactSel
	--Nivel 1
	SELECT CASE  WHEN t.IdRecepFacturaMaquilador IS NULL THEN 0
					ELSE 1 END AS Incluir
			,t.idBoleta
			, isnull(bol.FechaHoraSalida, getdate()) AS FechaHoraSalida
			, convert(INT, NULL) AS IdContrato
			, convert(INT, NULL) AS IdOrdenMaquila
			, '' AS NomProcesoMaquila
			, '' AS NomArticulo
			, sum(t.CantRecibida) AS CantRecibida
			, Case WHEN t.IdRecepFacturaMaquilador IS NULL THEN  NULL ELSE sum(t.PesoRecibido) END AS PesoRecibido
			, sum(t.PesoRecibido) AS PesoRecibidoPaso
			, '' AS NombreCortoMoneda
			, convert(NUMERIC(22,4),NULL) AS Precio
			, Case WHEN t.IdRecepFacturaMaquilador IS NULL THEN  NULL ELSE sum(t.TotalSinIVA) END AS TotalSinIVA
			, sum(t.TotalSinIVA) AS TotalSinIVAPaso
			, Case WHEN t.IdRecepFacturaMaquilador IS NULL THEN  NULL ELSE sum(t.IVA) END AS IVA
			, sum(t.IVA) AS IVAPaso
			, Case WHEN t.IdRecepFacturaMaquilador IS NULL THEN  NULL ELSE sum(t.TotalConIVA)END  AS TotalConIVA
			, sum(t.TotalConIVA) AS TotalConIVAPaso
			, t.IdRecepOrdenMaquila
	FROM 
		(SELECT rec.IdRecepOrdenMaquila 
			, rec.IdBoleta
			, contrato.IdContrato
			--, recdet.PesoRecibido
--			, CASE
--				WHEN r.IdRecepFacturaMaquilador IS NULL THEN convert(NUMERIC(22,4),0)
--					ELSE recdet.PesoRecibido END AS PesoRecibido
--			, CASE  
--				WHEN r.IdRecepFacturaMaquilador IS NULL THEN convert(NUMERIC(22,4),0) 
--					ELSE recdet.CantRecibida * cot.FactorConversion * cot.CostoXUnidadArticulo END AS TotalSinIVA
--			, CASE  
--				WHEN r.IdRecepFacturaMaquilador IS NULL THEN convert(NUMERIC(22,4),0) 
--					ELSE (recdet.CantRecibida * cot.FactorConversion * cot.CostoXUnidadArticulo) * (maq.PorcIVA / 100) END AS IVA
--			, CASE  
--				WHEN r.IdRecepFacturaMaquilador IS NULL THEN convert(NUMERIC(22,4),0) 
--					ELSE (recdet.CantRecibida * cot.FactorConversion * cot.CostoXUnidadArticulo) * (1 + (maq.PorcIVA / 100)) END AS TotalConIVA	

			,recdet.PesoRecibido AS PesoRecibido
			,ROUND(ROUND(recdet.CantRecibida * isnull(contrato.FactorConversion,1),2)  * contrato.PrecioNegociado,2) AS TotalSinIVA
			,ROUND(ROUND(ROUND(recdet.CantRecibida * isnull(contrato.FactorConversion,1),2)  * contrato.PrecioNegociado,2) * (ISNULL(maq.PorcIVA,0) / 100), 2) AS IVA
			,ROUND(ROUND(ROUND(recdet.CantRecibida * isnull(contrato.FactorConversion,1),2)  * contrato.PrecioNegociado,2) * (1 + (ISNULL(maq.PorcIVA,0) / 100)),2) AS TotalConIVA	
			, recdet.CantRecibida
		--	, contrato.FactorConversion
			, r.IdRecepFacturaMaquilador
			FROM OPESCH.OpeTraRecepOrdenMaquila rec				(nolock) 
			INNER JOIN OPeSch.OPETraRecepOrdenMaquilaDet recdet (nolock) ON rec.ClaUbicacion			= recdet.ClaUbicacion	
																		AND rec.IdRecepOrdenMaquila		= recdet.IdRecepOrdenMaquila 
			INNER JOIN opesch.OPeArtCatArticuloVw art			(nolock) ON recdet.ClaArticulo			= art.ClaArticulo 
	    																AND recdet.ClaTipoInventario	= art.ClaTipoInventario 
																		AND art.ClaFamilia != 117 
			INNER JOIN OPESCH.OpeTraContratoMaquila contrato	(nolock) ON recdet.ClaUbicacion			= contrato.ClaUbicacion 
																		AND recdet.IdContrato			= contrato.IdContrato 
			INNER JOIN OPESCH.OpeCatMaquilador maq				(nolock) ON contrato.ClaUbicacion		= maq.ClaUbicacion		
																		AND contrato.ClaMaquilador		= maq.ClaMaquilador 
			 --   JOIN select * from cmqsch.CmqTraCotizacion cot (nolock) ON contrato.IdCotizacion = cot.IdCotizacion INNER
		   	LEFT  JOIN OPESCH.OpeTraRecepFacturaMaquilador r	(nolock) ON r.ClaUbicacion				= rec.ClaUbicacion		
		   																AND r.IdRecepFacturaMaquilador	= rec.IdRecepFacturaMaquilador 
		   	INNER JOIN OPESCH.OpeTraBoletaHisVw bol				(nolock) ON rec.IdBoleta				= bol.IdBoleta 			
		   																AND bol.ClaUbicacion			= @pnClaUbicacion
		WHERE	rec.ClaEstatus in (2,3) 
		AND		rec.ClaUbicacion = @pnClaUbicacion
		AND		contrato.ClaMaquilador = @pnClaMaquilador
		AND		(r.IdRecepFacturaMaquilador IS NULL OR r.IdRecepFacturaMaquilador = @pnIdRecepFacturaMaquilador)
		) t 
	LEFT    JOIN OPESCH.OpeTraBoletaHisVw  bol (nolock) ON t.IdBoleta = bol.IdBoleta AND bol.ClaUbicacion = @pnClaUbicacion
	GROUP BY t.IdRecepOrdenMaquila, t.IdBoleta, t.IdRecepFacturaMaquilador, bol.FechaHoraSalida
	
	
	
	--Fin Nivel 1
	/*
	--Nivel 2
	SELECT convert(TINYINT, NULL) AS Incluir
		, convert(INT, NULL) AS IdBoleta --rec.IdBoleta
		, convert(DATETIME, NULL) AS FechaHoraSalida
		, contrato.IdContrato
		, recdet.IdOrdenMaquila
		, pro.NomProcesoMaquila
		, art.NomArticulo
		, recdet.CantRecibida
		, recdet.PesoRecibido 
		, moneda.NombreCortoMoneda
		, cot.PrecioNegociado AS Precio --convert(NUMERIC(22,4),0) AS Precio
		, recdet.CantRecibida * cot.FactorConversion * cot.PrecioNegociado AS TotalSinIVA
		, recdet.CantRecibida * cot.FactorConversion * cot.PrecioNegociado AS TotalSinIVA2
		, (recdet.CantRecibida * cot.FactorConversion * cot.PrecioNegociado) * (maq.PorcIVA / 100) AS IVA
		, (recdet.CantRecibida * cot.FactorConversion * cot.PrecioNegociado) * (maq.PorcIVA / 100) AS IVA2
		, (recdet.CantRecibida * cot.FactorConversion * cot.PrecioNegociado) * (1 + (maq.PorcIVA / 100)) AS TotalConIVA	
		, (recdet.CantRecibida * cot.FactorConversion * cot.PrecioNegociado) * (1 + (maq.PorcIVA / 100)) AS TotalConIVA2
		, rec.IdRecepOrdenMaquila
		, cot.FactorConversion
		, cot.IdCotizacion
		, uni.NomUnidad
		--, r.IdRecepFacturaMaquilador
	FROM CmqTraRecepOrdenMaquila rec (nolock) INNER
	    JOIN CmqTraRecepOrdenMaquilaDet recdet (nolock) ON rec.IdRecepOrdenMaquila = recdet.IdRecepOrdenMaquila INNER
	    JOIN CmqTraContratoMaquila contrato (nolock) ON recdet.IdContrato = contrato.IdContrato INNER
	    JOIN CmqCatProcesoMaquila pro (nolock) ON contrato.ClaProcesoMaquila = pro.ClaProcesoMaquila INNER
	    JOIN ArtCatArticuloVw art (nolock) ON recdet.ClaArticulo = art.ClaArticulo 
	    							AND recdet.ClaTipoInventario=art.ClaTipoInventario 
									AND art.ClaFamilia != 117  INNER
	    JOIN CmqTraCotizacion cot (nolock) ON contrato.IdCotizacion = cot.IdCotizacion INNER
		JOIN CmqCatMaquilador maq (nolock) ON contrato.ClaMaquilador = maq.ClaMaquilador INNER
	    JOIN TesCatMonedaVw moneda (nolock) ON cot.ClaMoneda = moneda.ClaMoneda INNER    
	    JOIN PloCTraBoletaHisVw bol (nolock) ON rec.IdBoleta = bol.IdBoleta 
	    					AND bol.ClaUbicacion = @pnClaUbicacion LEFT
	    JOIN CmqRelRecepMaquilaFactura r (nolock) ON r.IdRecepOrdenMaquila = rec.IdRecepOrdenMaquila LEFT
	    JOIN ArtCatUnidadVw uni (NOLOCK) ON	art.ClaTipoInventario = uni.ClaTipoInventario AND art.ClaUnidadBase = uni.ClaUnidad		    			
	WHERE rec.ClaEstatus in (2,3)  AND 
		rec.ClaUbicacion = @pnClaUbicacion
		AND contrato.ClaMaquilador = @pnClaMaquilador
		AND (r.IdRecepFacturaMaquilador IS NULL OR r.IdRecepFacturaMaquilador = @pnIdRecepcionFactMaquilador)
	--Fin Nivel 2    
  
*/
SET NOCOUNT OFF
END