USE Operacion
GO
-- EXEC SP_HELPTEXT 'OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_IU'
GO
ALTER PROCEDURE  OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_IU
	  @pnClaUbicacion		INT
	, @pnIdRelFactura		INT = NULL
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

	IF @pnIdRelFactura IS NULL
		SELECT  @pnIdRelFactura = IdRelFactura
		FROM	OpeSch.OpeRelFacturaSuministroDirecto WITH(NOLOCK)
		WHERE	ClaUbicacion		= @pnClaUbicacion
		AND		NumFacturaFilial	= @psNumFacturaFilial
		AND		IdFacturaFilial		= @nIdFacturaFilial


	IF NOT EXISTS (
		SELECT  1
		FROM	OpeSch.OpeRelFacturaSuministroDirecto WITH(NOLOCK)
		WHERE	ClaUbicacion		= @pnClaUbicacion
		AND		IdRelFactura		= @pnIdRelFactura
	)
	BEGIN
		SELECT	@pnIdRelFactura = ISNULL(MAX(IdRelFactura),0) + 1
		FROM	OpeSch.OpeRelFacturaSuministroDirecto WITH(NOLOCK)
		WHERE	ClaUbicacion = @pnClaUbicacion

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
		) VALUES (
			  @pnClaUbicacion			-- ClaUbicacion
			, @pnIdRelFactura			-- IdRelFactura
			, @psNumFacturaFilial		-- NumFacturaFilial
			, @nIdFacturaFilial			-- IdFacturaFilial
			, @pnClaUbicacionOrigen		-- ClaUbicacionOrigen
			, @psNumFacturaOrigen		-- NumFacturaOrigen
			, @nIdFacturaOrigen			-- IdFacturaOrigen
			, 1							-- ClaEstatus			--Esperando generarse
			, NULL						-- MensajeError
			, NULL						-- IdCertificado
			, NULL						-- NumCertificado
			, NULL						-- ClaAceriaOrigen
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
		AND		IdRelFactura		= @pnIdRelFactura

		IF @pnDebug = 1
			SELECT @nEsBajaLogica AS '@nEsBajaLogica'

		IF @nEsBajaLogica = 0 AND @pnBajaLogica = 0
		BEGIN
			SELECT @sMensajeError =' La factura <b>'+@psNumFacturaFilial+'</b> ya tiene relación.'
			RAISERROR(@sMensajeError,16,1)
			RETURN
		END
			
		UPDATE	OpeSch.OpeRelFacturaSuministroDirecto WITH(UPDLOCK)  
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
		AND		IdRelFactura		= @pnIdRelFactura
	END

	SET NOCOUNT OFF
END