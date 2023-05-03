USE Operacion
GO

	--CREATE TABLE #TmpClaveSerivio
	--(
	--	ID					INT IDENTITY(1,1),
	--	ClaveServicio		INT
	--)

	--INSERT INTO #TmpClaveSerivio 
	--SELECT DISTINCT LTRIM(RTRIM(string))
	--FROM FleSch.FleUtiSplitStringFn(518, ',')




SELECT	KgsReal/1000 AS KgsReal  
	,PesoAceroFisico = (ISNULL(H.KgCubicados,H2.KgCubicados)) / 1000.00
	,H.KgCubicados
	,H2.KgCubicados
	,t0.Referencia1
FROM	FLESch.FLETraTabularVw t0
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
	INNER JOIN #TmpClaveSerivio serv
	ON		c.ClaFamilia <> serv.ClaveServicio
	WHERE	fac.ClaUbicacion = 325--@pnClaUbicacion
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
	INNER JOIN #TmpClaveSerivio serv
	ON		c.ClaFamilia <> serv.ClaveServicio
	WHERE	ent.ClaUbicacion = 325--@pnClaUbicacion
	GROUP BY CONVERT(VARCHAR(50),ent.NumViaje)
)	H2 ON	t0.ClaTipoTabular = 1 
	AND		t0.Referencia1 = H2.NumViaje 
WHERE	ClaUbicacion = 325 AND IdTabular = 9175

-- procedimiento para obtener KgReales
--exec FLESch.FLE_CU6_Pag1_Sel @pnClaUbicacion=325,@pnNumViajeCU6P1=6028,@psIdioma='Spanish',@pnClaIdioma=default


--SELECT * FROM FleSch.FleTraViaje WHERE NumViaje = 6028

SELECT SUM(KgReales) FROM FleSch.FleTraTabularDetVw a
LEFT JOIN FleSch.FleArtCatArticuloVw c
ON		a.ClaArticulo		= c.ClaArticulo
AND		c.ClaTipoInventario = 1	
INNER JOIN #TmpClaveSerivio serv
ON		c.ClaFamilia <> serv.ClaveServicio
WHERE ClaUbicacion = 325 AND IdTabular = 9175



SELECT SUM(KgReales) FROM FleSch.FleTraTabularDetVw a
LEFT JOIN FleSch.FleArtCatArticuloVw c
ON		a.ClaArticulo		= c.ClaArticulo
AND		c.ClaTipoInventario = 1	
INNER JOIN #TmpClaveSerivio serv
ON		c.ClaFamilia <> serv.ClaveServicio
WHERE ClaUbicacion = 326 AND IdTabular = 2950












SELECT NumFactura FROM FleSch.FleTraViajeFactura WHERE ClaUbicacion = 325 AND NumViaje = 6028

SELECT	ClaFamilia, [FleSch].[FleObtieneFacturaStrFn](b.NumFactura) Factura, KgCubicados, * 
FROM	FleSch.FleTraViajeFacturaDet b WITH(NOLOCK) 
	LEFT JOIN FleSch.FleArtCatArticuloVw c
	ON		b.ClaArticulo		= c.ClaArticulo
	AND		C.ClaTipoInventario = 1	
WHERE	b.ClaUbicacion = 325 
AND		NumFactura IN (1023006205,1023006206,1023006207,1023006208,1023006209,1023006210)


SELECT * FROM FleSch.FleTraViajeFacturaDet 

