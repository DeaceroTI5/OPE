Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE OpeSch.OPE_CU550_Pag28_Grid_GridConsFactEstimaciones_Sel
    @pnClaUbicacion         INT, 
    @pnCmbCliente           INT,
    @pnCmbProyecto          INT, 
    @pnCmbTipoProyecto      INT,
    @pnChkRemNoEntregadas   TINYINT = 0,
	@psClaUbicacionOrig	    VARCHAR(600)= '',
	@pdFechaInicio			DATETIME = NULL,
	@pdFechaFin			    DATETIME = NULL,
    @pnCmbTransportista     INT,
    @pnChkRemCanceladas		TINYINT = 0,
	@pnClaUsuarioMod		INT = NULL,
	@psTxtRemision			VARCHAR(20) = '',
	@pnViajeSel				INT = NULL,
	@pnDebug				TINYINT = 0
AS
BEGIN

	IF (@pdFechaInicio IS NOT NULL AND @pdFechaFin IS NOT NULL AND (@pdFechaFin < @pdFechaInicio)) 
	BEGIN
		RAISERROR('La Fecha Inicial NO debe ser Mayor a la Fecha Final. Favor de Verificar.',16,1)
		RETURN
	END	
	
	IF @pdFechaFin IS NOT NULL
		SELECT @pdFechaFin = DATEADD(DAY,1,@pdFechaFin)
	
    DECLARE	@CmbCliente         INT,
			@CmbProyecto        INT,
            @CmbTipoProyecto    INT,
			@TxtRemision		VARCHAR(20)

	DECLARE @tUbicacionEstimacionCmb TABLE(
		  Id						INT IDENTITY(1,1)
		, ClaUbicacionEstimacion	INT
		, NomUbicacionEstimacion	VARCHAR(150)
	)

	DECLARE @tbControlFacturadoRemisiones TABLE(
		Proyecto		INT,
		Viaje			INT,
		Remision		VARCHAR(20),
		NoFabricaciones	INT,
		Articulo		INT,
		CantSurtidaRec	NUMERIC(22,4),
		CantSurtidaFact	NUMERIC(22,4)
	)

	DECLARE @tbProformasEstimaciones TABLE(
		Remision		VARCHAR(20),
		Proformas		VARCHAR(600)
	)
    
	------------------------------------------------------------------------------	
	SELECT	@CmbCliente         = (CASE WHEN (@pnCmbCliente = -1 OR @pnCmbCliente IS NULL) THEN 1 ELSE 0 END),
			@CmbProyecto        = (CASE WHEN (@pnCmbProyecto = -1 OR @pnCmbProyecto IS NULL) THEN 1 ELSE 0 END),
            @CmbTipoProyecto    = (CASE WHEN (@pnCmbTipoProyecto = -1 OR @pnCmbTipoProyecto IS NULL) THEN 1 ELSE 0 END)
	
	SET @psClaUbicacionOrig = ISNULL(@psClaUbicacionOrig,'')

	IF @psClaUbicacionOrig <> ''
	BEGIN
		INSERT	INTO @tUbicacionEstimacionCmb
		SELECT	DISTINCT LTRIM(RTRIM(T0.string)), T1.NombreUbicacion
		FROM	OpeSch.OPEUtiSplitStringFn(@psClaUbicacionOrig, ',') T0
		INNER JOIN	OpeSch.OpeTiCatUbicacionVw T1 WITH(NOLOCK)  
			ON	LTRIM(RTRIM(T0.string)) = T1.ClaUbicacion
	END

    IF  ISNULL(@pnDebug, 0) = 1
    BEGIN 
        SELECT  '@tUbicacionEstimacionCmb',
                *
        FROM    @tUbicacionEstimacionCmb
    END
	
	------------------------------------------------------------------------------
	INSERT INTO @tbControlFacturadoRemisiones(
		  Proyecto		
		, Viaje			
		, Remision		
		, NoFabricaciones	
		, Articulo		
		, CantSurtidaRec	
		, CantSurtidaFact		
	)
	SELECT	T0.ClaProyecto AS Proyecto,
			T0.IdViaje AS Viaje,
			T0.RemisionAlfanumerico AS Remision,
			COUNT(T0.IdFabricacion) AS NoFabricaciones,
			T1.ClaArticulo AS Articulo,
			SUM(ISNULL(T1.CantSurtidaRec,0)) AS CantSurtidaRec,
			SUM(ISNULL(T1.CantSurtidaFact,0)) AS CantSurtidaFact
	FROM    OpeSch.OpeControlFacturaRemisionEstimacionVw T0 WITH(NOLOCK)
	INNER JOIN  OpeSch.OpeControlFacturaRemisionEstimacionDetVw T1 WITH(NOLOCK)
		ON	T0.IdContFacturaRemision = T1.IdContFacturaRemision AND T0.IdFabricacion = T1.IdFabricacion
	GROUP BY
			T0.ClaProyecto,
			T0.IdViaje,
			T0.RemisionAlfanumerico,
			T1.ClaArticulo

    IF  ISNULL(@pnDebug, 0) = 1
    BEGIN 
        SELECT  '@tbControlFacturadoRemisiones',
                *
        FROM    @tbControlFacturadoRemisiones
    END

    ------------------------------------------------------------------------------
	;WITH	ListadoRemisionesEstimacion		AS
	(
		SELECT	DISTINCT
				T0.FacturaAlfanumericoVenta
		FROM	OpeSch.OpeRelEmbarqueEstimacionVw T0 WITH(NOLOCK)
		INNER JOIN	@tUbicacionEstimacionCmb T1
			ON	T0.PlantaEstimacion			= T1.ClaUbicacionEstimacion
	),		
			RelProformasRemisiones			AS
	(
		SELECT	Remision			= T0.FacturaAlfanumericoVenta,
				FolioProforma		= T1.FolioProforma,
				Factura				= T3.IdFacturaAlfanumerico
		FROM	ListadoRemisionesEstimacion T0
		INNER JOIN	OpeSch.OpeTraRelFacturaRemisionEstimacionDet T1 WITH(NOLOCK)
			ON	T0.FacturaAlfanumericoVenta	= T1.RemisionAlfanumerico
		INNER JOIN	OpeSch.OpeVtaTraProformaVw T2 WITH(NOLOCK)
			ON	T1.FolioProforma			= T2.IdProforma
		LEFT JOIN	OpeSch.OpeVtaCTraFacturaVw T3 WITH(NOLOCK)
			ON	T2.IdFacturaNueva			= T3.IdFactura
	),		
			ConcatenadoProformas			AS
	(
		SELECT	Remision			= T0.FacturaAlfanumericoVenta,
				Proformas			= STUFF((	SELECT	', ' + pr.Factura
                                                FROM	RelProformasRemisiones pr
                                                WHERE	pr.Remision	= T0.FacturaAlfanumericoVenta											
                                                GROUP BY
                                                        pr.Factura
                                                FOR XML PATH ('')
                                                ), 1, 1, '')
		FROM	ListadoRemisionesEstimacion T0
	)

	INSERT INTO @tbProformasEstimaciones(
		  Remision		
		, Proformas		
	)
	SELECT	Remision,
			Proformas
	FROM	ConcatenadoProformas
	WHERE	Proformas IS NOT NULL

    IF  ISNULL(@pnDebug, 0) = 1
    BEGIN 
        SELECT  '@tbProformasEstimaciones',
                *
        FROM    @tbProformasEstimaciones
    END
			
	------------------------------------------------------------------------------
    

	IF ISNULL(@pnChkRemCanceladas,0) = 0
	BEGIN
		SELECT	--ColNomUbicacionOrigen
				LTRIM(RTRIM(CONVERT(VARCHAR(20), TA3.ClaUbicacion))) + ' - ' + TA3.NombreUbicacion AS ColNomUbicacionOrigen,
				--ColNomCliente
				LTRIM(RTRIM(CONVERT(VARCHAR(150), TA2.ClaClienteCuenta))) + ' - ' + TA2.NomClienteCuenta AS ColNomCliente,
				--ColNomProyecto
				LTRIM(RTRIM(CONVERT(VARCHAR(150), TA1.ClaProyecto))) + ' - ' + TA1.NomProyecto AS ColNomProyecto,
				--ColFabVenta
				T1.FabricacionVenta AS ColFabVenta,
				--ColFabEstimacion
				T1.FabricacionEstimacion AS ColFabEstimacion,
				--ColViajeEst
				T1.IdViajeEstimacion AS ColViajeEst,
				--ColRemision
				T1.FacturaAlfanumericoVenta AS ColRemision,
				--ColKilosRemisionados
				ISNULL( SUM(T1.CantEmbarcadoVenta * T1.PesoTeoricoKgs),0.00 ) AS ColKilosRemisionados,
				--ColKilosRecibidos
				ISNULL( SUM(T10.CantRecibida * T1.PesoTeoricoKgs),0.00 ) AS ColKilosRecibidos,
				--ColKilosFacturados
				ISNULL( SUM(T11.CantSurtidaFact * T1.PesoTeoricoKgs),0.00 ) AS ColKilosFacturados,
				--ColFecha
				T1.FechaViajeEstimacion AS ColFecha,
				--ColDias
				DATEDIFF(DAY, T1.FechaViajeEstimacion, GETDATE()) AS ColDias,
                --ColProformas
                T14.Proformas AS ColProformas,
				--ColVerRemision
				'Ver' AS ColVerRemision,
				--ColTransportista
				T13.NomTransportista AS ColTransportista,
				--ColEstatus
				CASE T3.EsEntregado WHEN 0 THEN 'No Entregado' WHEN 1 THEN 'Entregado' ELSE 'No Entregado' END AS ColEstatus,
				--ColEvidencia
				CASE WHEN T5.Remision IS NOT NULL THEN 'Ver Evidencia' ELSE '' END AS ColEvidencia,
				--ColAutorizado
				ISNULL(T3.EsRecibido, 0) AS ColAutorizado,
				--ColAutorizadoPor
				CASE T3.EsRecibido WHEN 0 THEN NULL WHEN 1 THEN T6.NombreUsuario + ' ' + T6.ApellidoPaterno ELSE NULL END AS ColAutorizadoPor,
				--ColComentarios
				CASE T3.EsRecibido WHEN 0 THEN NULL WHEN 1 THEN T3.ComentarioRecepcion  ELSE NULL END AS ColComentarios,
				--ColUbicacionOrigen
				T1.PlantaEstimacion AS ColUbicacionOrigen,
				--ColClaCliente
				T1.ClienteProyectoAgp AS ColClaCliente,
				--ColClaProyecto
				T1.ProyectoAgrupador AS ColClaProyecto,
				--ColViaje
				T1.IdViajeVenta AS ColViaje
		FROM	OpeSch.OpeRelEmbarqueEstimacionVw T1 WITH(NOLOCK)
		--Información de Ubicación, Cliente y Proyecto
		INNER JOIN	OpeSch.OpeVtaCatProyectoVw TA1 WITH(NOLOCK)
			ON T1.ProyectoAgrupador = TA1.ClaProyecto
		INNER JOIN	OpeSch.OpeVtaCatClienteCuentaVw TA2 WITH(NOLOCK)
			ON T1.ClienteProyectoAgp = TA2.ClaClienteCuenta
		INNER JOIN	OpeSch.OpeTiCatUbicacionVw TA3 WITH(NOLOCK)  
			ON T1.PlantaEstimacion = TA3.ClaUbicacion
		--Tabla Tipo de Proyecto
		INNER JOIN	OpeSch.OpeRelProyectoEstimacionVw T2 WITH(NOLOCK)
			ON T1.ClienteProyectoAgp = T2.ClaCliente AND T1.ProyectoAgrupador = T2.ClaProyecto
		--Base POD
		LEFT JOIN	OpeSch.OpeTraInfoViajeEstimacion T3 WITH(NOLOCK)
			ON T1.PlantaEstimacion = T3.ClaUbicacionOrigen AND T1.IdViajeEstimacion = T3.IdViajeOrigen AND T1.FacturaAlfanumericoVenta = T3.Remision
		LEFT JOIN	OpeSch.OpeTraInfoViajeEstimacionDet T4 WITH(NOLOCK)
			ON T3.ClaUbicacionOrigen = T4.ClaUbicacionOrigen AND T3.IdViajeOrigen = T4.IdViajeOrigen AND T1.FabricacionEstimacion = T4.IdFabricacion AND T1.RenglonEstimacion = T4.IdFabricacionDet
		LEFT JOIN	OpeSch.OpeTraEvidenciaViajeEstimacion T5 WITH(NOLOCK)
			ON T3.ClaUbicacion = T5.ClaUbicacion AND T3.ClaUbicacionOrigen = T5.ClaUbicacionOrigen AND T3.IdViajeOrigen = T5.IdViajeOrigen AND T3.Remision = T5.Remision
		LEFT JOIN	OpeSch.TiCatUsuarioVw T6 WITH(NOLOCK)
			ON T3.ClaUsuarioMod = T6.ClaUsuario       
		--Base Recepcion Traspaso
		LEFT JOIN	OpeSch.OpeTraRecepTraspaso T7 WITH(NOLOCK)
			ON T1.PlantaEstimacion = T7.ClaUbicacionOrigen AND T1.IdViajeEstimacion = T7.IdViajeOrigen
		LEFT JOIN	Opesch.OpeTraRecepTraspasoFab T8 WITH(NOLOCK)
			ON T7.ClaUbicacionOrigen = T8.ClaUbicacionOrigen AND T7.IdViajeOrigen = T8.IdViajeOrigen AND  T1.FabricacionEstimacion = T8.IdFabricacion AND T1.IdEntSalEstimacion = T8.IdEntSalOrigen
		LEFT JOIN	Opesch.OpeTraRecepTraspasoProd T9 WITH(NOLOCK)
			ON T8.ClaUbicacionOrigen = T9.ClaUbicacionOrigen AND T8.IdViajeOrigen = T9.IdViajeOrigen AND T8.IdFabricacion = T9.IdFabricacion AND T4.IdFabricacionDet = T9.IdFabricacionDet
		LEFT JOIN	Opesch.OpeTraRecepTraspasoProdRecibido T10 WITH(NOLOCK)   
			ON T9.ClaUbicacionOrigen = T10.ClaUbicacionOrigen AND T9.IdViajeOrigen = T10.IdViajeOrigen AND T9.IdFabricacion = T10.IdFabricacion AND T9.IdFabricacionDet = T10.IdFabricacionDet
		--Base Control de Facturación por Remisión
		LEFT JOIN	@tbControlFacturadoRemisiones T11 
			ON T1.ProyectoAgrupador = T11.Proyecto AND T1.IdViajeVenta = T11.Viaje AND T1.FacturaAlfanumericoVenta = T11.Remision AND T1.ClaArticulo = T11.Articulo
		--Listado de Catalogos Filtro
		LEFT JOIN	@tUbicacionEstimacionCmb T12 
			ON T1.PlantaEstimacion = T12.ClaUbicacionEstimacion
		LEFT JOIN	OpeSch.OpeFleCatTransportistaVw T13 WITH(NOLOCK)
			ON T1.PlantaEstimacion = T13.ClaUbicacion AND T1.ClaTransportistaEstimacion = T13.ClaTransportista AND (T13.ClaTransportista = ISNULL( @pnCmbTransportista,0 ) OR ISNULL( @pnCmbTransportista,0 ) = 0)
        LEFT JOIN	@tbProformasEstimaciones T14
            ON	T1.FacturaAlfanumericoVenta		= T14.Remision
		WHERE	T1.PlantaVirtualAgrupador IN (365)		
		AND     T2.EsEstimacion = 1
		AND		( T1.ClienteProyectoAgp = @pnCmbCliente OR @CmbCliente = 1 )  
		AND		( T1.ProyectoAgrupador = @pnCmbProyecto OR @CmbProyecto = 1 ) 
		AND		( T2.EsInstalacion = @pnCmbTipoProyecto OR @CmbTipoProyecto = 1 )
		AND		(@psClaUbicacionOrig = '' OR (T1.PlantaEstimacion = T12.ClaUbicacionEstimacion))
		AND		( ISNULL(T3.EsEntregado, 0) = 1 OR ISNULL(@pnChkRemNoEntregadas,0) = 1 )
		AND		(@pdFechaInicio IS NULL OR (@pdFechaInicio <= T1.FechaViajeEstimacion))
		AND		(@pdFechaFin IS NULL OR (@pdFechaFin > T1.FechaViajeEstimacion))
		AND		(ISNULL(@psTxtRemision,'') = '' OR (T1.FacturaAlfanumericoVenta = @psTxtRemision))
		AND		(@pnViajeSel IS NULL OR @pnViajeSel = T1.IdViajeEstimacion)
		GROUP BY
				T1.ProyectoAgrupador,
				LTRIM(RTRIM(CONVERT(VARCHAR(150), TA1.ClaProyecto))) + ' - ' + TA1.NomProyecto,
				T1.ClienteProyectoAgp,
				LTRIM(RTRIM(CONVERT(VARCHAR(150), TA2.ClaClienteCuenta))) + ' - ' + TA2.NomClienteCuenta,
				T1.PlantaEstimacion,
				LTRIM(RTRIM(CONVERT(VARCHAR(20), TA3.ClaUbicacion))) + ' - ' + TA3.NombreUbicacion,
				T1.IdViajeEstimacion,
				T1.IdViajeVenta,
				T1.FechaViajeEstimacion,
				T1.FacturaAlfanumericoVenta,
				T1.FabricacionEstimacion,
				T1.FabricacionVenta,
				T13.NomTransportista,
				T3.EsEntregado,
				T3.EsRecibido,
				T5.Remision,
				T6.NombreUsuario + ' ' + T6.ApellidoPaterno,
				T3.ComentarioRecepcion,
			    T14.Proformas
		ORDER BY 
				T1.IdViajeVenta, T1.FacturaAlfanumericoVenta
	END
	ELSE
	BEGIN
		SELECT	--ColNomUbicacionOrigen
				LTRIM(RTRIM(CONVERT(VARCHAR(20), TA3.ClaUbicacion))) + ' - ' + TA3.NombreUbicacion AS ColNomUbicacionOrigen,
				--ColNomCliente
				LTRIM(RTRIM(CONVERT(VARCHAR(150), TA2.ClaClienteCuenta))) + ' - ' + TA2.NomClienteCuenta AS ColNomCliente,
				--ColNomProyecto
				LTRIM(RTRIM(CONVERT(VARCHAR(150), TA1.ClaProyecto))) + ' - ' + TA1.NomProyecto AS ColNomProyecto,
				--ColFabVenta
				T1.FabricacionVenta AS ColFabVenta,
				--ColFabEstimacion
				T1.FabricacionEstimacion AS ColFabEstimacion,
				--ColViajeEst
				T1.IdViajeEstimacion AS ColViajeEst,
				--ColRemision
				T1.FacturaAlfanumericoVenta AS ColRemision,
				--ColKilosRemisionados
				ISNULL( SUM(T1.CantEmbarcadoVenta * T1.PesoTeoricoKgs),0.00 ) AS ColKilosRemisionados,
				--ColKilosRecibidos
				ISNULL( SUM(T10.CantRecibida * T1.PesoTeoricoKgs),0.00 ) AS ColKilosRecibidos,
				--ColKilosFacturados
				ISNULL( SUM(T11.CantSurtidaFact * T1.PesoTeoricoKgs),0.00 ) AS ColKilosFacturados,
				--ColFecha
				T1.FechaViajeEstimacion AS ColFecha,
				--ColDias
				DATEDIFF(DAY, T1.FechaViajeEstimacion, GETDATE()) AS ColDias,
                --ColProformas
                T14.Proformas AS ColProformas,
				--ColVerRemision
				'Ver' AS ColVerRemision,
				--ColTransportista
				T13.NomTransportista AS ColTransportista,
				--ColEstatus
				CASE T3.EsEntregado WHEN 0 THEN 'No Entregado' WHEN 1 THEN 'Entregado' ELSE 'No Entregado' END AS ColEstatus,
				--ColEvidencia
				CASE WHEN T5.Remision IS NOT NULL THEN 'Ver Evidencia' ELSE '' END AS ColEvidencia,
				--ColAutorizado
				ISNULL(T3.EsRecibido, 0) AS ColAutorizado,
				--ColAutorizadoPor
				CASE T3.EsRecibido WHEN 0 THEN NULL WHEN 1 THEN T6.NombreUsuario + ' ' + T6.ApellidoPaterno ELSE NULL END AS ColAutorizadoPor,
				--ColComentarios
				CASE T3.EsRecibido WHEN 0 THEN NULL WHEN 1 THEN T3.ComentarioRecepcion  ELSE NULL END AS ColComentarios,
				--ColUbicacionOrigen
				T1.PlantaEstimacion AS ColUbicacionOrigen,
				--ColClaCliente
				T1.ClienteProyectoAgp AS ColClaCliente,
				--ColClaProyecto
				T1.ProyectoAgrupador AS ColClaProyecto,
				--ColViaje
				T1.IdViajeVenta AS ColViaje
		FROM	OpeSch.OpeRelEmbarqueEstimacionBitVw T1 WITH(NOLOCK)
		--Información de Ubicación, Cliente y Proyecto
		INNER JOIN	OpeSch.OpeVtaCatProyectoVw TA1 WITH(NOLOCK)
			ON T1.ProyectoAgrupador = TA1.ClaProyecto
		INNER JOIN	OpeSch.OpeVtaCatClienteCuentaVw TA2 WITH(NOLOCK)
			ON T1.ClienteProyectoAgp = TA2.ClaClienteCuenta
		INNER JOIN	OpeSch.OpeTiCatUbicacionVw TA3 WITH(NOLOCK)  
			ON T1.PlantaEstimacion = TA3.ClaUbicacion
		--Tabla Tipo de Proyecto
		INNER JOIN	OpeSch.OpeRelProyectoEstimacionVw T2 WITH(NOLOCK)
			ON T1.ClienteProyectoAgp = T2.ClaCliente AND T1.ProyectoAgrupador = T2.ClaProyecto
		--Base POD
		LEFT JOIN	OpeSch.OpeTraInfoViajeEstimacion T3 WITH(NOLOCK)
			ON T1.PlantaEstimacion = T3.ClaUbicacionOrigen AND T1.IdViajeEstimacion = T3.IdViajeOrigen AND T1.FacturaAlfanumericoVenta = T3.Remision
		LEFT JOIN	OpeSch.OpeTraInfoViajeEstimacionDet T4 WITH(NOLOCK)
			ON T3.ClaUbicacionOrigen = T4.ClaUbicacionOrigen AND T3.IdViajeOrigen = T4.IdViajeOrigen AND T1.FabricacionEstimacion = T4.IdFabricacion AND T1.RenglonEstimacion = T4.IdFabricacionDet
		LEFT JOIN	OpeSch.OpeTraEvidenciaViajeEstimacion T5 WITH(NOLOCK)
			ON T3.ClaUbicacion = T5.ClaUbicacion AND T3.ClaUbicacionOrigen = T5.ClaUbicacionOrigen AND T3.IdViajeOrigen = T5.IdViajeOrigen AND T3.Remision = T5.Remision
		LEFT JOIN	OpeSch.TiCatUsuarioVw T6 WITH(NOLOCK)
			ON T3.ClaUsuarioMod = T6.ClaUsuario       
		--Base Recepcion Traspaso
		LEFT JOIN	OpeSch.OpeTraRecepTraspaso T7 WITH(NOLOCK)
			ON T1.PlantaEstimacion = T7.ClaUbicacionOrigen AND T1.IdViajeEstimacion = T7.IdViajeOrigen
		LEFT JOIN	Opesch.OpeTraRecepTraspasoFab T8 WITH(NOLOCK)
			ON T7.ClaUbicacionOrigen = T8.ClaUbicacionOrigen AND T7.IdViajeOrigen = T8.IdViajeOrigen AND  T1.FabricacionEstimacion = T8.IdFabricacion AND T1.IdEntSalEstimacion = T8.IdEntSalOrigen
		LEFT JOIN	Opesch.OpeTraRecepTraspasoProd T9 WITH(NOLOCK)
			ON T8.ClaUbicacionOrigen = T9.ClaUbicacionOrigen AND T8.IdViajeOrigen = T9.IdViajeOrigen AND T8.IdFabricacion = T9.IdFabricacion AND T4.IdFabricacionDet = T9.IdFabricacionDet
		LEFT JOIN	Opesch.OpeTraRecepTraspasoProdRecibido T10 WITH(NOLOCK)   
			ON T9.ClaUbicacionOrigen = T10.ClaUbicacionOrigen AND T9.IdViajeOrigen = T10.IdViajeOrigen AND T9.IdFabricacion = T10.IdFabricacion AND T9.IdFabricacionDet = T10.IdFabricacionDet
		--Base Control de Facturación por Remisión
		LEFT JOIN	@tbControlFacturadoRemisiones T11 
			ON T1.ProyectoAgrupador = T11.Proyecto AND T1.IdViajeVenta = T11.Viaje AND T1.FacturaAlfanumericoVenta = T11.Remision AND T1.ClaArticulo = T11.Articulo
		--Listado de Catalogos Filtro
		LEFT JOIN	@tUbicacionEstimacionCmb T12 
			ON T1.PlantaEstimacion = T12.ClaUbicacionEstimacion
		LEFT JOIN	OpeSch.OpeFleCatTransportistaVw T13 WITH(NOLOCK)
			ON T1.PlantaEstimacion = T13.ClaUbicacion AND T1.ClaTransportistaEstimacion = T13.ClaTransportista AND (T13.ClaTransportista = ISNULL( @pnCmbTransportista,0 ) OR ISNULL( @pnCmbTransportista,0 ) = 0)
        LEFT JOIN	@tbProformasEstimaciones T14
            ON	T1.FacturaAlfanumericoVenta		= T14.Remision
		WHERE	T1.PlantaVirtualAgrupador IN (365)		
		AND     T2.EsEstimacion = 1
		AND		( T1.ClienteProyectoAgp = @pnCmbCliente OR @CmbCliente = 1 )  
		AND		( T1.ProyectoAgrupador = @pnCmbProyecto OR @CmbProyecto = 1 ) 
		AND		( T2.EsInstalacion = @pnCmbTipoProyecto OR @CmbTipoProyecto = 1 )
		AND		(@psClaUbicacionOrig = '' OR (T1.PlantaEstimacion = T12.ClaUbicacionEstimacion))
		AND		( ISNULL(T3.EsEntregado, 0) = 1 OR ISNULL(@pnChkRemNoEntregadas,0) = 1 )
		AND		(@pdFechaInicio IS NULL OR (@pdFechaInicio <= T1.FechaViajeEstimacion))
		AND		(@pdFechaFin IS NULL OR (@pdFechaFin > T1.FechaViajeEstimacion))
		AND		(ISNULL(@psTxtRemision,'') = '' OR (T1.FacturaAlfanumericoVenta = @psTxtRemision))
		AND		(@pnViajeSel IS NULL OR @pnViajeSel = T1.IdViajeEstimacion)
		GROUP BY
				T1.ProyectoAgrupador,
				LTRIM(RTRIM(CONVERT(VARCHAR(150), TA1.ClaProyecto))) + ' - ' + TA1.NomProyecto,
				T1.ClienteProyectoAgp,
				LTRIM(RTRIM(CONVERT(VARCHAR(150), TA2.ClaClienteCuenta))) + ' - ' + TA2.NomClienteCuenta,
				T1.PlantaEstimacion,
				LTRIM(RTRIM(CONVERT(VARCHAR(20), TA3.ClaUbicacion))) + ' - ' + TA3.NombreUbicacion,
				T1.IdViajeEstimacion,
				T1.IdViajeVenta,
				T1.FechaViajeEstimacion,
				T1.FacturaAlfanumericoVenta,
				T1.FabricacionEstimacion,
				T1.FabricacionVenta,
				T13.NomTransportista,
				T3.EsEntregado,
				T3.EsRecibido,
				T5.Remision,
				T6.NombreUsuario + ' ' + T6.ApellidoPaterno,
				T3.ComentarioRecepcion,
			    T14.Proformas
		ORDER BY 
				T1.IdViajeVenta, T1.FacturaAlfanumericoVenta
	END
END