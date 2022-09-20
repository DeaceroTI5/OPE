USE Operacion
GO
ALTER PROCEDURE OPESch.OpeGeneraFormatoPLPdfProc
 	  @pnClaUbicacion	INT
	, @pnIdViaje		INT
	, @pnIdFactura		INT
	, @nNumVersion		INT = 1
	, @psIdioma			VARCHAR(10) = 'es-MX'	
	, @pnDebug			INT	= 0
	, @psNombrePcMod	VARCHAR(64)
AS
BEGIN
	SET NOCOUNT ON
	-- Instruccion agregada por problemas en el envío del archivo generado a partir de cambios en la seguridad de los servidores
	EXECUTE AS LOGIN = 'sa'
	
	DECLARE   @nExisteArchivo	INT
			, @nIndice			INT
			, @sNomArchivo		VARCHAR(1000)
			, @sNomArchivoRSS	VARCHAR(1000)
			, @sRutaServidorRS	VARCHAR(1000)
			, @sRutaTemp		VARCHAR(1000)
			, @sComandoDinamico	VARCHAR(8000)
			, @sId				VARCHAR(100)
			, @sRutaReporte		VARCHAR(1000)
			, @sReporte			VARCHAR(250)
			, @psNomPdf			VARCHAR(100)
			, @psRutaArchivo	VARCHAR(1000)		
			, @pnError			TINYINT			= 0	
			, @bArchivo			VARBINARY(MAX)
	
	DECLARE @tbBinPDF TABLE(
		BlkColumn VARBINARY(MAX)
	)
	

	SET	@pnError = 0
	

	--SELECT	@sRutaServidorRS	= LTRIM(RTRIM(sValor1)),
	--		@sRutaReporte		= LTRIM(RTRIM(sValor2))
	--FROM	OPCSch.OPCTiCatConfiguracionVw 
	--WHERE	ClaSistema			= 246
	--AND		ClaConfiguracion	= 24612
	--AND		ClaUbicacion		= @pnClaUbicacion
	--AND		BajaLogica			= 0

	SELECT	  @sRutaServidorRS	= 'http://appitknet04/ReportServer'
			, @sRutaReporte		= '/OPE/Reportes/'
			, @sReporte			= 'OPE_CU71_Pag1_Rpt_ImpPackingListEsp'
	
	--El nombre del reporte es fijo por tipo de certificado
	SELECT @sRutaReporte = @sRutaReporte + @sReporte


	--/*Crea un archivo temporal de salida*/	
	CREATE TABLE #SalidaComando (SalidaComando VARCHAR(8000))
	
	INSERT INTO #SalidaComando
	EXEC master.dbo.xp_cmdshell 'echo %TEMP%'
	--Obtiene la ruta en el servidor del archivo de salida temporal
	SELECT	TOP 1 @sRutaTemp = SalidaComando
	FROM	#SalidaComando
	
	--Crea un nombre a los archivos pdf y rss que se van a crear	
	IF ISNULL(@psNomPdf,'') = ''
	BEGIN
		SET @sId = CONVERT(VARCHAR(100),NEWID())	
	END
	ELSE
	BEGIN
		SET @sId = @psNomPdf
	END
	
	
	/*Asignacion Nombre*/
	SET @sNomArchivo	= @sRutaTemp + '\' + @sId + '.pdf'
	SET @sNomArchivoRSS = @sRutaTemp + '\' + @sId + '.rss'	
	SET @nExisteArchivo = 0
	SET @nIndice = 1
	

	--'es-MX'


	--/*Abre el Archivo*/
	--/*Declara el formato del archivo de salida, el nombre del rss*/
	SET	@sComandoDinamico = 'echo	Public Sub Main()																	> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	Dim format as string = "PDF"														>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	Dim fileName as String = "'+@sNomArchivo+'"											>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	Dim reportPath as String = "'+@sRutaReporte+'"										>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	SET @sComandoDinamico = 'echo 	Dim results() as Byte																>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

	
	--/*Envio de parámetros*/
	--/*Crear Lista de Parámetros*/
	SET @sComandoDinamico = 'echo 	Dim parameters(4) As ParameterValue													>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	--/*Crear Parámetros(0)*/
	SET @sComandoDinamico = 'echo 	parameters(0) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	SET @sComandoDinamico = 'echo 	parameters(0).Name = "pnClaUbicacion"												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	SET @sComandoDinamico = 'echo 	parameters(0).Value = "'+CONVERT(VARCHAR,@pnClaUbicacion)+'"						>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	--/*Crear Parámetros(1)*/
	SET @sComandoDinamico = 'echo 	parameters(1) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	SET @sComandoDinamico = 'echo 	parameters(1).Name = "pnIdViaje"													>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	SET @sComandoDinamico = 'echo 	parameters(1).Value = "'+CONVERT(VARCHAR,@pnIdViaje)+'"								>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

	--/*Crear Parámetros(2)*/
	SET @sComandoDinamico = 'echo 	parameters(2) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	SET @sComandoDinamico = 'echo 	parameters(2).Name = "psClaIdioma"													>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	SET @sComandoDinamico = 'echo 	parameters(2).Value = "'+CONVERT(VARCHAR,@psIdioma)+'"								>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

	--/*Crear Parámetros(2)*/
	SET @sComandoDinamico = 'echo 	parameters(3) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	SET @sComandoDinamico = 'echo 	parameters(3).Name = "pnNumVersion"													>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	SET @sComandoDinamico = 'echo 	parameters(3).Value = "'+	CONVERT(VARCHAR,@nNumVersion)	+'"						>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output	
	
		
	--/*Creación Archivo*/
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
	SET @sComandoDinamico = 'echo	End Sub																				>> "'+@sNomArchivoRSS+'"'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	IF @pnDebug = 1
	BEGIN
		SELECT @sComandoDinamico AS '@sComandoDinamico 1'	
	END
	
	--/*Una vez que cerro el archivo lo ejecuta y dice que use Reporting Services 2005*/
	SET @sComandoDinamico = 'rs -i "'+@sNomArchivoRSS+'" -s "'+ @sRutaServidorRS + '" -e Exec2005'
	EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
	IF @pnDebug = 1
	BEGIN
		SELECT @sComandoDinamico AS '@sComandoDinamico 2'	
	END	
	
	--/*Hace una espera de 15 segundos para ver si ya se creo el archivo pdf*/
	WHILE @nIndice <= 15 and @nExisteArchivo <> 1
	BEGIN
		WAITFOR DELAY '00:00:01'
 
		DELETE #SalidaComando
		INSERT INTO #SalidaComando
			EXEC master.dbo.xp_cmdshell 'dir %TEMP%'
 
		IF EXISTS ( SELECT 1 FROM #SalidaComando WHERE SalidaComando LIKE '%' + @sId + '.pdf%' )
			SET @nExisteArchivo = 1
 
		SET @nIndice = @nIndice + 1
	END


 	--/*Elimina la tabla con la info del archivo de salida*/
	DROP TABLE #SalidaComando	


	--/*Elimina regresa en un select el varbinary del pdf "delete" los pdf y rss*/
	IF @nExisteArchivo = 1
	BEGIN
		SET @pnError = 0
		SET @psRutaArchivo = @sNomArchivo
 
		SET @sComandoDinamico = 'del "'+@sNomArchivoRSS+'"'
		EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
		
		IF @pnDebug = 1
		SELECT @sComandoDinamico AS '@sComandoDinamico 3'				
	END
	ELSE
	BEGIN
		IF @pnDebug = 1
			SELECT 'No existe Archivo'

		SET @pnError = 1
		GOTO FIN
	END
 
	IF @pnError = 0
	BEGIN
		/*BULK ARCHIVO*/
		INSERT @tbBinPDF(BlkColumn)
		EXEC ('SELECT * FROM OPENROWSET(BULK ''' + @psRutaArchivo + ''', SINGLE_BLOB) AS a')
		
		SELECT	TOP 1 @bArchivo = BlkColumn
		FROM	@tbBinPDF
		
		IF ISNULL(@pnDebug,0) = 0
		BEGIN
			EXEC OpeSch.OPE_CU71_Pag4_ReporteAPDF_Proc		-- '[OpeSch].OPE_CU71_Pag4_ReporteAPDF_Proc'                 
				  @pnClaUbicacion			= @pnClaUbicacion
				, @psNombreReporte			= NULL
				, @pbBytesReporte			= @bArchivo
				, @pnClaFormatoImpresion	= 8		-- Packing List
				, @pnIdFactura				= @pnIdFactura
				, @pnIdCertificado			= NULL
				, @psNombrePcMod			= @psNombrePcMod
				, @pnClaUsuarioMod 			= 0
		END

		--/*Borra Archivo*/
		SET @sComandoDinamico = 'del "' + @psRutaArchivo + '"'
		EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
		
		IF @pnDebug = 1
		SELECT @sComandoDinamico AS '@sComandoDinamico 4'
	END

	FIN:
	IF @pnDebug = 1
	BEGIN
		SELECT	 @pnError				AS '@pnError' 
				,@nExisteArchivo		AS '@nExisteArchivo'
				,@bArchivo				AS '@bArchivo'			
				,@nIndice				AS '@nIndice'			
				,@sNomArchivo			AS '@sNomArchivo'		
				,@sNomArchivoRSS		AS '@sNomArchivoRSS'	
				,@sRutaServidorRS		AS '@sRutaServidorRS'	
				,@sRutaTemp				AS '@sRutaTemp'			
				,@sComandoDinamico		AS '@sComandoDinamico'	
				,@sId					AS '@sId'				
				,@sRutaReporte			AS '@sRutaReporte'		
				,@sReporte				AS '@sReporte'			
	END	
	
	--IF @@Error <> 0 --OR @pnError <> 0
	--GOTO ABORT

	/*Descargar Archivo*/		
--	SELECT	 FileData	= @bArchivo
--			,FileName	= @sReporte 
--			,FileExt	= 'pdf'	
	
	SET NOCOUNT OFF
	RETURN
	
	--* Manejo de errores
	ABORT: 
	--RAISERROR('No fue posible crear el certificado.',16,1)


	SET NOCOUNT OFF
	RETURN
END


