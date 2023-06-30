USE Operacion
GO
-- [ACESch].[AceGeneraCertificadoPuntoLogisticoSrv]
BEGIN TRAN

SELECT * FROM OpeSch.OpeRelFacturaSuministroDirecto WITH(NOLOCK) WHERE IdFacturaOrigen = 50399234
ORDER BY FechaUltimaMod DESC

SELECT * FROM DEAOFINET04.Operacion.AceSch.AceTraCertificado a WITH(NOLOCK) WHERE ClaUbicacion = 150 AND IdFactura = 50399234	--@pnIdFacturaOrigen
SELECT * FROM DEAOFINET04.Operacion.AceSch.AceTraCertificado b WITH(NOLOCK) WHERE	ClaUbicacion = 324  AND	IdFactura = 1034003611	--@pnIdFactura



DECLARE @nClaUbicacionOrigen INT = 22
		,@pnEsRegeneraCertificado INT = 0


	SELECT *
	FROM	DEAOFINET04.Operacion.AceSch.AceTraCertificado a WITH(NOLOCK)
	WHERE ClaUbicacion = 150--@pnClaUbicacionOrigen
	AND IdFactura = 50399234--@pnIdFacturaOrigen
--	AND ClaUbicacionOrigen = @nClaUbicacionOrigen
	AND NOT EXISTS(
		SELECT 1
		FROM	DEAOFINET04.Operacion.AceSch.AceTraCertificado b WITH(NOLOCK)
		WHERE	ClaUbicacion = 324 --@pnClaUbicacion
		AND		IdFactura = 1034003611--@pnIdFactura
		AND		a.ClaUbicacionOrigen = b.ClaUbicacionOrigen-- = @nClaUbicacionOrigen
		AND		@pnEsRegeneraCertificado = 0
	--	AND		b.Archivo IS NULL
	)

ROLLBACK TRAN