DECLARE	  @pnClaUbicacion			INT
		, @pnClaMes					INT
		, @pnDebug					TINYINT = 0

SELECT	  @pnClaUbicacion	= 360
		, @pnClaMes			= NULL
		, @pnDebug			= 0
-- AS	OPEDigitalizacionFormatoPLProc
IF 1 = 1
BEGIN
	SET NOCOUNT ON

	DECLARE	  @dFechaInicio		DATETIME
			, @dFechaFin		DATETIME
			, @nId				INT
			, @nIdViaje			INT
			, @nIdFactura		INT

	DECLARE @tPackingList TABLE(
		  Id			INT IDENTITY(1,1)
		, IdFactura		INT
		, IdViaje		INT
		, IdBoleta		INT
		, FechaViaje	DATETIME
	)


	IF ISNULL(@pnClaMes,0) > 0
		SELECT	  @dFechaInicio = CONVERT(VARCHAR(4),YEAR(GETDATE())) + RIGHT(('00' +CONVERT(VARCHAR(2),@pnClaMes)),2) + '01'
				, @dFechaFin = DATEADD(DAY,-1,DATEADD(MONTH,1,@dFechaInicio))
	ELSE
		SELECT   @dFechaInicio = CAST(CONVERT(VARCHAR(10),(GETDATE() - DAY(GETDATE()) +1),112) AS DATETIME)
				, @dFechaFin = CAST(CONVERT(VARCHAR(10),(GETDATE()),112) AS DATETIME)
	
	IF @pnDebug = 1
		SELECT	  @dFechaInicio AS '@dFechaInicio'
				, @dFechaFin AS '@dFechaFin'

	-- Agrego 1 dia a fecha fin
	SELECT	@dFechaFin = DATEADD(DAY,1,@dFechaFin)

	------------------------------------------------------------------------------------------------------------
	INSERT INTO @tPackingList (IdFactura, IdViaje, IdBoleta, FechaViaje)
	SELECT	c.IdFactura, a.IdViaje, a.IdBoleta, a.FechaViaje
	FROM	OpeSch.OpeTraViajeVw a
	INNER JOIN OpeSch.OpeTraPlanCargaVw e
	ON		a.ClaUbicacion	= e.ClaUbicacion
	AND		a.IdPlanCarga	= e.IdPlanCarga
	INNER JOIN OpeSch.OpeTraBoletaHisVw b
	ON		a.ClaUbicacion	= b.ClaUbicacion
	AND		a.IdBoleta		= b.IdBoleta
	CROSS APPLY (
		SELECT	TOP 1 IdFactura
		FROM	OpeSch.OpeTraMovEntSal cc
		WHERE	a.ClaUbicacion = cc.ClaUbicacion
		AND		a.IdViaje	= cc.IdViaje
		AND		(cc.IdFactura IS NOT NULL AND cc.IdFactura > 0)
		ORDER BY IdFactura DESC
	)	c
	LEFT JOIN	OpeSch.OpeReporteFactura  d WITH(NOLOCK)    
	on		a.ClaUbicacion			= d.ClaUbicacion    
	AND		c.IdFactura				= d.IdFactura		    
	AND		d.ClaFormatoImpresion	= 8		-- Packing List 
	AND		d.IdCertificado			= d.IdCertificado
	WHERE	a.ClaUbicacion			= @pnClaUbicacion
	AND		(a.FechaViaje			>= @dFechaInicio
	AND		a.FechaViaje			< @dFechaFin)
	AND		a.ClaTipoViaje			= 4		-- Exportación
	AND		e.ClaEstatusPlanCarga	NOT IN (4, 5, 6) -- Cancelado, Eliminado, Eliminado Por Sistema
	AND		b.ClaMotivoEntrada		= 1		-- Camion por Cargar
	AND		b.ClaTipoPesajeEntrada	= 1		-- Tractor + Caja
	AND		b.ClaTipoPesajeSalida	= 4		-- Camión con Movimiento
	AND		d.IdCertificado IS NULL
	AND		EXISTS (
				SELECT	1	-- Que existan datos del packing list
				FROM	OpeSch.OpeTraPlanCargaEmpaque  f WITH(NOLOCK)
				WHERE	a.ClaUbicacion	= f.ClaUbicacion
				AND		a.IdPlanCarga	= f.IdPlanCarga
			)
	ORDER BY IdViaje ASC

	SELECT	@nId = MIN(Id)
	FROM	@tPackingList

	WHILE @nId IS NOT NULL
	BEGIN
		SELECT	  @nIdViaje		= NULL
				, @nIdFactura	= NULL

		SELECT	  @nIdViaje		= IdViaje
				, @nIdFactura	= IdFactura
		FROM	@tPackingList
		WHERE	Id = @nId
		
		SELECT	  @nIdViaje		AS '@nIdViaje'
				, @nIdFactura	AS '@nIdFactura'	
				
		--EXEC OPESch.OpeGeneraFormatoPLPdfProc
 	--		  @pnClaUbicacion	= @pnClaUbicacion
		--	, @pnIdViaje		= @nIdViaje
		--	, @pnIdFactura		= @nIdFactura
		--	, @nNumVersion		= 1
		--	, @psIdioma			= 'es-MX'	
		--	, @pnDebug			= 0
		--	, @psNombrePcMod	= 'OPEDigitalizacionFormatoPLProc'	


		SELECT	@nId = MIN(Id)
		FROM	@tPackingList
		WHERE	Id > @nId
	END

	SET NOCOUNT OFF
END

