USE Operacion
GO
-- EXEC SP_HELPTEXT 'OpeSch.OPE_CU550_Pag37_GeneraCertificadoFilial'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag37_GeneraCertificadoFilial
	  @pnClaUbicacion		INT
	, @psNumFacturaFilial	VARCHAR(20) = ''
	, @pnIdFacturaFilial	INT = NULL
	, @pnEsRegenerarCertificado TINYINT = 0
	, @pnClaAceria			INT = NULL
	, @pnDebug				TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT	 @pnDebug					= ISNULL(@pnDebug,0)
			,@pnEsRegenerarCertificado	= ISNULL(@pnEsRegenerarCertificado,0)


	IF @pnDebug =1
		SELECT 'Proc OPE_CU550_Pag37_GeneraCertificadoFilial'

	--SP ejecutado como Job para crear los certificados
	DECLARE @Relaciones TABLE 
	(
		Id					INT IDENTITY(1,1),
		IdRelFactura		INT,
		ClaUbicacionFilial	INT,
		NumFacturaFilial	VARCHAR(50),
		IdFacturaFilial		INT,
		ClaUbicacionOrigen	INT,
		NumFacturaOrigen	VARCHAR(50),
		IdFacturaOrigen		INT,
		MensajeError		VARCHAR(250),
		ClaTipoUbicacion	INT
	)

	DECLARE @tbCertificados TABLE (
		  Id			INT IDENTITY(1,1)
		, IdCertificado	INT
	)

	DECLARE @tbCertificadosRegenerar TABLE (
		  Id			INT IDENTITY(1,1)
		, EsRegenerar	INT
		, IdCertificado	INT
	)

	DECLARE @nId					INT,
			@nIdRelFactura			INT,
			@nClaUbicacionFilial	INT,
			@sNumFacturaFilial		VARCHAR(50),
			@nIdFacturaFilial		INT,
			@nClaUbicacionOrigen	INT,
			@sNumFacturaOrigen		VARCHAR(50),
			@nIdFacturaOrigen		INT,
			@nIdCertificado			INT,
			@sNumCertificado		VARCHAR(500),
	--		@nClaEstatus			TINYINT,
			@sMensajeError			VARCHAR(500),
			@iArchivo				VARBINARY(MAX),
			@nClaTipoUbicacion		INT,
			@nNumError				INT,
			@sErrorMsj				VARCHAR(1000),
			@nEsRegeneraCertificado TINYINT,
			@sIdCertificado			VARCHAR(1000),
			@nClaAceria				INT,
			@nExisteArchivoAceria	TINYINT = 0


	
	INSERT INTO @Relaciones
	(
		ClaUbicacionFilial,
		IdRelFactura,
		NumFacturaFilial,
		IdFacturaFilial,
		ClaUbicacionOrigen,
		NumFacturaOrigen,
		IdFacturaOrigen,
		MensajeError,
		ClaTipoUbicacion
	)
	SELECT	a.ClaUbicacion,
			a.IdRelFactura,
			a.NumFacturaFilial,
			a.IdFacturaFilial,
			a.ClaUbicacionOrigen,
			a.NumFacturaOrigen,
			a.IdFacturaOrigen,
			a.MensajeError,
			b.ClaTipoUbicacion
	FROM	OpeSch.OpeRelFacturaSuministroDirecto a WITH(NOLOCK)
	LEFT JOIN OPESch.OpeTiCatUbicacionVw b
	ON		a.ClaUbicacion = b.ClaUbicacion
	WHERE	(@pnClaUbicacion IS NULL OR (a.ClaUbicacion = @pnClaUbicacion))
	AND		(@psNumFacturaFilial = '' OR (NumFacturaFilial = @psNumFacturaFilial))
	AND		(@pnIdFacturaFilial IS NULL OR (IdFacturaFilial = @pnIdFacturaFilial))
	AND		(@pnClaAceria IS NULL OR (ClaAceriaOrigen = @pnClaAceria))
--	AND		ClaEstatus <> 3 -- Pendiente y En Proceso
	AND		ClaEstatus IN (1,2) -- Pendiente y En Proceso
	AND		a.BajaLogica = 0
	
	--Cambio a estatus 2 para prevenir doble ejecución del los certificados
	UPDATE	RelFactFilial
	SET		RelFactFilial.ClaEstatus = 2		--En proceso
	FROM	OpeSch.OpeRelFacturaSuministroDirecto RelFactFilial
	INNER JOIN @Relaciones RelProceso
	ON		RelFactFilial.ClaUbicacion = RelProceso.ClaUbicacionFilial
	AND		RelFactFilial.IdRelFactura = RelProceso.IdRelFactura

	IF @pnDebug = 1
		SELECT	'' AS '@Relaciones',* FROM	@Relaciones


	SELECT	@nId = MIN(Id)
	FROM	@Relaciones

	WHILE @nId IS NOT NULL
	BEGIN
		--BEGIN TRAN GeneraCertificado
		SELECT	  @nIdCertificado	= NULL
				, @sNumCertificado	= NULL
				, @sMensajeError	= NULL
				, @iArchivo			= NULL
				, @nIdFacturaFilial = NULL
				, @nIdFacturaOrigen	= NULL
				, @nClaTipoUbicacion = NULL
				, @nNumError		= 0
				, @nEsRegeneraCertificado	= 0
				, @sIdCertificado	= ''
				, @nIdRelFactura	= NULL

		SELECT @nClaUbicacionFilial		= ClaUbicacionFilial,
				@sNumFacturaFilial		= NumFacturaFilial,
				@nIdFacturaFilial		= IdFacturaFilial,
				@nClaUbicacionOrigen	= ClaUbicacionOrigen,
				@sNumFacturaOrigen		= NumFacturaOrigen,
				@nIdFacturaOrigen		= IdFacturaOrigen,
				@sMensajeError			= MensajeError,
				@nClaTipoUbicacion		= ClaTipoUbicacion,
				@nIdRelFactura			= IdRelFactura
		FROM	@Relaciones
		WHERE	Id = @nId

		BEGIN TRY
			IF @nClaTipoUbicacion IN (2)	-- Acerias
			BEGIN
				SELECT 'Acerias'
				--Regresar numcertificado e idcertificado
				EXEC DEAOFINET04.Operacion.AceSch.AceGeneraCertificadoSumDirectoSrv
					@pnClaUbicacion			=	@nClaUbicacionFilial,
					@psNumFacturaFilial		=	@sNumFacturaFilial,
					@pnClaUbicacionOrigen	=	@nClaUbicacionOrigen,
					@psNumFacturaOrigen		=	@sNumFacturaOrigen,
					@pnIdCertificado		=	@nIdCertificado		OUT,
					@psNumeroCertificado	=	@sNumCertificado	OUT,
					@piArchivoCertificado	=	@iArchivo,
					@pnClaEstatus			=	@nNumError			OUT,
					@psMensajeError			=	@sMensajeError		OUT,
					@pnDebug				=	@pnDebug
				
				SET @sIdCertificado = CONVERT(VARCHAR(20),@nIdCertificado)

				IF @pnDebug =1
				BEGIN
					SELECT 'Acerias', @nId AS '@nId', @sIdCertificado as '@sIdCertificado', @sMensajeError AS '@sMensajeError', Error = ISNULL(ERROR_MESSAGE(),'') + ' [' + ISNULL(ERROR_PROCEDURE(),'') +']'
				END
			END
			ELSE
			BEGIN
				IF ISNULL(@pnEsRegenerarCertificado,0) = 1
				BEGIN
					SELECT @nEsRegeneraCertificado = 1
				END
				ELSE
				--Revisión previa de Certificado
				IF EXISTS (
					SELECT	1
					FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK)
					WHERE	ClaUbicacion	= @nClaUbicacionFilial
					AND		IdFactura		= @nIdFacturaFilial
				)
				BEGIN
						--SELECT	  @nEsRegeneraCertificado = CASE	WHEN Archivo IS NULL THEN 1 
						--											ELSE 0 END
						--		, @sIdCertificado = CONVERT(VARCHAR(20),IdCertificado)
						--FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK)
						--WHERE	ClaUbicacion	= @nClaUbicacionFilial
						--AND		IdFactura		= @nIdFacturaFilial

						INSERT INTO @tbCertificadosRegenerar (EsRegenerar, IdCertificado)
						SELECT	EsRegenerar = CASE	WHEN Archivo IS NULL THEN 1 
																	ELSE 0 END
								,IdCertificado
						FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK)
						WHERE	ClaUbicacion	= @nClaUbicacionFilial
						AND		IdFactura		= @nIdFacturaFilial

						IF EXISTS (
							SELECT	1
							FROM	@tbCertificadosRegenerar
							WHERE	EsRegenerar = 1
						)
						BEGIN
							SELECT @nEsRegeneraCertificado = 1
						END
						ELSE
						BEGIN
							SELECT @sIdCertificado = 
							STUFF(
								  (
      								SELECT ', ' + RTRIM(LTRIM(CONVERT(VARCHAR(20),IdCertificado))) 
									FROM @tbCertificadosRegenerar 
									GROUP BY IdCertificado
									FOR XML PATH ('')
								  )
							, 1, 1, '')

							GOTO SALTO	-- Ya existe Certificado
						END				
				END

				SET @sIdCertificado = ''
				SELECT 'Otros Certificados'

				IF ISNULL(@pnEsRegenerarCertificado,0) = 0
					SELECT @pnClaAceria = NULL

				EXEC DEAOFINET04.Operacion.ACESch.AceGeneraCertificadoPuntoLogisticoSrv
					@pnClaUbicacion			= @nClaUbicacionFilial,
					@pnIdFactura			= @nIdFacturaFilial,
					@pnClaUbicacionOrigen	= @nClaUbicacionOrigen,
					@pnIdFacturaOrigen		= @nIdFacturaOrigen,
					@pnEsRegeneraCertificado = @nEsRegeneraCertificado,
					@psNombrePcMod			= 'GeneraCertificadoFilial',
					@pnClaUsuarioMod		= 1,
					@psIdCertificado		= @sIdCertificado	OUT,
					@pnClaEstatus			= @nNumError		OUT,
					@psMensajeError			= @sMensajeError	OUT,
					@pnClaAceria			= @pnClaAceria

				IF ISNULL(@sIdCertificado,'') <> '' AND @nNumError IS NULL
					SELECT @nNumError = 0

				IF @pnDebug =1
				BEGIN
					SELECT 'Otros Cert', @nId AS '@nId', @sIdCertificado as '@sIdCertificado', @sMensajeError AS '@sMensajeError', Error = ISNULL(ERROR_MESSAGE(),'') + ' [' + ISNULL(ERROR_PROCEDURE(),'') +']', @nEsRegeneraCertificado AS '@nEsRegeneraCertificado'
				END
		
			END
		END TRY
		BEGIN CATCH
			SET @sErrorMsj = NULL
			SELECT @sErrorMsj = ERROR_MESSAGE() + ' [' + ERROR_PROCEDURE() +']'

			IF @pnDebug =1
				SELECT @sErrorMsj AS '@sErrorMsj'

			IF ISNULL(@sIdCertificado,'') = '' AND ISNULL(@sErrorMsj,'') <> ''
			BEGIN
				SELECT	  @nNumError	 = -1
						, @sMensajeError = ISNULL(@sMensajeError,'') + ISNULL(@sErrorMsj,'')
			END

			IF @pnDebug =1
			BEGIN
				SELECT 'CATCH ERROR', @nId AS '@nId', @sIdCertificado as '@sIdCertificado', @sMensajeError AS '@sMensajeError', Error = ISNULL(ERROR_MESSAGE(),'') + ' [' + ISNULL(ERROR_PROCEDURE(),'') +']'
			END

		END CATCH	

		IF(@nNumError = 0) -- No hubo errores o ya existe el certificado
		BEGIN
			SALTO:

			DECLARE   @dFecha		DATETIME
					, @nUsuario		INT
					, @sUsuario		VARCHAR(200)
					, @nIdCert		INT
			
			IF ISNULL(@sIdCertificado,'') <> ''
			BEGIN
				INSERT INTO @tbCertificados (IdCertificado)
				SELECT DISTINCT LTRIM(RTRIM(string))
				FROM OPESch.OPEUtiSplitStringFn(@sIdCertificado, ',')

				SELECT	@nIdCert = MIN(Id)
				FROM	@tbCertificados 

				WHILE @nIdCert IS NOT NULL
				BEGIN
					SELECT	  @nIdCertificado	= NULL
							, @sUsuario			= ''
							, @iArchivo			= NULL
							, @nUsuario			= NULL
							, @dFecha			= NULL
							, @sNumCertificado	= NULL
							, @nExisteArchivoAceria = 0

					SELECT	@nIdCertificado = IdCertificado
					FROM	@tbCertificados 
					WHERE	Id = @nIdCert
					----------------------
					SELECT  @iArchivo = Archivo
							,@nUsuario = ClaUsuarioMod
							,@dFecha	= FechaUltimaMod
							,@nClaAceria = ClaUbicacionOrigen
							--,@sNumCertificado = CASE	WHEN ISNULL(@sNumCertificado,'') <> '' 
							--							THEN  @sNumCertificado
							--							ELSE NumCertificado END
							,@sNumCertificado = NumCertificado
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
			
					IF	@nIdCertificado IS NOT NULL 
					AND @iArchivo IS NOT NULL 
					BEGIN
						EXEC OpeSch.OpeRelFacturaSuministroDirectoIU
							  @pnClaUbicacionFilial	= @nClaUbicacionFilial
							, @psNumFacturaFilial	= @sNumFacturaFilial
							, @pnIdFacturaFilial	= @nIdFacturaFilial
							, @pnClaUbicacionOrigen	= @nClaUbicacionOrigen
							, @psNumFacturaOrigen	= @sNumFacturaOrigen
							, @pnIdFacturaOrigen	= @nIdFacturaOrigen
							, @psMensajeError		= @sMensajeError
							, @pnIdCertificado		= @nIdCertificado
							, @psNumCertificado		= @sNumCertificado
							, @pnClaAceria			= @nClaAceria
							, @psArchivo			= @iArchivo

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

					------------------------
					SELECT	@nIdCert = MIN(Id)
					FROM	@tbCertificados 
					WHERE	Id > @nIdCert
				END
			END
		END
		ELSE
		BEGIN
			SELECT @sErrorMsj = ERROR_MESSAGE() + ' [' + ERROR_PROCEDURE() +']'
			SELECT @sMensajeError = ISNULL(@sMensajeError, @sErrorMsj)

			UPDATE	OpeSch.OpeRelFacturaSuministroDirecto
			SET		ClaEstatus		= 4,
					NumError		= @nNumError, 
					MensajeError	= @sMensajeError,
					FechaUltimaMod	= GETDATE()
			WHERE	ClaUbicacion	= @nClaUbicacionFilial
			AND		IdRelFactura	= @nIdRelFactura
		END
		

		SELECT	@nId = MIN(Id)
		FROM	@Relaciones
		WHERE	Id > @nId
	END

	SET NOCOUNT OFF
END