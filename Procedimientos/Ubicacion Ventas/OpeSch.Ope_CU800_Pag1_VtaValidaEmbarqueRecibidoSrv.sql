CREATE PROCEDURE OpeSch.Ope_CU800_Pag1_VtaValidaEmbarqueRecibidoSrv
		@pnClaUbicacion int, 
		@pnIdViaje		int, 
		@psRespuesta	INT = 0 OUTPUT,
		@psMensaje		varchar(250) OUTPUT
AS 
BEGIN 
	 
	DECLARE @sConexionRemota		VARCHAR(1000),
			@pnClaSistema			INT,
			@psObjetoRemoto			VARCHAR(50)
  
	SET @pnClaSistema	= 19 
	SET @psObjetoRemoto = 'VtaValidaEmbarqueRecibidoSrv'
  
  
	SET @sConexionRemota = OPESch.OpeConexionRemota2Fn(@pnClaUbicacion, @pnClaSistema, @psObjetoRemoto)
  

	-- Ubicacion de Ventas
	DECLARE @nClaUbicacionVentas INT
	
	SELECT	@nClaUbicacionVentas = ClaUbicacionVentas 
	FROM	OpeSch.OpeTiCatUbicacionVw 
	WHERE	ClaUbicacion		= @pnClaUbicacion
	

     EXEC @sConexionRemota 						
			 @nClaUbicacionVentas, --@pnClaUbicacion,
			@pnIdViaje,
			@psRespuesta OUT,
			 @psMensaje OUTPUT
  
	
END