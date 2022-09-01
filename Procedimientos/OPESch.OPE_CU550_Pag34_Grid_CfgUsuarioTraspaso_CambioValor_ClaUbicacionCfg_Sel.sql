USE Operacion
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag34_Grid_CfgUsuarioTraspaso_CambioValor_ClaUbicacionCfg_Sel
	  @pnClaTipoUbicacion		INT = NULL
	, @pnClaUbicacionCfg		INT
AS
BEGIN
	SET NOCOUNT ON

	IF @pnClaUbicacionCfg = -1 AND @pnClaTipoUbicacion IS NULL
	BEGIN
		SELECT @pnClaTipoUbicacion = -1
	END
	ELSE
	BEGIN
		SELECT	@pnClaTipoUbicacion = ClaTipoUbicacion
		FROM	OpeSch.OpeTiCatUbicacionVw
		WHERE	ClaUbicacion = @pnClaUbicacionCfg
	END

	SELECT ClaTipoUbicacion = @pnClaTipoUbicacion

	SET NOCOUNT OFF
END