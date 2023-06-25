---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CREATE PROCEDURE OpeSch.OPE_CU71_Pag1_ImprimirSrvBack_Proc
DECLARE
	@pnClaUbicacion		INT = 267,
	@pnIdBoletaMod711	INT,
	@pnClaIdioma		INT = 5,
	@psNombrePcMod		VARCHAR(64) ='100-Hvalle',
	@pnIdOrdenEnvio		INT = 0,
	@nIdViaje			INT = 86

	SELECT	@pnIdBoletaMod711 = IdBoleta
	FROM	OpeSch.OpeTraViaje 
	WHERE	IdViaje = @nIdViaje

	--SELECT @pnIdBoletaMod711 AS '@pnIdBoletaMod711'

IF 1=1--AS
BEGIN 
	SET NOCOUNT ON  

	DECLARE @nClaMotivoEntrada INT
	DECLARE @nEsFacturacion INT
	DECLARE @nIdPlanCargaFact INT
	
	IF EXISTS(SELECT 1
				FROM OpeSch.OpeTraBoleta WITH(NOLOCK)
				WHERE ClaUbicacion = @pnClaUbicacion AND 
					IdBoleta = @pnIdBoletaMod711)
	BEGIN
		SELECT @nClaMotivoEntrada = A.ClaMotivoEntrada,
			@nEsFacturacion = (CASE WHEN A.ClaMotivoEntrada = 1 THEN 1 ELSE 0 END),
			@nIdPlanCargaFact = B.IdPlanCarga
		FROM OpeSch.OpeTraBoleta A WITH(NOLOCK)
		LEFT JOIN OpeSch.OpeTraPlanCarga B WITH(NOLOCK) ON
			B.ClaUbicacion = A.ClaUbicacion AND
			B.IdBoleta = A.IdBoleta
		WHERE A.ClaUbicacion = @pnClaUbicacion AND 
			A.IdBoleta = @pnIdBoletaMod711
	END
	ELSE
	BEGIN
		SELECT @nClaMotivoEntrada = ClaMotivoEntrada,
			@nEsFacturacion = 0
		FROM OpeSch.OpeTraBoletaHis WITH(NOLOCK)
		WHERE ClaUbicacion = @pnClaUbicacion AND 
			IdBoleta = @pnIdBoletaMod711 
	END

	--SELECT @nIdPlanCargaFact AS '@nIdPlanCargaFact', @nClaMotivoEntrada AS '@nClaMotivoEntrada', @nEsFacturacion AS '@nEsFacturacion'

	EXEC OPESch.OPE_ImprimirSrvBack_ProcHv
		@pnClaUbicacion = @pnClaUbicacion,
		@pnClaMotivoEntrada = @nClaMotivoEntrada,
		@pnIdboleta = @pnIdBoletaMod711,
		@pnIdPlanCargaFact = @nIdPlanCargaFact,
		@pnClaIdioma = @pnClaIdioma,
		@pnEsFacturacion = @nEsFacturacion,
		@psNombrePcMod = @psNombrePcMod,
		@pnIdOrdenEnvio = @pnIdOrdenEnvio
		--,@pnDebug = 1
			
	SET NOCOUNT OFF
END
