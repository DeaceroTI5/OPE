USE Operacion
GO
ALTER PROCEDURE OPESch.OPE_CU71_Pag1_Boton_btnLimpiarPantallaMod711_Proc
	@pnClaUbicacion		INT
	,@pnIdViajeMod711	INT = NULL
	,@pnEsModal711		TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON	
	
	DECLARE @nIdViajeMod711 INT
	DECLARE @nIdBoletaMod711 INT
	DECLARE @sPlacaMod711 VARCHAR(12)
	DECLARE @nIdPlanCargaMod711 INT
	DECLARE @nEsPesajeParcialMod711 INT
	DECLARE @nIdTabularMod711 INT
	DECLARE @nPorcRealMod711 NUMERIC(13,2)
	
	DECLARE @nPorcCubMod711 NUMERIC(13,2)
	DECLARE @sMontacarguistaMod711 VARCHAR(100)
	DECLARE @nClaMovEntSalMod711 INT
	DECLARE @nClaFactura INT
	DECLARE @nRemisionSN INT
	DECLARE @nEnPlanta INT
	DECLARE @nCopiaTranspSN INT
	DECLARE @nClaViaje INT
	DECLARE @nClaFabricacion INT
	DECLARE @nEsNacional INT

	IF ISNULL(@pnEsModal711,0) = 1
		SET @nIdViajeMod711 = @pnIdViajeMod711
		
	SELECT @nIdViajeMod711 AS IdViajeMod711,
		@nIdBoletaMod711 AS IdBoletaMod711,
		@sPlacaMod711 AS PlacaMod711,
		@nIdPlanCargaMod711 AS IdPlanCargaMod711,
		@nEsPesajeParcialMod711 AS EsPesajeParcialMod711,
		@nIdTabularMod711 AS IdTabularMod711,
		@nPorcRealMod711 AS PorcRealMod711,
		@nPorcCubMod711 AS PorcCubMod711,
		@sMontacarguistaMod711 AS MontacarguistaMod711,
		@nClaMovEntSalMod711 AS ClaMovEntSalMod711,
		@nClaFactura AS ClaFactura,
		@nRemisionSN AS RemisionSN,
		@nEnPlanta AS EnPlanta,
		@nCopiaTranspSN AS CopiaTranspSN,
		@nClaViaje AS ClaViaje,
		@nClaFabricacion AS ClaFabricacion,
		@nEsNacional AS EsNacional

	SET NOCOUNT OFF
END