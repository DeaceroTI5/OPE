USE Operacion
GO

DECLARE   @pnDebug						TINYINT = 1
		, @pnIdFabricacionEstimacion	INT	= NULL
		, @pnClaUbicacionOrigen			INT = 325

BEGIN TRAN
BEGIN TRY

	DECLARE @tbEmbarqueEstimacion TABLE(
		  Id							INT IDENTITY(1,1)
		, IdFabricacionEstimacion		INT		
		, ClaUbicacionOrigen			INT
		, NumViaje  					INT
		, FacturaAlfanumericoVenta		VARCHAR(20)
		, IdBoletaVenta					INT
		, IdPlanCargaVenta				INT
		, IdViajeVenta					INT
		, FabricacionVenta				INT
		, Proyecto						VARCHAR(80)
		, EsTardio						TINYINT
	)

	DECLARE @tbGpoEmbarquesEstimacion TABLE(
		  Id					INT IDENTITY(1,1)
		, ClaUbicacionOrigen	INT
		, IdBoletaVenta			INT
		, IdPlanCargaVenta		INT
		, IdViajeVenta			INT
	)

	DECLARE @DetalleCorreo TABLE(
		 Ident	INT IDENTITY(1, 1)
		,HTML	VARCHAR(4000)
	)

	DECLARE @tUbicacionesEstimacion TABLE(
		  Id			        INT IDENTITY(1,1)
		, ClaUbicacion	        INT
		, Destinatarios	        VARCHAR(400)
        , CopiaDestinatarios    VARCHAR(400)
	)

	DECLARE   @nId					INT
			, @nClaUbicacionVenta	INT
			, @nIdBoletaVenta		INT
			, @nIdPlanCargaVenta	INT
			, @nIdViajeVenta		INT
			, @sCuerpo				VARCHAR(MAX)
			, @sAsunto				VARCHAR(100)
			, @nCont				INT
			, @sCuentasCorreo		VARCHAR(1000)
			, @sCuentaCopia			VARCHAR(1000)
			, @sCuentaCopiaOculta	VARCHAR(1000)
			, @sNomUbicacion		VARCHAR(50)

	--- /* Universo */
	INSERT INTO @tbEmbarqueEstimacion (
		  IdFabricacionEstimacion		, ClaUbicacionOrigen		, NumViaje  				
		, FacturaAlfanumericoVenta		, IdBoletaVenta				, IdPlanCargaVenta			
		, IdViajeVenta					, FabricacionVenta			, Proyecto
		, EsTardio
	)
    SELECT  DISTINCT
			  f.IdFabricacionEstimacion
			, a.ClaUbicacionOrigen
			, a.NumViaje  
			, g.FacturaAlfanumericoVenta
			, g.IdBoletaVenta
			, g.IdPlanCargaVenta
			, g.IdViajeVenta
			, g.FabricacionVenta
			, Proyecto						= CONVERT(VARCHAR(10),h.ClaProyecto) +' - ' + h.NomProyecto
			, EsTardio						= 0
    FROM	OpeSch.OpeTraMovMciasTranEnc a WITH(NOLOCK)
    INNER JOIN OpeSch.OpeTraMovMciasTranDet  b WITH(NOLOCK)
    ON      a.ClaUbicacion              = b.ClaUbicacion              
    AND     a.ClaTipoInventario         = b.ClaTipoInventario 
    AND     a.IdMovimiento              = b.IdMovimiento
    INNER JOIN OpeSch.OpeBitFabricacionEstimacion f WITH(NOLOCK)
    ON      b.NumericoExtra2            = f.IdFabricacionEstimacion
    INNER JOIN OpeSch.OpeTiCatUbicacionVw c
    ON      a.ClaUbicacionOrigen        = c.ClaUbicacion
    INNER JOIN OpeSch.ArtCatArticuloVw e
    ON      e.ClaTipoInventario         = 1
    AND     b.ClaArticulo               = e.ClaArticulo      
	INNER JOIN OpeSch.OpeRelEmbarqueEstimacionVw g
    ON      a.ClaUbicacionOrigen        = g.PlantaEstimacion
    AND     a.NumViaje                  = g.IdViajeEstimacion     
	AND		b.NumericoExtra2            = g.FabricacionEstimacion 
	AND		b.ClaArticulo				= g.ClaArticulo
    LEFT JOIN OpeSch.OpeVtaCatProyectoVw h
	ON		g.ProyectoAgrupador			= h.ClaProyecto
	WHERE	(@pnClaUbicacionOrigen IS NULL OR (@pnClaUbicacionOrigen = a.ClaUbicacionOrigen))
	AND		(@pnIdFabricacionEstimacion IS NULL OR (b.NumericoExtra2 = @pnIdFabricacionEstimacion))
	AND		b.EstatusTransito			= 3


	--- /* Es Facturación de estimaciones */
	UPDATE	a
	SET		EsTardio	= 1
	FROM	@tbEmbarqueEstimacion a
	INNER JOIN OpeSch.OpeControlFacturaRemisionEstimacionVw b
	ON		a.IdViajeVenta				= b.IdViaje
	AND		a.FacturaAlfanumericoVenta	= b.RemisionAlfanumerico


	IF @pnDebug = 1
		SELECT '' AS '@tbEmbarqueEstimacion',* FROM @tbEmbarqueEstimacion WHERE EsTardio = 1

	
	--- Registros de Embarques de Estimaciones no tardios
	INSERT INTO @tbGpoEmbarquesEstimacion (
		  ClaUbicacionOrigen
		, IdBoletaVenta		
		, IdPlanCargaVenta	
		, IdViajeVenta				
	)
	SELECT DISTINCT
			  ClaUbicacionOrigen
			, IdBoletaVenta		
			, IdPlanCargaVenta	
			, IdViajeVenta
	FROM	@tbEmbarqueEstimacion
	WHERE	EsTardio = 0


	--IF @pnDebug = 1
	--	SELECT '' AS '@tbGpoEmbarquesEstimacion',* FROM  @tbGpoEmbarquesEstimacion

	SELECT  @nId	= MIN(Id) 
	FROM	@tbGpoEmbarquesEstimacion


/*
	WHILE  @nId IS NOT NULL
	BEGIN
		SELECT   @nClaUbicacionVenta	= NULL	
			   , @nIdBoletaVenta		= NULL
			   , @nIdPlanCargaVenta		= NULL
			   , @nIdViajeVenta			= NULL

		SELECT    @nClaUbicacionVenta	= ClaUbicacionOrigen	
				, @nIdBoletaVenta		= IdBoletaVenta
				, @nIdPlanCargaVenta	= IdPlanCargaVenta
				, @nIdViajeVenta		= IdViajeVenta
		FROM	@tbGpoEmbarquesEstimacion
		WHERE	Id = @nId

		
		SELECT    @nClaUbicacionVenta	AS ClaUbicacionVenta	
				, @nIdBoletaVenta		AS IdBoletaVenta		
				, @nIdPlanCargaVenta	AS IdPlanCargaVenta	
				, @nIdViajeVenta		AS IdViajeVenta		

		IF @pnDebug = 2
		BEGIN
			--- /* Consulta de Cambios realizados */
			SELECT * FROM OpeSch.OpeTraPlanCarga a	WHERE a.IdPlanCarga = @nIdPlanCargaVenta AND a.ClaUbicacion = @nClaUbicacionVenta
			SELECT * FROM OpeSch.OpeTraViaje a		WHERE a.idboleta = @nIdBoletaVenta AND a.ClaUbicacion = @nClaUbicacionVenta
			SELECT * FROM OpeSch.OpeTraMovEntSal a	WHERE a.idboleta = @nIdBoletaVenta AND a.ClaUbicacion = @nClaUbicacionVenta
			SELECT * FROM OpeSch.OpeTraBoleta a		WHERE a.idboleta = @nIdBoletaVenta AND a.ClaUbicacion = @nClaUbicacionVenta
			SELECT * FROM OpeSch.OpeTraBoletaHis a	WHERE a.idboleta = @nIdBoletaVenta AND a.ClaUbicacion = @nClaUbicacionVenta
			---/* Consulta de Factura PreCancelacion */
			SELECT * FROM vtapta.dbo.ev_factura_viaje	WHERE cla_planta = @nClaUbicacionVenta AND cla_viaje = @nIdPlanCargaVenta
			SELECT * FROM vtapta.dbo.ev_factura_enc		WHERE cla_planta = @nClaUbicacionVenta AND cla_viaje = @nIdPlanCargaVenta
			SELECT * FROM vtapta.dbo.ev_factura_det		WHERE cla_planta = @nClaUbicacionVenta AND cla_viaje = @nIdPlanCargaVenta
			--select 'Consulta de Regitro en PlanCargaRemision - Operacion Bitacora'
			--select * from OpeSch.OpeTraPlanCargaRemisionEstimacion		
		END


		--- /*Actualización previa a proceso de Cancelacion de Plan de Carga y Eliminación de Placa*/
		--UPDATE	a 
		--SET		  a.claestatusplancarga = 2
		--		, a.ClaTipoViaje = 5 
		--FROM	OpeSch.OpeTraPlanCarga a WITH(NOLOCK) 
		--WHERE	a.IdPlanCarga	= @nIdPlanCargaVenta 
		--AND		a.ClaUbicacion	= @nClaUbicacionVenta
	
		--UPDATE	a 
		--SET		  a.ClaTipoViaje = 5
		--		, IdNumTabular = 0 
		--FROM	OpeSch.OpeTraViaje a WITH(NOLOCK)
		--WHERE	a.idboleta		= @nIdBoletaVenta	
		--AND		a.ClaUbicacion	= @nClaUbicacionVenta


		---/*Ejecucion de Proceso de Cancelacion de Plan de Carga*/
		--EXEC	[OpeSch].[OPE_CU72_Pag8_Grid_PlanEncCU72PAG8_IU]
		--		@pnClaUbicacion			= @nClaUbicacionVenta,
		--		@pnIdPlanCargaCU72PAG8	= @nIdPlanCargaVenta,
		--		@pnClaUsuarioMod		= 10001,
		--		@psNombrePcMod			= 'EstimacionesIngetek',
		--		@psIdioma				= 'Spanish'

		--- /*Ejecucion de Eliminacion de Placa*/
		--EXEC	OpeSch.OpeEliminaPlacasProc 
		--		@pnClaUbicacion			= @nClaUbicacionVenta, 
		--		@pnIdBoleta				= @nIdBoletaVenta, 
		--		@psNombrePcMod			= 'EstimacionesIngetek', 
		--		@pnClaUsuarioMod		= 10001



		IF @pnDebug = 2
		BEGIN
			--- /* Consulta de Caso Post Operacion */
			SELECT * FROM OpeSch.OpeTraPlanCarga a	WHERE a.IdPlanCarga = @nIdPlanCargaVenta AND a.ClaUbicacion = @nClaUbicacionVenta
			SELECT * FROM OpeSch.OpeTraViaje a		WHERE a.idboleta = @nIdBoletaVenta AND a.ClaUbicacion = @nClaUbicacionVenta
			SELECT * FROM OpeSch.OpeTraMovEntSal a	WHERE a.idboleta = @nIdBoletaVenta AND a.ClaUbicacion = @nClaUbicacionVenta
			SELECT * FROM OpeSch.OpeTraBoleta a		WHERE a.idboleta = @nIdBoletaVenta AND a.ClaUbicacion = @nClaUbicacionVenta
			SELECT * FROM OpeSch.OpeTraBoletaHis a	WHERE a.idboleta = @nIdBoletaVenta AND a.ClaUbicacion = @nClaUbicacionVenta
			--- /* Consulta de Factura PostCancelacion */
			SELECT * FROM vtapta.dbo.ev_factura_viaje	WHERE cla_planta = @nClaUbicacionVenta AND cla_viaje = @nIdPlanCargaVenta
			SELECT * FROM vtapta.dbo.ev_factura_enc		WHERE cla_planta = @nClaUbicacionVenta AND cla_viaje = @nIdPlanCargaVenta
			SELECT * FROM vtapta.dbo.ev_factura_det		WHERE cla_planta = @nClaUbicacionVenta AND cla_viaje = @nIdPlanCargaVenta
		END

		--INSERT INTO OpeSch.OpeTraPlanCargaRemisionEstimacionBit
		--SELECT * 
		--FROM	OpeSch.OpeTraPlanCargaRemisionEstimacion
		--WHERE ClaUbicacionVenta	= @nClaUbicacionVenta	
		--AND	IdBoletaVenta			= @nIdBoletaVenta	
		--AND	IdPlanCargaVenta		= @nIdPlanCargaVenta	
		--AND	IdViajeVenta			= @nIdViajeVenta

		--DELETE 
		--FROM	OpeSch.OpeTraPlanCargaRemisionEstimacion
		--WHERE ClaUbicacionVenta	= @nClaUbicacionVenta	
		--AND	IdBoletaVenta		= @nIdBoletaVenta	
		--AND	IdPlanCargaVenta	= @nIdPlanCargaVenta	
		--AND	IdViajeVenta		= @nIdViajeVenta

		SELECT  @nId	= MIN(Id) 
		FROM	@tbGpoEmbarquesEstimacion
		WHERE	Id > @nId
	END
*/
	----------------------------------------------
	-- Ubicaciones distintas
	INSERT INTO @tUbicacionesEstimacion (
		 ClaUbicacion
	)
	SELECT	DISTINCT 
			ClaUbicacionOrigen 
	FROM	@tbEmbarqueEstimacion
	WHERE	EsTardio = 1


	--- Actualización de correos configurados por Ubicación
	UPDATE	a
	SET		  Destinatarios			= b.sValor1
			, CopiaDestinatarios	= b.sValor2
	FROM	@tUbicacionesEstimacion a
	INNER JOIN OpeSch.OPETiCatConfiguracionVw b
	ON		a.ClaUbicacion			= b.ClaUbicacion
	AND		ClaSistema				= 127 
	AND		ClaConfiguracion		= 1271221


	--- Borrar registros que no tienen correo configurado
	DELETE 
	FROM	@tbEmbarqueEstimacion 
	WHERE	EsTardio = 1
	AND		ClaUbicacionOrigen IN (
				SELECT  b.ClaUbicacion
				FROM	@tUbicacionesEstimacion b
				WHERE	ISNULL(b.Destinatarios,'') = ''
			)



	SELECT  @nClaUbicacionVenta	= MIN(ClaUbicacion)
	FROM	@tUbicacionesEstimacion
	
	WHILE @nClaUbicacionVenta IS NOT NULL
	BEGIN
		DELETE FROM @DetalleCorreo
		
		SELECT	  @sCuerpo			= ''
				, @sCuentasCorreo	= ''
				, @sCuentaCopia		= ''

		---/* Asignación de Variables */
		SELECT	  @sCuentasCorreo	= Destinatarios
				, @sCuentaCopia		= CopiaDestinatarios
		FROM	@tUbicacionesEstimacion
		WHERE	ClaUbicacion = @nClaUbicacionVenta

		SELECT	@sNomUbicacion = NomUbicacion 
		FROM	OpcSch.OpcTiCatUbicacionVw 
		WHERE	ClaUbicacion = @nClaUbicacionVenta

		-----------------------------------------------------------------------------

		SELECT	@sAsunto = LTRIM(RTRIM('Notificación de Cancelación Tardía de Embarques de Estimaciones - '  + ISNULL(@sNomUbicacion,'')))

		SELECT	@sCuerpo = 
		'<!DOCTYPE html>      
		<html>      
		<style type="text/css">
			.tabla{font-family:Arial;font-size:12px;color:#000000;}
			.header{color:#FFFFFF;background-color:#304f60;}
			.texto1{color=#000000" style="font-family: Arial; font-size: 12pt;}
			.centrar{text-align: center;}
			.izquierda{text-align: left;}
			.derecha{text-align: right;}
		</style>
		<body>      
			<FONT class="texto1">
			<h3><strong>Notificación:</strong></h3>   
			<p>Listado de Viajes de Estimación Cerrados para la ubicación <b>'+LTRIM(RTRIM(ISNULL(@sNomUbicacion,'')))+'</b>, que han sido Cancelados por el equipo de Embarques, pero se encuentran Facturados en el Sistema:</p>
			</FONT></br>
		<table class="tabla" cellspacing="0" border="1" width="80%">      
		<tr class="header">
		  <th WIDTH=" 12%">Proyecto</th>  
		  <th WIDTH=" 4%">Fabricación Venta</th>           
		  <th WIDTH=" 4%">Fabricación Estimaciones</th>            
		  <th WIDTH=" 4%">Viaje Estimación</th> 
		  <th WIDTH=" 4%">Remisión</th>        
		</tr>'

		INSERT INTO @DetalleCorreo (HTML)
		SELECT	
			'<tr><td class="izquierda"	bgcolor="lightgrey">'	+ ISNULL(RTRIM(LTRIM(Proyecto)) , '') + '</td>  ' +		
				'<td class="centrar"	bgcolor="lightgrey">'	+ ISNULL(CAST(RTRIM(LTRIM(FabricacionVenta)) AS VARCHAR), '') + '</td>  ' +
				'<td class="centrar"	bgcolor="lightgrey">'	+ ISNULL(CAST(RTRIM(LTRIM(IdFabricacionEstimacion)) AS VARCHAR), '') + '</td>  ' +
				'<td class="centrar"	bgcolor="lightgrey">'	+ ISNULL(CAST(RTRIM(LTRIM(NumViaje)) AS VARCHAR), '') + '</td>  ' +
				'<td class="centrar"	bgcolor="lightgrey">'	+ ISNULL(RTRIM(LTRIM(FacturaAlfanumericoVenta)) , '') + '</td>  ' +		
				'</tr> ' AS Datos
		FROM	@tbEmbarqueEstimacion
		WHERE	EsTardio = 1
		AND		ClaUbicacionOrigen = @nClaUbicacionVenta


		--Para poner rows en blanco 
		UPDATE	@DetalleCorreo			-- #bdbdbd
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

		SELECT	@sCuerpo = @sCuerpo + '</table><br><br> </body> </html>'

		IF @pnDebug = 1
		BEGIN
			SELECT @sCuentasCorreo AS '@sCuentasCorreo', @sCuentaCopia AS '@sCuentaCopia', @sCuentaCopiaOculta AS '@sCuentaCopiaOculta'
			SELECT @sCuentasCorreo = 'hvalle@deacero.com' ,@sCuentaCopia = NULL, @sCuentaCopiaOculta = NULL
			SELECT @sAsunto AS '@sAsunto', @sCuerpo AS 'Cuerpo', @sCuentasCorreo AS '@sCuentasCorreo', @sCuentaCopia AS '@sCuentaCopia', @sCuentaCopiaOculta AS '@sCuentaCopiaOculta'
		END

		IF (	SELECT	COUNT(1)
				FROM	@DetalleCorreo	) > 0 AND ISNULL(@sCuentasCorreo, '') <> ''
		BEGIN
			EXECUTE AS LOGIN = 'sa'
			EXEC msdb.dbo.sp_send_dbmail 
				  @profile_name			= 'OPEEst Profile'
				, @recipients			= 'hvalle@deacero.com'--@sCuentasCorreo
				, @copy_recipients		= null--@sCuentaCopia
				, @blind_copy_recipients = null--@sCuentaCopiaOculta
				, @importance			= 'NORMAL'	--'HIGH'
				, @subject				= @sAsunto
				, @body					= @sCuerpo
				, @body_format			= 'HTML'
				, @file_attachments		= NULL
		END

		SELECT  @nClaUbicacionVenta	= MIN(ClaUbicacion)
		FROM	@tUbicacionesEstimacion
		WHERE	ClaUbicacion > @nClaUbicacionVenta
	END
	
	COMMIT TRAN
END TRY
BEGIN CATCH
	SELECT 'ERROR'
	ROLLBACK TRAN
END CATCH