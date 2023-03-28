/*
	SELECT	IdPlanCarga, IdBoleta  
	FROM	OpeSch.OpetraViajeVw WHERE IdViaje = 3645

	SELECT	  t1.ClaArticulo
			, t1.IdFabricacion
			, t1.IdFabricacionDet
			, CantEmbarcada = SUM(ISNULL(t1.CantEmbarcada,0))
			, PesoEmbarcado = SUM(ISNULL(t1.PesoEmbarcado,0))
	FROM	OpeSch.OpeTraPlanCargaLocInv t1 WITH(NOLOCK)
	WHERE	t1.ClaUbicacion = 325	-- @ClaUbicacion 
	AND		t1.IdPlanCarga	= 4112	-- @IdPlanCarga
	GROUP BY t1.ClaArticulo, t1.IdFabricacion, t1.IdFabricacionDet

	SELECT	  CantEmbMovEntSal		= ISNULL( t2.CantEmbarcada,0)
			, PesoEmbarcadoEntSal	= ISNULL (t2.PesoEmbarcado, 0) 
	FROM	OpeSch.OpeTraMovEntSal t1 WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTraMovEntSalDet t2 WITH(NOLOCK) 
	ON		t2.ClaUbicacion			= t1.ClaUbicacion 
	AND		t2.IdMovEntSal			= t1.IdMovEntSal
	WHERE	t1.ClaUbicacion			= 325		--@ClaUbicacion 
	AND		t1.IdBoleta				= 222460002	--@IdBoleta 
	AND		t1.IdViaje				= 3645		--@IdViaje
	AND		t2.ClaArticulo			= 710682	--@ClaArticulo 
	AND		t2.IdFabricacion		= 24150925	--@IdFabricacion 
	AND		t2.IdFabricacionDet		= 1			--@idFabricacionDet

*/

--Validaciones
--SELECT	1
--FROM	OpeSch.OpeTraPlanCarga t1 WITH(NOLOCK)
--WHERE	t1.EsPesajeParcial = 1 AND
--		t1.EsUltimoPesajeParcial = 0 AND
--		t1.ClaUbicacion = 325 AND
--		t1.IdBoleta like 222460002 AND
--		t1.ClaEstatusPlanCarga = 2

		SELECT	  t1.ClaArticulo
				, t1.IdFabricacion
				, t1.IdFabricacionDet
				, CantEmbarcada = SUM(ISNULL(t1.CantEmbarcada,0))
				, PesoEmbarcado = SUM(ISNULL(t1.PesoEmbarcado,0))
		FROM	OpeSch.OpeTraPlanCargaLocInv t1 WITH(NOLOCK)
		WHERE	t1.ClaUbicacion = 325	-- @ClaUbicacion 
		AND		t1.IdPlanCarga	= 4112	-- @IdPlanCarga
		GROUP BY t1.ClaArticulo, t1.IdFabricacion, t1.IdFabricacionDet

		SELECT	IdFabricacion = COUNT(t2.IdFabricacion), ClaArticulo = COUNT(t2.ClaArticulo), CantEmbarcada = SUM(ISNULL(t2.CantEmbarcada,0))
				, PesoEmbarcado = SUM(ISNULL(t2.PesoEmbarcado,0)), PesoTara = SUM(ISNULL(t2.PesoTara,0))
		FROM	OpeSch.OpeTraPlanCarga t1 WITH(NOLOCK)
		INNER JOIN OpeSch.OpeTraPlanCargaDet t2 WITH(NOLOCK) 
		ON		t1.ClaUbicacion		= t2.ClaUbicacion 
		AND		t1.IdPlanCarga		= t2.IdPlanCarga 
		AND		t2.CantEmbarcada	> 0					
		WHERE	t1.ClaUbicacion		= 325 
		AND		t1.IdBoleta			= 222460002 
		AND		t1.ClaEstatusPlanCarga = 2
		GROUP BY t1.IdPlanCarga

		--datos del viaje
		SELECT	IdFabricacion = COUNT(t2.IdFabricacion), ClaArticulo = COUNT(t2.ClaArticulo), CantEmbarcada = SUM(ISNULL(t2.CantEmbarcada,0)), 
				PesoEmbarcado = SUM(ISNULL(t2.PesoEmbarcado,0)), PesoTara = SUM(ISNULL(t2.PesoTara,0))
		FROM	OpeSch.OpeTraMovEntSal t1 WITH(NOLOCK)
		INNER JOIN OpeSch.OpeTraMovEntSalDet t2 WITH(NOLOCK) 
		ON		t1.ClaUbicacion = t2.ClaUbicacion 
		AND		t1.IdMovEntSal = t2.IdMovEntSal
		WHERE	t1.ClaUbicacion		= 325		-- @ClaUbicacion 
		AND		t1.IdBoleta			= 222460002 -- @IdBoleta 
		AND		t1.IdViaje			= 3645		-- @IdViaje 
		AND		t2.CantEmbarcada	> 0

