USE Operacion
GO
ALTER PROCEDURE OpeSch.OpeRelFacturaSuministroDirectoIU
	  @pnClaUbicacionFilial	INT
	, @psNumFacturaFilial	VARCHAR(50)
	, @pnIdFacturaFilial	INT
	, @pnClaUbicacionOrigen	INT
	, @psNumFacturaOrigen	VARCHAR(50)	
	, @pnIdFacturaOrigen	INT	
	, @psMensajeError		VARCHAR(500)		
	, @pnIdCertificado		INT
	, @psNumCertificado		VARCHAR(500)	
	, @pnClaAceria			INT
	, @psArchivo			VARBINARY(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON

	DECLARE  @nClaUsuarioMod	INT				= 1
			, @sNombrePcMod		VARCHAR(64)		= 'GeneraCertificadoFilialIU'

	IF @psArchivo IS NULL 
		SELECT  @psArchivo		= Archivo
		FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK)
		WHERE	ClaUbicacion	= @pnClaUbicacionFilial
		AND		IdCertificado	= @pnIdCertificado


	IF NOT EXISTS (
		SELECT	1
		FROM	OpeSch.OpeRelFacturaSuministroDirecto WITH(NOLOCK)
		WHERE	ClaUbicacion		= @pnClaUbicacionFilial
		AND		NumFacturaFilial	= @psNumFacturaFilial
		AND		ClaAceriaOrigen		= @pnClaAceria
	)
	BEGIN
		IF EXISTS(
			SELECT	1
			FROM	OpeSch.OpeRelFacturaSuministroDirecto WITH(NOLOCK)
			WHERE	ClaUbicacion		= @pnClaUbicacionFilial
			AND		NumFacturaFilial	= @psNumFacturaFilial
			AND		ClaAceriaOrigen		IS NULL
			AND		BajaLogica			= 0
		)
		BEGIN
			-- Relación nueva por actualizar 
			UPDATE	OpeSch.OpeRelFacturaSuministroDirecto WITH(UPDLOCK)
			SET		ClaAceriaOrigen		= @pnClaAceria,			--Actualiza Aceria
					ClaEstatus			= 3,
					MensajeError		= @psMensajeError,
					NumCertificado		= @psNumCertificado,
					IdCertificado		= @pnIdCertificado,
					ArchivoCertificado	= @psArchivo,
					FechaUltimaMod		= GETDATE(),
					NumError			= 0,
					ClaUsuarioMod		= @nClaUsuarioMod,
					NombrePcMod			= @sNombrePcMod
			WHERE	ClaUbicacion		= @pnClaUbicacionFilial
			AND		NumFacturaFilial	= @psNumFacturaFilial
			AND		ClaAceriaOrigen		IS NULL
			AND		BajaLogica			= 0
		END
		ELSE
		BEGIN
			-- Registrar relación por acería (Ya existe otro certificado de otra acería para la factura filial)
			DECLARE @nIdRelFactura INT

			SELECT	@nIdRelFactura = ISNULL(MAX(IdRelFactura),0) + 1
			FROM	OpeSch.OpeRelFacturaSuministroDirecto WITH(NOLOCK)
			WHERE	ClaUbicacion = @pnClaUbicacionFilial

			INSERT INTO OpeSch.OpeRelFacturaSuministroDirecto (
				  ClaUbicacion
				, IdRelFactura
				, NumFacturaFilial
				, IdFacturaFilial
				, ClaUbicacionOrigen
				, NumFacturaOrigen
				, IdFacturaOrigen
				, ClaEstatus
				, MensajeError
				, IdCertificado
				, NumCertificado
				, ClaAceriaOrigen
				, ArchivoCertificado
				, ClaUsuarioMod
				, NombrePcMod
				, FechaUltimaMod
				, NumError
			) VALUES (
				  @pnClaUbicacionFilial		-- ClaUbicacion
				, @nIdRelFactura			-- IdRelFactura
				, @psNumFacturaFilial		-- NumFacturaFilial
				, @pnIdFacturaFilial		-- IdFacturaFilial
				, @pnClaUbicacionOrigen		-- ClaUbicacionOrigen
				, @psNumFacturaOrigen		-- NumFacturaOrigen
				, @pnIdFacturaOrigen		-- IdFacturaOrigen
				, 3							-- ClaEstatus	
				, @psMensajeError			-- MensajeError
				, @pnIdCertificado			-- IdCertificado
				, @psNumCertificado			-- NumCertificado
				, @pnClaAceria				-- ClaAceriaOrigen
				, @psArchivo				-- ArchivoCertificado
				, @nClaUsuarioMod			-- ClaUsuarioMod
				, @sNombrePcMod				-- NombrePcMod
				, GETDATE()					-- FechaUltimaMod	
				, 0							-- NumError
			)
		END
	END
	ELSE
	BEGIN
		-- Existe relacion por aceria
		UPDATE	OpeSch.OpeRelFacturaSuministroDirecto WITH(UPDLOCK)
		SET		ClaEstatus			= 3,
				MensajeError		= @psMensajeError,
				NumCertificado		= @psNumCertificado,
				IdCertificado		= @pnIdCertificado,
				ArchivoCertificado	= @psArchivo,
				FechaUltimaMod		= GETDATE(),
				NumError			= 0,
				ClaUsuarioMod		= @nClaUsuarioMod,
				NombrePcMod			= @sNombrePcMod
		WHERE	ClaUbicacion		= @pnClaUbicacionFilial
		AND		NumFacturaFilial	= @psNumFacturaFilial
		AND		ClaAceriaOrigen		= @pnClaAceria
	END

	SET NOCOUNT OFF
END