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
		IdFacturaOrigen		INT,
		MensajeError		VARCHAR(250),
		ClaTipoUbicacion	INT
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
		IdFacturaOrigen,
		MensajeError,
		ClaTipoUbicacion
	)
	SELECT	a.ClaUbicacion,
			NumFacturaFilial,
			IdFacturaFilial,
			ClaUbicacionOrigen,
			NumFacturaOrigen,
			IdFacturaOrigen,
			MensajeError,
			ClaTipoUbicacion
	FROM	OpeSch.OpeRelFacturaSuministroDirecto a WITH(NOLOCK)
	LEFT JOIN OPESch.OpeTiCatUbicacionVw b
	ON		a.ClaUbicacion = b.ClaUbicacion
	WHERE	(@pnClaUbicacion IS NULL OR (a.ClaUbicacion = @pnClaUbicacion))
	AND		(@psNumFacturaFilial = '' OR (NumFacturaFilial = @psNumFacturaFilial))
	AND		(@pnIdFacturaFilial IS NULL OR (IdFacturaFilial = @pnIdFacturaFilial))
--	AND		ClaEstatus <> 3 -- Generado
	AND		ClaEstatus < 3 -- Pendiente y En Proceso
	AND		a.BajaLogica = 0
	
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
		--BEGIN TRAN GeneraCertificado
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
				@nIdFacturaOrigen		= IdFacturaOrigen,
				@sMensajeError			= MensajeError,
				@nClaTipoUbicacion		= ClaTipoUbicacion
		FROM	@Relaciones
		WHERE	Id = @nId

		BEGIN TRY
			IF @nClaTipoUbicacion IN (2)	-- Acerias
			BEGIN
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
				BEGIN
					SELECT 'Acerias', @nId AS '@nId', @nIdCertificado as '@nIdCertificado', @nClaUbicacionFilial AS '@nClaUbicacionFilial', @nIdFacturaFilial AS '@nIdFacturaFilial'
					,@nClaUbicacionOrigen AS '@nClaUbicacionOrigen', @nIdFacturaOrigen AS '@nIdFacturaOrigen', @sNumFacturaFilial AS '@sNumFacturaFilial', @sNumFacturaOrigen AS '@sNumFacturaOrigen'
					, @nIdCertificado AS IdCertificado, @sMensajeError AS MensajeError , @nClaEstatus AS ClaEstatus, @nClaTipoUbicacion as '@nClaTipoUbicacion'
				END
			END
			ELSE
			BEGIN		
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
					@pbArchivo				= @iArchivo 

				-- Si el registro no se pudo generar previamente, regenera el certificado.
				IF ISNULL(@nClaEstatus,0) = 8
				BEGIN
					EXEC DEAOFINET04.Operacion.ACESch.AceGeneraCertificadoSobrePuntoLogisticoSrv
						@pnClaUbicacion			= @nClaUbicacionFilial,
						@pnIdFactura			= @nIdFacturaFilial,
						@pnClaUbicacionOrigen	= @nClaUbicacionOrigen,
						@pnIdFacturaOrigen		= @nIdFacturaOrigen,
						@pnEsRegeneraCertificado = 1,
						@psNombrePcMod			= 'GeneraCertificadoFilial',
						@pnClaUsuarioMod		= 1,
						@pnIdCertificado		= @nIdCertificado OUT,
						@pnClaEstatus			= @nClaEstatus OUT,
						@psMensajeError			= @sMensajeError OUT,
						@pbArchivo				= @iArchivo 				
				END

				IF @pnDebug =1
				BEGIN
					SELECT 'Bodegas Deacero, Patios, Bodegas Ansa, CEDIS', @nId AS '@nId', @nIdCertificado as '@nIdCertificado', @nClaUbicacionFilial AS '@nClaUbicacionFilial', @nIdFacturaFilial AS '@nIdFacturaFilial'
					,@nClaUbicacionOrigen AS '@nClaUbicacionOrigen', @nIdFacturaOrigen AS '@nIdFacturaOrigen', @sNumFacturaFilial AS '@sNumFacturaFilial', @sNumFacturaOrigen AS '@sNumFacturaOrigen'
					, @nIdCertificado AS IdCertificado, @sMensajeError AS MensajeError , @nClaEstatus AS ClaEstatus, @nClaTipoUbicacion as '@nClaTipoUbicacion'
				END
			
			END
		
		--COMMIT TRAN GeneraCertificado
		END TRY
		BEGIN CATCH

			IF @pnDebug =1
			BEGIN
				SELECT 'error', @nId AS '@nId', @nIdCertificado as '@nIdCertificado', @nClaUbicacionFilial AS '@nClaUbicacionFilial', @nIdFacturaFilial AS '@nIdFacturaFilial'
				,@nClaUbicacionOrigen AS '@nClaUbicacionOrigen', @nIdFacturaOrigen AS '@nIdFacturaOrigen', @sNumFacturaFilial AS '@sNumFacturaFilial', @sNumFacturaOrigen AS '@sNumFacturaOrigen'
				, @nIdCertificado AS IdCertificado, @sMensajeError AS MensajeError , @nClaEstatus AS ClaEstatus, @nClaTipoUbicacion as '@nClaTipoUbicacion'
			END

			IF @nClaTipoUbicacion <> 2 AND @nClaEstatus = 1
			BEGIN
				SET @nClaEstatus  = 0 -- Ya existe un certificado
			END

			--ROLLBACK TRAN GeneraCertificado

			DECLARE @sMsj VARCHAR(MAX)
			SELECT @sMsj = ERROR_MESSAGE()
			SELECT @sMsj 

			UPDATE	OpeSch.OpeRelFacturaSuministroDirecto
			SET		ClaEstatus		= 4,--@nClaEstatus, 
					MensajeError	= @sMsj,
					FechaUltimaMod	= GETDATE()
			WHERE	ClaUbicacion	= @nClaUbicacionFilial
			AND		NumFacturaFilial = @sNumFacturaFilial
		
		END CATCH

		--IF @pnDebug = 1
		--	SELECT @nIdCertificado as '@nIdCertificado', @nClaEstatus AS '@nClaEstatus', @sMsj as '@sMsj'

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
				SELECT @sMensajeError = 'Certificado ya existe. Fecha generado: '+CONVERT(VARCHAR,@dFecha,20)+ '. Usuario que generó:' + ISNULL(@sUsuario,'')
			END

			IF @pnDebug = 1
				SELECT 'PASÓ', @nIdCertificado AS '@nIdCertificado', @nClaUbicacionFilial AS '@nClaUbicacionFilial', @sNumFacturaFilial AS '@sNumFacturaFilial'
			
			
			IF @nIdCertificado IS NOT NULL AND @iArchivo IS NOT NULL
			BEGIN
				UPDATE	OpeSch.OpeRelFacturaSuministroDirecto
				SET		ClaEstatus		= 3,
						MensajeError	= @sMensajeError,
						NumCertificado	= @sNumCertificado,
						IdCertificado	= @nIdCertificado,
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