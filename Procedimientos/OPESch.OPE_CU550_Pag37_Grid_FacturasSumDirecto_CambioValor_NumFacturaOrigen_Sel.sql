USE Operacion
GO
	-- 'OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_CambioValor_NumFacturaOrigen_Sel'
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_CambioValor_NumFacturaOrigen_Sel
	  @pnClaUbicacionOrigen	INT
	, @psNumFacturaOrigen	VARCHAR(15)
AS
BEGIN
	SET NOCOUNT ON

	IF ISNULL(@pnClaUbicacionOrigen,0) = 0
	BEGIN
		RAISERROR('El campo Ubicación Origen es requerido.',16,1)
	END

	DECLARE  @nTipoUbicacion		INT
			,@nClaUbicacionVentas	INT
			,@sMensajeError			VARCHAR(1000) = ''

	SELECT	@nTipoUbicacion		 = ClaTipoUbicacion,
			@nClaUbicacionVentas = ClaUbicacionVentas
	FROM	OpeSch.OpeTiCatUbicacionVw
	WHERE	ClaUbicacion = @pnClaUbicacionOrigen

	IF @nTipoUbicacion IN ( 2, 3, 4, 7)
	BEGIN
		IF NOT EXISTS(
					SELECT	1 
					FROM	DEAOFINET04.Operacion.AceSch.VtaCTraFacturaVw
					WHERE	ClaUbicacion			= @nClaUbicacionVentas
					AND		IdFacturaAlfanumerico	= @psNumFacturaOrigen
		)
		BEGIN
			SELECT @sMensajeError = 'La factura <b>' + @psNumFacturaOrigen + '</b> de Origen no existe.'
			RAISERROR(@sMensajeError,16,1)
			RETURN
		END
	END

	SET NOCOUNT OFF

END