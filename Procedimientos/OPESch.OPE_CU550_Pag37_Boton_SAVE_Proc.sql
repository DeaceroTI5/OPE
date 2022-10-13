ALTER PROCEDURE OPESch.OPE_CU550_Pag37_Boton_SAVE_Proc
	@pnClaUbicacion	INT
AS
BEGIN
	SET NOCOUNT ON

	IF @@SERVERNAME <> 'SRVDBDES01\ITKQA'	-- No afectar en ambiente de pruebas
	BEGIN
		BEGIN TRAN CU550Pag37_Save
		BEGIN TRY

			EXEC [OpeSch].[OPE_CU550_Pag37_GeneraCertificadoFilial]
				  @pnClaUbicacion		= @pnClaUbicacion
				, @psNumFacturaFilial	= ''
				, @pnIdFacturaFilial	= NULL
		
			COMMIT TRAN CU550Pag37_Save
		END TRY
		BEGIN CATCH
			
			DECLARE @sMsj VARCHAR(1000)
			SELECT @sMsj = 'Error: Trans('+CONVERT(VARCHAR,@@TRANCOUNT)+')' + ISNULL(ERROR_MESSAGE(),'')

			--IF (@@TRANCOUNT <> 0)
			--BEGIN
			--	BEGIN TRANSACTION CU550Pag37_Save
			--END



			RAISERROR(@sMsj,16,1)
			ROLLBACK TRAN CU550Pag37_Save
			RETURN
		END CATCH
	END

	SET NOCOUNT OFF
END
