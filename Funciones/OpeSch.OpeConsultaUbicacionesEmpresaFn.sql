USE Operacion
GO
ALTER FUNCTION OpeSch.OpeConsultaUbicacionesEmpresaFn 
(
	  @pnClaUbicacion		INT
	, @nClaEmpresa			INT
	, @pnClaConfiguracion	INT
)
RETURNS TABLE
AS
RETURN (
	SELECT DISTINCT 
			  ClaUbicacion = LTRIM(RTRIM(string))
			, b.NomUbicacion
			, b.BajaLogica
	FROM	OpeSch.OpeUtiSplitStringFn	(
		(	
			SELECT '277, 278, 364,'
			--SELECT	sValor1
			--FROM	OpeSch.OpeTiCatConfiguracionVw
			--WHERE	ClaUbicacion		= @pnClaUbicacion
			--AND		ClaSistema			= 127
			--AND		ClaConfiguracion	= @pnClaConfiguracion
		), ',') a
	INNER JOIN OpeSch.OpeTiCatUbicacionVw b
	ON		a.string = b.ClaUbicacion
	UNION
	SELECT    a.ClaUbicacion
			, a.NomUbicacion
			, a.BajaLogica
	FROM	OpeSch.OpeTiCatUbicacionVw a
	WHERE	ClaEmpresa	= @nClaEmpresa
)