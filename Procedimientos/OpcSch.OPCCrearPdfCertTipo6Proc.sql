USE Operacion
GO
-- EXEC SP_HELPTEXT 'OpcSch.OPCCrearPdfCertTipo6Proc'
GO
ALTER PROCEDURE OpcSch.OPCCrearPdfCertTipo6Proc
@pnNumVersion		INT,
@pnClaUbicacion		INT,
@pnIdCertificado	INT,
@psRollos			VARCHAR(250),
@psNomPdf			VARCHAR(100),
@psRutaArchivo		VARCHAR(1000) OUTPUT,
@pnError			TINYINT = 0 OUTPUT,
@pxmlEncabezado		XML = NULL,
@psClaIdioma		VARCHAR(10) = 'es-MX',
@pnClaUsuarioMod    INT = NULL,
@psNombrePcMod      VARCHAR(64)= '',
@psRutaProcedimiento VARCHAR(250) = '',
@pnDebug			INT = 0
AS
BEGIN
	SET NOCOUNT ON

	-- AMLE/LFVR 18-12-2019: 
	-- Instruccion agregada por problemas en el env�o del archivo generado a partir de cambios en la seguridad de los servidores
	-- JGE/HAVS/AMLE 01-03-2022: 
	-- Se recibi� apoyo de JGE (Infraestructura BD) para que ya no sea necesario esa instrucci�n en los nuevos servidores y adem�s se agreg� una ruta especifica

	IF @pnClaUbicacion NOT IN ( 267 )	-- Planta WWR
		EXECUTE AS LOGIN = 'sa'

	SELECT	 @pnClaUsuarioMod   = ISNULL(@pnClaUsuarioMod,1)
			,@psNombrePcMod     = ISNULL(NULLIF(@psNombrePcMod,''),HOST_NAME())
	
	IF ISNULL(@psRutaProcedimiento, '') = ''
		SELECT @psRutaProcedimiento = 'OpcSch.OPCCrearPdfCertTipo6Proc'
    ELSE
		SELECT @psRutaProcedimiento = LTRIM(RTRIM(@psRutaProcedimiento)) + ' - ' + 'OpcSch.OPCCrearPdfCertTipo6Proc'

				
	DECLARE	@nClaCliente	INT,
			@sNombreCliente		VARCHAR(1000),
			@sNumeroFactura		VARCHAR(100),
			@sNombreCiudad		VARCHAR(1000),
			@nKgsTotal			NUMERIC(22,4),
			@sNombreUbicacion	VARCHAR(400),
			@sNomArticulo		VARCHAR(1000),
			@sNomUnidad			VARCHAR(100),
			@nIdViaje			INT,
			@nIdPlanCarga		INT,
			@sNota				VARCHAR(1000),
			@sRutaServidorRS	VARCHAR(1000),
			@sRutaReporte		VARCHAR(1000),
			@nIdFabricacion		INT,
			@sDireccion			VARCHAR(500),
			@nIdOpm				INT,
			@nClaArticulo		INT,
			@sIdEntSal			VARCHAR(100),
			@sEspecificacion	VARCHAR(100),
			@sDiametro			VARCHAR(100),
			@sLongitudTotal		VARCHAR(100),
			@sTipoCable			VARCHAR(100)
						
	
	DECLARE @nExisteArchivo INT,
			@nIndice INT,
			@sNomArchivo VARCHAR(1000),
			@sNomArchivoRSS VARCHAR(1000),
			@sRutaTemp VARCHAR(1000),
			@sComandoDinamico VARCHAR(8000),
			@sId VARCHAR(100),
			@bArchivo VARBINARY(MAX),
			@sRutaTempServidor		VARCHAR(1000)
	
	DECLARE @tbBinPDF TABLE(BlkColumn VARBINARY(MAX))
	
	SET @pnError = 0
	
	IF LTRIM(RTRIM(ISNULL(@psRollos,'')))<>''
	BEGIN
		SET @psRollos = REPLACE(@psRollos,'"','''')
	END
		
	SELECT	@sRutaServidorRS = LTRIM(RTRIM(sValor1)),
			@sRutaReporte = LTRIM(RTRIM(sValor2))
	FROM	OPCSch.OPCTiCatConfiguracionVw 
	WHERE	ClaSistema = 246
			AND ClaConfiguracion = 24601
			AND ClaUbicacion = @pnClaUbicacion

	DECLARE @sReporte VARCHAR(250)
				
	SELECT	@sReporte = LTRIM(RTRIM(sValor1))
	FROM	OPCSch.OPCTiCatConfiguracionVw 
	WHERE	ClaSistema = 246
			AND ClaConfiguracion = 24607
			AND ClaUbicacion = @pnClaUbicacion			
 
	--El nombre del reporte es fijo por tipo de certificado
	SELECT @sRutaReporte = @sRutaReporte + @sReporte
	
	SELECT  @sNombreUbicacion = CASE WHEN @psClaIdioma = 'es-MX' THEN sValor1 ELSE sValor2 END  
    FROM	OPCSch.OPCTiCatConfiguracionVw 
    WHERE	ClaUbicacion      = @pnClaUbicacion 
    AND     ClaSistema        = 127 
    AND     ClaConfiguracion  = 1270206
    AND		BajaLogica        = 0
	

	DECLARE @sClaFamiliaCfg	VARCHAR(500)
	
	SELECT  @sClaFamiliaCfg  = sValor1
    FROM	OPCSch.OPCTiCatConfiguracionVw
    WHERE	ClaUbicacion      = @pnClaUbicacion 
    AND     ClaSistema        = 127 
    AND     ClaConfiguracion  = 1271205
    AND		BajaLogica        = 0

	CREATE TABLE #TmpFamiliaCfg(
		ID					INT IDENTITY(1,1),
		ClaFamilia	VARCHAR(50)
	)
	
	IF ISNULL(@sClaFamiliaCfg,'') <> ''
	BEGIN
		INSERT INTO #TmpFamiliaCfg
		SELECT DISTINCT LTRIM(RTRIM(string))
		FROM OpcSch.OpcUtiSplitStringFn(@sClaFamiliaCfg, ',')
	END    
	
	 
	SELECT	@nClaCliente = ISNULL(cer.ClaCliente, 0),
			@sNombreCliente = ISNULL(cli.NombreCliente, ' '),
			@sNumeroFactura = ISNULL(cer.NumeroFactura, ' '),
			@sIdEntSal = ISNULL(CONVERT(VARCHAR(100), cer.IdEntSal), ' '),
			@sNombreCiudad = ISNULL(ciu.NombreCiudad, ' '),
			--@nKgsTotal = ISNULL(cer.KgsTotal, 0),
			@nKgsTotal =
						CASE	WHEN ISNULL(cfgFam.ClaFamilia,0) > 0 -- Si se encuentra dentro de la config. de Familias OPC
								THEN ISNULL(NULLIF(cer.Cantidad,0),
											-- si es 0 o Nulo calcula la cantidad mediante la funci�n
											ISNULL(NULLIF(OpcSch.OpcObtenCantidadCertificadoFn(cer.ClaUbicacion, cer.IdPlanCarga, cer.IdFabricacion, cer.IdFabricacionDet, cer.ClaArticulo),0),
													-- si es 0 o nulo devuelve el valor para Unidad de peso
													CASE	WHEN ciudadpedido.ClaPais = 1 
					 										THEN KgsTotal
					 										ELSE KgsTotal * 2.2046 -- Convertir a Libras
					 								END
													)
										  )
								ELSE	-- No se encuentra dentro de la config. de Familias OPC
									CASE	WHEN ciudadpedido.ClaPais = 1 
					 						THEN KgsTotal
					 						ELSE KgsTotal * 2.2046 -- Convertir a Libras
					 				END
					END, 			
			@sNombreUbicacion = CASE WHEN ISNULL(@sNombreUbicacion,'') <> '' THEN @sNombreUbicacion ELSE LTRIM(RTRIM(UPPER(ISNULL(ubi.NombreUbicacion, ' ')))) END,
			@sNomArticulo = ISNULL(art.ClaveArticulo,'') + ' - ' + ISNULL(art.NomArticulo, ' '),
			--@sNomUnidad = ISNULL(uni.NomUnidad, ' '),
			@sNomUnidad = CASE	WHEN ISNULL(cfgFam.ClaFamilia,0) > 0 -- Si se encuentra dentro de la config. de Familias OPC
								THEN	
										CASE	WHEN ISNULL(NULLIF(cer.Cantidad,0),
															-- si es 0 o Nulo calcula la cantidad mediante la funci�n
															ISNULL(NULLIF(OpcSch.OpcObtenCantidadCertificadoFn(cer.ClaUbicacion, cer.IdPlanCarga, cer.IdFabricacion, cer.IdFabricacionDet, cer.ClaArticulo),0),0)
															) <> 0		
												THEN ISNULL(uni.NomUnidad, ' ')	-- Si Cantidad no es cero o el calculo tampoco es cero muestra Unidad Longitud
												ELSE							-- Si Cantidad es cero muestra por Unidad de Peso
														CASE	WHEN ciudadpedido.ClaPais = 1	
																THEN 'Kg' 
																ELSE 'LBS'
														END
										END	
								ELSE	-- No se encuentra dentro de la config. de Familias OPC
										CASE	WHEN ciudadpedido.ClaPais = 1	
												THEN 'Kg' 
												ELSE 'LBS'
										END			
						END,
			@nIdViaje = ISNULL(cer.IdViaje, 0),
			@nIdPlanCarga = ISNULL(cer.IdPlanCarga, 0),
			@sNota = nc.Nota,
			@nIdFabricacion = ISNULL(cer.IdFabricacion, 0),
			@sDireccion = (RTRIM(ISNULL(ubi.Direccion,'')) + ' ' + 
						  RTRIM(ISNULL(ubi.Colonia,'')) + ' ' + 
						   CASE WHEN Ubi.CodigoPostal IS NOT NULL THEN CASE @psClaIdioma WHEN 'es-MX' THEN 'CP. ' ELSE 'ZP. ' END + 
						   ISNULL(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(ubi.CodigoPostal,'CP.',''),'C.P.',''),'CP',''))),'') ELSE '' END + ', ' + 
						   RTRIM(ISNULL(ubi.Poblacion,'')) + ' ' +
						   CASE WHEN ISNULL(ubi.Telefonos, '') <> '' THEN CASE @psClaIdioma WHEN 'es-MX' THEN 'Tel: ' ELSE CASE WHEN @pnClaUbicacion IN (65,267) THEN 'Ph: ' ELSE 'Ph: +52 ' END END +
						   RTRIM(ISNULL(ubi.Telefonos, '')) ELSE '' END +  
						   CASE LEN(RTRIM(LTRIM(ISNULL(Ubi.Fax, '')))) WHEN 0 THEN '' ELSE ' Fax: ' + RTRIM(LTRIM(ISNULL(Ubi.Fax,''))) END
						   ),						   
			@nIdOpm = ISNULL(cer.IdOPM, 0),
			@nClaArticulo = ISNULL(cer.ClaArticulo, 0),
			@sEspecificacion = ISNULL(CarEspecificacion.NomCaracteristica,''),
			@sDiametro = ISNULL(CarDiametro.NomCaracteristica,''),
			@sLongitudTotal = ISNULL(CarLongitudTotal.NomCaracteristica,''),
			@sTipoCable = ISNULL(CarTipoCable.NomCaracteristica,'')			
	FROM	OPCSch.OPCTraCertificado cer WITH(NOLOCK)
	LEFT	JOIN OPCSch.OPCArtCatArticuloVw art  WITH(NOLOCK) ON
			art.ClaTipoInventario = 1
			AND art.ClaArticulo = cer.ClaArticulo
	LEFT	JOIN OPCSch.OPCTiCatUbicacionVw ubi  WITH(NOLOCK) ON
			ubi.ClaUbicacion = cer.ClaUbicacion
	LEFT	JOIN OPCSch.OPCVtaCatClienteVw cli WITH(NOLOCK) ON
			cli.ClaCliente = cer.ClaCliente
	LEFT	JOIN OPCSch.OPCVtaCatCiudadVw ciu WITH(NOLOCK) ON
			ciu.ClaCiudad = cer.ClaCiudad
	LEFT	JOIN OPCSch.OPCArtCatUnidadVw uni WITH(NOLOCK) ON
			uni.ClaTipoInventario = 1
			AND uni.ClaUnidad = art.ClaUnidadBase
	--		AND uni.ClaUnidad = art.ClaUnidadProd
			AND uni.ClaTipoInventario = art.ClaTipoInventario
	LEFT	JOIN OPCSch.OPCCfgNotaCliente nc WITH(NOLOCK) ON
			nc.ClaUbicacion = cer.ClaUbicacion
			AND nc.ClaCliente = cer.ClaCliente
			AND nc.ClaArticulo = cer.ClaArticulo
			AND nc.BajaLogica = 0
	LEFT	JOIN OPCSCH.OpcCatConceptosCableFamilia AS ptccp WITH(nolock) ON 
			ptccp.ClaFamilia = art.ClaFamilia 
			AND ptccp.ClaUbicacion = cer.ClaUbicacion
	LEFT	JOIN OPCSch.OPCArtCatCaracteristicaVw CarDiametro		WITH(NOLOCK) ON 
			CarDiametro.ClaCaracteristica = ptccp.Diametro 
			And CarDiametro.ClaTipoInventario = 1
	LEFT	JOIN OPCSch.OPCArtCatCaracteristicaVw CarLongitudTotal	WITH(NOLOCK) ON 
			CarLongitudTotal.ClaCaracteristica = ptccp.LongitudTotal 
			And CarLongitudTotal.ClaTipoInventario = 1
	LEFT	JOIN OPCSch.OPCArtCatCaracteristicaVw CarEspecificacion WITH(NOLOCK) ON 
			CarEspecificacion.ClaCaracteristica = ptccp.Especificacion 
			And CarEspecificacion.ClaTipoInventario = 1
	LEFT	JOIN OPCSch.OPCArtCatCaracteristicaVw CarTipoCable		WITH(NOLOCK) ON 
			CarTipoCable.ClaCaracteristica = ptccp.TipoCable 
			And CarTipoCable.ClaTipoInventario = 1
	LEFT JOIN OPCSch.opcTraFabricacionVw a WITH(NOLOCK)
	ON		cer.IdFabricacion = a.IdFabricacion
	LEFT JOIN  OPcSch.opcVtaCatCiudadVw ciudadpedido(nolock)
	ON		a.ClaCiudad	= ciudadpedido.ClaCiudad	
	LEFT JOIN #TmpFamiliaCfg cfgFam
	ON		art.ClaFamilia = cfgFam.ClaFamilia	
	WHERE	cer.ClaUbicacion = @pnClaUbicacion
			AND cer.IdCertificado = @pnIdCertificado
			
	--Es un certificado de vista previa
	IF @pnIdCertificado < 0
	BEGIN
		DECLARE @nClaClienteXml INT
		
		SELECT  @sNombreCliente	= t.value('./@NombreCliente', 'VARCHAR(1000)'),
				@sNumeroFactura = t.value('./@NumeroFactura', 'VARCHAR(20)'),
				@nKgsTotal		= t.value('./@KgsTotal', 'NUMERIC(22,4)'),
				@sNomUnidad		= t.value('./@NomUnidad', 'VARCHAR(100)'),
				@sNombreCiudad	= t.value('./@NombreCiudad', 'VARCHAR(1000)'),
				@nIdViaje		= t.value('./@IdViaje', 'INT'),
				@nIdPlanCarga	= t.value('./@IdPlanCarga', 'INT'),
				@sNota			= t.value('./@Nota', 'VARCHAR(500)'),
				@nClaClienteXml = t.value('./@ClaCliente', 'INT')
		FROM	@pxmlEncabezado.nodes('//row')x(t)
		
		IF ISNULL(@nClaCliente,0) = 0
			SELECT @nClaCliente = ISNULL(@nClaClienteXml,0)

		IF ISNULL(@sNota,'') = '' AND ISNULL(@nClaCliente,0)>0 AND ISNULL(@nClaArticulo,0)>0
		BEGIN
			SELECT	@sNota = Nota
			FROM	OpcSch.OpcCfgNotaCliente nc WITH(NOLOCK)
			WHERE	nc.ClaUbicacion = @pnClaUbicacion
			AND		nc.ClaCliente = @nClaCliente
			AND     nc.ClaArticulo = @nClaArticulo
			AND     nc.BajaLogica = 0                 
		END
	END

	
	--No encontro con Cliente-Producto
	IF ISNULL(@sNota,'') = ''
	BEGIN
		SELECT	@sNota = nc.Nota
		FROM	OPCSch.OPCTraCertificado cer WITH(NOLOCK)
		INNER	JOIN OPCSch.OPCCfgNotaCliente nc WITH(NOLOCK)
		ON		nc.ClaUbicacion = cer.ClaUbicacion
		AND		nc.ClaCliente = -1
		AND		nc.ClaArticulo = cer.ClaArticulo
		AND		nc.BajaLogica = 0
		WHERE	cer.ClaUbicacion = @pnClaUbicacion
		AND		cer.IdCertificado = @pnIdCertificado
		--No encontro con Producto-Todos
		IF ISNULL(@sNota,'') = ''
		BEGIN
			--Notas para Todos - Todos
			SELECT	@sNota = isnull(nc.Nota, ' ')
			FROM	OPCSch.OPCTraCertificado cer WITH(NOLOCK)
			LEFT JOIN	OPCSch.OPCCfgNotaCliente nc WITH(NOLOCK)
			ON		nc.ClaUbicacion = cer.ClaUbicacion
			AND		nc.ClaCliente = -1
			AND		nc.ClaArticulo = -1
			AND		nc.BajaLogica = 0
			WHERE	cer.ClaUbicacion = @pnClaUbicacion
			AND		cer.IdCertificado = @pnIdCertificado
		END
	END

	SELECT @sNota = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(@sNota,'""','"""') ,
					'%','%%'),'^','^^'),'&','^&'),'<','^<'),'>','^>'),'|','^|'),'`','^`'),',','^,'),';','^;'),'=','^='),'(','^('),')','^)'),'!','^^!'),char(10),''),'�','��'),'�','��')
    --SELECT @sNomArticulo = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(@sNomArticulo, '"', '""') ,
				--	'%','%%'),'^','^^'),'&','^&'),'<','^<'),'>','^>'),'|','^|'),'`','^`'),',','^,'),';','^;'),'=','^='),'(','^('),')','^)'),'!','^^!'),char(10),''),'�','��'),'�','��')

   SELECT @sNomArticulo = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(@sNomArticulo, 
					'%','%%'),'^','^^'),'&','^&'),'<','^<'),'>','^>'),'|','^|'),'`','^`'),',','^,'),';','^;'),'=','^='),'(','^('),')','^)'),'!','^^!'),char(10),''),'�','��'),'�','��')

	
	SELECT	@sNumeroFactura = ISNULL(@sNumeroFactura, @sIdEntSal)
 
	SELECT	@sRutaTempServidor = LTRIM(RTRIM(sValor1))
	FROM	OPCSch.OPCTiCatConfiguracionVw 
	WHERE	ClaSistema = 246
	AND		ClaConfiguracion = 246153
	AND		ClaUbicacion = @pnClaUbicacion
 
	CREATE TABLE #SalidaComando (SalidaComando VARCHAR(8000))

	IF ISNULL(@sRutaTempServidor, '') = ''
	BEGIN
		--Crea un archivo temporal de salida
		INSERT INTO #SalidaComando
		EXEC master.dbo.xp_cmdshell 'echo %TEMP%'
	
		--Obtiene la ruta en el servidor del archivo de salida temporal
		SELECT	TOP 1 @sRutaTemp = SalidaComando
		FROM	#SalidaComando
	END
	ELSE
		SET @sRutaTemp = @sRutaTempServidor		-- JGE
	
	--Crea un nombre a los archivos pdf y rss que se van a crear	
	IF ISNULL(@psNomPdf,'') = ''
	BEGIN
		SET @sId = CONVERT(VARCHAR(100),NEWID())	
	END
	ELSE
	BEGIN
		SET @sId = @psNomPdf
	END
	
	SET @sNomArchivo = @sRutaTemp + '\' + @sId + '.pdf'
	SET @sNomArchivoRSS = @sRutaTemp + '\' + @sId + '.rss'	
	SET @nExisteArchivo = 0
	SET @nIndice = 1
	
	SELECT @pnNumVersion = isnull(@pnNumVersion, 1)
	
	--Inserta texto al archivo
	--declara el formato del archivo de salida, el nombre del rss
	--declara 16 parametros
	SET	@sComandoDinamico = 'echo Public Sub Main()																		> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	Dim format as string = "PDF"														>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	Dim fileName as String = "'+@sNomArchivo+'"											>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	Dim reportPath as String = "'+@sRutaReporte+'"										>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	Dim results() as Byte																>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	Dim parameters(23) As ParameterValue												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(0) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(0).Name = "pnNumVersion"													>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(0).Value = "'+CONVERT(VARCHAR,@pnNumVersion)+'"							>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(1) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(1).Name = "pnClaUbicacion"												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(1).Value = "'+CONVERT(VARCHAR,@pnClaUbicacion)+'"						>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(2) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(2).Name = "pnClaCliente"													>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(2).Value = "'+CONVERT(VARCHAR,@nClaCliente)+'"							>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output	
	
	SET @sComandoDinamico = 'echo 	parameters(3) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(3).Name = "psNombreCliente"												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(3).Value = "' + @sNombreCliente + '"						>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(4) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(4).Name = "psNumeroFactura"												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(4).Value = "' + @sNumeroFactura +'"						>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(5) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(5).Name = "pnIdCertificado"												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(5).Value = "'+CONVERT(VARCHAR,@pnIdCertificado)+'"						>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output	
	
	SET @sComandoDinamico = 'echo 	parameters(6) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(6).Name = "psCiudad"														>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(6).Value = "' + @sNombreCiudad + '"							>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(7) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(7).Name = "pnKgsTotal"													>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(7).Value = "'+CONVERT(VARCHAR,@nKgsTotal)+'"								>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(8) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(8).Name = "psNombreUbicacion"											>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(8).Value = "' + @sNombreUbicacion + '"						>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output	
	
	SET @sComandoDinamico = 'echo 	parameters(9) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(9).Name = "psNomArticulo"												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
 
	SELECT @sNomArticulo = replace(@sNomArticulo, '"', '''''') --quita las comillas, porque se confunde en el string
	SET @sComandoDinamico = 'echo 	parameters(9).Value = "' + @sNomArticulo + '"							>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(10) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(10).Name = "psNomUnidad"													>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(10).Value = "' + @sNomUnidad + '"							>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(11) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(11).Name = "pnIdViaje"													>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(11).Value = "'+CONVERT(VARCHAR,@nIdViaje)+'"								>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(12) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(12).Name = "pnIdPlanCarga"												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(12).Value = "'+CONVERT(VARCHAR,@nIdPlanCarga)+'"							>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(13) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(13).Name = "psNota"														>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(13).Value = "' + @sNota + '"								>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(14) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(14).Name = "cultureName"													>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(14).Value = "' + @psClaIdioma + '"										>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output	
	
	SET @sComandoDinamico = 'echo 	parameters(15) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(15).Name = "psClaIdioma"													>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(15).Value = "' + @psClaIdioma + '"										>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(16) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(16).Name = "psDireccion"													>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(16).Value = "' + @sDireccion + '"							>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(17) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(17).Name = "pnClaTipoImpresion"											>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(17).Value = "1"															>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(18) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(18).Name = "pnIdFabricacion"														>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(18).Value = "'+CONVERT(VARCHAR,@nIdFabricacion)+'"								>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(19) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(19).Name = "psClavesRollo"														>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(19).Value = "' + ISNULL(@psRollos,' ') + '"								>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(20) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(20).Name = "psDiametro"														>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(20).Value = "' + @sDiametro + '"								>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
 
	SET @sComandoDinamico = 'echo 	parameters(21) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(21).Name = "psLongitud"														>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(21).Value = "' + @sLongitudTotal + '"								>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(22) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(22).Name = "psEspecificacion"														>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(22).Value = "' + @sEspecificacion + '"								>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output	
	
	SET @sComandoDinamico = 'echo 	parameters(23) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(23).Name = "psTipo"														>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	parameters(23).Value = "' + @sTipoCable + '"								>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output		
	
	SET @sComandoDinamico = 'echo 	rs.LoadReport(reportPath, Nothing)													>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	rs.SetExecutionParameters(parameters, "es-MX")										>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	results = rs.Render(format, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing)	>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	Dim stream  As FileStream = File.OpenWrite(fileName)								>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	stream.Write(results, 0, results.Length)											>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	stream.Close()																		>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo End Sub																				>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	--Una vez que cerro el archivo lo ejecuta y dice que use Reporting Services 2005
	SET @sComandoDinamico = 'rs -i "'+@sNomArchivoRSS+'" -s "'+ @sRutaServidorRS + '" -e Exec2005'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	
	--Hace una espera de 15 segundos para ver si ya se creo el archivo pdf
	WHILE @nIndice <= 15 and @nExisteArchivo <> 1
	BEGIN
		WAITFOR DELAY '00:00:01'
 
		DELETE #SalidaComando

		IF ISNULL(@sRutaTempServidor,'') = ''
			INSERT INTO #SalidaComando
			EXEC master.dbo.xp_cmdshell 'dir %TEMP%'
		ELSE
		BEGIN
			SET @sComandoDinamico = 'dir "' + @sRutaTempServidor + '"'
			INSERT INTO #SalidaComando
			EXEC master.dbo.xp_cmdshell @sComandoDinamico
		END
 
		IF EXISTS ( SELECT 1 FROM #SalidaComando WHERE SalidaComando LIKE '%' + @sId + '.pdf%' )
			SET @nExisteArchivo = 1
 
		SET @nIndice = @nIndice + 1
	END
	--Elimina la tabla con la info del archivo de salida
	DROP TABLE #SalidaComando
	
	--elimina regresa en un select el varbinary del pedf "delete" los pdf y rss
	IF @nExisteArchivo = 1
	BEGIN
		SET @pnError = 0
		SET @psRutaArchivo = @sNomArchivo
 
		SET @sComandoDinamico = 'del "'+@sNomArchivoRSS+'"'
		EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output		
	END
	ELSE
	BEGIN
		SET @pnError = 1
		GOTO FIN
	END
 
	FIN:
	SET NOCOUNT OFF
END