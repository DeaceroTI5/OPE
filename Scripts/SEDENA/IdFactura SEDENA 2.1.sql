USE Operacion
GO

CREATE TABLE #Remisiones (
	 Id			INT IDENTITY(1,1)
	,Remision	VARCHAR(30)
	,Liga		VARCHAR(300)
)

INSERT INTO #Remisiones (Remision) VALUES ('G398495')
INSERT INTO #Remisiones (Remision) VALUES ('G398498')
INSERT INTO #Remisiones (Remision) VALUES ('G398503')
INSERT INTO #Remisiones (Remision) VALUES ('G398578')
INSERT INTO #Remisiones (Remision) VALUES ('G398580')
INSERT INTO #Remisiones (Remision) VALUES ('G398451')
INSERT INTO #Remisiones (Remision) VALUES ('G398489')
INSERT INTO #Remisiones (Remision) VALUES ('G398493')
INSERT INTO #Remisiones (Remision) VALUES ('G398502')
INSERT INTO #Remisiones (Remision) VALUES ('G398586')





SELECT	a.IdFactura
		, a.ClaUbicacion
		, c.NombreUbicacion
		, a.IdViaje
		, a.IdFacturaAlfanumerico
		, c.ClaTipoUbicacion
		, d.NombreTipoUbicacion
		, Path	= CASE	WHEN c.ClaTipoUbicacion = 4 THEN 'nosotros procesaremos la generación del pdf (proc_SOS)'
						WHEN c.ClaTipoUbicacion  = 5 THEN 'http://appbodnet2/Reports/Pages/Report.aspx?ItemPath=%2fOPE%2fReportes%2fOPE_CU71_Pag1_Rpt_RemisionNacional&ViewMode=Detail'
						WHEN c.ClaTipoUbicacion  = 2 THEN 'http://operceldb/Reports/Pages/Report.aspx?ItemPath=%2fVTAPTA%2fReports%2fRemisionNacional&ViewMode=Detail'
					ELSE '' END
FROM	DEAOFINET05.Ventas.VtaSch.VtaCTraFactura a WITH(NOLOCK)
INNER JOIN #Remisiones b 
ON		a.IdFacturaAlfanumerico = b.Remision
INNER JOIN OpeSch.OpeTiCatUbicacionVw c
ON		a.ClaUbicacion = c.ClaUbicacion
INNER JOIN OpeSch.OpeTiCatTipoUbicacionVw d
ON		c.ClaTipoUbicacion = d.ClaTipoUbicacion
ORDER BY b.Id


DROP TABLE #Remisiones