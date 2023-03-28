Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 
CREATE PROCEDURE FLESch.FLE_CU6_Pag1_Grid_PedidoCU6P1_Sel
	@pnClaUbicacion INT,
	@pnNumEntsal INT,
	@pnNumViajeCU6P1 INT,
	@pnNumFactura int,	
	@psIdioma VARCHAR(10) = 'Spanish',
	@pnClaIdioma INT = 5	
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @nContinuar	TINYINT
 
	EXEC FLESch.FLE_CU6_Pag1_Grid_PedidoCU6P1_Sel_Before @pnClaUbicacion OUTPUT, @pnNumEntsal OUTPUT, @pnNumViajeCU6P1 OUTPUT, @pnNumFactura OUTPUT, @psIdioma OUTPUT, @pnClaIdioma OUTPUT, @nContinuar OUTPUT
 
	IF ISNULL(@nContinuar,1) = 0
		GOTO FIN
		
	SELECT	t0.CantSurtida AS CantSurtida
			,t0.FactorCubicaje AS FactorCubicaje
			,t0.KgCubicados AS KgCubicados
			,t0.KgSurtidos AS KgSurtidos
			,t0.KgTaras AS KgTaras
			,t0.NumViaje AS NumViaje
	FROM	FLESch.FLETraViajeEntsalDetVw t0 WITH(NOLOCK)
	WHERE (@pnClaUbicacion IS NULL OR t0.ClaUbicacion = @pnClaUbicacion)
	AND		(@pnNumEntsal IS NULL OR t0.NumEntsal = @pnNumEntsal)
	AND		(@pnNumViajeCU6P1 IS NULL OR t0.NumViaje = @pnNumViajeCU6P1)
 
FIN:
	SET NOCOUNT OFF
END