USE Operacion
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag37_Boton_EsRegenerar_Proc
	  @pnClaUbicacion		INT
	, @pnIdRelFacturaP		INT
	, @psNombrePcMod		VARCHAR(64)  
	, @pnClaUsuarioMod		INT
	, @pnDebug				TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	DECLARE	  @nIdFacturaFilial		INT
			, @sFacturaFilial		VARCHAR(20)
			, @nClaAceriaOrigen		INT

	SELECT	  @sFacturaFilial		= NumFacturaFilial
			, @nIdFacturaFilial		= IdFacturaFilial
			, @nClaAceriaOrigen		= ClaAceriaOrigen
	FROM	OpeSch.OpeRelFacturaSuministroDirecto WITH(NOLOCK)
	WHERE	ClaUbicacion		= @pnClaUbicacion
	AND		IdRelFactura		= @pnIdRelFacturaP


	UPDATE	OpeSch.OpeRelFacturaSuministroDirecto WITH(UPDLOCK)  
	SET		 NombrePcMod		= @psNombrePcMod  
			,ClaUsuarioMod		= @pnClaUsuarioMod  
			,FechaUltimaMod		= GETDATE()
			,ClaEstatus			= 1
			,MensajeError		= ''
			,IdCertificado		= NULL
			,NumCertificado		= NULL
			,ArchivoCertificado	= NULL
	WHERE	ClaUbicacion		= @pnClaUbicacion
	AND		IdRelFactura		= @pnIdRelFacturaP

	IF @@SERVERNAME <> 'SRVDBDES01\ITKQA'
	BEGIN
		EXEC OpeSch.OPE_CU550_Pag37_GeneraCertificadoFilial
			  @pnClaUbicacion			= @pnClaUbicacion
			, @psNumFacturaFilial		= @sFacturaFilial
			, @pnIdFacturaFilial		= @nIdFacturaFilial
			, @pnEsRegenerarCertificado = 1
			, @pnClaAceria				= @nClaAceriaOrigen
			, @pnDebug					= 0
	END

	SET NOCOUNT OFF
END