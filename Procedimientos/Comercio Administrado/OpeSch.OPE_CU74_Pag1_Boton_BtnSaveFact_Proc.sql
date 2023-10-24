CREATE PROCEDURE OpeSch.OPE_CU74_Pag1_Boton_BtnSaveFact_Proc
@pnClaUbicacion		INT,
@pnOCMF				INT	 
AS
BEGIN
	SET NOCOUNT ON 
	DECLARE @nCaptCert TINYINT  ,
			@nFAltaCapt TINYINT 

	SET @nCaptCert  =0 
	SET @nFAltaCapt = 0 

	SET @nCaptCert  =OpeSch.OpeGenCertifCalAcexTViajeransitSNFn(@pnClaUbicacion ,@pnOCMF  )
	
	IF ISNULL(@nCaptCert,0)= 1 
	BEGIN
		IF  NOT EXISTS (SELECT 1 FROM OpeSch.OPETraOrdenCargaColadaSecuencia WHERE ClaUbicacion = @pnClaUbicacion AND  IdOrdenCarga =  @pnOCMF AND ISNULL(BajaLogica,0)=0 )
		BEGIN

			SET @nFAltaCapt =1 

		END
	END 
	 
	SELECT EsFaltaCaptColada =  @nFAltaCapt

	SET NOCOUNT  OFF
END


Completion time: 2023-10-24T17:15:19.2824249-06:00
