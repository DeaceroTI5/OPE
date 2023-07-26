USE Operacion
GO

-- /*Prueba 1 no sale nada*/
--DECLARE	  @nClaUbicacionFilial	INT			= 324
--		, @sNumFacturaFilial	VARCHAR(50) = 'QN6306'
--		, @nIdFacturaFilial		INT			= 1034006306
--		, @nClaUbicacionOrigen	INT			= 22
--		, @nIdFacturaOrigen		INT			= 43179966
--		, @sNumFacturaOrigen	VARCHAR(50) = 'FQ179966 '
--		, @nEsRegeneraCertificado INT		= 1

-- /*Prueba 2 no sale nada*/
--DECLARE	  @nClaUbicacionFilial	INT			= 324
--		, @sNumFacturaFilial	VARCHAR(50) = 'QN2020'
--		, @nIdFacturaFilial		INT			= 1034002020
--		, @nClaUbicacionOrigen	INT			= 7
--		, @nIdFacturaOrigen		INT			= 7376760
--		, @sNumFacturaOrigen	VARCHAR(50) = 'G376760 '
--		, @nEsRegeneraCertificado INT		= 1

DECLARE	  @nClaUbicacionFilial	INT			= 362
		, @sNumFacturaFilial	VARCHAR(50) = 'QP1250'
		, @nIdFacturaFilial		INT			= 1036001250
		, @nClaUbicacionOrigen	INT			= 7
		, @nIdFacturaOrigen		INT			= 7388658
		, @sNumFacturaOrigen	VARCHAR(50) = 'G388658 '
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

		SELECT	  @nIdCertificado	AS '@nIdCertificado'
				, @sNumCertificado	AS '@sNumCertificado'
				, @nNumError		AS '@nNumError'
				, @sMensajeError	AS '@sMensajeError'

ROLLBACK TRAN