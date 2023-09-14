DECLARE @pnClaUbicacionDestino INT = 362 --323,324,470

	CREATE TABLE #TmpRemision
	(
		DarEntrada					VARCHAR(255),		IdPlanCarga		INT,				NombreEstatusPC		VARCHAR(150),		Origen			INT,
		NomOrigen					VARCHAR(50),		NumViaje		INT,				Remisiones			VARCHAR(200),		Placas			VARCHAR(12),
		FechaHoraMovimientoEntrada	DATETIME,			ClaEstatus		INT,				NombreEstatus		VARCHAR(50),		ClaTransporte	INT,
		NomChofer					VARCHAR(500),		KilosEnviados	NUMERIC(22, 4)
	)

		INSERT INTO #TmpRemision
		EXEC OPE_LOCALSERVER_LNKSVR.Operacion.OPESch.OPE_CU444_Pag44_Grid_GridMercancia_Sel @pnClaUbicacion = @pnClaUbicacionDestino, 
			 @pnClaUbicacionEmbarca = NULL, @pnClaTransportista = NULL, @pnClaArticulo = NULL,
			 @pnEsEnTransito = 0, @pnEsEnPatio = 0, @pnEsRecibidas = 0, @pnEsLiberadas = 0, @pnEsTodos = 1,
			 @ptFechaDesde = NULL, @ptFechaHasta = NULL, @pnNumViaje = NULL, @psIdioma = 'Spanish', @pnIdentificador = 1


		SELECT	ClaUbicacion = 362--@pnClaUbicacionDestino
				, a.Origen, a.NomOrigen, a.NumViaje, a.Remisiones, a.Placas, a.FechaHoraMovimientoEntrada, 
				c.NomTransporte, a.NomChofer, a.KilosEnviados, a.IdPlanCarga,  b.ClaEstatusPlanCarga, 
				a.IdPlanCarga, CASE WHEN a.IdPlanCarga IS NULL THEN 0 ELSE 1 END, 
				a.ClaEstatus,a.DarEntrada,a.NombreEstatus,
				CASE WHEN a.ClaEstatus IN (1,0) AND ISNULL(a.DarEntrada,'') = '' THEN a.NombreEstatus + ' sin fabricación espejo'
				     ELSE CASE WHEN a.ClaEstatus IN (1,0) AND ISNULL(a.DarEntrada,'') <> '' THEN a.NombreEstatus + ' con fabricación espejo'
					 ELSE CASE WHEN ( a.IdPlanCarga IS NOT NULL AND b.ClaEstatusPlanCarga NOT IN (3, 4, 5, 6) ) THEN ' Recibido con Plan de Carga Virtual'
					 ELSE a.NombreEstatus END END END AS NombreEstatus
		FROM	#TmpRemision a
		LEFT JOIN OpeSch.OpeTraPlanCarga b WITH(NOLOCK) 
		ON b.ClaUbicacion = 362--@pnClaUbicacionDestino
		AND a.IdPlanCarga = b.IdPlanCarga
		LEFT JOIN FleSch.FLECatTransporteCen c WITH(NOLOCK) ON a.ClaTransporte = c.ClaTransporte
		WHERE	( a.ClaEstatus IN (1,0) OR ( a.IdPlanCarga IS NOT NULL AND b.ClaEstatusPlanCarga NOT IN (3, 4, 5, 6) ) )


		SELECT	a.NumViaje , a.Remisiones, c.IdMovimiento, CantidadEnviada = SUM(d.CantidadEnviada), EstatusEnc = c.EstatusTransito,d.EstatusTransito, a.FechaHoraMovimientoEntrada
		FROM	#TmpRemision a
		LEFT JOIN	OpeSch.OpeTraPlanCarga b WITH(NOLOCK) 
		ON		b.ClaUbicacion	= 362--@pnClaUbicacionDestino
		AND		a.IdPlanCarga	= b.IdPlanCarga
		INNER JOIN	OpeSCH.OpeTraMovMciasTranEnc c WITH(NOLOCK)
		ON		a.Origen	= c.ClaUbicacion
		AND		a.NumViaje	= c.NumViaje
		LEFT JOIN	OpeSCH.OpeTraMovMciasTranDet d WITH(NOLOCK)
		ON		a.Origen	= d.ClaUbicacion
		AND		c.IdMovimiento	= d.IdMovimiento
		AND		d.ClaUbicacionDestino = 362
		WHERE	( a.ClaEstatus IN (1,0) OR ( a.IdPlanCarga IS NOT NULL AND b.ClaEstatusPlanCarga NOT IN (3, 4, 5, 6) ) )
		AND		YEAR(FechaHoraMovimientoEntrada) = 2022  
		GROUP by a.NumViaje , a.Remisiones, c.IdMovimiento, c.EstatusTransito,d.EstatusTransito, a.FechaHoraMovimientoEntrada
		ORDER BY a.NumViaje ASC

		