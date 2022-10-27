CREATE PROCEDURE OpeSch.Ope_CU800_Pag1_VtaRecibirEmbarqueSrv
		@pnClaUbicacion			INT,
		@pnIdViaje				INT,
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
		@psMensaje				varchar(250) output		
AS 
BEGIN 
	 
	DECLARE @sConexionRemota		VARCHAR(1000),
			@pnClaSistema			INT,
			@psObjetoRemoto			VARCHAR(50)
  
	SET @pnClaSistema	= 19 
	SET @psObjetoRemoto = 'VtaRecibirEmbarqueSrv'
  
  
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
 
	
END