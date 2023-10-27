CREATE PROCEDURE OpeSch.OPE_CU550_Pag41_Grid_GridRemisionDeAcero_Sel
    @pnClaUbicacion				INT,
	@pnCmbUbicacionOrigen		INT,
	@pnIdViajeOrigen			INT	= NULL,
	@psIdFacturaAlfanumerica	VARCHAR(20) = NULL,
	@pnClaUsuarioMod			INT = NULL,
	@psNombrePcMod				VARCHAR(64) = NULL,
	@pnDebug					INT	= NULL
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@nExisteRegistro		INT = 0,
		@nIdBoletaOrigen		INT	= NULL,
		@nIdViajeOrigen			INT	= NULL,
		@nIdFactura				INT = NULL,
		@sFacturaAlfanumerica	VARCHAR(20) = NULL,
		@sServidorUrl			VARCHAR(500) = NULL,
		@sServidorApp			VARCHAR(50) = NULL,
		@sServidorBD			VARCHAR(50) = NULL,
		@sLinkedServer			VARCHAR(500) = NULL

	IF	EXISTS(	SELECT	1
				FROM	OpeSch.OpeTraRemisionesDeAceroSD WITH(NOLOCK)
				WHERE	ClaUbicacionOrigen	= @pnCmbUbicacionOrigen
				AND		(	IdViajeOrigen	= @pnIdViajeOrigen
					OR		Remision		= @psIdFacturaAlfanumerica ))
	BEGIN
		SET	@nExisteRegistro	= 1
	END

	--Creación de Registro en Tabla Transaccional
	IF	ISNULL( @nExisteRegistro, 0 ) = 0
	BEGIN 
		SELECT	TOP 1
				@sServidorUrl		= ServidorUrl
		FROM	TICENTRAL.TiCatalogo.dbo.TiCatAplicacion WITH(NOLOCK)
		WHERE	ClaUbicacion		= @pnCmbUbicacionOrigen
		AND		IdAplicacion		IN ('OPE','AMP')
		AND		ServidorUrl			LIKE '%APP%'

		SET		@sServidorApp		= SUBSTRING( @sServidorUrl, ( CHARINDEX( '://', @sServidorUrl) + 3 ),  CHARINDEX( ':', @sServidorUrl, CHARINDEX( '://', @sServidorUrl ) + 1) - ( CHARINDEX( '://', @sServidorUrl) + 3 ))

		IF	ISNULL( @pnDebug, 0 ) =  1
		BEGIN
			SELECT	sServidorUrl	= @sServidorUrl,
					sServidorApp	= @sServidorApp
		END

		--Escenario de Patios
		IF	ISNULL( @sServidorApp, '' ) LIKE '%PATNET%'
		BEGIN
			--Consulta de Servidor BD de la Ubicación de Patios
			SELECT	@sServidorBD	= NomServidor
			FROM	AMP_DEAPATNET02_LNKSVR.Operacion.AMPsch.AmpRelUbicacionServidorVw WITH(NOLOCK)
			WHERE	ClaUbicacion	= @pnCmbUbicacionOrigen

			--Identificar Linked Server a Usar
			SELECT	@sLinkedServer	= name
			FROM	sys.servers
			WHERE	data_source		= @sServidorBD

			--Identificar Viaje, IdFactura y Remision en Servidor de BD
			IF	ISNULL( @sLinkedServer, '' ) = 'AMP_DEAPATNET02_LNKSVR'
			BEGIN
				IF	ISNULL( @psIdFacturaAlfanumerica, '' ) != ''
				BEGIN
					SELECT	@nIdBoletaOrigen		= IdBoleta,
							@nIdFactura				= NumFactura,
							@sFacturaAlfanumerica	= IdFacturaAlfanumerico
					FROM	AMP_DEAPATNET02_LNKSVR.Operacion.AMPsch.AmpRelRegistroEntradaFactura WITH(NOLOCK)
					WHERE	ClaUbicacion			= @pnCmbUbicacionOrigen
					AND		IdFacturaAlfanumerico	= @psIdFacturaAlfanumerica

					SELECT	@nIdViajeOrigen			= IdViaje
					FROM	AMP_DEAPATNET02_LNKSVR.Operacion.AMPSch.AmpTraViaje
					WHERE	ClaUbicacion			= @pnCmbUbicacionOrigen
					AND		IdBoleta				= @nIdBoletaOrigen
				END			
			END
			ELSE IF	ISNULL( @sLinkedServer, '' ) = 'AMP_DEAPATNET03_LNKSVR'
			BEGIN
				IF	ISNULL( @psIdFacturaAlfanumerica, '' ) != ''
				BEGIN
					SELECT	@nIdBoletaOrigen		= IdBoleta,
							@nIdFactura				= NumFactura,
							@sFacturaAlfanumerica	= IdFacturaAlfanumerico
					FROM	AMP_DEAPATNET03_LNKSVR.Operacion.AMPsch.AmpRelRegistroEntradaFactura WITH(NOLOCK)
					WHERE	ClaUbicacion			= @pnCmbUbicacionOrigen
					AND		IdFacturaAlfanumerico	= @psIdFacturaAlfanumerica

					SELECT	@nIdViajeOrigen			= IdViaje
					FROM	AMP_DEAPATNET03_LNKSVR.Operacion.AMPSch.AmpTraViaje
					WHERE	ClaUbicacion			= @pnCmbUbicacionOrigen
					AND		IdBoleta				= @nIdBoletaOrigen
				END
			END
			ELSE IF	ISNULL( @sLinkedServer, '' ) = 'AMP_DEAPATNET04_LNKSVR'
			BEGIN
				IF	ISNULL( @psIdFacturaAlfanumerica, '' ) != ''
				BEGIN
					SELECT	@nIdBoletaOrigen		= IdBoleta,
							@nIdFactura				= NumFactura,
							@sFacturaAlfanumerica	= IdFacturaAlfanumerico
					FROM	AMP_DEAPATNET04_LNKSVR.Operacion.AMPsch.AmpRelRegistroEntradaFactura WITH(NOLOCK)
					WHERE	ClaUbicacion			= @pnCmbUbicacionOrigen
					AND		IdFacturaAlfanumerico	= @psIdFacturaAlfanumerica

					SELECT	@nIdViajeOrigen			= IdViaje
					FROM	AMP_DEAPATNET04_LNKSVR.Operacion.AMPSch.AmpTraViaje
					WHERE	ClaUbicacion			= @pnCmbUbicacionOrigen
					AND		IdBoleta				= @nIdBoletaOrigen
				END
			END
			ELSE IF	ISNULL( @sLinkedServer, '' ) = 'AMP_DEAPATNET05_LNKSVR'
			BEGIN
				IF	ISNULL( @psIdFacturaAlfanumerica, '' ) != ''
				BEGIN
					SELECT	@nIdBoletaOrigen		= IdBoleta,
							@nIdFactura				= NumFactura,
							@sFacturaAlfanumerica	= IdFacturaAlfanumerico
					FROM	AMP_DEAPATNET05_LNKSVR.Operacion.AMPsch.AmpRelRegistroEntradaFactura WITH(NOLOCK)
					WHERE	ClaUbicacion			= @pnCmbUbicacionOrigen
					AND		IdFacturaAlfanumerico	= @psIdFacturaAlfanumerica

					SELECT	@nIdViajeOrigen			= IdViaje
					FROM	AMP_DEAPATNET05_LNKSVR.Operacion.AMPSch.AmpTraViaje
					WHERE	ClaUbicacion			= @pnCmbUbicacionOrigen
					AND		IdBoleta				= @nIdBoletaOrigen
				END
			END

			IF	ISNULL( @pnDebug, 0 ) =  1
			BEGIN
				SELECT	sServidorBD				= @sServidorBD,
						sLinkedServer			= @sLinkedServer,
						nIdBoletaOrigen			= @nIdBoletaOrigen,
						nIdViajeOrigen			= @nIdViajeOrigen,
						nIdFactura				= @nIdFactura,
						sFacturaAlfanumerica	= @sFacturaAlfanumerica
			END

			--Registrar Remision a Cargar en Tabla Transaccional
			INSERT	INTO OpeSch.OpeTraRemisionesDeAceroSD (ClaUbicacion, ClaUbicacionOrigen, IdViajeOrigen, IdFactura, Remision, ServidorUrl, ServidorApp, ServidorBD, LinkedServerDB,
															FechaUltimaMod, NombrePcMod, ClaUsuarioMod, ArchivosComprimidos)
			SELECT	@pnClaUbicacion,
					@pnCmbUbicacionOrigen,
					@nIdViajeOrigen,
					@nIdFactura,
					@sFacturaAlfanumerica,
					@sServidorUrl,
					UPPER(@sServidorApp),
					UPPER(@sServidorBD),
					UPPER(@sLinkedServer),
					GETDATE(),
					@psNombrePcMod,
					@pnClaUsuarioMod,
					0

			IF	ISNULL( @pnDebug, 0 ) =  1
			BEGIN
				SELECT	*
				FROM	OpeSch.OpeTraRemisionesDeAceroSD
			END
		END
		--ELSE IF	ISNULL( @sServidorApp, '' ) LIKE '%BODNET%'
		--BEGIN
		--	--Escenario de Bodegas, Alambres y MacroHub
		--END
	END

	SELECT	ColUbicacionOrigen		= CONVERT(VARCHAR, T1.ClaUbicacion) + ' - ' + T1.NombreUbicacion,
			ColViajeOrigen			= T0.IdViajeOrigen,
			ColRemisionDeAcero		= T0.Remision,
			ColGenerarRemision		= (	CASE
											WHEN	T0.Archivo IS NULL
											THEN	'Generar'
											ELSE	''
										END	),
			ColDescargaArchivo		= (	CASE
											WHEN	T0.Archivo IS NOT NULL
											THEN	'Descargar'
											ELSE	''
										END	),
			ColClaUbicacion			= T0.ClaUbicacion,
			ColClaUbicacionOrigen	= T0.ClaUbicacionOrigen,
			ColIdFactura			= T0.IdFactura
	FROM	OpeSch.OpeTraRemisionesDeAceroSD T0 WITH(NOLOCK)
	INNER JOIN	OpeSch.OpeTiCatUbicacionVw T1 WITH(NOLOCK)
		ON	T0.ClaUbicacionOrigen	= T1.ClaUbicacion
	WHERE	ClaUbicacionOrigen		= @pnCmbUbicacionOrigen
	AND		(	IdViajeOrigen		= @pnIdViajeOrigen
		OR		Remision			= @psIdFacturaAlfanumerica )
	
	SET NOCOUNT OFF
END