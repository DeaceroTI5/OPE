USE Operacion
GO
--****************************************************--
--* Objeto:		CmqSch.CmqConCatBeneficiarioCmb
--* Autor:
--* Fecha:
--* EXEC OpeSch.OpeConBeneficiarioCmb @pnClaCUP=6,@psNombreBeneficiario=''
--****************************************************--
ALTER PROCEDURE OpeSch.OpeConBeneficiarioCmb
	@psValor				VARCHAR(100),		-- Texto a Buscar  
	@pnTipo					INT,				-- 1=Buscar por la ClaveXxxxx  
	@pnModoSel				INT = 1,			-- 1=Retorno Clave - Descripcion   <>1  Descripcion  
	@pnBajasSn				INT = 0 ,
	@pnClaCUP				INT,  
	@pnClaUbicacion			INT = NULL
AS 
BEGIN
SET NOCOUNT ON
	
 	DECLARE @nClaEmpresa INT
 	
 	SELECT	@nClaEmpresa = ClaEmpresa
 	FROM	OpeSch.TiCatUbicacionVw (NOLOCK)
 	WHERE	ClaUbicacion = @pnClaUbicacion
	
	IF (@psValor = '' OR @psValor IS NULL)  
	BEGIN
		SELECT	TOP 500  
				ClaBeneficiario = ClaBeneficiario, 
				NomBeneficiario = CASE @pnModoSel WHEN 1 THEN CONVERT(VARCHAR,ClaBeneficiario) + ' - ' + CONVERT(VARCHAR,ClaDepartamento) + ' - ' + RTRIM(LTRIM(NombreBeneficiario)) ELSE NombreBeneficiario END, 
				Clave = ClaBeneficiario
		FROM	OpeSch.ConCatBeneficiarioVw
		WHERE	(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1)  
		AND		ClaCUP = @pnClaCUP
		AND		ClaEmpresa = @nClaEmpresa
		ORDER BY CASE WHEN @pnModoSel = 1 THEN ClaBeneficiario END,
				 CASE WHEN @pnModoSel = 2 THEN NombreBeneficiario END  
	END
	ELSE
	BEGIN
		IF @pnTipo  IN (1,99)   
			SELECT  TOP 500  
					ClaBeneficiario = ClaBeneficiario, 
					NomBeneficiario = CASE @pnModoSel WHEN 1 THEN CONVERT(VARCHAR,ClaBeneficiario) + ' - ' + CONVERT(VARCHAR,ClaDepartamento) + ' - ' + RTRIM(LTRIM(NombreBeneficiario)) ELSE NombreBeneficiario END, 
					Clave = ClaBeneficiario
			FROM	OpeSch.ConCatBeneficiarioVw
			WHERE	(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1)  
			AND		ClaCUP = @pnClaCUP
			AND		ClaEmpresa = @nClaEmpresa
			AND		ClaBeneficiario = @psValor  
			ORDER BY CASE WHEN @pnModoSel = 1 THEN ClaBeneficiario END,
					 CASE WHEN @pnModoSel = 2 THEN NombreBeneficiario END  
		ELSE  
		BEGIN  
			SELECT  TOP 500  
					ClaBeneficiario = ClaBeneficiario, 
					NomBeneficiario = CASE @pnModoSel WHEN 1 THEN CONVERT(VARCHAR,ClaBeneficiario) + ' - ' + CONVERT(VARCHAR,ClaDepartamento) + ' - ' + RTRIM(LTRIM(NombreBeneficiario)) ELSE NombreBeneficiario END, 
					Clave = ClaBeneficiario
			FROM	OpeSch.ConCatBeneficiarioVw
			WHERE	(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1)  
			AND		ClaCUP = @pnClaCUP
			AND		ClaEmpresa = @nClaEmpresa
			AND		NombreBeneficiario LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'
			ORDER BY CASE WHEN @pnModoSel = 1 THEN ClaBeneficiario END,
					 CASE WHEN @pnModoSel = 2 THEN NombreBeneficiario END  
		END  
	END

	SET NOCOUNT OFF
END