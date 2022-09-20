USE Operacion
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag38_Grid_MotivosRechazo_IU
	  @pnClaMotivoRechazoSol	INT
	, @psNomMotivoRechazoSol	VARCHAR(300)
	, @pnBajaLogica				INT  
	, @psNombrePcMod			VARCHAR(64)  
	, @pnClaUsuarioMod			INT
	, @pnAccionSp				TINYINT = -1 
AS
BEGIN
	SET NOCOUNT ON

	IF NOT EXISTS (
		SELECT	1
		FROM	OpeSch.OpeCatMotivoRechazoSolTraspasoVw 
		WHERE	ClaMotivoRechazoSolTraspaso = @pnClaMotivoRechazoSol
	)
	BEGIN
		/*Asigna Id renglon para los nuevos registros*/  
		SELECT  @pnClaMotivoRechazoSol = ISNULL(MAX(ClaMotivoRechazoSolTraspaso),0) + 1        
		FROM	OpeSch.OpeCatMotivoRechazoSolTraspasoVw   
		

		INSERT INTO OpeSch.OpeCatMotivoRechazoSolTraspasoVw(
			  ClaMotivoRechazoSolTraspaso
			, NomMotivoRechazoSolTraspaso
			, BajaLogica
			, FechaBajaLogica
			, ClaUsuarioMod
			, FechaUltimaMod
			, NombrePcMod		
		)
		VALUES(
			  @pnClaMotivoRechazoSol
			, @psNomMotivoRechazoSol
			, @pnBajaLogica
			, NULL
			, @pnClaUsuarioMod
			, GETDATE()
			, @psNombrePcMod
		)
	END
	ELSE
	BEGIN
		IF(@pnAccionSp = 3)  
			SET @pnBajaLogica = 1  

		UPDATE OpeSch.OpeCatMotivoRechazoSolTraspasoVw  
		SET   
				  NomMotivoRechazoSolTraspaso	= @psNomMotivoRechazoSol
				, BajaLogica					= @pnBajaLogica  
				, FechaBajaLogica				=	CASE	WHEN @pnBajaLogica = 1 
															THEN GETDATE() ELSE NULL END 
				, NombrePcMod					= @psNombrePcMod  
				, ClaUsuarioMod					= @pnClaUsuarioMod  
				, FechaUltimaMod				= GETDATE()
		WHERE	ClaMotivoRechazoSolTraspaso = @pnClaMotivoRechazoSol 		
	END

	SET NOCOUNT OFF
END

