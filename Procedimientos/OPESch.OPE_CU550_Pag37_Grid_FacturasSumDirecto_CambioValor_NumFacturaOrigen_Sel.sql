USE Operacion
GO
	-- 'OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_CambioValor_NumFacturaOrigen_Sel'
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_CambioValor_NumFacturaOrigen_Sel
	  @psNumFacturaOrigen	VARCHAR(15) 
AS
BEGIN
	SET NOCOUNT ON

	DECLARE	  @sMensajeError		VARCHAR(1000) = ''
			, @sNumFacturaOrigen	VARCHAR(15)
			, @nClaUbicacionOrigen	INT = NULL
			, @sNomUbicacionOrigen	VARCHAR(90)

	SET @sNumFacturaOrigen = @psNumFacturaOrigen

	SELECT	@nClaUbicacionOrigen	= ClaUbicacion
	FROM	DEAOFINET04.Operacion.AceSch.VtaCTraFacturaVw
	WHERE	IdFacturaAlfanumerico	= @psNumFacturaOrigen

	SELECT	@sNomUbicacionOrigen = CONVERT(VARCHAR(10),a.ClaUbicacion) + ' - ' + a.NomUbicacion
	FROM	OpeSch.OpeTiCatUbicacionVw a
	WHERE	ClaUbicacion = @nClaUbicacionOrigen


	SELECT	  NumFacturaOrigen	 = @sNumFacturaOrigen --CASE WHEN @sNumFacturaOrigen IS NULL THEN NULL ELSE @sNumFacturaOrigen END
			, ClaUbicacionOrigen = @nClaUbicacionOrigen
			, NomUbicacionOrigen = @sNomUbicacionOrigen


	IF @nClaUbicacionOrigen IS NULL
	BEGIN
		SELECT @sMensajeError = 'La factura <b>' + @sNumFacturaOrigen + '</b> de Origen no existe.'
		RAISERROR(@sMensajeError,16,1)
		RETURN 
	END

	SET NOCOUNT OFF

END