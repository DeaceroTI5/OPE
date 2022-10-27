CREATE PROCEDURE OpeSch.Ope_CU800_Pag1_VtaCierraViajeSrv
	@pnClaUbicacion		INT,
	@pnIdViaje			INT,
	@pnRespuesta		INT OUTPUT,
	@psMensaje			varchar(250) output	
AS 
BEGIN 
	 
	DECLARE @sConexionRemota		VARCHAR(1000),
			@pnClaSistema			INT,
			@psObjetoRemoto			VARCHAR(50)
  
	SET @pnClaSistema	= 19 
	SET @psObjetoRemoto = 'VtaCierraViajeSrv'
  
  
	SET @sConexionRemota = OPESch.OpeConexionRemota2Fn(@pnClaUbicacion, @pnClaSistema, @psObjetoRemoto)
  
  
	-- Ubicacion de Ventas
	DECLARE @nClaUbicacionVentas INT
	
	SELECT	@nClaUbicacionVentas = ClaUbicacionVentas 
	FROM	OpeSch.OpeTiCatUbicacionVw 
	WHERE	ClaUbicacion		= @pnClaUbicacion


    EXEC @sConexionRemota 						
		 @nClaUbicacionVentas, --@pnClaUbicacion,
		  @pnIdViaje,
		  @pnRespuesta	OUTPUT,
		  @psMensaje	OUTPUT
  
	
END