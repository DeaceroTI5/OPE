ALTER PROCEDURE OpeSch.OpeTiUbicacionRel2Cmb 
		@psValor			VARCHAR(100),		-- Texto a Buscar  
		@pnIncluirTodosSN	TINYINT = 0,
		@pnTipo				INT,				-- 1=Buscar por la ClaveXxxxx  
		@pnModoSel			INT = 1,			-- 1=Retorno Clave - Descripcion   <>1  Descripcion  
		@pnBajasSn			INT = 0  	   
AS   
BEGIN
	-- EXEC OpeSch.OpeTiUbicacionRel2Cmb '', 0, 1, 1, 0

	SET NOCOUNT ON

	DECLARE @TUbicaciones TABLE
	(
		  ClaUbicacion		INT
		, NombreUbicacion	VARCHAR(70)
	)

	INSERT	INTO @TUbicaciones(ClaUbicacion, NombreUbicacion)
	SELECT  ClaUbicacion,
			NombreUbicacion
	FROM	OPESch.OPETiCatUbicacionVw
	WHERE	ClaTipoUbicacion IN (2,5, 3,4,7)	-- Acer�as, Bodegas/CEDIS; Bodegas Deacero, Patios, CEDIS 
	AND		ClaEmpresa = 1
	AND		( ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1 )  

	IF (@psValor = '' OR @psValor IS NULL)  
		SELECT	TOP 500 ClaUbicacionRel2 = ClaUbicacion, 
				NomUbicacionRel2 = CASE @pnModoSel WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(150), ClaUbicacion))) + ' - ' + NombreUbicacion ELSE NombreUbicacion END  
		FROM	@TUbicaciones
		ORDER BY ClaUbicacion, NomUbicacionRel2  
	ELSE  
	IF @pnTipo  IN (1,99)   
		SELECT	TOP 500 ClaUbicacionRel2 = ClaUbicacion, 
				NomUbicacionRel2 = CASE @pnModoSel WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(150), ClaUbicacion))) + ' - ' + NombreUbicacion ELSE NombreUbicacion END  
		FROM	@TUbicaciones
		WHERE	ClaUbicacion = @psValor     
		ORDER BY ClaUbicacion,NomUbicacionRel2 
	ELSE  
	BEGIN  
		SELECT	TOP 500 ClaUbicacionRel2 = ClaUbicacion, 
				NomUbicacionRel2 = CASE @pnModoSel WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(150), ClaUbicacion))) + ' - ' + NombreUbicacion ELSE NombreUbicacion END  
		FROM	@TUbicaciones
		WHERE	NombreUbicacion LIKE '%' + ltrim(rtrim(@psValor)) + '%' 
		ORDER BY ClaUbicacion, NomUbicacionRel2 
	END
	
	SET NOCOUNT OFF
END