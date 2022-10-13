Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [ACESch].[AceGeneraCertificadoSumDirectoSrv]
	@pnClaUbicacion			INT,			
	@psNumFacturaFilial		VARCHAR(50)	,
	@pnClaUbicacionOrigen	INT,			
	@psNumFacturaOrigen		VARCHAR(50) ,
	@pnIdCertificado		INT				OUTPUT,
	@psNumeroCertificado	VARCHAR(50)		OUTPUT,
	@piArchivoCertificado	VARBINARY(MAX),
	@pnClaEstatus			TINYINT			OUTPUT,
	@psMensajeError			VARCHAR(100)	OUTPUT,
	@pnDebug				TINYINT = 0
AS
BEGIN

	/*
	BEGIN TRAN
	DECLARE	@pnIdCertificado		INT				,
			@psNumeroCertificado	VARCHAR(50)		,
			@pnClaEstatus			TINYINT			,
			@psMensajeError			VARCHAR(100)	
	EXEC ACESch.AceGeneraCertificadoSumDirectoSrv 323, 'QM243', 22, 'FQ159425', @pnIdCertificado OUTPUT, @psNumeroCertificado OUTPUT, NULL,
			@pnClaEstatus OUTPUT, @psMensajeError OUTPUT, 1
	SELECT	@pnIdCertificado, @psNumeroCertificado, @pnClaEstatus, @psMensajeError
	ROLLBACK TRAN
	*/

	IF @pnDebug = 1
		SELECT '' AS 'Debug AceGeneraCertificadoSumDirectoSrv'

	--Variable Servicio
	DECLARE @idFabricacionItk			INT,
			@idFacturaItk				INT,
			@idFabricacionOrigen		INT,
			@idFacturaOrigen			INT,
			@pnError					TINYINT,
			@sMensajeError				VARCHAR(1000),
			@nPesoDeAcero				NUMERIC(22,4),
			@nPesoFilial				NUMERIC(22,4),
			@nClaUbicacionFilialVentas	INT,
			@nClaUbicacionOrigenVentas	INT

	SELECT	@nClaUbicacionFilialVentas = ClaUbicacionVentas
	FROM	AceSch.AceTiCatUbicacionVw
	WHERE	ClaUbicacion = @pnClaUbicacion

	SELECT	@nClaUbicacionOrigenVentas = ClaUbicacionVentas
	FROM	AceSch.AceTiCatUbicacionVw
	WHERE	ClaUbicacion = @pnClaUbicacionOrigen

	SELECT	@idFabricacionItk	= IdFabricacion,
			@idFacturaItk		= IdFactura
	FROM	AceSch.VtaCTraFacturaVw WITH(NOLOCK)
	WHERE	IdFacturaAlfanumerico = @psNumFacturaFilial
	AND		ClaUbicacion = @nClaUbicacionFilialVentas

	SELECT	@idFabricacionOrigen	= IdFabricacion,
			@idFacturaOrigen		= IdFactura
	FROM	AceSch.VtaCTraFacturaVw WITH(NOLOCK)
	WHERE	IdFacturaAlfanumerico = @psNumFacturaOrigen
	AND		ClaUbicacion = @nClaUbicacionOrigenVentas

	SELECT	@nPesoFilial = CantSurtida
	FROM	FleSch.FleTraViajeFacturaDet WITH(NOLOCK)
	WHERE	NumFactura = @idFacturaItk
	AND		ClaUbicacion = @pnClaUbicacion

	SELECT	@nPesoFilial = CantSurtida
	FROM	FleSch.FleTraViajeFacturaDet  WITH(NOLOCK)
	WHERE	NumFactura=@idFacturaOrigen
	AND		ClaUbicacion = @pnClaUbicacionOrigen

	--Validaciones
	--Validar Existencia de la Factura Filial
	IF NOT EXISTS (	SELECT	1
					FROM	AceSch.VtaCTraFacturaVw WITH(NOLOCK)
					WHERE	IdFacturaAlfanumerico = @psNumFacturaFilial
					AND		ClaUbicacion = @nClaUbicacionFilialVentas	)
		SELECT @pnError = 1, @sMensajeError = 'La factura Itk no existe ' + @psNumFacturaFilial, @pnClaEstatus = 4;

	--Validacion Existencia de la factura Origen
	IF NOT EXISTS (	SELECT	1
					FROM	AceSch.VtaCTraFacturaVw WITH(NOLOCK)
					WHERE	IdFacturaAlfanumerico = @psNumFacturaOrigen
					AND		ClaUbicacion = @nClaUbicacionOrigenVentas	)
		SELECT @pnError = 1, @sMensajeError = 'La factura de Origen no existe ' + @psNumFacturaOrigen, @pnClaEstatus = 5;

	IF EXISTS (	SELECT	ClaCiudadCliente,ClaCiudadDestinoPedido,ClaArticulo 
				FROM	FleSch.FleTraViajeFacturaDet WITH(NOLOCK)
				WHERE	NumFactura = @idFacturaItk
				EXCEPT
				SELECT	ClaCiudadCliente,ClaCiudadDestinoPedido,ClaArticulo 
				FROM	FleSch.FleTraViajeFacturaDet WITH(NOLOCK)
				WHERE	NumFactura=@idFacturaOrigen)
		SELECT @pnError = 1, @sMensajeError = 'Las facturas no coinciden', @pnClaEstatus = 6;

	IF((@nPesoDeacero/@nPesoFilial) > 1.06)
		SELECT @pnError = 1, @sMensajeError = ']El peso de la factura filial excede 6%', @pnClaEstatus = 9;
	
	IF EXISTS (	SELECT	1 
				FROM	ACESch.AceTraCertificado WITH(NOLOCK)
				WHERE	IdFabricacion = @idFabricacionItk
				AND		IdFactura = @idFacturaItk
				AND		ClaUbicacion = @pnClaUbicacion)
		SELECT @pnError = 1, @sMensajeError = 'Ya existe un certificado asociado a la factura '+ @psNumFacturaFilial, @pnClaEstatus = 8;

	IF (@pnError > 0)
	BEGIN
		GOTO VALIDACION;
	END

	--DECLARE @tmpCertificado TABLE (ClaUbicacion INT, IdCertificado INT, EsGenerado TINYINT);
	DECLARE @tmpCertificadoDetalle TABLE 
		(Id				INT IDENTITY (1,1),
		ClaHornoFusion	INT,
		IdColada		INT,
		ClaMolino		INT,
		IdSecuencia		INT,
		ClaArticuloExt	INT,
		Cantidad		NUMERIC(20,7),
		PesoEmbarque	NUMERIC(20,7));

	DECLARE @sNEW_LINE	CHAR(2),
			@nId		INT,
			@sMsjError	NVARCHAR(1000),
			@sMsjParametrosRequeridos NVARCHAR(100),
			@nClaHornoFusion	INT,
			@nIdColada			INT,
			@nClaMolino			INT,
			@nIdSecuencia		INT,
			@nClaArticuloExt	INT,
			@nCantidad			NUMERIC(20,7),
			@nPesoEmbarque		NUMERIC(20,7),
			@nIdCertificadoOrigen	INT,
			@nIdViajeItk		INT,
			@nPlanCarga			INT,
			@tFechaViaje		DATETIME,
			@ProcName			nvarchar(128);


	SELECT	@nIdViajeItk	= IdViaje,
			@tFechaViaje	= FechaEntSal
	FROM	ACESch.AcePloCTraMovEntSalVw WITH(NOLOCK)
	WHERE	ClaUbicacion	= @pnClaUbicacion
	AND		IdFactura		= @idFacturaItk

	SELECT	@nPlanCarga		= IdPlanCarga
	FROM	ACESch.PloCTraViajeVw
	WHERE	ClaUbicacion	= @pnClaUbicacion
	AND		IdViaje			= @nIdViajeItk

	SELECT	@nIdCertificadoOrigen = IdCertificado
	FROM	ACESch.AceTraCertificado WITH(NOLOCK)
	WHERE	IdFabricacion = @idFabricacionOrigen
	AND		IdFactura = @idFacturaOrigen
	AND		ClaUbicacion = @pnClaUbicacionOrigen
	
	INSERT INTO @tmpCertificadoDetalle	(
		ClaHornoFusion,
		IdColada,
		ClaMolino,
		IdSecuencia,
		ClaArticuloExt,
		Cantidad,
		PesoEmbarque )
	SELECT ClaHornoFusion,
			IdColada,
			ClaMolino,
			IdSecuencia,
			ClaArticuloExt,
			Cantidad,
			PesoEmbarque
		FROM ACESch.AceTraCertificadoDet  WITH(NOLOCK)
		WHERE IdCertificado = @nIdCertificadoOrigen
			AND ClaUbicacion = @pnClaUbicacionOrigen

	SELECT @nId = MIN(Id) FROM @tmpCertificadoDetalle;

	WHILE @nId IS NOT NULL
	BEGIN
		SELECT @nClaHornoFusion = NULL,
				@nIdColada = NULL,
				@nClaMolino = NULL,
				@nIdSecuencia = NULL,
				@nClaArticuloExt = NULL,
				@nCantidad = NULL,
				@nPesoEmbarque = NULL;

		SELECT	@nClaHornoFusion = ClaHornoFusion
				, @nIdColada = IdColada
				, @nClaMolino = ClaMolino
				, @nIdSecuencia = IdSecuencia
				, @nClaArticuloExt = ClaArticuloExt
				, @nCantidad = Cantidad
				, @nPesoEmbarque = PesoEmbarque
			FROM @tmpCertificadoDetalle 
			WHERE Id = @nId;

		--IF @pnDebug = 1
		--	SELECT 'ACESch.AceRecibeDatosCertificadoPLSrv', @pnClaUbicacion, @nIdViajeItk, @idFabricacionItk, @idFacturaItk, @psNumFacturaFilial,
		--			@nPlanCarga, @tFechaViaje, @nClaHornoFusion, @nIdColada, @nClaMolino, @nIdSecuencia, @pnClaUbicacionOrigen, @nClaArticuloExt,
		--			@nCantidad, @nPesoEmbarque
	
		EXEC ACESch.AceRecibeDatosCertificadoPLSrv
			@pnClaUbicacion		= @pnClaUbicacion,--Datos itk
			@pnIdViaje			= @nIdViajeItk,
			@pnIdFabricacion	= @idFabricacionItk,
			@pnIdFactura		= @idFacturaItk,
			@psNumFactura		= @psNumFacturaFilial,
			@pnNumPlan			= @nPlanCarga,
			@pdFechaViaje		= @tFechaViaje,
			@pnClaHornoFusion	= @nClaHornoFusion,--Datos certificado Original
			@pnIdColada			= @nIdColada,
			@pnClaMolino		= @nClaMolino,
			@pnIdSecuencia		= @nIdSecuencia,
			@pnClaUbicacionAce	= @pnClaUbicacionOrigen,
			@pnClaArticulo		= @nClaArticuloExt,
			@pnCantidad			= @nCantidad,
			@pnPesoEmbarque		= @nPesoEmbarque,
			@psNombrePcMod		= 'ServicioSumDirecto',
			@pnClaUsuarioMod	= 10,
			@pnError			= @pnError			OUT,
			@psMensajeError		= @psMensajeError	OUT

		IF @pnError > 0
		BEGIN
			GOTO ABORT;
		END

		SELECT @nId = MIN(Id) FROM @tmpCertificadoDetalle WHERE @nId < Id;		
	END

	IF @pnDebug = 1
		SELECT 'ACESch.AceValidaDatosCertificadoCalidadProc', @pnClaUbicacion AS '@pnClaUbicacion', @nIdViajeItk AS '@nIdViajeItk', @idFabricacionItk AS '@idFabricacionItk'

	EXEC ACESch.AceValidaDatosCertificadoCalidadProc
		@pnClaUbicacion = @pnClaUbicacion,
		@pnIdViaje = @nIdViajeItk,
		@pnIdFabricacion = @idFabricacionItk,
		@psNombrePcMod = 'ServicioSumDirecto',
		@pnClausuarioMod = 10,
		@pnError = @pnError OUT,
		@psMensajeError = @psMensajeError OUT;

	IF @pnError > 0
	BEGIN
		GOTO ABORT;
	END

	SELECT @pnIdCertificado = IdCertificado
		FROM ACESch.AceTraCertificado (NOLOCK)
		WHERE ClaUbicacion = @pnClaUbicacion
			AND ClaUbicacionOrigen = @pnClaUbicacionOrigen
			AND IdFactura = @idFacturaItk
			AND IdFabricacion = @IdFabricacionItk;

	IF @pnDebug = 1
		SELECT 'ACESch.AceGeneraCertificadoProc_CU161 Inicia', @pnClaUbicacion, @pnIdCertificado

	EXEC [ACESch].[AceGeneraCertificadoProc_CU161] 
		@pnClaUbicacion		= @pnClaUbicacion,
		@pnIdCertificado	= @pnIdCertificado,
		@pnClaIdioma		= NULL,
		@psNombrePcMod		= 'ServicioDirectoSum',      
		@pnClaUsuarioMod	= 10,      
		@psIdioma			= 'es-MX',      
		@pnError			= @pnError			OUT,      
		@psMensajeError		= @psMensajeError	OUT

	IF @pnDebug = 1
		SELECT 'ACESch.AceGeneraCertificadoProc_CU161 Termina', @pnClaUbicacion as '@pnClaUbicacion', @pnIdCertificado as '@pnIdCertificado', @pnError as '@pnError', @psMensajeError as '@psMensajeError'

	IF @pnError > 0
	BEGIN
		GOTO ABORT;
	END

	SELECT 	@pnIdCertificado		= IdCertificado,
			@psNumeroCertificado	= NumCertificado,
			@pnClaEstatus			= 0,
			@psMensajeError			= NULL,
			@piArchivoCertificado	= Archivo
		FROM ACESch.AceTraCertificado (NOLOCK)
		WHERE ClaUbicacion = @pnClaUbicacion
			AND ClaUbicacionOrigen = @pnClaUbicacionOrigen
			AND IdViaje = @nIdViajeItk
			AND IdFabricacion = @IdFabricacionItk;

	IF @pnDebug = 1
		SELECT @pnError AS '@pnError', @psMensajeError AS '@psMensajeError', @pnClaUbicacion AS '@pnClaUbicacion', @pnClaUbicacionOrigen AS '@pnClaUbicacionOrigen', @nIdViajeItk AS '@nIdViajeItk', @IdFabricacionItk AS '@IdFabricacionItk', @piArchivoCertificado 
AS '@piArchivoCertificado'



	SELECT @pnClaEstatus	= 0,
			@psMensajeError = null;

	SELECT	@pnIdCertificado,
			@psNumeroCertificado,
			@piArchivoCertificado,
			@pnClaEstatus,
			@psMensajeError;


	RETURN;
	
	
	
	VALIDACION:
		SET NOCOUNT OFF;
		SELECT @pnIdCertificado = NULL,
				@psNumeroCertificado = NULL,
				@psMensajeError = @sMensajeError;
		SELECT @pnIdCertificado,
				@psNumeroCertificado,
				@pnClaEstatus,
				@psMensajeError;

		IF @pnDebug = 1
			SELECT '' as 'Validacion', @psMensajeError as '@psMensajeError'

		RETURN;

	ABORT:
	SET NOCOUNT OFF;
	SET @ProcName = OBJECT_NAME(@@PROCID);
	SELECT @pnIdCertificado = NULL,
			@psNumeroCertificado = NULL,
			@pnClaEstatus = 7, --Error de Servicios locales
			@psMensajeError = @psMensajeError + ' ' + @ProcName;
	SELECT @pnIdCertificado,
				@psNumeroCertificado,
				@pnClaEstatus,
				@psMensajeError;

	IF @pnDebug = 1
		SELECT '' as 'Abort', @psMensajeError as '@psMensajeError'

	RETURN;
END
