USE Operacion
GO
	-- 'OPESch.OPE_CU550_Pag30_Boton_ConfirmarDocumento_Proc'
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag30_Boton_ConfirmarDocumento_Proc
	  @pnClaUbicacion			INT
	, @pnIdViajeMod				INT
	, @pnIdDocumentoMod			INT = NULL
	, @pnClaTipoDocumentoMod	INT
	, @pnNumDocumentoMod		INT = NULL
	, @pnEsNuevoDoc				TINYINT
	, @pnClaFabricacionMod		INT = NULL
	, @pnClaOrigenDocumentoMod	INT = NULL
AS
BEGIN
	SET NOCOUNT ON

	IF @pnClaTipoDocumentoMod = 37 AND ISNULL(@pnClaOrigenDocumentoMod,0) = 0
	BEGIN
		RAISERROR ('El campo Origen Documento es requerido. Favor de verificar.',16,1)
		RETURN
	END

	DECLARE   @nIdFactura			INT
			, @nExisteArchivo		TINYINT = 0
			, @sMsjConfirmaRegistro	VARCHAR(200) = ''
			, @nCantRegistros		INT


	SELECT @nIdFactura = @pnIdDocumentoMod

	IF @nIdFactura IS NULL 
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

	-- Editar			
	IF @pnEsNuevoDoc = 0
	BEGIN
		SELECT	  @nExisteArchivo		= 1
				, @sMsjConfirmaRegistro = '¿Seguro que deseas actualizar el registro?'		
	
		GOTO FIN
	END

	IF ISNULL(@pnNumDocumentoMod,0) > 0
	BEGIN
		IF EXISTS(	
			SELECT	1 
			FROM	OpeSch.OpeRelViajeDocumento WITH(NOLOCK) 
			WHERE	ClaUbicacion	= @pnclaUbicacion 
			AND		IdViaje			= @pnIdViajeMod
			AND		IdDocumento		= @nIdFactura
			AND		ClaTipoDocumento = @pnClaTipoDocumentoMod
			AND		NumDocumento	= @pnNumDocumentoMod
		)
		BEGIN
			DECLARE @sTipoDocumento VARCHAR(50)

			SELECT	@sTipoDocumento = NomFormatoImpresion 
			FROM	OpeSch.OpeCatFormatoImpresion
			WHERE	ClaFormatoImpresion = @pnClaTipoDocumentoMod

			SELECT	  @nExisteArchivo		= 1
					, @sMsjConfirmaRegistro = 'Ya existe un registro para el Tipo de Documento <b>'+@sTipoDocumento+'</b> y Número de Documento <b>' 
												+ CONVERT(VARCHAR(10),@pnNumDocumentoMod) +'</b> ¿Deseas reemplazarlo?'
		END
	END
	ELSE
	BEGIN
		SELECT	@nCantRegistros = COUNT(1) 
		FROM	OpeSch.OpeRelViajeDocumento WITH(NOLOCK) 
		WHERE	ClaUbicacion	= @pnclaUbicacion 
		AND		IdViaje			= @pnIdViajeMod
		AND		IdDocumento		= @nIdFactura
		AND		ClaTipoDocumento = @pnClaTipoDocumentoMod

		SET @nCantRegistros = ISNULL(@nCantRegistros,0)

		IF @nCantRegistros = 1
		BEGIN
			SELECT	  @nExisteArchivo		= 2
					, @sMsjConfirmaRegistro = 'Ya existe un registro para este tipo de documento ¿Deseas reemplazarlo o generar uno nuevo?'			
		END
		ELSE
		IF @nCantRegistros > 1
		BEGIN
			SELECT	  @nExisteArchivo		= 3
					, @sMsjConfirmaRegistro = 'Ya existen registros para este tipo de documento ¿Deseas generar uno nuevo?'
		END
	END

	FIN:
	SELECT	  ExisteArchivo		 = @nExisteArchivo		-- 1- Num.Documento > 0 ; 2- Num.Documento= 0 & CantRegistros = 1 ; 3- Num.Documento= 0 & CantRegistros > 1
			, EtConfirmaRegistro = @sMsjConfirmaRegistro

	SET NOCOUNT OFF
END