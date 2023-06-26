	DECLARE   @pnFabricacionEstimacion	INT
			, @pdFechaInicio			DATETIME
			, @pdIdViajeEstimacion		INT

	SELECT	  @pnFabricacionEstimacion	= 24126850
			, @pdIdViajeEstimacion		= 3632

	-------------------------------------------------------------------------------------------------------

	;WITH PedidosEstimaciones AS
	(
		SELECT	  a.IdFabriacionUnificado
				, 365						AS ClaUbicacionVenta
				, a.IdFabricacionOriginal	AS idFabricacionVenta
				, a.ClaUbicacion			AS ClaUbicacionEstimacion
				, a.IdFabricacionEstimacion AS idFabricacionEstimacion
		FROM	OpeSch.OpeRelFabricacionbUnificadasVw a WITH(NOLOCK)
		WHERE	a.IdFabricacionEstimacion = @pnFabricacionEstimacion
		AND		a.IdControlUnificacion IN (	SELECT	MAX(IdControlUnificacion)
											FROM	OpeSch.OpeRelFabricacionbUnificadasVw 
											GROUP BY ClaUbicacion, IdFabricacionOriginal, IdFabricacionEstimacion
											)
		UNION
		SELECT DISTINCT
				  NULL AS IdFabriacionUnificado
				, b.ClaUbicacionVenta
				, b.idFabricacionVenta
				, b.ClaUbicacionEstimacion
				, b.idFabricacionEstimacion
		FROM	OpeSch.OpeTraFabricacionEspejoEstimacion b WITH(NOLOCK)
		WHERE	b.IdFabricacionEstimacion = @pnFabricacionEstimacion
		AND		b.idFabricacionVenta NOT IN (	SELECT DISTINCT IdFabriacionUnificado
												FROM	OpeSch.OpeRelFabricacionbUnificadasVw
											)
	)
		SELECT--a.ClaUbicacionVenta, a.idFabricacionVenta, ir.IdViaje AS ViajeVenta, a.ClaUbicacionEstimacion, a.idFabricacionEstimacion, ie.IdViaje AS ViajeEstimacion,
				fr.IdFacturaAlfanumerico AS Remision
		FROM	PedidosEstimaciones a 
		--Flujo de Remision / Venta
		INNER JOIN	OpeSch.OpeTraMovEntSal fr WITH(NOLOCK)
		ON		a.ClaUbicacionVenta		= fr.ClaUbicacion
		AND		a.idFabricacionVenta	= fr.IdFabricacion
		INNER JOIN	OpeSch.OpeTraBoleta gr WITH(NOLOCK)
		ON		fr.ClaUbicacion			= gr.ClaUbicacion  
		AND		fr.IdBoleta				= gr.IdBoleta	 
	--	INNER JOIN	OpeSch.OpeTraPlanCarga hr WITH(NOLOCK)
	--	ON		gr.ClaUbicacion		= hr.ClaUbicacion
	--	AND		gr.IdBoleta			= hr.IdBoleta
	--	INNER JOIN	OpeSch.OpeTraViaje ir WITH(NOLOCK)
	--	ON		hr.ClaUbicacion		= ir.ClaUbicacion
	--	AND		hr.IdBoleta			= ir.IdBoleta
	--	Flujo de Estimaciones / Traspaso
		INNER JOIN	OpeSch.OpeTraMovEntSal fe WITH(NOLOCK)
		ON		a.ClaUbicacionEstimacion	= fe.ClaUbicacion
		AND		a.idFabricacionEstimacion	= fe.IdFabricacion
		INNER JOIN	OpeSch.OpeTraBoletaHis ge WITH(NOLOCK)
		ON		fe.ClaUbicacion		= ge.ClaUbicacion
		AND		fe.IdBoleta			= ge.IdBoleta
		INNER JOIN	OpeSch.OpeTraPlanCarga he WITH(NOLOCK)
		ON		ge.ClaUbicacion		= he.ClaUbicacion
		AND		ge.IdBoleta			= he.IdBoleta
		INNER JOIN	OpeSch.OpeTraViaje ie WITH(NOLOCK)
		ON		he.ClaUbicacion		= ie.ClaUbicacion 
		AND		he.IdBoleta			= ie.IdBoleta	
		--Tabla Relación de Estimacion - Remision
		INNER JOIN	OpeSch.OpeTraPlanCargaRemisionEstimacion o WITH(NOLOCK)  
		ON		fe.ClaUbicacion		= o.ClaUbicacionEstimacion
		AND		fr.ClaUbicacion		= o.ClaUbicacionVenta
		AND		ge.IdBoleta			= o.IdBoletaEstimacion
		AND		gr.IdBoleta			= o.IdBoletaVenta
		WHERE	a.idFabricacionEstimacion	= @pnFabricacionEstimacion
		AND		ie.IdViaje					= @pdIdViajeEstimacion
