USE Operacion
GO
--'OPESch.OpeObtieneFirmaSel'
GO
ALTER PROCEDURE OPESch.OpeObtieneFirmaSel
 @pnNumVersion		INT
,@pnClaUbicacion	INT
,@pnIdCertificado	INT
,@psClaIdioma	    VARCHAR(50) = 'es-MX'
AS
BEGIN 
	SET NOCOUNT ON
			
	DECLARE @nMuestraLogDeaVerde  INT,
			@nMuestraLogCIM		  INT,
			@nDepartamentoDefault INT,
			@sNormaISO			  VARCHAR(200),
			@nMuestraImgUSA		  TINYINT = 0,
			@nMuestraImgDWR		  INT = 0,
			@nMuestraImgWWR		  INT = 0

	SELECT	@sNormaISO = UPPER(CASE WHEN @psClaIdioma = 'es-MX' THEN sValor1 ELSE sValor2 END)
	FROM	OpeSch.OpeTiCatConfiguracionVw
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		ClaSistema = 246
	AND		ClaConfiguracion = 246131

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

	--IF @pnClaUbicacion IN (65, 267)
	--	SELECT @nMuestraImgUSA = 1
	--ELSE
	--	SELECT @nMuestraImgUSA = 0

	DECLARE @tDatos TABLE
	(	
		ClaDepartamento		INT,
		Firma				VARBINARY(MAX),
		PuestoDesc			VARCHAR(250),
		MuestraLogDeaVerde	INT,
		MuestraLogCIM		INT,
		NombreUsuario		VARCHAR(250)
	)
	
	SET		@nMuestraLogCIM			= OpeSch.OpeObtenerConfigNumericaFn(@pnClaUbicacion, 1271022, 1)
	SET		@nDepartamentoDefault	= OpeSch.OpeObtenerConfigNumericaFn(@pnClaUbicacion, 1270183, 1)
	SET		@nMuestraLogDeaVerde	= OpeSch.OpeObtenerConfigNumericaFn(@pnClaUbicacion, 1271021, 1)
	SELECT	@nMuestraLogDeaVerde	= ISNULL(@nMuestraLogDeaVerde,0)
	
--	IF ISNULL(@pnIdCertificado,-1) > 0 
--	BEGIN
			
		INSERT INTO @tDatos
		(	ClaDepartamento ,
			Firma ,
			PuestoDesc ,
			MuestraLogDeaVerde ,
			MuestraLogCIM ,
			NombreUsuario	)
		SELECT	TOP (1) ptc.ClaDepartamento,
				ISNULL(pccuf.Firma, NULL),
				CASE WHEN @psClaIdioma = 'es-MX' THEN LTRIM(RTRIM(pccuf.PuestoDesc))
				 	 WHEN @psClaIdioma = 'en-US' THEN LTRIM(RTRIM(PuestoDescIngles))
				END AS PuestoDesc,
				@nMuestraLogDeaVerde AS MuestraLogDeaVerde, 
				@nMuestraLogCIM	AS MuestraLogCIM,
				LTRIM((RTRIM(ISNULL(NombreUsuario,'')) + ' ' + RTRIM(ISNULL(ApellidoPaterno,'')) + ' ' + RTRIM(ISNULL(ApellidoMaterno,'')))) AS NombreUsuario
		FROM	OpeSch.OpeOpcTraCertificadoVw AS ptc WITH(nolock)
		JOIN	OpeSch.OpeOpcCatFirmasCertificadosVw AS pccuf WITH(nolock)ON ptc.ClaDepartamento = pccuf.ClaDepartamento AND pccuf.BajaLogica = 0
		AND		pccuf.ClaUbicacion = ptc.ClaUbicacionIndustrial
		AND		pccuf.Firma IS NOT NULL
		JOIN	OpeSch.OpeTiCatUsuarioVw AS tcuv WITH(nolock)ON pccuf.ClaUsuario = tcuv.ClaUsuario
		WHERE	ptc.ClaUbicacion = @pnClaUbicacion
		AND		ptc.IdCertificado = @pnIdCertificado
	
--	END
 
	IF NOT EXISTS (	SELECT 1 FROM @tDatos )
	BEGIN
		INSERT INTO @tDatos
		(	ClaDepartamento ,
			Firma ,
			PuestoDesc ,
			MuestraLogDeaVerde ,
			MuestraLogCIM ,
			NombreUsuario	)
		SELECT	TOP (1) pccuf.ClaDepartamento,
				ISNULL(pccuf.Firma, NULL) AS Firma,
				CASE WHEN @psClaIdioma = 'es-MX' THEN LTRIM(RTRIM(pccuf.PuestoDesc))
					 WHEN @psClaIdioma = 'en-US' THEN LTRIM(RTRIM(PuestoDescIngles))
				END AS PuestoDesc,
				@nMuestraLogDeaVerde AS MuestraLogDeaVerde, 
				@nMuestraLogCIM	AS MuestraLogCIM,
				(LTRIM(RTRIM(ISNULL(NombreUsuario,'')) + ' ' + RTRIM(ISNULL(ApellidoPaterno,'')) + ' ' + RTRIM(ISNULL(ApellidoMaterno,'')))) AS NombreUsuario
		FROM	OpeSch.OpeOpcCatFirmasCertificadosVw AS pccuf WITH(nolock)
		JOIN	OpeSch.OpeTiCatUsuarioVw AS tcuv WITH(nolock)ON pccuf.ClaUsuario = tcuv.ClaUsuario
		WHERE	pccuf.ClaUbicacion = @pnClaUbicacion
		AND		pccuf.ClaDepartamento = @nDepartamentoDefault
		AND		pccuf.BajaLogica = 0
	END
	
	IF EXISTS ( SELECT 1 FROM @tDatos )
	BEGIN
		SELECT	ClaDepartamento,
				ISNULL(Firma, NULL) AS Firma,
				PuestoDesc,
				MuestraLogDeaVerde,
				MuestraLogCIM,
				NombreUsuario,
				@sNormaISO AS NormaISO,
				@nMuestraImgUSA AS MuestraImgUSA,
				@nMuestraImgDWR AS MuestraImgDWR,
				@nMuestraImgWWR AS MuestraImgWWR	
		FROM	@tDatos AS td
	END
	ELSE
	BEGIN
		SELECT	0 AS ClaDepartamento,
				NULL AS Firma,
				'' AS PuestoDesc,
				@nMuestraLogDeaVerde AS MuestraLogDeaVerde,
				0 AS MuestraLogCIM,
				'' AS NombreUsuario,
			    @sNormaISO AS NormaISO,
				@nMuestraImgUSA AS MuestraImgUSA,
				@nMuestraImgDWR AS MuestraImgDWR,
				@nMuestraImgWWR AS MuestraImgWWR	
	END
	
	SET NOCOUNT ON
END