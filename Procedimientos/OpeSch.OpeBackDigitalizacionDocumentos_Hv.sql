USE Operacion
GO
--'OpeSch.OpeReDigitalizacionDocumentosProc'
GO
ALTER PROCEDURE OpeSch.OpeReDigitalizacionDocumentosProc
	  @pnClaUbicacion		INT
	, @psFacturaFiltro		VARCHAR(1000)= ''
	, @pnIdReporteFactura	INT
	, @pnDebug				TINYINT = 0
AS
BEGIN
	
	-- EXEC OpeSch.OpeReDigitalizacionDocumentosProc 267, '1058000036, 1058000037, 1058000038, 1058000039', 1

	---- Pendiente corregir parametro psCultureName
	IF object_id('tempdb..#TempNoFactDig') IS NOT NULL
	BEGIN
		DROP TABLE #TempNoFactDig
	END

	IF object_id('tempdb..#TempFactDig') IS NOT NULL
	BEGIN
		DROP TABLE #TempFactDig
	END

	IF object_id('tempdb..#TempReimpresionDigital') IS NOT NULL
	BEGIN
		DROP TABLE #TempReimpresionDigital
	END

	IF object_id('tempdb..#ResulExecConsecutivo') IS NOT NULL
	BEGIN
		DROP TABLE #ResulExecConsecutivo
	END

	IF object_id('tempdb..#TempBitacoraFactura') IS NOT NULL
	BEGIN
		DROP TABLE #TempBitacoraFactura
	END

	IF object_id('tempdb..#reportes') IS NOT NULL
	BEGIN
		DROP TABLE #reportes
	END

	IF object_id('tempdb..#reportes') IS NOT NULL
	BEGIN
		DROP TABLE #reportes2
	END

	IF object_id('tempdb..#SalidaComando') IS NOT NULL
	BEGIN
		DROP TABLE #SalidaComando
	END

	IF object_id('tempdb..#TmpInfoReporteFROM') IS NOT NULL
	BEGIN
		DROP TABLE #TmpInfoReporteFROM
	END

	IF object_id('tempdb..#TempNoFactDigs') IS NOT NULL
	BEGIN
		DROP TABLE #TempNoFactDigs
	END

	IF object_id('tempdb..#PDFbinary') IS NOT NULL
	BEGIN
		DROP TABLE #PDFbinary
	END

	DECLARE	@pnNumVersion					INT,
			@psNomPdf						INT,
			@psClaIdioma					VARCHAR(250),
			@psRutaArchivo					VARCHAR(1000),
			@pnError						VARCHAR(250),
			@sRutaServidorRS				VARCHAR(1000),
			@sRutaReporte					VARCHAR(1000),
			@sNomReporte					VARCHAR(1000),
			@FechaIn						DATETIME,
			@fechaFin						DATETIME,
			@pnIdOrderRemp					INT,
			@CountWh						INT,
			@nIdFactura						INT,
			@Formato						INT,
			@pnIdPlanCargaFact				INT,
			@pnIdboleta						INT,
			@IdTemp							INT,
			@psIdFacturaAlfanumerico		VARCHAR(50),
			@psIdViaje						VARCHAR(50),
			@psIdFacturaAlfa			    VARCHAR(50),
			@ServerName						VARCHAR(50),
			@sNomArchivo					VARCHAR(1000),
			@sRutaTemp						VARCHAR(1000),
			@sId							VARCHAR(100),
			@sNomArchivoRSS					VARCHAR(1000),
			@nExisteArchivo					INT,
			@nIndice						INT,
			@sComandoDinamico				VARCHAR(8000),
			@Count							INT,
			@sRutaReportesName				VARCHAR(1000),
			@FormatoCertificado			    INT,
			@pnIdViaje						INT,
			@pnIdFactura					INT,
			@psIdioma						VARCHAR(10),
			@pnClaCliente					INT,
			@pnDiametro						INT,
			@psNombreCliente				VARCHAR(500),
			@pnIdCertificado				INT,
			@psNomUnidad                    VARCHAR(250),
			@psObservaciones				VARCHAR(250),
			@pscultureName					VARCHAR(50),
			@pnColada						INT,
			@pnDiamMM						INT,
			@NombreRep						VARCHAR(250),
			@psNumeroFactura				VARCHAR(250),
			@psCiudad						VARCHAR(250),
			@pnKgsTotal						INT,
			@psNombreUbicacion				VARCHAR(250),
			@psNomArticulo					VARCHAR(250),
			@pnIdPlanCarga					INT,
			@psNota							VARCHAR(1000),
			@psDireccion					VARCHAR(500),
			@pnClaTipoImpresion			    INT,
			@pnIdFabricacion				INT,
			@psClavesRollo					VARCHAR(50),
			@sqlUpdate						VARCHAR(MAX),
			@pdf							VARBINARY(MAX),
			@HostName						VARCHAR(100),
			@pnEsVistaPrevia				INT,
			@pnIdOpm						INT,
			@pnCantidad						INT,
			@psFactura						VARCHAR(100),
			@psDiametro						NVARCHAR(200),
			@psLongitud						NVARCHAR(200),
			@psEspecificacion				NVARCHAR(200),
			@psTipo							NVARCHAR(200),
			@psGrado						NVARCHAR(200),
			@psConstruccion					NVARCHAR(200),
			@psLubrication					NVARCHAR(200),
			@psCoreType						NVARCHAR(200),
			@psTorcido						NVARCHAR(200),
			@psAcabado						NVARCHAR(200),
			@psTipoConstruccion				NVARCHAR(200),
			@psFirma						NVARCHAR(200),
			@psNombreUsuario				NVARCHAR(200),
			@psPuesto						NVARCHAR(200),
			@psLongitudTotal				NVARCHAR(200)
		
	CREATE TABLE #reportes
				(orden			        INT,
				 ClaFormatoImpresion	INT,
				 NombreReporte			VARCHAR(500),
				 pnClaUbicacion			INT,
				 ClaUbicacion			INT NULL,
				 IdViaje				INT NULL,
				 pnIdViaje				INT NULL,
				 pnNumVersion			INT NULL,
				 NumVersion				INT NULL,
				 IdPlanCarga			INT NULL,
				 IdBoleta				INT NULL,
				 IdTipoConcepto			INT NULL,
				 IdTabular				INT NULL,
				 IdMovEntSal			INT,
				 IdFactura				INT NULL,
				 IdOrdenEnvioCU66P1		INT NULL,
				 PorcReal				NUMERIC(19,2) NULL,
				 PorcCub				NUMERIC(19,2) NULL,
				 Montacarguista			VARCHAR(500),
				 ClaCliente				INT NULL, 
				 NombreCliente			VARCHAR (250) NULL, 
				 Ciudad					VARCHAR (250) NULL, 
				 IdCertificado			INT NULL, 
				 KgsTotal				NUMERIC (28, 3) NULL, 
				 NumeroFactura			VARCHAR (250) NULL, 
				 NomArticulo			VARCHAR (500) NULL, 
				 NombreUbicacion		VARCHAR (50) NULL, 
				 Nota					VARCHAR (500) NULL, 
				 Direccion				VARCHAR (500) NULL, 
				 ClaTipoImpresion		INT NULL, 
				 IdFabricacion			INT NULL, 
				 NomUnidad				VARCHAR (100) NULL,
				 psClaIdioma			VARCHAR (5) NULL,
				 ClavesRollo			VARCHAR(8000) NULL,
				 NomIsoIdioma			VARCHAR(3) NULL,
				 ClaPais				INT NULL,
				 cultureName		    VARCHAR (5) NULL,
				 ClaIdioma				VARCHAR (5) NULL,
				 EsVistaPrevia			INT NULL,
				 IdOpm					INT  NULL,
				 Cantidad				NUMERIC (28, 3) NULL,
				 Factura				VARCHAR (250) NULL  ,  
				 Diametro				VARCHAR(250)NULL,
				 Longitud				VARCHAR(250)NULL,
				 Especificacion			VARCHAR(250)NULL,
				 Tipo					VARCHAR(250)NULL,
				 ClaFactura				INT,
				 RemisionSN				INT,
				 EnPlanta				INT,
				 CopiaTranspSN			INT,
				 ClaViaje				INT,
				 ClaFabricacion			INT,
				 EsStayTuff				INT,
				 Idioma					VARCHAR(2),
				 EsExportarPDF			INT,
				 EsLandscape			INT,
				 Grado					VARCHAR(250),
				 Construccion			VARCHAR(250),
				 Lubrication			VARCHAR(250),
				 CoreType				VARCHAR(250),
				 Torcido				VARCHAR(250),
				 Acabado				VARCHAR(250),
				 TipoConstruccion		VARCHAR(250),
				 Firma					VARBINARY(MAX),
				 NombreUsuario			VARCHAR(250),
				 Puesto					VARCHAR(250),
				 LongitudTotal			VARCHAR(250),
				 psIdioma				VARCHAR(10),
				 ClaUbicacionOrigen		INT,
				 ClaArticulo			INT,
				 Observaciones			VARCHAR(1000),
				 Colada					INT,
				 DiamMM					INT,
				 IdCertificadoR			INT,
				 ClaIdiomaR				INT)

			 
	CREATE TABLE #SalidaComando (SalidaComando VARCHAR(8000))
	CREATE TABLE #PDFbinary (pdf VARBINARY(max))
			 
	CREATE Table #TempNoFactDigs ( 
		Seleccionar				BIT,	
		id						INT,
		IdFactura				INT , 
		IdFacturaAlfanumerico	VARCHAR(30), 
		IdViaje					INT ,
		ContFactDigitalizadas	INT
	)

	CREATE TABLE #TmpFormatos (
		  Id		INT IDENTITY(1,1)
		, IdFormato	INT
	)

	select @HostName = HOST_NAME()

		   
	IF NOT EXISTS (select top 1  IdRegitro from Operacion.OpeSch.OpeBitReimpresionDigital (NOLOCK)
				   order by IdRegitro desc)
	BEGIN
		SELECT @IdTemp = 1

	END
	ELSE
	BEGIN
		SELECT top 1  @IdTemp = IdRegitro + 1 from Operacion.OpeSch.OpeBitReimpresionDigital (NOLOCK)
		ORDER BY IdRegitro desc

	END


	DECLARE @tbFacturas TABLE(
		  Id		INT IDENTITY(1,1)
		, IdFactura	VARCHAR(30)
	)

	IF ISNULL(@psFacturaFiltro,'') <> ''
	BEGIN
		INSERT INTO @tbFacturas
		SELECT DISTINCT LTRIM(RTRIM(Value))
		FROM OPESch.OpeSplitFn(@psFacturaFiltro, ',')
	END

	---- Obtengo las facturas no digitalizadas	-- Hv
	INSERT INTO #TempNoFactDigs (Seleccionar,  
								 id, 
								 IdFactura,  
								 IdFacturaAlfanumerico, 
								 IdViaje, 
								 ContFactDigitalizadas)	
	SELECT	DISTINCT
			Seleccionar				=  0,  
			id						= 1, 
			a.IdFactura,  
			a.IdFacturaAlfanumerico, 
			a.IdViaje, 
			ContFactDigitalizadas	= 0
	FROM	OPESch.OPETraMovEntSal a WITH(NOLOCK)
	INNER JOIN OPESch.OpeReporteFactura b WITH(NOLOCK)
	ON		a.ClaUbicacion	= b.ClaUbicacion
	AND		a.IdFactura		= b.IdFactura
	AND		b.ClaFormatoImpresion = 27
	LEFT JOIN @tbFacturas c
	ON		a.IdFactura = c.IdFactura
	WHERE	a.ClaUbicacion = @pnClaUbicacion
	AND		(@psFacturaFiltro = '' OR (a.IdFactura = c.IdFactura))
	
	IF @pnDebug = 1
		SELECT '' AS '#TempNoFactDigs', * FROM #TempNoFactDigs

	 --Inserto los formatos en la bitacora 
	SELECT 
		   IdFactura			 AS IdFactura,
		   IdFacturaAlfanumerico AS IdFacturaAlfanumerico,
		   IdViaje               AS IdViaje,
		   ContFactDigitalizadas AS ContFactDigitalizadas
	INTO #TempBitacoraFactura 
	FROM #TempNoFactDigs
	ORDER BY IdFactura ASC



	IF @pnDebug = 1
		SELECT '' AS '#TempBitacoraFactura', * FROM #TempBitacoraFactura


	SELECT @CountWh = COUNT(*) FROM #TempBitacoraFactura

	--- Inserto las facturas que se van a digitalizar en  [OpeBitReimpresionDigital]
	WHILE @CountWh > 0
	BEGIN
		SELECT TOP 1 @nIdFactura		= IdFactura, 
					 @psIdViaje			= IdViaje,
					 @psIdFacturaAlfa	= IdFacturaAlfanumerico
		FROM	#TempBitacoraFactura

		--exec [OpeSch].[OPE_CU71_Pag4_Grid_GridDetalleFact_IU_Hv] @pnClaUbicacion,0,@IdTemp,2,1,@nIdFactura , @psIdFacturaAlfa , @psIdViaje
		--------------------------------------------------------
		IF 1=1--(@pnAccionSp = 2 AND @pnSeleccionar = 1)
		BEGIN
			--- Obtengo los formatos faltantes 
			DELETE FROM #TmpFormatos
			INSERT INTO #TmpFormatos  (IdFormato) VALUES (27)

			INSERT INTO [Operacion].[OpeSch].[OpeBitReimpresionDigital]
			SELECT @IdTemp,
				   @nIdFactura,
				   @psIdFacturaAlfa,
				   tf.IdFormato,
				   CONVERT(INT,@psIdViaje),
				   @pnClaUbicacion,	
				   0, --@PnClaUsuarioMod,
				   HOST_NAME(),
				   GETDATE(),
				   NULL   
			FROM #TmpFormatos tf
		END		
		--------------------------------------------------------
		
		DELETE TOP (1) FROM #TempBitacoraFactura 
		SELECT @CountWh = COUNT(*) FROM #TempBitacoraFactura
	END 

	IF @pnDebug = 1
		SELECT '' AS 'OpeBitReimpresionDigital', * FROM Operacion.OpeSch.OpeBitReimpresionDigital WITH(NOLOCK) WHERE IdRegitro = @IdTemp

	-- Obtengo los parametros de las facturas
	Insert INTO #reportes (orden,ClaFormatoImpresion ,NombreReporte,pnClaUbicacion,ClaUbicacion ,IdViaje,pnIdViaje,pnNumVersion,NumVersion,IdPlanCarga,
						   IdBoleta,IdTipoConcepto,IdTabular,IdMovEntSal,IdFactura,IdOrdenEnvioCU66P1,PorcReal,PorcCub,Montacarguista,ClaCliente,NombreCliente,
						   Ciudad,IdCertificado,KgsTotal,NumeroFactura,NomArticulo,NombreUbicacion,Nota,Direccion,ClaTipoImpresion,IdFabricacion,NomUnidad,
						   psClaIdioma,ClavesRollo,NomIsoIdioma,ClaPais,cultureName,ClaIdioma,EsVistaPrevia,IdOpm,Cantidad,Factura,Diametro,Longitud,Especificacion,
						   Tipo,ClaFactura,RemisionSN,EnPlanta,CopiaTranspSN,ClaViaje,ClaFabricacion,EsStayTuff,Idioma,EsExportarPDF,EsLandscape,Grado,Construccion,
						   Lubrication,CoreType,Torcido,Acabado,TipoConstruccion,Firma,NombreUsuario,Puesto,LongitudTotal,psIdioma,ClaUbicacionOrigen,ClaArticulo,
						   Observaciones,Colada,DiamMM,IdCertificadoR,ClaIdiomaR)
	EXEC [OpeSch].[OPE_CU71_Pag4_ImprimirSrvBack_Proc_Hv] @pnClaUbicacion, @IdTemp


	IF @pnDebug = 1
		SELECT '' AS '#reportes', * FROM #reportes ORDER BY NumeroFactura ASC


	SELECT @sRutaServidorRS = sValor1,
		   @sRutaReportesName = '/OPE/Reportes/' 
	FROM OpeSch.OpeTiCatConfiguracionVw 
	WHERE ClaUbicacion = 267--@pnClaUbicacion 
	AND ClaSistema = 127 
	AND ClaConfiguracion = 1270003
	   
	IF @pnDebug = 1
		SELECT @sRutaServidorRS AS '@sRutaServidorRS', @sRutaReportesName AS '@sRutaReportesName'

	SELECT  * 
	INTO #TmpInfoReporteFROM 
	FROM #reportes

	SELECT @Count = COUNT(*) 
	FROM #TmpInfoReporteFROM


	IF @pnDebug = 1
		SELECT '' AS '#TmpInfoReporteFROM', * FROM #TmpInfoReporteFROM


	WHILE(@Count > 0)
	BEGIN
		SELECT top 1 @sRutaReporte                   = @sRutaReportesName + r.NombreReporte ,
					 @FormatoCertificado			 = r.ClaFormatoImpresion,
					 @pnIdViaje						 = R.IdViaje,
					 @psIdioma						 = R.psClaIdioma,
					 @pnNumVersion					 = R.NumVersion,
					 @pnClaCliente					 = r.ClaCliente,
					 @pnDiametro					 = r.Diametro,
					 @psNombreCliente				 = r.NombreCliente,
					 @pnIdCertificado				 = r.IdCertificado,
					 @psNomUnidad					 = r.NomUnidad,
					 @psObservaciones				 = r.Observaciones,
					 @pscultureName					 = r.cultureName,
					 @pnColada						 = r.Colada,
					 @pnDiamMM						 = r.DiamMM,
					 @NombreRep						 = r.NombreReporte,
					 @psNombreCliente				 = R.NombreCliente,
					 @psNumeroFactura				 = r.NumeroFactura,
					 @psCiudad						 = r.Ciudad,
					 @pnKgsTotal					 = r.KgsTotal,
					 @psNombreUbicacion				 = r.NombreUbicacion,
					 @psNomArticulo					 = r.NomArticulo,
					 @pnIdPlanCarga					 = r.IdPlanCarga,
					 @psNota						 = r.Nota,
					 @psDireccion					 = r.Direccion,
					 @pnClaTipoImpresion			 = r.ClaTipoImpresion,
					 @pnIdFabricacion				 = r.IdFabricacion,
					 @psClavesRollo					 = r.ClavesRollo,
					 @pnIdFactura					 = r.IdFactura,
					 @pnEsVistaPrevia				 = EsVistaPrevia,
					 @pnIdOpm					     = r.IdOpm,
					 @pnCantidad					 = r.Cantidad,
					 @psFactura						 = Factura,
					 @psDiametro					 = R.Diametro,
					 @psLongitud					 = r.Longitud,
					 @psEspecificacion				 = R.Especificacion,
					 @psTipo						 = r.Tipo,
					 @psGrado						 = r.Grado,
					 @psConstruccion				 = R.Construccion,
					 @psLubrication					 = r.Lubrication,
					 @psCoreType					 = r.CoreType,
					 @psTorcido						 = r.Torcido,
					 @psAcabado						 = r.Acabado,
					 @psTipoConstruccion			 = r.TipoConstruccion,
					 @psFirma						 = r.Firma,
					 @psNombreUsuario				 = r.NombreUsuario,
					 @psPuesto						 = r.Puesto,
					 @psLongitudTotal				 = r.LongitudTotal,
					 @psClaIdioma					 = r.ClaIdioma			 
		FROM #TmpInfoReporteFROM R

		SET @psNomArticulo = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@psNomArticulo,'%','%%'),'^','^^'),'&','^&'),'<','^<'),'>','^>'),'|','^|'),'`','^`'),',','^,'),';','^

		;'),'=','^='),'(','^('),')','^)'),'!','^^!'),char(10),'') 

		/*	
			INSERT INTO #SalidaComando
			EXEC master.dbo.xp_cmdshell 'echo %TEMP%'

			--Obtiene la ruta en el servidor del archivo de salida temporal
			SELECT	TOP 1 @sRutaTemp = SalidaComando
			FROM #SalidaComando
		*/

		SET @sRutaTemp = 'e:\temp'

		--Crea un nombre a los archivos pdf y rss que se van a crear	
		IF ISNULL(@psNomPdf,'') = ''
		BEGIN
			SET @sId = CONVERT(VARCHAR(100),NEWID())	
		END
		ELSE
		BEGIN
			SET @sId = @psNomPdf
		END

		SET @sNomArchivo    = @sRutaTemp + '\' + @sId + '.pdf'
		SET @sNomArchivoRSS = @sRutaTemp + '\' + @sId + '.rss'	
		SET @nExisteArchivo = 0
		SET @nIndice	    = 1
 
		SELECT @pnNumVersion = isnull(NumVersion, 1) 
		FROM #reportes

		--Inserta texto al archivo
		--declara el formato del archivo de salida, el nombre del rss

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
		
		---------- 32
		IF(@FormatoCertificado = 32)
		BEGIN
			SET @sComandoDinamico = 'echo 	Dim parameters(12) As ParameterValue												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
                                                                                                                                               
			SET @sComandoDinamico = 'echo 	parameters(0) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(0).Name = "pnNumVersion"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(0).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnNumVersion),'')+'"							>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(1) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(1).Name = "pnClaUbicacion"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(1).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnClaUbicacion),'')+'"							>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(2) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(2).Name = "pnClaCliente"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(2).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnClaCliente),'')+'"							>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(3) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(3).Name = "pnDiametro"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(3).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnDiametro),'')+'"							>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(4) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(4).Name = "psNombreCliente"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(4).Value = "'+ISNULL(@psNombreCliente,'')+'"							>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(5) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(5).Name = "pnIdCertificado"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(5).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnIdCertificado),'')+'"							>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(6) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(6).Name = "psNomUnidad"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(6).Value = "'+ISNULL(@psNomUnidad,'')+'"							>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(7) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(7).Name = "psObservaciones"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(7).Value = "'+ISNULL(@psObservaciones,'')+'"							>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(8) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(8).Name = "cultureName"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(8).Value = "'+ISNULL(@pscultureName,'')+'"							>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(9) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(9).Name = "psClaIdioma"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(9).Value = "'+ISNULL(@psClaIdioma,'')+'"							>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(10) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(10).Name = "pnColada"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(10).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnColada),'')+'"							>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(11) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(11).Name = "pnDiamMM"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(11).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnDiamMM),'')+'"							>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
		END
		---------- 27
		IF(@FormatoCertificado = 27)
		BEGIN
			--- Imprimo los 6 formatos de certificados 1 4,5 Y 6
			IF (@NombreRep = 'OPE_CU70_Pag1_Rpt_CertificadoCalidad' OR @NombreRep = 'OPE_CU70_Pag1_Rpt_CertificadoHou' OR @NombreRep= 'OPE_CU70_Pag1_Rpt_CertificadoEstrobo')
			BEGIN
				IF( @NombreRep = 'OPE_CU70_Pag1_Rpt_CertificadoHou')
				BEGIN
					SET @sComandoDinamico = 'echo 	Dim parameters(35) As ParameterValue												>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
				END
				ELSE
				BEGIN
					SET @sComandoDinamico = 'echo 	Dim parameters(20) As ParameterValue												>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
				END
                                                                                                                                               
				SET @sComandoDinamico = 'echo 	parameters(0) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(0).Name = "pnNumVersion"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(0).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnNumVersion),'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(1) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(1).Name = "pnClaUbicacion"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(1).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnClaUbicacion),'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(2) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(2).Name = "pnClaCliente"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(2).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnClaCliente),'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(3) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(3).Name = "psNombreCliente"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(3).Value = "'+ISNULL(@psNombreCliente,'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(4) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(4).Name = "psNumeroFactura"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(4).Value = "'+ISNULL(CONVERT(VARCHAR(20),@psNumeroFactura),'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(5) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(5).Name = "pnIdCertificado"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(5).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnIdCertificado),'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(6) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(6).Name = "psCiudad"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(6).Value = "'+ISNULL(@psCiudad,'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(7) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(7).Name = "pnKgsTotal"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(7).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnKgsTotal),'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(8) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(8).Name = "psNombreUbicacion"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(8).Value = "'+ISNULL(@psNombreUbicacion,'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(9) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(9).Name = "psNomArticulo"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(9).Value = "'+ISNULL(@psNomArticulo,'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(10) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(10).Name = "psNomUnidad"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(10).Value = "'+ISNULL(@psNomUnidad,'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(11) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(11).Name = "pnIdViaje"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(11).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnIdViaje),'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(12) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(12).Name = "pnIdPlanCarga"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(12).Value = "'+CONVERT(VARCHAR(20),@pnIdPlanCarga)+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(13) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(13).Name = "psNota"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(13).Value = "'+ISNULL(@psNota,'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(14) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				IF( @NombreRep = 'OPE_CU70_Pag1_Rpt_CertificadoHou')
				BEGIN				
					SET @sComandoDinamico = 'echo 	parameters(14).Name = "psCultureName"													>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
				END	
				ELSE
				BEGIN
					SET @sComandoDinamico = 'echo 	parameters(14).Name = "pscultureName"													>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
				END

				SET @sComandoDinamico = 'echo 	parameters(14).Value = "'+ISNULL(@pscultureName,'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(15) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(15).Name = "psClaIdioma"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(15).Value = "'+ISNULL(@psClaIdioma,'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(16) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(16).Name = "psDireccion"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(16).Value = "'+ISNULL(@psDireccion,'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(17) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(17).Name = "pnClaTipoImpresion"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(17).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnClaTipoImpresion),'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(18) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(18).Name = "pnIdFabricacion"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(18).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnIdFabricacion),'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(19) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(19).Name = "psClavesRollo"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(19).Value = "'+ISNULL(@psClavesRollo,'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				IF (@NombreRep = 'OPE_CU70_Pag1_Rpt_CertificadoHou')
				BEGIN
					SET @sComandoDinamico = 'echo 	parameters(20) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(20).Name = "psDiametro"													>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
					SET @sComandoDinamico = 'echo 	parameters(20).Value = "'+ISNULL(@psDiametro,'')+'"							>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(21) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(21).Name = "psLongitud"													>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
					SET @sComandoDinamico = 'echo 	parameters(21).Value = "'+ISNULL(@psLongitud,'')+'"							>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(22) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(22).Name = "psEspecificacion"													>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
					SET @sComandoDinamico = 'echo 	parameters(22).Value = "'+ISNULL(@psEspecificacion,'')+'"							>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(23) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(23).Name = "psTipo"													>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
					SET @sComandoDinamico = 'echo 	parameters(23).Value = "'+ISNULL(@psTipo,'')+'"							>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(24) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(24).Name = "psGrado"													>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
					SET @sComandoDinamico = 'echo 	parameters(24).Value = "'+ISNULL(@psGrado,'')+'"							>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(25) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(25).Name = "psConstruccion"													>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
					SET @sComandoDinamico = 'echo 	parameters(25).Value = "'+ISNULL(@psConstruccion,'')+'"							>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(26) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(26).Name = "psLubrication"													>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
					SET @sComandoDinamico = 'echo 	parameters(26).Value = "'+ISNULL(@psLubrication,'')+'"							>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(27) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(27).Name = "psCoreType"													>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
					SET @sComandoDinamico = 'echo 	parameters(27).Value = "'+ISNULL(@psCoreType,'')+'"							>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(28) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(28).Name = "psTorcido"													>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
					SET @sComandoDinamico = 'echo 	parameters(28).Value = "'+ISNULL(@psTorcido,'')+'"							>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(29) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(29).Name = "psAcabado"													>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
					SET @sComandoDinamico = 'echo 	parameters(29).Value = "'+ISNULL(@psAcabado,'')+'"							>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(30) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(30).Name = "psTipoConstruccion"													>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
					SET @sComandoDinamico = 'echo 	parameters(30).Value = "'+ISNULL(@psTipoConstruccion,'')+'"							>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(31) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(31).Name = "psFirma"													>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
					SET @sComandoDinamico = 'echo 	parameters(31).Value = "'+ISNULL(@psFirma,'')+'"							>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(32) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(32).Name = "psNombreUsuario"													>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
					SET @sComandoDinamico = 'echo 	parameters(32).Value = "'+ISNULL(@psNombreUsuario,'')+'"							>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(33) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(33).Name = "psPuesto"													>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
					SET @sComandoDinamico = 'echo 	parameters(33).Value = "'+ISNULL(@psPuesto,'')+'"							>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(34) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

					SET @sComandoDinamico = 'echo 	parameters(34).Name = "psPuesto"													>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
					SET @sComandoDinamico = 'echo 	parameters(34).Value = "'+ISNULL(@psLongitudTotal,'')+'"							>> "'+@sNomArchivoRSS+'"'
					EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
				END

			END --- Imprimo los 6 formatos de certificados 1 4,5 Y 6
			----- CERTIFICADO 2 y 3 
			IF (@NombreRep = 'OPE_CU70_Pag1_Rpt_CertificadoMono' or @NombreRep = 'OPE_CU70_Pag1_Rpt_CertificadoMulti')
			BEGIN

				SET @sComandoDinamico = 'echo 	Dim parameters(11) As ParameterValue												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
                                                                                                                                               
				SET @sComandoDinamico = 'echo 	parameters(0) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(0).Name = "pnNumVersion"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(0).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnNumVersion),'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(1) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(1).Name = "pnClaUbicacion"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(1).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnClaUbicacion),'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(2) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(2).Name = "pnIdCertificado"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(2).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnIdCertificado),'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(3) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(3).Name = "psClaIdioma"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(3).Value = "'+ISNULL(@psClaIdioma,'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(4) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(4).Name = "pnEsVistaPrevia"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(4).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnEsVistaPrevia),'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(5) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(5).Name = "pnIdOpm"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(5).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnIdOpm),'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(6) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(6).Name = "psClaveRollo"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(6).Value = "'+ISNULL(@psClavesRollo,'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(7) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(7).Name = "psNombreCliente"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(7).Value = "'+ISNULL(@psNombreCliente,'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(8) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(8).Name = "pnCantidad"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(8).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnCantidad),'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(9) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(9).Name = "psNomUnidad"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(9).Value = "'+ISNULL(@psNomUnidad,'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(10) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

				SET @sComandoDinamico = 'echo 	parameters(10).Name = "psFactura"													>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
				SET @sComandoDinamico = 'echo 	parameters(10).Value = "'+ISNULL(@psFactura,'')+'"							>> "'+@sNomArchivoRSS+'"'
				EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
			END

		END	---------- 27
	
		---------- 11
		IF(@FormatoCertificado = 11)
		BEGIN

			SET @sComandoDinamico = 'echo 	Dim parameters(3) As ParameterValue												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(0) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(0).Name = "pnClaUbicacion"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(0).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnClaUbicacion),'')+'"							>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(1) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(1).Name = "pnIdViaje"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(1).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnIdViaje),'')+'"							>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(2) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

		END ---------- 11
		---------- 8
		IF(@FormatoCertificado = 8)
		BEGIN 

			SET @sComandoDinamico = 'echo 	Dim parameters(4) As ParameterValue												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(0) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(0).Name = "pnClaUbicacion"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(0).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnClaUbicacion),'')+'"							>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(1) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(1).Name = "pnIdViaje"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(1).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnIdViaje),'')+'"							>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(2) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(2).Name = "psClaIdioma"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(2).Value = "'+ISNULL(@psIdioma,'')+'"							>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(3) = New ParameterValue()												>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

			SET @sComandoDinamico = 'echo 	parameters(3).Name = "pnNumVersion"													>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
	
			SET @sComandoDinamico = 'echo 	parameters(3).Value = "'+ISNULL(CONVERT(VARCHAR(20),@pnNumVersion),'')+'"						>> "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

		END ---------- 8

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

		----Una vez que cerro el archivo lo ejecuta y dice que use Reporting Services 2005
		--SET @sComandoDinamico = 'rs -i "'+@sNomArchivoRSS+'" -s "'+ @sRutaServidorRS + '" -v FILENAME="' + @sNomArchivo + '" -v FORMAT="PDF" -e Exec2005'
		
		--Una vez que cerro el archivo lo ejecuta y dice que use Reporting Services 2005
		SET @sComandoDinamico = 'rs -i "'+@sNomArchivoRSS+'" -s "'+ @sRutaServidorRS + '" -e Exec2005'
		EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output

		IF @pnDebug = 1
			SELECT @sComandoDinamico AS '@sComandoDinamico'


		IF @@ERROR > 0
		BEGIN
			RETURN
		END
	
		--Hace una espera de 15 segundos para ver si ya se creo el archivo pdf
		WHILE @nIndice <= 15 and @nExisteArchivo <> 1
		BEGIN
			WAITFOR DELAY '00:00:01'
 
			DELETE #SalidaComando
			INSERT INTO #SalidaComando
				--EXEC master.dbo.xp_cmdshell 'dir %TEMP%'
				EXEC master.dbo.xp_cmdshell 'dir e:\temp'
 
			IF EXISTS ( SELECT 1 FROM #SalidaComando WHERE SalidaComando LIKE '%' + @sId + '.pdf%' )
				SET @nExisteArchivo = 1

			SET @nIndice = @nIndice + 1
		END

		--Elimina la tabla con la info del archivo de salida
		DELETE  #SalidaComando

		IF @pnDebug = 1
			SELECT @nExisteArchivo AS '@nExisteArchivo', @pnIdFactura AS '@pnIdFactura' ,@pnIdCertificado AS '@pnIdCertificado', @sNomArchivo AS '@sNomArchivo'
	
		--elimina regresa en un select el varbinary del pdf "delete" los pdf y rss
		IF @nExisteArchivo = 1
		BEGIN
			SET @pnError = 0
		--	SET @psRutaArchivo = @sNomArchivo
		
			SET @sComandoDinamico = 'del "'+@sNomArchivoRSS+'"'
			EXEC master.dbo.xp_cmdshell @sComandoDinamico, no_output
		
		END
		ELSE
		BEGIN
			SET @pnError = 1
			GOTO FIN
		END



			-- Obtengo el pdf 
			set @sqlUpdate = 'Declare @pdf VARBINARY(MAX)	
							  SELECT @pdf = BulkColumn
							  FROM OPENROWSET(BULK N'''+@sNomArchivo+''', SINGLE_BLOB) AS Document
							  SELECT @pdf
								'
					
			insert into #PDFbinary
			EXEC (@sqlupdate)

			SELECT @pdf = t1.pdf FROM #PDFbinary t1


			IF @pnDebug = 1
				SELECT @pdf AS '@pdf'

			INSERT INTO OpeSch.OpeTmpReporteFactura (IdFactura, IdReporteFactura,IdCertificado, Reporte, FechaUltimaMod)
			SELECT @pnIdFactura, @pnIdReporteFactura, @pnIdCertificado, @pdf, GETDATE()
			
			--SELECT * FROM #PDFbinary
			--EXEC [OpeSch].OPE_CU71_Pag4_ReporteAPDF_Proc @pnClaUbicacion,default,@pdf,@FormatoCertificado,@pnIdFactura,@pnIdCertificado,@HostName,0				
			
			FIN:
			-- Reseteo todo 
			set @sComandoDinamico = ''
			set @sqlUpdate = ''
			SET @psNomPdf = ''

			DELETE TOP(1) FROM #TmpInfoReporteFROM

			SET @Count = (SELECT COUNT(*) FROM #TmpInfoReporteFROM)
			delete #PDFbinary 

	END ---- fin WHILE

END

