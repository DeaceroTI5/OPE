/*
BEGIN TRAN
	DECLARE @sIdCertificado	VARCHAR(100) = NULL
			,@nClaEstatus		INT = NULL
			,@sMensajeError	VARCHAR(500) = ''

EXEC ACESch.AceGeneraCertificadoPuntoLogisticoSrv
	  @pnClaUbicacion					= 324
	, @pnIdFactura						= 1034003611
	, @pnClaUbicacionOrigen				= 150
	, @pnIdFacturaOrigen				= 50399234
	, @pnEsRegeneraCertificado			= 1
	, @psNombrePcMod					= 'Prueba'
	, @pnClaUsuarioMod					= 1
	, @psIdCertificado					= @sIdCertificado	OUT
	, @pnClaEstatus						= @nClaEstatus		OUTPUT
	, @psMensajeError					= @sMensajeError	OUTPUT
	, @pnClaAceria						= NULL
	, @pnDebug							= 1

	SELECT @sIdCertificado AS '@sIdCertificado'

ROLLBACK TRAN
*/

---- revision Facturas Origen existentes (no hy casos)
--SELECT	ClaUbicacion, ClaUbicacionOrigen,IdFacturaOrigen,NumFacturaOrigen, Cont = COUNT(1) 
--INTO	#Facturas
--FROM	OpeSch.OpeRelFacturaSuministroDirecto a
--WHERE	BajaLogica = 0
--GROUP BY ClaUbicacion, ClaUbicacionOrigen, IdFacturaOrigen, NumFacturaOrigen
--HAVING COUNT(1)>1


--SELECT	b.ClaUbicacionOrigen, a.* 
--FROM	OpeSch.OpeRelFacturaSuministroDirecto a WITH(NOLOCK)
--INNER JOIN #Facturas b
--ON		a.ClaUbicacion		= b.ClaUbicacion
--AND		a.IdFacturaOrigen	= b.IdFacturaOrigen
--WHERE	a.MensajeError		IS NULL


-- revision registros unicos de factura origen (acerias)
SELECT	DISTINCT  ClaUbicacionOrigen, IdFacturaOrigen, NumFacturaOrigen
INTO	#Universo
FROM	OpeSch.OpeRelFacturaSuministroDirecto a WITH(NOLOCK)
WHERE	BajaLogica = 0


SELECT	a.ClaUbicacionOrigen, a.IdFacturaOrigen, a.NumFacturaOrigen --,Conteo = COUNT(1)
INTO	#Facturas2
FROM	#Universo a
LEFT JOIN DEAOFINET04.Operacion.ACESch.AceTraCertificado b WITH(NOLOCK)
ON		a.ClaUbicacionOrigen	= b.ClaUbicacion
AND		a.IdFacturaOrigen		= b.IdFactura
GROUP BY a.ClaUbicacionOrigen, a.IdFacturaOrigen, a.NumFacturaOrigen
HAVING COUNT(1) > 1


SELECT	a.ClaUbicacion, ClaAceria = a.ClaUbicacionOrigen, a.IdFactura, a.NumFactura, a.EsGenerado
INTO	#Pruebas
FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado a WITH(NOLOCK)
INNER JOIN #Facturas2 b
ON		a.ClaUbicacion	= b.ClaUbicacionOrigen
AND		a.IdFactura		= b.IdFacturaOrigen


SELECT	b.ClaAceria, b.EsGenerado,a.* 
FROM	OpeSch.OpeRelFacturaSuministroDirecto a WITH(NOLOCK)
INNER JOIN #Pruebas b
ON		a.ClaUbicacionOrigen	= b.ClaUbicacion
AND		a.IdFacturaOrigen		= b.IdFactura
WHERE	ISNULL(MensajeError,'') = ''