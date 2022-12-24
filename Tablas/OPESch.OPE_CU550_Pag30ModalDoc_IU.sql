USE Operacion
GO
	-- 'OPESch.OPE_CU550_Pag30ModalDoc_IU'
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag30ModalDoc_IU
	@pnClaUbicacion			INT,
	@pnIdDocumentoMod		INT=NULL,
	@pnIdViajeMod			INT,
	@pbDocumentoWFileData	VARBINARY(MAX), -- Bits del archivo
	@psDocumentoWFileName	VARCHAR(50), -- Nombre del archivo en el cliente
	@psDocumentoWFileExt	VARCHAR(50), -- Extensión del archivo en el cliente
	@psDocumentoWFilePath	VARCHAR(300), -- Ruta del archivo en el cliente
	@pnClaUsuarioMod		INT,
	@psNombrePcMod			VARCHAR(64),
	@pnClaTipoDocumentoMod	INT,
	@pnNumDocumentoMod		INT,
	@pnEsNuevoDoc			TINYINT,
	@pnEsGenerarNuevo		TINYINT = 0,
	@pnEsReemplazar			TINYINT = 0,
	@pnClaFabricacionMod	INT = NULL,
	@pnClaOrigenDocumentoMod INT = NULL,
	@pnDebug				TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE	  @nIdFactura		INT

	-- SELECT @nIdFactura = @pnIdDocumentoMod
	IF @pnEsNuevoDoc = 1 --@nIdFactura IS NULL
		SELECT	@nIdFactura = t2.IdFactura 	
		FROM	OpeSch.OpeTraViaje t1 WITH(NOLOCK)
		LEFT JOIN OpeSch.OpeTraMovEntSal t2 WITH(NOLOCK)
		ON		t1.ClaUbicacion = t2.ClaUbicacion
		AND		t1.IdViaje		= t2.IdViaje
		AND		t1.IdBoleta		= t2.IdBoleta
		AND		t2.IdFactura IS NOT NULL
		WHERE	t1.ClaUbicacion	= @pnClaUbicacion
		AND		t1.IdViaje		= @pnIdViajeMod
		AND		t1.ClaEstatus	= 3
		AND		( @pnClaFabricacionMod IS NULL OR t2.IdFabricacion = @pnClaFabricacionMod )

	IF ISNULL(@nIdFactura,0) = 0
	BEGIN
		DECLARE @sMsj VARCHAR(200)
		SELECT	@sMsj = 'No se puede grabar debido a que el viaje ' +convert(VARCHAR(20),@pnIdViajeMod) + ' no tiene una factura asociada. Favor de verificar.'
		RAISERROR(@sMsj, 16, 1)
	END
	

	IF ISNULL(@pnEsReemplazar,0) = 1
	BEGIN
		IF ISNULL(@pnEsNuevoDoc,0) = 1			
		BEGIN
			SELECT	@pnNumDocumentoMod = MAX(NumDocumento)
			FROM	OpeSch.OpeRelViajeDocumento WITH(NOLOCK)
			WHERE	ClaUbicacion	= @pnclaUbicacion 
			AND		IdViaje			= @pnIdViajeMod
			AND		IdDocumento		= @nIdFactura
			AND		ClaTipoDocumento = @pnClaTipoDocumentoMod 		
		END

		UPDATE OpeSch.OpeRelViajeDocumento
		SET		Archivo			= NULL,	--@pbDocumentoWFileData, 
				NombreArchivo	= @psDocumentoWFileName, 
				ExtensionArchivo = @psDocumentoWFileExt,
				ClaUsuarioMod	= @pnClaUsuarioMod,
				NombrePcMod		= @psNombrePcMod,
				FechaUltimaMod	= GETDATE(),
				ClaOrigenDocumento = @pnClaOrigenDocumentoMod
		WHERE	ClaUbicacion	= @pnclaUbicacion 
		AND		IdViaje			= @pnIdViajeMod
		AND		IdDocumento		= @nIdFactura
		AND		ClaTipoDocumento = @pnClaTipoDocumentoMod 
		AND		NumDocumento	= @pnNumDocumentoMod
	END
	ELSE
	IF ISNULL(@pnEsGenerarNuevo,0) = 1
	BEGIN
		IF ISNULL(@pnNumDocumentoMod,0) = 0
			SELECT	@pnNumDocumentoMod = ISNULL(MAX(NumDocumento),0) + 1 
			FROM	OpeSch.OpeRelViajeDocumento WITH(NOLOCK) 
			WHERE	ClaUbicacion	= @pnclaUbicacion 
			AND		IdViaje			= @pnIdViajeMod
			AND		IdDocumento		 = @nIdFactura
			AND		ClaTipoDocumento = @pnClaTipoDocumentoMod
		
		INSERT INTO OpeSch.OpeRelViajeDocumento(
			  ClaUbicacion
			, IdViaje
			, IdDocumento
			, ClaTipoDocumento
			, Archivo
			, NombreArchivo
			, ExtensionArchivo
			, ClaUsuarioMod
			, NombrePcMod
			, FechaUltimaMod
			, NumDocumento
			, IdFabricacion
			, ClaOrigenDocumento
		)
		VALUES(
			  @pnclaUbicacion
			, @pnIdViajeMod
			, @nIdFactura
			, @pnClaTipoDocumentoMod
			, NULL--@pbDocumentoWFileData
			, @psDocumentoWFileName
			, @psDocumentoWFileExt
			, @pnClaUsuarioMod
			, @psNombrePcMod
			, GETDATE()
			, @pnNumDocumentoMod
			, @pnClaFabricacionMod
			, @pnClaOrigenDocumentoMod
		)
	END

	-- /*OpeReporteFactura*/ -- ClaUbicacion, IdFactura, ClaFormatoImpresion, IdCertificado
	IF NOT EXISTS (
			SELECT	1 
			FROM	OpeSch.OpeReporteFactura WITH(NOLOCK) 
			WHERE	ClaUbicacion	= @pnclaUbicacion 
			AND		IdFactura		= @nIdFactura
			AND		ClaFormatoImpresion = @pnClaTipoDocumentoMod 
			AND		IdCertificado	= @pnNumDocumentoMod
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
		)
		VALUES(
			  @pnclaUbicacion
			, @nIdFactura
			, @pnClaTipoDocumentoMod
			, @pnNumDocumentoMod
			, @pbDocumentoWFileData
			, GETDATE()
			, @psNombrePcMod
			, @pnClaUsuarioMod
		)
	END
	ELSE
	BEGIN
		UPDATE OpeSch.OpeReporteFactura
		SET		Impresion		= @pbDocumentoWFileData, 
				ClaUsuarioMod	= @pnClaUsuarioMod,
				NombrePcMod		= @psNombrePcMod,
				FechaUltimaMod	= GETDATE()
		WHERE	ClaUbicacion	= @pnclaUbicacion 
		AND		IdFactura		= @nIdFactura
		AND		ClaFormatoImpresion = @pnClaTipoDocumentoMod 
		AND		IdCertificado	= @pnNumDocumentoMod
	END

	SET NOCOUNT OFF
END