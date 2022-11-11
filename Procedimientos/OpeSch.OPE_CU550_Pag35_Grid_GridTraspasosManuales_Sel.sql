USE Operacion
GO
	-- 'OpeSch.OPE_CU550_Pag35_Grid_GridTraspasosManuales_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag35_Grid_GridTraspasosManuales_Sel
	@pnClaUbicacion         INT,	
    @pnClaSolicitud	        INT = 0,
    @pnClaPedido	        INT = 0,
    @pnClaPedidoOrigen	    INT = 0,
    @pnCmbEstatusSolicitud	INT = 0,
    @pnCmbPlantaPide	    INT = 0,
    @pnCmbPlantaSurte	    INT = 0,
    @ptFechaInicio          DATETIME,
    @ptFechaFinal           DATETIME,
	@pnClaProyecto			INT = NULL,
	@pnClaCliente			INT = NULL,
	@pnClaConsignado		INT = NULL,
	@pnDebug				TINYINT= 0
AS
BEGIN
    
    SET NOCOUNT ON

	-- exec OPESch.OPE_CU550_Pag35_Grid_GridTraspasosManuales_Sel @pnClaUbicacion=325,@pnClaSolicitud=NULL,@pnClaPedido=NULL,@pnClaPedidoOrigen=NULL,@pnCmbEstatusSolicitud=NULL,@pnCmbPlantaPide=NULL,@pnCmbPlantaSurte=NULL,@ptFechaInicio='2022-09-06 00:00:00',@ptFechaFinal='2022-10-07 00:00:00'
    
	--Validación de Fecha Inicio y Fecha Fin
    IF (@ptFechaInicio IS NOT NULL AND @ptFechaFinal IS NOT NULL AND (@ptFechaFinal < @ptFechaInicio)) 
	BEGIN
		RAISERROR('La Fecha Inicial NO debe ser Mayor a la Fecha Final. Favor de Verificar.',16,1)
		RETURN
	END	

    --Inicialización de Tabla Temporal Resulset
    CREATE TABLE    #TraspasosManuales 
    (   Consecutivo             INT IDENTITY(1,1),
        NivelGrid               INT,
        Solicitud               INT,
        Fabricacion             INT,
        PedidoOrigen            INT,
        UbicacionSolicita       VARCHAR(250),
        UbicacionSurte          VARCHAR(250),
        FechaCaptura            DATETIME,
        EstatusSolicitud        VARCHAR(50),
        Renglon                 INT,
        Producto                VARCHAR(250),
        Unidad                  VARCHAR(10),
        CantPedida              NUMERIC(22,4),
        PrecioListaMP           NUMERIC(22,4),
        PrecioLista             NUMERIC(22,4),
        MotivoRechazo           VARCHAR(250),
        HechaPor                VARCHAR(255),
        ClaUbicacionSolicita    INT,
        ClaUbicacionSurte       INT,
        ClaEstatusSolicitud     INT,
        ClaEstatus              INT,
        ClaProducto             INT,
        ClaMotivoRechazo        INT,
        ClaMotivoAutomatico     INT,
        ClaRelacion             INT,
		NomProyecto				VARCHAR(60),
		NombreCliente			VARCHAR(80),
		NombreConsignado		VARCHAR(70),
		EstatusPedidoMP			VARCHAR(30),
		EstatusPedidoOrigen		VARCHAR(30),
		EstatusPedidoMPDet		VARCHAR(30),
		EstatusPedidoOrigenDet	VARCHAR(30),
		FechaDesea				DATETIME,
		CantidadSurtida        	NUMERIC(22,4),
		KilosSurtidos       	NUMERIC(22,4),
		PesoTeorico				NUMERIC(22,7),
		EsBitacora				TINYINT
    )

	DECLARE @tbEstatusFabricacion TABLE(
		  Id			INT IDENTITY(1,1)
		, ClaEstatus	INT
		, NomEstatus	VARCHAR(30)
	)

	DECLARE @tbPedidos TABLE(
		  Id			INT IDENTITY(1,1)
		, IdFabricacion	INT
		, ClaEstatus	INT
	)

	DECLARE @tbPedidosDet TABLE(
		  Id			INT IDENTITY(1,1)
		, IdFabricacion	INT
		, ClaArticulo	INT
		, ClaEstatus	INT
		, FechaDesea	DATETIME
		, CantidadSurtida NUMERIC(22,4)
	)



	INSERT INTO @tbEstatusFabricacion(ClaEstatus, NomEstatus)
	SELECT	ClaEstatus
			,Descripcion
	FROM	DEAOFINET05.Ventas.Vtasch.VtaCatEstatusFabricacionVw 
	WHERE	BajaLogica = 0


    --Inicialización de Proceso de Envio de Datos Nivel Detalle
    SELECT  @pnClaSolicitud         = ISNULL( @pnClaSolicitud,0 ),
            @pnClaPedido            = ISNULL( @pnClaPedido,0 ),
            @pnClaPedidoOrigen      = ISNULL( @pnClaPedidoOrigen,0 ),
            @pnCmbEstatusSolicitud  = ISNULL( @pnCmbEstatusSolicitud,-1 ),
            @pnCmbPlantaPide        = ISNULL( @pnCmbPlantaPide,-1 ),
            @pnCmbPlantaSurte       = ISNULL( @pnCmbPlantaSurte,-1 ),
			@pnClaProyecto			= ISNULL( @pnClaProyecto,-1),
			@pnClaCliente			= ISNULL( @pnClaCliente,-1),
			@pnClaConsignado		= ISNULL( @pnClaConsignado,-1)


    --Carga de Nivel Grid Encabezado
    INSERT INTO #TraspasosManuales (
		NivelGrid,				Solicitud,				Fabricacion,			PedidoOrigen,        
		UbicacionSolicita,		UbicacionSurte,			FechaCaptura,			EstatusSolicitud,    
		HechaPor,				ClaUbicacionSolicita,	ClaUbicacionSurte,		ClaEstatusSolicitud,
		ClaRelacion,			NomProyecto,			NombreCliente,			NombreConsignado	
	)
    SELECT  NivelGrid               = 1,
            Solicitud               = a.IdSolicitudTraspaso,
            Fabricacion             = a.ClaPedido,
            PedidoOrigen            = a.ClaPedidoOrigen,
            UbicacionSolicita       = CONVERT(VARCHAR(10),b.ClaUbicacion) + ' - '  + LTRIM(RTRIM(b.NombreUbicacion)),
            UbicacionSurte          = CONVERT(VARCHAR(10),c.ClaUbicacion) + ' - '  + LTRIM(RTRIM(c.NombreUbicacion)),
            FechaCaptura            = a.FechaIns,
            EstatusSolicitud        = CONVERT(VARCHAR(10),d.ClaEstatus) + ' - '  + LTRIM(RTRIM(d.NombreEstatus)),
            HechaPor                = RTRIM(LTRIM(e.NombreUsuario)) + ' ' + RTRIM(LTRIM(e.ApellidoPaterno)) + ' ' + RTRIM(LTRIM(e.ApellidoMaterno)),
            ClaUbicacionSolicita    = a.ClaUbicacionSolicita,
            ClaUbicacionSurte       = a.ClaUbicacionSurte,
            ClaEstatusSolicitud     = a.ClaEstatusSolicitud,
            ClaRelacion             = a.IdSolicitudTraspaso,
			NomProyecto				= f.NomProyecto,
			NombreCliente			= CONVERT(VARCHAR(10),a.ClaCliente) +' - '+g.NombreCliente,
			NombreConsignado		= CONVERT(VARCHAR(10),a.ClaConsignado) +' - '+h.NombreConsignado
    FROM    OpeSch.OpeTraSolicitudTraspasoEncVw a WITH(NOLOCK)  
    INNER JOIN  OpeSch.OpeTiCatUbicacionVw b WITH(NOLOCK)  
        ON  a.ClaUbicacionSolicita = b.ClaUbicacion
    INNER JOIN  OpeSch.OpeTiCatUbicacionVw c WITH(NOLOCK)  
        ON  a.ClaUbicacionSurte = c.ClaUbicacion
    INNER JOIN  TiCatalogo.dbo.TiCatEstatus d WITH(NOLOCK)   
        ON  a.ClaEstatusSolicitud = d.ClaEstatus AND d.ClaClasificacionEstatus = 1270105 AND ISNULL(d.BajaLogica, 0) = 0
    LEFT JOIN   OpeSch.OpeTiCatUsuarioVw e WITH(NOLOCK)  
        ON  a.ClaUsuarioIns = e.ClaUsuario
    LEFT JOIN OpeSch.OpeVtaCatProyectoVw f
	ON		a.ClaProyecto	=	f.ClaProyecto
	LEFT JOIN OpeSch.OpeVtaCatClienteVw g
	ON		a.ClaCliente	= g.ClaCliente
	LEFT JOIN OpeSch.OpeVtaCatConsignadoVw h
	ON		a.ClaConsignado	= h.ClaConsignado	
	WHERE   (a.IdSolicitudTraspaso = @pnClaSolicitud OR @pnClaSolicitud = 0)
    AND     (a.ClaPedido = @pnClaPedido OR @pnClaPedido = 0)
    AND     (a.ClaPedidoOrigen = @pnClaPedidoOrigen OR @pnClaPedidoOrigen = 0)
    AND     (a.ClaEstatusSolicitud = @pnCmbEstatusSolicitud OR @pnCmbEstatusSolicitud = -1)
    AND     (a.ClaUbicacionSolicita = @pnCmbPlantaPide OR @pnCmbPlantaPide = -1)
    AND     (a.ClaUbicacionSurte = @pnCmbPlantaSurte OR @pnCmbPlantaSurte = -1)
	AND		(@pnClaProyecto = -1 OR (a.ClaProyecto = @pnClaProyecto))
	AND		(@pnClaCliente = -1 OR (a.ClaCliente = @pnClaCliente))
	AND		(@pnClaConsignado = -1 OR (a.ClaConsignado = @pnClaConsignado))
    AND     (a.FechaIns >= @ptFechaInicio OR @ptFechaInicio IS NULL)
    AND     (a.FechaIns <= @ptFechaFinal OR @ptFechaFinal IS NULL)

	------------------------------------------------------------------------
	INSERT INTO @tbPedidos (IdFabricacion)
	SELECT DISTINCT Fabricacion FROM #TraspasosManuales
	UNION
	SELECT DISTINCT PedidoOrigen FROM #TraspasosManuales

	UPDATE	a
	SET		ClaEstatus = b.ClaEstatusFabricacion
	FROM	@tbPedidos a
	INNER JOIN DEAOFINET05.Ventas.Vtasch.VtaTraFabricacionVw b
	ON		a.IdFabricacion = b.IdFabricacion

	UPDATE  a
	SET		EstatusPedidoMP = j.NomEstatus
	FROM	#TraspasosManuales a
	INNER JOIN @tbPedidos i
	ON		a.Fabricacion	= i.IdFabricacion
	LEFT JOIN @tbEstatusFabricacion j
	ON		i.ClaEstatus = j.ClaEstatus

	UPDATE  a
	SET		EstatusPedidoOrigen = l.NomEstatus
	FROM	#TraspasosManuales a
	INNER JOIN @tbPedidos k
	ON		a.PedidoOrigen	= k.IdFabricacion
	LEFT JOIN @tbEstatusFabricacion l
	ON		k.ClaEstatus = l.ClaEstatus

	UPDATE	a
	SET		EsBitacora = 1
	FROM	#TraspasosManuales a
	WHERE	EXISTS (	SELECT	1
						FROM	OpeSch.OpeVtaBitFabricacionCambioPlanta b WITH(NOLOCK)
						WHERE	a.Fabricacion = b.IdFabricacionNueva
					)

	------------------------------------------------------------------------

    --Carga de Nivel Grid Detalle
    INSERT INTO #TraspasosManuales (
		NivelGrid,				EstatusSolicitud,			Renglon,				Producto,                
		Unidad,					CantPedida,					PrecioListaMP,			PrecioLista,             
		MotivoRechazo,			HechaPor,					ClaUbicacionSolicita,   ClaUbicacionSurte,      
		ClaEstatusSolicitud,    ClaEstatus,					ClaProducto,            ClaMotivoRechazo,        
		ClaMotivoAutomatico,    ClaRelacion,				Fabricacion,			PedidoOrigen,
		PesoTeorico
	)
    SELECT  NivelGrid               = 2,
            EstatusSolicitud        = CONVERT(VARCHAR(10),e.ClaEstatus) + ' - '  + LTRIM(RTRIM(e.NombreEstatus)),
            Renglon                 = b.IdRenglon,
            Producto                = CONVERT(VARCHAR(10),c.ClaveArticulo) + ' - '  + LTRIM(RTRIM(c.NomArticulo)),
            Unidad                  = d.NomCortoUnidad,
            CantPedida              = b.CantidadPedida,
            PrecioListaMP           = b.PrecioListaMP,
            PrecioLista             = b.PrecioLista,
            MotivoRechazo           = f.NomMotivoRechazoSolTraspaso,
            HechaPor                = a.HechaPor,
            ClaUbicacionSolicita    = a.ClaUbicacionSolicita,
            ClaUbicacionSurte       = a.ClaUbicacionSurte,
            ClaEstatusSolicitud     = a.ClaEstatusSolicitud,
            ClaEstatus              = e.ClaEstatus,
            ClaProducto             = b.ClaProducto,
            ClaMotivoRechazo        = f.ClaMotivoRechazoSolTraspaso,
            ClaMotivoAutomatico     = b.ClaMotivoAutomatico,
            ClaRelacion             = a.ClaRelacion,
            Fabricacion,            
            PedidoOrigen,
			c.PesoTeoricoKgs
    FROM    #TraspasosManuales a WITH(NOLOCK) 
    INNER JOIN  OpeSch.OpeTraSolicitudTraspasoDetVw b WITH(NOLOCK)  
        ON  a.ClaRelacion = b.IdSolicitudTraspaso
    INNER JOIN  OpeSch.OpeArtCatArticuloVw c WITH(NOLOCK)  
        ON  b.ClaProducto = c.ClaArticulo AND c.ClaTipoInventario = 1
    INNER JOIN  OpeSch.OpeArtCatUnidadVw d WITH(NOLOCK)  
        ON  c.ClaUnidadBase = d.ClaUnidad AND d.ClaTipoInventario = 1
    INNER JOIN  TiCatalogo.dbo.TiCatEstatus e WITH(NOLOCK)   
        ON  b.ClaEstatus = e.ClaEstatus AND e.ClaClasificacionEstatus = 1270105 AND ISNULL(e.BajaLogica, 0) = 0
    LEFT JOIN   OpeSch.OpeCatMotivoRechazoSolTraspasoVw f WITH(NOLOCK)  
        ON  ISNULL( b.ClaMotivoRechazo,b.ClaMotivoAutomatico ) = f.ClaMotivoRechazoSolTraspaso


	------------------------------------------------------------------------
	INSERT INTO @tbPedidosDet (IdFabricacion, ClaArticulo)
		SELECT DISTINCT a.Fabricacion, a.ClaProducto    
		FROM    #TraspasosManuales a WITH(NOLOCK) 
		WHERE	NivelGrid = 2
		AND		a.Fabricacion IS NOT NULL
		UNION
		SELECT DISTINCT a.PedidoOrigen, a.ClaProducto      
		FROM    #TraspasosManuales a WITH(NOLOCK) 
		WHERE	NivelGrid = 2
		AND		a.PedidoOrigen IS NOT NULL


	UPDATE	a
	SET		ClaEstatus = b.ClaEstatusFabricacion,
			FechaDesea = b.FechaDeseaCliente,
			CantidadSurtida = b.CantidadSurtida
	FROM	@tbPedidosDet a
	INNER JOIN DEAOFINET05.Ventas.Vtasch.VtaTraFabricacionDetVw b
	ON		a.IdFabricacion = b.IdFabricacion
	AND		a.ClaArticulo	= b.ClaArticulo

	IF @pnDebug = 1
		SELECT '' AS '@tbPedidosDet', * FROM @tbPedidosDet

	UPDATE  a
	SET		EstatusPedidoMPDet = j.NomEstatus
			,FechaDesea = i.FechaDesea
			,CantidadSurtida = ISNULL(i.CantidadSurtida,0.00)
			,KilosSurtidos	= ISNULL((i.CantidadSurtida * a.PesoTeorico), 0.00 )
	FROM	#TraspasosManuales a
	INNER JOIN @tbPedidosDet i
	ON		a.Fabricacion	= i.IdFabricacion
	AND		a.ClaProducto	= i.ClaArticulo
	LEFT JOIN @tbEstatusFabricacion j
	ON		i.ClaEstatus = j.ClaEstatus

	UPDATE  a
	SET		EstatusPedidoOrigenDet = l.NomEstatus
	FROM	#TraspasosManuales a
	INNER JOIN @tbPedidosDet k
	ON		a.PedidoOrigen	= k.IdFabricacion
	AND		a.ClaProducto	= k.ClaArticulo
	LEFT JOIN @tbEstatusFabricacion l
	ON		k.ClaEstatus = l.ClaEstatus

	------------------------------------------------------------------------
    
	--Retorno de Información Cargada

    --Captura de Información de Registro Existente de Traspaso a Nivel Encabezado
    SELECT  ColSolicitud            = a.Solicitud,
            ColFabricacion          = CASE WHEN NivelGrid=1 THEN a.Fabricacion ELSE NULL END,
            ColPedidoOrigen         = CASE WHEN NivelGrid=1 THEN a.PedidoOrigen ELSE NULL END,
            ColUbicacionSolicita    = a.UbicacionSolicita,
            ColUbicacionSurte       = a.UbicacionSurte,
            ColFechaCaptura         = a.FechaCaptura,
            ColEstatusSolicitud     = a.EstatusSolicitud,
            ColRenglon              = a.Renglon,
            ColProducto             = a.Producto,
            ColUnidad               = a.Unidad,
            ColCantPedida           = a.CantPedida,
            ColPrecioListaMP        = a.PrecioListaMP,
            ColPrecioLista          = a.PrecioLista,
            ColMotivoRechazo        = a.MotivoRechazo,
            ColHechaPor             = a.HechaPor,
            ColClaUbicacionSolicita = a.ClaUbicacionSolicita,
            ColClaUbicacionSurte    = a.ClaUbicacionSurte,
            ColClaEstatusSolicitud  = a.ClaEstatusSolicitud,
            ColClaEstatus           = a.ClaEstatus,
            ColClaProducto          = a.ClaProducto,
            ColClaMotivoRechazo     = a.ClaMotivoRechazo,
            ColClaMotivoAutomatico  = a.ClaMotivoAutomatico,
			ColNomProyecto			= a.NomProyecto,				
			ColNombreCliente		= a.NombreCliente,		
			ColNombreConsignado		= a.NombreConsignado,		
			ColEstatusPedidoMP		= a.EstatusPedidoMP,			
			ColEstatusPedidoOrigen	= a.EstatusPedidoOrigen,		
			ColEstatusPedidoMPDet	= a.EstatusPedidoMPDet,		
			ColEstatusPedidoOrigenDet =	a.EstatusPedidoOrigenDet,	
			ColFechaDesea			 = CONVERT(VARCHAR(10),a.FechaDesea, 103),
			ColCantSurtida			= a.CantidadSurtida,
			ColKilosSurtidos		= a.KilosSurtidos,
			EsBitacora				= ISNULL(a.EsBitacora,0)
    FROM    #TraspasosManuales a WITH(NOLOCK) 
    ORDER BY
            a.ClaRelacion DESC,
            a.NivelGrid ASC,
            ISNULL(a.Renglon,0) ASC

    DROP TABLE #TraspasosManuales

    SET NOCOUNT OFF       

	RETURN
END