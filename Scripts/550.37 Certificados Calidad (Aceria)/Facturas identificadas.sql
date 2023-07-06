------------------------------------------------------
SELECT	* 
FROM	OpeSch.OpeRelFacturaSuministroDirecto 
WHERE	NumFacturaOrigen IN ('H398820','DC39607','DC39606','H399234 ')
ORDER BY FechaUltimaMod DESC

SELECT * FROM DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK) WHERE ClaUbicacion = 150 AND NumFactura IN ('H399234') -- Origen
SELECT * FROM DEAOFINET04.Operacion.ACESch.AceTraCertificadoDet WITH(NOLOCK) WHERE ClaUbicacion = 150 AND IdCertificado IN (33316,33585)

SELECT * FROM DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK) WHERE ClaUbicacion = 324 AND NumFactura IN ('QN3611')	-- Filial
SELECT * FROM DEAOFINET04.Operacion.ACESch.AceTraCertificadoDet WITH(NOLOCK) WHERE ClaUbicacion = 150 AND IdCertificado IN (217,264)

SELECT	* 
FROM	OpeSch.OpeRelFacturaSuministroDirecto 
WHERE	NumFacturaOrigen IN ('H396219','H390451','H367708', 'H368412', 'H350306') 
	OR NumFacturaFilial IN ('H396219','H390451','H367708', 'H368412', 'H350306') 
ORDER BY FechaUltimaMod DESC


SELECT * FROM DEAOFINET04.Operacion.ACESch.VtaCTraFacturaRel1Vw WHERE IdFacturaAlfanumerico IN ('H396219','H390451', 'H368412', 'H350306') 
-------------------------------------------------------

	SELECT	a.ClaUbicacion, a.NombreUbicacion, a.ClaUbicacionVentas, NombreUbicacionVentas = b.NombreUbicacion
	INTO	#Ubicaciones
	FROM	OpeSch.OpeTiCatUbicacionVw a
	LEFT JOIN OpeSch.OpeTiCatUbicacionVw b
	ON		a.Claubicacion = b.ClaUbicacionVentas
	WHERE	a.ClaUbicacion IN (
		SELECT DISTINCT ClaUbicacionOrigen
		FROM	OpeSch.OpeRelFacturaSuministroDirecto WITH(NOLOCK)
	)

SELECT	a.ClaUbicacion, a.IdFactura, a.NumFactura
INTO	#Facturas
FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado a WITH(NOLOCK)
INNER JOIN #Ubicaciones b
ON		a.ClaUbicacion = b.ClaUbicacion
WHERE	NumFactura IS NOT  NULL
GROUP BY a.ClaUbicacion, a.IdFactura, a.NumFactura
HAVING	COUNT(1) > 1


SELECT	a.ClaUBICACION, a.ClaUbicacionOrigen, a.NumFactura, Esgenerado--, Archivo  = CASE WHEN Archivo IS NULL THEN 0 ELSE 1 END
FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado a WITH(NOLOCK) 
INNER JOIN #Facturas b 
ON		a.ClaUbicacion	= b.ClaUbicacion
AND		a.IdFactura		= b.IdFactura
WHERE	a.NumFactura LIKE 'DC%'


SELECT * FROM OpeSch.OpeTiCatUbicacionVw where ClaUbicacion = 158
--SELECT * FROM OpeSch.OpeTiCatUbicacionVw WHERE ClaUbicacion IN (13,158,150)

DROP TABLE #Facturas



SELECT * FROM DEAOFINET04.Operacion.ACESch.AceTraCertificado WHERE NumFactura IN ('H396219','H390451', 'H368412', 'H350306') 

-------------------------------------------------------------

