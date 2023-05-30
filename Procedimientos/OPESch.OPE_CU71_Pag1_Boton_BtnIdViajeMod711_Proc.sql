CREATE PROC OPESch.OPE_CU71_Pag1_Boton_BtnIdViajeMod711_Proc
	@pnClaUbicacion int,
	@pnIdViajeMod711 int
AS
BEGIN
	SET NOCOUNT ON

	EXEC OpeSch.OPE_CU71_Pag1_Boton_IdViajeMod711_Proc
		 @pnClaUbicacion = @pnClaUbicacion
		,@pnIdViajeMod711 = @pnIdViajeMod711

	SET NOCOUNT OFF
END