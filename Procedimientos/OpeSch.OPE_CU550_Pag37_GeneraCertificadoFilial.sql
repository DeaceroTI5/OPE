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

	DECLARE @tbCertificados TABLE (
		  Id			INT IDENTITY(1,1)
		, IdCertificado	INT
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
			@sMensajeError			VARCHAR(500),
			@iArchivo				VARBINARY(MAX),
			@nClaTipoUbicacion		INT,
			@nNumError				INT,
			@sErrorMsj				VARCHAR(1000),
			@nEsRegeneraCertificado TINYINT,
			@sIdCertificado			VARCHAR(1000)


	
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
--	AND		ClaEstatus <> 3 -- Pendiente y En Proceso
	AND		ClaEstatus IN (1,2) -- Pendiente y En Proceso
	AND		a.BajaLogica = 0
	
	--Cambio a estatus 2 para prevenir doble ejecuci�n del los certificados
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
				, @sMensajeError	= NULL
				, @iArchivo			= NULL
				, @nIdFacturaFilial = NULL
				, @nIdFacturaOrigen	= NULL
				, @nClaTipoUbicacion = NULL
				, @nNumError		= NULL
				, @nEsRegeneraCertificado	= 0
				, @sIdCertificado	= ''

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
					SELECT 'Acerias', @nId AS '@nId', @sIdCertificado as '@sIdCertificado', @nClaUbicacionFilial AS '@nClaUbicacionFilial', @nIdFacturaFilial AS '@nIdFacturaFilial'
					,@nClaUbicacionOrigen AS '@nClaUbicacionOrigen', @nIdFacturaOrigen AS '@nIdFacturaOrigen', @sNumFacturaFilial AS '@sNumFacturaFilial', @sNumFacturaOrigen AS '@sNumFacturaOrigen'
					, @sMensajeError AS MensajeError , @nNumError AS NumError, @nClaTipoUbicacion as '@nClaTipoUbicacion'
				END
			END
			ELSE
			BEGIN
				--Revisi�n previa de Certificado
				IF EXISTS (
					SELECT	1
					FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK)
					WHERE	ClaUbicacion	= @nClaUbicacionFilial
					AND		IdFactura		= @nIdFacturaFilial
				)
				BEGIN
						SELECT	  @nEsRegeneraCertificado = CASE	WHEN Archivo IS NULL THEN 1 
																	ELSE 0 END
								, @sIdCertificado = CONVERT(VARCHAR(20),IdCertificado)
						FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK)
						WHERE	ClaUbicacion	= @nClaUbicacionFilial
						AND		IdFactura		= @nIdFacturaFilial


						IF @nEsRegeneraCertificado = 0	
						BEGIN
							GOTO SALTO	-- Ya existe Certificado
						END
				END

				SET @sIdCertificado = ''
				SELECT 'Otros Certificados'

				EXEC DEAOFINET04.Operacion.ACESch.AceGeneraCertificadoSobrePuntoLogisticoSrv--_DEV
					@pnClaUbicacion			= @nClaUbicacionFilial,
					@pnIdFactura			= @nIdFacturaFilial,
					@pnClaUbicacionOrigen	= @nClaUbicacionOrigen,
					@pnIdFacturaOrigen		= @nIdFacturaOrigen,
					@pnEsRegeneraCertificado = @nEsRegeneraCertificado,
					@psNombrePcMod			= 'GeneraCertificadoFilial',
					@pnClaUsuarioMod		= 1,
					@psIdCertificado		= @sIdCertificado	OUT,
					@pnClaEstatus			= @nNumError		OUT,
					@psMensajeError			= @sMensajeError	OUT
					--@pbArchivo				= @iArchivo 

				--SET @sIdCertificado = CONVERT(VARCHAR(20),@nIdCertificado)

				--select 'pas�'

				IF @pnDebug =1
				BEGIN
					SELECT 'Otros', @nId AS '@nId', @sIdCertificado as '@sIdCertificado', @nClaUbicacionFilial AS '@nClaUbicacionFilial', @nIdFacturaFilial AS '@nIdFacturaFilial'
					,@nClaUbicacionOrigen AS '@nClaUbicacionOrigen', @nIdFacturaOrigen AS '@nIdFacturaOrigen', @sNumFacturaFilial AS '@sNumFacturaFilial', @sNumFacturaOrigen AS '@sNumFacturaOrigen'
					, @sMensajeError AS MensajeError , @nNumError AS NumError, @nClaTipoUbicacion as '@nClaTipoUbicacion'
				END
		
			END
		END TRY
		BEGIN CATCH
			-- Validaci�n temporal debido a RAISERROR
			IF @nClaTipoUbicacion <> 2 AND @nNumError = 1
			BEGIN
				SET @nNumError  = 0 -- Ya existe un certificado
			END

			--SET @sIdCertificado = CONVERT(VARCHAR(20),@nIdCertificado)

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
				SELECT 'CATCH ERROR', @nId AS '@nId', @sIdCertificado as '@sIdCertificado',@nIdCertificado AS '@nIdCertificado', @nClaUbicacionFilial AS '@nClaUbicacionFilial', @nIdFacturaFilial AS '@nIdFacturaFilial'
				,@nClaUbicacionOrigen AS '@nClaUbicacionOrigen', @nIdFacturaOrigen AS '@nIdFacturaOrigen', @sNumFacturaFilial AS '@sNumFacturaFilial', @sNumFacturaOrigen AS '@sNumFacturaOrigen'
				, @sMensajeError AS MensajeError , @nNumError AS NumError, @nClaTipoUbicacion as '@nClaTipoUbicacion'
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

					SELECT	@nIdCertificado = IdCertificado
					FROM	@tbCertificados 
					WHERE	Id = @nIdCert
					----------------------
					SELECT  @iArchivo = Archivo
							,@nUsuario = ClaUsuarioMod
							,@dFecha	= FechaUltimaMod
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
						SELECT @sMensajeError = 'Certificado ya existe. Fecha generado: '+CONVERT(VARCHAR,@dFecha,20)+ '. Usuario que gener�:' + ISNULL(@sUsuario,'')
					END

					IF @pnDebug = 1
						SELECT 'PAS�', @nIdCertificado AS '@nIdCertificado', @nClaUbicacionFilial AS '@nClaUbicacionFilial', @sNumFacturaFilial AS '@sNumFacturaFilial'
			
			
					IF @nIdCertificado IS NOT NULL AND @iArchivo IS NOT NULL
					BEGIN
						UPDATE	OpeSch.OpeRelFacturaSuministroDirecto
						SET		ClaEstatus		= 3,
								MensajeError	= @sMensajeError,
								NumCertificado	= @sNumCertificado,
								IdCertificado	= @nIdCertificado,
								ArchivoCertificado = @iArchivo,
								FechaUltimaMod	= GETDATE(),
								NumError		= @nNumError
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

					------------------------
					SELECT	@nIdCert = MIN(Id)
					FROM	@tbCertificados 
					WHERE	Id > @nIdCert
				END
			END
		END
		ELSE
		BEGIN
			UPDATE	OpeSch.OpeRelFacturaSuministroDirecto
			SET		ClaEstatus		= 4,
					NumError		= @nNumError, 
					MensajeError	= @sMensajeError,
					FechaUltimaMod	= GETDATE()
			WHERE	ClaUbicacion	= @nClaUbicacionFilial
			AND		NumFacturaFilial = @sNumFacturaFilial
		END
		

		SELECT	@nId = MIN(Id)
		FROM	@Relaciones
		WHERE	Id > @nId
	END

	SET NOCOUNT OFF
END