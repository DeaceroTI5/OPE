---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE OpeSch.OpeEmbarquesDetIuSrv
	@pnClaUbicacion		    INT,
	@pnClaViaje			    INT,
	@pnClaPedido		    INT,
	@pnNumeroRemision	    int,
	@pnRenglonPedido  	    INT,
	@pnCantidad			    NUMERIC(22,4),
	@pnKilosReales		    INT,
	@pnKilosTara		    INT,
	@pnRespuesta 		    INT = 0 OUTPUT,
	@psMensaje		        VARCHAR(250) OUTPUT,
	@psComentariosRemision	VARCHAR(5000)
As
--* Declaracion de variables locales 
DECLARE @sConexionRemota		VARCHAR(1000),
--	@pnClaUbicacion			INT,
	@pnClaSistema			INT,
	@psNombreClave			VARCHAR(50),
	@psObjetoRemoto			VARCHAR(50),
	@sRollos				VARCHAR(200),
	@nParamCarrete			INT
 
--SET @pnClaUbicacion = 5
SET @pnClaSistema = 19
SET @psNombreClave = 'VTA'
SET @psObjetoRemoto = 'VtaRecibirEmbarqueDetSrv'


	-- Ubicacion de Ventas
	DECLARE @nClaUbicacionVentas INT
	
	SELECT	@nClaUbicacionVentas = ClaUbicacionVentas 
	FROM	OpeSch.OpeTiCatUbicacionVw 
	WHERE	ClaUbicacion		= @pnClaUbicacion

 
	SELECT	@sRollos = ''
 
	SELECT	@sRollos = @sRollos + 
			CASE WHEN ROW_NUMBER() OVER(ORDER BY x.IdFabricacionDet) > 1 THEN ', '
			ELSE ''
			END + 
			Referencia4
	FROM	OpeSch.OpeTraViajeVw y (NOLOCK)
	INNER JOIN OpeSch.OpeTraPlanCargaLocInvVw x (NOLOCK)
	ON		x.ClaUbicacion = y.ClaUbicacion
	AND		x.IdPlanCarga = y.IdPlanCarga
	AND		x.IdFabricacion = @pnClaPedido
	AND		x.IdFabricacionDet = @pnRenglonPedido
	WHERE	y.ClaUbicacion = @pnClaUbicacion
	AND		y.IdViaje = @pnClaViaje
	AND		x.CantEmbarcada > 0
	AND		Referencia3 <> ''
	AND		Referencia4 <> ''
 
--* Obtener conexion remota de InvIntInsertaMovEncSrv para ejecucion 
	SET @sConexionRemota = OpeSch.OpeConexionRemotaFn(@pnClaUbicacion, @pnClaSistema, @psNombreClave, @psObjetoRemoto)
	SELECT	@nParamCarrete = nValor1 from OpeSch.OpeTiCatConfiguracionVw where ClaUbicacion = @pnClaUbicacion AND ClaSistema = 127 AND ClaConfiguracion = 1270213
--* Declaracion de variables Para Ejecucion Remota
--* N/A
	SET @sRollos = (CASE WHEN @nParamCarrete = 1 THEN @sRollos ELSE NULL END)
 
--* Se Executa para Select de Vista Remota
	EXEC @sConexionRemota 						
			@nClaUbicacionVentas, --@pnClaUbicacion,
			@pnClaViaje,
			@pnClaPedido,
			@pnNumeroRemision,
			@pnRenglonPedido,
			@pnCantidad,
			@pnKilosReales,
			@pnKilosTara,
			@pnRespuesta output,
			@psMensaje OUTPUT,
			@sRollos,
			@psComentariosRemision

	
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
		'@pnClaPedido=' + CONVERT(VARCHAR, ISNULL(@pnClaPedido,'')) + ' ' +
		'@pnNumeroRemision=' + CONVERT(VARCHAR, ISNULL(@pnNumeroRemision,'')) + ' ' +
		'@pnRenglonPedido=' + CONVERT(VARCHAR, ISNULL(@pnRenglonPedido,'')) + ' ' +
		'@pnCantidad=' + CONVERT(VARCHAR, ISNULL(@pnCantidad,0)) + ' ' +
		'@pnKilosReales=' + CONVERT(VARCHAR, ISNULL(@pnKilosReales,'')) + ' ' +
		'@pnKilosTara=' + CONVERT(VARCHAR, ISNULL(@pnKilosTara,'')) + ' ' +
        '@psComentariosRemision=' + ISNULL(@psComentariosRemision,'') + ' ' +
		'@sRollos=' + CONVERT(VARCHAR, ISNULL(@sRollos,'')) + ' ',
		GETDATE(),
		NULL,
		NULL

