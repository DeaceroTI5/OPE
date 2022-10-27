CREATE PROCEDURE OpeSch.OpeCalculaViajeSrv
		@pnClaUbicacion int, 
		@pnNumViaje int, 
		@psRespuesta INT = 0 OUT,
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
SET @psObjetoRemoto = 'VtaCalculaViajeSrv'
 
--* Obtener conexion remota de InvIntInsertaMovEncSrv para ejecucion 
	SET @sConexionRemota = OpeSch.OpeConexionRemotaFn(@pnClaUbicacion, @pnClaSistema, @psNombreClave, @psObjetoRemoto)
 

 	-- Ubicacion de Ventas
	DECLARE @nClaUbicacionVentas INT
	
	SELECT	@nClaUbicacionVentas = ClaUbicacionVentas 
	FROM	OpeSch.OpeTiCatUbicacionVw 
	WHERE	ClaUbicacion		= @pnClaUbicacion


--* Declaracion de variables Para Ejecucion Remota
--* N/A

--* Se Executa para Select de Vista Remota
                EXEC @sConexionRemota 						
				@nClaUbicacionVentas, --@pnClaUbicacion,
				@pnNumViaje,
				@psRespuesta OUT,
				@psMensaje OUTPUT

	PRINT @psMensaje

	INSERT INTO OPESch.OpeDatosEmbarqueBit
		(ClaUbicacion,
		IdViaje,
		Servicio,
		Parametros,
		FechaUltimaMod,
		NombrePcMod,
		ClaUsuarioMod)
	SELECT @pnClaUbicacion,
		@pnNumViaje,
		@sConexionRemota,
		'@pnClaUbicacion=' + CONVERT(VARCHAR, ISNULL(@nClaUbicacionVentas,'')) + ' ' +
		'@pnNumViaje=' + CONVERT(VARCHAR, ISNULL(@pnNumViaje,'')) + ' ',
		GETDATE(),
		NULL,
		NULL						


