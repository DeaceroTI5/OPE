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
