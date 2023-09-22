USE Operacion
GO
-- EXEC SP_HELPTEXT 'OpeSch.OPE_CU550_Pag41_Servicio_CargaRemisionDeAcero_Proc'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag41_Servicio_CargaRemisionDeAcero_Proc
    @pnClaUbicacion				INT,
	@pnClaUbicacionOrigen		INT,
	@pnIdViajeOrigen			INT	= NULL,
	@pnIdFactura				INT = NULL,
	@pnEsImpresionPDF			INT = NULL,
	@pnTipoGeneracion			INT = NULL, --1: Patios / 2: Bodegas / , Alambres y Macrohub
	@pnClaUsuarioMod			INT = NULL,
	@psNombrePcMod				VARCHAR(64) = NULL,
	@pnEsCargarArchivo			TINYINT = 1,
	@pnEsCopiarArchivo			TINYINT = 0,
	@pnDebug					INT = 0
AS
BEGIN
	SET NOCOUNT ON

	DECLARE  
		@tResources				TABLE
		(
			Id					INT IDENTITY(1,1)
		  , ArchivoOrigen		VARCHAR(8000)
		  , ArchivoDestino		VARCHAR(8000)
		  , RutaCompletaOrigen	VARCHAR(8000)
		  , RutaCompletaDestino	VARCHAR(8000)
		)

	DECLARE
		@sFacturaAlfanumerica	VARCHAR(20) = NULL,
		@sServidorApp			VARCHAR(50) = NULL,
		@sServidorBD			VARCHAR(50) = NULL,
		@sLinkedServer			VARCHAR(500) = NULL,
		@sPathOrigen			VARCHAR(255) = NULL,
		@sArchivoOrigen			VARCHAR(8000) = NULL,
		@sRutaCompletaOrigen	VARCHAR(8000) = NULL,
		@sPathOrigenDestino		VARCHAR(255) = NULL,
		@sArchivoDestino		VARCHAR(8000) = NULL,
		@sRutaCompletaDestino	VARCHAR(8000) = NULL,
		@nId					INT = 1,
		@sql					NVARCHAR(MAX),
		@parmsdeclare			NVARCHAR(4000),
		@ObjectToken			INT,
		@sCmd					VARCHAR(1000),
		@sComando				VARCHAR(8000),
		@bArchivo				VARBINARY(MAX),
		@nEsCargarArchivo		TINYINT = @pnEsCargarArchivo,
		@nEsCopiarArchivo		TINYINT = @pnEsCopiarArchivo

	SELECT	@sFacturaAlfanumerica	= Remision,
			@sServidorApp			= ServidorApp,
			@sServidorBD			= ServidorBD,
			@sLinkedServer			= LinkedServerDB
	FROM	OpeSch.OpeTraRemisionesDeAceroSD
	WHERE	ClaUbicacionOrigen		= @pnClaUbicacionOrigen
	AND		IdViajeOrigen			= @pnIdViajeOrigen
	AND		IdFactura				= @pnIdFactura

	IF	ISNULL( @pnDebug, 0 ) =  1
	BEGIN
		SELECT	sFacturaAlfanumerica	= @sFacturaAlfanumerica,
				sServidorApp			= @sServidorApp,
				sServidorBD				= @sServidorBD,
				sLinkedServer			= @sLinkedServer
	END

	--Escenario de Patios
	IF	ISNULL( @pnTipoGeneracion, 0 ) = 1
	BEGIN
		--Identificar Linked Server a Usar y Ejecutar Servicio de Generación
		IF	ISNULL( @sLinkedServer, '' ) = 'AMP_DEAPATNET02_LNKSVR'
		BEGIN
			--Ejecución del Servicio que Genera la Remisión en la Ruta del Server
			--EXEC	[AMP_DEAPATNET02_LNKSVR].[Operacion].[AMPSch].[AMP_CU117_Pag2_Boton_ReimprimirFactura_Proc]  
			--	@pnClaUbicacion			= @pnClaUbicacionOrigen,
			--	@pnNumViajeM            = @pnIdViajeOrigen,
			--	@pnNumFacturaImprimeM   = @pnIdFactura,
			--	@pnEsImpresionPDF       = @pnEsImpresionPDF,
			--	@psNombrePcMod          = 'APPITKNET04',
			--	@pnForzarRemision       = 1

			EXEC	[AMP_DEAPATNET02_LNKSVR].[Operacion].[AMPSch].[AMPImprimeFacturaVentasProc_SOS]  
				@psFactura				= @sFacturaAlfanumerica

			--Declaración de Path Origen
			SET	@sPathOrigen	= '\\deapatnet02\Docvtas\' 
			SET	@sCmd			= 'dir ' + @sPathOrigen
		END
		ELSE IF	ISNULL( @sLinkedServer, '' ) = 'AMP_DEAPATNET03_LNKSVR'
		BEGIN
			--EXEC	[AMP_DEAPATNET03_LNKSVR].[Operacion].[AMPSch].[AMP_CU117_Pag2_Boton_ReimprimirFactura_Proc]  
			--	@pnClaUbicacion			= @pnClaUbicacionOrigen,
			--	@pnNumViajeM            = @pnIdViajeOrigen,
			--	@pnNumFacturaImprimeM   = @pnIdFactura,
			--	@pnEsImpresionPDF       = @pnEsImpresionPDF,
			--	@psNombrePcMod          = 'APPITKNET04',
			--	@pnForzarRemision       = 1

			EXEC	[AMP_DEAPATNET03_LNKSVR].[Operacion].[AMPSch].[AMPImprimeFacturaVentasProc_SOS]  
				@psFactura				= @sFacturaAlfanumerica

			--Declaración de Path Origen
			SET	@sPathOrigen	= '\\deapatnet03\Docvtas\' 
			SET	@sCmd			= 'dir ' + @sPathOrigen
		END
		ELSE IF	ISNULL( @sLinkedServer, '' ) = 'AMP_DEAPATNET04_LNKSVR'
		BEGIN
			--EXEC	[AMP_DEAPATNET04_LNKSVR].[Operacion].[AMPSch].[AMP_CU117_Pag2_Boton_ReimprimirFactura_Proc]  
			--	@pnClaUbicacion			= @pnClaUbicacionOrigen,
			--	@pnNumViajeM            = @pnIdViajeOrigen,
			--	@pnNumFacturaImprimeM   = @pnIdFactura,
			--	@pnEsImpresionPDF       = @pnEsImpresionPDF,
			--	@psNombrePcMod          = 'APPITKNET04',
			--	@pnForzarRemision       = 1

			EXEC	[AMP_DEAPATNET04_LNKSVR].[Operacion].[AMPSch].[AMPImprimeFacturaVentasProc_SOS]  
				@psFactura				= @sFacturaAlfanumerica

			--Declaración de Path Origen
			SET	@sPathOrigen	= '\\deapatnet04\Docvtas\' 
			SET	@sCmd			= 'dir ' + @sPathOrigen
		END
		ELSE IF	ISNULL( @sLinkedServer, '' ) = 'AMP_DEAPATNET05_LNKSVR'
		BEGIN
			--EXEC	[AMP_DEAPATNET05_LNKSVR].[Operacion].[AMPSch].[AMP_CU117_Pag2_Boton_ReimprimirFactura_Proc]  
			--	@pnClaUbicacion			= @pnClaUbicacionOrigen,
			--	@pnNumViajeM            = @pnIdViajeOrigen,
			--	@pnNumFacturaImprimeM   = @pnIdFactura,
			--	@pnEsImpresionPDF       = @pnEsImpresionPDF,
			--	@psNombrePcMod          = 'APPITKNET04',
			--	@pnForzarRemision       = 1

			EXEC	[AMP_DEAPATNET05_LNKSVR].[Operacion].[AMPSch].[AMPImprimeFacturaVentasProc_SOS]  
				@psFactura				= @sFacturaAlfanumerica

			--Declaración de Path Origen
			SET	@sPathOrigen	= '\\deapatnet05\Docvtas\' 
			SET	@sCmd			= 'dir ' + @sPathOrigen
		END	

		-- Hv 13/09/23 SE agrega condición de filtro
		SELECT @sCmd = @sCmd + ' /b | find "' + @sFacturaAlfanumerica + '"'


		IF	ISNULL( @pnDebug, 0 ) =  1
		BEGIN
			SELECT	sPathOrigen			= @sPathOrigen,
					sCmd				= @sCmd
		END

		--Proceso de Busqueda de Recurso
		SELECT	@sComando		=	'DECLARE @sCmd VARCHAR(8000) = ''' + @sCmd + ''' ' +
									'TRUNCATE TABLE [OpeSch].[OpeTraSalidaComandoCmdShellProcess] ' + 
									'INSERT	INTO [OpeSch].[OpeTraSalidaComandoCmdShellProcess] ( SalidaComando ) ' + 
									'EXEC	master.dbo.xp_cmdshell @sCmd'


		EXEC	[OpeSch].[OPE_CU550_Pag41_Servicio_ExecCmdShellProcess_Proc]
			@psNombreJob				= 'xp_cmdshell replacement', 
			@psSubSistema				= 'TSQL',
			@psComando					= @sComando,
			@pnDebug					= @pnDebug

		--EXEC	[dbo].[OPEServicioExecCmdShellProcess]
		--	@psNombreJob				= 'xp_cmdshell replacement',
		--	@psSubSistema				= 'TSQL',
		--	@psComando					= @sComando
			
		INSERT	INTO @tResources ( ArchivoOrigen )
		SELECT	ArchivoOrigen	= SUBSTRING( SalidaComando, CHARINDEX('Factura',SalidaComando,0), LEN(SalidaComando) ) 
		FROM	OpeSch.OpeTraSalidaComandoCmdShellProcess WITH(NOLOCK) 
		WHERE	SalidaComando	LIKE '%' + @sFacturaAlfanumerica + '%'
		AND		SalidaComando LIKE '%Factura%'			-- Hv 12/09/23  Corrección de error al encontrar más de un archivo generado (Caso de Certificado Calidad)

		UPDATE	T0
		SET		T0.RutaCompletaOrigen	= @sPathOrigen + ArchivoOrigen
		FROM	@tResources T0

		IF	ISNULL( @pnDebug, 0 ) =  1
		BEGIN
			SELECT	sComando				= @sComando,
					sFacturaAlfanumerica	= @sFacturaAlfanumerica

			SELECT	'' AS 'OpeSch.OpeTraSalidaComandoCmdShellProcess',
					*
			FROM	OpeSch.OpeTraSalidaComandoCmdShellProcess WITH(NOLOCK)  
			WHERE	SalidaComando	LIKE '%' + @sFacturaAlfanumerica + '%'

			SELECT	'' AS '@tResources',
					*
			FROM	@tResources 
		END

		--Revisión de Registros de Recursos
		SELECT	@sRutaCompletaOrigen	= RutaCompletaOrigen,
				@sRutaCompletaDestino	= RutaCompletaDestino,
				@sArchivoOrigen			= ArchivoOrigen,
				@sArchivoDestino		= ArchivoDestino
		FROM	@tResources
		WHERE	Id = @nId

		--IF	ISNULL( @pnDebug, 0 ) =  1
		--BEGIN
		--	SELECT	sRutaCompletaOrigen		= @sRutaCompletaOrigen,
		--			sRutaCompletaDestino	= @sRutaCompletaDestino,
		--			sArchivoOrigen			= @sArchivoOrigen,
		--			sArchivoDestino			= @sArchivoDestino
		--END

		--Carga de Archivo Fisico para Obtener VARBINARY
		IF @nEsCargarArchivo = 1
		BEGIN
			SET @sql =	'SELECT @bArchivo=(select * from openrowset ( 
						    bulk ''' + @sRutaCompletaOrigen + ''' 
						    ,SINGLE_BLOB) x 
						    )' 

			SET @parmsdeclare = '@bArchivo VARBINARY(MAX) OUTPUT'  

			EXEC sp_executesql @stmt = @sql 
								, @params = @parmsdeclare 
								, @bArchivo = @bArchivo OUTPUT 

			IF	ISNULL( @pnDebug, 0 ) =  1
			BEGIN
				SELECT	sRutaCompletaOrigen		= @sRutaCompletaOrigen,
						sRutaCompletaDestino	= @sRutaCompletaDestino,
						sql_cmd					= @sql,
						parmsdeclare			= @parmsdeclare,
						bArchivo				= @bArchivo
			END
		END

		--Almacenamiento de VARBINARY en Tabla Transaccionalx
		UPDATE	T0
		SET		T0.NombreArchivo		= SUBSTRING( @sArchivoOrigen, 0, CHARINDEX('.', @sArchivoOrigen) ),
				T0.Extension			= SUBSTRING( @sArchivoOrigen, CHARINDEX('.', @sArchivoOrigen) + 1, (LEN(@sArchivoOrigen) - CHARINDEX('.', @sArchivoOrigen) )),
				T0.Ruta					= @sArchivoOrigen,
				T0.Archivo				= @bArchivo
		FROM	OpeSch.OpeTraRemisionesDeAceroSD  T0
		WHERE	T0.ClaUbicacionOrigen	= @pnClaUbicacionOrigen
		AND		T0.IdViajeOrigen		= @pnIdViajeOrigen
		AND		T0.IdFactura			= @pnIdFactura

		IF	ISNULL( @pnDebug, 0 ) =  1
		BEGIN
			SELECT	'' AS 'OpeTraRemisionesDeAceroSD', *
			FROM	OpeSch.OpeTraRemisionesDeAceroSD  
			WHERE	ClaUbicacionOrigen	= @pnClaUbicacionOrigen
			AND		IdViajeOrigen		= @pnIdViajeOrigen
			AND		IdFactura			= @pnIdFactura
		END
	END

	SET NOCOUNT OFF
END