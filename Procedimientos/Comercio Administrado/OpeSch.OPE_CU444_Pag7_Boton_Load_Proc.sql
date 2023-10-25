USE operacion
-- EXEC SP_HELPTEXT 'OpeSch.OPE_CU444_Pag7_Boton_Load_Proc'
GO
ALTER PROCEDURE OpeSch.OPE_CU444_Pag7_Boton_Load_Proc
	@pnClaUbicacion int ,
	@pnClaPlanCarga	int
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		EsCargaTerminada = IsNull(EsCargaTerminada, 0) 
		, etiqPlanFinalizado = CASE WHEN EsCargaTerminada = 1 OR ClaEstatusPlanCarga >= 2 THEN 'Plan Finalizado' ELSE '' END
		, ClaPlanCargaAux = IdPlanCarga
	FROM OpeSch.OpeTraPlanCarga WITH (NOLOCK)
	WHERE ClaUbicacion = @pnClaUbicacion
	AND IdPlanCarga = @pnClaPlanCarga

	SET NOCOUNT OFF
END