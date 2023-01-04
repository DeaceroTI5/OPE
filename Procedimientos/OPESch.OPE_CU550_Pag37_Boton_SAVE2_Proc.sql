USE Operacion
GO
	-- 'OPESch.OPE_CU550_Pag37_Boton_SAVE2_Proc'
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag37_Boton_SAVE2_Proc
	  @pnClaUbicacion	INT
	, @pnDebug			TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	SELECT @pnDebug = ISNULL(@pnDebug,0)

	IF @@SERVERNAME <> 'SRVDBDES01\ITKQA'	-- No afectar en ambiente de pruebas
	BEGIN
		--BEGIN TRAN OPE_CU550_Pag37_Boton_SAVE2_Proc
		BEGIN TRY

			EXEC [OpeSch].[OPE_CU550_Pag37_GeneraCertificadoFilial]
				  @pnClaUbicacion		= @pnClaUbicacion
				, @psNumFacturaFilial	= ''
				, @pnIdFacturaFilial	= NULL
				, @pnDebug				= @pnDebug

		--COMMIT TRAN OPE_CU550_Pag37_Boton_SAVE2_Proc
		END TRY
		BEGIN CATCH
			
			--ROLLBACK TRAN OPE_CU550_Pag37_Boton_SAVE2_Proc

			DECLARE @sMsj VARCHAR(1000)
			SELECT @sMsj = 'Error: ' + ISNULL(ERROR_MESSAGE(),'')

			RAISERROR(@sMsj,16,1)
			RETURN
		END CATCH
	END

	SET NOCOUNT OFF
END