USE Operacion
GO
-- EXEC SP_HELPTEXT 'OpeSch.OpeEstGeneradorPedidosEstimacion'
GO
CREATE PROCEDURE [OpeSch].[OpeEstGeneradorPedidosEstimacion]
	  @pnClaUsuarioMod		INT = 1000
	, @psNombrePcMod		VARCHAR(64) = 'JOB - EstimacionIngetek'
	, @pnDebug				TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	DECLARE	@nPlantaVirtual INT,
			@nConsecutivo	INT,
            @nUbicacion     INT,
            @nFabricacion   INT
	SELECT	@nPlantaVirtual = 365,
            @nConsecutivo   = NULL,
            @nUbicacion     = NULL,
            @nFabricacion   = NULL

    --  Obtener Fabricaciones Que Cumplen Criterio de AutoGeneración de Pedido Espejo
	DECLARE @tFabricaciones		TABLE (
			Consecutivo         INT IDENTITY(1,1),
            Ubicacion           INT,
            Cliente             INT,
            Proyecto            INT,
            DescripcionProyecto VARCHAR(500),
            FabriacionOriginal  INT,
            FabricacionEspejo   INT,
            Partidas            INT,
            PartidasSurtidas    INT,
            FabPlanCarga        INT
	)

	-- Carga de Tabla Variable de los pedidos activos pendientes de los proyectos de Estimaciones
	;WITH FabriacionesAplicantes AS
	(
		SELECT	  e.ClaPlanta				AS Planta
				, c.ClaClienteCuenta		AS Cliente
				, b.ClaProyecto				AS Proyecto
				, Descripcion		= LTRIM(RTRIM(CONVERT(VARCHAR(50), b.ClaProyecto))) + ' - ' + b.NomProyecto
				, f.IdFabricacion			AS FabricacionOri
				, h.idFabricacionEstimacion	AS FabricacionEsp
				, COUNT(g.NumeroRenglon)	AS Partidas
				, PartidasNoActivas	= SUM( CASE WHEN g.ClaEstatusFabricacion NOT IN (4,5) THEN 1 ELSE 0 END )
		FROM	OpeSch.OpeRelProyectoEstimacionVw a WITH(NOLOCK)
		INNER JOIN OpeSch.OpeVtaCatProyectoVw b WITH(NOLOCK)
		ON		a.ClaProyecto				= b.ClaProyecto
		INNER JOIN OpeSch.OpeVtaCatClienteCuentaVw c WITH(NOLOCK)
		ON		b.ClaClienteCuenta			= c.ClaClienteCuenta
		INNER JOIN OpeSch.OpeVtaRelFabricacionProyectoVw d WITH(NOLOCK)
		ON		a.ClaProyecto				= d.ClaProyecto
		INNER JOIN OpeSch.OpeTraFabricacionVw e WITH(NOLOCK)
		ON		d.IdFabricacion				= e.IdFabricacion
		INNER JOIN Ventas.VtaSch.VtaCTraFabricacionEnc f WITH(NOLOCK)
		ON		d.IdFabricacion				= f.IdFabricacion
		INNER JOIN Ventas.VtaSch.VtaCTraFabricacionDet g WITH(NOLOCK)
		ON		d.IdFabricacion				= g.IdFabricacion
		LEFT JOIN  OpeSch.OpeTraFabricacionEspejoEstimacion h WITH(NOLOCK)
		ON		d.IdFabricacion				= h.idFabricacionVenta
		AND		g.ClaArticulo				= h.ClaArticuloEstimacion        
		WHERE   a.EsEstimacion				= 1
		AND		e.ClaEstatus				= 1
		AND		e.ClaPlanta					NOT IN (@nPlantaVirtual)
		AND		h.idFabricacionEstimacion	IS NULL
		AND		b.ClaProyecto				NOT IN (21728)
		--AND		e.IdFabricacion			NOT IN ()
		GROUP BY 
				e.ClaPlanta, c.ClaClienteCuenta, b.ClaProyecto, b.NomProyecto, f.IdFabricacion, h.idFabricacionEstimacion
	)
	INSERT INTO @tFabricaciones
	( 
			  Ubicacion
			, Cliente
			, Proyecto
			, DescripcionProyecto
			, FabriacionOriginal
			, FabricacionEspejo
			, Partidas
			, PartidasSurtidas
			, FabPlanCarga 
	)
	SELECT	  a.Planta
			, a.Cliente
			, a.Proyecto
			, a.Descripcion
			, a.FabricacionOri
			, a.FabricacionEsp
			, a.Partidas
			, a.PartidasNoActivas
			, SUM( CASE WHEN c.ClaEstatusPlanCarga IN (0,1,2) THEN 1 ELSE 0 END )	-- 0-Capturado; 1-Impreso; 2-Facturado
	FROM	FabriacionesAplicantes a
	LEFT JOIN OpeSch.OpeTraPlanCargaDet b WITH(NOLOCK)
	ON		a.Planta			= b.ClaUbicacion
	AND		a.FabricacionOri	= b.IdFabricacion
	LEFT JOIN OpeSch.OpeTraPlanCarga c WITH(NOLOCK)
	ON		b.IdPlanCarga		= c.IdPlanCarga
	AND		b.ClaUbicacion		= c.ClaUbicacion 
	GROUP BY
			a.Planta, a.Cliente, a.Proyecto, a.Descripcion, a.FabricacionOri, a.FabricacionEsp, a.Partidas, a.PartidasNoActivas
	
	-- Impresion de Tabla Variable con Coincidencias
    IF @pnDebug = 1
		SELECT '' AS 'Tabla @tFabricaciones', * FROM @tFabricaciones
    
    -- Bucle Que Procesa la Generación de Pedidos Espejo Para Fabricaciones Almacenadas
    SELECT	@nConsecutivo = MIN( Consecutivo )
    FROM	@tFabricaciones

    WHILE	ISNULL( @nConsecutivo,0 ) <> 0
    BEGIN
        IF EXISTS (	SELECT  1    
                    FROM    @tFabricaciones
                    WHERE   Consecutivo		    = @nConsecutivo	
                    AND     Partidas		    > 0
                    AND     PartidasSurtidas    = 0
                    AND     FabPlanCarga	    = 0
				   )
        BEGIN
            SELECT	@nUbicacion		= Ubicacion, 
                    @nFabricacion	= FabriacionOriginal
            FROM	@tFabricaciones
            WHERE	Consecutivo		= @nConsecutivo	
            
            EXEC	OpeSch.OPE_CU550_Pag21_Boton_GeneraPedidoEspejo_Proc 
					  @PnClaUbicacion			= @nUbicacion
					, @PnIdFabricacion			= @nFabricacion
					, @PnClaUbicacionFabrica	= @nPlantaVirtual
					, @PnClaUsuarioMod			= @pnClaUsuarioMod
					, @PsNombrePcMod			= @psNombrePcMod

            UPDATE  a
            SET     a.FabricacionEspejo = (	SELECT  DISTINCT 
													b.idFabricacionEstimacion			
											FROM	OpeSch.OpeTraFabricacionEspejoEstimacion b 
                                            WHERE	b.idFabricacionVenta	    = @nFabricacion
                                            AND		b.ClaUbicacionEstimacion    = @nUbicacion
											)
            FROM    @tFabricaciones a
            WHERE   a.Consecutivo = @nConsecutivo	
            AND     a.FabriacionOriginal = @nFabricacion

            --  Impresion de Registro Procesado por Generación de Espejo
			IF  @pnDebug = 1
				SELECT '' AS 'Tabla @tFabricaciones', * 
				FROM	@tFabricaciones a
				WHERE   a.Consecutivo = @nConsecutivo	
				AND     a.FabriacionOriginal = @nFabricacion
        END

        SELECT	@nConsecutivo = MIN( Consecutivo )
        FROM	@tFabricaciones
        WHERE	Consecutivo > @nConsecutivo	
    END

    -- Proceso de Eliminacion de Fabricaciones sin poder generar Pedido Espejo
    DELETE FROM @tFabricaciones WHERE FabricacionEspejo IS NULL

    -- Impresion de Listado de Fabricaciones despues de DELETE de casos sin Pedido Espejo
	IF @pnDebug = 1
		SELECT '' AS 'Tabla @tFabricaciones (despues de DELETE)', * 
		FROM	@tFabricaciones a
	
    ------------------------------------------------------------------------------------------------------------
	-- /*Actualizacion Bitácora Pedidos de Estimaciones*/
	DECLARE @nIdBitacora	INT
	
	-- Consecutivo de Identificador de Bitacora
	SELECT	@nIdBitacora = ISNULL(MAX(IdBitacora),0)
	FROM	OpeSch.OpeBitFabricacionEstimacion

	INSERT INTO OpeSch.OpeBitFabricacionEstimacion(
			  ClaUbicacion				
			, IdBitacora
			, IdFabricacionOriginal
			, IdFabricacionEstimacion
			, IdFabricacionUnificado
			, IdFabricacionAgrupado
			, Estatus
			, KgsPedidaPU
			, KgsSurtidaPU
			, FechaRegistro
			, FechaUltimaMod
			, NombrePcMod
			, ClaUsuarioMod
	)
	
	SELECT	  ClaUbicacion				= a.Ubicacion
			, IdBitacora				= @nIdBitacora + ROW_NUMBER() OVER(ORDER BY a.Consecutivo ASC)
			, IdFabricacionOriginal		= a.FabriacionOriginal  
			, IdFabricacionEstimacion	= a.FabricacionEspejo 
			, IdFabricacionUnificado	= NULL
			, IdFabricacionAgrupado		= a.FabriacionOriginal
			, Estatus					= 1
			, KgsPedidaPU				= NULL
			, KgsSurtidaPU				= NULL
			, FechaRegistro				= GETDATE()
			, FechaUltimaMod			= GETDATE()
			, NombrePcMod				= @psNombrePcMod
			, ClaUsuarioMod				= @pnClaUsuarioMod       
	FROM	@tFabricaciones a
	------------------------------------------------------------------------------------------------------------
  
	-- Proceso de Notificación //NOTA: El proceso de notificación se basa en los correos registrados en la configuración 1271221, el default son correos del equipo de sistemas
    IF EXISTS ( SELECT  1    
                FROM    @tFabricaciones a
                WHERE   a.FabricacionEspejo IS NOT NULL )
    BEGIN    
        DECLARE	
				-- Parametros de Registro de Fabricacion
				  @nTUbicacion			INT
				, @sTProyecto			VARCHAR(500)
				, @nTFabricacionVentas	INT
				, @nTFabricacionEspejo	INT
				, @nTPartidas			INT
				-- Parametros de Cuerpo de Correo
				, @sMensaje				VARCHAR(MAX)
				, @sTableTagClose		VARCHAR(500)
				, @sHeaderList			VARCHAR(8000)
				, @sDetailList			VARCHAR(MAX)
				, @sHeaderMsg			VARCHAR(1000)
				, @sLink				VARCHAR(1000)
				, @nColor				INT
				, @sTableEncTagOpen		VARCHAR(800)
				, @sLink2				VARCHAR(1000)
				, @sDetailListEnc		VARCHAR(MAX)
        
		SELECT	  @nConsecutivo			= NULL

        SELECT	  @nTUbicacion			= NULL
				, @sTProyecto			= NULL
				, @nTFabricacionVentas	= NULL
				, @nTFabricacionEspejo	= NULL
				, @nTPartidas			= NULL

		SELECT	  @sMensaje			= ''
				, @sDetailList		= ''
				, @sDetailListEnc	= ''
				, @nColor			= 1;

        SELECT @sHeaderMsg = ' <!DOCTYPE html> 
								<html>
                                <head>
                                    <title></title>
                                        <style type="text/css">
                                            body {background-color:#ffffff;}'
                                            + '.header{font-family:Arial;color:#FFFFFF;background-color:#304f60;} TABLE{font-family:Helvetica;font-size:12px;color:#000000;}'
                                            + 'bodytext{font-family:Arial;color:#304f60;background-color:#000000;}'
                                            + '</style></head><body>';


        SELECT @sLink =	'<p>Listado de Fabriaciones AutoGeneradas para Proyectos de Estimación:</p>';
                                    
        SELECT @sLink2 =	'<p><b>NOTA:</b> Los números de pedido que se han compartido pueden tardar un máximo de 1 hora en verse reflejados en la planta,
                                            si se identifica que se ha superado este plazo y aun no se visualiza el pedido espejo compartido, favor de contactar al equipo de Sistemas.</p>'        
		
        SELECT @sHeaderList =	'<table cellspacing="0" border="1" width="90%">
								<tr class="header" style="font-size:11px">
									<th WIDTH="10%">Ubicación</th> 
									<th WIDTH="40%">Proyecto</td>
									<th WIDTH="20%">Fabricación Venta</td>
									<th WIDTH="20%">Fabricación Estimaciones</td>
									<th WIDTH="10%">Partidas</td>
								</tr>'

        SELECT @sTableTagClose = '</table><br><br>'

		-- Proceso De Notificación: Talleres
		DECLARE @tUbicacionesEstimacion TABLE
		(
			  Id			        INT IDENTITY(1,1)
			, ClaUbicacion	        INT
			, Destinatarios	        VARCHAR(400)
            , CopiaDestinatarios    VARCHAR(400)
		)

		DECLARE   @nUbicacionEspejo INT
				, @sDestinatarios	VARCHAR(400)
				, @sCopiaDestinatario VARCHAR(400)

		-- Ubicaciones con configuración activa (Notificacion de genereación de pedido espejo)
		INSERT INTO @tUbicacionesEstimacion (ClaUbicacion, Destinatarios, CopiaDestinatarios)
		SELECT DISTINCT 
				  a.Ubicacion
				, CASE WHEN ISNULL(sValor1,'') <> '' THEN  sValor1 ELSE sValor2 END
                , CASE WHEN ISNULL(sValor2,'') <> '' THEN  sValor2 ELSE 'josmor@deacero.com;hvalle@deacero.com;dcabrerah@deacero.com' END
		FROM	@tFabricaciones a
		INNER JOIN OPESch.OpeTiCatConfiguracionVw b
		ON		a.Ubicacion			= b.ClaUbicacion
		AND		b.ClaSistema		= 127
		AND		b.ClaConfiguracion	= 1271221
		WHERE   a.FabricacionEspejo IS NOT NULL
		AND		b.nValor1			= 1				    -- Configuración activa

		IF @pnDebug = 1
			SELECT '' AS 'tabla @tUbicacionesEstimacion', * FROM @tUbicacionesEstimacion

		SELECT	@nUbicacionEspejo = MIN(ClaUbicacion)
		FROM	@tUbicacionesEstimacion

		WHILE @nUbicacionEspejo IS NOT NULL
		BEGIN
			SELECT	  @nConsecutivo	        = NULL
					, @sMensaje			    = ''
					, @sDetailList		    = ''
					, @sDetailListEnc	    = ''
					, @nColor			    = 1
					, @sDestinatarios	    = ''
                    , @sCopiaDestinatario   = ''
		
			SELECT	@sDestinatarios     = Destinatarios,
               @sCopiaDestinatario = CopiaDestinatarios
			FROM	@tUbicacionesEstimacion
			WHERE	ClaUbicacion = @nUbicacionEspejo
		
			SELECT	@nConsecutivo = MIN( Consecutivo )
			FROM	@tFabricaciones
			WHERE   Ubicacion = @nUbicacionEspejo


			WHILE	ISNULL( @nConsecutivo,0 ) != 0
			BEGIN
				SELECT	@nTUbicacion		    = ISNULL(CONVERT(VARCHAR(10), Ubicacion), ''), 
						@sTProyecto			    = ISNULL(DescripcionProyecto, ''), 
						@nTFabricacionVentas    = ISNULL(CONVERT(VARCHAR(15), FabriacionOriginal), ''), 
						@nTFabricacionEspejo    = ISNULL(CONVERT(VARCHAR(15), FabricacionEspejo), ''), 
						@nTPartidas			    = ISNULL(CONVERT(VARCHAR(10), Partidas), '')
				FROM	@tFabricaciones
				WHERE	Ubicacion = @nUbicacionEspejo
				AND     Consecutivo = @nConsecutivo	

				IF @pnDebug = 1
					SELECT	  @nUbicacionEspejo AS '@tUbicacionesEstimacion', @nConsecutivo AS '@nConsecutivo',@nTUbicacion AS '@nTUbicacion', @sTProyecto AS '@sTProyecto', @nTFabricacionVentas AS '@nTFabricacionVentas'
							, @nTFabricacionEspejo AS '@nTFabricacionEspejo', @nTPartidas AS '@nTPartidas'			

				IF(@nColor % 2) = 0
				BEGIN
					SELECT @sDetailList = @sDetailList + '<tr style="background-color:lightgrey;font-size:11px">'
				END
				ELSE
				BEGIN
					SELECT @sDetailList = @sDetailList + '<tr style="font-size:11px">'
				END

				SELECT @sDetailList = @sDetailList + 
									'<td style="text-align:center">' + ISNULL(RTRIM(LTRIM(@nTUbicacion)), '') + '</td>' +
									'<td style="text-align:left">' + ISNULL(RTRIM(LTRIM(@sTProyecto)), '') + '</td>' +
									'<td style="text-align:center">' + ISNULL(RTRIM(LTRIM(@nTFabricacionVentas)), '') + '</td>' + 
									'<td style="text-align:center">' + ISNULL(RTRIM(LTRIM(@nTFabricacionEspejo)), '') + '</td>' +
									'<td style="text-align:center">' + ISNULL(RTRIM(LTRIM(@nTPartidas)), '') + '</td>' + 
									'</tr>'

				SELECT	@nConsecutivo = MIN( Consecutivo )
				FROM	@tFabricaciones
				WHERE	Ubicacion = @nUbicacionEspejo
				AND     Consecutivo > @nConsecutivo	

				SELECT @nColor = @nColor + 1;
			END	-- FIN WHILE @nConsecutivo

			SELECT @sMensaje =  @sHeaderMsg + @sLink + @sHeaderList + @sDetailList + @sTableTagClose + @sLink2 + '</body></html>'

			IF @pnDebug = 1
			BEGIN
				SELECT	@sDestinatarios AS '@sDestinatarios', @sMensaje AS '@sMensaje'
				SET		@sDestinatarios = 'josmor@deacero.com;hvalle@deacero.com;dcabrerah@deacero.com'  
			END

			EXEC msdb.dbo.sp_send_dbmail 
					@profile_name			= 'OPEEst Profile', 
					@recipients				= @sDestinatarios, 
					@copy_recipients		= @sCopiaDestinatario,
					@subject				= 'Notificación de Estimaciones: Pedidos Espejo AutoGenerados', 
					@body_format			= 'HTML', 
					@body					= @sMensaje,
					@importance				= 'HIGH',
					@exclude_query_output	= 1;

			SELECT	@nUbicacionEspejo = MIN(ClaUbicacion)
			FROM	@tUbicacionesEstimacion
			WHERE	ClaUbicacion > @nUbicacionEspejo
		END -- FIN WHILE @nUbicacionEspejo
	END -- FIN EXISTS
	
	SET NOCOUNT OFF
END