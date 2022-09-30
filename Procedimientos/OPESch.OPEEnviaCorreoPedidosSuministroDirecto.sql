USE Operacion
GO
	--IF @pnPrueba = 1
	--BEGIN
	--	INSERT INTO @tbResultado (ClaUbicacionSolicita, UbicacionSolicita, UbicacionSurte, NomProyecto, ClaPedidoVentas, ClaPedidoMP)
	--	VALUES	  
	--			  (324,'324 - CEDI Virtual Aceria Celaya Ingetek', '7 - Acería Celaya', 'Proyecto de Prueba', 2107179, 24202807)
	--			, (324,'324 - CEDI Virtual Aceria Celaya Ingetek', '7 - Acería Celaya', 'Proyecto de Prueba', 2108191, 24187662)
	--			, (324,'324 - CEDI Virtual Aceria Celaya Ingetek', '7 - Acería Celaya', 'Proyecto de Prueba', 2274198, 24192959)
	--			, (324,'324 - CEDI Virtual Aceria Celaya Ingetek', '7 - Acería Celaya', 'Proyecto de Prueba', 2274205, 24138077)
	--			, (324,'324 - CEDI Virtual Aceria Celaya Ingetek', '7 - Acería Celaya', 'Proyecto de Prueba', 2274198, 2274205)

	--	--- Estatus Ventas
	--	UPDATE	a
	--	SET		  ClaEstatusVentas		= b.ClaEstatusFabricacion
	--			, EstatusVentas			= CASE WHEN b.ClaEstatusFabricacion = 200 THEN 'Por Autorizar' ELSE LTRIM(RTRIM(c.Descripcion)) END
	--	FROM	@tbResultado a
	--	INNER JOIN DEAOFINET05.ventas.vtasch.vtatrafabricacion b WITH(NOLOCK)
	--	ON		a.ClaPedidoVentas		= b.IdFabricacion
	--	INNER JOIN DEAOFINET05.ventas.vtasch.vtacatestatusfabricacionVw c
	--	ON		b.ClaEstatusFabricacion = c.ClaEstatus
	--END
GO
ALTER PROCEDURE OPESch.OPEEnviaCorreoPedidosSuministroDirecto
	@pnPrueba		TINYINT = 0
AS
BEGIN
	-- EXEC OPESch.OPEEnviaCorreoPedidosSuministroDirecto 1

	SET NOCOUNT ON
--	SET LANGUAGE Spanish;
	
	DECLARE	 @sCuerpo				VARCHAR(MAX)
			,@sAsunto				VARCHAR(100)
			,@nCont					INT
			,@sCuentasCorreo		VARCHAR(1000)
			,@sCuentaCopia			VARCHAR(1000)
			,@sCuentaCopiaOculta	VARCHAR(1000)
			/*valores de Tabla*/
			,@sNomUbicacion			VARCHAR(50)
			,@nValorConfig			TINYINT		
			,@dFechaIni				DATETIME
			,@dFechaFin				DATETIME
			,@sServ					VARCHAR(20)
			,@nMostrarLongitud		TINYINT
			,@sConcepto				VARCHAR(10)
			,@nClaUbicacionSolicita INT
			,@sUbicacionSolicita	VARCHAR(50)



	DECLARE @DetalleCorreo	TABLE
	(
		 Ident			INT IDENTITY(1, 1)
		,HTML			VARCHAR(4000)
	)
	
	DECLARE	@tbResultado TABLE
	(
		  Id					INT IDENTITY(1,1)
		, IdSolicitudTraspaso	INT
		, ClaUbicacionSolicita	INT
		, UbicacionSolicita		VARCHAR(100)
		, UbicacionSurte		VARCHAR(100)
		, NomProyecto			VARCHAR(60)
		, ClaPedidoVentas		INT
		, ClaEstatusVentas		INT
		, EstatusVentas			VARCHAR(30)
		, ClaPedidoMP			INT
		, ClaEstatusPedidoMP	INT
		, EstatusPedidoMP		VARCHAR(150)
	)

	DECLARE @tUbicacionSolicita TABLE
	(
		  Id					INT IDENTITY (1,1)
		, ClaUbicacionSolicita	INT
		, CuentasCorreo			VARCHAR(1000)
		, CuentasCopia			VARCHAR(1000)
	)

	--------------------------------------------------------------------------------------------
	
	SELECT	  @sAsunto = 'Notificación de Generación de Pedidos Espejo de Suministro Directo'
			, @sCuentaCopiaOculta = 'hvalle@deacero.com'	

	INSERT INTO @tbResultado (IdSolicitudTraspaso, ClaUbicacionSolicita, UbicacionSolicita, UbicacionSurte, NomProyecto, ClaPedidoVentas, ClaPedidoMP
								,ClaEstatusVentas, EstatusVentas)
	SELECT	  a.IdSolicitudTraspaso
			, a.ClaUbicacionSolicita
			, UbicacionSolicita		= CONVERT(VARCHAR(10),a.ClaUbicacionSolicita) +' - '+ LTRIM(RTRIM(c.NomUbicacion))
			, UbicacionSurte		= CONVERT(VARCHAR(10),a.ClaUbicacionSurte) +' - '+ LTRIM(RTRIM(d.NomUbicacion))
			, NomProyecto			= LTRIM(RTRIM(b.NomProyecto))
			, a.ClaPedidoOrigen
			, a.ClaPedido
			, ClaEstatusVentas		= e.ClaEstatusFabricacion
			, EstatusVentas			= CASE WHEN e.ClaEstatusFabricacion = 200 THEN 'Por Autorizar' ELSE LTRIM(RTRIM(f.Descripcion)) END
	FROM	OpeSch.OpeTraSolicitudTraspasoEncVw a
	INNER JOIN OpeSch.OpeVtaCatProyectoVw b
	ON		a.ClaProyecto				= b.ClaProyecto
	INNER JOIN OpeSch.OpeTiCatUbicacionVw c
	ON		a.ClaUbicacionSolicita		= c.ClaUbicacion
	INNER JOIN OpeSch.OpeTiCatUbicacionVw d
	ON		a.ClaUbicacionSurte			= d.ClaUbicacion
	INNER JOIN DEAOFINET05.ventas.vtasch.vtatrafabricacion e WITH(NOLOCK)
	ON		a.ClaPedido					= e.IdFabricacion
	INNER JOIN DEAOFINET05.ventas.vtasch.vtacatestatusfabricacionVw f
	ON		e.ClaEstatusFabricacion		= f.ClaEstatus	
	WHERE	a.ClaEstatusSolicitud		= 1					--- Aprobada
	AND		a.ClaPedidoOrigen			IS NOT NULL
	AND		a.ClaPedido					IS NOT NULL
	AND		a.EsSuministroDirecto		= 1
	AND		a.EsNotificado				= 0
	AND		e.ClaEstatusFabricacion		IN (1,2,4,5,6)


	--*
	--*

	--- Estatus Pedido
	UPDATE	a
	SET		  ClaEstatusPedidoMP	= b.ClaEstatusFabricacion
			, EstatusPedidoMP		= CASE WHEN b.ClaEstatusFabricacion = 200 THEN 'Por Autorizar' ELSE LTRIM(RTRIM(c.Descripcion)) END
	FROM	@tbResultado a
	INNER JOIN DEAOFINET05.ventas.vtasch.vtatrafabricacion b WITH(NOLOCK)
	ON		a.ClaPedidoMP			= b.IdFabricacion
	INNER JOIN DEAOFINET05.ventas.vtasch.vtacatestatusfabricacionVw c
	ON		b.ClaEstatusFabricacion = c.ClaEstatus



	----- Omitir Registros Cancelados y Surtidos en ambas partes
	--DELETE
	--FROM	@tbResultado 
	--WHERE	(ClaEstatusVentas = 3 AND ClaEstatusPedidoMP = 3)	-- Cancelada
	--OR		(ClaEstatusVentas = 6 AND ClaEstatusPedidoMP = 6)	-- Surtido Total

	--------------------------------------------------------------------------------------------

	INSERT INTO @tUbicacionSolicita (ClaUbicacionSolicita)
	SELECT	DISTINCT ClaUbicacionSolicita
	FROM	@tbResultado



	--- Actualización de correos configurados por Ubicación Solicita
	UPDATE	a
	SET		  CuentasCorreo = b.sValor1
			, CuentasCopia	= b.sValor2
	FROM	@tUbicacionSolicita a
	INNER JOIN OpeSch.OPETiCatConfiguracionVw b
	ON		a.ClaUbicacionSolicita = b.ClaUbicacion
	AND		ClaSistema = 127 
	AND		ClaConfiguracion = 1271224


	IF @pnPrueba = 1
	BEGIN
		SELECT '' AS '@tbResultado 2', * FROM @tbResultado
		SELECT '' AS '@tUbicacionSolicita', * FROM @tUbicacionSolicita
	END


	--- Borrar registros que no tienen correo configurado
	DELETE 
	FROM	@tbResultado 
	WHERE	ClaUbicacionSolicita IN (
				SELECT  b.ClaUbicacionSolicita
				FROM	@tUbicacionSolicita b
				WHERE	ISNULL(b.CuentasCorreo,'') = ''
			)

	--------------------------------------------------------------------------------------------

	SELECT	@nClaUbicacionSolicita = MIN(ClaUbicacionSolicita)
	FROM	@tbResultado

	WHILE @nClaUbicacionSolicita IS NOT NULL
	BEGIN
		SELECT	  @sCuerpo			= ''
				, @sCuentasCorreo	= ''
				, @sCuentaCopia		= ''
				, @sUbicacionSolicita = ''
		
		DELETE FROM @DetalleCorreo
		--------------------------------------------------------------------------------------------
		SELECT	  @sCuentasCorreo	= CuentasCorreo
				, @sCuentaCopia		= CuentasCopia
		FROM	@tUbicacionSolicita
		WHERE	ClaUbicacionSolicita = @nClaUbicacionSolicita
	
		SELECT	@sUbicacionSolicita = NomUbicacion
		FROM	OpeSch.OpeTiCatUbicacionVw 
		WHERE	ClaUbicacion = @nClaUbicacionSolicita
		
		
		--------------------------------------------------------------------------------------------
		SELECT	@sCuerpo = 
		' <!DOCTYPE html>      
		<html>      
		<head>      
		<title>Page Title</title>      
		</head>
		
		<style type="text/css">
			body {background-color:#ffffff;}
			.header{font-family:Arial;color:#FFFFFF;background-color:#304f60;} 
			TABLE{font-family:Helvetica;font-size:12px;color:#000000;}
			bodytext{font-family:Arial;color:#304f60;background-color:#000000;}
		</style>

		<body>      
		 <FONT color="Black" FACE="verdana" style="font-family: verdana; font-size: 12pt"><p><strong>Notificación:</strong></p></FONT>    
		<p>Nuevos pedidos Espejo generados para la ubicación '+@sUbicacionSolicita+'.</br> 
      
		<table cellspacing="0" border="1" width="90%">      
		  <tr class="header">
		  <th WIDTH=" 4%">	<FONT COLOR=WHITE	style="font-family: verdana; font-size: 10pt">Pedido venta</th> 
		  <th WIDTH=" 10%">	<FONT COLOR=WHITE	style="font-family: verdana; font-size: 10pt">Estatus</th>
		  <th WIDTH=" 4%">	<FONT COLOR=WHITE	style="font-family: verdana; font-size: 10pt">Pedido materia prima</th> 		  
		  <th WIDTH=" 10%">	<FONT COLOR=WHITE	style="font-family: verdana; font-size: 10pt">Estatus</th>
		  <th WIDTH="15%">	<FONT COLOR=WHITE	style="font-family: verdana; font-size: 10pt">Ubicación solicita</th>  
		  <th WIDTH="15%">	<FONT COLOR=WHITE	style="font-family: verdana; font-size: 10pt">Ubicación surte</th>           
		  <th WIDTH="20%">	<FONT COLOR=WHITE	style="font-family: verdana; font-size: 10pt">Proyecto</th>            
		</tr>'

		INSERT INTO @DetalleCorreo (HTML)
		SELECT	'<tr>
				 <td bgcolor="lightgrey" align="center"	style="font-family: verdana; font-size: 10pt">'	+ ISNULL(CAST(RTRIM(LTRIM(ClaPedidoVentas)) AS VARCHAR), '')	+ '</td>  ' +
				 CASE WHEN ClaEstatusVentas = 3 
					THEN '<td bgcolor="lightgrey" align="left"	style="font-family: verdana; font-size: 10pt; color: Red">'	+ ISNULL(RTRIM(LTRIM(EstatusVentas)) , '')	+ '</td>  ' 
					ELSE '<td bgcolor="lightgrey" align="left"	style="font-family: verdana; font-size: 10pt">'	+ ISNULL(RTRIM(LTRIM(EstatusVentas)) , '')				+ '</td>  ' END + 
				
				'<td bgcolor="lightgrey" align="center"	style="font-family: verdana; font-size: 10pt">'	+ ISNULL(CAST(RTRIM(LTRIM(ClaPedidoMP)) AS VARCHAR), '')		+ '</td>  ' + 	
				CASE WHEN  ClaEstatusPedidoMP = 3
					THEN '<td bgcolor="lightgrey" align="left"	style="font-family: verdana; font-size: 10pt; color: Red">'	+ ISNULL(RTRIM(LTRIM(EstatusPedidoMP)) , '')+ '</td>  '
					ELSE '<td bgcolor="lightgrey" align="left"	style="font-family: verdana; font-size: 10pt">'	+ ISNULL(RTRIM(LTRIM(EstatusPedidoMP)) , '')			+ '</td>  '	END	+
					
				'<td bgcolor="lightgrey" align="left"	style="font-family: verdana; font-size: 10pt">'	+ ISNULL(RTRIM(LTRIM(UbicacionSolicita)) , '')					+ '</td>  ' + 
				'<td bgcolor="lightgrey" align="left"	style="font-family: verdana; font-size: 10pt">'	+ ISNULL(RTRIM(LTRIM(UbicacionSurte)) , '')						+ '</td>  ' + 
				'<td bgcolor="lightgrey" align="left"	style="font-family: verdana; font-size: 10pt">'	+ ISNULL(RTRIM(LTRIM(NomProyecto)) , '')						+ '</td>  ' + 
				'</tr> ' AS Datos
		FROM	@tbResultado
		WHERE	ClaUbicacionSolicita = @nClaUbicacionSolicita
		ORDER BY ClaPedidoVentas ASC


		--Para poner rows en blanco 
		UPDATE	@DetalleCorreo
		SET		HTML = REPLACE(HTML, 'bgcolor="lightgrey"' , 'bgcolor="white"')
		WHERE	(Ident % 2 = 0)
		     
		SELECT	@nCont = MIN(Ident)
		FROM	@DetalleCorreo

		WHILE @nCont IS NOT NULL
		BEGIN
			SELECT	@sCuerpo = @sCuerpo + HTML
			FROM	@DetalleCorreo
			WHERE	Ident = @nCont

			SELECT	@nCont = MIN(Ident)
			FROM	@DetalleCorreo
			WHERE	Ident > @nCont
		END

		SELECT	@sCuerpo = @sCuerpo + '</table><br><br> 
		</body> </html>'
--		<a href="http://appitknet04:2243/Pages/OPE_CU550_Pag35.aspx?wu='+CONVERT(VARCHAR(10),@nClaUbicacionSolicita)+'&CmbEstatusSolicitud=1&CmbPlantaPide='+CONVERT(VARCHAR(10),@nClaUbicacionSolicita)+'&OnSearch=1"> Consulta de Traspasos Manuales </a></p><br><br>		

			--------------------------------------------------------------------------------------------
		IF @pnPrueba = 1
		BEGIN
			SELECT  @nClaUbicacionSolicita AS '@nClaUbicacionSolicita', @sAsunto AS '@sAsunto',  @sCuerpo AS 'Cuerpo', @sCuentasCorreo AS '@sCuentasCorreo', @sCuentaCopia AS '@sCuentaCopia', @sCuentaCopiaOculta AS '@sCuentaCopiaOculta'
			SELECT	* FROM @DetalleCorreo
			SELECT @sCuentasCorreo = 'hvalle@deacero.com' ,@sCuentaCopia = ''--'josmor@deacero.com', @sCuentaCopiaOculta = ''
		END
		--------------------------------------------------------------------------------------------

		IF (SELECT COUNT(1) FROM @DetalleCorreo) > 0 AND ISNULL(@sCuentasCorreo, '') <> ''
		BEGIN
				EXECUTE AS LOGIN = 'sa'
				EXEC msdb.dbo.sp_send_dbmail 
					 @profile_name			= 'OPESuministroDirecto'
					,@recipients			= @sCuentasCorreo
					,@copy_recipients		= @sCuentaCopia
					,@blind_copy_recipients = @sCuentaCopiaOculta
					,@importance			= 'NORMAL'	--'HIGH'
					,@subject				= @sAsunto
					,@body					= @sCuerpo
					,@body_format			= 'HTML'
					,@file_attachments		= NULL
				--	,@exclude_query_output	= 1
		END
		

		SELECT	@nClaUbicacionSolicita = MIN(ClaUbicacionSolicita)
		FROM	@tbResultado
		WHERE	ClaUbicacionSolicita > @nClaUbicacionSolicita
	END


	UPDATE	a
	SET		EsNotificado = 1
	FROM	OpeSch.OpeTraSolicitudTraspasoEnc a WITH(NOLOCK)
	INNER JOIN @tbResultado b
	ON		a.IdSolicitudTraspaso = b.IdSolicitudTraspaso


	SET NOCOUNT OFF
END
