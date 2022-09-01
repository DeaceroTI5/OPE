USE Operacion
GO
ALTER PROCEDURE OpeSch.OPEUbicacionOrigenCmb
		@psValor	VARCHAR(100),		-- Texto a Buscar  
		@pnTipo		INT,				-- 1=Buscar por la ClaveXxxxx  
		@pnModoSel	INT = 1,			-- 1=Retorno Clave - Descripcion   <>1  Descripcion  
		@pnBajasSn	INT = 0,
		@pnwtk0		INT = NULL
AS
BEGIN
	SET NOCOUNT ON

	IF (@psValor = '' OR @psValor IS NULL)  
	BEGIN
		SELECT  TOP 500  
				  ClaUbicacion = ClaUbicacion 
				, NomUbicacion =  CASE @pnModoSel WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(10), ClaUbicacion))) + '-' + NomUbicacion ELSE NomUbicacion END  
		FROM	OpeSch.OpeTiCatUbicacionVw
		WHERE	ClaUbicacion <> @pnwtk0
		AND		(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1)  
		ORDER BY CASE  WHEN @pnModoSel = 1 THEN   ClaUbicacion END,
					CASE  WHEN  @pnModoSel = 2 THEN  NomUbicacion END  
	END
	ELSE  
	BEGIN
		IF @pnTipo  IN (1,99)   
			SELECT TOP 500  
					  ClaUbicacion= ClaUbicacion  
					, NomUbicacion =  CASE @pnModoSel WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(10), ClaUbicacion))) + '-' + NomUbicacion ELSE NomUbicacion END  
			FROM	OpeSch.OpeTiCatUbicacionVw
			WHERE	ClaUbicacion <> @pnwtk0
			AND		(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1)  
			AND		ClaUbicacion = @psValor    
			ORDER BY CASE  WHEN @pnModoSel = 1 THEN   ClaUbicacion END,
						CASE  WHEN  @pnModoSel = 2 THEN  NomUbicacion END  
		ELSE  
		BEGIN  
			SELECT TOP 500  
					  ClaUbicacion = ClaUbicacion 
					, NomUbicacion =  CASE @pnModoSel WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(10), ClaUbicacion))) + '-' + NomUbicacion ELSE NomUbicacion END  
			FROM	OpeSch.OpeTiCatUbicacionVw
			WHERE	ClaUbicacion <> @pnwtk0
			AND		(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1)  
			AND		NomUbicacion LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'
			ORDER BY CASE  WHEN @pnModoSel = 1 THEN   ClaUbicacion END,
						CASE  WHEN  @pnModoSel = 2 THEN  NomUbicacion END  
		END  
	END
	
	SET NOCOUNT ON
END