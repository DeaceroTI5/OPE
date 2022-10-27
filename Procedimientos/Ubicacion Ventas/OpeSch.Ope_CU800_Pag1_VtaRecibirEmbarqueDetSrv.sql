CREATE PROCEDURE OpeSch.Ope_CU800_Pag1_VtaRecibirEmbarqueDetSrv
	@pnClaUbicacion		INT,
	@pnIdViaje			INT,
	@pnClaPedido		INT,
	@pnNumeroRemision	int,
	@pnRenglonPedido  	INT,
	@pnCantidad			NUMERIC(22,4),
	@pnKilosReales		INT,
	@pnKilosTara		INT,
	@pnRespuesta 		INT = 0 OUTPUT,
	@psMensaje			varchar(250) output	
AS 
BEGIN 
	 
	DECLARE @sConexionRemota		VARCHAR(1000),
			@pnClaSistema			INT,
			@psObjetoRemoto			VARCHAR(50)
  
	SET @pnClaSistema	= 19 
	SET @psObjetoRemoto = 'VtaRecibirEmbarqueDetSrv'
  
  
	SET @sConexionRemota = OPESch.OpeConexionRemota2Fn(@pnClaUbicacion, @pnClaSistema, @psObjetoRemoto)
  
 
 	-- Ubicacion de Ventas
	DECLARE @nClaUbicacionVentas INT
	
	SELECT	@nClaUbicacionVentas = ClaUbicacionVentas 
	FROM	OpeSch.OpeTiCatUbicacionVw 
	WHERE	ClaUbicacion		= @pnClaUbicacion


    EXEC @sConexionRemota 						
		 @nClaUbicacionVentas, --@pnClaUbicacion,
		 @pnIdViaje,
		 @pnClaPedido,
		 @pnNumeroRemision,
		 @pnRenglonPedido,
		 @pnCantidad,
		 @pnKilosReales,
		 @pnKilosTara,
		 @pnRespuesta output,
		 @psMensaje OUTPUT
 
	
END