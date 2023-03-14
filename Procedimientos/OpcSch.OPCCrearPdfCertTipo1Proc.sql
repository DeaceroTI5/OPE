USE Operacion
GO
-- EXEC SP_HELPTEXT 'OpcSch.OPCCrearPdfCertTipo1Proc'
GO
ALTER PROCEDURE OpcSch.OPCCrearPdfCertTipo1Proc
	@pnNumVersion		INT,
	@pnClaUbicacion		INT,
	@pnIdCertificado	INT,
	@psRollos			VARCHAR(MAX),
	@psNomPdf			VARCHAR(100),
	@psRutaArchivo		VARCHAR(1000) OUTPUT,
	@pnError			TINYINT = 0 OUTPUT,
	@pxmlEncabezado		XML = NULL,
	@psClaIdioma		VARCHAR(6) = 'es-MX',
	@pnClaUsuarioMod    INT = NULL,
	@psNombrePcMod      VARCHAR(64)= '',
	@psRutaProcedimiento VARCHAR(250) = '',
	@pnDebug			INT = 0
AS
BEGIN
	SET NOCOUNT ON
	
	-- AMLE/LFVR 18-12-2019: 
	-- Instruccion agregada por problemas en el envío del archivo generado a partir de cambios en la seguridad de los servidores
	-- JGE/HAVS/AMLE 01-03-2022: 
	-- Se recibió apoyo de JGE (Infraestructura BD) para que ya no sea necesario esa instrucción en los nuevos servidores y además se agregó una ruta especifica

	IF @pnClaUbicacion NOT IN ( 267 )	-- Planta WWR
		EXECUTE AS LOGIN = 'sa'

	SELECT	 @pnClaUsuarioMod   = ISNULL(@pnClaUsuarioMod,1)
			,@psNombrePcMod     = ISNULL(NULLIF(@psNombrePcMod,''),HOST_NAME())
	
	IF ISNULL(@psRutaProcedimiento, '') = ''
		SELECT @psRutaProcedimiento = 'OpcSch.OPCCrearPdfCertTipo1Proc'
    ELSE
		SELECT @psRutaProcedimiento = LTRIM(RTRIM(@psRutaProcedimiento)) + ' - ' + 'OpcSch.OPCCrearPdfCertTipo1Proc'

	
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
			@sIdEntSal			VARCHAR(100)
	
	DECLARE @sNomArchivo VARCHAR(1000),
			@sNomArchivoRSS VARCHAR(1000),
			@sRutaTemp VARCHAR(1000),
			@sComandoDinamico VARCHAR(8000),
			@sId VARCHAR(100),
			@sServername VARCHAR(200),
			@sNomArchivoBatExec VARCHAR(1000),
			@sGuiId VARCHAR(200),
			@sTableTemp VARCHAR(200),
			@sSQL VARCHAR(8000),			
			@nExiste INT,
			@sUsuarioLecturaArchivo VARCHAR(50),
			@sRutaTempServidor		VARCHAR(1000)
			--@sUsername varchar(20),
			--@sPassword varchar(20)
	
	--DECLARE @tbBinPDF TABLE(BlkColumn VARBINARY(MAX))
	DECLARE @tArchivoTxt  TABLE(Id INT IDENTITY(1,1), Texto varchar(5000))
		
	SET @pnError = 0
	
	IF LTRIM(RTRIM(ISNULL(@psRollos,'')))<>''
	BEGIN
		SET @psRollos = REPLACE(@psRollos,'"','''')
	END
		
	SELECT	@sServername = CONVERT(VARCHAR, @@SERVERNAME)
	
	SELECT	@sRutaServidorRS = LTRIM(RTRIM(sValor1)),
			@sRutaReporte = LTRIM(RTRIM(sValor2))
	FROM	OPCSch.OPCTiCatConfiguracionVw 
	WHERE	ClaSistema = 246
			AND ClaConfiguracion = 24601
			AND ClaUbicacion = @pnClaUbicacion

	DECLARE @sReporte VARCHAR(250)
	DECLARE @nConfiguracionReporte INT
	
	
	IF @pnClaUbicacion = 61 
		SELECT @nConfiguracionReporte = 24603 
	ELSE
		SELECT @nConfiguracionReporte = 24602
				
	SELECT	@sReporte = LTRIM(RTRIM(sValor1))
	FROM	OPCSch.OPCTiCatConfiguracionVw 
	WHERE	ClaSistema = 246
			AND ClaConfiguracion = @nConfiguracionReporte
			AND ClaUbicacion = @pnClaUbicacion		
	
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
 
 
	--El nombre del reporte es fijo por tipo de certificado
	SELECT @sRutaReporte = @sRutaReporte + @sReporte
 
	SELECT	@nClaCliente = ISNULL(cer.ClaCliente, 0),
			@sNombreCliente = ISNULL(cli.NombreCliente, ' '),
			@sNumeroFactura = ISNULL(cer.NumeroFactura,cer.idEntsal), 
			@sIdEntSal = ISNULL(CONVERT(VARCHAR(100), cer.IdEntSal), ' '),
			@sNombreCiudad = ISNULL(ciu.NombreCiudad, ' '),
			--@nKgsTotal = ISNULL(cer.KgsTotal, 0),
			@nKgsTotal =
						CASE	WHEN ISNULL(cfgFam.ClaFamilia,0) > 0 -- Si se encuentra dentro de la config. de Familias OPC
								THEN ISNULL(NULLIF(cer.Cantidad,0),
											-- si es 0 o Nulo calcula la cantidad mediante la función
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
			@sNomArticulo = LTRIM(RTRIM(ISNULL(art.ClaveArticulo,'') + ' - ' + ISNULL(art.NomArticulo, ' '))),
			--@sNomUnidad = ISNULL(uni.NomUnidad, ' '),
			@sNomUnidad = CASE	WHEN ISNULL(cfgFam.ClaFamilia,0) > 0
								THEN	
										CASE	WHEN ISNULL(NULLIF(cer.Cantidad,0),
															-- si es 0 o Nulo calcula la cantidad mediante la función
															ISNULL(NULLIF(OpcSch.OpcObtenCantidadCertificadoFn(cer.ClaUbicacion, cer.IdPlanCarga, cer.IdFabricacion, cer.IdFabricacionDet, cer.ClaArticulo),0),0)
															) <> 0		
												THEN ISNULL(uni.NomUnidad, ' ')	-- Si Cantidad no es cero o el calculo tampoco es cero muestra Unidad Longitud
												ELSE							-- Si Cantidad es cero muestra por Unidad de Peso
														CASE	WHEN ciudadpedido.ClaPais = 1	
																THEN 'Kg' 
																ELSE 'LBS'
														END
										END	
								ELSE	-- Unidad diferente a Longitud
										CASE	WHEN ciudadpedido.ClaPais = 1	
												THEN 'Kg' 
												ELSE 'LBS'
										END			
						END,
			@nIdViaje = ISNULL(cer.IdViaje, 0),
			@nIdPlanCarga = ISNULL(cer.IdPlanCarga, 0),
			@sNota = nc.Nota,
			@nIdFabricacion = ISNULL(cer.IdFabricacion, 0),
			@sDireccion =(RTRIM(ISNULL(tcuv.Direccion,'')) + ' ' + 
						RTRIM(ISNULL(tcuv.Colonia,'')) + ' ' + 
						CASE WHEN tcuv.CodigoPostal IS NOT NULL THEN CASE @psClaIdioma WHEN 'es-MX' THEN 'CP. ' ELSE 'ZP. ' END + ISNULL(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(tcuv.CodigoPostal,'CP.',''),'C.P.',''),'CP',''))),'') ELSE '' END + ', ' + 
						RTRIM(ISNULL(tcuv.Poblacion,'')) + ' ' +
						CASE WHEN ISNULL(tcuv.Telefonos,'') <> '' THEN CASE @psClaIdioma WHEN 'es-MX' THEN 'Tel: ' ELSE CASE WHEN @pnClaUbicacion IN (65,267) THEN 'Ph: ' ELSE 'Ph: +52 ' END END +
						   RTRIM(ISNULL(tcuv.Telefonos, '')) ELSE '' END +  
						   CASE LEN(RTRIM(LTRIM(ISNULL(tcuv.Fax, '')))) WHEN 0 THEN '' ELSE ' Fax: ' + RTRIM(LTRIM(ISNULL(tcuv.Fax,''))) END
						   ),
			@nIdOpm = ISNULL(cer.IdOPM, 0),
			@nClaArticulo = ISNULL(cer.ClaArticulo, 0)
	FROM	opcsch.OPCTraCertificado cer WITH(NOLOCK)
	INNER JOIN OpcSch.OpcTiCatUbicacionVw AS tcuv WITH(nolock)ON tcuv.ClaUbicacion = cer.ClaUbicacion
	LEFT	JOIN OpcSch.OPCArtCatArticuloVw art  WITH(NOLOCK) ON
			art.ClaTipoInventario = 1
			AND art.ClaArticulo = cer.ClaArticulo
	LEFT	JOIN OpcSch.OpcTiCatUbicacionVw ubi  WITH(NOLOCK) ON
			ubi.ClaUbicacion = cer.ClaUbicacion
	LEFT	JOIN OpcSch.OpcVtaCatClienteVw cli WITH(NOLOCK) ON
			cli.ClaCliente = cer.ClaCliente
	LEFT	JOIN OpcSch.OpcVtaCatCiudadVw ciu WITH(NOLOCK) ON
			ciu.ClaCiudad = cer.ClaCiudad
	LEFT	JOIN OpcSch.OpcArtCatUnidadVw uni WITH(NOLOCK) ON
			uni.ClaTipoInventario = 1
			AND uni.ClaUnidad = art.ClaUnidadBase
	--		AND uni.ClaUnidad = art.ClaUnidadProd
			AND uni.ClaTipoInventario = art.ClaTipoInventario
	LEFT	JOIN OpcSch.OpcCfgNotaCliente nc WITH(NOLOCK) ON
			nc.ClaUbicacion = cer.ClaUbicacion
			AND nc.ClaCliente = cer.ClaCliente
			AND nc.ClaArticulo = cer.ClaArticulo
			AND nc.BajaLogica = 0
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
		FROM	opcsch.OpcTraCertificado cer WITH(NOLOCK)
		INNER	JOIN OPCSch.OpcCfgNotaCliente nc WITH(NOLOCK)
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
			FROM	opcsch.OpcTraCertificado cer WITH(NOLOCK)
			LEFT JOIN	OPCSch.OPCCfgNotaCliente nc WITH(NOLOCK)
			ON		nc.ClaUbicacion = cer.ClaUbicacion
			AND		nc.ClaCliente = -1
			AND		nc.ClaArticulo = -1
			AND		nc.BajaLogica = 0
			WHERE	cer.ClaUbicacion = @pnClaUbicacion
			AND		cer.IdCertificado = @pnIdCertificado
		END
	END

	--SELECT	@sNota = replace(@sNota, '"' , char(39) + char(39))
	--SELECT	@sNota = replace(@sNota, '”' , char(39) + char(39))

	--SELECT	@sNomArticulo = replace(@sNomArticulo, '"' , char(39) + char(39))	--quita las comillas, porque se confunde en el string
	--SELECT	@sNomArticulo = replace(@sNomArticulo, '”' , char(39) + char(39) )	--quita las comillas, porque se confunde en el string

	--SELECT	@sNota = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(@sNota, '"', '""') ,
	--'%','%%'),'^','^^'),'&','^&'),'<','^<'),'>','^>'),'|','^|'),'`','^`'),',','^,'),';','^;'),'=','^='),'(','^('),')','^)'),'!','^^!'),char(10),'')
	--SELECT	@sNomArticulo = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(@sNomArticulo, '"', '""') ,
	--'%','%%'),'^','^^'),'&','^&'),'<','^<'),'>','^>'),'|','^|'),'`','^`'),',','^,'),';','^;'),'=','^='),'(','^('),')','^)'),'!','^^!'),char(10),'')

	SELECT @sNota = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(@sNota,'""','"""') ,
					'%','%%'),'^','^^'),'&','^&'),'<','^<'),'>','^>'),'|','^|'),'`','^`'),',','^,'),';','^;'),'=','^='),'(','^('),')','^)'),'!','^^!'),char(10),''),'“','““'),'”','””')
    --SELECT @sNomArticulo = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(@sNomArticulo, '"', '""') ,
				--	'%','%%'),'^','^^'),'&','^&'),'<','^<'),'>','^>'),'|','^|'),'`','^`'),',','^,'),';','^;'),'=','^='),'(','^('),')','^)'),'!','^^!'),char(10),''),'“','““'),'”','””')

   SELECT @sNomArticulo = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(@sNomArticulo, 
					'%','%%'),'^','^^'),'&','^&'),'<','^<'),'>','^>'),'|','^|'),'`','^`'),',','^,'),';','^;'),'=','^='),'(','^('),')','^)'),'!','^^!'),char(10),''),'“','““'),'”','””')


	SELECT	@sNumeroFactura = ISNULL(@sNumeroFactura, @sIdEntSal)

	IF @pnDebug = 1 
		SELECT 'Pase: OpcSch.OPCCrearPdfCertTipo1Proc - Obtener datos'

	SELECT	@sRutaTempServidor = LTRIM(RTRIM(sValor1))
	FROM	OPCSch.OPCTiCatConfiguracionVw 
	WHERE	ClaSistema = 246
	AND		ClaConfiguracion = 246153
	AND		ClaUbicacion = @pnClaUbicacion
 
	declare @SalidaComando TABLE (SalidaComando VARCHAR(8000))

	IF ISNULL(@sRutaTempServidor, '') = ''
	BEGIN
		--Crea un archivo temporal de salida
		INSERT INTO @SalidaComando
		EXEC master.dbo.xp_cmdshell 'echo %TEMP%'
	
		--Obtiene la ruta en el servidor del archivo de salida temporal
		SELECT	TOP 1 @sRutaTemp = SalidaComando
		FROM	@SalidaComando
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
	SET @sNomArchivoBatExec = @sRutaTemp + '\' + CONVERT(VARCHAR(200), NEWID()) + '.bat'
	
	SELECT @pnNumVersion = isnull(@pnNumVersion, 1)
	
	--Inserta texto al archivo
	--declara el formato del archivo de salida, el nombre del rss
	--declara 16 parametros
	
	insert into @tArchivoTxt SELECT 'Public Sub Main()'--																		> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	Dim format as string = "PDF"'--														>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	Dim fileName as String = "'+@sNomArchivo+'"	'--										>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	Dim reportPath as String = "'+@sRutaReporte+'"'--										>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	Dim results() as Byte'--																>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	Dim parameters(19) As ParameterValue'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(0) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(0).Name = "pnNumVersion"'--													>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(0).Value = "'+CONVERT(VARCHAR,@pnNumVersion)+'"'--							>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(1) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(1).Name = "pnClaUbicacion"'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(1).Value = "'+CONVERT(VARCHAR,@pnClaUbicacion)+'"'--						>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(2) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(2).Name = "pnClaCliente"	'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(2).Value = "'+CONVERT(VARCHAR,@nClaCliente)+'"'--							>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(3) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(3).Name = "psNombreCliente"'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(3).Value = "' + @sNombreCliente + '"'--						>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(4) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(4).Name = "psNumeroFactura"'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(4).Value = "' + @sNumeroFactura +'"'--						>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(5) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(5).Name = "pnIdCertificado"'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(5).Value = "'+CONVERT(VARCHAR,@pnIdCertificado)+'"'--						>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(6) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(6).Name = "psCiudad"'--														>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(6).Value = "' + @sNombreCiudad + '"'--							>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT '	parameters(7) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(7).Name = "pnKgsTotal"'--													>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(7).Value = "'+CONVERT(VARCHAR,@nKgsTotal)+'"'--								>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(8) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(8).Name = "psNombreUbicacion"'--											>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(8).Value = "' + rtrim(@sNombreUbicacion) + '"'--						>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(9) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(9).Name = "psNomArticulo"'--												>> "'+@sNomArchivoRSS+'"'
 
	insert into @tArchivoTxt SELECT ' 	parameters(9).Value = "' + @sNomArticulo + '"'--							>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(10) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(10).Name = "psNomUnidad"'--													>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(10).Value = "' + @sNomUnidad + '"'--							>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(11) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(11).Name = "pnIdViaje"'--													>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(11).Value = "'+CONVERT(VARCHAR,@nIdViaje)+'"'--								>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(12) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(12).Name = "pnIdPlanCarga"'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(12).Value = "'+CONVERT(VARCHAR,@nIdPlanCarga)+'"'--							>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(13) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(13).Name = "psNota"'--														>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(13).Value = "' + @sNota + '"'--								>> "'+@sNomArchivoRSS+'"'

	insert into @tArchivoTxt SELECT ' 	parameters(14) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(14).Name = "pscultureName"'--													>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(14).Value = "' + @psClaIdioma + '"'--														>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(15) = New ParameterValue()'--)												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(15).Name = "psClaIdioma"'--													>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(15).Value = "' + @psClaIdioma + '"'--														>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(16) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(16).Name = "psDireccion"'--													>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(16).Value = "' + @sDireccion + '"'--							>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(17) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(17).Name = "pnClaTipoImpresion"'--											>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(17).Value = "1"'--															>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(18) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(18).Name = "pnIdFabricacion"'--														>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(18).Value = "'+CONVERT(VARCHAR,@nIdFabricacion)+'"'--								>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(19) = New ParameterValue()'--												>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(19).Name = "psClavesRollo"'--														>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	parameters(19).Value = "' + ISNULL(@psRollos,'') + '"'--								>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	rs.LoadReport(reportPath, Nothing)'--													>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	rs.SetExecutionParameters(parameters, "es-MX")'--										>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	results = rs.Render(format, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing)'--	>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	Dim stream  As FileStream = File.OpenWrite(fileName)'--								>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	stream.Write(results, 0, results.Length)'--											>> "'+@sNomArchivoRSS+'"'
	
	insert into @tArchivoTxt SELECT ' 	stream.Close()'--																		>> "'+@sNomArchivoRSS+'"'
	
	INSERT INTO @tArchivoTxt SELECT 'End Sub'--																				>> "'+@sNomArchivoRSS+'"'
	--
	DECLARE @sIdSesion VARCHAR(100)
	SELECT	@sIdSesion = NEWID()
	INSERT INTO OpcSch.OpcTraArchivoTexto(IdArchivo, IdRenglon, LineaTexto)	
	SELECT	@sIdSesion, Id, Texto FROM @tArchivoTxt

	IF @pnDebug = 1 select * from OpcSch.OpcTraArchivoTexto where IdArchivo = @sIdSesion
	
	SELECT @sSQL = 'SELECT LineaTexto FROM Operacion.OpcSch.OPCTraArchivoTexto(NOLOCK) WHERE IdArchivo = ' + char(39) + @sIdSesion + char(39)
	--PRINT 'Ejecuta bcp para creat archivo script rss:' + @sComandoDinamico
	SELECT @sComandoDinamico = 'bcp "' + @sSQL + '" queryout "' + @sNomArchivoRSS +'" -w -C RAW -t -T -S ' + @sServername
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	--Borrar las tablas de archivo para generar un archivo nuevo
	DELETE FROM @tArchivoTxt
	DELETE FROM OpcSch.OpcTraArchivoTexto WHERE IdArchivo = @sIdSesion
	
	--Crear el archivo rss meterlo al .bat
	SET @sComandoDinamico = 'rs -i "'+@sNomArchivoRSS+'" -s "'+ @sRutaServidorRS + '" -e Exec2005' -- > "' + @sNomArchivoBatExec + '"' 
	
	INSERT INTO @tArchivoTxt
	SELECT	@sComandoDinamico
	--PRINT 'agregar rs -i a bat: ' + @sComandoDinamico
	
	--crear bcp para actualizar el certificado con el archivo generado pdf
	--SET @sComandoDinamico = 'sqlcmd -Q "UPDATE Operacion.OPMSch.PloTraCertificado SET Archivo = ( SELECT BulkColumn FROM OPENROWSET(BULK ' + char(39) 
	--+ @sNomArchivo + char(39) + ', SINGLE_BLOB) as sourcefile) WHERE ClaUbicacion = ' + CONVERT(VARCHAR, @pnClaUbicacion) + ' AND IdCertificado = ' 
	--+ CONVERT(VARCHAR, @pnIdCertificado) + '" /S "' + convert(varchar,@@servername) + '" /U "' + @sUsername + '" /P "' + @sPassword + '"'
	--SET @sSQL = 'EXEC Operacion.OpmSch.PloActualizaCertificadoArchivo 1, ' + convert(varchar, @pnClaUbicacion) + ',' + convert(varchar, @pnIdCertificado) + ',' + char(39) + @sNomArchivo + char(39)
	--declare @sNomTxt varchar(500)
	--SET @sNomTxt = replace(@sNomArchivoRSS, '.rss', '.txt')
	--SET @sComandoDinamico = 'bcp "' + @sSQL + '" queryout "' + @sNomTxt +'" -c -t -T -S ' + @sServername
	--INSERT INTO @tArchivoTxt
	--SELECT	@sComandoDinamico
	--PRINT 'agregar bcp a bat: ' + @sComandoDinamico
	
	--SET @sComandoDinamico = 'del "' + @sNomArchivo + '"'
	--INSERT INTO @tArchivoTxt
	--SELECT	@sComandoDinamico
	--PRINT 'agregar instruccion borrado del pdf a bat: ' + @sComandoDinamico
	
	IF ISNULL(@sRutaTempServidor, '') = '' 
	AND @pnDebug <> 1	-- Si es igual a 1, que no elimine el archivo RSS para revisar el porque no lo crea.
	BEGIN
		SET @sComandoDinamico = 'del "' + @sNomArchivoRSS + '"'
		
		INSERT INTO @tArchivoTxt
		SELECT	@sComandoDinamico
	END
	
	--PRINT 'agregar instruccion borrado de .rss a bat: ' + @sComandoDinamico
	
	INSERT INTO OpcSch.OPCTraArchivoTexto(IdArchivo, IdRenglon, LineaTexto)	
	SELECT	@sIdSesion, Id, Texto FROM @tArchivoTxt
	
	SELECT @sSQL = 'SELECT LineaTexto FROM Operacion.OpcSch.OPCTraArchivoTexto(NOLOCK) WHERE IdArchivo = ' + char(39) + @sIdSesion + char(39)
		
	SELECT @sComandoDinamico = 'bcp "' + @sSQL + '" queryout "'+ @sNomArchivoBatExec + '" -c -t -T -S ' + @sServername
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

	IF @pnDebug = 1	
		SELECT 'Comando 1', @sComandoDinamico

	--Ejecutar archivo .bat en shell
	SET @sComandoDinamico = @sNomArchivoBatExec
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	IF @pnDebug = 1	
		SELECT 'Comando 2', @sComandoDinamico
	
	--PRINT 'ejecutar archivo .bat:' + @sComandoDinamico
	--Borrar el .bat
	--SET @sComandoDinamico = 'del ' + @sNomArchivoBatExec
	--EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	--Eliminar los registros de la tabla temporal
	DELETE FROM OpcSch.OPCtraArchivoTexto WHERE IdArchivo = @sIdSesion
	
	IF ISNULL(@sRutaTempServidor, '') = ''
	BEGIN
		--Revisar si existe el archivo pdf	
		SET @sUsuarioLecturaArchivo = OPCSch.OPCObtenerConfigStringFn(0,1271028,1)
		SELECT @sUsuarioLecturaArchivo  = LTRIM(RTRIM(@sUsuarioLecturaArchivo))  
		EXECUTE AS LOGIN = @sUsuarioLecturaArchivo
	
		EXEC master.dbo.xp_fileexist @sNomArchivo, @nExiste OUTPUT
	
		IF @pnDebug = 1	SELECT 'UsuarioLecturaArchivo', @sNomArchivo AS '@sNomArchivo', @sUsuarioLecturaArchivo AS '@sUsuarioLecturaArchivo'
	
		IF @nExiste = 1
			SELECT @psRutaArchivo = @sNomArchivo
		ELSE
			SELECT	@pnError = 1
	END
	ELSE
	BEGIN
		CREATE TABLE #SalidaComando (SalidaComando VARCHAR(8000))
		DECLARE @nIndice INT
		SELECT  @nIndice = 1, @nExiste = 0

		--Hace una espera de 15 segundos para ver si ya se creo el archivo pdf
		WHILE @nIndice <= 15 and @nExiste <> 1
		BEGIN
			WAITFOR DELAY '00:00:01'
 			DELETE #SalidaComando

			SET @sComandoDinamico = 'dir "' + @sRutaTempServidor + '"'
			INSERT INTO #SalidaComando
			EXEC master.dbo.xp_cmdshell @sComandoDinamico
 
			IF EXISTS ( SELECT 1 FROM #SalidaComando WHERE SalidaComando LIKE '%' + @sId + '.pdf%' )
				SET @nExiste = 1
 
			SET @nIndice = @nIndice + 1
		END

		IF @pnDebug = 1 SELECT @nExiste as '@nExiste'

		--Elimina la tabla con la info del archivo de salida
		DROP TABLE #SalidaComando

		IF @nExiste = 1
		BEGIN
			SET @pnError = 0
			SET @psRutaArchivo = @sNomArchivo
 
			IF @pnDebug <> 1
			BEGIN
				SET @sComandoDinamico = 'del "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output		
			END
		END
		ELSE
		BEGIN
			SET @pnError = 1
		END
	END

	FIN:
	SET NOCOUNT OFF
 
END