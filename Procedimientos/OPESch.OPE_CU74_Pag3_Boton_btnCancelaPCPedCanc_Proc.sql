USE Operacion
GO
ALTER PROC OPESch.OPE_CU74_Pag3_Boton_btnCancelaPCPedCanc_Proc
@pnClaUbicacion			INT,
@pnIdPlanCarga			INT OUTPUT,	
@pnClaUsuarioMod		INT,
@psNombrePcMod			VARCHAR(64) ,
@pnEsOCPedCanc			INT = NULL 
AS
BEGIN
	SET NOCOUNT ON 

	EXEC OpeSch.OPE_CU74_Pag3_Boton_btnEliminarPlanCarga_Proc	@pnClaUbicacion		= @pnClaUbicacion ,
																@pnIdPlanCarga		= @pnIdPlanCarga  OUTPUT,	
																@pnClaUsuarioMod	= @pnClaUsuarioMod ,
																@psNombrePcMod		= @psNombrePcMod  ,
																@pnEsOCPedCanc		= @pnEsOCPedCanc 


	
	SET NOCOUNT OFF
END