--SELECT * FROM OpeSch.OpeArtCatArticuloVw WHERE ClaveArticulo IN('78995', '22277')

SELECT	t1.EstatusTransito, t2.EstatusTransito, t2.ClaTma, *
FROM	DEAOFINET04.Operacion.invsch.InvTraMovMciasTranEnc t1 WITH(NOLOCK)    
INNER JOIN DEAOFINET04.Operacion.invsch.InvTraMovMciasTrandet t2 WITH(NOLOCK) 
ON		t2.ClaUbicacion =  t1.ClaUbicacion 
AND		t2.IdMovimiento = t1.IdMovimiento
AND		t2.ClaTipoInventario = t1.ClaTipoInventario
WHERE	t2.EntradaSalida = -1
AND		t1.ClaTipoInventario = 1
AND		t1.ClaUbicacionOrigen = 22
AND		(t1.FechaHoraMovimiento >= '20220101' AND t1.FechaHoraMovimiento < '20230721')
AND		ISNULL(t1.EstatusTransito, 0) = 0
AND		t2.ClaUbicacionDestino = 325
AND		t2.ClaArticulo IN (564387, 534232)


SELECT	t1.EstatusTransito, t2.EstatusTransito, t2.ClaTma, *
FROM	Opesch.OpeTraMovMciasTranEnc t1 WITH(NOLOCK)    
INNER JOIN Opesch.OpeTraMovMciasTranDet t2 WITH(NOLOCK) 
ON		t2.ClaUbicacion =  t1.ClaUbicacion 
AND		t2.IdMovimiento = t1.IdMovimiento
AND		t2.ClaTipoInventario = t1.ClaTipoInventario
WHERE	t1.IdMovimiento IN (915644, 918748)

SELECT *
FROM OpeSch.OpeTraBoletaVw WHERE ClaUbicacion = 325 AND Placa = '80AU6D  '

SELECT IdBoleta, ClaBasculaEntrada, ClaBasculaSalida, ClaEstatusPlaca, ClaMotivoEntrada, ClaUbicacionOrigen, IdViajeOrigen, EsEntradaManual, PesoDocumentado
		, PesoEntrada, PesoBruto, PesoNeto, PesoSalida, EsSalidaManual, FechaUltimaMod
FROM OpeSch.OpeTraBoletaHisVw WHERE ClaUbicacion = 325 AND Placa = '80AU6D  '


------
--Revision 
--DECLARE @sPlaca VARCHAR(10) = '80AU6D  '
DECLARE @sPlaca VARCHAR(10) = '80AU6D'
SET @sPlaca = LTRIM(RTRIM(@sPlaca))

SELECT * 
FROM	OPeSCH.OpeTraMovMciasTranEnc WITH(nolock)
WHERE	Placas LIKE '%'+@sPlaca+'%'
AND		Placas NOT LIKE '%'+@sPlaca+'%'




SELECT * 
FROM	OPeSCH.OpeTraMovMciasTranEnc encOrigen WITH(nolock)
WHERE	Placas LIKE '%'+@sPlaca+'%'
AND		encOrigen.Placas NOT IN (SELECT Placa FROM OpeSch.OpeTraBoleta (NOLOCK) WHERE ClaUbicacion = 325)

SELECT * 
FROM	OPeSCH.OpeTraMovMciasTranEnc encOrigen WITH(nolock)
WHERE	ISNULL( @sPlaca,'') IN ('',LTRIM(RTRIM(encOrigen.Placas)))
AND		LTRIM(RTRIM(encOrigen.Placas)) NOT IN (SELECT LTRIM(RTRIM(Placa)) FROM OpeSch.OpeTraBoleta (NOLOCK) WHERE ClaUbicacion = 325)

SELECT * 
FROM	OPeSCH.OpeTraMovMciasTranEnc encOrigen WITH(nolock)
WHERE	ISNULL( @sPlaca,'') IN ('',encOrigen.Placas)
AND		encOrigen.Placas NOT IN (SELECT Placa FROM OpeSch.OpeTraBoleta (NOLOCK) WHERE ClaUbicacion = 325)


GO
DECLARE @sPlaca VARCHAR(10) = '80AU6D'

SELECT 'CONSULTA BOLETA'
SELECT * FROM OpeSch.OpeTraBoleta (NOLOCK) WHERE ClaUbicacion = 325 AND ISNULL( @sPlaca,'') IN ('', Placa)							-- condicion Proc
SELECT * FROM OpeSch.OpeTraBoleta (NOLOCK) WHERE ClaUbicacion = 325 AND Placa LIKE '%'+@sPlaca+'%'									-- condición LIKE
SELECT * FROM OpeSch.OpeTraBoleta (NOLOCK) WHERE ClaUbicacion = 325 AND LTRIM(RTRIM(Placa)) = LTRIM(RTRIM(@sPlaca))					-- condición sin espacios

SELECT 'CONSULTA MOVIMIENTOS'
SELECT * FROM OPeSCH.OpeTraMovMciasTranEnc encOrigen WITH(nolock) WHERE ISNULL( @sPlaca,'') IN ('',Placas)							-- condicion Proc
SELECT * FROM OPeSCH.OpeTraMovMciasTranEnc encOrigen WITH(nolock) WHERE Placas LIKE '%'+@sPlaca+'%'										-- condición LIKE
SELECT * FROM OPeSCH.OpeTraMovMciasTranEnc encOrigen WITH(nolock) WHERE LTRIM(RTRIM(Placas)) = LTRIM(RTRIM(@sPlaca))					-- condición sin espacios


SELECT IdViajeOrigen, * FROM opeSch.OpeTraRecepTraspaso WHERE (rtrim(ltrim(isnull('80AU6D','')))='' or rtrim(ltrim(isnull('80AU6D','')))= Placa) 
SELECT IdViajeOrigen, * FROM opeSch.OpeTraRecepTraspaso WHERE  Placa LIKE '%80AU6D%'	



-------------------------
SELECT viaje.FechaViaje,viaje.ClaEstatus, * FROM OpeSch.OpeTraRecepTraspasoProd prod
INNER JOIN /*PloTraRecepTraspaso*/ opeSch.OpeTraRecepTraspaso viaje (nolock) ON viaje.IdViajeOrigen = prod.IdViajeOrigen AND
viaje.ClaUbicacionOrigen = prod.ClaUbicacionOrigen AND
viaje.ClaUbicacion = prod.ClaUbicacion
INNER JOIN /*PloTraRecepTraspasoFab*/ OpeSch.OpeTraRecepTraspasoFab traspasoFabricacion (nolock) ON traspasoFabricacion.IdViajeOrigen = prod.IdViajeOrigen
AND traspasoFabricacion.ClaUbicacionOrigen = prod.ClaUbicacionOrigen
AND traspasoFabricacion.ClaUbicacion = prod.ClaUbicacion
AND traspasoFabricacion.IdFabricacion = prod.IdFabricacion
 WHERE viaje.IdViajeOrigen = 254146

----------------------------------------------------------

	DECLARE @pbRbTodasMod537 INT = 1

		SELECT encOrigen.FechaMovimiento, NumViaje , *
		FROM OPeSCH.OpeTraMovMciasTranEnc encOrigen WITH(nolock)
		LEFT JOIN OPeSCH.OpeTraMovMciasTranDet detOrigen WITH(nolock)
		ON detOrigen.ClaUbicacion = encOrigen.ClaUbicacion 
		AND detOrigen.ClaTipoInventario = encOrigen.ClaTipoInventario 
		AND detOrigen.IdMovimiento = encOrigen.IdMovimiento
		INNER JOIN opesch.opeTiCatUbicacionVw Ubicacion WITH(NOLOCK)
		ON Ubicacion.ClaUbicacion = encOrigen.ClaUbicacionOrigen
		INNER JOIN Opesch.OpeFleCatTransporteVw Transporte WITH(NOLOCK)
		ON Transporte.ClaTransporte = encOrigen.Clatransporte
		INNER JOIN #tmp__EstatusMt estatusMt
		ON estatusMt.ClaEstatusMt = ISNULL(encOrigen.estatusTransito,0)
		WHERE encOrigen.ClaTipoInventario = 1
		--AND EncOrigen.ClaUbicacion != @pnClaUbicacion --Con AND detOrigen.ClaTMA IN (100, 200) para que muestre tambien los cambios de destino a la misma ubicacion.
		AND detOrigen.ClaUbicacionDestino = 325
		AND (isnull(encOrigen.EstatusTransito,0) = 0 OR (isnull(encOrigen.EstatusTransito,0) = 0 AND isnull(detOrigen.EstatusTransito,0) = 0 )) 
		AND ISNULL(22,encOrigen.ClaUbicacionOrigen) = encOrigen.ClaUbicacionOrigen
		AND  encOrigen.Placas LIKE '%80AU6D%'
		AND (ISNULL(@pbRbTodasMod537,0) = 0 AND encOrigen.Placas NOT IN (SELECT Placa FROM OpeSch.OpeTraBoleta (NOLOCK) WHERE ClaUbicacion = 325))
		AND detOrigen.ClaTMA IN (100, 200, 3)

		SELECT encOrigen.FechaMovimiento, NumViaje , *
		FROM OPeSCH.OpeTraMovMciasTranEnc encOrigen WITH(nolock)
		LEFT JOIN OPeSCH.OpeTraMovMciasTranDet detOrigen WITH(nolock)
		ON detOrigen.ClaUbicacion = encOrigen.ClaUbicacion 
		AND detOrigen.ClaTipoInventario = encOrigen.ClaTipoInventario 
		AND detOrigen.IdMovimiento = encOrigen.IdMovimiento
		INNER JOIN opesch.opeTiCatUbicacionVw Ubicacion WITH(NOLOCK)
		ON Ubicacion.ClaUbicacion = encOrigen.ClaUbicacionOrigen
		INNER JOIN Opesch.OpeFleCatTransporteVw Transporte WITH(NOLOCK)
		ON Transporte.ClaTransporte = encOrigen.Clatransporte
		INNER JOIN #tmp__EstatusMt estatusMt
		ON estatusMt.ClaEstatusMt = ISNULL(encOrigen.estatusTransito,0)
		WHERE encOrigen.ClaTipoInventario = 1
		--AND EncOrigen.ClaUbicacion != @pnClaUbicacion --Con AND detOrigen.ClaTMA IN (100, 200) para que muestre tambien los cambios de destino a la misma ubicacion.
		AND detOrigen.ClaUbicacionDestino = 325
		AND (isnull(encOrigen.EstatusTransito,0) = 0 OR (isnull(encOrigen.EstatusTransito,0) = 0 AND isnull(detOrigen.EstatusTransito,0) = 0 )) 
		AND ISNULL(22,encOrigen.ClaUbicacionOrigen) = encOrigen.ClaUbicacionOrigen
		AND  encOrigen.Placas LIKE '%80AU6D%'
		AND ((ISNULL(@pbRbTodasMod537,0) = 0 AND encOrigen.Placas NOT IN (SELECT Placa FROM OpeSch.OpeTraBoleta (NOLOCK) WHERE ClaUbicacion = 325)
		) OR ((ISNULL(@pbRbTodasMod537,0)  )= 1))
		AND detOrigen.ClaTMA IN (100, 200, 3)

		SELECT TOP 10 * FROM OpeSch.OpeTraBoleta WHERE ClaUbicacion = 325 AND ClaEstatusPlaca=3 ORDER BY FechaUltimaMod DESC
		SELECT * FROM OpeSch.OpeTraBoleta (NOLOCK) WHERE Placa LIKE '%80AU6D%'

		SELECT * FROM OpeSch.OpeTraMovEntSal WHERE ClaUbicacion = 325 AND IdBoleta = 223370020
		SELECT * FROM OpeSch.OpeTraMovEntSal WHERE ClaUbicacion = 325 AND IdBoleta IN (232020021, 232020009, 232020005, 223370020)