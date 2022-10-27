CREATE PROCEDURE OpeSch.Ope_CU800_Pag1_VtaAsignaRemisionViajeSrv
	@pnClaUbicacion		INT,
	@pnClaCliente		INT, 		
	@pnIdViaje			INT,
	@pnIdPedido			INT,
	@pnTipoUbicacion	INT,
	@pnIdRemision		INT OUTPUT,	
	@psIdRemisionStr	VARCHAR(20) OUTPUT,
	@pnError			INT = 0 OUTPUT
AS 
BEGIN 
	 
	DECLARE @sConexionRemota		VARCHAR(1000),
			@pnClaSistema			INT,
			@psObjetoRemoto			VARCHAR(50)
  
	SET @pnClaSistema	= 19 
	SET @psObjetoRemoto = 'VtaAsignaRemisionViajeSrv'
  
  
	SET @sConexionRemota = OPESch.OpeConexionRemota2Fn(@pnClaUbicacion, @pnClaSistema, @psObjetoRemoto)
  

	-- Ubicacion de Ventas
	DECLARE @nClaUbicacionVentas INT
	
	SELECT	@nClaUbicacionVentas = ClaUbicacionVentas 
	FROM	OpeSch.OpeTiCatUbicacionVw 
	WHERE	ClaUbicacion		= @pnClaUbicacion

  
      EXEC @sConexionRemota 						
			 @nClaUbicacionVentas, --@pnClaUbicacion,
			 @pnClaCliente,
			 @pnIdViaje,
			 @pnIdPedido,
			 @pnTipoUbicacion,
			 @pnIdRemision output,
			 @psIdRemisionStr output,
			@pnError output
 
 
	
END