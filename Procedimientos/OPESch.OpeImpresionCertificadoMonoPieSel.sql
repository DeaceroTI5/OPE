USE Operacion
GO
--	EXEC SP_HELPTEXT 'OPESch.OpeImpresionCertificadoMonoPieSel'
GO
ALTER PROCEDURE OPESch.OpeImpresionCertificadoMonoPieSel
	@pnNumVersion		INT,
	@pnClaUbicacion		INT,
	@pnIdCertificado	INT,
	@pnIdOpm			INT,
	@psClaveRollo		VARCHAR(20),
	@psClaIdioma		VARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE	@nClaIdioma INT
	DECLARE @nClaDepartamento INT
	DECLARE @nClaUsuario1 INT
	DECLARE @bFirmaUsuario1 VARBINARY(MAX)
	DECLARE @sNombreUsuario1 VARCHAR(100)
	DECLARE @sPuestoUsuario1 VARCHAR(250)
	DECLARE @bFirmaUsuario2 VARBINARY(MAX)
	DECLARE @sNombreUsuario2 VARCHAR(100)
	DECLARE @sPuestoUsuario2 VARCHAR(250)
	DECLARE @nUbicacionIndustrial INT
	DECLARE	@sNormaISO	VARCHAR(200)
	DECLARE @nMuestraLogDeaVerde INT,
			@sRutaLogo			VARCHAR(300),
			@nMuestraNombreUbicacion TINYINT,
			@nMuestraLogCIM		INT

	
	IF (ISNULL(@psClaIdioma, '') = 'es-MX')
	BEGIN
		SELECT @nClaIdioma = 5
	END
	ELSE IF (ISNULL(@psClaIdioma, '') = 'en-US')
	BEGIN
		SELECT @nClaIdioma = 0
	END
 
	SELECT	@nClaIdioma = ISNULL(@nClaIdioma, 5)
	
	SELECT	@nUbicacionIndustrial = ClaUbicacionIndustrial
	FROM	OpeSch.OpeOpcTraCertificadoVw WITH(NOLOCK)
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		IdCertificado = @pnIdCertificado
	
	--*Obtener las firmas de los usuarios configurados para el departamento
	SELECT	@nClaDepartamento = ClaDepartamento
	FROM	OpeSch.OpeOpcTraRolloVw WITH(nolock)
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		IdOpm = @pnIdOpm
	AND		ClaveRollo = @psClaveRollo
	
	SELECT	@sNormaISO = UPPER(CASE WHEN @psClaIdioma = 'es-MX' THEN sValor1 ELSE sValor2 END)
	FROM	OpeSch.OpeTiCatConfiguracionVw
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		ClaSistema = 246
	AND		ClaConfiguracion = 246131
	
	SET		@nMuestraLogDeaVerde = OpeSch.OpeObtenerConfigNumericaFn(@pnClaUbicacion, 1271021, 1)	
	SELECT	@nMuestraLogDeaVerde = ISNULL(@nMuestraLogDeaVerde,0)


	SELECT	@sRutaLogo = sValor1
	FROM	OpeSch.OpeTiCatConfiguracionVw
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		ClaSistema = 127
	AND		ClaConfiguracion = 1271235

	SELECT  @nMuestraNombreUbicacion = ISNULL(nValor1,1)
    FROM	OpeSch.OPETiCatConfiguracionVw 
    WHERE	ClaUbicacion      = @pnClaUbicacion 
    AND     ClaSistema        = 127 
    AND     ClaConfiguracion  = 1270206
    AND		BajaLogica        = 0

	SET		@nMuestraLogCIM			= OpeSch.OpeObtenerConfigNumericaFn(@pnClaUbicacion, 1271022, 1)

	/*
	Logo_Deacero.png		-- Logo DeaAcero fondo Negro
	Logo_Deacero2.png		-- Logo DeaAcero fondo Blanco
	Logo_DeaceroSummit.png	-- Logo Summit
	*/

	IF @pnClaUbicacion = 300
		SET @sRutaLogo = @sRutaLogo + 'Logo_DeaceroSummit.png'
	ELSE
		SET @sRutaLogo = @sRutaLogo + 'Logo_Deacero.png'


	--*Obtener el primer usuario de firmas
	SELECT	TOP 1
			@nClaUsuario1 = F.ClaUsuario,
			@bFirmaUsuario1 = F.Firma,
			@sNombreUsuario1 = RTRIM(U.NombreUsuario) + ' ' + RTRIM(U.ApellidoPaterno) + ' ' + RTRIM(U.ApellidoMaterno),
			@sPuestoUsuario1 = CASE @nClaIdioma WHEN 5 THEN F.PuestoDesc ELSE F.PuestoDescIngles END
	FROM	OpeSch.OpeOpcCatFirmasCertificadosVw F WITH(NOLOCK)
	INNER	JOIN OpeSch.OpeManCatDepartamentoVw depto WITH(NOLOCK) ON depto.ClaDepartamento = F.ClaDepartamento
	INNER	JOIN OpeSch.OpeTiCatUsuarioVw U WITH (NOLOCK) ON F.ClaUsuario = U.ClaUsuario
	WHERE	F.ClaUbicacion = @nUbicacionIndustrial
	AND		F.ClaDepartamento = @nClaDepartamento
	AND		depto.BajaLogica = 0
	AND		F.BajaLogica = 0  
	AND		U.BajaLogica = 0
	ORDER	BY F.IdCertificadoUsuarioFirma
	
	--*Obtener el segundo usuario de firmas
	SELECT	@bFirmaUsuario2 = F.Firma,
			@sNombreUsuario2 = RTRIM(U.NombreUsuario) + ' ' + RTRIM(U.ApellidoPaterno) + ' ' + RTRIM(U.ApellidoMaterno),
			@sPuestoUsuario2 = CASE @nClaIdioma WHEN 5 THEN F.PuestoDesc ELSE F.PuestoDescIngles END
	FROM	OpeSch.OpeOpcCatFirmasCertificadosVw F WITH(NOLOCK)
	INNER	JOIN OpeSch.OpeManCatDepartamentoVw depto WITH(NOLOCK) ON depto.ClaDepartamento = F.ClaDepartamento
	INNER	JOIN OpeSch.OpeTiCatUsuarioVw U WITH(NOLOCK) ON F.ClaUsuario = U.ClaUsuario
	WHERE	F.ClaUbicacion = @nUbicacionIndustrial
	AND		F.ClaDepartamento = @nClaDepartamento
	AND		F.ClaUsuario != @nClaUsuario1
	AND		depto.BajaLogica = 0
	AND		F.BajaLogica = 0  
	AND		U.BajaLogica = 0
	ORDER	BY F.IdCertificadoUsuarioFirma
	

	DECLARE  @sNombreUbicacion VARCHAR(50)
			,@sDireccion1		VARCHAR(300)
			,@sDireccion2		VARCHAR(300)

	--*Regresar informacion del footer del reporte
	SELECT	@sNombreUbicacion = 'DEACERO S.A.P.I. DE C.V. ' + RTRIM(U.NombreUbicacion), --AS NombreUbicacion,
			@sDireccion1 = RTRIM(U.Direccion) + ' ' +
				RTRIM(U.Colonia) + ' ' +
				CASE @nClaIdioma WHEN 5 THEN 'CP. ' ELSE 'ZP. ' END + ISNULL(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(U.CodigoPostal,'CP.',''),'C.P.',''),'CP',''))),'') + ',',
			--	AS Direccion1,
			@sDireccion2 = RTRIM(U.Poblacion) + ' ' +
				CASE @nClaIdioma WHEN 5 THEN 'Tel: ' ELSE 'Ph: ' END + RTRIM(ISNULL(U.Telefonos, '')) +
				CASE LEN(RTRIM(LTRIM(ISNULL(U.Fax, '')))) WHEN 0 THEN '' ELSE ' Fax: ' + RTRIM(LTRIM(U.Fax)) END
			--	AS Direccion2,
	FROM	OpeSch.OpeTiCatUbicacionVw U WITH (NOLOCK)
	WHERE	U.ClaUbicacion = @nUbicacionIndustrial

	SELECT @sNombreUbicacion AS NombreUbicacion,
			@sDireccion1 AS Direccion1,
			@sDireccion2 AS Direccion2,
			@sNombreUsuario1 AS NombreUsuario1,
			@bFirmaUsuario1 AS FirmaUsuario1,
			@sPuestoUsuario1 AS PuestoUsuario1,
			@sNombreUsuario2 AS NombreUsuario2,
			@bFirmaUsuario2 AS FirmaUsuario2,
			@sPuestoUsuario2 AS PuestoUsuario2,
			@sNormaISO AS NormaISO,
			@nMuestraLogDeaVerde AS MuestraLogDeaVerde,
			@sRutaLogo		AS RutaLogo,
			ISNULL(@nMuestraNombreUbicacion,1) AS MuestraNombreUbicacion,
			ISNULL(@nMuestraLogCIM,0) AS MuestraLogCIM


	SET NOCOUNT OFF
END