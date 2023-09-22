/*exec OPESch.OPE_CU550_Pag41_Boton_btnGenerarRemisionDeAcero_Proc @pnClaUbicacion=324,@pnClaUbicacionOrigenDS=191,@pnIdViajeOrigenDS=317978,@pnIdFacturaDS=191026019,@psFacturaAlfanumericaDS='PP26019',@pnClaUsuarioMod=100010318,@psNombrePcMod='100-Hvalle',@pnDebug=1
*/ 

/*
EXEC OpeSch.OPE_CU550_Pag41_Servicio_CargaRemisionDeAcero_Proc
    @pnClaUbicacion				= 324,
	@pnClaUbicacionOrigen		= 191,
	@pnIdViajeOrigen			= 317978,
	@pnIdFactura				= 191026019,
	@pnEsImpresionPDF			= 0,
	@pnTipoGeneracion			= 1, --1: Patios / 2: Bodegas / , Alambres y Macrohub
	@pnClaUsuarioMod			= 100010318,
	@psNombrePcMod				= '100-Hvalle',
	@pnEsCargarArchivo			= 1,
	@pnEsCopiarArchivo			= 0,
	@pnDebug					= 1
*/

			--EXEC	[AMP_DEAPATNET03_LNKSVR].[Operacion].[AMPSch].[AMPImprimeFacturaVentasProc_SOS]  
			--	@psFactura				= 'PP26019'--@sFacturaAlfanumerica

			--SELECT	*
			--FROM	OpeSch.OpeTraRemisionesDeAceroSD  
			--WHERE	ClaUbicacionOrigen	= 191
			--AND		IdViajeOrigen		= 317978
			--AND		IdFactura			= 191026019


DECLARE	  @sComando				VARCHAR(8000)
		, @sPathOrigen			VARCHAR(1000)	
		, @sCmd					VARCHAR(1000)	
		, @sFacturaAlfanumerica VARCHAR(30)	


	SELECT @sPathOrigen = '\\deapatnet03\Docvtas\'
			, @sCmd		= 'dir ' + @sPathOrigen



	SELECT	TOP 1
			@sFacturaAlfanumerica	= Remision
	FROM	OpeSch.OpeTraRemisionesDeAceroSD
	ORDER BY FechaUltimaMod DESC

	--EXEC	master.dbo.xp_cmdshell @sCmd

	SELECT @sCmd = @sCmd + ' /b | find "' + @sFacturaAlfanumerica + '"'

		--SELECT	@sComando		=	'DECLARE @sCmd VARCHAR(8000) = ''' + @sCmd + ''' ' +
		--							'TRUNCATE TABLE [OpeSch].[OpeTraSalidaComandoCmdShellProcess] ' + 
		--							'INSERT	INTO [OpeSch].[OpeTraSalidaComandoCmdShellProcess] ( SalidaComando ) ' + 
		--							'EXEC	master.dbo.xp_cmdshell @sCmd'
	
	SELECT @sCmd
	EXEC	master.dbo.xp_cmdshell @sCmd




	--EXEC	OpeSch.OPE_CU550_Pag41_Servicio_ExecCmdShellProcess_Proc
	--		@psNombreJob	= 'xp_cmdshell replacement',
	--		@psSubSistema	= 'TSQL',
	--		@psComando		= @sComando


	--SELECT	SalidaComando
	--		, ArchivoOrigen	= SUBSTRING( SalidaComando, CHARINDEX('Factura',SalidaComando,0), LEN(SalidaComando) )
	--FROM	OpeSch.OpeTraSalidaComandoCmdShellProcess WITH(NOLOCK) 
	--WHERE	SalidaComando	LIKE '%' + 'PP26019' + '%'

--'OpeSch.OPE_CU550_Pag41_Servicio_ExecCmdShellProcess_Proc'