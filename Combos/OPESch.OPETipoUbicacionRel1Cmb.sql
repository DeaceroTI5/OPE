USE Operacion
GO
ALTER PROCEDURE OPESch.OPETipoUbicacionRel1Cmb  
	@psValor			VARCHAR(100),		-- Texto a Buscar  
	@pnIncluirTodosSN	TINYINT = 0,
	@pnTipo				INT,				-- 1=Buscar por la ClaveXxxxx  
	@pnModoSel			INT = 1,			-- 1=Retorno Clave - Descripcion   <>1  Descripcion  
	@pnBajasSn			INT = 0  
As    
BEGIN
	SET NOCOUNT ON

	DECLARE @tCatTipoUbicacion	TABLE(
		  ClaTipoUbicacion		INT
		, NombreTipoUbicacion	VARCHAR(50)
	)

	IF ISNULL(@pnIncluirTodosSN,0) = 1
		INSERT INTO @tCatTipoUbicacion (ClaTipoUbicacion, NombreTipoUbicacion)
		SELECT	  ClaTipoUbicacion		= -1
				, NombreTipoUbicacion	= 'Todos'

	INSERT INTO @tCatTipoUbicacion (ClaTipoUbicacion, NombreTipoUbicacion)
	SELECT	  ClaTipoUbicacion		
			, NombreTipoUbicacion	
	FROM	OPESch.OpeTiCatTipoUbicacionVw
	WHERE	( ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1 )  

	-----------------------------------------------------------------------------------------	
	IF (@psValor = '' OR @psValor IS NULL)  
		SELECT  TOP 500  
				  ClaTipoUbicacion= ClaTipoUbicacion  
				, NomTipoUbicacion=  CASE @pnModoSel	WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(150), ClaTipoUbicacion))) + '-' + NombreTipoUbicacion 
															ELSE NombreTipoUbicacion END  
		FROM	@tCatTipoUbicacion
		ORDER BY CASE  WHEN @pnModoSel = 1 THEN   ClaTipoUbicacion END,
		CASE  WHEN  @pnModoSel = 2 THEN  NombreTipoUbicacion END  
 
	ELSE  
	IF @pnTipo  IN (1,99)   
		SELECT  TOP 500  
				  ClaTipoUbicacion= ClaTipoUbicacion  
				, NomTipoUbicacion=  CASE @pnModoSel	WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(150), ClaTipoUbicacion))) + '-' + NombreTipoUbicacion 
															ELSE NombreTipoUbicacion END  
		FROM	@tCatTipoUbicacion
		WHERE	ClaTipoUbicacion = @psValor    
		ORDER BY CASE  WHEN @pnModoSel = 1 THEN   ClaTipoUbicacion END,
		CASE  WHEN  @pnModoSel = 2 THEN  NombreTipoUbicacion END  
	ELSE  
	BEGIN    
		SELECT  TOP 500  
				  ClaTipoUbicacion= ClaTipoUbicacion  
				, NomTipoUbicacion=  CASE @pnModoSel	WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(150), ClaTipoUbicacion))) + '-' + NombreTipoUbicacion 
															ELSE NombreTipoUbicacion END  
		FROM	@tCatTipoUbicacion
		WHERE	NombreTipoUbicacion LIKE '%' + ltrim(rtrim(@psValor)) + '%'   
		ORDER BY CASE  WHEN @pnModoSel = 1 THEN   ClaTipoUbicacion END,
		CASE  WHEN  @pnModoSel = 2 THEN  NombreTipoUbicacion END		  
	END

	SET NOCOUNT OFF
END