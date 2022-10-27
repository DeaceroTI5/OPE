---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE OpeSch.OpeCierraViajeSrv	
	@pnClaUbicacion	INT,
	@pnIdViaje		INT,
	@pnRespuesta		INT OUTPUT,
	@psMensaje		varchar(250) output	
As
--* Declaracion de variables locales 
DECLARE @sConexionRemota		VARCHAR(1000),
--	@pnClaUbicacion			INT,
	@pnClaSistema			INT,
	@psNombreClave			VARCHAR(50),
	@psObjetoRemoto			VARCHAR(50)
 
--SET @pnClaUbicacion = 5
SET @pnClaSistema = 19
SET @psNombreClave = 'VTA'
SET @psObjetoRemoto = 'VtaCierraViajeSrv'
 
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
				@pnIdViaje,
				@pnRespuesta OUT,
				@psMensaje OUTPUT

	INSERT INTO OPESch.OpeDatosEmbarqueBit
		(ClaUbicacion,
		IdViaje,
		Servicio,
		Parametros,
		FechaUltimaMod,
		NombrePcMod,
		ClaUsuarioMod)
	SELECT @pnClaUbicacion,
		@pnIdViaje,
		@sConexionRemota,
		'@pnClaUbicacion=' + CONVERT(VARCHAR, ISNULL(@nClaUbicacionVentas,'')) + ' ' +
		'@pnIdViaje=' + CONVERT(VARCHAR, ISNULL(@pnIdViaje,'')) + ' ',
		GETDATE(),
		NULL,
		NULL					


