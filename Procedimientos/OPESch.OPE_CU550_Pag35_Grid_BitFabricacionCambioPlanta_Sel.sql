ALTER PROCEDURE OPESch.OPE_CU550_Pag35_Grid_BitFabricacionCambioPlanta_Sel
	@pnClaPedidoBit	INT = NULL
AS
BEGIN
	SET NOCOUNT ON

	EXEC OPESch.OPE_CU550_Pag32_Grid_BitFabricacionCambioPlanta_Sel
		@pnClaPedidoBit = @pnClaPedidoBit

	SET NOCOUNT OFF
END