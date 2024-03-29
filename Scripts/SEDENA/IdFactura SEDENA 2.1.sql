USE Operacion
GO

CREATE TABLE #Remisiones (
	 Id			INT IDENTITY(1,1)
	,Remision	VARCHAR(30)
	,Liga		VARCHAR(300)
)


INSERT INTO #Remisiones (Remision) VALUES ('QN8359')




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
		, e.ClaClienteUnico, e.NomClienteCuenta
		, EsSedena = CASE WHEN ClaClienteUnico = 14064 THEN 'Si' ELSE 'No' END
FROM	DEAOFINET05.Ventas.VtaSch.VtaCTraFactura a WITH(NOLOCK)
INNER JOIN #Remisiones b 
ON		a.IdFacturaAlfanumerico = b.Remision
INNER JOIN OpeSch.OpeTiCatUbicacionVw c
ON		a.ClaUbicacion = c.ClaUbicacion
INNER JOIN OpeSch.OpeTiCatTipoUbicacionVw d
ON		c.ClaTipoUbicacion = d.ClaTipoUbicacion
LEFT JOIN OpeSch.OpeVtaCatClienteCuentaVw e
ON		a.ClaCliente = e.ClaClienteCuenta
ORDER BY b.Id


DROP TABLE #Remisiones