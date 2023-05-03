IF @@SERVERNAME = 'DEAWWRNET01\OPERACION'
BEGIN
	USE Operacion

	DECLARE	  @pnClaUbicacion		INT = 267
			, @pnIdPlanRecoleccion	INT = 842


	SELECT	t1.IdPlanRecoleccion, t1.ClaEstatus, t2.NombreEstatus, c.NomTipoPlanRecoleccion,
			t1.ClaTransporte, t1.ClaTransportista, t1.Chofer, t1.ClaCiudadOrigen, t1.ClaCiudadDestino
	FROM	OpeSch.OpeTraPlanRecoleccion t1 WITH(NOLOCK)
	INNER JOIN InvSch.TiCatEstatusVw t2 WITH(NOLOCK)
	ON		t2.ClaEstatus				= t1.ClaEstatus 
	AND		t2.ClaClasificacionEstatus	= 1270014 --Plan de Recolección
	INNER JOIN OPESch.OpeCatTipoPlanRecoleccionVW c
	ON		t1.ClaTipoPlanRecoleccion = c.ClaTipoPlanRecoleccion
	WHERE	IdPlanRecoleccion			= @pnIdPlanRecoleccion--@pnIdPlanRecoleccion



	SELECT	* 
	FROM	OpeSch.OpeTraPlanRecoleccionDet WITH(NOLOCK) 
	WHERE	IdPlanRecoleccion = @pnIdPlanRecoleccion


	SELECT	b.NombreEstatus, a.* 
	FROM	OPESch.OpeTraDevolucionVw a
	INNER JOIN OpeSch.OpeTiCatestatusVw b
	ON		b.ClaClasificacionEstatus = 1270006	-- Estatus de Reclasificaciones Devoluciones
	AND		a.ClaEstatus = b.ClaEstatus
	WHERE	IdPlanRecoleccion = @pnIdPlanRecoleccion
	

	SELECT	* 
	FROM	OPESch.OPETraDevolucionFactura WITH(NOLOCK) 
	WHERE	ClaUbicacion = 267--@pnClaUbicacion 
	AND		IdBoleta = 231110003


	SELECT * FROM OpeSch.OpeTraRecepDevolucionProdRecibido WITH(NOLOCK) WHERE IdPlanRecoleccion = 842
	
	--SELECT	* 
	--FROM	OPESch.OpeTraDevolucionFacturaDet WITH(NOLOCK) 
	--WHERE	ClaUbicacion	= 267--@pnClaUbicacion 
	--AND		IdBoleta		= 231110003

	----SELECT TOP 10 * FROM OPESch.OpeTraReclamacionEnc WITH(NOLOCK) WHERE IdReclamacion = 240843
	----SELECT TOP 10 * FROM OPESch.OpeTraReclamacionDet WITH(NOLOCK) WHERE IdReclamacion = 240843


	SELECT b.NomEstatusBoleta ,a.* 
	FROM	OpeSch.OpeTraBoletaHisVw a WITH(NOLOCK) 
	INNER JOIN OPESch.OPECatEstatusBoletaVw b 
	ON		a.ClaEstatusPlaca = b.ClaEstatusBoleta
	WHERE	IdPlanRecoleccion = 842--@pnIdPlanRecoleccion

	SELECT * FROM OPESch.OpeTraDevolucionVw WHERE IdPlanRecoleccion = 230830016
	 



	--'%OPE%CU441_Pag2%'
	--'OPESch.OPE_CU441_Pag2_Grid_DetPlan_Sel'
END

return

	SELECT * FROM OpeSch.OpeTraViajevw WHERE IdBoleta = 231110003
	SELECT * FROM OPESch.OpeTraPlanCargaVw WHERE IdBoleta = 231110003


	SELECT * FROM OPESch.OpeTraMovEntSalVw WHERE IdBoleta = 231110003

	SELECT * FROM OPESch.OPETraMovEntSalDetVw WHERE IdMovEntSal = 202

	--OPESch.OpeTraMovEntSal
	--OPESch.OPETraMovEntSalDet

	SELECT * FROM OPESch.OpeCatMotivoEntrada WHERE ClaMotivoEntrada = 401


--- DEAOFINET04
	SELECT	* 
	FROM	OPE_6OFGRALES_LNKSVR.Operacion.OpeSch.OpeTraPlanRecoleccionOfi WITH(NOLOCK)	-- DEAOFINET04
	WHERE	IdPlanRecoleccion = 842--@pnIdPlanRecoleccion

	SELECT	* 
	FROM	OPE_6OFGRALES_LNKSVR.Operacion.OpeSch.OpeTraPlanRecoleccionOfiDet WITH(NOLOCK)	-- DEAOFINET04
	WHERE	ClaUbicacion		= 267--@pnClaUbicacion 
	AND		IdPlanRecoleccion	= 842--@pnIdPlanRecoleccion

--SELECT * FROM OPE_6OFGRALES_LNKSVR.Operacion.PloSch.PloTraViajevw WHERE IdBoleta = 231110003
--SELECT * FROM OPE_6OFGRALES_LNKSVR.Operacion.PloSch.PloTraPlanCargaVw WHERE IdBoleta = 231110003

--SELECT * FROM OPE_6OFGRALES_LNKSVR.Operacion.PloSch.PloTraBoletaVw WITH(NOLOCK) WHERE IdBoleta = 231110003

--SELECT * FROM OPE_6OFGRALES_LNKSVR.Operacion.PloSch.PloTraMovEntSalVw WHERE IdBoleta = 231110003
--SELECT * FROM OPE_6OFGRALES_LNKSVR.Operacion.PloSch.PloTraMovEntSalDetVw WHERE IdMovEntSal = 202
