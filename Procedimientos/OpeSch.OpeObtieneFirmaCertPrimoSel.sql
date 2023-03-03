USE Operacion
GO
-- 'OpeSch.OpeObtieneFirmaCertPrimoSel'
GO
ALTER PROCEDURE OpeSch.OpeObtieneFirmaCertPrimoSel
	@pnClaUbicacion		INT		
	,@pnClaArticulo		INT
	,@psClavesRollo		VARCHAR(MAX)
	,@psClaIdioma	    VARCHAR(50) = 'es-MX'
AS
BEGIN 
	SET NOCOUNT ON
			
	SET NOCOUNT ON
	DECLARE @xmlOpmRollo XML
	DECLARE @xmlResult XML
	DECLARE @nFirma VARBINARY(MAX)
	DECLARE @tbClavesRollo AS TABLE(Id INT IDENTITY(1, 1),
									IdOpm INT,
									ClaveRollo VARCHAR(20))

	DECLARE @nMuestraImgUSA		  TINYINT = 0,
			@nMuestraImgDWR		  TINYINT = 0,
			@nMuestraImgWWR		  TINYINT = 0


	--IF @pnClaUbicacion IN (65, 267)
	--	SELECT @nMuestraImgUSA = 1
	--ELSE
	--	SELECT @nMuestraImgUSA = 0

	SELECT	@nMuestraImgWWR = nValor1
	FROM	OpeSch.OpeTiCatConfiguracionVw
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		ClaSistema = 127
	AND		ClaConfiguracion = 1271232

	SELECT	@nMuestraImgDWR = nValor1
	FROM	OpeSch.OpeTiCatConfiguracionVw
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		ClaSistema = 127
	AND		ClaConfiguracion = 1271233

	SELECT	@nMuestraImgUSA = nValor1
	FROM	OpeSch.OpeTiCatConfiguracionVw
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		ClaSistema = 127
	AND		ClaConfiguracion = 1271234


	DECLARE @tbResult TABLE(
		ClaDepartamento		INT,
		PuestoDesc			VARCHAR(250),
		MuestraLogDeaVerde	INT,
		MuestraLogCIM		INT,
		NombreUsuario		VARCHAR(250)
	)
 
	IF @psClavesRollo = 'JOBDigitalizaciondocumentos'
	BEGIN
		SELECT	@psClavesRollo		= ClavesRollo 
		FROM	OPESch.OPETmpDocDigitalizados WITH(NOLOCK)
		WHERE	ClaUbicacionOrigen	= @pnClaUbicacion 
		AND		ClaArticulo			= @pnClaArticulo
	END
 
	SELECT	@xmlOpmRollo = @psClavesRollo 
	INSERT  INTO @tbClavesRollo
	SELECT 	IdOpm = t.value('./@IdOpm', 'INT'),
			ClaveRollo =  rtrim(t.value('./@ClaveRollo', 'varchar(20)'))
	FROM 	@xmlOpmRollo.nodes('//row')x(t) 
 
 
	SELECT TOP 1 @xmlResult = CASE WHEN @psClaIdioma = 'es-Mx' THEN A.DatosXmlEsp ELSE A.DatosXmlIng END,
				 @nFirma = Firma1
	FROM OpeSch.OpeTraInformacionCertificado A WITH(NOLOCK)	
	INNER JOIN @tbClavesRollo B 
	 ON A.IdOpm = B.IdOpm
	 AND A.ClaveRollo = B.ClaveRollo
	WHERE A.ClaUbicacion = @pnClaUbicacion
	AND A.ClaArticulo = @pnClaArticulo
	AND ISNULL(A.BajaLogica,0) = 0
	
	
	INSERT INTO @tbResult
	EXEC OpeSch.OpeObtenDatosXmlProc
		@xml				= @xmlResult,
		@psTabla			= 'Firma'
		

	----------------------------------------------------------------------------
	DECLARE	 @nMuestraLogDeaVerde	INT			 
			,@sNormaISO				VARCHAR(200) 
			
			
	EXEC OpeSch.OpeObtieneConfiguracionCertificadosOtUbic
		 @pnClaUbicacionOrigen	= @pnClaUbicacion
		,@psClaIdioma			= @psClaIdioma
		,@pnMuestraLogDeaVerde  = @nMuestraLogDeaVerde	OUTPUT
		,@psNormaISO			= @sNormaISO			OUTPUT					
	----------------------------------------------------------------------------
	
	/*Resultado*/
	IF EXISTS	(	SELECT	1 FROM	@tbResult)
	BEGIN
		SELECT
			ClaDepartamento,
			@nFirma AS Firma,
			PuestoDesc,
			ISNULL(@nMuestraLogDeaVerde,0) AS MuestraLogDeaVerde,
			MuestraLogCIM,
			NombreUsuario,
			@sNormaISO AS NormaISO,
			@nMuestraImgUSA AS MuestraImgUSA,
			@nMuestraImgDWR AS MuestraImgDWR,
			@nMuestraImgWWR AS MuestraImgWWR	
		FROM @tbResult
	END
	ELSE
	BEGIN
		SELECT
			0 AS ClaDepartamento,
			@nFirma AS Firma,
			'' AS PuestoDesc,
			ISNULL(@nMuestraLogDeaVerde,0) AS MuestraLogDeaVerde,
			0 AS MuestraLogCIM,
			'' AS NombreUsuario,
			@sNormaISO AS NormaISO,
			@nMuestraImgUSA AS MuestraImgUSA,
			@nMuestraImgDWR AS MuestraImgDWR,
			@nMuestraImgWWR AS MuestraImgWWR		  

	END		
			
	SET NOCOUNT ON
END