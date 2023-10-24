CREATE PROCEDURE OpeSch.OPE_CU444_Pag7_Boton_Load_Proc
	@pnClaUbicacion int ,
	@pnClaPlanCarga	int
AS
BEGIN	
	SELECT 
		EsCargaTerminada = IsNull(EsCargaTerminada, 0) 
		, etiqPlanFinalizado = CASE WHEN EsCargaTerminada = 1 OR ClaEstatusPlanCarga >= 2 THEN 'Plan Finalizado' ELSE '' END
	from OpeSch.OpeTraPlanCarga WITH (NOLOCK)
	where ClaUbicacion = @pnClaUbicacion
	and IdPlanCarga = @pnClaPlanCarga
END