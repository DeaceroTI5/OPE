GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag37_LnkBoton_Descarga_Descarga
	@pnClaUbicacion		INT,
	@psNumFacturaFilial	VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON

	SELECT	FileData = ArchivoCertificado,
			FileName = CASE WHEN ISNULL(NumCertificado,'')<> '' 
							THEN NumCertificado 
							ELSE CONVERT(VARCHAR(20),IdCertificado) END,
			FileExt = 'pdf'
	FROM	OpeSch.OpeRelFacturaSuministroDirecto a WITH(NOLOCK)
	WHERE	a.ClaUbicacion = @pnClaUbicacion
	AND		a.NumFacturaFilial = @psNumFacturaFilial

	SET NOCOUNT OFF
END

GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag37_GeneraCertificadoFilial
	  @pnClaUbicacion		INT
	, @psNumFacturaFilial	VARCHAR(20) = ''
	, @pnIdFacturaFilial	INT = NULL
	, @pnEsRegenerarCertificado TINYINT = 0
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
			@sIdCertificado			VARCHAR(1000),
			@nClaAceria				INT,
			@nExisteArchivoAceria	TINYINT = 0


	
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

						IF @pnDebug = 1
							SELECT @nClaUbicacionFilial AS '@nClaUbicacionFilial', @nIdFacturaFilial AS '@nIdFacturaFilial', @nEsRegeneraCertificado AS '@nEsRegeneraCertificado'
				END

				SET @sIdCertificado = ''
				SELECT 'Otros Certificados'

				--EXEC DEAOFINET04.Operacion.ACESch.AceGeneraCertificadoSobrePuntoLogisticoSrv_DEV
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
					@psMensajeError			= @sMensajeError	OUT

					IF ISNULL(@sIdCertificado,'') <> '' AND @nNumError IS NULL
						SELECT @nNumError = 0

				IF @pnDebug =1
				BEGIN
					SELECT 'Otros Cert', @nId AS '@nId', @sIdCertificado as '@sIdCertificado', @sMensajeError AS '@sMensajeError', Error = ISNULL(ERROR_MESSAGE(),'') + ' [' + ISNULL(ERROR_PROCEDURE(),'') +']', @nEsRegeneraCertificado AS '@nEsRegeneraCertificado'
				END
		
			END
		END TRY
		BEGIN CATCH
			-- Validación temporal debido a RAISERROR
			--IF @nClaTipoUbicacion <> 2 AND @nNumError = 1
			--BEGIN
			--	SET @nNumError  = 0 -- Ya existe un certificado
			--END

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

					--IF @pnDebug = 1
					--	SELECT 'PASÓ', @nIdCertificado AS '@nIdCertificado', @nClaUbicacionFilial AS '@nClaUbicacionFilial', @sNumFacturaFilial AS '@sNumFacturaFilial'
					--			,@nClaAceria AS '@nClaAceria', @pnIdFacturaFilial AS '@pnIdFacturaFilial'

					--IF @pnDebug = 1
					--	SELECT '' AS'ACESch.AceTraCertificado',* FROM DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK)
					--	WHERE	ClaUbicacion = @nClaUbicacionFilial
					--	AND		IdCertificado = @nIdCertificado

					---- Revisa que el Certificado exista en la Aceria para la factura Origen 
					SELECT	@nExisteArchivoAceria = CASE WHEN Archivo IS NOT NULL THEN 1 ELSE 0 END
					FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK)
					WHERE	ClaUbicacion		= @nClaUbicacionOrigen
					AND		IdFactura			= @nIdFacturaOrigen
					AND		ClaUbicacionOrigen	= @nClaAceria

					IF @pnDebug = 1
						SELECT @nExisteArchivoAceria AS '@nExisteArchivoAceria', @nClaAceria AS '@nClaAceria'
			
					IF @nIdCertificado IS NOT NULL AND @iArchivo IS NOT NULL AND ISNULL(@nExisteArchivoAceria,0) = 1
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
			SELECT @sErrorMsj = ERROR_MESSAGE() + ' [' + ERROR_PROCEDURE() +']'
			SELECT @sMensajeError = ISNULL(@sMensajeError, @sErrorMsj)

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

GO
ALTER PROCEDURE  OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_IU
	  @pnClaUbicacion		INT
	, @psNumFacturaFilial	VARCHAR(15)
	, @pnClaUbicacionOrigen	INT
	, @psNumFacturaOrigen	VARCHAR(15)
	, @pnBajaLogica			TINYINT = 0
	, @psNombrePcMod		VARCHAR(64)  
	, @pnClaUsuarioMod		INT
	, @pnAccionSp			TINYINT = -1 
	, @pnDebug				TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	IF @pnDebug = 1
		SELECT '' AS 'Debug OPE_CU550_Pag37_Grid_FacturasSumDirecto_IU'

	IF(@pnAccionSp = 3)  
		SET @pnBajaLogica = 1 
	
	IF @pnBajaLogica = 0
	BEGIN
		/*Validaciones*/
		EXEC OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_CambioValor_NumFacturaOrigen_Sel
			  @psNumFacturaOrigen	= @psNumFacturaOrigen

		EXEC OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_CambioValor_NumFacturaFilial_Sel
			  @pnClaUbicacion		= @pnClaUbicacion	
			, @psNumFacturaFilial	= @psNumFacturaFilial

		IF ISNULL(ERROR_MESSAGE(),'') <> ''
		BEGIN
			DECLARE @sMsj VARCHAR(300) 
			SET @sMsj = ERROR_MESSAGE() + ' [' + ERROR_PROCEDURE() +']'
			
			RAISERROR(@sMsj,16,1)
			RETURN
		END
	END
	
	DECLARE	  @nIdFacturaFilial		INT
			, @nIdFacturaOrigen		INT
			, @sMensajeError		VARCHAR(1000) = ''
			, @nEsBajaLogica		TINYINT = NULL
			, @nTipoUbicacion		INT
			, @nClaUbicacionVentas	INT

	SELECT	@nIdFacturaFilial		= IdFactura
	FROM	OpeSch.OpeTraMovEntSal WITH(NOLOCK)
	WHERE	ClaUbicacion			= @pnClaUbicacion
	AND		IdFacturaAlfanumerico	= @psNumFacturaFilial

	SELECT	@nTipoUbicacion		 = ClaTipoUbicacion,
			@nClaUbicacionVentas = ClaUbicacionVentas
	FROM	OpeSch.OpeTiCatUbicacionVw
	WHERE	ClaUbicacion		 = @pnClaUbicacionOrigen

	SELECT	@nIdFacturaOrigen		= IdFactura
	FROM	DEAOFINET04.Operacion.AceSch.VtaCTraFacturaVw
	WHERE	IdFacturaAlfanumerico	= @psNumFacturaOrigen
--	AND		ClaUbicacion			= @nClaUbicacionVentas

	IF @pnDebug = 1
		SELECT @nIdFacturaFilial AS '@nIdFacturaFilial', @nIdFacturaOrigen AS '@nIdFacturaOrigen', @nClaUbicacionVentas AS '@nClaUbicacionVentas'


	IF NOT EXISTS (
		SELECT  1
		FROM	OpeSch.OpeRelFacturaSuministroDirecto WITH(NOLOCK)
		WHERE	ClaUbicacion		= @pnClaUbicacion
		AND		NumFacturaFilial	= @psNumFacturaFilial
		AND		IdFacturaFilial		= @nIdFacturaFilial
	)
	BEGIN

		INSERT INTO OpeSch.OpeRelFacturaSuministroDirecto (
			  ClaUbicacion
			, NumFacturaFilial
			, IdFacturaFilial
			, ClaUbicacionOrigen
			, NumFacturaOrigen
			, IdFacturaOrigen
			, ClaEstatus
			, MensajeError
			, IdCertificado
			, NumCertificado
			, ArchivoCertificado
			, ClaUsuarioMod
			, NombrePcMod
			, FechaUltimaMod
		) VALUES (
			  @pnClaUbicacion			-- ClaUbicacion
			, @psNumFacturaFilial		-- NumFacturaFilial
			, @nIdFacturaFilial			-- IdFacturaFilial
			, @pnClaUbicacionOrigen		-- ClaUbicacionOrigen
			, @psNumFacturaOrigen		-- NumFacturaOrigen
			, @nIdFacturaOrigen			-- IdFacturaOrigen
			, 1							-- ClaEstatus			--Esperando generarse
			, NULL						-- MensajeError
			, NULL						-- IdCertificado
			, NULL						-- NumCertificado
			, NULL						-- ArchivoCertificado
			, @pnClaUsuarioMod			-- ClaUsuarioMod
			, @psNombrePcMod			-- NombrePcMod
			, GETDATE()					-- FechaUltimaMod		
		)
	
	END
	ELSE
	BEGIN

		-- Revisar si el registro esta activo
		SELECT  @nEsBajaLogica		= BajaLogica
		FROM	OpeSch.OpeRelFacturaSuministroDirecto WITH(NOLOCK)
		WHERE	ClaUbicacion		= @pnClaUbicacion
		AND		NumFacturaFilial	= @psNumFacturaFilial
		AND		IdFacturaFilial		= @nIdFacturaFilial

		IF @pnDebug = 1
			SELECT @nEsBajaLogica AS '@nEsBajaLogica'

		IF @nEsBajaLogica = 0 AND @pnBajaLogica = 0
		BEGIN
			SELECT @sMensajeError =' La factura <b>'+@psNumFacturaFilial+'</b> ya tiene relación.'
			RAISERROR(@sMensajeError,16,1)
			RETURN
		END
			
		UPDATE	OpeSch.OpeRelFacturaSuministroDirecto WITH(ROWLOCK)  
		SET		 ClaUbicacionOrigen	= @pnClaUbicacionOrigen
				,NumFacturaOrigen	= @psNumFacturaOrigen
				,IdFacturaOrigen	= @nIdFacturaOrigen
				,BajaLogica			= @pnBajaLogica  
				,FechaBajaLogica	= CASE WHEN @pnBajaLogica = 1 
										THEN GETDATE() ELSE NULL END 
				,NombrePcMod		= @psNombrePcMod  
				,ClaUsuarioMod		= @pnClaUsuarioMod  
				,FechaUltimaMod		= GETDATE()
				,ClaEstatus			= 1
				,MensajeError		= ''
				,IdCertificado		= NULL
				,NumCertificado		= NULL
				,ArchivoCertificado	= NULL
		WHERE	ClaUbicacion		= @pnClaUbicacion
		AND		NumFacturaFilial	= @psNumFacturaFilial
		AND		IdFacturaFilial		= @nIdFacturaFilial
	END

	SET NOCOUNT OFF
END

GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_Sel
	  @pnClaUbicacion		INT
	, @psNumFacturaFilial	VARCHAR(20)
	, @pnClaUbicacionOrigen	INT
	, @psNumFacturaOrigen	VARCHAR(20)
	, @pnVerBajas			TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	-- exec OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_Sel @pnClaUbicacion=324,@psNumFacturaFilial='',@psClaUbicacionOrigen=191,@psNumFacturaOrigen='',@pnVerBajas=0

	SELECT	  a.ClaUbicacionOrigen
			, NomUbicacionOrigen = CONVERT(VARCHAR(10),a.ClaUbicacionOrigen) + ' - ' + b.NomUbicacion
			, a.NumFacturaFilial
			, a.NumFacturaOrigen
			, Numcertificado = ISNULL(a.Numcertificado,'')
			, Estatus = CASE	WHEN a.ClaEstatus = 1 THEN 'Pendiente'
								WHEN a.ClaEstatus = 2 THEN 'En Proceso'
								WHEN a.ClaEstatus = 3 THEN 'Generado'
								ELSE 'Error' END
			, MensajeError = NULLIF(a.MensajeError,'')
			, Descarga = 'Descargar'
			, EsRegenerar = CASE WHEN a.ArchivoCertificado IS NULL THEN '' ELSE 'Regenerar' END 
			, a.BajaLogica
	FROM	OpeSch.OpeRelFacturaSuministroDirecto a WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTiCatUbicacionVw b
	ON		a.ClaUbicacionOrigen = b.ClaUbicacion
	WHERE	a.ClaUbicacion = @pnClaUbicacion
	AND		(@psNumFacturaFilial = '' OR(a.NumFacturaFilial LIKE '%'+@psNumFacturaFilial+'%'))
	AND		(@pnClaUbicacionOrigen IS NULL OR(a.ClaUbicacionOrigen = @pnClaUbicacionOrigen))
	AND		(@psNumFacturaOrigen = '' OR(a.NumFacturaOrigen LIKE '%'+ @psNumFacturaOrigen+'%'))
	AND		(a.BajaLogica = @pnVerBajas)
	--AND		(@pnVerBajas = 1 OR a.BajaLogica = 0)
	ORDER BY NumFacturaFilial ASC

	SET NOCOUNT OFF
END

GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag37_Boton_EsRegenerar_Proc
	  @pnClaUbicacion		INT
	, @psFacturaFilial		VARCHAR(15)
	, @psNombrePcMod		VARCHAR(64)  
	, @pnClaUsuarioMod		INT
	, @pnDebug				TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	DECLARE	  @nIdFacturaFilial		INT

	SELECT	@nIdFacturaFilial		= IdFactura
	FROM	OpeSch.OpeTraMovEntSal WITH(NOLOCK)
	WHERE	ClaUbicacion			= @pnClaUbicacion
	AND		IdFacturaAlfanumerico	= @psFacturaFilial

	UPDATE	OpeSch.OpeRelFacturaSuministroDirecto WITH(ROWLOCK)  
	SET		 NombrePcMod		= @psNombrePcMod  
			,ClaUsuarioMod		= @pnClaUsuarioMod  
			,FechaUltimaMod		= GETDATE()
			,ClaEstatus			= 1
			,MensajeError		= ''
			,IdCertificado		= NULL
			,NumCertificado		= NULL
			,ArchivoCertificado	= NULL
	WHERE	ClaUbicacion		= @pnClaUbicacion
	AND		NumFacturaFilial	= @psFacturaFilial
	AND		IdFacturaFilial		= @nIdFacturaFilial

	IF @@SERVERNAME <> 'SRVDBDES01\ITKQA'
	BEGIN
		EXEC OpeSch.OPE_CU550_Pag37_GeneraCertificadoFilial
			  @pnClaUbicacion			= @pnClaUbicacion
			, @psNumFacturaFilial		= @psFacturaFilial
			, @pnIdFacturaFilial		= @nIdFacturaFilial
			, @pnEsRegenerarCertificado = 1
			, @pnDebug					= 0
	END

	SET NOCOUNT OFF
END

GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag37_Boton_SAVE_Proc
	  @pnClaUbicacion	INT
	, @pnDebug			TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	SELECT @pnDebug = ISNULL(@pnDebug,0)

	IF @@SERVERNAME <> 'SRVDBDES01\ITKQA'	-- No afectar en ambiente de pruebas
	BEGIN
		BEGIN TRY

			EXEC [OpeSch].[OPE_CU550_Pag37_GeneraCertificadoFilial]
				  @pnClaUbicacion		= @pnClaUbicacion
				, @psNumFacturaFilial	= ''
				, @pnIdFacturaFilial	= NULL
				, @pnDebug				= @pnDebug
		
		END TRY
		BEGIN CATCH
			
			DECLARE @sMsj VARCHAR(1000)
			SELECT @sMsj = 'Error: ' + ISNULL(ERROR_MESSAGE(),'')

			RAISERROR(@sMsj,16,1)

			RETURN
		END CATCH
	END

	SET NOCOUNT OFF
END

GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_CambioValor_NumFacturaFilial_Sel
	  @pnClaUbicacion		INT
	, @psNumFacturaFilial	VARCHAR(15)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE	  @sMensajeError	VARCHAR(1000) = ''
			, @sUbicacion		VARCHAR(50)

	SELECT	@sUbicacion = NombreUbicacion
	FROM	OpeSch.OpeTiCatUbicacionVw
	WHERE	ClaUbicacion = @pnClaUbicacion

	IF NOT EXISTS(
				SELECT	1 
				FROM	OpeSch.OpeTraMovEntSal WITH(NOLOCK)
				WHERE	ClaUbicacion = @pnClaUbicacion
				AND		IdFacturaAlfanumerico = @psNumFacturaFilial
	)
	BEGIN
		SELECT @sMensajeError = 'La factura <b>' + @psNumFacturaFilial + '</b> no existe en ' + ISNULL(@sUbicacion,'') + '.'
		RAISERROR(@sMensajeError,16,1)
		RETURN
	END

	SET NOCOUNT OFF
END

GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_CambioValor_NumFacturaOrigen_Sel
	  @psNumFacturaOrigen	VARCHAR(15)
	  ,@pnClaUbicacionOrigen INT = NULL
AS
BEGIN
	SET NOCOUNT ON

	DECLARE	  @sMensajeError		VARCHAR(1000) = ''
			, @sNumFacturaOrigen	VARCHAR(15)
			, @nClaUbicacionOrigen	INT = NULL
			, @nClaUbicacionVentaOrigen INT
			, @sNomUbicacionOrigen	VARCHAR(90)

	SET @sNumFacturaOrigen = @psNumFacturaOrigen

	IF @pnClaUbicacionOrigen IS NULL
	SELECT	@pnClaUbicacionOrigen	= ClaUbicacion
	FROM	OpeSch.OpeVtaCTraFacturaVw
	WHERE	IdFacturaAlfanumerico	= @psNumFacturaOrigen

	IF @pnClaUbicacionOrigen IS NULL
		SELECT	@nClaUbicacionVentaOrigen	= ClaUbicacion
		FROM	DEAOFINET04.Operacion.AceSch.VtaCTraFacturaVw
		WHERE	IdFacturaAlfanumerico	= @psNumFacturaOrigen

	IF @nClaUbicacionVentaOrigen IS NOT NULL
		SELECT	@sNomUbicacionOrigen = CONVERT(VARCHAR(10),a.ClaUbicacion) + ' - ' + a.NomUbicacion
				,@nClaUbicacionOrigen = ClaUbicacion
		FROM	OpeSch.OpeTiCatUbicacionVw a
		WHERE	ClaUbicacionVentas = @nClaUbicacionVentaOrigen
	ELSE
		IF @pnClaUbicacionOrigen IS NOT NULL
			SELECT    @sNomUbicacionOrigen = CONVERT(VARCHAR(10),a.ClaUbicacion) + ' - ' + a.NomUbicacion
					, @nClaUbicacionOrigen = ClaUbicacion
			FROM    OpeSch.OpeTiCatUbicacionVw a
			WHERE    ClaUbicacion = @pnClaUbicacionOrigen
		ELSE
			SELECT	@sNomUbicacionOrigen = NULL
					,@nClaUbicacionOrigen = NULL

	SELECT	  NumFacturaOrigen	 = @sNumFacturaOrigen
			, ClaUbicacionOrigen = @nClaUbicacionOrigen
			, NomUbicacionOrigen = @sNomUbicacionOrigen

	IF @nClaUbicacionOrigen IS NULL
	BEGIN
		SELECT @sMensajeError = 'La Factura Origen ' + @sNumFacturaOrigen + ' NO existe.'
		RAISERROR(@sMensajeError,16,1)
		RETURN 
	END

	SET NOCOUNT OFF

END
