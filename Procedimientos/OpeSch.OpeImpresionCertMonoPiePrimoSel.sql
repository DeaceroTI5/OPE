USE Operacion
GO
-- 'OpeSch.OpeImpresionCertMonoPiePrimoSel'
GO
ALTER PROCEDURE OpeSch.OpeImpresionCertMonoPiePrimoSel
	@pnClaUbicacion			INT,
	@pnClaUbicacionOrigen	INT,
	@pnClaArticulo			INT,
	@pnIdOpm				INT,
	@psClaveRollo			VARCHAR(20),
	@psClaIdioma			VARCHAR(10),
	@psNombreCliente		VARCHAR(250),
	@psNombreUbicacion		VARCHAR(200),
	@pnKgsTotal				NUMERIC(22,4),
	@pnIdCertificado		INT,
	@pnIdFabricacion		INT,
	@pnIdViaje				INT,
	@pnIdPlanCarga			INT,
	@pnIdFactura			INT,
	@psNumeroFactura		VARCHAR(100),
	@psNomUnidad			VARCHAR(50)	
AS
BEGIN
	SET NOCOUNT ON
		
	DECLARE @xmlResult XML
	DECLARE @nFirma1 VARBINARY(MAX)
	DECLARE @nFirma2 VARBINARY(MAX)
	DECLARE @sRutaLogo VARCHAR(300)
			,@nMuestraNombreUbicacion TINYINT
			,@nMuestraLogCIM	TINYINT

	DECLARE @tResult TABLE(
		NombreUsuario1	  VARCHAR(250),
		PuestoUsuario1	  VARCHAR(250),
		NombreUsuario2	  VARCHAR(250),
		PuestoUsuario2	  VARCHAR(250)
	)		

	SELECT top 1 @xmlResult = CASE WHEN @psClaIdioma = 'es-Mx' THEN A.DatosXmlEsp ELSE A.DatosXmlIng END,
				 @nFirma1 = Firma1,
				 @nFirma2 = Firma2
	FROM OpeSch.OpeTraInformacionCertificado A WITH(NOLOCK)	
	where A.ClaUbicacion = @pnClaUbicacionOrigen
	 AND A.IdOpm = @pnIdOpm
	 AND A.ClaveRollo = @psClaveRollo
	 AND A.ClaArticulo = @pnClaArticulo
	 AND ISNULL(A.BajaLogica,0) = 0

	INSERT INTO @tResult
	EXEC OpeSch.OpeObtenDatosXmlProc
		@xml				= @xmlResult,
		@psTabla			= 'FirmasMono'

	----------------------------------------------------------------------------
	DECLARE	 @nMuestraLogDeaVerde	INT			 
			,@sNormaISO				VARCHAR(200) 
			
			
	EXEC OpeSch.OpeObtieneConfiguracionCertificadosOtUbic
		 @pnClaUbicacionOrigen	= @pnClaUbicacionOrigen
		,@psClaIdioma			= @psClaIdioma
		,@pnMuestraLogDeaVerde  = @nMuestraLogDeaVerde	OUTPUT
		,@psNormaISO			= @sNormaISO			OUTPUT					
	----------------------------------------------------------------------------	
	SELECT	@sRutaLogo = sValor1
	FROM	OpeSch.OpeTiCatConfiguracionVw
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		ClaSistema = 127
	AND		ClaConfiguracion = 1271235

	/*
	Logo_Deacero.png		-- Logo DeaAcero fondo Negro
	Logo_Deacero2.png		-- Logo DeaAcero fondo Blanco
	Logo_DeaceroSummit.png	-- Logo Summit
	*/

	IF @pnClaUbicacion = 300
		SET @sRutaLogo = @sRutaLogo + 'Logo_DeaceroSummit.png'
	ELSE
		SET @sRutaLogo = @sRutaLogo + 'Logo_Deacero.png'


	SELECT  @nMuestraNombreUbicacion = ISNULL(nValor1,1)
    FROM	OpeSch.OPETiCatConfiguracionVw 
    WHERE	ClaUbicacion      = @pnClaUbicacion 
    AND     ClaSistema        = 127 
    AND     ClaConfiguracion  = 1270206
    AND		BajaLogica        = 0

	SET		@nMuestraLogCIM	= OpeSch.OpeObtenerConfigNumericaFn(@pnClaUbicacion, 1271022, 1)
	
	DECLARE	 @sDireccion1		VARCHAR(300)
			,@sDireccion2		VARCHAR(300)	
			,@sNombreUsuario1	  VARCHAR(250)
			,@sPuestoUsuario1	  VARCHAR(250)
			,@sNombreUsuario2	  VARCHAR(250)
			,@sPuestoUsuario2	  VARCHAR(250)

	SELECT	
			@sDireccion1 = RTRIM(U.Direccion) + ' ' +
				RTRIM(U.Colonia) + ' ' +
				CASE @psClaIdioma WHEN 'es-Mx' THEN 'CP. ' ELSE 'ZP. ' END + U.CodigoPostal + ',',
			--	AS Direccion1,
			@sDireccion2 = RTRIM(U.Poblacion) + ' ' +
				CASE @psClaIdioma WHEN 'es-Mx' THEN 'Tel: ' ELSE 'Ph: ' END + RTRIM(ISNULL(U.Telefonos, '')) +
				CASE LEN(RTRIM(LTRIM(ISNULL(U.Fax, '')))) WHEN 0 THEN '' ELSE ' Fax: ' + RTRIM(LTRIM(U.Fax)) END,
			--	AS Direccion2,
			@sNombreUsuario1 = res.NombreUsuario1,
			@sPuestoUsuario1 = res.PuestoUsuario1,
			@sNombreUsuario2 = res.NombreUsuario2,
			@sPuestoUsuario2 = res.PuestoUsuario2
	FROM	OPMSch.TiCatUbicacionVw U WITH (NOLOCK),
			@tResult res
	WHERE	U.ClaUbicacion = @pnClaUbicacionOrigen
	


	SELECT
			@sDireccion1 AS Direccion1,
			@sDireccion2 AS Direccion2,
			@sNombreUsuario1 AS NombreUsuario1,
			@sPuestoUsuario1 AS PuestoUsuario1,
			@sNombreUsuario2 AS NombreUsuario2,
			@sPuestoUsuario2 AS PuestoUsuario2,
			@nFirma1 AS FirmaUsuario1,
			@nFirma2 AS FirmaUsuario2,
			NombreCliente = @psNombreCliente,
			NombreUbicacion = @psNombreUbicacion,
			KgsTotal = @pnKgsTotal,
			IdCertificado = @pnIdCertificado,
			IdFabricacion = @pnIdFabricacion,
			IdViaje = @pnIdViaje,
			IdPlanCarga = @pnIdPlanCarga,
			IdFactura = @pnIdFactura,
			NumeroFactura = @psNumeroFactura,
			NomUnidad = @psNomUnidad,
			ISNULL(@nMuestraLogDeaVerde,0) AS MuestraLogDeaVerde,
			@sNormaISO AS NormaISO,
			@sRutaLogo		AS RutaLogo,
			ISNULL(@nMuestraNombreUbicacion,1) AS MuestraNombreUbicacion,
			@nMuestraLogCIM	AS MuestraLogCIM


	SET NOCOUNT OFF
END