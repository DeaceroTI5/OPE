USE Operacion
GO

DECLARE @pnClaUbicacion		INT		 = 325
		, @ptFechaInicial	DATETIME = '2023-03-01 00:00:00'
		, @ptFechaFinal		DATETIME = '2023-03-31 00:00:00'

DECLARE @nClaveServicio INT

SELECT	@nClaveServicio = nValor1
FROM	OPESCH.OPETiCatConfiguracionVw 
WHERE	ClaUbicacion	= @pnClaUbicacion 
AND		ClaSistema		= 127 
AND		ClaConfiguracion = 1271229

;WITH Hv as(
	 SELECT t0.ClaUbicacion, t0.IdTabular, t0.Referencia1 AS Viaje, t0.ClaTipoTabular, t0.NumGuia
	--		,KgCubicados = (ISNULL(H.KgCubicados,H2.KgCubicados))		
			,H.KgCubicados, KgCubicados2 = H2.KgCubicados
	 FROM	FLESch.FLETraTabularVw t0 WITH(NOLOCK) 
	 LEFT JOIN (
		SELECT	NumViaje = CONVERT(VARCHAR(50),fac.NumViaje),
				KgCubicados = SUM(b.KgCubicados)
		FROM	FleSch.FleTraViajeFactura			fac		WITH (NOLOCK)
		INNER JOIN FleSch.FleTraViajeFacturaDet b
		ON		fac.ClaUbicacion	= b.ClaUbicacion
		AND		fac.NumFactura		= b.NumFactura
		INNER JOIN FleSch.FleArtCatArticuloVw c
		ON		b.ClaArticulo		= c.ClaArticulo
		AND		C.ClaTipoInventario = 1
		WHERE	fac.ClaUbicacion = @pnClaUbicacion
		AND		c.ClaFamilia <> @nClaveServicio
		GROUP BY fac.NumViaje
	 )	H ON	t0.ClaTipoTabular = 1 
		AND		t0.Referencia1	= H.NumViaje 
	 LEFT JOIN (
		SELECT	NumViaje = CONVERT(VARCHAR(50),ent.NumViaje),	
				KgCubicados = SUM(b.KgCubicados)
		FROM	FleSch.FleTraViajeEntsal			ent		WITH (NOLOCK)
		LEFT JOIN FleSch.FleTraViajeEntsalDet b
		ON		ent.ClaUbicacion	= b.ClaUbicacion
		AND		ent.NumEntsal		= b.NumEntsal
		LEFT JOIN FleSch.FleArtCatArticuloVw c
		ON		b.ClaArticulo		= c.ClaArticulo
		AND		C.ClaTipoInventario = 1	
		WHERE	ent.ClaUbicacion = @pnClaUbicacion
		AND		c.ClaFamilia <> @nClaveServicio
		GROUP BY CONVERT(VARCHAR(50),ent.NumViaje)
	) H2 ON t0.ClaTipoTabular = 1 AND t0.Referencia1 = H2.NumViaje 
	WHERE	t0.ClaUbicacion = @pnClaUbicacion
	 AND  t0.FechaTabular >= @ptFechaInicial            
	 AND  t0.FechaTabular < DATEADD(dd,1,@ptFechaFinal) 
)
	SELECT * FROM Hv WHERE viaje = 5604 ORDER BY ClaUbicacion, Viaje
 --SELECT ClaUbicacion, Viaje, COUNT(1) Cont FROM H GROUP BY ClaUbicacion, Viaje having count(1)>1

-- SELECT ClaUbicacion, Viaje, IdTabular, COUNT(1) Cont FROM H GROUP BY ClaUbicacion, Viaje, IdTabular ORDER BY Viaje ASC