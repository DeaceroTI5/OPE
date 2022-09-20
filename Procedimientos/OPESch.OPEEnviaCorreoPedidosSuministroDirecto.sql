USE Operacion
GO
ALTER PROCEDURE OPESch.OPEEnviaCorreoPedidosSuministroDirecto
	@pnClaUbicacion INT,
	@pnPrueba		INT = 0
AS
BEGIN
	-- EXEC OPESch.OPEEnviaCorreoPedidosSuministroDirecto 325, 1

	SET NOCOUNT ON

	SET LANGUAGE Spanish;
	
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

	
	DECLARE @DetalleCorreo	TABLE
	(
		 Ident			INT IDENTITY(1, 1)
		,HTML			VARCHAR(4000)
	)
	
	DECLARE	@tbResultado TABLE
	(
		  IdSolicitudTraspaso	INT
		, ClaUbicacionSolicita	INT
		, UbicacionSolicita		VARCHAR(60)
		, UbicacionSurte		VARCHAR(60)
		, NomProyecto			VARCHAR(60)
		, ClaPedidoOrigen		INT
		, ClaPedido				INT
	)

	DECLARE @tUbicacionSolicita TABLE
	(
		  Id					INT IDENTITY (1,1)
		, ClaUbicacionSolicita	INT
		, CuentasCorreo			VARCHAR(1000)
	)

	SELECT	@sAsunto = 'Notificación de Pedido de Suministro Directo'

	INSERT INTO @tbResultado (IdSolicitudTraspaso, ClaUbicacionSolicita, UbicacionSolicita, UbicacionSurte, NomProyecto, ClaPedidoOrigen, ClaPedido)
	SELECT	  a.IdSolicitudTraspaso
			, a.ClaUbicacionSolicita
			, UbicacionSolicita = CONVERT(VARCHAR(10),a.ClaUbicacionSolicita) +' - '+ c.NomUbicacion
			, UbicacionSurte	= CONVERT(VARCHAR(10),a.ClaUbicacionSurte) +' - '+ d.NomUbicacion 
			, b.NomProyecto
			, a.ClaPedidoOrigen
			, a.ClaPedido
	FROM	OpeSch.OpeTraSolicitudTraspasoEncVw a
	INNER JOIN OpeSch.OpeVtaCatProyectoVw b
	ON		a.ClaProyecto	= b.ClaProyecto
	INNER JOIN OpeSch.OpeTiCatUbicacionVw c
	ON		a.ClaUbicacionSolicita = c.ClaUbicacion
	INNER JOIN OpeSch.OpeTiCatUbicacionVw d
	ON		a.ClaUbicacionSurte = d.ClaUbicacion
	WHERE	EsSuministroDirecto = 1
--	AND		EsNotificado = 0
	
	--------------------------------------------------------------------------------------------

	--IF @pnPrueba = 1
	--	INSERT INTO @tbResultado (IdSolicitudTraspaso, ClaUbicacionSolicita, UbicacionSolicita, UbicacionSurte, NomProyecto, ClaPedidoOrigen, ClaPedido)
	--	VALUES	  (-1, 324,'324 - CEDI Virtual Aceria Cela', '7 - Acería Celaya', 'Proyecto', 1234, 56789)
	--			, (-1, 375,'375 - CEDI Virtual Aceria', '7 - Acería Celaya', 'Proyecto',5678,6789)
	--			, (-1, 324,'324 - CEDI Virtual Aceria Cela', '7 - Acería Celaya', 'Proyecto',0987, 4534)


	INSERT INTO @tUbicacionSolicita (ClaUbicacionSolicita)
	SELECT	DISTINCT ClaUbicacionSolicita
	FROM	@tbResultado


	IF @pnPrueba = 1
		SELECT '' AS '@tUbicacionSolicita', * FROM @tUbicacionSolicita

	UPDATE	a
	SET		CuentasCorreo = b.sValor1
	FROM	@tUbicacionSolicita a
	INNER JOIN OpeSch.OPETiCatConfiguracionVw b
	ON		a.ClaUbicacionSolicita = b.ClaUbicacion
	AND		ClaSistema = 127 
	AND		ClaConfiguracion = 1271221

	--- Borrar registros que no tienen correo configurado
	DELETE 
	FROM	@tbResultado 
	WHERE	IdSolicitudTraspaso IN (
				SELECT  IdSolicitudTraspaso
				FROM	@tbResultado a
				INNER JOIN @tUbicacionSolicita b
				ON		a.ClaUbicacionSolicita = b.ClaUbicacionSolicita
				WHERE	ISNULL(b.CuentasCorreo,'') = ''
			)

	--------------------------------------------------------------------------------------------

	SELECT	@nClaUbicacionSolicita = MIN(ClaUbicacionSolicita)
	FROM	@tbResultado

	WHILE @nClaUbicacionSolicita IS NOT NULL
	BEGIN
		SELECT	  @sCuerpo = NULL
				, @sCuentasCorreo = NULL
		
		DELETE FROM @DetalleCorreo
		--------------------------------------------------------------------------------------------
		SELECT	@sCuentasCorreo = CuentasCorreo
		FROM	@tUbicacionSolicita
		WHERE	ClaUbicacionSolicita = @nClaUbicacionSolicita

		IF @pnPrueba = 1
			SELECT @nClaUbicacionSolicita AS '@nClaUbicacionSolicita', @sCuentasCorreo AS '@sCuentasCorreo'
		
		--IF ISNULL(@sCuentasCorreo,'') = ''
		--BEGIN
		--	GOTO SALTO
		--END
		--------------------------------------------------------------------------------------------
		SELECT	@sCuerpo = 
		' <!DOCTYPE html>      
		<html>      
		<head>      
		<title>Page Title</title>      
		</head>      

		<body>      
		 <FONT color="Black" FACE="verdana" style="font-family: verdana; font-size: 12pt"><p><strong>Notificación:</strong></p></FONT>    
		<p>Listado de Pedidos de Suministro Directo</br> 
      
		<table class="ex" cellspacing="0" border="1" width="90%"  bgcolor="DarkBlue" >      
		  <tr>
		  <th WIDTH="10%">	<FONT COLOR=WHITE	style="font-family: verdana; font-size: 10pt">Ubicación solicita</th>  
		  <th WIDTH="10%">	<FONT COLOR=WHITE	style="font-family: verdana; font-size: 10pt">Ubicación surte</th>           
		  <th WIDTH="15%">	<FONT COLOR=WHITE	style="font-family: verdana; font-size: 10pt">Proyecto</th>            
		  <th WIDTH=" 4%">	<FONT COLOR=WHITE	style="font-family: verdana; font-size: 10pt">Pedido origen</th> 
		  <th WIDTH=" 4%">	<FONT COLOR=WHITE	style="font-family: verdana; font-size: 10pt">Pedido materia prima</th>     
		</tr>'

		INSERT INTO @DetalleCorreo (HTML)
		SELECT	'<tr>
				 <td bgcolor="#ffffcc" align="left"		style="font-family: verdana; font-size: 10pt">'	+ ISNULL(CAST(RTRIM(LTRIM(UbicacionSolicita)) AS VARCHAR), '') + '</td>  ' + 
				'<td bgcolor="#ffffcc" align="center"	style="font-family: verdana; font-size: 10pt">'	+ ISNULL(CAST(RTRIM(LTRIM(UbicacionSurte)) AS VARCHAR), '') + '</td>  ' + 
				'<td bgcolor="#ffffcc" align="left"		style="font-family: verdana; font-size: 10pt">'	+ ISNULL(CAST(RTRIM(LTRIM(NomProyecto)) AS VARCHAR), '') + '</td>  ' + 
				'<td bgcolor="#ffffcc" align="center"	style="font-family: verdana; font-size: 10pt">'	+ ISNULL(RTRIM(LTRIM(ClaPedidoOrigen)) , '') + '</td>  ' +	
				'<td bgcolor="#ffffcc" align="center"	style="font-family: verdana; font-size: 10pt">'	+ ISNULL(CAST(RTRIM(LTRIM(ClaPedido)) AS VARCHAR), '') + '</td>  ' + 	
				'</tr> ' AS Datos
		FROM	@tbResultado
		WHERE	ClaUbicacionSolicita = @nClaUbicacionSolicita

		--Para poner rows en blanco 
		UPDATE	@DetalleCorreo
		SET		HTML = REPLACE(HTML, 'bgcolor="#ffffcc"' , 'bgcolor="white"')
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

		SELECT	@sCuerpo = @sCuerpo + '</table><br><br> </body> </html>'
		--------------------------------------------------------------------------------------------
			   
		IF @pnPrueba = 1
		BEGIN
			SELECT @sAsunto AS '@sAsunto',  @sCuerpo AS 'Cuerpo', @sCuentasCorreo AS '@sCuentasCorreo', @sCuentaCopia AS '@sCuentaCopia', @sCuentaCopiaOculta AS '@sCuentaCopiaOculta'
			SELECT	* FROM @DetalleCorreo
			SELECT @sCuentasCorreo = 'hvalle@deacero.com' --,@sCuentaCopia = 'josmor@deacero.com', @sCuentaCopiaOculta = NULL
		END
		--------------------------------------------------------------------------------------------

		IF (SELECT COUNT(1) FROM @DetalleCorreo) > 0 AND ISNULL(@sCuentasCorreo, '') <> ''
		BEGIN
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
		
		--SALTO:
		
		SELECT	@nClaUbicacionSolicita = MIN(ClaUbicacionSolicita)
		FROM	@tbResultado
		WHERE	ClaUbicacionSolicita > @nClaUbicacionSolicita
	END

		
	--UPDATE	a
	--SET		EsNotificado = 1
	--FROM		OpeSch.OpeTraSolicitudTraspasoEncVw a WITH(NOLOCK)
	--INNER JOIN @tbResultado b 
	--ON		a.IdSolicitudTraspaso = b.IdSolicitudTraspaso

	SET NOCOUNT OFF
END
