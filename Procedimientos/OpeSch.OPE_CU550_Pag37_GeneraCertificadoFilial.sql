USE Operacion
GO
	-- 'OpeSch.OPE_CU550_Pag37_GeneraCertificadoFilial'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag37_GeneraCertificadoFilial
	  @pnClaUbicacion		INT
	, @psNumFacturaFilial	VARCHAR(20) = ''
	, @pnIdFacturaFilial	INT = NULL
	, @pnDebug				TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT @pnDebug = ISNULL(@pnDebug,0)
	IF @pnDebug =1
		SELECT 'Proc OPE_CU550_Pag37_GeneraCertificadoFilial'

	--SP ejecutado como Job para crear los certificados
	DECLARE @Relaciones TABLE 
	(
		Id					INT IDENTITY(1,1),
		ClaUbicacionFilial	INT,
		NumFacturaFilial	VARCHAR(50),
		IdFacturaFilial		INT,
		ClaUbicacionOrigen	INT,
		NumFacturaOrigen	VARCHAR(50),
		IdFacturaOrigen		INT
	)

	DECLARE @nId					INT,
			@nClaUbicacionFilial	INT,
			@sNumFacturaFilial		VARCHAR(50),
			@nIdFacturaFilial		INT,
			@nClaUbicacionOrigen	INT,
			@sNumFacturaOrigen		VARCHAR(50),
			@nIdFacturaOrigen		INT,
			@nIdCertificado			INT,
			@sNumCertificado		VARCHAR(500),
			@nClaEstatus			TINYINT,
			@sMensajeError			VARCHAR(250),
			@iArchivo				VARBINARY(MAX),
			@nClaTipoUbicacion		INT

	
	INSERT INTO @Relaciones
	(
		ClaUbicacionFilial,
		NumFacturaFilial,
		IdFacturaFilial,
		ClaUbicacionOrigen,
		NumFacturaOrigen,
		IdFacturaOrigen
	)
	SELECT	ClaUbicacion,
			NumFacturaFilial,
			IdFacturaFilial,
			ClaUbicacionOrigen,
			NumFacturaOrigen,
			IdFacturaOrigen
	FROM	OpeSch.OpeRelFacturaSuministroDirecto WITH(NOLOCK)
	WHERE	(@pnClaUbicacion IS NULL OR (ClaUbicacion = @pnClaUbicacion))
	AND		(@psNumFacturaFilial = '' OR (NumFacturaFilial = @psNumFacturaFilial))
	AND		(@pnIdFacturaFilial IS NULL OR (IdFacturaFilial = @pnIdFacturaFilial))
	AND		ClaEstatus <> 3 -- Generado
	AND		BajaLogica = 0
	
	--Cambio a estatus 2 para prevenir doble ejecución del los certificados
	UPDATE	RelFactFilial
	SET		RelFactFilial.ClaEstatus = 2		--En proceso
	FROM	OpeSch.OpeRelFacturaSuministroDirecto RelFactFilial
	INNER JOIN @Relaciones RelProceso
	ON		RelFactFilial.ClaUbicacion = RelProceso.ClaUbicacionFilial
	AND		RelFactFilial.NumFacturaFilial = RelProceso.NumFacturaFilial

	IF @pnDebug = 1
		SELECT	'' AS '@Relaciones',* FROM	@Relaciones

	SELECT	@nId = MIN(Id)
	FROM	@Relaciones

	WHILE @nId IS NOT NULL
	BEGIN
		SELECT	  @nIdCertificado	= NULL
				, @sNumCertificado	= NULL
				, @nClaEstatus		= NULL
				, @sMensajeError	= NULL
				, @iArchivo			= NULL
				, @nIdFacturaFilial = NULL
				, @nIdFacturaOrigen	= NULL
				, @nClaTipoUbicacion = NULL

		SELECT @nClaUbicacionFilial		= ClaUbicacionFilial,
				@sNumFacturaFilial		= NumFacturaFilial,
				@nIdFacturaFilial		= IdFacturaFilial,
				@nClaUbicacionOrigen	= ClaUbicacionOrigen,
				@sNumFacturaOrigen		= NumFacturaOrigen,
				@nIdFacturaOrigen		= IdFacturaOrigen
		FROM	@Relaciones
		WHERE	Id = @nId

		IF @pnDebug =1
			SELECT @nId AS '@nId', @nClaUbicacionFilial AS '@nClaUbicacionFilial', @sNumFacturaFilial AS '@sNumFacturaFilial', @nIdFacturaFilial AS '@nIdFacturaFilial'
					, @nClaUbicacionOrigen AS '@nClaUbicacionOrigen', @sNumFacturaOrigen AS '@sNumFacturaOrigen', @nIdFacturaOrigen AS '@nIdFacturaOrigen'


		SELECT	@nClaTipoUbicacion = ClaTipoUbicacion
		FROM	OPESch.OpeTiCatUbicacionVw 
		WHERE	ClaUbicacion = @nClaUbicacionOrigen


		BEGIN TRY
			IF @nClaTipoUbicacion IN (3,4,7)
			BEGIN
				IF @pnDebug =1
					SELECT 'Bodegas Deacero, Patios, CEDIS'

				EXEC DEAOFINET04.Operacion.ACESch.AceGeneraCertificadoSobrePuntoLogisticoSrv
				@pnClaUbicacion			= @nClaUbicacionFilial,
				@pnIdFactura			= @nIdFacturaFilial,
				@pnClaUbicacionOrigen	= @nClaUbicacionOrigen,
				@pnIdFacturaOrigen		= @nIdFacturaOrigen,
				@pnEsRegeneraCertificado = 0,
				@psNombrePcMod			= 'GeneraCertificadoFilial',
				@pnClaUsuarioMod		= 1,
				@pnIdCertificado		= @nIdCertificado OUT,
				@pnClaEstatus			= @nClaEstatus OUT,
				@psMensajeError			= @sMensajeError OUT,
				@pbArchivo				= @iArchivo --OUT
 
				IF @pnDebug =1
					SELECT @nIdCertificado AS IdCertificado, @sMensajeError AS MensajeError , @nClaEstatus AS ClaEstatus--, @iArchivo AS Archivo
			END
			ELSE 
			IF @nClaTipoUbicacion IN (2, 5)
			BEGIN
				IF @pnDebug =1
					SELECT 'Acerias, Bodegas Ansa'

				--Regresar numcertificado e idcertificado
				EXEC DEAOFINET04.Operacion.AceSch.AceGeneraCertificadoSumDirectoSrv
					@pnClaUbicacion			=	@nClaUbicacionFilial,
					@psNumFacturaFilial		=	@sNumFacturaFilial,
					@pnClaUbicacionOrigen	=	@nClaUbicacionOrigen,
					@psNumFacturaOrigen		=	@sNumFacturaOrigen,
					@pnIdCertificado		=	@nIdCertificado		OUT,
					@psNumeroCertificado	=	@sNumCertificado	OUT,
					@piArchivoCertificado	=	@iArchivo,
					@pnClaEstatus			=	@nClaEstatus		OUT,
					@psMensajeError			=	@sMensajeError		OUT,
					@pnDebug				=	@pnDebug
				
				IF @pnDebug =1
					SELECT @nIdCertificado AS IdCertificado
			END
		END TRY
		BEGIN CATCH
			DECLARE @sMsj VARCHAR(MAX)
			SELECT @sMsj = ERROR_MESSAGE()
			SELECT @sMsj 

			UPDATE	OpeSch.OpeRelFacturaSuministroDirecto
			SET		ClaEstatus = @nClaEstatus, 
					MensajeError = @sMsj,
					FechaUltimaMod = GETDATE()
			WHERE	ClaUbicacion = @nClaUbicacionFilial
			AND		NumFacturaFilial = @sNumFacturaFilial
			
		END CATCH

		IF @pnDebug = 1
			SELECT @nClaEstatus AS '@nClaEstatus'

		IF(@nClaEstatus <> 0)
		BEGIN
			UPDATE	OpeSch.OpeRelFacturaSuministroDirecto
			SET		ClaEstatus = @nClaEstatus, 
					MensajeError = @sMensajeError,
					FechaUltimaMod = GETDATE()
			WHERE	ClaUbicacion = @nClaUbicacionFilial
			AND		NumFacturaFilial = @sNumFacturaFilial
		END
		ELSE
		BEGIN
			DECLARE   @dFecha		DATETIME
					, @nUsuario		INT
					, @sUsuario		VARCHAR(200)


			SELECT  @iArchivo = Archivo
					,@nUsuario = ClaUsuarioMod
					,@dFecha	= FechaUltimaMod
					,@sNumCertificado = CASE	WHEN ISNULL(@sNumCertificado,'') <> '' 
												THEN  @sNumCertificado
												ELSE NumCertificado END
			FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK)
			WHERE	ClaUbicacion = @nClaUbicacionFilial
			AND		IdCertificado = @nIdCertificado

			SELECT	@sUsuario = CONVERT(VARCHAR(10),ClaEmpleado) +' - '+ NomUsuario 
			FROM	OpeSch.OpeTiCatUsuarioVw
			WHERE	ClaUsuario = @nUsuario

			IF ISNULL(@sMensajeError,'') <> ''
			BEGIN
				SELECT @sMensajeError = 'Certificado ya existe. Fecha generado: '+CONVERT(VARCHAR,@dFecha,20)+ '. Usuario que generó:' + @sUsuario
			END

			IF @pnDebug = 1
				SELECT 'PASÓ', @iArchivo AS '@iArchivo', @nIdCertificado AS '@nIdCertificado', @nClaUbicacionFilial AS '@nClaUbicacionFilial'
			
			IF @nIdCertificado IS NOT NULL
			BEGIN
				UPDATE	OpeSch.OpeRelFacturaSuministroDirecto
				SET		ClaEstatus = 3,
						MensajeError	= @sMensajeError,
						NumCertificado = @sNumCertificado,
						IdCertificado  = @nIdCertificado,
						ArchivoCertificado = @iArchivo,
						FechaUltimaMod = GETDATE()
				WHERE	ClaUbicacion = @nClaUbicacionFilial
				AND		NumFacturaFilial = @sNumFacturaFilial

				IF NOT EXISTS (
					SELECT	1
					FROM	OpeSch.OpeReporteFactura WITH(NOLOCK)
					WHERE	ClaUbicacion	= @nClaUbicacionFilial
					AND		IdFactura		= @nIdFacturaFilial
					AND		ClaFormatoImpresion = 27	-- Certificado Calidad 
					AND		IdCertificado	= @nIdCertificado
				)
				BEGIN
					INSERT INTO OpeSch.OpeReporteFactura(
						  ClaUbicacion
						, IdFactura
						, ClaFormatoImpresion
						, IdCertificado
						, Impresion
						, FechaUltimaMod
						, NombrePcMod
						, ClaUsuarioMod
					) VALUES (
						  @nClaUbicacionFilial
						, @nIdFacturaFilial
						, 27						-- Certificado Calidad 
						, @nIdCertificado
						, @iArchivo
						, GETDATE()
						, HOST_NAME()
						, 1				
					)
				END
			END
		END

		SELECT	@nId = MIN(Id)
		FROM	@Relaciones
		WHERE	Id > @nId
	END

	SET NOCOUNT OFF
END