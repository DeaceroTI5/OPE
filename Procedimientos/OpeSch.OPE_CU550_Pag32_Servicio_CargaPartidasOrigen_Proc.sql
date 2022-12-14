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
	@psMensajeTraspaso			VARCHAR(MAX) = '' OUTPUT,
	@pnDebug					TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	--IF @@SERVERNAME = 'SRVDBDES01\ITKQA' SELECT @pnDebug = 1
	--IF @pnDebug = 1 
	--	SELECT 'OPE_CU550_Pag32_Servicio_CargaPartidasOrigen_Proc'
	
	SELECT @psMensajeTraspaso = ''

	DECLARE @tbCargaPartidasOrigen TABLE
	(
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
		, ClaProyecto			INT
		, ClaEstatusDet			INT
	)

	DECLARE @tbOtrasSolicitudes TABLE
	(
		  Id					INT IDENTITY(1,1)
		, ClaPedido				INT
		, ClaProducto			INT
		, ClaEstatus			INT
		, CantidadFabricacion	NUMERIC(22,4)
		, CantidadSolicitada	NUMERIC(22,4)
		, CantidadDisponible	NUMERIC(22,4)
	)

	DECLARE @DetalleCorreo	TABLE
	(
			 Ident		INT IDENTITY(1, 1)
			,HTML		VARCHAR(4000)
	)

	DECLARE	  @nCantidadDisponible	NUMERIC(22,4)
			, @smsj					VARCHAR(300)
			, @nRenglon				INT = 0
			, @nCont				INT




    IF ( EXISTS ( SELECT 1 FROM OpeSch.OpeTraSolicitudTraspasoEncVw WHERE IdSolicitudTraspaso = @pnClaSolicitud AND ClaPedidoOrigen IS NOT NULL AND ClaEstatusSolicitud IN (0) ) 
        AND @pnClaSolicitud > 0 AND @pnClaPedidoOrigen > 0 AND @pnClaTipoTraspaso IN (3,4) )
    BEGIN
		---- No ingresar los registros que superan la cantidad disponible (Suministro directo) 
		IF @pnClaPedidoOrigen IS NOT NULL AND @pnClaTipoTraspaso IN (3,4)
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
			, PrecioListaCPO		
			, PesoTeoricoCPO		
			, CantidadMinAgrupCPO	
			, EsMultiploCPO
			, ClaProyecto
			, ClaEstatusDet
		)
         SELECT  DISTINCT
                 FabricacionCPO      = a.IdFabricacion,
                 NoRenglonCPO        = b.IdFabricacionDet,
                 ClaProductoCPO      = c.ClaArticulo,
                 UnidadCPO           = d.NomCortoUnidad,
                 CantPedidaCPO       = ISNULL( b.CantPedida,0.00 ),
                 PrecioListaCPO      = ISNULL( b.PrecioLista,0.00 ),
                 PesoTeoricoCPO      = c.PesoTeoricoKgs,
                 CantidadMinAgrupCPO = ISNULL( i.CantidadMinAgrup,0.00 ),
                 EsMultiploCPO       = ISNULL( i.Multiplo,0 ),
				 ClaProyecto		= e.ClaProyecto,
				 ClaEstatusDet		= ISNULL(b.ClaEstatus,0)
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
         WHERE  a.IdFabricacion = @pnClaPedidoOrigen


		IF ISNULL( @pnClaTipoTraspaso,0 ) IN (3,4)
		BEGIN
			UPDATE	a
			SET		PrecioListaMPCPO     = ISNULL( ISNULL( j.PrecioMP,k.PrecioMP ),0.00 )
			FROM	@tbCargaPartidasOrigen a
			OUTER APPLY (
				SELECT	TOP 1 jj.PrecioMP
				FROM	DEAOFINET05.Ventas.VtaSch.VtaTraControlProyectoDet jj WITH(NOLOCK)
				WHERE	a.ClaProyecto		= jj.ClaProyecto 
				AND		a.ClaProductoCPO	= jj.ValorLlaveCriterio
				ORDER BY jj.FechaUltimaMod DESC
			) j
			OUTER APPLY (
				SELECT	TOP 1 kk.PrecioMP
				FROM	DEAOFINET05.Ventas.VtaSch.VtaTraControlProyectoDet kk WITH(NOLOCK)  
				WHERE	a.ClaProyecto		= kk.ClaProyecto 
				AND		a.PrecioListaCPO = kk.Precio
				ORDER BY kk.FechaUltimaMod DESC
			) k
			WHERE	ClaEstatusDet = 1
		END
		ELSE
		BEGIN
			UPDATE	a
			SET		PrecioListaMPCPO     =  0.00
			FROM	@tbCargaPartidasOrigen a
			WHERE	ClaEstatusDet = 1
		END


		IF @pnDebug = 1
			SELECT '' AS '@tbCargaPartidasOrigen', * FROM @tbCargaPartidasOrigen

		---- /* Mensaje Traspaso
		--------------------------------------------------------------------------
		DECLARE   @nOtrasSolicitudes TINYINT = 0
				, @nPedidosNoActivos TINYINT = 0
				, @sTabla2 VARCHAR(MAX) = '' 
		
		IF EXISTS (SELECT 1 FROM @tbOtrasSolicitudes WHERE	CantidadSolicitada > 0)
		BEGIN
			SELECT @nOtrasSolicitudes = 1
		END

		IF EXISTS (SELECT 1 FROM @tbCargaPartidasOrigen WHERE ClaEstatusDet <> 1 )
		BEGIN
			SELECT @nPedidosNoActivos = 1
		END

		IF ( ISNULL(@nOtrasSolicitudes,0) = 1 OR ISNULL(@nPedidosNoActivos,0) = 1 )
		BEGIN
			SELECT	@psMensajeTraspaso = 
			'<!DOCTYPE html>
			<html>
			<style type="text/css">
				.tabla{font-family:Arial;font-size:12px;color:#000000;}
				.header{color:#FFFFFF;background-color:#3dbab3;}
				.texto1{color=#000000" style="font-family: Arial; font-size: 10pt;}
				.centrar{text-align: center;}
				.izquierda{text-align: left;}
				.derecha{text-align: right;}
			</style>
			<body>'

			IF ISNULL(@nOtrasSolicitudes,0) = 1
			BEGIN
				SELECT @psMensajeTraspaso = ISNULL(@psMensajeTraspaso,'') +
					'<FONT class="texto1">
						<h5><strong>AVISO:</strong></h5>  
						<p>Las siguientes partidas del pedido Origen <b>'+CONVERT(VARCHAR(10),@pnClaPedidoOrigen)+'</b> se identificaron para otras solicitudes:</FONT></br></br>
					<table class="tabla" cellspacing="0" border="1" width="100%">
						<tr class="header">
						  <th WIDTH="5%">Pedido</th>
						  <th WIDTH="20%">Producto</th>
						  <th WIDTH="3%">Unidad</th>
						  <th WIDTH="4%">Cant. Pedida Cliente</th>
						  <th WIDTH="4%">Cant. Solicitada</th>
						  <th WIDTH="4%">Cant. Disponible</th>
						  <th WIDTH="6%">Etatus MP</th>
						</tr>'

				INSERT INTO @DetalleCorreo (HTML)
				SELECT	
						'<tr><td class="centrar" bgcolor="#bdbdbd">'	+ ISNULL(CAST(RTRIM(LTRIM(b.ClaPedido)) AS VARCHAR), '') + '</td>' +
							'<td class="izquierda" bgcolor="#bdbdbd">'	+ ISNULL(RTRIM(LTRIM(REPLACE(c.ClaveArticulo+' - '+ c.NomArticulo,'''',''))) , '') + '</td>' +
							'<td class="centrar" bgcolor="#bdbdbd">'	+ ISNULL(RTRIM(LTRIM(d.NomCortoUnidad)) , '') + '</td>' +
							'<td class="derecha" bgcolor="#bdbdbd">'	+ ISNULL(CAST(RTRIM(LTRIM(FORMAT(b.CantidadFabricacion,'###,###.####'))) AS VARCHAR), '') + '</td>' +
							'<td class="derecha" bgcolor="#bdbdbd">'	+ ISNULL(CAST(RTRIM(LTRIM(FORMAT(b.CantidadSolicitada,'###,###.####'))) AS VARCHAR), '') + '</td>' +
							'<td class="derecha" bgcolor="#bdbdbd">'	+ CASE WHEN b.CantidadDisponible = 0 THEN '0' ELSE ISNULL(CAST(RTRIM(LTRIM(FORMAT(b.CantidadDisponible,'###,###.####'))) AS VARCHAR), '') END + '</td>' +
							'<td class="izquierda" bgcolor="#bdbdbd">'	+ '&nbsp &nbsp &nbsp' + ISNULL(RTRIM(LTRIM(e.Descripcion)) , '') + '</td>' +
						'</tr>' AS Datos
				FROM	@tbCargaPartidasOrigen a
				INNER JOIN @tbOtrasSolicitudes b
				ON		a.ClaProductoCPO	= b.ClaProducto
				LEFT JOIN OpeSch.OpeArtCatArticuloVw c
				ON		a.ClaProductoCPO	= c.ClaArticulo
				LEFT JOIN  OpeSch.OpeArtCatUnidadVw d WITH(NOLOCK)  
				ON		c.ClaUnidadBase		= d.ClaUnidad 
				AND		d.ClaTipoInventario = 1
				INNER JOIN DEAOFINET05.Ventas.VtaSch.vtacatestatusfabricacionVw e
				ON		b.ClaEstatus		= e.ClaEstatus
				WHERE	a.ClaEstatusDet = 1
				AND		b.CantidadSolicitada > 0
				ORDER BY c.ClaveArticulo ASC

				--Para poner rows en blanco 
				UPDATE	@DetalleCorreo
				SET		HTML = REPLACE(HTML, 'bgcolor="#bdbdbd"' , 'bgcolor="white"')
				WHERE	(Ident % 2 = 0)
		     
				SELECT	@nCont = MIN(Ident)
				FROM	@DetalleCorreo

				WHILE @nCont IS NOT NULL
				BEGIN
					SELECT	@psMensajeTraspaso = @psMensajeTraspaso + HTML
					FROM	@DetalleCorreo
					WHERE	Ident = @nCont

					SELECT	@nCont = MIN(Ident)
					FROM	@DetalleCorreo
					WHERE	Ident > @nCont
				END

				SELECT	@psMensajeTraspaso = ISNULL(@psMensajeTraspaso,'') + '</table></br>'
			END -- @nOtrasSolicitudes = 1

			IF @nPedidosNoActivos = 1
			BEGIN
				DELETE FROM @DetalleCorreo
				SELECT @sTabla2 = ISNULL(@psMensajeTraspaso,'') +
					'<FONT class="texto1">
						<h5><strong>AVISO:</strong></h5>
						<p>Las siguientes partidas del pedido Origen <b>'+CONVERT(VARCHAR(10),@pnClaPedidoOrigen)+'</b> se encuentran inactivas:</FONT></br></br>
					<table class="tabla" cellspacing="0" border="1" width="80%">
						<tr class="header">
						  <th WIDTH="20%">Producto</th>
						  <th WIDTH="5%">Etatus Pedido</th>
						</tr>'

				INSERT INTO @DetalleCorreo (HTML)
				SELECT	
						'<tr><td class="izquierda" bgcolor="#bdbdbd">'	+ ISNULL(RTRIM(LTRIM(REPLACE(c.ClaveArticulo+' - '+ c.NomArticulo,'''',''))) , '') + '</td>' +
							'<td class="centrar" bgcolor="#bdbdbd">'	+ '&nbsp &nbsp &nbsp' + 'No Activo' + '</td>' +
						'</tr>' AS Datos
				FROM	@tbCargaPartidasOrigen a
				LEFT JOIN OpeSch.OpeArtCatArticuloVw c
				ON		a.ClaProductoCPO	= c.ClaArticulo
				WHERE	a.ClaEstatusDet <> 1
				ORDER BY a.NoRenglonCPO ASC

				--Para poner rows en blanco 
				UPDATE	@DetalleCorreo
				SET		HTML = REPLACE(HTML, 'bgcolor="#bdbdbd"' , 'bgcolor="white"')
				WHERE	(Ident % 2 = 0)
		     
				SELECT	@nCont = MIN(Ident)
				FROM	@DetalleCorreo

				WHILE @nCont IS NOT NULL
				BEGIN
					SELECT	@sTabla2 = @sTabla2 + HTML
					FROM	@DetalleCorreo
					WHERE	Ident = @nCont

					SELECT	@nCont = MIN(Ident)
					FROM	@DetalleCorreo
					WHERE	Ident > @nCont
				END

				SELECT	@psMensajeTraspaso = ISNULL(@sTabla2,'') + '</table>'
			END -- @nPedidosNoActivos = 1
		
			SELECT	@psMensajeTraspaso = ISNULL(@psMensajeTraspaso,'') + '</body></html>'
		END
		--------------------------------------------------------------------------*/
		------ Actualiza Cantidad Pedido
		UPDATE 	a
		SET		CantPedidaCPO  = (SELECT TOP 1 CantidadDisponible FROM @tbOtrasSolicitudes h WHERE a.ClaProductoCPO = h.ClaProducto)
		FROM	@tbCargaPartidasOrigen a
		INNER JOIN @tbOtrasSolicitudes b
		ON		a.ClaProductoCPO = b.ClaProducto
		WHERE	a.ClaEstatusDet = 1
		AND		b.CantidadSolicitada > 0


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
			WHERE	a.CantPedidaCPO > 0
			AND		ClaEstatusDet = 1
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
			WHERE	a.CantPedidaCPO > 0
			AND		ClaEstatusDet = 1
	
		END
    END

	SET NOCOUNT OFF    

	RETURN            

	-- Manejo de Errores              
	ABORT: 
    RAISERROR('El SP (OPE_CU550_Pag32_Servicio_CargaPartidasOrigen_Proc) no puede ser procesado.', 16, 1)        

END
