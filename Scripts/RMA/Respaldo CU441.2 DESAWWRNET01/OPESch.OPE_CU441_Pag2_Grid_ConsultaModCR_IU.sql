Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- Objeto:		OPESch.OPE_CU441_Pag2_Grid_ConsultaModCR_IU
-- Autor:
-- Fecha:
-- Objetivo:
-- Entrada:
-- Salida:
-- Precondiciones:
-- Retorno:
-- Revisiones:
--*----
CREATE PROCEDURE [OPESch].[OPE_CU441_Pag2_Grid_ConsultaModCR_IU]
@pnClaUbicacion INT,
@pnIdPlanRecoleccion		INT,
@pnIdPlanRecoleccionDet		INT = null,
@pnClaCliente				INT,
@pnCantRecolectar			NUMERIC(22,4),
@pnPesoRecolectar			NUMERIC(22,4) = NULL,
@pnCantFacturada			NUMERIC(22,4),
@pnPesoFacturado			NUMERIC(22,4),
@pnClaConsignado			INT,
@pnClaArticulo				INT,
@pnIdFactura				INT,
@pnIdRMA					INT,
@pnIdFacturaDet				INT,
@psIdFacturaAlfanumerico	VARCHAR(25),
@pnPesoTeoricoKgs			NUMERIC(22, 4),
@psNombrePcMod				VARCHAR(64),
@pnClaUsuarioMod			INT,
@pnIncluye					INT
AS
BEGIN
	SET NOCOUNT ON
	
	IF(@pnIncluye = 1)
	BEGIN
		SELECT	@pnPesoRecolectar = @pnPesoTeoricoKgs * @pnCantRecolectar
		
		EXEC	OPESch.OPE_CU441_Pag2_Boton_CreaPlanDet_Proc
				@pnClaUbicacion				= @pnClaUbicacion,
				@pnIdPlanRecoleccion		= @pnIdPlanRecoleccion,
				@pnIdPlanRecoleccionDet		= @pnIdPlanRecoleccionDet,
				@pnClaCliente				= @pnClaCliente,
				@pnCantRecolectar			= @pnCantRecolectar,
				@pnPesoRecolectar			= @pnPesoRecolectar,
				@pnCantFacturada			= @pnCantFacturada,
				@pnPesoFacturado			= @pnPesoFacturado,
				@pnClaConsignado			= @pnClaConsignado,
				@pnClaArticulo				= @pnClaArticulo,
				@pnIdFactura				= @pnIdFactura,
				@pnIdRMA					= @pnIdRMA,
				@pnIdFacturaDet				= @pnIdFacturaDet,
				@psIdFacturaAlfanumerico	= @psIdFacturaAlfanumerico,
				@psNombrePcMod				= @psNombrePcMod,
				@pnClaUsuarioMod			= @pnClaUsuarioMod
				
				IF ISNULL(@@ERROR, 0) = 0
				BEGIN
					SELECT EsDetalleOk = 1
				
			
				DECLARE	@nClaUbicacion          INT 
				DECLARE	@nIdViaje               INT 
				DECLARE	@nIdFabricacion         INT 
				DECLARE	@nClaCliente            INT 
				DECLARE	@nClaConsignado         INT 
				DECLARE	@nClaCiudad             INT 
				DECLARE	@nClaOrganizacion       INT 
				DECLARE	@nClaTransportista      INT 
				DECLARE	@nTipoFlete             INT 
				DECLARE	@nClaMoneda             INT 
				DECLARE	@dFechaFactura          DATETIME
				DECLARE	@nKilosSurtidos         NUMERIC 
				DECLARE	@sIdFacturaAlfanumerico VARCHAR(15) 
				DECLARE @sExec NVARCHAR(MAX)	
				DECLARE @nClaSistema INT
				DECLARE @sNombreClave VARCHAR(50)
				DECLARE @sConexionRemota VARCHAR(1000)
				DECLARE @sObjetoRemoto			VARCHAR(50)
						
				--SET @nClaSistema = 199
				--SET @sNombreClave = 'VTA3'
				--SET @sObjetoRemoto = 'VtaCTraFacturaVw'
				SET @nClaSistema = 1990-- 199
				SET @sNombreClave = 'VTA5'--'VTA3'
				SET @sObjetoRemoto = 'VtaTraFacturaVw'--'VtaCTraFacturaVw'
				SET @sConexionRemota = OpeSch.OpeConexionRemotaFn(@pnClaUbicacion, @nClaSistema, @sNombreClave, @sObjetoRemoto)
				
				--CREAMOS TABLA DONDE ALMACENAREMOS INFORMACION DE TABLA REMOTA
				create table #tmpcTraFactura(
				ClaUbicacion INT,
				IdViaje INT,
				IdFabricacion INT,
				ClaCliente INT,
				ClaConsignado INT,
				ClaCiudad INT,
				ClaOrganizacion INT,
				ClaTransportista INT,
				TipoFlete INT,
				ClaMoneda INT,
				FechaFactura DATETIME,
				KilosSurtidos INT,
				IdFacturaAlfanumerico VARCHAR(20),
				IdFactura INT)
				
				--CREAMOS CONSULTA	
				SET @sExec = 'INSERT INTO #tmpcTraFactura SELECT ClaUbicacionNet,IdViaje,IdFabricacion,ClaCliente,ClaConsignado,ClaCiudad,ClaOrganizacion,ClaTransportista,TipoFlete,ClaMoneda,FechaFactura,KilosSurtidos,IdFacturaAlfanumerico,IdFactura
								FROM ' + @sConexionRemota + ' A WITH(NOLOCK) WHERE IdFactura = ' + convert(varchar, @pnIdFactura)
				
								
				EXEC SP_EXECUTESQL @sEXEC
				
				--ASIGNAMOS INFORMACION
				SELECT
					@nClaUbicacion = ClaUbicacion,
					@nIdViaje = IdViaje,
					@nIdFabricacion = IdFabricacion,
					@nClaCliente = ClaCliente,
					@nClaConsignado = ClaConsignado,
					@nClaCiudad = ClaCiudad,
					@nClaOrganizacion = ClaOrganizacion,
					@nClaTransportista = ClaTransportista,
					@nTipoFlete = TipoFlete,
					@nClaMoneda = ClaMoneda,
					@dFechaFactura = FechaFactura,
					@nKilosSurtidos = KilosSurtidos,
					@sIdFacturaAlfanumerico = IdFacturaAlfanumerico
				FROM #tmpcTraFactura
				WHERE IdFactura = @pnIdFactura
				
				drop table #tmpcTraFactura
			
				-- Insertar encabezado de factura en ventas local (trabajo)
				IF (@sIdFacturaAlfanumerico IS NOT NULL)
				BEGIN
				
					EXEC Ventas.VtaSch.VtaCTraFacturaIUSrv
						1, --Version
						@pnIdFactura, 
						@nClaUbicacion, 
						@nIdViaje, 
						@nIdFabricacion, 
						@nClaCliente, 
						@nClaConsignado, 
						@nClaCiudad, 
						@nClaOrganizacion, 
						@nClaTransportista, 
						@nTipoFlete, 
						@nClaMoneda, 
						@dFechaFactura, 
						@nKilosSurtidos, 
						@sIdFacturaAlfanumerico
				 
					-- Consultar detalles de factura en Oficinas Generales
					CREATE TABLE #tmpVtaCTraFacturaDet
						(
						NumRenglon      INT NOT NULL,
						IdFabricacion   INT NULL,
						NumRenglonFab   INT NULL,
						ClaArticulo     INT NULL,
						CantidadSurtida NUMERIC (22,4) NULL,
						KilosSurtidos   NUMERIC (22,4) NULL
						)
				 
					--SET @nClaSistema = 199
					--SET @sNombreClave = 'VTA3'
					--SET @sObjetoRemoto = 'VtaCTraFacturaDetVw'
					SET @nClaSistema = 1990
					SET @sNombreClave = 'VTA5'
					SET @sObjetoRemoto = 'VtaTraFacturaDetVw'
					SET @sConexionRemota = OpeSch.OpeConexionRemotaFn(@pnClaUbicacion, @nClaSistema, @sNombreClave, @sObjetoRemoto)
					
					--CREAMOS CONSULTA	
					SET @sExec = 'SELECT NumRenglon,NumRenglonFab,ClaArticulo,CantidadSurtida,KilosSurtidos
									FROM ' + @sConexionRemota + ' A WITH(NOLOCK) WHERE IdFactura = ' + CONVERT(varchar, @pnIdFactura) + ' AND NumRenglonFab <> 0'				
					SELECT @sExec ='INSERT INTO #tmpVtaCTraFacturaDet (
							NumRenglon,
							NumRenglonFab,
							ClaArticulo,
							CantidadSurtida,
							KilosSurtidos
					)' + @sExec
					
					EXEC SP_EXECUTESQL  @sExec
					
					-- Insertar cada detalle de la factura
					DECLARE @minNumRenglon INT
					DECLARE @nNumRenglonFab   INT
					DECLARE @nClaArticulo     INT
					DECLARE @nCantidadSurtida NUMERIC
				 
				 
					SELECT @minNumRenglon = MIN(NumRenglon)
					FROM #tmpVtaCTraFacturaDet
				 
					WHILE @minNumRenglon IS NOT NULL
					BEGIN
				 
						SELECT 
							@nNumRenglonFab = NumRenglonFab,
							@nClaArticulo = ClaArticulo,
							@nCantidadSurtida = CantidadSurtida,
							@nKilosSurtidos = KilosSurtidos
						FROM #tmpVtaCTraFacturaDet
						WHERE NumRenglonFab = @minNumRenglon
				 
				 
						-- Insertar encabezado de factura en ventas local (trabajo)
						EXEC Ventas.VtaSch.VtaCTraFacturaDetIUSrv
							1, --Version
							@pnIdFactura, 
							@minNumRenglon, 
							@nIdFabricacion, 
							@nNumRenglonFab, 
							@nClaArticulo, 
							@nCantidadSurtida, 
							@nKilosSurtidos
				 				 
				 
						SELECT @minNumRenglon = MIN(NumRenglon)
						FROM #tmpVtaCTraFacturaDet
						WHERE NumRenglon > @minNumRenglon
					
					END
						
				END
			END					
			ELSE 
				SELECT EsDetalleOk = 0
	END
	
				
	
	SET NOCOUNT OFF
END














Completion time: 2023-04-12T11:55:13.5828848-06:00
