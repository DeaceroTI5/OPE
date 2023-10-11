ALTER PROCEDURE OPESch.OPEViajeOrigenCmb
		@psValor				VARCHAR(100),		-- Texto a Buscar  
		@pnTipo					INT,				-- 1=Buscar por la ClaveXxxxx  
		@pnClaUbicacion			INT,
		@pnClaUbicacionOrigen	INT,
		@pnClaArticuloRel		INT,
		@pnClaPlanCargaAux		INT
AS    
BEGIN  

	DECLARE @tbViajeOrigen TABLE (
		  ClaViajeOrigen	INT
		, NomViajeOrigen	VARCHAR(20)
	)

	INSERT INTO @tbViajeOrigen (ClaViajeOrigen, NomViajeOrigen)
	SELECT	a.NumViaje, CONVERT(VARCHAR(20),NumViaje)
	FROM	OpeSch.OpeTraMovMciasTranEncVw a
	INNER JOIN OpeSch.OpeTraMovMciasTranDetVw b	
	ON		a.ClaUbicacion			= b.ClaUbicacion
	AND		a.ClaTipoInventario		= b.ClaTipoInventario
	AND		a.IdMovimiento			= b.IdMovimiento
	WHERE	a.ClaUbicacion			= @pnClaUbicacionOrigen
	AND		a.ClaUbicacionOrigen	= @pnClaUbicacionOrigen
	AND		a.EstatusTransito		IN (0,1)
	AND		b.ClaUbicacionDestino	= @pnClaUbicacion
	AND		b.ClaArticulo			= @pnClaArticuloRel
	AND		NOT EXISTS (	-- Mostrar Viajes no relacionados a otro plan de carga)
				SELECT	1
				FROM	OpeSch.OpeRelPlanCargaViajeOrigenDet c WITH(NOLOCK)		
				WHERE	b.ClaUbicacionDestino	= C.ClaUbicacion
				AND		c.IdPlanCarga			<> @pnClaPlanCargaAux
				AND		a.NumViaje				= c.IdViajeOrigen
				AND		c.BajaLogica			= 0
	)
	------------------------------------------------------------------------------------

	IF (@psValor = '' OR @psValor IS NULL)  
		SELECT  TOP 500  ClaViajeOrigen 
					, NomViajeOrigen
		FROM	@tbViajeOrigen
		ORDER BY ClaViajeOrigen  

	ELSE  
		IF @pnTipo  IN (1,99)   
			SELECT TOP 500  ClaViajeOrigen  
					, NomViajeOrigen
			FROM	@tbViajeOrigen
			WHERE ClaViajeOrigen = @psValor    
			ORDER BY ClaViajeOrigen
		ELSE  
		BEGIN  
			SELECT TOP 500  ClaViajeOrigen 
					, NomViajeOrigen 
			FROM	@tbViajeOrigen
			WHERE	NomViajeOrigen LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'
			ORDER BY ClaViajeOrigen 
		END  
END  