 USE Operacion
 GO
--****************************************************--
--* Objeto:		CmqSch.CmqTesCuentaCUPCmb
--* Autor:
--* Fecha:
--* [CmqSch].[CmqTesCuentaCUPCmb] 5,null, ''
--* EXEC OpeSch.OpeTesCuentaCUPCmb 6, NULL
--****************************************************--
ALTER PROCEDURE OpeSch.OpeTesCuentaCUPCmb
	@psValor	VARCHAR(100),		-- Texto a Buscar  
	@pnTipo		INT,				-- 1=Buscar por la ClaveXxxxx  
	@pnModoSel	INT = 1,			-- 1=Retorno Clave - Descripcion   <>1  Descripcion  
	@pnBajasSn	INT = 0 ,
	@pnClaCUP	INT,
	@psNumCuentaCUP	VARCHAR(50) = NULL
AS 
BEGIN
	SET NOCOUNT ON
	
	/*
	IF @psNumCuentaCUP IS NULL
	BEGIN
		SET @psNumCuentaCUP = ''
	END
		
	SELECT	ClaCuentaCUP, 
			NomBanco AS NomCuentaCUP
			NumCuentaCUP,
	FROM	OpeSch.OpeTesCatCuentaCUPVw  WITH (NOLOCK) 
	WHERE	ISNULL(BajaLogica,0) != 1 
	AND		ClaCUP = @pnClaCUP --OR @claCUP IS NULL)
	AND		(NumCuentaCUP LIKE '%' + @psNumCuentaCUP + '%' OR @psNumCuentaCUP = '')
	ORDER BY ClaCUP
	*/

	IF (@psValor = '' OR @psValor IS NULL)  
	BEGIN
		SELECT  TOP 500  
				ClaCuentaCUP = ClaCuentaCUP,
				NomCuentaCUP = CASE @pnModoSel WHEN 1 THEN CONVERT(VARCHAR,ClaCuentaCUP) + ' - ' + RTRIM(LTRIM(NomBanco)) ELSE NomBanco END, 
				Clave = ClaCuentaCUP
		FROM	OpeSch.OpeTesCatCuentaCUPVw
		WHERE	(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1) 
		AND		ClaCUP = @pnClaCUP
		ORDER BY CASE WHEN @pnModoSel = 1 THEN ClaCuentaCUP END,
				 CASE WHEN @pnModoSel = 2 THEN NomBanco END  
	END
	ELSE
	BEGIN
		IF @pnTipo  IN (1,99)   
			SELECT  TOP 500  
					ClaCuentaCUP = ClaCuentaCUP,
					NomCuentaCUP = CASE @pnModoSel WHEN 1 THEN CONVERT(VARCHAR,ClaCuentaCUP) + ' - ' + RTRIM(LTRIM(NomBanco)) ELSE NomBanco END, 
					Clave = ClaCuentaCUP
			FROM	OpeSch.OpeTesCatCuentaCUPVw
			WHERE	(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1) 
			AND		ClaCUP = @pnClaCUP
			AND		ClaCuentaCUP = @psValor  
			ORDER BY CASE WHEN @pnModoSel = 1 THEN ClaCuentaCUP END,
					 CASE WHEN @pnModoSel = 2 THEN NomBanco END  
		ELSE  
		BEGIN  
			SELECT  TOP 500  
					ClaCuentaCUP = ClaCuentaCUP,
					NomCuentaCUP = CASE @pnModoSel WHEN 1 THEN CONVERT(VARCHAR,ClaCuentaCUP) + ' - ' + RTRIM(LTRIM(NomBanco)) ELSE NomBanco END, 
					Clave = ClaCuentaCUP
			FROM	OpeSch.OpeTesCatCuentaCUPVw
			WHERE	(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1) 
			AND		ClaCUP = @pnClaCUP
			AND		NomBanco LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'
			ORDER BY CASE WHEN @pnModoSel = 1 THEN ClaCuentaCUP END,
					 CASE WHEN @pnModoSel = 2 THEN NomBanco END 
		END  
	END

	SET NOCOUNT OFF
END