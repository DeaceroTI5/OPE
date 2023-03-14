USE Operacion
GO
-- 'OPESch.OpeObtieneFirmaSel'
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
			@nMuestraNombreUbicacion TINYINT,
			@nMuestraImgUSA		  TINYINT = 0,
			@nMuestraImgDWR		  TINYINT = 0,
			@nMuestraImgWWR		  TINYINT = 0,
			@sRutaLogo				VARCHAR(300),
			@nMuestraNomEmpresaUSA TINYINT = 0,
			@nOcultarOPM		TINYINT = 0,
			@nOcultarCarrete	TINYINT = 0
			
	SELECT	@sNormaISO = UPPER(CASE WHEN @psClaIdioma = 'es-MX' THEN sValor1 ELSE sValor2 END)
	FROM	OpeSch.OpeTiCatConfiguracionVw
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		ClaSistema = 246
	AND		ClaConfiguracion = 246131

	SELECT  @nMuestraNombreUbicacion = ISNULL(nValor1,1)
    FROM	OpeSch.OPETiCatConfiguracionVw 
    WHERE	ClaUbicacion      = @pnClaUbicacion 
    AND     ClaSistema        = 127 
    AND     ClaConfiguracion  = 1270206
    AND		BajaLogica        = 0

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

	SELECT	@sRutaLogo = sValor1
	FROM	OpeSch.OpeTiCatConfiguracionVw
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		ClaSistema = 127
	AND		ClaConfiguracion = 1271235


	SELECT	@nMuestraNomEmpresaUSA = nValor1
	FROM	OpeSch.OpeTiCatConfiguracionVw
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		ClaSistema = 127
	AND		ClaConfiguracion = 1271236

	SELECT	@nOcultarOPM = nValor1,
			@nOcultarCarrete = nValor2
	FROM	OpeSch.OpeTiCatConfiguracionVw
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		ClaSistema = 127
	AND		ClaConfiguracion = 1271237


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


	/*
	Logo_Deacero.png		-- Logo DeaAcero fondo Negro
	Logo_Deacero2.png		-- Logo DeaAcero fondo Blanco
	Logo_DeaceroSummit.png	-- Logo Summit
	*/

	IF @pnClaUbicacion = 300
	BEGIN
		SELECT @sRutaLogo = @sRutaLogo + 'Logo_DeaceroSummit.png'
				, @nMuestraImgUSA = 0			-- Bandera USA no se utiliza en Summit
	END
	ELSE
	BEGIN
		SELECT @sRutaLogo = @sRutaLogo + 'Logo_Deacero.png'
				,@nMuestraLogCIM = 0			-- Logo Calidad sólo se muestra en Summit
	END
	
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
	
	IF @@SERVERNAME = 'DEAINDNET02'	-- Prueba
		SELECT @nMuestraNombreUbicacion = 0


	IF EXISTS ( SELECT 1 FROM @tDatos )
	BEGIN
		SELECT	ClaDepartamento,
				ISNULL(Firma, NULL) AS Firma,
				PuestoDesc,
				MuestraLogDeaVerde,
				MuestraLogCIM,
				NombreUsuario,
				@sNormaISO AS NormaISO,
				ISNULL(@nMuestraNombreUbicacion,1) AS MuestraNombreUbicacion,
				@nMuestraImgUSA AS MuestraImgUSA,
				@nMuestraImgDWR AS MuestraImgDWR,
				@nMuestraImgWWR AS MuestraImgWWR,
				@sRutaLogo		AS RutaLogo,
				ISNULL(@nMuestraNomEmpresaUSA,0) AS MuestraNomEmpresaUSA,
				ISNULL(@nOcultarOPM,0) AS OcultarOPM,
				ISNULL(@nOcultarCarrete,0) AS OcultarCarrete
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
				ISNULL(@nMuestraNombreUbicacion,1) AS MuestraNombreUbicacion,
				@nMuestraImgUSA AS MuestraImgUSA,
				@nMuestraImgDWR AS MuestraImgDWR,
				@nMuestraImgWWR AS MuestraImgWWR,
				@sRutaLogo		AS RutaLogo,
				ISNULL(@nMuestraNomEmpresaUSA,0) AS MuestraNomEmpresaUSA,
				ISNULL(@nOcultarOPM,0) AS OcultarOPM,
				ISNULL(@nOcultarCarrete,0) AS OcultarCarrete
	END
	
	SET NOCOUNT ON
END