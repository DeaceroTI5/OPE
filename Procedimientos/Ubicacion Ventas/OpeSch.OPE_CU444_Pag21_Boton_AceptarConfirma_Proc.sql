CREATE PROCEDURE OpeSch.OPE_CU444_Pag21_Boton_AceptarConfirma_Proc
	@pnClaUbicacion		INT,
	@psUid				VARCHAR(36),
	@psCliente			VARCHAR(250),
	@psNombrePcMod		VARCHAR(64),
	@pnClaUsuarioMod	INT
AS
BEGIN

	DECLARE @nIdNotificacion			INT,
			@nClaArticulo				INT,
			@nClaUnidad					INT,
			@nCantidad					NUMERIC(22,4), 
			@nKilos						NUMERIC(22,4), 
			@nClaTipoReferencia1		INT, 
			@nClaTipoReferencia2		INT, 
			@nClaTipoReferencia3		INT, 
			@sValorReferencia1			VARCHAR(30),
			@sValorReferencia2			VARCHAR(30),
			@sValorReferencia3			VARCHAR(30),
			@nIdFabricacionCEDI			INT,
			-- PARA ENVIAR A VENTAS
			@sNumCarrete				VARCHAR(30),
			@nIdOpm						INT,
			@sClaveRollo				VARCHAR(20),
			@sIdFabricacionCEDI			VARCHAR(16),
			@sNumCamion					VARCHAR(30)

	-- Ubicacion de Ventas
	DECLARE @nClaUbicacionVentas INT
	
	SELECT	@nClaUbicacionVentas = ClaUbicacionVentas 
	FROM	OpeSch.OpeTiCatUbicacionVw 
	WHERE	ClaUbicacion		= @pnClaUbicacion

	CREATE TABLE #tDatos (IdNotificacion		INT,
						ClaArticulo				INT,
						ClaUnidad				INT,
						Cantidad				NUMERIC(22,4), 
						Kilos					NUMERIC(22,4), 
						NumCamion				VARCHAR(30),
						ClaTipoReferencia1		INT, 
						ClaTipoReferencia2		INT, 
						ClaTipoReferencia3		INT, 
						ValorReferencia1		VARCHAR(30),
						ValorReferencia2		VARCHAR(30),
						ValorReferencia3		VARCHAR(30),
						-- PARA CORREO
						NomArticulo				VARCHAR(300),
						RefCorreo				VARCHAR(300),
						CantCorreo				VARCHAR(100))

	INSERT #tDatos (IdNotificacion,
				ClaArticulo,
				ClaUnidad,
				Cantidad,
				Kilos,
				NumCamion,
				ClaTipoReferencia1,
				ClaTipoReferencia2,
				ClaTipoReferencia3,
				ValorReferencia1,
				ValorReferencia2,
				ValorReferencia3,
				-- PARA CORREO
				NomArticulo,
				RefCorreo,
				CantCorreo)
	SELECT		noti.IdNotificacion,
				noti.ClaArticulo,
				art.ClaUnidadBase,
				exis.Cantidad,
				exis.Cantidad * art.PesoTeoricoKgs,
				noti.NumCamion,
				ClaTipoReferencia1,
				ClaTipoReferencia2,
				ClaTipoReferencia3,
				ValorReferencia1,
				ValorReferencia2,
				ValorReferencia3,
				-- PARA CORREO
				NomArticulo =	LTRIM(RTRIM(CONVERT(VARCHAR(150), Art.ClaveArticulo))) + '-' + ISNULL(NULLIF(Art.NomArticuloIngles,''), Art.NomArticulo),
				RefCorreo	=	CASE 
									WHEN ClaTipoReferencia1 = 3 THEN ISNULL(ValorReferencia2,'')
									WHEN ClaTipoReferencia1 = 5 THEN ISNULL(ValorReferencia1,'')
								END,
				REPLACE(CONVERT(VARCHAR(100), CAST(ROUND(Exis.Cantidad, 0)  AS MONEY), 1), '.00', '') + '  ' + Uni.NomUnidad
	FROM		OpeSch.OpeTraNotificaArticuloCEDITmp	noti WITH (NOLOCK)
	INNER JOIN	OpeSch.OpeTraExistencias				exis WITH (NOLOCK) ON (	noti.IdExistencia			= exis.IdExistencia
																				AND ClaUbicacion			= @pnClaUbicacion
																				AND ClaTipoInventario		= 1
																				AND noti.ClaArticulo		= exis.ClaArticulo)
	LEFT JOIN	OpeSch.OpeArtCatArticuloVw				art					ON (noti.ClaArticulo			= art.ClaArticulo
																				AND art.ClaTipoInventario	= 1)
	LEFT JOIN	OpeSch.OpeArtCatUnidadVw				Uni					ON (Art.ClaUnidadBase			= Uni.ClaUnidad
																				AND Uni.ClaTipoInventario	= 1)
	WHERE		Uid = @psUid


	BEGIN TRY
		BEGIN TRAN
		
		SELECT @nIdNotificacion = MIN (IdNotificacion)
		FROM #tDatos
		
		WHILE(@nIdNotificacion IS NOT NULL)
		BEGIN

			SELECT	@nClaArticulo			= ClaArticulo,
					@nClaUnidad				= ClaUnidad,
					@nCantidad				= Cantidad,
					@nKilos					= Kilos,
					@nClaTipoReferencia1	= ClaTipoReferencia1,
					@nClaTipoReferencia2	= ClaTipoReferencia2,
					@nClaTipoReferencia3	= ClaTipoReferencia3,
					@sValorReferencia1		= ValorReferencia1,
					@sValorReferencia2		= ValorReferencia2,
					@sValorReferencia3		= ValorReferencia3,
					@sNumCarrete			= CASE WHEN ClaTipoReferencia1 = 5 THEN ValorReferencia1 ELSE NULL END,
					@nIdOpm					= CASE WHEN ClaTipoReferencia1 = 3 THEN CONVERT(INT, ValorReferencia1) ELSE NULL END,
					@sClaveRollo			= CASE WHEN ClaTipoReferencia1 = 3 THEN ValorReferencia2 ELSE NULL END,
					@sNumCamion				= NumCamion
			FROM	#tDatos
			WHERE	IdNotificacion	= @nIdNotificacion

			SELECT	@nIdFabricacionCEDI = MAX(IdFabricacion)
			FROM	[OpeSch].[OpeTraFabricacionCEDI] WITH (NOLOCK)
			
			SET @nIdFabricacionCEDI = ISNULL(@nIdFabricacionCEDI, 0) + 1
			
			-- INSERTAR EN LA TABLA DE NOSOTROS
			INSERT INTO [OpeSch].[OpeTraFabricacionCEDI]	([IdFabricacion]
														   ,[NombreCliente]
														   ,[ClaArticulo]
														   ,[ClaUbicacion]
														   ,[NumCarrete]
														   ,[FechaUltimaMod]
														   ,[NombrePcMod]
														   ,[ClaUsuarioMod]
														   ,[IdOPM]
														   ,[ClaveRollo]
														   ,[Cantidad]
														   ,[Kilos]
														   ,[NumCamion]
														   --,[ClaPedidoCliente] NNAVA
														   ,[ClaEstatus])
			 SELECT		@nIdFabricacionCEDI
					   ,@psCliente
					   ,@nClaArticulo
					   ,@pnClaUbicacion
					   ,@sNumCarrete
					   ,GETDATE()
					   ,@psNombrePcMod
					   ,@pnClaUsuarioMod
					   ,@nIdOpm
					   ,@sClaveRollo
					   ,@nCantidad
					   ,@nKilos
					   ,@sNumCamion
					   --,@nIdFabricacionCEDI YA NO SE NECESITA
					   ,1 -- ClaEstatus

			-- MANDAR A CUARENTENA
			EXEC OpeSch.OPE_CU444_Pag21_Boton_MandarCuarentena_Proc	@pnClaUbicacion				= @pnClaUbicacion, 
																	@pnClaTipoInventario		= 1, 
																	@pnClaGrupoTMA				= 4, 
																	@pnClaTipoMotivo			= 4, 
																	@pnClaArticulo				= @nClaArticulo,
																	@pnClaUnidad				= @nClaUnidad,
																	@pnClaAlmacenActual			= 1, 
																	@pnClaSubAlmacenActual		= NULL, 
																	@pnClaSubSubAlmacenActual	= NULL, 
																	@pnClaSeccionActual			= NULL, 
																	@pnCantidad					= @nCantidad,
																	@pnKilos					= @nKilos,
																	@pnClaTipoReferencia1		= @nClaTipoReferencia1,
																	@pnClaTipoReferencia2		= @nClaTipoReferencia2,
																	@pnClaTipoReferencia3		= @nClaTipoReferencia3,
																	@psValorReferencia1			= @sValorReferencia1,
																	@psValorReferencia2			= @sValorReferencia2,
																	@psValorReferencia3			= @sValorReferencia3,
																	@pnClaUsuarioMod			= @pnClaUsuarioMod,
																	@psNombrePcMod				= @psNombrePcMod

			-- NOTIFICAR A VENTAS
			--exec [VTA_Central].Ventas.dbo.sp_helptext '[VTASch].[VtaRecibeInfoFabCEDISrv]'
			EXEC [VTA_Central].Ventas.[VTASch].[VtaRecibeInfoFabCEDISrv]	@psNombreCliente	= @psCliente,
																			@pnClaArticulo		= @nClaArticulo,
																			@pnClaUbicacion		= @nClaUbicacionVentas, --@pnClaUbicacion,
																			@psNumCarrete		= @sNumCarrete,
																			@psNombrePcMod		= @psNombrePcMod,
																			@pnClaUsuarioMod	= @pnClaUsuarioMod,
																			@pnIdOPM			= @nIdOpm, 
																			@psClaveRollo		= @sClaveRollo,
																			@psClaPedidoCliente = @nIdFabricacionCEDI,
																			@psNumCamion		= @sNumCamion,
																			@pnCantidad			= @nCantidad,
																			@pnIdPreOrdenCEDI	= NULL


			SELECT @nIdNotificacion = MIN (IdNotificacion)
			FROM #tDatos
			WHERE IdNotificacion > @nIdNotificacion
			
		END
		
		-- NOTIFICACIÓN POR CORREO
		DECLARE @sCss		VARCHAR(MAX),
				@sBody		VARCHAR(MAX),
				@sSubject	VARCHAR(500)
		
		SET @sCss = '<style type="text/css">
.tg  {border-collapse:collapse;border-spacing:0;border-color:#999;}
.tg td{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-
color:#999;color:#444;background-color:#F7FDFA;}
.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-
break:normal;border-color:#999;color:#000;background-color:#d8d8da;}
.tg .tg-3sk9{font-weight:bold;font-size:12px}
.tg .tg-k6pi{background-color:#ffffff;font-size:12px;text-align:left}
.tg .tg-dx8v{background-color:#ffffff;font-size:12px;text-align:center}
.tg .tg-0wl7{background-color:#F2F2F2;font-size:12px;text-align:center}
.tg .tg-0wl8{background-color:#F2F2F2;font-size:12px;text-align:left}
</style>'

		SET @sBody = ''

		SELECT @sBody = @sBody + '<tr>
		<td class="' + CASE WHEN IdNotificacion%2 = 1 THEN 'tg-k6pi' ELSE 'tg-0wl8' END + '">' + ISNULL(LTRIM(RTRIM(NomArticulo)),'')+ '</td>
		<td class="' + CASE WHEN IdNotificacion%2 = 1 THEN 'tg-k6pi' ELSE 'tg-0wl8' END + '">' + ISNULL(LTRIM(RTRIM(RefCorreo)),'')+ '</td>
		<td class="' + CASE WHEN IdNotificacion%2 = 1 THEN 'tg-dx8v' ELSE 'tg-0wl7' END + '">' + ISNULL(CantCorreo,'')+ '</td>
	  </tr>'	
	  FROM #tDatos
	  ORDER BY NomArticulo, RefCorreo, CantCorreo
  		
		SELECT @sBody = @sCss + 'The following cables have been installed to <B>' +  ISNULL(@psCliente, '') + '</B>: <BR><BR><table class="tg">
  <tr>
	<th width="100px" class="tg-3sk9">Description</th>
	<th width="100px" class="tg-3sk9">Reel</th>
	<th width="100px" class="tg-3sk9">Lenght</th>
  </tr>'
  + @sBody
  + '</table>'
  
		
		SELECT	@sSubject  = 'Cable Installations (' + ISNULL(UPPER(NombreCorto),'') + ')'
		FROM	OpeSch.OpeTiCatUbicacionVw
		WHERE	ClaUbicacion = @pnClaUbicacion
	  
  		EXEC msdb.dbo.sp_send_dbmail		@profile_name	= 'OPE_CEDI' ,
											@recipients		= 'cgranados@deacero.com;jnavarrete@deacero.com;fgarcia@deacero.com',
											@subject		= @sSubject,
											@body			= @sBody,
											@body_format	= 'HTML'
										
		DROP TABLE #tDatos
		
		DELETE OpeSch.OpeTraNotificaArticuloCEDITmp
		WHERE	Uid = @psUid
	
		COMMIT TRAN
	END TRY
	BEGIN CATCH  
		IF @@TRANCOUNT > 0 
		BEGIN 
			DECLARE @sErrorMessage VARCHAR(250)
			SET @sErrorMessage = ERROR_MESSAGE()
			RAISERROR( @sErrorMessage, 16, 1 )
			ROLLBACK TRANSACTION 				
			RETURN 
		END
	END CATCH

END