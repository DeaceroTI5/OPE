Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [OpeSch].[OPE_CU550_Pag37_GeneraCertificadoFilial]
	  @pnClaUbicacion		INT = NULL
	, @psNumFacturaFilial	VARCHAR(20) = ''
	, @pnIdFacturaFilial	INT = NULL
	, @pnDebug				TINYINT = 0
AS
BEGIN
	IF @pnDebug =1
		SELECT 'Proc OPE_CU550_Pag37_GeneraCertificadoFilial'

	--SP ejecutado como Job para crear los certificados
	DECLARE @Relaciones TABLE 
	(
		Id					INT IDENTITY(1,1),
		ClaUbicacionFilial	INT,
		NumFacturaFilial	VARCHAR(50),
		ClaUbicacionOrigen	INT,
		NumFacturaOrigen	VARCHAR(50)
	)

	DECLARE @nId					INT,
			@nClaUbicacionFilial	INT,
			@sNumFacturaFilial		VARCHAR(50),
			@nClaUbicacionOrigen	INT,
			@sNumFacturaOrigen		VARCHAR(50),
			@nIdCertificado			INT,
			@sNumCertificado		VARCHAR(500),
			@nClaEstatus			TINYINT,
			@sMensajeError			VARCHAR(100),
			@iArchivo				VARBINARY(MAX);
	
	INSERT INTO @Relaciones
	(
		ClaUbicacionFilial,
		NumFacturaFilial,
		ClaUbicacionOrigen,
		NumFacturaOrigen
	)
	SELECT	ClaUbicacion,
			NumFacturaFilial,
			ClaUbicacionOrigen,
			NumFacturaOrigen
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

		SELECT @nClaUbicacionFilial		= ClaUbicacionFilial,
				@sNumFacturaFilial		= NumFacturaFilial,
				@nClaUbicacionOrigen	= ClaUbicacionOrigen,
				@sNumFacturaOrigen		= NumFacturaOrigen
		FROM	@Relaciones

		BEGIN TRY
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
		END TRY
		BEGIN CATCH
			DECLARE @sMsj VARCHAR(MAX)
			SELECT @sMsj = 'Error: ' + ERROR_MESSAGE()
			SELECT @sMsj 

			--IF (@@TRANCOUNT <> 0)
			--BEGIN
			--	ROLLBACK TRAN
			--END
		END CATCH

		IF @pnDebug = 1
			SELECT @nClaEstatus AS '@nClaEstatus'

		--Ajustar if con retorno 0
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
			SELECT  @iArchivo = Archivo
			FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK)
			WHERE	ClaUbicacion = @nClaUbicacionFilial
			AND		IdCertificado = @nIdCertificado

		IF @pnDebug = 1
			SELECT 'PASÓ', @iArchivo AS '@iArchivo', @nIdCertificado AS '@nIdCertificado', @nClaUbicacionFilial AS '@nClaUbicacionFilial'

			UPDATE	OpeSch.OpeRelFacturaSuministroDirecto
			SET		ClaEstatus = 3,
					NumCertificado = @sNumCertificado,
					IdCertificado  = @nIdCertificado,
					ArchivoCertificado = @iArchivo,
					FechaUltimaMod = GETDATE()
			WHERE	ClaUbicacion = @nClaUbicacionFilial
			AND		NumFacturaFilial = @sNumFacturaFilial
		END

		SELECT	@nId = MIN(Id)
		FROM	@Relaciones
		WHERE	Id < @nId;
	END

END