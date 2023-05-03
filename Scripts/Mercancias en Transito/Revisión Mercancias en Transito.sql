USE Operacion
GO

-- exec OPESch.OPE_CU53_Pag7_Grid_ResultadoMod537_Sel @pnClaUbicacion=267,@pnClaUbicacionOriMod537=NULL,@pdFechaIniMod537='2023-03-01 00:00:00',@pdFechaFinMod537='2023-03-16 00:00:00',@psPlacaMod537='',@pbRbTodasMod537=0,@pbRbRecibidasMod537=0,@pbRbTransitoMod537=1,@pbRbReclasificarMod537=0,@pnNumViaje537=NULL
-- EXEC SP_HELPTEXT 'OPESch.OPE_CU53_Pag7_Grid_ResultadoMod537_Sel'

DECLARE @pnClaUbicacion INT = 267
		, @nIdViaje		INT = 158172

		SELECT	  NumViaje
				, ClaUbicacionDestino
				, encOrigen.EstatusTransito
				, detOrigen.EstatusTransito
				, detOrigen.ClaTMA
				, encOrigen.FechaMovimiento
				, encOrigen.Placas
				, encOrigen.Clatransporte
				, Transporte.ClaTransporte
		FROM	OPeSCH.OpeTraMovMciasTranEnc encOrigen WITH(nolock)
		LEFT JOIN OPeSCH.OpeTraMovMciasTranDet detOrigen WITH(nolock)
		ON		detOrigen.ClaUbicacion = encOrigen.ClaUbicacion 
		AND		detOrigen.ClaTipoInventario = encOrigen.ClaTipoInventario 
		AND		detOrigen.IdMovimiento = encOrigen.IdMovimiento
		LEFT JOIN Opesch.OpeFleCatTransporteVw Transporte WITH(NOLOCK)	-- INNER
		ON		Transporte.ClaTransporte = encOrigen.Clatransporte
		WHERE	encOrigen.ClaTipoInventario = 1
		AND		NumViaje = @nIdViaje  
--		AND		detOrigen.ClaUbicacionDestino = @pnClaUbicacion
		-- Solo viajes vivos
--		AND (ISNULL(@pbRbTodasMod537,0) = 0 AND encOrigen.Placas NOT IN (SELECT Placa FROM OpeSch.OpeTraBoleta (NOLOCK) WHERE ClaUbicacion = @pnClaUbicacion))
	--	AND convert(varchar,encOrigen.FechaMovimiento,112) BETWEEN  convert(varchar,@pdFechaIniMod537,112)	AND convert(varchar,@pdFechaFinMod537,112)
	--	AND		detOrigen.ClaTMA IN (100, 200, 3)
		--AND		(ISNULL(encOrigen.EstatusTransito,0) = 0 
		--		 OR (ISNULL(encOrigen.EstatusTransito,0) = 0 AND ISNULL(detOrigen.EstatusTransito,0) = 0 )) 
		ORDER BY encOrigen.claUbicacionOrigen, encOrigen.numviaje


--INSERT INTO FLESch.FLECatTransporte
--SELECT * FROM DEAHOUNET03.Operacion.FLESch.FLECatTransporte WITH(NOLOCK) WHERE ClaTransporte = 180

--SELECT * FROM FLESch.FLECatTransporte WITH(NOLOCK) WHERE ClaTransporte = 180