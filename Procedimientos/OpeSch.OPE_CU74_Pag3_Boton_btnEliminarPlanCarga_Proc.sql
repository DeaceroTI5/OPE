USE Operacion
GO
-- EXEC SP_HELPTEXT 'OpeSch.OPE_CU74_Pag3_Boton_btnEliminarPlanCarga_Proc'
GO
ALTER PROCEDURE OpeSch.OPE_CU74_Pag3_Boton_btnEliminarPlanCarga_Proc
	@pnClaUbicacion			INT,
	@pnIdPlanCarga			INT OUTPUT,	
	@pnClaUsuarioMod		INT,
	@psNombrePcMod			VARCHAR(64) ,
	@pnEsOCPedCanc			INT = NULL 
AS
BEGIN
	SET NOCOUNT ON  
	
	IF (@pnIdPlanCarga IS NOT NULL)
	BEGIN
		DECLARE @nClaEstatus INT
		DECLARE @nCuentaViaje INT
			
		SELECT	@nClaEstatus	= ClaEstatusPlanCarga
		FROM	OpeSch.Opetraplancarga WITH (NOLOCK)
		WHERE	IdPlanCarga		= @pnIdPlanCarga
		AND		ClaUbicacion	= @pnClaUbicacion
		
		SELECT TOP 1 @nCuentaViaje = (idViaje)
		FROM PloSch.plotraviaje WITH (NOLOCK)
		WHERE claUbicacion= @pnClaUbicacion
		AND IdPlanCarga = @pnIdPlanCarga
		
		IF @nClaEstatus = 2 AND ISNULL(@pnEsOCPedCanc,0)= 0 
		BEGIN		
			RAISERROR('No es posible eliminar un Plan de Carga que esta Facturado.', 16, 1)
			RETURN 
		END	
		IF @nClaEstatus > 2 AND @nClaEstatus <> 7
		BEGIN		
			RAISERROR('No es posible eliminar el Plan de Carga, por el estatus en el que se encuentra', 16, 1)
			RETURN 
		END	
		IF ISNULL(@nCuentaViaje,0) > 0 AND ISNULL(@pnEsOCPedCanc,0)= 0 
		BEGIN		
			RAISERROR('No es posible eliminar el Plan de Carga, porque ya tiene asociado un viaje', 16, 1)
			RETURN 
		END	
	END	

	BEGIN TRY
	BEGIN TRAN

		EXEC Plosch.PloPlanCargaSd 1,
							@pnClaUbicacion,
							@pnIdPlanCarga,
							@psNombrePcMod,
							@pnClaUsuarioMod

		EXEC Plosch.PloPlanCargaLocInvCerrarProc	1,
											@pnIdPlanCarga,
											@pnClaUbicacion

		EXEC Plosch.PloOPMCertificadoDesasociaPedidosProc	1,
													@pnClaUbicacion,
													@pnIdPlanCarga,
													'',
													1
													
		SET @pnIdPlanCarga = NULL
		
	COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
		BEGIN 
			DECLARE @sErrorMessage VARCHAR(250)
			SET @sErrorMessage =  ERROR_MESSAGE()
			RAISERROR( @sErrorMessage, 16, 1 )
			ROLLBACK TRANSACTION 				
			RETURN 
		END
	END CATCH

	SET NOCOUNT OFF 
END