	/* -- Consulta de Facturas de Proformas que no existen en tabla de Facturas */
	SELECT	a.IdFacturaNueva, Mes = MONTH(c.FechaUltimaMod), Anio = YEAR(c.FechaUltimaMod), c.FechaUltimaMod, c.FechaFactura
--	INTO	#Proformas
	FROM	Ventas.VtaSch.VtaTraProforma a WITH(NOLOCK) 
	LEFT JOIN Ventas.VtaSch.VtaCTraFactura b WITH(NOLOCK)
	ON		a.IdFacturaNueva = b.IdFactura
	INNER JOIN DEAOFINET05.Ventas.VtaSch.VtaCTraFactura c WITH(NOLOCK)
	ON		a.IdFacturaNueva = c.IdFactura 
	WHERE	a.IdFacturaNueva IS NOT NULL
	AND		b.IdFactura IS NULL
	AND		c.ClaUbicacion IN (277, 278, 322, 323, 324, 325, 326, 327, 328, 329, 360, 361, 362, 363, 364, 365, 366, 367, 368, 375, 424, 430, 431, 432, 433, 434, 435, 436, 437, 438, 470)
	ORDER BY c.FechaFactura ASC

	SELECT * FROM #Proformas 

	--SELECT a.IdFacturaNueva, a.FechaUltimaMod FROM Ventas.VtaSch.VtaTraProforma a WITH(NOLOCK) INNER JOIN #Proformas b ON a.IdFacturaNueva = b.IdFacturaNueva
	--SELECT a.IdFacturaNueva, a.FechaUltimaMod FROM DEAOFINET05.Ventas.VtaSch.VtaTraProforma a WITH(NOLOCK) INNER JOIN #Proformas b ON a.IdFacturaNueva = b.IdFacturaNueva
	--SELECT COUNT(1) FROM Ventas.VtaSch.VtaCTraFactura a WITH(NOLOCK) INNER JOIN #Proformas b ON a.IdFactura = b.IdFacturaNueva
	--

	--SELECT	Mes, Anio, Cantidad = COUNT(1)
	--FROM	#Proformas
	--GROUP BY Mes, Anio
	--ORDER BY Anio, Mes


	---------------------------------
	SELECT	Anio = YEAR(a.FechaUltimaMod), Mes = MONTH(a.FechaUltimaMod), Cantidad = COUNT(1)
	FROM	DEAOFINET05.Ventas.VtaSch.VtaCTraFactura a WITH(NOLOCK) 
	INNER JOIN #Proformas b ON a.IdFactura = b.IdFacturaNueva
	WHERE	a.ClaUbicacion IN (277, 278, 322, 323, 324, 325, 326, 327, 328, 329, 360, 361, 362, 363, 364, 365, 366, 367, 368, 375, 424, 430, 431, 432, 433, 434, 435, 436, 437, 438, 470)
	GROUP BY YEAR(a.FechaUltimaMod), MONTH(a.FechaUltimaMod)
	ORDER BY 1, 2

	SELECT	a.*
	FROM	DEAOFINET05.Ventas.VtaSch.VtaCTraFactura a WITH(NOLOCK) 
	INNER JOIN #Proformas b ON a.IdFactura = b.IdFacturaNueva
	WHERE	a.ClaUbicacion IN (277, 278, 322, 323, 324, 325, 326, 327, 328, 329, 360, 361, 362, 363, 364, 365, 366, 367, 368, 375, 424, 430, 431, 432, 433, 434, 435, 436, 437, 438, 470)
	ORDER BY FechaUltimaMod ASC
	---------------------------------

	DROP TABLE #Proformas

	--------------------------------------
	--------------------------------------

	/* -- Consulta de Facturas QH que no esten registradas en tabla de proformas */
	SELECT	  a.IdFactura
			, Mes = MONTH(a.FechaUltimaMod), Anio = YEAR(a.FechaUltimaMod), a.FechaUltimaMod, a.ClaUbicacion
	INTO	#Facturas
	FROM	DEAOFINET05.Ventas.VtaSch.VtaCTraFactura a WITH(NOLOCK)
	LEFT JOIN Ventas.VtaSch.VtaTraProforma b WITH(NOLOCK) 
	ON		a.IdFactura = b.IdFacturaNueva
	WHERE	a.IdFacturaAlfanumerico LIKE 'QH%'
	AND		(b.IdFacturaNueva IS NULL)
	AND		a.ClaUbicacion IN (277, 278, 322, 323, 324, 325, 326, 327, 328, 329, 360, 361, 362, 363, 364, 365, 366, 367, 368, 375, 424, 430, 431, 432, 433, 434, 435, 436, 437, 438, 470)


	SELECT * FROM #Facturas ORDER BY FechaUltimaMod ASC

	SELECT a.IdFacturaNueva, a.FechaUltimaMod 
	FROM DEAOFINET05.Ventas.VtaSch.VtaTraProforma a WITH(NOLOCK) 
	INNER JOIN #Facturas b ON a.IdFacturaNueva = b.IdFactura


	
	SELECT	Mes, Anio, Cantidad = COUNT(1)
	FROM	#Facturas
	GROUP BY Mes, Anio

	--SELECT a.IdFacturaNueva, a.FechaUltimaMod FROM Ventas.VtaSch.VtaTraProforma a WITH(NOLOCK) INNER JOIN #Facturas b ON a.IdFacturaNueva = b.IdFactura
	--SELECT a.IdFacturaNueva, a.FechaUltimaMod FROM DEAOFINET05.Ventas.VtaSch.VtaTraProforma a WITH(NOLOCK) INNER JOIN #Facturas b ON a.IdFacturaNueva = b.IdFactura
	--SELECT * FROM Ventas.VtaSch.VtaCTraFactura a WITH(NOLOCK) INNER JOIN #Facturas b ON a.IdFactura = b.IdFactura

	DROP TABLE #Facturas

	--SELECT * FROM #Proformas a INNER JOIN #Facturas b ON a.IdFacturaNueva = b.IdFactura

	--;WITH H AS (
	--	SELECT * FROM #Proformas 
	--	UNION
	--	SELECT * FROM #Facturas
	--)	SELECT Anio, Mes, Cantidad = COUNT(1)
	--	FROM	H
	--	GROUP BY Anio, Mes
	--	ORDER BY Anio ASC, Mes ASC