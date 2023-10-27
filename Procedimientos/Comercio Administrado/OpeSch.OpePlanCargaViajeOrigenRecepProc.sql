ALTER PROCEDURE OpeSch.OpePlanCargaViajeOrigenRecepProc
	  @pnClaUbicacion			INT
	, @pnClaPlanCargaAux		INT		
	, @pnClaUbicacionOrigen		INT
	, @pnClaViajeOrigen			INT
	, @pnIdFabricacionRel		INT
	, @pnIdFabricacionDetRel	INT
	, @pnClaArticuloRel			INT
	, @pnCantPlanRel			NUMERIC(22,4)	= NULL
	, @pnDebug					TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	-- EXEC OpeSch.OpePlanCargaViajeOrigenRecepProc @pnClaUbicacion=369,@pnClaPlanCargaAux=4,@pnClaUbicacionOrigen=325,@pnClaViajeOrigen=NULL,@pnIdFabricacionRel=23210530,@pnIdFabricacionDetRel=1,@pnClaArticuloRel=699722,@pnCantPlanRel=20958.0000, @pnDebug= 0
	-- EXEC OpeSch.OpePlanCargaViajeOrigenRecepProc @pnClaUbicacion=369,@pnClaPlanCargaAux=4,@pnClaUbicacionOrigen=325,@pnClaViajeOrigen=4304,@pnIdFabricacionRel=23210530,@pnIdFabricacionDetRel=1,@pnClaArticuloRel=699722,@pnCantPlanRel=20958.0000, @pnDebug= 1

	CREATE TABLE #RelPlanCargaViajeOrigenDet(	-- Universo
		  Id					INT IDENTITY(1,1)
		, IdPlanCarga			INT
		, IdViajeOrigen			INT
		, CantDocumentadaPlan	NUMERIC(22,4)
	)

	CREATE TABLE #CantDocumentada(
		  IdViajeOrigen		INT
		, CantDocumentada	NUMERIC(22,4)
	)

	CREATE TABLE #ViajeRecepTraspaso(
		  Id					INT IDENTITY(1,1)
		, IdViajeOrigen			INT
		, CantidadRecibida		NUMERIC(22,4)
		, PesoRecibido			NUMERIC(22,4)
		, CantidadDisponible	NUMERIC(22,4)
	)
	
	--DECLARE @nTotalCantDoc NUMERIC(22,4)


	-- UNIVERSO
	INSERT INTO #RelPlanCargaViajeOrigenDet (IdPlanCarga, IdViajeOrigen, CantDocumentadaPlan)
	SELECT	IdPlanCarga, IdViajeOrigen, CantDocumentadaPlan = ISNULL(SUM(CantDocumentada),0) 
	FROM	OpeSch.OpeRelPlanCargaViajeOrigenDet a WITH(NOLOCK) 
	WHERE	a.ClaUbicacion			= @pnClaUbicacion
	AND		a.ClaArticulo			= @pnClaArticuloRel
	AND		a.BajaLogica			= 0
	GROUP BY IdPlanCarga, IdViajeOrigen


	IF @pnDebug = 1 SELECT '' AS '#RelPlanCargaViajeOrigenDet', * FROM #RelPlanCargaViajeOrigenDet
	
	-- Calcula Cantidad Documentada a nivel de viaje/producto en otros diferentes Planes de Carga
	;WITH H AS(
		SELECT 
			  IdPlanCarga
			, IdViajeOrigen
			, CantDocumentada	= 
					(	SELECT	ISNULL(SUM(b.CantDocumentadaPlan),0) 
						FROM	#RelPlanCargaViajeOrigenDet b WITH(NOLOCK)
						LEFT JOIN #RelPlanCargaViajeOrigenDet c
						ON 		b.IdViajeOrigen	=	c.IdViajeOrigen
						AND		b.IdPlanCarga	<>	c.IdPlanCarga
						WHERE	a.IdPlanCarga = b.IdPlanCarga 
						AND		a.IdViajeOrigen = b.IdViajeOrigen
					)
		FROM	#RelPlanCargaViajeOrigenDet a WITH(NOLOCK)
		GROUP BY IdPlanCarga, IdViajeOrigen
	)	
		INSERT INTO #CantDocumentada
		SELECT	 IdViajeOrigen 
				, TotalCantDoc = CantDocumentada
		FROM	H
		WHERE	IdPlanCarga <> @pnClaPlanCargaAux


	IF @pnDebug = 1
		SELECT '' AS '#CantDocumentada', * FROM #CantDocumentada

	---- -- Calcula Cantidad Total Documentada en el Plan de Carga sin considerar el Viaje a ingresar
	--SELECT	@nTotalCantDoc	= SUM(ISNULL(a.CantDocumentadaPlan,0))
	--FROM	#RelPlanCargaViajeOrigenDet a WITH(NOLOCK)
	--LEFT JOIN #RelPlanCargaViajeOrigenDet c
	--ON		a.IdPlanCarga	=	c.IdPlanCarga
	--AND		a.IdViajeOrigen	<>	c.IdViajeOrigen
	--WHERE	a.IdPlanCarga = @pnClaPlanCargaAux
	--GROUP BY a.IdPlanCarga, a.IdViajeOrigen

	--SELECT @nTotalCantDoc = ISNULL(@nTotalCantDoc,0)
	

IF @@SERVERNAME = 'SRVLABUSA01'
	INSERT INTO #ViajeRecepTraspaso (IdViajeOrigen, CantidadRecibida, PesoRecibido, CantidadDisponible) 
	SELECT	  IdViajeOrigen			= a.NumViaje
			, CantidadRecibida		= b.CantidadRecibida
			, PesoRecibido			= b.KilosPesados
			, CantidadDisponible	= (b.CantidadRecibida - ISNULL(c.CantDocumentada,0))
	FROM	OpeSch.OpeTraMovMciasTranEncVw a
	INNER JOIN OpeSch.OpeTraMovMciasTranDetVw b	
	ON		a.ClaUbicacionOrigen	= b.ClaUbicacion
	AND		a.ClaTipoInventario		= b.ClaTipoInventario
	AND		a.IdMovimiento			= b.IdMovimiento
	LEFT JOIN #CantDocumentada c
	ON		a.NumViaje				= c.IdViajeOrigen
	WHERE	a.ClaUbicacion			= @pnClaUbicacionOrigen
	AND		a.ClaUbicacionOrigen	= @pnClaUbicacionOrigen
	AND		(@pnClaViajeOrigen IS NULL OR (a.NumViaje	= @pnClaViajeOrigen))
	AND		b.ClaUbicacionDestino	= @pnClaUbicacion
	AND		b.ClaArticulo			= @pnClaArticuloRel

IF @@SERVERNAME <> 'SRVLABUSA01'
	INSERT INTO #ViajeRecepTraspaso (IdViajeOrigen, CantidadRecibida, PesoRecibido, CantidadDisponible)
	SELECT	  a.IdViajeOrigen
			, CantidadRecibida		= a.CantRecibida
			, PesoRecibido			= a.PesoRecibido
			, CantidadDisponible	= a.CantRecibida - ISNULL(c.CantDocumentada,0)
	FROM	OpeSch.OpeTraRecepTraspasoProdRecibido a WITH(NOLOCK)
	LEFT JOIN #CantDocumentada c
	ON		a.ClaUbicacionOrigen				= c.IdViajeOrigen
	WHERE	(@pnClaViajeOrigen IS NULL OR (a.IdViajeOrigen = @pnClaViajeOrigen))
	AND		ClaUbicacionOrigen	= @pnClaUbicacionOrigen
	AND		ClaUbicacion		= @pnClaUbicacion
	AND		IdFabricacion		= @pnIdFabricacionRel
	AND		IdFabricacionDet	= @pnIdFabricacionDetRel
	AND		ClaArticuloRecibido	= @pnClaArticuloRel


	--UPDATE	a
	--SET CantidadDocumentada = 
	--	CASE	WHEN ( (CantidadDisponible <= @pnCantPlanRel) AND (CantidadDisponible <= (@pnCantPlanRel-@nTotalCantDoc)) ) 
	--			THEN CantidadDisponible
	--			ELSE CASE	WHEN ( (CantidadDisponible <= @pnCantPlanRel) AND (CantidadDisponible > (@pnCantPlanRel-@nTotalCantDoc)) ) 
	--						THEN (@pnCantPlanRel-@nTotalCantDoc)
	--			ELSE CASE	WHEN ( (CantidadDisponible > @pnCantPlanRel) )  
	--						THEN (@pnCantPlanRel-@nTotalCantDoc)
	--	END END END
	--FROM	#ViajeRecepTraspaso a

	IF @pnDebug = 1 SELECT '' AS '#ViajeRecepTraspaso', * FROM #ViajeRecepTraspaso 


	/*RESULTADO*/
	SELECT	  a.IdViajeOrigen
			, CantidadRecibida		= ISNULL(a.CantidadRecibida,0)	
			, PesoRecibido			= ISNULL(a.PesoRecibido,0)		
			, CantidadDisponible	= ISNULL(a.CantidadDisponible,0)	
	--		, CantidadDocumentada	= ISNULL(a.CantidadDocumentada,0)	
	--		, TotalCantDoc			= @nTotalCantDoc
	FROM	#ViajeRecepTraspaso a
	ORDER BY a.IdViajeOrigen ASC


	DROP TABLE #RelPlanCargaViajeOrigenDet, #CantDocumentada,  #ViajeRecepTraspaso

	SET NOCOUNT OFF
END