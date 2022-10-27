CREATE PROCEDURE OpeSch.OPE_CU444_Pag36_Boton_AceptarConfirma_Proc
	@pnClaUbicacion			INT,
	@pnIdPreordenCediMod	INT,
	@pnIdExistenciaAg		INT,
	@pnClaArticuloMod		INT,
	@pstxtCamion			VARCHAR(30),
	@psNombrePcMod			VARCHAR(64),
	@pnClaUsuarioMod		INT
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
			@nIdPreOrdenCEDI			INT,
			@sCliente					VARCHAR(250)

	-- Ubicacion de Ventas
	DECLARE @nClaUbicacionVentas INT
	
	SELECT	@nClaUbicacionVentas = ClaUbicacionVentas 
	FROM	OpeSch.OpeTiCatUbicacionVw 
	WHERE	ClaUbicacion		= @pnClaUbicacion


	CREATE TABLE #tDatos (	ClaArticulo				INT,
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
							NomCliente				VARCHAR(250))

	INSERT #tDatos (ClaArticulo,
					ClaUnidad,
					Cantidad,
					Kilos,
					ClaTipoReferencia1,
					ClaTipoReferencia2,
					ClaTipoReferencia3,
					ValorReferencia1,
					ValorReferencia2,
					ValorReferencia3)
	SELECT			exis.ClaArticulo,
					art.ClaUnidadBase,
					Cantidad,
					Cantidad * art.PesoTeoricoKgs,
					ClaTipoReferencia1,
					ClaTipoReferencia2,
					ClaTipoReferencia3,
					ValorReferencia1,
					ValorReferencia2,
					ValorReferencia3
	FROM			OpeSch.OpeTraExistencias		exis WITH (NOLOCK) 
	LEFT JOIN		OpeSch.OpeArtCatArticuloVw		art  ON (exis.ClaArticulo			= art.ClaArticulo
															AND art.ClaTipoInventario	= 1)
	WHERE			IdExistencia			= @pnIdExistenciaAg
	AND				ClaUbicacion			= @pnClaUbicacion
	AND				exis.ClaTipoInventario	= 1	
	AND				exis.ClaArticulo		= @pnClaArticuloMod	

	BEGIN TRY
		BEGIN TRAN

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
					@sClaveRollo			= CASE WHEN ClaTipoReferencia1 = 3 THEN ValorReferencia2 ELSE NULL END
			FROM	#tDatos

			SELECT	@nIdPreOrdenCEDI= NumPreorden,
					@sCliente		= NombreCliente
			FROM	OpeSch.OpeTraPreordenCEDI WITH (NOLOCK)
			WHERE	ClaUbicacion	= @pnClaUbicacion
			AND		IdPreordenCEDI	= @pnIdPreordenCediMod

			-- INSERTAR EN LA TABLA DE NOSOTROS			
			SELECT	@nIdFabricacionCEDI = MAX(IdFabricacion)
			FROM	[OpeSch].[OpeTraFabricacionCEDI] WITH (NOLOCK)
			
			SET @nIdFabricacionCEDI = ISNULL(@nIdFabricacionCEDI, 0) + 1			

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
														   ,[ClaEstatus]
														   --,[ClaPedidoCliente] NNAVA ESTA COLUMNA YA NO SE NECESITA
														   )
			 SELECT		@nIdFabricacionCEDI
					   ,@sCliente
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
					   ,@pstxtCamion
					   ,1
					   --,@nIdPreOrdenCEDI

			-- MANDAR A CUARENTENA
			EXEC OpeSch.OPE_CU444_Pag36_Boton_MandarCuarentena_Proc	@pnClaUbicacion				= @pnClaUbicacion, 
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
			EXEC [VTA_Central].Ventas.[VTASch].[VtaRecibeInfoFabCEDISrv]	@psNombreCliente	= @sCliente,
																			@pnClaArticulo		= @nClaArticulo,
																			@pnClaUbicacion		= @nClaUbicacionVentas, --@pnClaUbicacion,
																			@psNumCarrete		= @sNumCarrete,
																			@psNombrePcMod		= @psNombrePcMod,
																			@pnClaUsuarioMod	= @pnClaUsuarioMod,
																			@pnIdOPM			= @nIdOpm, 
																			@psClaveRollo		= @sClaveRollo,
																			@psClaPedidoCliente = @nIdFabricacionCEDI,
																			@psNumCamion		= @pstxtCamion,
																			@pnCantidad			= @nCantidad,
																			@pnIdPreOrdenCEDI	= @nIdPreOrdenCEDI


			UPDATE	OpeSch.OpeTraPreordenCEDI WITH (ROWLOCK)
				SET ClaEstatus		= 2,
					ClaUsuarioMod	= @pnClaUsuarioMod,
					NombrePcMod		= @psNombrePcMod,
					FechaUltimaMod	= GETDATE()
			WHERE	IdPreordenCedi	= @pnIdPreordenCediMod
			AND		ClaUbicacion	= @pnClaUbicacion

		DROP TABLE #tDatos
	
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