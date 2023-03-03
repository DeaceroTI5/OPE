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
	FROM	OpeSch.OpeVtaCTraFacturaVw
	WHERE	IdFacturaAlfanumerico	= @psNumFacturaOrigen

	IF @nClaUbicacionOrigen IS NULL
		SELECT	@nClaUbicacionOrigen	= ClaUbicacion
		FROM	DEAOFINET04.Operacion.AceSch.VtaCTraFacturaVw
		WHERE	IdFacturaAlfanumerico	= @psNumFacturaOrigen

	IF @nClaUbicacionOrigen IS NOT NULL
		SELECT	@sNomUbicacionOrigen = CONVERT(VARCHAR(10),a.ClaUbicacion) + ' - ' + a.NomUbicacion
		FROM	OpeSch.OpeTiCatUbicacionVw a
		WHERE	ClaUbicacion = @nClaUbicacionOrigen
	ELSE 
		SELECT	@sNomUbicacionOrigen = NULL

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
