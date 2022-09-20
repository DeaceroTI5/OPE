USE Operacion
GO
ALTER PROCEDURE OpeSch.Ope_CU550_Pag35_Grid_Traspasos_Sel
	  @pnClaUbicacion			INT
	, @pnIdSolicitud			INT
	, @pnClaPedido				INT
	, @ptFechaInicio			DATETIME
	, @ptFechaFinal				DATETIME
	, @pnClaUbicacionSolicita	INT
	, @pnClaUbicacionSurte		INT
	, @psVerTraspasos			VARCHAR(300)  -- 1.Pendientes, 2.Autorizados, 3.Rechazados, 4.Cancelados, 5.Automáticos    
	, @pnVerAutomaticos			INT = 0		-- BORRAR
	, @pnClaUsuarioMod			INT 
	, @pnDebug					TINYINT = 0
 AS
 BEGIN
	SET NOCOUNT ON

    
   CREATE TABLE #TblResultados (
	  Id						INT IDENTITY(1,1)
	, SelRow					TINYINT
	, ColIdSolicitudTraspaso	INT
	, ColIdSolicitudVista		VARCHAR(20) NULL
	, ColClaPedido				INT NULL
	, ClaUbicacion				INT NULL
	, NomUbicacion				VARCHAR(100) NULL
	, ClaTipoUbicacion			INT NULL
	, ClaUbicacionSurte			INT NULL
	, NomUbicacionSurte			VARCHAR(100) NULL
	, FechaDesea				DATETIME NULL
	, FechaCaptura				DATETIME NULL
	, ClaEstatus				INT NULL
	, Estatus					VARCHAR(15) NULL
	, ClaProducto				INT NULL
	, Producto					VARCHAR(200) NULL
	, IdRenglon					INT NULL
	, CantidadPedida			NUMERIC(22,2) NULL
	, ColAprobar				TINYINT NULL
	, ColRechazar				TINYINT NULL
	, Comentarios				VARCHAR(MAX) NULL
	, ClaMotivoRechazo			INT
	, NomMotivoRechazo			VARCHAR(300)
	, NivelGrid					TINYINT
	, EsNoActualizable			INT NULL
	, EsAutomatico				TINYINT
	, Accion					TINYINT
	, EstatusPedido				VARCHAR(25)
	, Unidad					VARCHAR(15)
	, ColPedido					INT
	, ClaUsuarioMod				INT
	, EsRojo					TINYINT
	, Autorizacion				VARCHAR(15)
	, ClaUsuarioAprob			INT  
	, EsConsumoInterno			INT  
   )
   
    DECLARE @tEstatusSolicitudes TABLE(
		  Id			INT IDENTITY(1,1)
		, ClaEstatus	INT
        , DescEstatus	VARCHAR(60)
	)

	DECLARE @tMotivoRechazoSol TABLE(
		  Id				INT IDENTITY(1,1)
		, ClaMotivoRechazo	INT
		, DescMotivoRechazo	VARCHAR(255)
	)

    DECLARE @tTraspasos TABLE(
		  Id			INT IDENTITY(1,1)
		, ClaEstatus	INT
	)

    INSERT INTO @tEstatusSolicitudes
    SELECT 0, 'Capturada'
    UNION
    SELECT 1, 'Aprobada'		
    UNION
    SELECT 2, 'Cancelada'
    UNION
    SELECT 3, 'Rechazada'

	INSERT INTO @tMotivoRechazoSol
	SELECT 1, 'Genera Inventario No Útil'
	UNION
	SELECT 2, 'Pedido Duplicado'
	UNION
	SELECT 3, 'Error de Captura'
	UNION
	SELECT 4, 'NO se tiene configurada TE'
	UNION
	SELECT 5, 'NO aprobada por Logística'
	UNION
	SELECT 6, 'No tiene configuración de cliente filial'
	UNION
	SELECT 7, 'Planta Pide Tiene Capacidad de Producción'

	SET @psVerTraspasos = ISNULL(@psVerTraspasos,'')
	IF @psVerTraspasos <> ''
	BEGIN
		INSERT INTO @tTraspasos
		SELECT DISTINCT LTRIM(RTRIM(string))
		FROM OpeSch.OPEUtiSplitStringFn(@psVerTraspasos, ',')
	END	
    
	INSERT INTO #TblResultados     
	SELECT	  SelRow					= NULL
			, ColIdSolicitudTraspaso	= a.IdSolicitudTraspaso
			, ColIdSolicitudVista		= Case when a.IdSolicitudTraspaso is null then '' else rtrim(ltrim(str(a.IdSolicitudTraspaso))) end
			, ColClaPedido				= Case when isnull(a.ClaPedido,0)<= 0 then NULL else a.ClaPedido end
			, ClaUbicacion				= a.ClaUbicacionSolicita 
			, NomUbicacion				= rtrim(ltrim(str(a.ClaUbicacionSolicita)))+'-'+rtrim(ltrim(e.NombreUbicacion))
			, e.ClaTipoUbicacion
			, a.ClaUbicacionSurte 
			, NomUbicacionSurte			= rtrim(ltrim(str(a.ClaUbicacionSurte)))+'-'+rtrim(ltrim(f.NombreUbicacion))
			, a.FechaDesea 
			, FechaCaptura				= a.FechaIns 
			, ClaEstatus				= a.ClaEstatusSolicitud
			, Estatus					= h.DescEstatus
			, ClaProducto				= NULL
			, Producto					= NULL
			, IdRenglon					= NULL
			, CantidadPedida			= NULL
			, ColAprobar				= 0
			, ColRechazar				= 0
			, Comentarios				= a.Observaciones -- a.ComentariosRechazo,    
			, ClaMotivoRechazo			= a.ClaMotivoRechazo
			, NomMotivoRechazo			= g.DescMotivoRechazo
			, 1
			, EsNoActualizable			= 1
			, EsAutomatico				= 0 
			, Accion					= 0
			, EstatusPedido				=  Case when isnull(a.ClaPedido,0) > 0 and a.ClaEstatusSolicitud = 1 then 'Autorizado'     
												when isnull(a.ClaPedido,0) > 0 and a.ClaEstatusSolicitud = 4 then 'Cancelado'     
												else NULL end    
			, Unidad					= NULL
			, ColPedido					= Case when isnull(a.ClaPedido,0)<= 0 then NULL else a.ClaPedido end
			, ClaUsuarioMod				= Case when isnull(a.ClaUsuarioIns,0) = 0 then 14 else a.ClaUsuarioIns end
			, EsRojo = 0    
			--, Case when isnull(a.ClaUsuarioAprob,0) = 0 and a.ClaUsuarioAprob IS NOT NULL then 'Automática'     
			--		   when isnull(a.ClaUsuarioAprob,0) > 0 then 'Manual'     
			--		   else '' end
			, Autorizacion				= 'Manual'
		--	, a.ClaUsuarioAprob
			, ClaUsuarioAprob			= a.ClaUsuarioIns
		--  , a.EsConsumoInterno
			, EsConsumoInterno			= 1
	FROM	OpeSch.OpeTraSolicitudTraspasoEncVw a    
	LEFT JOIN OPESch.OpetiCatUbicacionVw e 
	ON		e.ClaUbicacion = a.ClaUbicacionSolicita    
	LEFT JOIN OPESch.OpetiCatUbicacionVw f 
	ON		f.ClaUbicacion = a.ClaUbicacionSurte    
	LEFT JOIN @tMotivoRechazoSol g 
	ON		g.ClaMotivoRechazo = a.ClaMotivoRechazo    
	LEFT JOIN @tEstatusSolicitudes h 
	ON		h.ClaEstatus = a.ClaEstatusSolicitud    
	LEFT JOIN @tTraspasos i 
	ON		a.ClaEstatusSolicitud = i.ClaEstatus
	WHERE	(a.FechaIns BETWEEN @ptFechaInicio AND DATEADD(ss,-1,DATEADD(dd,1,@ptFechaFinal)))    
	AND		(a.ClaUbicacionSolicita  = @pnClaUbicacionSolicita OR ISNULL(@pnClaUbicacionSolicita,-1) = -1 )    
	AND		(a.ClaUbicacionSurte  = @pnClaUbicacionSurte OR ISNULL(@pnClaUbicacionSurte,-1) = -1 )
	AND		(@psVerTraspasos = '' OR (a.ClaEstatusSolicitud = i.ClaEstatus))    
	AND		(@pnIdSolicitud IS NULL or (a.IdSolicitudTraspaso = @pnIdSolicitud))    
	AND		(@pnClaPedido IS NULL or (a.ClaPedido = @pnClaPedido))    
	AND		(a.ClaUbicacionSolicita IN ( 
			SELECT	t1.ClaUbicacion 
			FROM	OpeSch.OpeCfgUsuarioTraspasoVw t1 
			WHERE	t1.ClaUsuario = @pnClaUsuarioMod 
			AND		t1.BajaLogica = 0 
			)	OR EXISTS ( 
				SELECT	1 
				FROM	OpeSch.OpeCfgUsuarioTraspasoVw t2 
				WHERE	t2.ClaUsuario = @pnClaUsuarioMod 
				AND		t2.ClaUbicacion = -1 
				AND		t2.ClaTipoUbicacion = -1 
				AND		t2.BajaLogica = 0
				)	OR EXISTS (
					SELECT	1 
					FROM	OpeSch.OpeCfgUsuarioTraspasoVw t3
					WHERE	t3.ClaUsuario = @pnClaUsuarioMod 
					AND		t3.ClaUbicacion = -1
					AND		t3.ClaTipoUbicacion = e.ClaTipoUbicacion  
					AND		t3.BajaLogica = 0
				)
			) 
 
	IF @pnDebug = 1
		SELECT '' AS '#TblResultados', * FROM #TblResultados
   
   INSERT INTO #TblResultados     
   SELECT	  SelRow					= NULL
			, ColIdSolicitudTraspaso	= a.IdSolicitudTraspaso
			, ColIdSolicitudVista		= ''
			, ColClaPedido				= NULL
			, ClaUbicacion				= NULL
			, NomUbicacion				= ''
			, ClaTipoUbicacion			= NULL
			, ClaUbicacionSurte			= NULL
			, NomUbicacionSurte			= ''
			, FechaDesea				= NULL
			, FechaCaptura				= NULL  
			, ClaEstatus				= b.ClaEstatus 
			, Estatus					= h.DescEstatus
			, ClaProducto				= b.ClaProducto 
			, Producto					= RTRIM(LTRIM(c.ClaveArticulo)) + '-' + RTRIM(LTRIM(c.NomArticulo))   
			, b.IdRenglon 
			, b.CantidadPedida 
			, ColAprobar				= 0
			, ColRechazar				= 0
			, Comentarios				= NULL    
			, ClaMotivoRechazo			= isnull(b.ClaMotivoRechazo,b.ClaMotivoAutomatico)
			, NomMotivoRechazo			= g.DescMotivoRechazo
			, 2
			, EsNoActualizable			= 1
			, EsAutomatico				= 0
			, Accion					= 0 
			, EstatusPedido				=  NULL
			, Unidad					= d.NomUnidad 
			, ColPedido					= CASE WHEN ISNULL(a.ClaPedido,0)<= 0 THEN NULL ELSE a.ClaPedido END
			, ClaUsuarioMod				= CASE WHEN ISNULL(a.ClaUsuarioIns,0) = 0 THEN 14 ELSE a.ClaUsuarioIns END
			, EsRojo					= 0 
			, '' 
			, 0      
			, EsConsumoInterno			= 1 --   , a.EsConsumoInterno
	FROM	OpeSch.OpeTraSolicitudTraspasoEncVw a    
    LEFT JOIN OpeSch.OpeTraSolicitudTraspasoDetVw b 
	ON		b.IdSolicitudTraspaso = a.IdSolicitudTraspaso    
    LEFT JOIN OpeSch.OpeArtCatArticuloVw c 
	ON		c.ClaArticulo = b.ClaProducto    
    LEFT JOIN OpeSch.OpeArtCatUnidadVw d 
	ON		d.ClaUnidad = c.ClaUnidadBase   -- c.ClaUnidadVenta     
    LEFT JOIN @tMotivoRechazoSol g 
	ON		g.ClaMotivoRechazo = ISNULL(b.ClaMotivoRechazo,b.ClaMotivoAutomatico)    
    LEFT JOIN @tEstatusSolicitudes h 
	ON		h.ClaEstatus = isnull(b.ClaEstatus,0)    
	LEFT JOIN @tTraspasos i 
	ON		a.ClaEstatusSolicitud = i.ClaEstatus
	WHERE	a.FechaIns BETWEEN @ptFechaInicio AND DATEADD(ss,-1,DATEADD(dd,1,@ptFechaFinal))    
	AND		(a.ClaUbicacionSolicita  = @pnClaUbicacionSolicita OR ISNULL(@pnClaUbicacionSolicita,-1) = -1 )    
	AND		(a.ClaUbicacionSurte  = @pnClaUbicacionSurte OR ISNULL(@pnClaUbicacionSurte,-1) = -1 )      
	AND		(a.IdSolicitudTraspaso = @pnIdSolicitud OR @pnIdSolicitud IS NULL )    
	AND		(a.ClaPedido = @pnClaPedido OR @pnClaPedido IS NULL )    
	AND		a.IdSolicitudTraspaso in ( select ColIdSolicitudTraspaso from #TblResultados  )   
	AND		(@psVerTraspasos = '' OR (a.ClaEstatusSolicitud = i.ClaEstatus))    
	
	
	IF @pnDebug = 1
		SELECT '' AS '#TblResultados', * FROM #TblResultados  
	--------------------------------------------------------------------------------------------------
	--UPDATE a SET EstatusPedido = 'Cancelado en Ventas'    
	--FROM #TblResultados a , AglogCancelacionTraspasos b    
	--WHERE b.ClaPedidoTraspaso = a.ColClaPedido    
	--AND b.ClaProducto = 0    
	--AND a.EstatusPedido = 'Autorizado'    
	--AND a.ClaProducto IS NULL    
   
	--UPDATE a 
	--SET		EstatusPedido = Case when a.ClaEstatus = 1 then 'Autorizado'     
 --                                    when a.ClaEstatus = 4 then 'Cancelado'     
 --                                    else NULL end    
 --  FROM #TblResultados a , ExtPedidoRen b    
 --  WHERE b.ClaPedido = a.ColClaPedido    
 --  AND b.ClaProducto = a.ClaProducto    
 --  AND b.IdRenglon = a.IdRenglon    
 --  AND a.ClaProducto IS NOT NULL    
    
 --  UPDATE a SET EstatusPedido = 'Cancelado en Ventas'    
 --  FROM #TblResultados a , AglogCancelacionTraspasos b    
 --  WHERE b.ClaPedidoTraspaso = a.ColClaPedido    
 --  AND b.ClaProducto = a.ClaProducto    
 --  AND a.EstatusPedido = 'Autorizado'    
 --  AND a.ClaProducto IS NOT NULL    

 
 --  UPDATE a SET NomMotivoRechazo = 'ERROR: ' + replace ( rtrim(ltrim(isnull(c.Error,''))), '4)', '' ) ,    
 --               EsRojo = Case when a.Estatus = 'Aprobada' then 1 else 0 end    
 --  FROM #TblResultados a , OpeSch.OpeTraSolicitudTraspasoEncVw b, AgBitErroresTraspasos c    
 --  WHERE b.IdSolicitudTraspaso = a.ColIdSolicitudTraspaso     
 --  AND c.ClaPedidoNeg = b.ClaPedidoNeg    
 --  AND c.ClaPeticion = b.ClaPeticion    
 --  AND c.ClaProducto = a.ClaProducto    
 ----  AND c.Error like '%Producto Sin Lista de Precios%'    
 --  AND a.NivelGrid = 2      
 --  -- 11 Feb 2016    
 --  UPDATE a SET NomMotivoRechazo = 'ERROR: ' + replace ( rtrim(ltrim(isnull(c.Error,''))), '4)', '' ) ,    
 --               EsRojo = Case when a.Estatus = 'Aprobada' then 1 else 0 end    
 --  FROM #TblResultados a , OpeSch.OpeTraSolicitudTraspasoEncVw b, AgBitErroresTraspasos c    
 --  WHERE b.IdSolicitudTraspaso = a.ColIdSolicitudTraspaso     
 --  AND c.ClaPedidoNeg = b.ClaPedidoNeg    
 --  AND c.ClaPeticion = b.ClaPeticion    
 --  AND c.Error like '%El pedido tiene productos sin descripción de factura en Ventas%'    
 --  AND a.NivelGrid = 1    
    

	--------------------------------------------------------------------------------------------------
	SELECT	  a.ColIdSolicitudVista 
			, a.ColClaPedido 
			, a.NomUbicacion 
			, a.NomUbicacionSurte 
			, a.FechaCaptura 
			, a.Estatus 
			, a.IdRenglon 
			, a.Producto 
			, a.Unidad 
			, a.CantidadPedida 
			, a.ColAprobar 
			, a.NomMotivoRechazo 
			, VerDetalle = Case when a.NivelGrid = 2 then 'Detalle' else '' end
			, HechaPor = rtrim(ltrim(b.NombreUsuario)) + ' ' + rtrim(ltrim(b.ApellidoPaterno)) + ' ' + rtrim(ltrim(b.ApellidoMaterno))
			, a.Comentarios 
			, a.EstatusPedido 
			, a.FechaDesea 
			, a.EsAutomatico 
			, a.Accion 
			, a.EsNoActualizable 
			, a.NivelGrid 
			, a.ColIdSolicitudTraspaso 
			, a.ClaUbicacion 
			, a.ClaUbicacionSurte 
			, a.ClaEstatus 
			, a.ClaProducto 
			, a.ClaMotivoRechazo  
			, EsAzul = Case when NivelGrid = 2 and a.Estatus = 'Aprobada' and EsRojo = 0 then 1 else 0 end
			, a.ColPedido 
			, EsRojo
			, Autorizacion
			, AprobadaPor = rtrim(ltrim(c.NombreUsuario)) + ' ' + rtrim(ltrim(c.ApellidoPaterno)) + ' ' + rtrim(ltrim(c.ApellidoMaterno))
			, a.EsConsumoInterno  
	FROM	#TblResultados a 
	LEFT OUTER JOIN TiCatUsuarioVw b 
	ON		b.ClaUsuario = a.ClaUsuarioMod    
	LEFT OUTER JOIN TiCatUsuarioVw c 
	ON		c.ClaUsuario = a.ClaUsuarioAprob    
	ORDER BY a.ColIdSolicitudTraspaso, a.IdRenglon
    

	DROP TABLE #TblResultados
	SET NOCOUNT OFF
 END