USE Operacion
 EXEC SP_HELPTEXT 'OpeSch.OPE_CU74_Pag1_Boton_BtnSaveFact_Proc'
GO
ALTER PROCEDURE OpeSch.OPE_CU74_Pag1_Boton_BtnSaveFact_Proc
@pnClaUbicacion		INT,
@pnOCMF				INT	 
AS
BEGIN
	SET NOCOUNT ON 
	DECLARE @nCaptCert TINYINT  ,
			@nFAltaCapt TINYINT ,
	--Variables para validación de relación Itk - Asa
			@nEsValidaRelItkAsa	TINYINT = NULL,
			@sMensajeRelItkAsa	VARCHAR(2000) = '',
			@nId			INT,
			@nFabricacion	INT,
			@nFabricaciondet	INT,
			@nPesoDocumentado	NUMERIC(14,4),
			@nPesoRelacionado	NUMERIC(14,4)

	DECLARE @Fabricaciones TABLE(
		id				INT IDENTITY(1,1),
		Fabricacion		INT,
		FabricacionDet	INT)

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
	 
	--Validación por niveles de relación NIVEL 1, 2 y 3 Ingetek-ASA
	--Nivel 1: Relación Plan de Carga (Itk Usa) - Viaje (Itk Mx)
	IF NOT EXISTS (SELECT 1
				FROM OpeSch.OpeRelPlanCargaViajeOrigen
				WHERE ClaUbicacion = @pnClaUbicacion
				AND IdPlanCarga = @pnOCMF
				AND IdViajeOrigen IS NOT NULL)
	BEGIN
		SELECT @nEsValidaRelItkAsa = 0,
				@sMensajeRelItkAsa = 'Error Nivel 1: El Plan de Carga <b>'+CAST(@pnOCMF AS VARCHAR)+'</b> no tiene asociado algún viaje origen.'
	END
	--Validación Nivel 2: 
	ELSE 
	BEGIN
		 INSERT INTO @Fabricaciones
		 SELECT DISTINCT IdFabricacion, IdFabricacionDet
			FROM OpeSch.OpeTraPlanCargaDet
			WHERE ClaUbicacion = @pnClaUbicacion
			AND IdPlanCarga = @pnOCMF

		SELECT @nId = MIN(Id)
			FROM @Fabricaciones

		WHILE @nId IS NOT NULL
		BEGIN
			SELECT @nFabricacion = Fabricacion,
					@nFabricaciondet = FabricacionDet
				from @Fabricaciones
				WHERE id = @nId

			SELECT @nPesoRelacionado = SUM(PesoDocumentado)
				FROM OpeSch.OpeRelPlanCargaViajeOrigenDet
				WHERE ClaUbicacion = @pnClaUbicacion
					AND IdPlanCarga = @pnOCMF
					AND IdFabricacion = @nFabricacion
					AND IdFabricacionDet = @nFabricaciondet
					AND BajaLogica = 0

			SELECT @nPesoDocumentado = PesoEmbarcado
				FROM OpeSch.OpeTraPlanCargaDet
				WHERE ClaUbicacion = @pnClaUbicacion
					AND IdPlanCarga = @pnOCMF
					AND IdFabricacion = @nFabricacion
					AND IdFabricacionDet = @nFabricaciondet

			IF (@nPesoDocumentado <> @nPesoRelacionado)
			BEGIN	
				SELECT @nEsValidaRelItkAsa = 0,
						@sMensajeRelItkAsa = 'Error Nivel 2: El peso documentado para la fabricación <b>'+cast(@nFabricacion as VARCHAR)+'</b> renglón <b>'+CAST(@nFabricaciondet AS VARCHAR)+'</b> tiene diferencias con las relacionadas en el plan de carga'
			END

			SELECT @nId = MIN(Id)
				FROM @Fabricaciones
				WHERE id > @nId
		END

	END

	SELECT EsFaltaCaptColada	=  @nFAltaCapt,
			EsValidaRelItkAsa	= ISNULL(@nEsValidaRelItkAsa,1),
			MensajeRelItkAsa	= @sMensajeRelItkAsa

	SET NOCOUNT  OFF
END