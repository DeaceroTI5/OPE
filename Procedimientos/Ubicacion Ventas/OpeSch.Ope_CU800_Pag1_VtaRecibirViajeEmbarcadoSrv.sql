CREATE PROCEDURE OpeSch.Ope_CU800_Pag1_VtaRecibirViajeEmbarcadoSrv
	@pnClaUbicacion		INT,
	@pnIdViaje			INT,
	@pdFechaReal		DATETIME,
	@pdFechaFact		DATETIME,
	@pnSumEmbarques		INT,
	@pnClaAgenteAduanal INT,
	@psNomAgenteAduanal VARCHAR(40),
	@pnClaTransp		INT,
	@psNomTransp		VARCHAR(40),
	@psNomChofer		VARCHAR(30),
	@psPlacas			VARCHAR(10),
	@pnTipoDeViaje		INT,
	@psPlacasCaja		VARCHAR(10),
	@pnRespuesta		INT = 0 output,
	@psMensaje			varchar(250) OUTPUT
AS 
BEGIN 
	 
	DECLARE @sConexionRemota		VARCHAR(1000),
			@pnClaSistema			INT,
			@psObjetoRemoto			VARCHAR(50)
  
	SET @pnClaSistema	= 19 
	SET @psObjetoRemoto = 'VtaRecibirViajeEmbarcadoSrv'
  
  
	SET @sConexionRemota = OPESch.OpeConexionRemota2Fn(@pnClaUbicacion, @pnClaSistema, @psObjetoRemoto)
  

	-- Ubicacion de Ventas
	DECLARE @nClaUbicacionVentas INT
	
	SELECT	@nClaUbicacionVentas = ClaUbicacionVentas 
	FROM	OpeSch.OpeTiCatUbicacionVw 
	WHERE	ClaUbicacion		= @pnClaUbicacion
	
	/*
    EXEC @sConexionRemota 	
		 @ClaUbicacion	   = @pnClaUbicacion,
		 @IdViaje		   = @pnIdViaje,
		 @FechaReal		   = @pdFechaReal,
		 @SumEmbarques	   = @pnSumEmbarques,
		 @ClaAgenteAduanal = @pnClaAgenteAduanal,
		 @NomAgenteAduanal = @psNomAgenteAduanal,
		 @ClaTransportista = @pnClaTransp,
		 @NomTransportista = @psNomTransp,
		 @NomChofer		   = @psNomChofer,
		 @Placas		   = @psPlacas,
		 @TipoDeViaje	   = @pnTipoDeViaje,
		 @PlacasCaja	   = @psPlacasCaja,
		 @Respuesta		   = @pnRespuesta out,
		 @psMensaje		   = @psMensaje out 
	 */
	 
	  EXEC @sConexionRemota 	
		 @nClaUbicacionVentas, --@pnClaUbicacion,
		 @pnIdViaje,
		 @pdFechaReal,
		 @pnSumEmbarques,
		 @pnClaAgenteAduanal,
		 @psNomAgenteAduanal,
		 @pnClaTransp,
		 @psNomTransp,
		 @psNomChofer,
		 @psPlacas,
		 @pnTipoDeViaje,
		 @psPlacasCaja,
		 @pnRespuesta out,
		 @psMensaje out 
 
	
END