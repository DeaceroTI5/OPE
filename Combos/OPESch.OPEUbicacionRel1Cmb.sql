USE Operacion
GO
ALTER PROCEDURE OPESch.OPEUbicacionRel1Cmb  
		@psValor			VARCHAR(100),		-- Texto a Buscar  
		@pnIncluirTodosSN	TINYINT = 0,
		@pnwtk0				INT = -1,			-- Tipo Ubicacion
		@pnTipo				INT,				-- 1=Buscar por la ClaveXxxxx  
		@pnModoSel			INT = 1,			-- 1=Retorno Clave - Descripcion   <>1  Descripcion  
		@pnBajasSn			INT = 0  	   
AS   
BEGIN
	SET NOCOUNT ON

	DECLARE @TUbicaciones TABLE(
		  ClaUbicacion		INT
		, NombreUbicacion	VARCHAR(70)
		, OrdenTipo			INT
	)

	IF ISNULL(@pnwtk0,-1) < 0
		SELECT @pnwtk0 = -1

	IF ISNULL(@pnIncluirTodosSN,0)=1
		INSERT INTO @TUbicaciones(ClaUbicacion, NombreUbicacion, OrdenTipo)
		SELECT    ClaUbicacion		= -1
				, NombreUbicacion	= 'Todos'
				, OrdenTipo			= 0
		
	INSERT INTO @TUbicaciones(ClaUbicacion, NombreUbicacion, OrdenTipo)
	SELECT    ClaUbicacion
			, NombreUbicacion
			, OrdenTipo
	FROM	OPESch.OPEAtiTICatUbicacionVw
	WHERE	(@pnwtk0 = -1 OR (ClaTipoUbicacion = @pnwtk0))
	AND		ClaEmpresa = 52
	AND		( ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1 )  

	-----------------------------------------------------------------------------------------	
	IF (@psValor = '' OR @psValor IS NULL)  
		SELECT  TOP 500  
				  ClaUbicacion	= ClaUbicacion  
				, NomUbicacion	= CASE @pnModoSel	WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(150), ClaUbicacion))) + '-' + NombreUbicacion 
													ELSE NombreUbicacion END  
				, OrdenTipo
		FROM	@TUbicaciones
		ORDER BY OrdenTipo,ClaUbicacion,NomUbicacion  
	ELSE  
	IF @pnTipo  IN (1,99)   
		SELECT TOP 500  
				  ClaUbicacion	= ClaUbicacion  
				, NomUbicacion	= CASE @pnModoSel	WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(150), ClaUbicacion))) + '-' + NombreUbicacion 
													ELSE NombreUbicacion END  
				, OrdenTipo
		FROM	@TUbicaciones
		WHERE	ClaUbicacion = @psValor     
		ORDER BY OrdenTipo,ClaUbicacion,NomUbicacion 
	ELSE  
	BEGIN  
		SELECT TOP 500  
				  ClaUbicacion = ClaUbicacion  
				, NomUbicacion =  CASE @pnModoSel	WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(150), ClaUbicacion))) + '-' + NombreUbicacion 
													ELSE NombreUbicacion END  
				, OrdenTipo
		FROM	@TUbicaciones
		WHERE	NombreUbicacion LIKE '%' + ltrim(rtrim(@psValor)) + '%' 
		ORDER BY OrdenTipo,ClaUbicacion,NomUbicacion 
	END
	
	SET NOCOUNT OFF
END