USE Operacion
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag32_Boton_btnTraspaso_Proc
	  @pnClaUbicacion		INT
--	, @pnClaUbicacionPide	INT
	, @pnClaUbicacionSurte	INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE   @nClaEmpresa			INT
			, @nClaConfiguracion	INT
			, @nEsAceptaAntes		TINYINT
			, @nEsAceptaParcial		TINYINT
			, @nEsTraspasoEmpresa	TINYINT

	--/* Asignacion de valores default */
	SELECT	  @nClaEmpresa			= 52 -- INGETEK
			, @nClaConfiguracion	= 1271221
			, @nEsAceptaAntes		= 0
			, @nEsAceptaParcial		= 0
			, @nEsTraspasoEmpresa	= 0

	CREATE TABLE #TmpUbicaciones
	(
		  ClaUbicacion	INT
		, BajaLogica	TINYINT
	)
	
	INSERT INTO #TmpUbicaciones (ClaUbicacion, BajaLogica)
	SELECT	ClaUbicacion, BajaLogica 
	FROM	OpeSch.OpeConsultaUbicacionesEmpresaFn(@pnClaUbicacion, @nClaEmpresa, @nClaConfiguracion)


	-- /* Valida si es Traspaso entre misma Empresa* */
	IF EXISTS (
		SELECT	1
		FROM	#TmpUbicaciones
		WHERE	ClaUbicacion = @pnClaUbicacionSurte
		AND		BajaLogica = 0
	)
	BEGIN
		SELECT	  @nEsAceptaAntes		= 1
				, @nEsAceptaParcial		= 1
				, @nEsTraspasoEmpresa	= 1
	END


	--------------------------------------------------------------------------------------------------
	SELECT	  EsAceptaAntes		= @nEsAceptaAntes
			, EsAceptaParcial	= @nEsAceptaParcial
			, EsTraspasoEmpresa	= @nEsTraspasoEmpresa

	DROP TABLE #TmpUbicaciones
	SET NOCOUNT OFF
END
