Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--grant exec on [ACESch].[AceGeneraCertificadoSobreLogisticoSrv]to public
CREATE PROCEDURE ACESch.AceGeneraCertificadoPuntoLogisticoSrv
@pnClaUbicacion INT,
@pnIdFactura INT,
@pnClaUbicacionOrigen INT,
@pnIdFacturaOrigen INT,
@pnEsRegeneraCertificado INT = 0,
@psNombrePcMod VARCHAR(64),
@pnClaUsuarioMod INT,
@psIdCertificado VARCHAR(100) = '' OUT,
@pnClaEstatus INT OUTPUT,
@psMensajeError VARCHAR(500) OUTPUT,
@pnClaAceria INT = NULL,
@pnDebug	TINYINT = 1
AS
BEGIN
	SET NOCOUNT ON

	IF @pnDebug = 1
		SELECT 'ACESch.AceGeneraCertificadoPuntoLogisticoSrv'

	DECLARE
		@nClaCliente INT,
		@sIdFacturaAlfanumerico VARCHAR(200),
		@nIdFabricacion INT,
		@nIdCertificado INT,
		@nIdCertificadoOrigen INT,
		@nNumViaje INT,
		@sNumCertificado VARCHAR(50),
	--	@nClaUbicacionOrigen INT,
		@nClaAceria INT,
		@sError VARCHAR(500) = ''

	DECLARE
		@sNumFacturaFilial VARCHAR(50),
		@sNumFacturaOrigen VARCHAR(50),
		@idFabricacionItk INT,
		@idFabricacionOrigen INT,
		@nClaUbicacionFilialVentas INT,
	--	@nClaUbicacionOrigenVentas INT,
		@nExisteCertificado INT = 0


	DECLARE @tbCertificados TABLE (
		  ClaUbicacion		int
		, IdCertificado		int
		, IdViaje			int
		, IdFabricacion		int
		, ClaUbicacionOrigen int	
		, ClaArticuloExt	int	
		, ClaCliente		int	
		, NumViaje			int	
		, IdFactura			int	
		, NumFactura		varchar	(50)
		, NumPlan			int	
		, FechaViaje		datetime
		, FechaCertificado	datetime
		, NumCertificado	varchar	(50)
		, Archivo			varchar(1)
		, EsGenerado		tinyint	
		, FechaUltimaMod	datetime
		, NombrePcMod		varchar	(64)
		, ClaUsuarioMod		int
		, ClaConsignado		int
		, IdViajeTraspaso	int
		, Placas			varchar	(20)
		, NumPedCliente		varchar	(10)
	)

       SELECT TOP 1 @nClaUbicacionFilialVentas = ClaUbicacionVentas
       FROM   AceSch.AceTiCatUbicacionVw WITH(NOLOCK)
       WHERE  ClaUbicacion = @pnClaUbicacion

       --SELECT TOP 1 @nClaUbicacionOrigenVentas = ClaUbicacionVentas
       --FROM AceSch.AceTiCatUbicacionVw (NOLOCK)
       --WHERE ClaUbicacion = @pnClaUbicacionOrigen


       SELECT TOP 1
		@idFabricacionItk = IdFabricacion,
        @sNumFacturaFilial = IdFacturaAlfanumerico
       FROM   AceSch.VtaCTraFacturaRel1Vw WITH(NOLOCK)
       WHERE  IdFactura = @pnIdFactura

       SELECT TOP 1
		@sNumFacturaOrigen = IdFacturaAlfanumerico,
		@idFabricacionOrigen = IdFabricacion                    
       FROM AceSch.VtaCTraFacturaRel1Vw WITH(NOLOCK)
       WHERE IdFactura = @pnIdFacturaOrigen

    IF EXISTS(
            SELECT 1
            FROM AceSch.AceTraCertificado WITH(NOLOCK)
            WHERE ClaUbicacion = @pnClaUbicacion
            AND IdFactura = @pnIdFactura
	  --    AND IdFabricacion = @idFabricacionItk
    ) AND @pnEsRegeneraCertificado = 0
    BEGIN
            SELECT TOP 1 @nIdCertificado = IdCertificado
            FROM AceSch.AceTraCertificado WITH(NOLOCK)
            WHERE ClaUbicacion = @pnClaUbicacion
            AND IdFactura = @pnIdFactura
        --  AND IdFabricacion = @idFabricacionItk

            SET @sError = 'Ya existe un certificado asociado a la factura: ' + ISNULL(@sNumFacturaFilial,'')
            SET @pnClaEstatus = 0 
            SET @psMensajeError = @sError
            RETURN        
    END
    ELSE IF NOT EXISTS(
            SELECT 1
            FROM AceSch.AceTraCertificado WITH(NOLOCK)
            WHERE ClaUbicacion = @pnClaUbicacion
            AND IdFactura = @pnIdFactura
    ) AND @pnEsRegeneraCertificado = 1
    BEGIN
            SET @sError = 'No existe un certificado asociado a la factura: ' + ISNULL(@sNumFacturaFilial,'')
            SET @pnClaEstatus = 6
            SET @psMensajeError = @sError   
			RETURN        
    END
    ELSE IF NOT EXISTS(
            SELECT 1
            FROM AceSch.VtaCTraFacturaRel1Vw WITH(NOLOCK)
            WHERE IdFactura = @pnIdFactura
            AND ClaUbicacion = @nClaUbicacionFilialVentas
    )
    BEGIN
   SET @sError = 'La factura Itk no existe: ' + ISNULL(@sNumFacturaFilial,'')
            SET @pnClaEstatus = 4
            SET @psMensajeError = @sError 
       RETURN
    END
    ELSE IF NOT EXISTS(
            SELECT 1
 FROM AceSch.VtaCTraFacturaRel1Vw WITH(NOLOCK)
            WHERE IdFactura = @pnIdFacturaOrigen
      --    AND ClaUbicacion = @nClaUbicacionOrigenVentas
    )
    BEGIN
            SET @sError = 'La factura de Origen no existe: ' + ISNULL(@sNumFacturaOrigen,'')
            SET @pnClaEstatus = 5
            SET @psMensajeError = @sError  
            RETURN
    END
    ELSE IF NOT EXISTS(
            SELECT 1
            FROM AceSch.AceTraCertificado WITH(NOLOCK)
            WHERE ClaUbicacion = @pnClaUbicacionOrigen
            AND IdFactura = @pnIdFacturaOrigen
    )
    BEGIN
            SET @sError = 'No existe un certificado asociado a la factura: ' + ISNULL(@sNumFacturaOrigen,'')
            SET @pnClaEstatus = 7
            SET @psMensajeError = @sError 
            RETURN        
    END


	BEGIN TRY
		DECLARE @tAcerias TABLE(
			ClaAceria INT,
			Orden INT IDENTITY(1, 1)
		)

		INSERT INTO @tAcerias(ClaAceria)
		SELECT DISTINCT ClaUbicacionOrigen
		FROM AceSch.AceTraCertificado WITH(NOLOCK)
		WHERE ClaUbicacion = @pnClaUbicacionOrigen
		AND IdFactura = @pnIdFacturaOrigen
		AND		(@pnClaAceria IS NULL OR (ClaUbicacionOrigen = @pnClaAceria))
		AND		Archivo IS NOT NULL	-- Hv Omitir Certificados Origen sin Archivo

		DECLARE @nCount INT = 1

		WHILE(@nCount <= (SELECT MAX(Orden) FROM @tAcerias))
		BEGIN
			SELECT	  @nExisteCertificado	= 0
					, @nClaAceria			= NULL
					, @nIdCertificadoOrigen = NULL
			--		, @nClaUbicacionOrigen	= NULL
					, @nClaCliente			= NULL
					, @sIdFacturaAlfanumerico = NULL
					, @nIdFabricacion		= NULL
					, @nNumViaje			= NULL
					, @sNumCertificado		= NULL
					, @nIdCertificado		= NULL


			SELECT TOP 1 @nClaAceria = ClaAceria
			FROM @tAcerias
			WHERE Orden = @nCount

			SELECT TOP 1
				@nIdCertificadoOrigen = IdCertificado
			FROM AceSch.AceTraCertificado WITH(NOLOCK)
			WHERE ClaUbicacion = @pnClaUbicacionOrigen
			AND IdFactura = @pnIdFacturaOrigen
			AND ClaUbicacionOrigen = @nClaAceria

			SELECT TOP 1
				@nClaCliente = ClaCliente,
				@sIdFacturaAlfanumerico = IdFacturaAlfanumerico,
				@nIdFabricacion = IdFabricacion
				,@nNumViaje = ClaViajeFactura
			FROM ACESch.VtaCTraFacturaRel1Vw WITH(NOLOCK)
			WHERE ClaUbicacion = @pnClaUbicacion
			ANd IdFactura = @pnIdFactura

			SELECT TOP 1 @nIdCertificado = ISNULL(MAX(IdCertificado), 0) + 1
			FROM ACESch.AceTraCertificado WITH(NOLOCK)
			WHERE ClaUbicacion = @pnClaUbicacion

			SET @sNumCertificado = CONVERT(VARCHAR(20), @nNumViaje) + ' - ' + CONVERT(VARCHAR(20), @nIdFabricacion) + ' - ' + CONVERT(VARCHAR(20), @nClaAceria)

			IF @pnDebug = 1 
				SELECT @sNumCertificado AS '@sNumCertificado', @nIdCertificado AS '@nIdCertificado', @nIdCertificadoOrigen AS '@nIdCertificadoOrigen', @nClaAceria AS '@nClaAceria', @pnEsRegeneraCertificado AS  '@pnEsRegeneraCertificado'

			INSERT INTO @tbCertificados (	--AceSch.AceTraCertificado
				ClaUbicacion,
				IdCertificado,
				IdViaje,
				IdFabricacion,
				ClaUbicacionOrigen,
				ClaArticuloExt,
				ClaCliente,
				NumViaje,
				IdFactura,
				NumFactura,
				NumPlan,
				FechaViaje,
				FechaCertificado,
				NumCertificado,
				Archivo,
				EsGenerado,
				FechaUltimaMod,
				NombrePcMod,
				ClaUsuarioMod,
				ClaConsignado,
				IdViajeTraspaso,
				Placas,
				NumPedCliente
			)
			SELECT
				@pnClaUbicacion ClaUbicacion,
				@nIdCertificado IdCertificado,
				IdViaje,
				@nIdFabricacion IdFabricacion,
				@nClaAceria ClaUbicacionOrigen,
				ClaArticuloExt,
				@nClaCliente ClaCliente,
				NumViaje,
				@pnIdFactura IdFactura,
				@sIdFacturaAlfanumerico NumFactura,
				NumPlan,
				FechaViaje,
				GETDATE() FechaCertificado,
				@sNumCertificado NumCertificado,
				NULL Archivo,
				0 EsGenerado,
				GETDATE() FechaUltimaMod,
				@psNombrePcMod NombrePcMod,
				@pnClaUsuarioMod ClaUsuarioMod,
				ClaConsignado,
				IdViajeTraspaso,
				Placas,
				NumPedCliente
			FROM AceSch.AceTraCertificado WITH(NOLOCK)
			WHERE ClaUbicacion = @pnClaUbicacionOrigen
			AND IdFactura = @pnIdFacturaOrigen
			AND ClaUbicacionOrigen = @nClaAceria
			AND NOT EXISTS(
				SELECT 1
				FROM AceSch.AceTraCertificado WITH(NOLOCK)
				WHERE ClaUbicacion = @pnClaUbicacion
				AND IdFactura = @pnIdFactura
				AND ClaUbicacionOrigen = @nClaAceria
			)
			AND @pnEsRegeneraCertificado = 0

			IF EXISTS (
				SELECT 1 
				FROM	@tbCertificados
				WHERE	ClaUbicacionOrigen = @nClaAceria	-- Aceria
			)
			SET @nExisteCertificado = 1

			----
			IF @pnDebug = 1
				SELECT ''AS'@tbCertificados', * FROM @tbCertificados

			IF EXISTS (
				SELECT	1
				FROM	AceSch.AceTraCertificado a WITH(NOLOCK)
				INNER JOIN @tbCertificados b 
				ON		a.ClaUbicacion	= b.ClaUbicacion
				AND		a.NumViaje		= b.NumViaje
				AND		a.IdFabricacion	= b.IdFabricacion
				AND		a.ClaUbicacionOrigen = b.ClaUbicacionOrigen
				AND		ISNULL(a.ClaArticuloExt,0)	= ISNULL(b.ClaArticuloExt,0)
				WHERE	a.IdFactura	<> @pnIdFactura
			)
			BEGIN
--				SELECT 'Si paso'
				DECLARE @sFacturaExiste VARCHAR(50)

				SELECT	@sFacturaExiste = a.NumFactura
				FROM	AceSch.AceTraCertificado a WITH(NOLOCK)
				INNER JOIN @tbCertificados b 
				ON		a.ClaUbicacion	= b.ClaUbicacion
				AND		a.NumViaje		= b.NumViaje
				AND		a.IdFabricacion	= b.IdFabricacion
				AND		a.ClaUbicacionOrigen = b.ClaUbicacionOrigen
				AND		ISNULL(a.ClaArticuloExt,0)	= ISNULL(b.ClaArticuloExt,0)
				WHERE	a.IdFactura	<> @pnIdFactura

				SELECT @sFacturaExiste = ISNULL(@sFacturaExiste,'')

				--SET @sError = 'La factura <b>'+@sNumFacturaFilial+'</b> no se puede procesar debido a que ya existe un certificado con la factura <b>'+@sFacturaExiste+'</b> con la misma información de viaje, pedido, ubicación de origen y producto.'
				SET @sError = 'No se puede generar el certificado debido a que ya existe otra factura <b>'+@sFacturaExiste+'</b> con la misma información de viaje, pedido, ubicación de origen y producto.'
				SET @pnClaEstatus = 9
				SET @psMensajeError = @sError 
				RETURN    				
			END
			ELSE
			BEGIN
				IF @pnDebug = 1
					SELECT '' AS 'INSERT AceSch.AceTraCertificado', * FROM @tbCertificados
				
				INSERT INTO AceSch.AceTraCertificado (
					ClaUbicacion,
					IdCertificado,
					IdViaje,
					IdFabricacion,
					ClaUbicacionOrigen,
					ClaArticuloExt,
					ClaCliente,
					NumViaje,
					IdFactura,
					NumFactura,
					NumPlan,
					FechaViaje,
					FechaCertificado,
					NumCertificado,
					Archivo,
					EsGenerado,
					FechaUltimaMod,
					NombrePcMod,
					ClaUsuarioMod,
					ClaConsignado,
					IdViajeTraspaso,
					Placas,
					NumPedCliente
				)
				SELECT	ClaUbicacion,
						IdCertificado,
						IdViaje,
						IdFabricacion,
						ClaUbicacionOrigen,
						ClaArticuloExt,
						ClaCliente,
						NumViaje,
						IdFactura,
						NumFactura,
						NumPlan,
						FechaViaje,
						FechaCertificado,
						NumCertificado,
						Archivo,
						EsGenerado,
						FechaUltimaMod,
						NombrePcMod,
						ClaUsuarioMod,
						ClaConsignado,
						IdViajeTraspaso,
						Placas,
						NumPedCliente
				FROM	@tbCertificados
			END
			
			---

			IF @pnEsRegeneraCertificado = 1
			BEGIN
				UPDATE AceSch.AceTraCertificado WITH(UPDLOCK)
				SET Archivo = NULL,
					EsGenerado = 0,
					FechaUltimaMod = GETDATE(),
					NombrePcMod = @psNombrePcMod,
					ClaUsuarioMod = @pnClaUsuarioMod
				WHERE ClaUbicacion = @pnClaUbicacion
				AND IdFactura = @pnIdFactura
				AND ClaUbicacionOrigen = @nClaAceria

				SELECT TOP 1 @nIdCertificado = IdCertificado
				FROM AceSch.AceTraCertificado WITH(NOLOCK)
				WHERE ClaUbicacion = @pnClaUbicacion
				AND IdFactura = @pnIdFactura
				AND ClaUbicacionOrigen = @nClaAceria

				IF @pnDebug = 1
					SELECT 'DELETE Certificado', @nIdCertificado as '@nIdCertificado', @pnClaUbicacion AS '@pnClaUbicacion'

				DELETE FROM AceSch.AceTraCertificadoDet WITH(ROWLOCK)
				WHERE ClaUbicacion = @pnClaUbicacion
				AND IdCertificado = @nIdCertificado
			END
			

			INSERT INTO AceSch.AceTraCertificadoDet
			SELECT
				@pnClaUbicacion ClaUbicacion,
				@nIdCertificado IdCertificado,
				ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) IdCertificadoDet,
				ClaHornoFusion,
				IdColada,
				ClaMolino,
				IdSecuencia,
				ClaArticulo,
				ClaArticuloExt,
				Cantidad,
				ClaGrado,
				ClaGradoCertificado,
				ClaNorma,
				ClaCalibre,
				0 BajaLogica,
				NULL FechaBajaLogica,
				GETDATE() FechaUltimaMod,
				@psNombrePcMod NombrePcMod,
				@pnClaUsuarioMod ClaUsuarioMod,
				ClaSeccion,
				ClaLongitud,
				ClaPeraltePerfil,
				ClaLbPiePerfil,
				ClaMedidaPerfil,
				ClaAnchoPerfil,
				ClaLado1Perfil,
				ClaLado2Perfil,
				ClaEspesorPerfil, 
				PesoEmbarque,
				PesoTeoricoProm
			FROM AceSch.AceTraCertificadoDet WITH(NOLOCK)
			WHERE ClaUbicacion = @pnClaUbicacionOrigen
			AND IdCertificado = @nIdCertificadoOrigen
			AND @nExisteCertificado = 1					-- Hv No registrar detalle sin encabezado (Error FK) 
			AND NOT EXISTS(
				SELECT 1
				FROM AceSch.AceTraCertificadoDet WITH(NOLOCK)
				WHERE ClaUbicacion = @pnClaUbicacion
				AND IdCertificado = @nIdCertificado
			)


			SET @psIdCertificado = ISNULL(@psIdCertificado,'') + ISNULL(CONVERT(VARCHAR(20), @nIdCertificado)+ ',', '')

			IF @pnDebug = 1
				SELECT @psIdCertificado AS '@psIdCertificado', @nIdCertificado AS '@nIdCertificado'

			DECLARE
				@sRutaServidorRS VARCHAR(1000),
				@sRutaReporte VARCHAR(1000),
				@sRutaFinalArchivo VARCHAR(1000),
				@bArchivo VARBINARY(MAX),
				@nError INT = 0

			SELECT
				@sRutaServidorRS = ACESch.AceConfiguracionTextoFn(3015, @pnClaUbicacion, 1),
				@sRutaReporte = ACESch.AceConfiguracionTextoFn(1, @pnClaUbicacion, 1),
				@sRutaFinalArchivo =  AceSch.AceConfiguracionTextoFn(3051, @pnClaUbicacion, 1)

			SELECT
				@sRutaServidorRS = CASE WHEN RTRIM(LTRIM(ISNULL(@sRutaServidorRS, ''))) = '' THEN 'http://repcenace/ReportServer' ELSE @sRutaServidorRS END,
				@sRutaReporte = CASE WHEN LTRIM(RTRIM(ISNULL(@sRutaReporte, ''))) = '' THEN '/ACE/Reports/IIDEA.ACE.CAL/INGETEK/RptCertificadoCalidadxColada' ELSE @sRutaReporte END,
				@sRutaFinalArchivo = CASE WHEN LTRIM(RTRIM(ISNULL(@sRutaFinalArchivo, ''))) = '' THEN '\\appnet02\Certificados' ELSE @sRutaFinalArchivo END
		
			
			IF @pnDebug = 1
				SELECT 'EXEC AceSch.AceImprimeCertificadoSuministroDirectoProc ANTES' , @psIdCertificado AS '@psIdCertificado', @nError AS '@nError'
			
			IF @nError = 0
			BEGIN
				EXEC AceSch.AceImprimeCertificadoSuministroDirectoProc
				@pnClaUbicacion = @pnClaUbicacion,
				@pnIdCertificado = @nIdCertificado,
				@pnClaIdioma = 0,
				@psRutaServidorRS = @sRutaServidorRS,
				@psRutaReporte = @sRutaReporte,
				@psRutaFinalArchivo = @sRutaFinalArchivo,
				@pbArchivo = @bArchivo OUT,
				@pnError = @nError OUT

				IF @pnDebug = 1
					SELECT 'EXEC AceSch.AceImprimeCertificadoSuministroDirectoProc' 

				IF ISNULL(@nError, 0) > 0
				BEGIN
					SET @sError = 'Error en la generación del archivo(AceImprimeCertificadoSuministroDirectoProc)'
					SET @pnClaEstatus = 8
					SET @psMensajeError = @sError			
					RETURN	
				END

				UPDATE AceSch.AceTraCertificado WITH(UPDLOCK)
				SET
					Archivo = @bArchivo,
					EsGenerado = 1,
					FechaUltimaMod = GETDATE(),
					NombrePcMod = @psNombrePcMod,
					ClaUsuarioMod = @pnClaUsuarioMod
				WHERE ClaUbicacion = @pnClaUbicacion
				AND IdFactura = @pnIdFactura
				AND ClaUbicacionOrigen = @nClaAceria
			END

			SET @nCount = @nCount + 1
		END

		SET @psIdCertificado = LEFT(RTRIM(LTRIM(@psIdCertificado)),LEN(RTRIM(LTRIM(@psIdCertificado))) -1)

	END TRY
	BEGIN CATCH
		SET @sError = ERROR_MESSAGE() + ' [' + ERROR_PROCEDURE() +']'
		SET @pnClaEstatus = -1
		SET @psMensajeError = @sError	
		RETURN -1
	END CATCH

	SET NOCOUNT OFF
END