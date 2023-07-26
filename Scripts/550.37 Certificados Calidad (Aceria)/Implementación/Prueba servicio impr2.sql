USE Operacion
GO

DECLARE	  @nClaUbicacionFilial	INT			= 324
		, @sNumFacturaFilial	VARCHAR(50) = 'QN6306'
		, @nIdFacturaFilial		INT			= 1034006306
		, @nClaUbicacionOrigen	INT			= 22
		, @nIdFacturaOrigen		INT			= 43179966
		, @sNumFacturaOrigen	VARCHAR(50) = 'FQ179966 '
		, @nEsRegeneraCertificado INT		= 1

DECLARE	  @pnDebug				TINYINT		= 1
		, @nIdCertificado		INT
		, @sIdCertificado		VARCHAR(50)
		, @sNumCertificado		VARCHAR(100)
		, @nNumError			INT
		, @sMensajeError		VARCHAR(500)
		, @pnClaAceria			INT
		, @iArchivo				VARBINARY(MAX)


BEGIN TRAN

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

		SELECT	  @sIdCertificado	AS '@sIdCertificado'
				, @nNumError		AS '@nNumError'
				, @sMensajeError	AS '@sMensajeError'

ROLLBACK TRAN