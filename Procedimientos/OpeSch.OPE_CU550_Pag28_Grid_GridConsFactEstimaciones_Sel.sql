USE Operacion
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag28_Grid_GridConsFactEstimaciones_Sel 
    @pnClaUbicacion         INT, 
    @pnCmbCliente           INT, 
    @pnCmbProyecto          INT, 
    @pnCmbTipoProyecto      INT,
    @pnChkRemNoEntregadas   INT
	,@psClaUbicacionOrig	VARCHAR(600)= ''
	,@pdFechaInicio			DATETIME = NULL
	,@pdFechaFin			DATETIME = NULL
	,@pnDebug				TINYINT = 0
AS
BEGIN
	--exec OPESch.OPE_CU550_Pag28_Grid_GridConsFactEstimaciones_Sel @pnClaUbicacion=365,@pnCmbCliente=NULL,@pnCmbProyecto=NULL,@pnCmbTipoProyecto=NULL,@pnChkRemNoEntregadas=1,@pnDebug=1

	IF (@pdFechaInicio IS NOT NULL AND @pdFechaFin IS NOT NULL AND (@pdFechaFin < @pdFechaInicio)) 
	BEGIN
		RAISERROR('La Fecha Inicial NO debe ser Mayor a la Fecha Final. Favor de Verificar.',16,1)
		RETURN
	END	
	
	IF @pdFechaFin IS NOT NULL
		SELECT @pdFechaFin = DATEADD(DAY,1,@pdFechaFin)

    ------Inicio: Proceso PreEjecucion de Consulta------
    DECLARE	@CmbCliente         INT, 
			@CmbProyecto        INT,
            @CmbTipoProyecto    INT
	
	SELECT	@CmbCliente         = (CASE WHEN (@pnCmbCliente = -1 OR @pnCmbCliente IS NULL) THEN 1 ELSE 0 END),
			@CmbProyecto        = (CASE WHEN (@pnCmbProyecto = -1 OR @pnCmbProyecto IS NULL) THEN 1 ELSE 0 END),
            @CmbTipoProyecto    = (CASE WHEN (@pnCmbTipoProyecto = -1 OR @pnCmbTipoProyecto IS NULL) THEN 1 ELSE 0 END)


	DECLARE @tPedidosEstimaciones TABLE(
		  IdFabriacionUnificado		INT
		, ClaUbicacionVenta			INT
		, idFabricacionVenta		INT
		, ClaUbicacionEstimacion	INT
		, idFabricacionEstimacion	INT
	)

	DECLARE @tPedidoAgrupadoEncabezado TABLE(
		  ClaCliente					INT
		, Cliente						VARCHAR(100)
		, ClaProyecto					INT
		, Proyecto						VARCHAR(100)
		, Planta_VO						INT
		, Pedido_Unificado				INT
		, Pedido_Venta_Original			INT
		, Cantidad_Pedida_Venta_Enc		NUMERIC(22,4)
		, Cantidad_Surtida_Venta_Enc	NUMERIC(22,4)
		, Planta_E						INT
		, Pedido_Espejo					INT
		, Cantidad_Pedida_Espejo_Enc	NUMERIC(22,4)
		, Cantidad_Surtida_Espejo_Enc	NUMERIC(22,4)
	)
    
	------------------------------------------------------------------------------
	DECLARE @tUbicacionOrigenCmb TABLE(
		  Id				INT IDENTITY(1,1)
		, ClaUbicacionOrig	INT
	)
	
	SET @psClaUbicacionOrig = ISNULL(@psClaUbicacionOrig,'')
	IF @psClaUbicacionOrig <> ''
	BEGIN
		INSERT INTO @tUbicacionOrigenCmb
		SELECT DISTINCT LTRIM(RTRIM(string))
		FROM	OpeSch.OPEUtiSplitStringFn(@psClaUbicacionOrig, ',')
	END
	------------------------------------------------------------------------------
	
	INSERT INTO @tPedidosEstimaciones(IdFabriacionUnificado	, ClaUbicacionVenta, idFabricacionVenta, ClaUbicacionEstimacion, idFabricacionEstimacion)
	SELECT	  a.IdFabriacionUnificado
			, 365						AS ClaUbicacionVenta
			, a.IdFabricacionOriginal	AS idFabricacionVenta
			, a.ClaUbicacion			AS ClaUbicacionEstimacion
			, a.IdFabricacionEstimacion AS idFabricacionEstimacion
	FROM	OpeSch.OpeRelFabricacionbUnificadasVw a WITH(NOLOCK)
	WHERE	a.IdControlUnificacion IN (	SELECT	MAX(IdControlUnificacion)
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
	WHERE	b.idFabricacionVenta NOT IN (	SELECT DISTINCT IdFabriacionUnificado
		                                        FROM	OpeSch.OpeRelFabricacionbUnificadasVw)



	INSERT INTO @tPedidoAgrupadoEncabezado(
		  ClaCliente					
		, Cliente						
		, ClaProyecto					
		, Proyecto						
		, Planta_VO						
		, Pedido_Unificado				
		, Pedido_Venta_Original			
		, Cantidad_Pedida_Venta_Enc		
		, Cantidad_Surtida_Venta_Enc	
		, Planta_E						
		, Pedido_Espejo					
		, Cantidad_Pedida_Espejo_Enc	
		, Cantidad_Surtida_Espejo_Enc
	)

	SELECT	  er.ClaCliente				AS ClaCliente
			, ltrim(rtrim(convert(varchar(150), er.ClaCliente))) + ' - ' + er.NombreCliente AS Cliente
			, dr.ClaProyecto			AS ClaProyecto
			, ltrim(rtrim(convert(varchar(150), dr.ClaProyecto))) + ' - ' + dr.NomProyecto AS Proyecto
			, a.ClaUbicacionVenta		AS Planta_VO
			, ur.IdFabricacion			AS Pedido_Unificado	
			, br.IdFabricacion			AS Pedido_Venta_Original
			, SUM(bdr.CantPedida)		AS Cantidad_Pedida_Venta_Enc
			, SUM(bdr.CantSurtida)		AS Cantidad_Surtida_Venta_Enc
			, a.ClaUbicacionEstimacion	AS Planta_E
			, be.IdFabricacion			AS Pedido_Espejo
			, SUM(bde.CantPedida)		AS Cantidad_Pedida_Espejo_Enc
			, SUM(bde.CantSurtida)		AS Cantidad_Surtida_Espejo_Enc
	FROM	@tPedidosEstimaciones a 
    --Flujo de Remision / Venta
    INNER JOIN	OpeSch.OpeTraFabricacionVw br WITH(NOLOCK)
    ON			br.IdFabricacion = a.idFabricacionVenta
    INNER JOIN	OpeSch.OpeVtaRelFabricacionProyectoVw cr WITH(NOLOCK)
    ON			cr.IdFabricacion = br.IdFabricacion
    INNER JOIN	OpeSch.OpeVtaCatProyectoVw dr WITH(NOLOCK)
    ON			dr.ClaProyecto = cr.ClaProyecto
    INNER JOIN	OpeSch.OpeVtaCatClienteVw er WITH(NOLOCK)
    ON			er.ClaCliente = dr.ClaClienteCuenta
    INNER JOIN	OpeSch.OpeTraFabricacionDetVw bdr WITH(NOLOCK)
    ON			bdr.IdFabricacion = br.IdFabricacion 
    INNER JOIN  Opesch.OpeArtCatArticuloVw art WITH(NOLOCK)
    ON			art.ClaArticulo = bdr.ClaArticulo
    --Flujo de Estimaciones / Traspaso
    INNER JOIN	OpeSch.OpeTraFabricacionVw be WITH(NOLOCK)
    ON			be.IdFabricacion = a.idFabricacionEstimacion
    INNER JOIN	OpeSch.OpeTraFabricacionDetVw bde WITH(NOLOCK)
    ON			bde.IdFabricacion = be.IdFabricacion 
	AND			bde.ClaArticulo = bdr.ClaArticulo
    --Tabla Tipo de Proyecto
    INNER JOIN	OpeSch.OpeRelProyectoEstimacionVw vw1 WITH(NOLOCK)
	ON			vw1.ClaCliente = er.ClaCliente 
	AND			vw1.ClaProyecto = dr.ClaProyecto
    --Flujo de Unificacion
	LEFT JOIN	OpeSch.OpeTraFabricacionVw ur WITH(NOLOCK)
    ON			ur.IdFabricacion = a.IdFabriacionUnificado
    LEFT JOIN	OpeSch.OpeTraFabricacionDetVw udr WITH(NOLOCK)
	ON			udr.IdFabricacion = ur.IdFabricacion 
	AND			udr.ClaArticulo = bdr.ClaArticulo
	LEFT JOIN	@tUbicacionOrigenCmb ub
	ON			a.ClaUbicacionEstimacion = ub.ClaUbicacionOrig
	WHERE		( dr.ClaClienteCuenta = @pnCmbCliente OR @CmbCliente = 1 )  
	AND			( dr.ClaProyecto = @pnCmbProyecto OR @CmbProyecto = 1 ) 
	AND			( vw1.EsInstalacion = @pnCmbTipoProyecto OR @CmbTipoProyecto = 1 )
	AND			(@psClaUbicacionOrig = '' OR (a.ClaUbicacionEstimacion = ub.ClaUbicacionOrig))
	GROUP BY
	        er.ClaCliente,
	        ltrim(rtrim(convert(varchar(150), er.ClaCliente))) + ' - ' + er.NombreCliente,
	        dr.ClaProyecto,		
	        ltrim(rtrim(convert(varchar(150), dr.ClaProyecto))) + ' - ' + dr.NomProyecto,
	        a.ClaUbicacionVenta,
	        a.ClaUbicacionEstimacion,
	        ur.IdFabricacion,
	        br.IdFabricacion,
	        be.IdFabricacion
	

	;WITH PedidoAgrupadoDetalle AS ( 
		SELECT	  a.ClaCliente
				, a.Cliente
				, a.ClaProyecto
				, a.Proyecto
				, a.Planta_VO
				, a.Pedido_Unificado
				, udr.IdFabricacionDet		AS No_Renglon_PU
				, a.Pedido_Venta_Original
				, a.Cantidad_Pedida_Venta_Enc
				, a.Cantidad_Surtida_Venta_Enc
				, bdr.IdFabricacionDet		AS No_Renglon_PVO
				, SUM(bdr.CantPedida)		AS Cantidad_Pedida_Venta_Det
				, SUM(bdr.CantSurtida)		AS Cantidad_Surtida_Venta_Det
				, a.Planta_E
				, a.Pedido_Espejo
				, a.Cantidad_Pedida_Espejo_Enc
				, a.Cantidad_Surtida_Espejo_Enc
				, bdr.IdFabricacionDet		AS No_Renglon_PE
				, SUM(bde.CantPedida)		AS Cantidad_Pedida_Espejo_Det
				, SUM(bde.CantSurtida)		AS Cantidad_Surtida_Espejo_Det
				, art.ClaArticulo			AS Articulo
				, bdr.PrecioLista			AS Precio_Lista
				, art.PesoTeoricoKgs		AS Peso_Teorico_Kgs
		FROM	@tPedidoAgrupadoEncabezado a 
        --Flujo de Remision / Venta
        INNER JOIN	OpeSch.OpeTraFabricacionDetVw bdr WITH(NOLOCK)
        ON		bdr.IdFabricacion = a.Pedido_Venta_Original
        INNER JOIN  Opesch.OpeArtCatArticuloVw art WITH(NOLOCK)
        ON		art.ClaArticulo = bdr.ClaArticulo
        --Flujo de Estimaciones / Traspaso
        INNER JOIN	OpeSch.OpeTraFabricacionDetVw bde WITH(NOLOCK)
        ON		bde.IdFabricacion = a.Pedido_Espejo 
		AND		bde.ClaArticulo = bdr.ClaArticulo
        --Flujo de Unificacion
        LEFT JOIN	OpeSch.OpeTraFabricacionDetVw udr WITH(NOLOCK)
        ON		udr.IdFabricacion = a.Pedido_Unificado 
		AND		udr.ClaArticulo = bdr.ClaArticulo
		GROUP BY
		        a.ClaCliente,
		        a.Cliente,
		        a.ClaProyecto,
		        a.Proyecto,
		        a.Planta_VO,
		        a.Pedido_Unificado,
		        udr.IdFabricacionDet,	
		        a.Pedido_Venta_Original,
		        a.Cantidad_Pedida_Venta_Enc,
		        a.Cantidad_Surtida_Venta_Enc,
		        bdr.IdFabricacionDet,
		        a.Planta_E,
		        a.Pedido_Espejo,
		        a.Cantidad_Pedida_Espejo_Enc,
		        a.Cantidad_Surtida_Espejo_Enc,
		        bdr.IdFabricacionDet,
		        art.ClaArticulo,
		        bdr.PrecioLista,
		        art.PesoTeoricoKgs
	) 
		SELECT	a.ClaCliente,
				a.Cliente,
				a.ClaProyecto,
				a.Proyecto,
				a.Planta_E,
				a.Pedido_Unificado,
				a.No_Renglon_PU,
				a.Pedido_Venta_Original,
				a.No_Renglon_PVO,            
				a.Cantidad_Pedida_Venta_Enc,
				a.Cantidad_Surtida_Venta_Enc,
				a.Cantidad_Pedida_Venta_Det,
				a.Cantidad_Surtida_Venta_Det,
				a.Pedido_Espejo,
				a.No_Renglon_PE,            
				a.Articulo,
				a.Precio_Lista,
				a.Peso_Teorico_Kgs,
				a.Cantidad_Pedida_Espejo_Enc,
				a.Cantidad_Surtida_Espejo_Enc,
				a.Cantidad_Pedida_Espejo_Det,
				a.Cantidad_Surtida_Espejo_Det,            
				gr.IdBoleta AS Boleta_VO,
				hr.IdPlanCarga AS Plan_Carga_VO,
				ir.IdViaje AS Viaje_VO,
				fr.IdFacturaAlfanumerico AS Remision,
				fr.FechaEntSal AS FechaRemision,
				ge.IdBoleta AS Boleta_PE,
				he.IdPlanCarga AS Plan_Carga_PE,
				ie.IdViaje AS Viaje_PE,
				ie.FechaViaje AS Fecha_Viaje_PE,
				DATEDIFF(DAY, ie.FechaViaje, GETDATE()) AS Dias_Viaje_PE,
				fe.IdEntSal AS Mov_Embarque,
				--Detalle Embarque
				fd.CantEmbarcada AS Cantidad_Embarcada_VO,		
				fd.PesoEmbarcado AS Kilos_Embarcada_VO,
				--Detalle Recepcion Mercancia
				z.CantRecibida AS Cantidad_Recibida_PE,
				z.PesoRecibido AS Kilos_Recibidos_PE,
				--Detalle POD Estimaciones
				CASE u.EsEntregado WHEN 0 THEN 'No Entregado' WHEN 1 THEN 'Entregado' ELSE 'No Entregado' END AS Estatus_Evidencia,
				CASE WHEN ev.IdViajeOrigen IS NOT NULL THEN 'Ver Evidencia' ELSE '' END AS Evidencia_POD,
				ISNULL(u.EsRecibido, 0) AS Estatus_Autorizacion,
				CASE u.EsRecibido WHEN 0 THEN NULL WHEN 1 THEN cu.NombreUsuario + ' ' + cu.ApellidoPaterno ELSE NULL END AS Autorizado_Por,
				CASE u.EsRecibido WHEN 0 THEN NULL WHEN 1 THEN u.ComentarioRecepcion  ELSE NULL END AS Comentarios_Autorizacion,
				--Detalle Disponibilidad Factura
				CASE WHEN ISNULL(u.EsRecibido,0) = 1 THEN fd.CantEmbarcada ELSE 0.00 END AS Cant_Disponible_Facturar,
				CASE WHEN ISNULL(u.EsRecibido,0) = 1 THEN fd.PesoEmbarcado ELSE 0.00 END AS Kilos_Disponible_Facturar,
				CASE WHEN ISNULL(u.EsRecibido,0) = 0 THEN fd.CantEmbarcada ELSE 0.00 END AS Cant_Pendiente_Aurotizacion,	
				CASE WHEN ISNULL(u.EsRecibido,0) = 0 THEN fd.PesoEmbarcado ELSE 0.00 END AS Kilos_Pendiente_Aurotizacion
		INTO	#TempVistaEstimacionesDetalleRemision
		FROM	PedidoAgrupadoDetalle a 
		--Flujo de Remision / Venta
		INNER JOIN	OpeSch.OpeTraMovEntSal fr WITH(NOLOCK)
		ON		fr.ClaUbicacion = a.Planta_VO 
		AND		fr.IdFabricacion = a.Pedido_Venta_Original
		INNER JOIN	OpeSch.OpeTraBoleta gr WITH(NOLOCK)
		ON		gr.ClaUbicacion = fr.ClaUbicacion 
		AND		gr.IdBoleta = fr.IdBoleta
		INNER JOIN	OpeSch.OpeTraPlanCarga hr WITH(NOLOCK)
		ON		hr.ClaUbicacion = gr.ClaUbicacion 
		AND		hr.IdBoleta = gr.IdBoleta
		INNER JOIN	OpeSch.OpeTraViaje ir WITH(NOLOCK)
		ON		ir.ClaUbicacion = hr.ClaUbicacion 
		AND		ir.IdBoleta = hr.IdBoleta
		--Flujo de Estimaciones / Traspaso
		INNER JOIN	OpeSch.OpeTraMovEntSal fe WITH(NOLOCK)
		ON		fe.ClaUbicacion = a.Planta_E 
		AND		fe.IdFabricacion = a.Pedido_Espejo
		INNER JOIN	OpeSch.OpeTraBoletaHis ge WITH(NOLOCK)
		ON		ge.ClaUbicacion = fe.ClaUbicacion 
		AND		ge.IdBoleta = fe.IdBoleta
		INNER JOIN	OpeSch.OpeTraPlanCarga he WITH(NOLOCK)
		ON		he.ClaUbicacion = ge.ClaUbicacion 
		AND		he.IdBoleta = ge.IdBoleta
		INNER JOIN	OpeSch.OpeTraViaje ie WITH(NOLOCK)
		ON		ie.ClaUbicacion = he.ClaUbicacion 
		AND		ie.IdBoleta = he.IdBoleta
		--Tabla Relación de Estimacion - Remision
		INNER JOIN	OpeSch.OpeTraPlanCargaRemisionEstimacion o WITH(NOLOCK)  
		ON		o.ClaUbicacionEstimacion = fe.ClaUbicacion 
		AND		o.ClaUbicacionVenta = fr.ClaUbicacion 
		AND		o.IdBoletaEstimacion = ge.IdBoleta 
		AND		o.IdBoletaVenta = gr.IdBoleta
		--Base Remisionado 
		INNER JOIN	OpeSch.OpeTraMovEntSalDet fd WITH(NOLOCK)
		ON		fd.ClaUbicacion = fr.ClaUbicacion 
		AND		fd.IdMovEntSal = fr.IdMovEntSal 
		AND		fd.IdFabricacion = a.Pedido_Venta_Original 
		AND		fd.IdFabricacionDet = a.No_Renglon_PVO
		--Base POD
		LEFT JOIN	OpeSch.OpeTraInfoViajeEstimacion u WITH(NOLOCK)
		ON		u.ClaUbicacionOrigen = ie.ClaUbicacion 
		AND		u.IdViajeOrigen = ie.IdViaje 
		AND		u.Remision = fr.IdFacturaAlfanumerico
		LEFT JOIN	OpeSch.OpeTraInfoViajeEstimacionDet v WITH(NOLOCK)
		ON		v.ClaUbicacionOrigen = u.ClaUbicacionOrigen 
		AND		v.IdViajeOrigen = u.IdViajeOrigen 
		AND		v.IdFabricacion = a.Pedido_Espejo 
		AND		v.IdFabricacionDet = a.No_Renglon_PE
		LEFT JOIN   OpeSch.OpeTraEvidenciaViajeEstimacion ev WITH(NOLOCK)
		ON		ev.ClaUbicacion = u.ClaUbicacion 
		AND		ev.ClaUbicacionOrigen = u.ClaUbicacionOrigen 
		AND		ev.IdViajeOrigen = u.IdViajeOrigen 
		AND		ev.Remision = u.Remision
		LEFT JOIN	OpeSch.TiCatUsuarioVw cu WITH(NOLOCK)
		ON		cu.ClaUsuario = u.ClaUsuarioMod            
		--Base Recepcion Traspaso
		LEFT JOIN	OpeSch.OpeTraRecepTraspaso w WITH(NOLOCK)
		ON		w.ClaUbicacionOrigen = ie.ClaUbicacion 
		AND		w.IdViajeOrigen = ie.IdViaje --AND w.IdBoleta = ie.IdBoleta
		LEFT JOIN	Opesch.OpeTraRecepTraspasoFab x WITH(NOLOCK)
		ON		x.ClaUbicacionOrigen = w.ClaUbicacionOrigen 
		AND		x.IdViajeOrigen = w.IdViajeOrigen 
		AND		x.IdFabricacion = a.Pedido_Espejo 
		AND		x.IdEntSalOrigen = fe.IdEntSal
		LEFT JOIN	Opesch.OpeTraRecepTraspasoProd y WITH(NOLOCK)
		ON		y.ClaUbicacionOrigen = x.ClaUbicacionOrigen 
		AND		y.IdViajeOrigen = x.IdViajeOrigen 
		AND		y.IdFabricacion = x.IdFabricacion 
		AND		y.IdFabricacionDet = v.IdFabricacionDet
		LEFT JOIN	Opesch.OpeTraRecepTraspasoProdRecibido z WITH(NOLOCK)   
		ON		z.ClaUbicacionOrigen = y.ClaUbicacionOrigen 
		AND		z.IdViajeOrigen = y.IdViajeOrigen 
		AND		z.IdFabricacion = y.IdFabricacion 
		AND		z.IdFabricacionDet = y.IdFabricacionDet 
		WHERE   ( ISNULL(u.EsEntregado, 0) = 1 OR ISNULL(@pnChkRemNoEntregadas,0) = 1 )
		AND		(@pdFechaInicio IS NULL OR (@pdFechaInicio <= ie.FechaViaje))
		AND		(@pdFechaFin IS NULL OR (@pdFechaFin > ie.FechaViaje))
		------Fin: Proceso PreEjecucion de Consulta------

	IF @pnDebug = 1
		SELECT '' AS '#TempVistaEstimacionesDetalleRemision', * FROM #TempVistaEstimacionesDetalleRemision



	------Inicio: Proceso de Consulta Encabezado------
    ;WITH	ControlRemisionFactura AS
    (SELECT	a.ClaCliente,
            a.ClaProyecto,
            a.Pedido_Unificado,
            a.Pedido_Venta_Original,
            a.Pedido_Espejo,
            a.No_Renglon_PE,
            a.Articulo,
            a.Viaje_PE,
            a.Remision,
            a.Mov_Embarque,
            ISNULL(SUM(cfd.CantSurtidaFact),0) AS Cant_Facturada
    FROM	#TempVistaEstimacionesDetalleRemision a
        LEFT JOIN OpeSch.OpeControlFacturaRemisionEstimacionVw cf WITH(NOLOCK)
            ON cf.ClaCliente = a.ClaCliente AND cf.ClaProyecto = a.ClaProyecto AND cf.IdViaje = a.Viaje_VO AND cf.RemisionAlfanumerico = a.Remision
        LEFT JOIN OpeSch.OpeControlFacturaRemisionEstimacionDetVw cfd WITH(NOLOCK)
            ON cfd.IdContFacturaRemision = cf.IdContFacturaRemision AND cfd.ClaArticulo = a.Articulo
    GROUP BY 
            a.ClaCliente,
            a.ClaProyecto,
            a.Pedido_Unificado,
            a.Pedido_Venta_Original,
            a.Pedido_Espejo,
            a.No_Renglon_PE,
            a.Articulo,
            a.Viaje_PE,
            a.Remision,
            a.Mov_Embarque)

    SELECT	a.Cliente AS ColNomCliente,
            a.Proyecto AS ColNomProyecto,
            a.Pedido_Venta_Original AS ColFabVenta,
            a.Pedido_Espejo AS ColFabEstimacion,
            a.Viaje_PE AS ColViajeEst,
            a.Remision AS ColRemision,
            a.Kilos_Embarcada_VO AS ColKilosRemisionados,
            a.Kilos_Recibidos_PE AS ColKilosRecibidos,
            ISNULL(SUM(b.Cant_Facturada),0) * a.Peso_Teorico_Kgs AS ColKilosFacturados,
            a.Fecha_Viaje_PE AS ColFecha,
			a.Dias_Viaje_PE AS ColDias,
            a.Estatus_Evidencia AS ColEstatus,
            a.Evidencia_POD AS ColEvidencia,
            a.Estatus_Autorizacion AS ColAutorizado,
            a.Autorizado_Por AS ColAutorizadoPor,
            a.Comentarios_Autorizacion AS ColComentarios,
            a.Planta_E AS ColUbicacionOrigen,
            a.ClaCliente AS ColClaCliente,
            a.ClaProyecto AS ColClaProyecto,
            a.Viaje_VO AS ColViaje
			,CONVERT(VARCHAR(10),a.Planta_E) + ' - ' + c.NomUbicacion AS ColNomUbicacionOrigen
			, ColVerRemision = 'Ver'
    FROM	#TempVistaEstimacionesDetalleRemision a
        LEFT JOIN ControlRemisionFactura b WITH(NOLOCK)
            ON b.ClaCliente = a.ClaCliente AND b.ClaProyecto = a.ClaProyecto AND b.Viaje_PE = a.Viaje_PE AND b.Remision = a.Remision AND b.Articulo = a.Articulo
		LEFT JOIN OpeSch.OpeTiCatUbicacionVw c
		ON		 a.Planta_E	= c.ClaUbicacion
    GROUP BY 
            a.Cliente,
            a.Proyecto,
            a.Pedido_Venta_Original,
            a.Pedido_Espejo,
            a.Viaje_PE,
            a.Remision,
            a.Kilos_Embarcada_VO,
            a.Kilos_Recibidos_PE,
            a.Peso_Teorico_Kgs,
            a.Fecha_Viaje_PE,
            a.Dias_Viaje_PE,
            a.Estatus_Evidencia,
            a.Evidencia_POD,
            a.Estatus_Autorizacion,
            a.Autorizado_Por,
            a.Comentarios_Autorizacion,
            a.Planta_E,
            a.ClaCliente,
            a.ClaProyecto,
            a.Viaje_VO
			, CONVERT(VARCHAR(10),a.Planta_E) + ' - ' + c.NomUbicacion
    ORDER BY
            a.Viaje_PE, a.Remision
    ------Fin: Proceso de Consulta Encabezado------

    DROP TABLE #TempVistaEstimacionesDetalleRemision
END