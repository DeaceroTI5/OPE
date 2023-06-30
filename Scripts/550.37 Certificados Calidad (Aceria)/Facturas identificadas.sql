SELECT	* 
FROM	OpeSch.OpeRelFacturaSuministroDirecto 
WHERE	NumFacturaOrigen IN ('H398820','DC39607','DC39606','H399234 ')
ORDER BY FechaUltimaMod DESC


--SELECT TOP 30 * FROM OpeSch.OpeRelFacturaSuministroDirecto WITH(NOLOCK) --WHERE ClaUbicacionOrigen IN (22,23)
--ORDER BY FechaUltimaMod  DESC

	SELECT	a.ClaUbicacion, a.NombreUbicacion, a.ClaUbicacionVentas, NombreUbicacionVentas = b.NombreUbicacion
	INTO	#Ubicaciones
	FROM	OpeSch.OpeTiCatUbicacionVw a
	LEFT JOIN OpeSch.OpeTiCatUbicacionVw b
	ON		a.Claubicacion = b.ClaUbicacionVentas
	WHERE	a.ClaUbicacion IN (
		SELECT DISTINCT ClaUbicacionOrigen
		FROM	OpeSch.OpeRelFacturaSuministroDirecto WITH(NOLOCK)
	)
	--AND		a.ClaUbicacion <> a.ClaUbicacionVentas


-------------------------------------------------------

SELECT * FROM DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK) WHERE ClaUbicacion = 150 AND NumFactura IN ('H399234') -- Origen
SELECT * FROM DEAOFINET04.Operacion.ACESch.AceTraCertificadoDet WITH(NOLOCK) WHERE ClaUbicacion = 150 AND IdCertificado IN (33316,33585)

SELECT * FROM DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK) WHERE ClaUbicacion = 324 AND NumFactura IN ('QN3611')	-- Filial
SELECT * FROM DEAOFINET04.Operacion.ACESch.AceTraCertificadoDet WITH(NOLOCK) WHERE ClaUbicacion = 150 AND IdCertificado IN (217,264)

-------------------------------------------------------

SELECT	a.ClaUbicacion, a.IdFactura, a.NumFactura
INTO	#Facturas
FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado a WITH(NOLOCK)
INNER JOIN #Ubicaciones b
ON		a.ClaUbicacion = b.ClaUbicacion
WHERE	NumFactura IS NOT  NULL
GROUP BY a.ClaUbicacion, a.IdFactura, a.NumFactura
HAVING	COUNT(1) > 1


SELECT	a.ClaUBICACION, a.ClaUbicacionOrigen, a.NumFactura, Esgenerado
FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado a WITH(NOLOCK) 
INNER JOIN #Facturas b 
ON		a.ClaUbicacion	= b.ClaUbicacion
AND		a.IdFactura		= b.IdFactura

--SELECT * FROM OpeSch.OpeTiCatUbicacionVw WHERE ClaUbicacion IN (13,158,150)

DROP TABLE #Facturas


-------------------------------------------------------------
SELECT	* 
FROM	OpeSch.OpeRelFacturaSuministroDirecto 
WHERE	NumFacturaOrigen IN ('DC39572','DR73354')
ORDER BY FechaUltimaMod DESC