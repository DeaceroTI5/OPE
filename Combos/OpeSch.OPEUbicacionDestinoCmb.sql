USE Operacion
GO
ALTER PROCEDURE OpeSch.OPEUbicacionDestinoCmb
		@pnClaUbicacion INT,
		@psValor		VARCHAR(100),		-- Texto a Buscar  
		@pnTipo			INT,				-- 1=Buscar por la ClaveXxxxx  
		@pnModoSel		INT = 1,			-- 1=Retorno Clave - Descripcion   <>1  Descripcion  
		@pnBajasSn		INT = 0  	
AS
BEGIN
	SET NOCOUNT ON

	DECLARE   @psClaUbicaciones	VARCHAR(300) = ''
			, @nClaEmpresa		INT

	CREATE TABLE #CfgUbicaciones(
		  ID			INT IDENTITY(1,1),
		  ClaUbicacion	VARCHAR(8)
	)
	
	CREATE TABLE #TmpUbicaciones(
		  ID			INT IDENTITY(1,1),
		  ClaUbicacion	VARCHAR(8)
		, NomUbicacion	VARCHAR(50)
		, BajaLogica	TINYINT
	)

	SET @nClaEmpresa = 52 -- INGETEK

	SELECT	@psClaUbicaciones = sValor1
	FROM	OpeSch.OpeTiCatConfiguracionVw
	WHERE	ClaUbicacion		= @pnClaUbicacion
	AND		ClaSistema			= 127
	AND		ClaConfiguracion	= 1271221
	

	IF @psClaUbicaciones <> ''
	BEGIN
		INSERT INTO #CfgUbicaciones (ClaUbicacion)
		SELECT DISTINCT LTRIM(RTRIM(string))
		FROM OpeSch.OpeUtiSplitStringFn(@psClaUbicaciones, ',')
	END	

	INSERT INTO #TmpUbicaciones
	(
		  ClaUbicacion
		, NomUbicacion
		, BajaLogica
	)
	SELECT	  b.ClaUbicacion
			, b.NomUbicacion
			, b.BajaLogica
	FROM	#CfgUbicaciones a
	INNER JOIN OpeSch.OpeTiCatUbicacionVw b
	ON		a.ClaUbicacion = b.ClaUbicacion
	UNION
	SELECT  DISTINCT 
			  a.ClaUbicacion
			, a.NomUbicacion
			, a.BajaLogica
	FROM	OpeSch.OpeTiCatUbicacionVw a
--	LEFT JOIN #CfgUbicaciones b
--	ON		a.ClaUbicacion	= b.ClaUbicacion
	WHERE	ClaEmpresa		= @nClaEmpresa
--	AND		b.ClaUbicacion IS NULL

	------------------------------------------------------------------------------------
	IF (@psValor = '' OR @psValor IS NULL)  
	BEGIN
		SELECT  TOP 500  
				  ClaUbicacion = ClaUbicacion 
				, NomUbicacion =  CASE @pnModoSel WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(10), ClaUbicacion))) + '-' + NomUbicacion ELSE NomUbicacion END  
		FROM	#TmpUbicaciones
		WHERE	(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1)  
		ORDER BY CASE  WHEN @pnModoSel = 1 THEN   ClaUbicacion END,
					CASE  WHEN  @pnModoSel = 2 THEN  NomUbicacion END  
	END
	ELSE
	BEGIN
		IF @pnTipo  IN (1,99)   
			SELECT TOP 500  
					  ClaUbicacion= ClaUbicacion  
					, NomUbicacion =  CASE @pnModoSel WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(10), ClaUbicacion))) + '-' + NomUbicacion ELSE NomUbicacion END  
			FROM	#TmpUbicaciones
			WHERE	(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1)  
			AND		ClaUbicacion = @psValor    
			ORDER BY CASE  WHEN @pnModoSel = 1 THEN   ClaUbicacion END,
						CASE  WHEN  @pnModoSel = 2 THEN  NomUbicacion END  
		ELSE  
		BEGIN  
			SELECT TOP 500  
					  ClaUbicacion = ClaUbicacion 
					, NomUbicacion =  CASE @pnModoSel WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(10), ClaUbicacion))) + '-' + NomUbicacion ELSE NomUbicacion END  
			FROM	#TmpUbicaciones
			WHERE	(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1)  
			AND		NomUbicacion LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'
			ORDER BY CASE  WHEN @pnModoSel = 1 THEN   ClaUbicacion END,
						CASE  WHEN  @pnModoSel = 2 THEN  NomUbicacion END  
		END  
	END
	------------------------------------------------------------------------------------
	
	DROP TABLE #TmpUbicaciones, #CfgUbicaciones
	SET NOCOUNT ON
END