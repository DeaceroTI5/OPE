-- DEAOFINET02 Consulta/consulta

IF @@SERVERNAME = 'DEAOFINET02'
BEGIN
	USE Ventas
	
	SELECT	a.FechaUltimaMod ,b.NomSituacion, c.NomEstatus ,a.* 
	FROM	RMASch.RmaCTraReclamacion a WITH(NOLOCK)
	INNER JOIN RMASch.RmaCatSituacion b WITH(NOLOCK)
	ON		a.ClaSituacion = b.ClaSituacion
	INNER JOIN RMASch.RmaCatEstatus c WITH(NOLOCK)
	ON		a.ClaEstatus = c.ClaEstatus
	WHERE	IdReclamacion = 240843


	SELECT	* 
	FROM	RMASch.RmaCTraReclamacionDet WITH(NOLOCK)
	WHERE	IdReclamacion = 240843


	SELECT * FROM RMASch.VtaCTraFactura WITH(NOLOCK) WHERE IdFactura = 1058000001
	SELECT * FROM RMASch.VtaCTraFacturaDet WITH(NOLOCK) WHERE IdFactura = 1058000001


	--OTRO
	select	*
	from	RmaSch.RmaTraReclamacion rma
	inner	join	RmaSch.RmaTraReclamacionDet det
		on	det.IdReclamacion = rma.IdReclamacion
	--inner	join	RmaSch.RmaTraReclamacionDet det2
	--	on	det2.IdFactura = det.IdFactura
	--	and	det2.IdReclamacion <> det.IdReclamacion
	--inner	join	RmaSch.RmaTraReclamacionEntrada rent
	--	on	rent.IdReclamacion = det2.IdReclamacion
	--	and	rent.IdFactura = det2.IdFactura
	where	rma.IdReclamacion = 240843
	--OTRO
	SELECT * FROM RmaSch.RmaTraReclamacionEntrada rent
	WHERE	rent.IdReclamacion = 240843
END


--COMPARAR REGISTRO DE LA 326
--REVISAR EL FLUJO DE LAS REPLICAS

	SELECT	a.* 
	FROM	RMASch.RmaCTraReclamacion a WITH(NOLOCK)
	INNER JOIN RMASch.RmaCTraReclamacionDet b WITH(NOLOCK)
	ON		a.IdReclamacion = b.IdReclamacion
	WHERE	a.ClaUbicacion = 267
	AND		a.ClaSituacion = 1
--	AND		a.ClaEstatus = 9
	ORDER BY a.FechaUltimaMod DESC

	SELECT	* 
	FROM	RMASch.RmaCTraReclamacionDet WITH(NOLOCK)
	WHERE	IdReclamacion = 240811

	-- Pendientes
	SELECT	a.FechaUltimaMod ,b.NomSituacion, c.NomEstatus , a.* 
	FROM	RMASch.RmaCTraReclamacion a WITH(NOLOCK)
	INNER JOIN RMASch.RmaCatSituacion b WITH(NOLOCK)
	ON		a.ClaSituacion = b.ClaSituacion
	INNER JOIN RMASch.RmaCatEstatus c WITH(NOLOCK)
	ON		a.ClaEstatus = c.ClaEstatus
	WHERE	a.ClaSituacion = 1
	AND		a.ClaEstatus = 1
	ORDER BY a.FechaUltimaMod DESC