USE Operacion
GO
-- 'OpeSch.OPE_CU550_Pag32_Servicio_CargaPartidasOrigen_Proc'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_Servicio_CargaPartidasOrigen_Proc
    @pnClaSolicitud             INT, --Clave de Solicitud de Traspaso Manual 
    @pnClaPedidoOrigen          INT,
    @pnClaTipoTraspaso          INT,
    @pnClaUsuarioMod            INT, --Usuario Autorizador
    @psNombrePcMod              VARCHAR(64),
	@pnDebug					TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	IF @pnDebug = 1 
		SELECT 'OPE_CU550_Pag32_Servicio_CargaPartidasOrigen_Proc'


	DECLARE @tbCargaPartidasOrigen TABLE(
		  Id					INT IDENTITY(1,1)
		, FabricacionCPO		INT
		, NoRenglonCPO			INT
		, ClaProductoCPO		INT
		, UnidadCPO				VARCHAR(20)
		, CantPedidaCPO			NUMERIC(22,4)
		, PrecioListaMPCPO		NUMERIC(25,4)
		, PrecioListaCPO		NUMERIC(22,4)
		, PesoTeoricoCPO		NUMERIC(22,7)
		, CantidadMinAgrupCPO	NUMERIC(18,4)
		, EsMultiploCPO			INT
	)

	DECLARE @tbOtrasSolicitudes TABLE(
		  Id					INT IDENTITY(1,1)
		, ClaPedido				INT
		, ClaProducto			INT
		, ClaEstatus			INT
		, CantidadFabricacion	NUMERIC(22,4)
		, CantidadSolicitada	NUMERIC(22,4)
		, CantidadDisponible	NUMERIC(22,4)
	)

	DECLARE	  @nCantidadDisponible	NUMERIC(22,4)
			, @smsj					VARCHAR(300)
			, @nRenglon				INT = 0

    IF ( EXISTS ( SELECT 1 FROM OpeSch.OpeTraSolicitudTraspasoEncVw WHERE IdSolicitudTraspaso = @pnClaSolicitud AND ClaPedidoOrigen IS NOT NULL AND ClaEstatusSolicitud IN (0) ) 
        AND @pnClaSolicitud > 0 AND @pnClaPedidoOrigen > 0 AND @pnClaTipoTraspaso = 3 )
    BEGIN
		---- No ingresar los registros que superan la cantidad disponible (Suministro directo) 
		IF @pnClaPedidoOrigen IS NOT NULL AND @pnClaTipoTraspaso = 3
		BEGIN
			---- CANTIDAD
			INSERT INTO @tbOtrasSolicitudes (ClaPedido, ClaProducto, ClaEstatus, CantidadFabricacion, CantidadSolicitada, CantidadDisponible)
			EXEC OpeSch.OPE_CU550_Pag32_ValidaCantidadPedidoOrigenProc
				  @pnClaPedidoOrigen	= @pnClaPedidoOrigen
				, @pnClaSolicitud		= @pnClaSolicitud
				, @pnClaArticulo		= NULL

			IF @pnDebug = 1
				SELECT '' AS '@tbOtrasSolicitudes', * FROM @tbOtrasSolicitudes
		END

        SELECT  @nRenglon = MAX(b.IdRenglon) 
        FROM    OpeSch.OpeTraSolicitudTraspasoEncVw a
        INNER JOIN OpeSch.OpeTraSolicitudTraspasoDetVw b   
            ON  a.IdSolicitudTraspaso = b.IdSolicitudTraspaso 
        WHERE   a.IdSolicitudTraspaso = @pnClaSolicitud

        SELECT  @nRenglon = ISNULL( @nRenglon,0 )


		INSERT INTO @tbCargaPartidasOrigen (
			  FabricacionCPO		
			, NoRenglonCPO			
			, ClaProductoCPO		
			, UnidadCPO				
			, CantPedidaCPO			
			, PrecioListaMPCPO		
			, PrecioListaCPO		
			, PesoTeoricoCPO		
			, CantidadMinAgrupCPO	
			, EsMultiploCPO
		)
         SELECT  DISTINCT
                 FabricacionCPO      = a.IdFabricacion,
                 NoRenglonCPO        = b.IdFabricacionDet,
                 ClaProductoCPO      = c.ClaArticulo,
                 UnidadCPO           = d.NomCortoUnidad,
                 CantPedidaCPO       = ISNULL( b.CantPedida,0.00 ),
                 PrecioListaMPCPO    = ( CASE
                                             WHEN ISNULL( @pnClaTipoTraspaso,0 ) = 3
                                             THEN ISNULL( ISNULL( j.PrecioMP,k.PrecioMP ),0.00 )
                                             ELSE 0.00
                                         END),
                 PrecioListaCPO      = ISNULL( b.PrecioLista,0.00 ),
                 PesoTeoricoCPO      = c.PesoTeoricoKgs,
                 CantidadMinAgrupCPO = ISNULL( i.CantidadMinAgrup,0.00 ),
                 EsMultiploCPO       = ISNULL( i.Multiplo,0 )
         FROM    OpeSch.OpeTraFabricacionVw a WITH(NOLOCK)  
         INNER JOIN  OpeSch.OpeTraFabricacionDetVw b WITH(NOLOCK)  
             ON  a.IdFabricacion = b.IdFabricacion
         INNER JOIN  OpeSch.OpeArtCatArticuloVw c WITH(NOLOCK)  
             ON  b.ClaArticulo = c.ClaArticulo AND c.ClaTipoInventario = 1
         INNER JOIN  OpeSch.OpeArtCatUnidadVw d WITH(NOLOCK)  
             ON  c.ClaUnidadBase = d.ClaUnidad AND d.ClaTipoInventario = 1
         INNER JOIN  OpeSch.OpeVtaRelFabricacionProyectoVw e WITH(NOLOCK)  
             ON  a.IdFabricacion = e.IdFabricacion
         INNER JOIN  OpeSch.OpeVtaCatProyectoVw f WITH(NOLOCK)  
             ON  e.ClaProyecto = f.ClaProyecto
         LEFT JOIN   OpeSch.OpeManCatArticuloDimensionVw i WITH(NOLOCK)  
             ON  b.ClaArticulo = i.ClaArticulo
         LEFT JOIN   DEAOFINET05.Ventas.VtaSch.VtaTraControlProyectoDet j WITH(NOLOCK)  
             ON  f.ClaProyecto = j.ClaProyecto AND b.ClaArticulo = j.ValorLlaveCriterio 
         LEFT JOIN   DEAOFINET05.Ventas.VtaSch.VtaTraControlProyectoDet k WITH(NOLOCK)  
             ON  f.ClaProyecto = k.ClaProyecto AND b.PrecioLista = k.Precio
         WHERE   a.IdFabricacion = @pnClaPedidoOrigen
		 AND		b.ClaEstatus IN (1)


		IF @pnDebug = 1
			SELECT '' AS '@tbCargaPartidasOrigen', * FROM @tbCargaPartidasOrigen


		---- Acrualiza Cantidad Pedido
		UPDATE 	a
		SET		CantPedidaCPO  = CASE b.ClaEstatus WHEN   4 then a.CantPedidaCPO		-- pendiente Total
													WHEN  5 then b.CantidadDisponible	-- Surtido Parcial
													WHEN  6 then NULL					-- Surtido Total
								END
		FROM	@tbCargaPartidasOrigen a
		INNER JOIN @tbOtrasSolicitudes b
		ON		a.ClaProductoCPO = b.ClaProducto
		WHERE	CantidadSolicitada > 0


		 IF @pnDebug = 1
			SELECT '' AS '@tbCargaPartidasOrigen Diferencias', * FROM @tbCargaPartidasOrigen

        
		IF ISNULL(@pnDebug,0) = 0
		BEGIN
			INSERT INTO OpeSch.OpeTraSolicitudTraspasoDetVw
					(IdSolicitudTraspaso,       ClaProducto,            IdRenglon,              CantidadPedidaOrigen,       CantidadPedida,
					Unidad,                     PesoTeoricoKgs,         CantidadMinAgrup,       Multiplo,                   PrecioListaOrigen,
					PrecioListaMP,              PrecioLista,            ClaEstatus,             ClaMotivoRechazo,           ClaMotivoAutomatico,
					FechaUltimaMod,             ClaUsuarioMod,          NombrePcMod)
			SELECT  @pnClaSolicitud,            
					a.ClaProductoCPO,
					ROW_NUMBER() OVER (PARTITION BY a.FabricacionCPO ORDER BY a.ClaProductoCPO) + @nRenglon,
					a.CantPedidaCPO,
					a.CantPedidaCPO,
					a.UnidadCPO,
					a.PesoTeoricoCPO,
					a.CantidadMinAgrupCPO,
					a.EsMultiploCPO,
					a.PrecioListaCPO,
					a.PrecioListaMPCPO,
					a.PrecioListaMPCPO,
					0,
					0,
					0,
					GETDATE(),
					@pnClaUsuarioMod,
					@psNombrePcMod
			FROM    @tbCargaPartidasOrigen a
			WHERE	a.CantPedidaCPO IS NOT NULL
		END
		ELSE	-- Debug
		BEGIN
			SELECT  ClaSolicitud = @pnClaSolicitud,            
					a.ClaProductoCPO,
					ROW_NUMBER() OVER (PARTITION BY a.FabricacionCPO ORDER BY a.ClaProductoCPO) + @nRenglon,
					a.CantPedidaCPO,
					a.CantPedidaCPO,
					a.UnidadCPO,
					a.PesoTeoricoCPO,
					a.CantidadMinAgrupCPO,
					a.EsMultiploCPO,
					a.PrecioListaCPO,
					a.PrecioListaMPCPO,
					a.PrecioListaMPCPO
			FROM    @tbCargaPartidasOrigen a
			WHERE	a.CantPedidaCPO IS NOT NULL
	
		END
    END

	SET NOCOUNT OFF    

	RETURN            

	-- Manejo de Errores              
	ABORT: 
    RAISERROR('El SP (OPE_CU550_Pag32_Servicio_CargaPartidasOrigen_Proc) no puede ser procesado.', 16, 1)        

END
