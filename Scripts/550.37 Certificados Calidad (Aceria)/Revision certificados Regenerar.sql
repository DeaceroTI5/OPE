USE Operacion
GO

	SELECT * FROM DEAOFINET04.Operacion.AceSch.AceTraCertificadoDet WITH(NOLOCK)
			WHERE ClaUbicacion = 150 --@pnClaUbicacionOrigen
			AND IdCertificado = 33585 --@nIdCertificadoOrigen
			AND NOT EXISTS(
				SELECT 1
				FROM DEAOFINET04.Operacion.AceSch.AceTraCertificadoDet WITH(NOLOCK)
				WHERE ClaUbicacion = 324--@pnClaUbicacion
				AND IdCertificado = 264--@nIdCertificado
			)


/*
BEGIN TRAN
	UPDATE	a
	SET		BajaLogica = 0
	FROM	OpeSch.OpeRelFacturaSuministroDirecto a WITH(NOLOCK) 
	WHERE	NumFacturaOrigen IN ('H399234')

	EXEC OpeSch.OPE_CU550_Pag37_GeneraCertificadoFilial
		  @pnClaUbicacion		= 324
		, @psNumFacturaFilial	= ''
		, @pnIdFacturaFilial	= NULL
		, @pnDebug				= 1

	SELECT ''as'FUERA',* FROM DEAOFINET04.Operacion.ACESch.AceTraCertificadoDet  WHERE IdCertificado in ( 217)  AND ClaUbicacion = 324
	   	 
	SELECT * FROM OpeSch.OpeRelFacturaSuministroDirecto a WITH(NOLOCK) 
	WHERE	NumFacturaOrigen IN ('H399234')
ROLLBACK TRAN
*/

--The INSERT statement conflicted with the FOREIGN KEY constraint "FK_AceTraCertificadoDet_AceTraCertificado". The conflict occurred in database "Operacion", table "ACESch.AceTraCertificado". [AceGeneraCertificadoPuntoLogisticoSrv]

SELECT	* 
FROM	OpeSch.OpeRelFacturaSuministroDirecto a WITH(NOLOCK) 
WHERE	NumFacturaOrigen IN ('H399234')

SELECT	  NumFactura, NumCertificado
		, ExisteArchivo = CASE	WHEN Archivo IS NULL THEN 0 
											ELSE 1 END
		, IdCertificado = CONVERT(VARCHAR(20),IdCertificado)
		, FechaUltimaMod, ClaUsuarioMod
FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK)
WHERE	NumFactura IN ('H399234','QN3611')

SELECT * FROM DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK)
WHERE	NumFactura IN ('H399234') AND ClaUbicacion = 150

SELECT * FROM DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK)
WHERE	NumFactura IN ('QN3611') AND ClaUbicacion = 324


SELECT * FROM DEAOFINET04.Operacion.AceSch.VtaCTraFacturaVw
WHERE	IdFacturaAlfanumerico	= 'H399234'

SELECT * 
FROM DEAOFINET04.Operacion.AceSch.AceTraCertificado WITH(NOLOCK)
WHERE ClaUbicacion = 324
AND IdFactura = 1034003611

DEAOFINET04.Operacion.AceSch.AceTraCertificadoDet
			
				SELECT *
				FROM  DEAOFINET04.Operacion.AceSch.AceTraCertificado WITH(NOLOCK)
				WHERE ClaUbicacion = 324
				AND IdFactura = 1034003611
				AND ClaUbicacionOrigen = @nClaUbicacionOrigen


SELECT * FROM DEAOFINET04.Operacion.AceSch.AceTraCertificado WHERE  idcertificado in (217) and claubicacion in (264)
SELECT * FROM DEAOFINET04.Operacion.AceSch.AceTraCertificadoDet WHERE  idcertificado in (217) and claubicacion in (264)

