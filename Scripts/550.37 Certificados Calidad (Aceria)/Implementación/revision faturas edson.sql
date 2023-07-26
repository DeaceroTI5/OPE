DROP TABLE #Facturas


SELECT	a.ClaUbicacion, a.IdFactura, a.NumFactura
INTO	#Facturas
FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado a WITH(NOLOCK)
WHERE	NumFactura IS NOT  NULL
AND		(NumFactura LIKE 'QM%' OR NumFactura LIKE 'QN%' OR NumFactura LIKE 'QP%')
GROUP BY a.ClaUbicacion, a.IdFactura, a.NumFactura
HAVING	COUNT(1) > 1


SELECT	a.ClaUBICACION, a.ClaUbicacionOrigen, a.NumFactura, Esgenerado--, Archivo  = CASE WHEN Archivo IS NULL THEN 0 ELSE 1 END
FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado a WITH(NOLOCK) 
INNER JOIN #Facturas b 
ON		a.ClaUbicacion	= b.ClaUbicacion
AND		a.IdFactura		= b.IdFactura
WHERE	a.NumFactura LIKE 'DC%'


SELECT * FROM DEAOFINET04.Operacion.ACESch.AceTraCertificado WHERE NumFactura IN ('QN3611','QP1')

SELECT	* 
FROM	OpeSch.OpeRelFacturaSuministroDirecto 
WHERE	NumFacturaOrigen IN ('QN3611','QP1')
ORDER BY FechaUltimaMod DESC


select * from opesch.OpeTiCatUbicacionVw where ClaUbicacion = 362