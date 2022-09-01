USE Operacion
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag34_ValidacionesProc
	  @pnClaUsuario				INT
	, @pnClaTipoUbicacion		INT
	, @pnClaUbicacionCfg		INT
	, @pnDebug					TINYINT = 0
AS
BEGIN
		SET NOCOUNT ON

		DECLARE @tValidaCfgUsuario	TABLE(
			  ClaTipoUbicacionCfg	INT
			, ClaUbicacionCfg		INT
		)

		DECLARE	  @sNomTipoUbicacionCfg		VARCHAR(30)
				, @sMsjError				VARCHAR(300)
				, @sUsuario					VARCHAR(160)

	
		INSERT INTO @tValidaCfgUsuario (ClaTipoUbicacionCfg, ClaUbicacionCfg)
		SELECT    a.ClaTipoUbicacion
				, a.ClaUbicacion
		FROM	OpeSch.OpeCfgUsuarioTraspaso a WITH(NOLOCK)
		WHERE	a.ClaUsuario			= @pnClaUsuario
		AND		(	a.ClaTipoUbicacion	<> @pnClaTipoUbicacion 
					OR a.ClaUbicacion	<> @pnClaUbicacionCfg
				)
		AND		a.BajaLogica = 0



		SELECT	@sNomTipoUbicacionCfg	= ltrim(rtrim(NombreTipoUbicacion)) 
		FROM	Opesch.OpeTiCatTipoUbicacionVw 
		WHERE	ClaTipoUbicacion = @pnClaTipoUbicacion


		SELECT	@sUsuario = LTRIM(RTRIM(NomUsuario)) 
		FROM	OpeSch.OpeTiCatUsuarioVw 
		WHERE	ClaUsuario = @pnClaUsuario


		IF @pnDebug = 1
			SELECT '' AS '@tValidaCfgUsuario' , * FROM @tValidaCfgUsuario

		
		----* Validación: Ingresa parámetros todos & todos y ya existen registros
		IF @pnClaTipoUbicacion = -1 AND @pnClaUbicacionCfg = -1
		AND	EXISTS (
			SELECT	1
			FROM	@tValidaCfgUsuario
		)
		BEGIN
			SET @sMsjError = 'Para el usuario <b>'+@sUsuario+'</b> ya existen registros de otras ubicaciones especificas.  Favor de verificar.'
			RAISERROR(@sMsjError, 16,1)
			RETURN
		END

		----* Validación: Ingresa un regisro y ya existe registro todos & todos
		IF EXISTS (
			SELECT	1
			FROM	@tValidaCfgUsuario
			WHERE	ClaTipoUbicacionCfg		= -1 -- Todos
			AND		ClaUbicacionCfg			= -1 -- Todos
		)
		BEGIN
			SET @sMsjError = 'Para el usuario <b>'+@sUsuario+'</b> ya existe un registro de <b>Todos</b> los tipos de ubicación y <b>Todas</b> las ubicaciones. Favor de verificar.'
			RAISERROR(@sMsjError, 16,1)
			RETURN
		END

		----* Validación: Ingresa parámetro de Ubicación todas y ya existen registros para ese tipo de Ubicación
		IF @pnClaTipoUbicacion <> -1 AND @pnClaUbicacionCfg = -1
		AND	EXISTS (
			SELECT	1
			FROM	@tValidaCfgUsuario
			WHERE	ClaTipoUbicacionCfg = @pnClaTipoUbicacion
		)
		BEGIN
			SET @sMsjError = 'Para el usuario <b>'+@sUsuario+'</b> ya existen registros con ubicaciones especificas del tipo <b> '+@sNomTipoUbicacionCfg+'</b>. Favor de verificar.'
			RAISERROR(@sMsjError, 16,1)
			RETURN
		END	

		----* Validación: Ingresa un registro y ya existe registro para ese tipo Ubicación y todas las Ubicaciones
		IF EXISTS (
			SELECT	1
			FROM	@tValidaCfgUsuario
			WHERE	ClaTipoUbicacionCfg	= @pnClaTipoUbicacion
			AND		ClaUbicacionCfg		= -1 -- Todos
		)
		BEGIN
			SET @sMsjError = 'Para el usuario <b>'+@sUsuario+'</b> ya existe un registro de <b>Todas</b> las Ubicaciones del tipo <b>'+@sNomTipoUbicacionCfg+'</b>. Favor de verificar.'
			RAISERROR(@sMsjError, 16,1)
			RETURN
		END


		SET NOCOUNT OFF
END