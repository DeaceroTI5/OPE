------Inicio: Transacción Generación de Pedidos Espejo------
BEGIN TRAN

DECLARE	  @nConsecutivo			INT
		, @nUbicacion			INT
		, @nFabricacion			INT
		, @nClaUsuarioMod		INT
		, @sNombrePcMod			VARCHAR(64)
		, @nFabricacionEspejo	INT
		, @pnDebug				TINYINT

	SELECT	  @nConsecutivo		= NULL
			, @nUbicacion		= NULL
			, @nFabricacion		= NULL
			, @nClaUsuarioMod	= 1000
			, @sNombrePcMod		= 'EstimacionIngetek'
			, @nFabricacionEspejo = NULL
			, @pnDebug			= 1

IF	1=1--AS
BEGIN
	SET NOCOUNT ON
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

	DECLARE @nPlantaVirtual INT
	SET @nPlantaVirtual = 365


	-- consulta los pedidos activos de los proyectos con Estimación 
	;WITH FabriacionesAplicantes AS
	(
		SELECT	  e.ClaPlanta				AS Planta
				, b.ClaCliente				AS Cliente
				, c.ClaProyecto				AS Proyecto
				, Descripcion		= LTRIM(RTRIM(CONVERT(VARCHAR(150), c.ClaProyecto))) + ' - ' + c.NomProyecto
				, f.IdFabricacion			AS FabricacionOri
				, h.idFabricacionEstimacion	AS FabricacionEsp
				, COUNT(g.NumeroRenglon)	AS Partidas
				, PartidasNoActivas	= SUM( CASE WHEN g.ClaEstatusFabricacion NOT IN (4,5) THEN 1 ELSE 0 END )
		FROM	OpeSch.OpeRelProyectoEstimacionVw a WITH(NOLOCK)
		INNER JOIN  OpeSch.OpeVtaCatClienteVw b WITH(NOLOCK)
		ON		b.ClaCliente			= a.ClaCliente
		INNER JOIN OpeSch.OpeVtaCatProyectoVw c WITH(NOLOCK)
		ON		c.ClaProyecto			= a.ClaProyecto
		INNER JOIN  OpeSch.OpeVtaRelFabricacionProyectoVw d WITH(NOLOCK)
		ON		a.ClaProyecto			= d.ClaProyecto
	--	ON		d.ClaProyecto			= c.ClaProyecto
		INNER JOIN OpeSch.OpeTraFabricacionVw e WITH(NOLOCK)
		ON		e.IdFabricacion			= d.IdFabricacion
		INNER JOIN  Ventas.VtaSch.VtaCTraFabricacionEnc f WITH(NOLOCK)
		ON		d.IdFabricacion			= f.IdFabricacion
	--	ON		f.IdFabricacion			= e.IdFabricacion
		INNER JOIN Ventas.VtaSch.VtaCTraFabricacionDet g WITH(NOLOCK)
		ON		g.IdFabricacion			= d.IdFabricacion
		LEFT JOIN OpeSch.OpeTraFabricacionEspejoEstimacion h WITH(NOLOCK)
		ON		d.IdFabricacion			= h.idFabricacionVenta
	--	ON		h.idFabricacionVenta	= f.IdFabricacion 
		AND		h.idFabricacionDetVenta	= g.NumeroRenglon        
		WHERE   a.EsEstimacion			= 1
		AND		e.ClaEstatus			= 1
		AND		e.ClaPlanta				NOT IN (@nPlantaVirtual)
		AND		e.IdFabricacion			NOT IN (23880920,23903151)
		AND		c.ClaProyecto			NOT IN (21728)
		AND		h.idFabricacionEstimacion IS NULL
		GROUP BY 
				e.ClaPlanta, b.ClaCliente, c.ClaProyecto, c.NomProyecto, f.IdFabricacion, h.idFabricacionEstimacion
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
	ON		b.ClaUbicacion	= a.Planta  
	AND		b.IdFabricacion = a.FabricacionOri 
	LEFT JOIN OpeSch.OpeTraPlanCarga c WITH(NOLOCK)
	ON		c.IdPlanCarga	= b.IdPlanCarga 
	AND		c.ClaUbicacion	= b.ClaUbicacion 
	GROUP BY
			a.Planta, a.Cliente, a.Proyecto, a.Descripcion, a.FabricacionOri, a.FabricacionEsp, a.Partidas, a.PartidasNoActivas
	
	--
    IF @pnDebug = 1
		SELECT '' AS 'Tabla @tFabricaciones', * FROM @tFabricaciones
    
    -- Bucle Que Procesa la Generación de Pedidos Espejo Para Fabricaciones Almacenadas
    SELECT	@nConsecutivo = MIN( Consecutivo )
    FROM	@tFabricaciones

    WHILE	ISNULL( @nConsecutivo,0 ) <> 0
    BEGIN
		-- SELECT ISNULL(FabriacionOriginal, 0), * FROM @tFabricaciones WHERE Consecutivo = @nConsecutivo AND Partidas > 0 AND PartidasSurtidas = 0 AND FabPlanCarga = 0

        IF EXISTS (	SELECT  1    
                    FROM    @tFabricaciones
                    WHERE   Consecutivo		= @nConsecutivo	
                    AND     Partidas		> 0
                    AND     PartidasSurtidas = 0
                    AND     FabPlanCarga	= 0
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
					, @PnClaUsuarioMod			= @nClaUsuarioMod
					, @PsNombrePcMod			= @sNombrePcMod

            UPDATE  a
            SET     a.FabricacionEspejo = (	SELECT DISTINCT 
													b.idFabricacionEstimacion			
											FROM	OpeSch.OpeTraFabricacionEspejoEstimacion b 
                                            WHERE	b.idFabricacionVenta	= @nFabricacion
                                            AND		b.ClaUbicacionEstimacion = @nUbicacion
											)
            FROM    @tFabricaciones a
            WHERE   a.Consecutivo = @nConsecutivo	
            AND     a.FabriacionOriginal = @nFabricacion


			IF @pnDebug = 1
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

	IF @pnDebug = 1
		SELECT '' AS 'Tabla @tFabricaciones (despues de DELETE)', * 
		FROM	@tFabricaciones a

    -- Proceso de Notificación //NOTA: Actualmente los Remitentes Es el Equipo de Sistemas, Posterior se Habilitara la Notificación Directa a los Talleres
    IF EXISTS ( SELECT  1    
                FROM    @tFabricaciones a
                WHERE   a.FabricacionEspejo IS NOT NULL )
    BEGIN    
        DECLARE	-- Control de Notificación   
				  @nTallerTlalnepantla	INT
				, @nTallerGarcia		INT
				, @nTallerMexicali		INT
				, @nTallerCancun		INT
				-- Parametros de Registro de Fabricacion
				, @nTUbicacion			INT
				, @sTProyecto			VARCHAR(500)
				, @nTFabricacionVentas	INT
				, @nTFabricacionEspejo	INT
				, @nTPartidas			INT
				-- Parametros de Cuerpo de Correo
				, @sMensaje				VARCHAR(MAX)
				, @sTableTagOpen		VARCHAR(800)
				, @sTableTagClose		VARCHAR(500)
				, @sHeaderPrinc			VARCHAR(8000)
				, @sHeaderList			VARCHAR(8000)
				, @sDetailList			VARCHAR(MAX)
				, @sTableTitulo			VARCHAR(500)
				, @sTABLETituloIni		VARCHAR(500)
				, @sHeaderMsg			VARCHAR(1000)
				, @sLink				VARCHAR(1000)
				, @nColor				INT
				, @sTableEncTagOpen		VARCHAR(800)
				, @sTableTagOpen2		VARCHAR(800)
				, @sTableEncTagOpen2	VARCHAR(800)
				, @sLink2				VARCHAR(1000)
				, @sDetailListEnc		VARCHAR(MAX)
        
		SELECT	  @nConsecutivo			= NULL
				, @nTallerTlalnepantla	= NULL
				, @nTallerGarcia		= NULL
				, @nTallerMexicali		= NULL
				, @nTallerCancun		= NULL

        SELECT	  @nTUbicacion			= NULL
				, @sTProyecto			= NULL
				, @nTFabricacionVentas	= NULL
				, @nTFabricacionEspejo	= NULL
				, @nTPartidas			= NULL

		SELECT	  @sMensaje			= ''
				, @sHeaderPrinc		= ''
				, @sDetailList		= ''
				, @sDetailListEnc	= ''
				, @nColor			= 1;

        SELECT @sHeaderMsg = '<html>
                                <head>
                                    <title></title>
                                        <style type="text/css">
                                            body {background-color:#ffffff;}'
                                            + '.header{font-family:Arial;color:#FFFFFF;background-color:#304f60;} TABLE{font-family:Helvetica;font-size:12px;color:#000000;}'
                                            + 'bodytext{font-family:Arial;color:#304f60;background-color:#000000;}'
                                            + '</style></head><body>';

        SELECT @sTableEncTagOpen = '<TABLE>';

        SELECT @sLink =	'<p>Se comparte el siguiente listado de Fabriaciones AutoGeneradas para Proyectos de Estimación:</p>';
                                    
        SELECT @sTableTagOpen = '<TABLE>';

        SELECT @sTableEncTagOpen2 = '<TABLE>';

        SELECT @sLink2 =	'<p>NOTA: Los números de pedido que se han compartido pueden tardar un máximo de 1 hora en verse reflejados en la planta,' 
                                            + ' si se identifica que se ha superado este plazo y aun no se visualiza el pedido espejo compartido, favor de contactar al equipo de Sistemas.</p>';
        SELECT @sTableTagOpen2 = '<TABLE>';

        SELECT @sHeaderList = '<tr class="header" style="font-size:11px">'+
                            '<td style="width:10;text-align:center">Ubicación</td>'+
                            '<td style="width:60;text-align:center">Proyecto</td>' +
                            '<td style="width:30;text-align:center">Fabricación Venta</td>' +
                            '<td style="width:30;text-align:center">Fabricación Estimaciones</td>' +
                            '<td style="width:10;text-align:center">Partidas</td>' +
                            '</tr>';

        SELECT @sTableTagClose = '</TABLE><tr><TABLE></tr></TABLE>';  

        SELECT @sTABLETitulo = '<tr class="header" style="font-weight:bold;font-size:13px">' +
                            '<td colspan="6" style="width:100%;text-align:LEFT">Fabriaciones de Estimación AutoGeneradas.</td></tr>'; 

        SELECT @sTABLETituloIni = '<tr class="bodytext" style="font-weight:bold;font-size:13px"></tr>'+
                                '<tr class="bodytext" style="font-weight:bold;font-size:8px"><td colspan="6" style="width:100%;text-align:LEFT">&nbsp;</td></tr>';


		-- Proceso De Notificación: Talleres
		DECLARE @tUbicacionesEspejo TABLE
		(
			  Id			INT IDENTITY(1,1)
			, ClaUbicacion	INT
			, Destinatarios	VARCHAR(400)
		)

		DECLARE   @nUbicacionEspejo INT
				, @sDestinatarios	VARCHAR(400)


		-- Ubicaciones con configuracion activa (Notificacion de genereacion de pedido espejo)
		INSERT INTO @tUbicacionesEspejo (ClaUbicacion, Destinatarios)
		SELECT DISTINCT 
				  a.Ubicacion
				, sValor1
		FROM	@tFabricaciones a
		INNER JOIN OPESch.OpeTiCatConfiguracionVw b
		ON		a.Ubicacion			= b.ClaUbicacion
		AND		b.ClaSistema		= 127
		AND		b.ClaConfiguracion	= 1271221
		WHERE   a.FabricacionEspejo IS NOT NULL
		AND		b.nValor1			= 1						-- Configuracion activa
		AND		(b.sValor1 IS NOT NULL OR b.sValor1	<> '')	-- Configuración con destinatarios

		IF @pnDebug = 1
			SELECT '' AS 'tabla @tUbicacionesEspejo', * FROM @tUbicacionesEspejo

		SELECT	@nUbicacionEspejo = MIN(ClaUbicacion)
		FROM	@tUbicacionesEspejo

		WHILE @nUbicacionEspejo IS NOT NULL
		BEGIN
			SELECT	  @nConsecutivo		= NULL
					, @sMensaje			= ''
					, @sHeaderPrinc		= ''
					, @sDetailList		= ''
					, @sDetailListEnc	= ''
					, @nColor			= 1
					, @sDestinatarios	= ''
		
			SELECT	@sDestinatarios = Destinatarios
			FROM	@tUbicacionesEspejo
			WHERE	ClaUbicacion = @nUbicacionEspejo
		
			SELECT	@nConsecutivo = MIN( Consecutivo )
			FROM	@tFabricaciones
			WHERE   Ubicacion = @nUbicacionEspejo


			WHILE	ISNULL( @nConsecutivo,0 ) != 0
			BEGIN
				SELECT	@nTUbicacion		= ISNULL(CONVERT(VARCHAR(10), Ubicacion), ''), 
						@sTProyecto			= ISNULL(DescripcionProyecto, ''), 
						@nTFabricacionVentas = ISNULL(CONVERT(VARCHAR(15), FabriacionOriginal), ''), 
						@nTFabricacionEspejo = ISNULL(CONVERT(VARCHAR(15), FabricacionEspejo), ''), 
						@nTPartidas			= ISNULL(CONVERT(VARCHAR(10), Partidas), '')
				FROM	@tFabricaciones
				WHERE	Ubicacion = @nUbicacionEspejo
				AND     Consecutivo = @nConsecutivo	

				IF @pnDebug = 1
					SELECT	  @nUbicacionEspejo AS '@tUbicacionesEspejo', @nConsecutivo AS '@nConsecutivo',@nTUbicacion AS '@nTUbicacion', @sTProyecto AS '@sTProyecto', @nTFabricacionVentas AS '@nTFabricacionVentas'
							, @nTFabricacionEspejo AS '@nTFabricacionEspejo', @nTPartidas AS '@nTPartidas'			

				IF(@nColor % 2) = 0
				BEGIN
					SELECT @sDetailList = @sDetailList + '<tr style="background-color:lightgrey;font-size:11px">' + 
														'<td style="text-align:center">' + ISNULL(RTRIM(LTRIM(@nTUbicacion)), '') + '</td>' +
														'<td style="text-align:left">' + ISNULL(RTRIM(LTRIM(@sTProyecto)), '') + '</td>' +
														'<td style="text-align:center">' + ISNULL(RTRIM(LTRIM(@nTFabricacionVentas)), '') + '</td>' + 
														'<td style="text-align:center">' + ISNULL(RTRIM(LTRIM(@nTFabricacionEspejo)), '') + '</td>' +
														'<td style="text-align:right">' + ISNULL(RTRIM(LTRIM(@nTPartidas)), '') + '</td>' + 
														'</tr>'
				END
				ELSE
				BEGIN
					SELECT @sDetailList = @sDetailList + '<tr style="font-size:11px">' + 
														'<td style="text-align:center">' + ISNULL(RTRIM(LTRIM(@nTUbicacion)), '') + '</td>' +
														'<td style="text-align:left">' + ISNULL(RTRIM(LTRIM(@sTProyecto)), '') + '</td>' +
														'<td style="text-align:center">' + ISNULL(RTRIM(LTRIM(@nTFabricacionVentas)), '') + '</td>' + 
														'<td style="text-align:center">' + ISNULL(RTRIM(LTRIM(@nTFabricacionEspejo)), '') + '</td>' +
														'<td style="text-align:right">' + ISNULL(RTRIM(LTRIM(@nTPartidas)), '') + '</td>' + 
														'</tr>'
				END

				SELECT	@nConsecutivo = MIN( Consecutivo )
				FROM	@tFabricaciones
				WHERE	Ubicacion = @nUbicacionEspejo
				AND     Consecutivo > @nConsecutivo	

				SELECT @nColor = @nColor + 1;
			END	-- FIN WHILE @nConsecutivo

			SELECT @sMensaje =  @sHeaderMsg + @sHeaderPrinc +
								@sTableEncTagOpen + @sLink +
								@sTableTagOpen + @sHeaderList + 
								@sDetailList + @sTableTagClose +
								@sTableEncTagOpen2 + @sLink2 + 
								@sTableTagOpen2; 

			IF @pnDebug = 1
			BEGIN
				SELECT @sDestinatarios AS '@sDestinatarios', @sMensaje AS '@sMensaje'

				SELECT @sDestinatarios = 'hvalle@deacero.com' -- josmor@deacero.com; 
			END

			EXEC msdb.dbo.sp_send_dbmail 
					@profile_name			= 'OPEEst Profile', 
					@recipients				= @sDestinatarios, 
					@copy_recipients		= 'josmor@deacero.com; lperaza@deacero.com',
					@subject				= 'Notificacion de Pedidos Espejo AutoGenerados', 
					@body_format			= 'HTML', 
					@body					= @sMensaje,
					@importance				= 'HIGH',
					@exclude_query_output	= 1;


			SELECT	@nUbicacionEspejo = MIN(ClaUbicacion)
			FROM	@tUbicacionesEspejo
			WHERE	ClaUbicacion > @nUbicacionEspejo
		END -- FIN WHILE @nUbicacionEspejo
	END -- FIN EXISTS
	
	SET NOCOUNT OFF
END

ROLLBACK TRAN
PRINT 'FIN TRANSATION'


--COMMIT TRAN
------Fin: Transacción Generación de Pedidos Espejo------