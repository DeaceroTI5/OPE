USE Operacion
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag34_Grid_CfgUsuarioTraspaso_IU
	  @pnClaUsuario				INT
	, @pnClaTipoUbicacion		INT
	, @pnClaUbicacionCfg		INT
	, @pnEsUsuarioCancelaSolicitud TINYINT = 0
	, @pnEsUsuarioCancelaPedido TINYINT = 0
	, @pnEsUsuarioAutorizador	TINYINT = 0
	, @pnBajaLogica				TINYINT = 0
	, @pnClaUsuarioMod			INT
	, @psNombrePcMod			VARCHAR(64)
	, @pnAccionSp				INT = -1
	, @pnDebug					TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	---/*Validaciones*/
	
	IF @pnAccionSp = 1 -- Revisa nuevos registros
	OR	EXISTS(		SELECT  1
					FROM	OpeSch.OpeCfgUsuarioTraspaso WITH(NOLOCK)
					WHERE	ClaUsuario			= @pnClaUsuario
					AND		ClaTipoUbicacion	= @pnClaTipoUbicacion
					AND		ClaUbicacion		= @pnClaUbicacionCfg
					AND		BajaLogica			= 1
	)
	BEGIN
		EXEC OPESch.OPE_CU550_Pag34_ValidacionesProc
			  @pnClaUsuario				= @pnClaUsuario			
			, @pnClaTipoUbicacion		= @pnClaTipoUbicacion	
			, @pnClaUbicacionCfg		= @pnClaUbicacionCfg	
			, @pnDebug					= @pnDebug				
	END
	----------------------------------------------------------------------------	
	IF NOT EXISTS(	SELECT  1
					FROM	OpeSch.OpeCfgUsuarioTraspaso WITH(NOLOCK)
					WHERE	ClaUsuario			= @pnClaUsuario
					AND		ClaTipoUbicacion	= @pnClaTipoUbicacion
					AND		ClaUbicacion		= @pnClaUbicacionCfg
			)
	BEGIN
		INSERT INTO OpeSch.OpeCfgUsuarioTraspaso(
			  ClaUsuario
			, ClaTipoUbicacion
			, ClaUbicacion
			, EsUsuarioCancelaSolicitud
			, EsUsuarioCancelaPedido
			, EsUsuarioAutorizador
			, BajaLogica
			, FechaBajaLogica
			, ClaUsuarioMod
			, NombrePcMod
			, FechaUltimaMod
			, FechaIns
		)
		VALUES(
			  @pnClaUsuario
			, @pnClaTipoUbicacion
			, @pnClaUbicacionCfg
			, @pnEsUsuarioCancelaSolicitud
			, @pnEsUsuarioCancelaPedido
			, @pnEsUsuarioAutorizador
			, @pnBajaLogica
			, NULL
			, @pnClaUsuarioMod
			, @psNombrePcMod
			, GETDATE()
			, GETDATE()		
		)
	END
	ELSE
	BEGIN
		IF(@pnAccionSp = 3)  
			SET @pnBajaLogica = 1  

		UPDATE	OpeSch.OpeCfgUsuarioTraspaso
		SET		  EsUsuarioCancelaSolicitud	= @pnEsUsuarioCancelaSolicitud
				, EsUsuarioCancelaPedido = @pnEsUsuarioCancelaPedido
				, EsUsuarioAutorizador	= @pnEsUsuarioAutorizador
				, BajaLogica			= @pnBajaLogica
				, FechaBajaLogica		= CASE WHEN @pnBajaLogica = 1 THEN GETDATE() ELSE NULL END
				, FechaUltimaMod		= GETDATE()
				, ClaUsuarioMod			= @pnClaUsuarioMod
				, NombrePcMod			= @psNombrePcMod
		WHERE	ClaUsuario			= @pnClaUsuario
		AND		ClaTipoUbicacion	= @pnClaTipoUbicacion
		AND		ClaUbicacion		= @pnClaUbicacionCfg
	END

	SET NOCOUNT OFF
END
