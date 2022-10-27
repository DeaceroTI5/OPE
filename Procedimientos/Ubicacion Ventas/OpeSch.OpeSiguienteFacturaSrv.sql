CREATE PROCEDURE OpeSch.OpeSiguienteFacturaSrv
	@pnClaUbicacion		INT,
	@pnClaCliente		INT, 		
	@pnIdViaje			INT,
	@pnIdPedido			INT,
	@pnTipoUbicacion	INT,
	@pnIdRemision		INT OUTPUT,	
	@psIdRemisionStr	VARCHAR(20) OUTPUT,
	@pnError			INT = 0 OUTPUT

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
SET @psObjetoRemoto = 'VtaAsignaRemisionViajeSrv'
 
--* Obtener conexion remota de InvIntInsertaMovEncSrv para ejecucion 
	SET @sConexionRemota = OpeSch.OpeConexionRemotaFn(@pnClaUbicacion, @pnClaSistema, @psNombreClave, @psObjetoRemoto)
 

 	-- Ubicacion de Ventas
	DECLARE @nClaUbicacionVentas INT
	
	SELECT	@nClaUbicacionVentas = ClaUbicacionVentas 
	FROM	OpeSch.OpeTiCatUbicacionVw 
	WHERE	ClaUbicacion		= @pnClaUbicacion


--* Se Executa Para Ejecucion Remota
                EXEC @sConexionRemota 						
					@nClaUbicacionVentas, --@pnClaUbicacion,
					@pnClaCliente,
					@pnIdViaje,
					@pnIdPedido,
					@pnTipoUbicacion,
					@pnIdRemision output,
					@psIdRemisionStr output,
					@pnError output
 
 
