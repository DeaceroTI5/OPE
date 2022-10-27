---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE OpeSch.OpeEmbarquesViajeIuSrv	
		@pnClaUbicacion		INT,
		@pnClaViaje		INT,
		@pdFechaReal		DATETIME,
		@pdFechaFact		DATETIME,
		@pnSumEmbarques		INT,
		@pnClaAgenteAduanal 	INT,
		@psNomAgenteAduanal 	VARCHAR(40),
		@pnClaTransp		INT,
		@psNomTransp		VARCHAR(40),
		@psNomChofer		VARCHAR(40),
		@psPlacas			VARCHAR(10),
		@pnTipoDeViaje		INT,
		@psPlacasCaja		VARCHAR(10),
		@pnRespuesta		INT = 0 output,
		@psMensaje		varchar(250) output
As
--* Declaracion de variables locales 
DECLARE
 @sConexionRemota		VARCHAR(1000),
--	@pnClaUbicacion			INT,
	@pnClaSistema			INT,
	@psNombreClave			VARCHAR(50),
	@psObjetoRemoto			VARCHAR(50)
 
--SET @pnClaUbicacion = 5
SET @pnClaSistema = 19
SET @psNombreClave = 'VTA'
SET @psObjetoRemoto = 'VtaRecibirViajeEmbarcadoSrv'
 
select @psNomChofer = SUBSTRING(@psNomChofer,1,30)
 
--* Obtener conexion remota de InvIntInsertaMovEncSrv para ejecucion 
	SET @sConexionRemota = OpeSch.OpeConexionRemotaFn(@pnClaUbicacion, @pnClaSistema, @psNombreClave, @psObjetoRemoto)
 
 
--* Declaracion de variables Para Ejecucion Remota
--* N/A
 
 	-- Ubicacion de Ventas
	DECLARE @nClaUbicacionVentas INT
	
	SELECT	@nClaUbicacionVentas = ClaUbicacionVentas 
	FROM	OpeSch.OpeTiCatUbicacionVw 
	WHERE	ClaUbicacion		= @pnClaUbicacion

--* Se Executa para Select de Vista Remota
                EXEC @sConexionRemota 	
					@nClaUbicacionVentas, --@pnClaUbicacion,
					@pnClaViaje,
					@pdFechaReal,
					@pnSumEmbarques,
					@pnClaAgenteAduanal,
					@psNomAgenteAduanal,
					@pnClaTransp,
					@psNomTransp,
					@psNomChofer,
					@psPlacas,
					@pnTipoDeViaje,
					@psPlacasCaja,
					@pnRespuesta output,
					@psMensaje output

	INSERT INTO OPESch.OpeDatosEmbarqueBit
		(ClaUbicacion,
		IdViaje,
		Servicio,
		Parametros,
		FechaUltimaMod,
		NombrePcMod,
		ClaUsuarioMod)
	SELECT @pnClaUbicacion,
		@pnClaViaje,
		@sConexionRemota,
		'@pnClaUbicacion=' + CONVERT(VARCHAR, ISNULL(@nClaUbicacionVentas,'')) + ' ' +
		'@pnClaViaje=' + CONVERT(VARCHAR, ISNULL(@pnClaViaje,'')) + ' ' +
		'@pdFechaReal=' + CONVERT(VARCHAR, ISNULL(@pdFechaReal,'')) + ' ' +
		'@pnSumEmbarques=' + CONVERT(VARCHAR, ISNULL(@pnSumEmbarques,'')) + ' ' +
		'@pnClaAgenteAduanal=' + CONVERT(VARCHAR, ISNULL(@pnClaAgenteAduanal,'')) + ' ' +
		'@psNomAgenteAduanal=' + CONVERT(VARCHAR, ISNULL(@psNomAgenteAduanal,'')) + ' ' +
		'@pnClaTransp=' + CONVERT(VARCHAR, ISNULL(@pnClaTransp,'')) + ' ' +
		'@psNomTransp=' + CONVERT(VARCHAR, ISNULL(@psNomTransp,'')) + ' ' +
		'@psNomChofer=' + CONVERT(VARCHAR, ISNULL(@psNomChofer,'')) + ' ' +
		'@psPlacas=' + CONVERT(VARCHAR, ISNULL(@psPlacas,'')) + ' ' +
		'@pnTipoDeViaje=' + CONVERT(VARCHAR, ISNULL(@pnTipoDeViaje,'')) + ' ' +
		'@psPlacasCaja=' + CONVERT(VARCHAR, ISNULL(@psPlacasCaja,'')) + ' ',
		GETDATE(),
		NULL,
		NULL

