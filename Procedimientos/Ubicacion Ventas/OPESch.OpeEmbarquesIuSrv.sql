---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE OPESch.OpeEmbarquesIuSrv	
		@pnClaUbicacion			INT,
		@pnClaViaje				INT,
		@pnClaPedido			INT,
		@pnNumFactura			INT,
		@psComentarios			CHAR(255),
		@pnTotalOParcial		INT,
		@pnSumCantidad			NUMERIC(22,4),
		@pnSumKilos				INT,
		@pnSumRenglones			INT,
		@pnRespuesta			INT = 0 OUTPUT,
		@psSello				VARCHAR(40),
		@pnTarimas				INT,
		@psCaja					VARCHAR(10),
		@pnClaUbicacionDestino	INT,
		@pnIdPlanCarga			INT,
		@psMensaje		varchar(250) output		
AS
--* Declaracion de variables locales 
DECLARE @sConexionRemota		VARCHAR(1000),
--	@pnClaUbicacion			INT,
	@pnClaSistema			INT,
	@psNombreClave			VARCHAR(50),
	@psObjetoRemoto			VARCHAR(50)
 
--SET @pnClaUbicacion = 5
SET @pnClaSistema = 19
SET @psNombreClave = 'VTA'
SET @psObjetoRemoto = 'VtaRecibirEmbarqueSrv'
 
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
					@pnClaPedido,
					@pnNumFactura,
					@psComentarios,
					@pnTotalOParcial,
					@pnSumCantidad,
					@pnSumKilos,
					@pnSumRenglones,
					@pnRespuesta OUTPUT,
					@psSello,
					@pnTarimas,
					@psCaja,
					@pnClaUbicacionDestino,
					@pnIdPlanCarga,
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
		@pnClaViaje,
		@sConexionRemota,
		'@pnClaUbicacion=' + CONVERT(VARCHAR, ISNULL(@nClaUbicacionVentas,'')) + ' ' +
		'@pnClaViaje=' + CONVERT(VARCHAR, ISNULL(@pnClaViaje,'')) + ' ' +
		'@pnClaPedido=' + CONVERT(VARCHAR, ISNULL(@pnClaPedido,'')) + ' ' +
		'@pnNumFactura=' + CONVERT(VARCHAR, ISNULL(@pnNumFactura,'')) + ' ' +
		'@psComentarios=' + CONVERT(VARCHAR, ISNULL(@psComentarios,'')) + ' ' +
		'@pnTotalOParcial=' + CONVERT(VARCHAR, ISNULL(@pnTotalOParcial,'')) + ' ' +
		'@pnSumCantidad=' + CONVERT(VARCHAR, ISNULL(@pnSumCantidad,0)) + ' ' +
		'@pnSumKilos=' + CONVERT(VARCHAR, ISNULL(@pnSumKilos,'')) + ' ' +
		'@pnSumRenglones=' + CONVERT(VARCHAR, ISNULL(@pnSumRenglones,'')) + ' ' +
		'@psSello=' + CONVERT(VARCHAR, ISNULL(@psSello,'')) + ' ' +
		'@pnTarimas=' + CONVERT(VARCHAR, ISNULL(@pnTarimas,'')) + ' ' +
		'@psCaja=' + CONVERT(VARCHAR, ISNULL(@psCaja,'')) + ' ' +
		'@pnClaUbicacionDestino=' + CONVERT(VARCHAR, ISNULL(@pnClaUbicacionDestino,'')) + ' ' +
		'@pnIdPlanCarga=' + CONVERT(VARCHAR, ISNULL(@pnIdPlanCarga,'')) + ' ',
		GETDATE(),
		NULL,
		NULL					

