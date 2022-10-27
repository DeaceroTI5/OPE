---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
		SELECT TOP 50 * FROM deaofinet05.ventas.VtaSch.VtaTraProforma WHERE idproforma = @nIdProforma
		SELECT TOP 50 * FROM deaofinet05.ventas.VtaSch.VtaTraProformadet WHERE  idproforma = @nIdProforma
		SELECT TOP 50 * FROM deaofinet05.ventas.VtaSch.VtaTraProformaComentario WHERE  idproforma = @nIdProforma

*/

CREATE PROCEDURE OpeSch.OpeEstimacionGenerarFacturaServ
						  @pnClaUbicacion			INT
						, @pnidEstimacionFactura	INT
						, @psNombrePcMod			VARCHAR(64)
						, @pnClaUsuarioMod			INT
						, @pnIdProforma				INT = NULL OUTPUT
AS
BEGIN

--PRINT 1
--			RAISERROR('error controlado', 16, 1)
--			RETURN
--PRINT 2

	DECLARE
		@pnCerrarFactura	INT,
		@nEsUsarNet			TINYINT,
		@sErrorMsg			VARCHAR(500),
		@nNumFabricaciones	INT


	-- Ubicacion de Ventas
	DECLARE @nClaUbicacionVentas INT
	
	SELECT	@nClaUbicacionVentas = ClaUbicacionVentas 
	FROM	OpeSch.OpeTiCatUbicacionVw 
	WHERE	ClaUbicacion		= @pnClaUbicacion


	-- CAMPOS PARA EL SERVICIO DE ENCABEZADO
	DECLARE 
		  @dFechaBaseFabricacion		DATETIME
		, @nIdFabricacion				INT
		, @nOrganizacion				int				-- Clave del agente
		, @sPedidoCliente				varchar(15)
		, @dFechaPedido					datetime
		, @nCliente						int				-- CLave de la cuenta del Cliente
		, @nConsignado					int				-- Clave del consignado
		, @nCiudad						int				-- Clave de la ciudad (verificar dato en base al valor de @EsUsarNet)
		, @nTipoFlete					int				-- Clave del tipo de flete
		, @nIva							numeric(19,4)	-- Pct iva
		, @nFormaPago					int				-- calve de la forma de pago
		, @nDiasPlazo					int
		, @sObservVenta					varchar(255)
		, @nMedioEmbarque				int				-- Clave del medio de embarque
		, @nClaTipoEmbarque				int
		, @dFechaVenceCarta				datetime		-- Fecha de vencimiento de la factura
		, @nIdProforma					int				-- Clave de la Proforma = IdFabricacion
		, @nEsBack						smallint = 0	-- 1= realiza ResultSet del IdProforma
		, @nClaProyecto					int = null
		, @nClaMovCargo					int 
		, @sComentariosFactura			varchar(8000) = null      -- Comentarios que se agregan en el cuerpo del PDF de la factura.
		, @nClaMetodoPagoSAT			varchar(3) = null
		, @nClaUsoCFDI					int = null
		, @nEsVentaInterempresa			tinyint = 0
		, @sComentariosMotivoProforma	varchar(250) = null
		, @nEsRetieneIva				tinyint = 0
		, @ObservacionEstimacion		varchar(8000) = null 

	-- CAMPOS DEL SERVICIO DE DETALLE
	DECLARE
		  @nClaArticulo					int
		, @nIdFabricacionDet			INT
		, @nClaLisPrecio				int
		, @nPrecioLista					numeric(19,4)
		, @nPrecioConfidencial			numeric(19,4)
		, @nTipoCargoFlete				int
		, @nImpCargoFlete				numeric(19,4)
		, @nPrecioEntrega				numeric(19,4)     -- Precio Neto Unitario
		, @nCantidadPedida				numeric(19,4)
		, @nCantidadSurtida				numeric(19,4)
		, @sUnidadDeVenta				varchar(30)
		, @sNomProductoFacturar			varchar(100)
		, @nTipoDesctoConf				int
		, @nNumeroDeRenglon				int
		, @nClaTipoDescuento			int = null
		, @sDesctoAdicionalTexto		varchar(10) = null
		, @nProducidoXDeacero			tinyint = null
		, @sComentariosFacturaDet		varchar(8000) = null      -- Comentarios adicionales que se agregan debajo del producto en el PDF de la Factura.
		, @nEsPrecioEntregaUnitario		tinyint


		SET @pnCerrarFactura		= 1
		SET @nEsBack				= 0
		SET @nEsUsarNet				= 1		-- Significa que se usarán los datos de los catálogos de Net.
		SET @nEsVentaInterempresa	= 0
		SET @nEsPrecioEntregaUnitario = 0

		-- REVISAR SI HAY DETALLE DE ARTICULOS PARA FACTURAR
		IF NOT EXISTS (SELECT 1
					FROM OpeSch.OpeTraFacturaEstimacion
					WHERE ClaUbicacion = @pnClaUbicacion
					AND idEstimacionFactura = @pnidEstimacionFactura
					AND Estatus = 1 )
		BEGIN
			PRINT @pnidEstimacionFactura
			PRINT 'ES AQUI 1'
			SET @sErrorMsg = 'El estado de la estimación es invalido'
			GOTO ERROR
		END
				
		-- REVISAR SI HAY DETALLE DE ARTICULOS PARA FACTURAR
		SELECT @nNumFabricaciones = COUNT(DISTINCT idFabricacion)
		FROM OpeSch.OpeTraFacturaEstimacionDet
		WHERE ClaUbicacion = @pnClaUbicacion
		AND idEstimacionFactura = @pnidEstimacionFactura
		AND CantSurtida > 0
		
		IF ISNULL(@nNumFabricaciones,0) = 0
		BEGIN
			SET @sErrorMsg = 'No hay detalle para facturar'
			GOTO ERROR
		END

		--IF ISNULL(@nNumFabricaciones,0) > 1
		--BEGIN
		--	SET @sErrorMsg = 'Este proceso solo permite facturar una fabricacion a la vez'
		--	GOTO ERROR
		--END
		
		SELECT @nIdFabricacion = NULL

		SELECT 
			@nIdFabricacion			= MIN(idFabricacion)
		FROM OpeSch.OpeTraFacturaEstimacion
		WHERE ClaUbicacion = @pnClaUbicacion
		AND idEstimacionFactura = @pnidEstimacionFactura
		AND Estatus = 1

		WHILE @nIdFabricacion IS NOT NULL
		BEGIN

			SELECT 
				@sComentariosFactura	= ComentariosFactura,
				@ObservacionEstimacion	= ObservacionEstimacion
			FROM OpeSch.OpeTraFacturaEstimacion
			WHERE ClaUbicacion = @pnClaUbicacion
			AND idEstimacionFactura = @pnidEstimacionFactura
			AND idFabricacion = @nIdFabricacion
			AND Estatus = 1

			
			SELECT

					  @dFechaBaseFabricacion		= FechaBaseFabricacion
					, @nOrganizacion				= ClaAgente
					, @sPedidoCliente				= ClaPedidoCliente				
					, @dFechaPedido					= FechaPedidoCliente
					, @nCliente						= ClaCliente
					, @nConsignado					= ClaConsignado
					, @nCiudad						= ClaCiudad
					, @nTipoFlete					= ClaTipoFlete
					, @nIva							= PorcentajeIVA
					, @nFormaPago					= ClaFormaPago
					, @nDiasPlazo					= DiasPlazoConfidencial
					, @sObservVenta					= ObsVenta
					, @nMedioEmbarque				= ClaMedioEmbarque
					, @nClaTipoEmbarque				= ClaTipoEmbarque
					, @nClaProyecto					= a.ClaProyecto
					, @nClaMetodoPagoSAT			= ClaMetodoPagoSat
					, @nClaUsoCFDI					= ClaUsoCFDI
					, @nEsRetieneIva				= EsRetieneIva
					, @sComentariosMotivoProforma	= 'Generada Por Sistema Operaciones Ingetek (Estimacion)'

			FROM deaofinet05.ventas.VtaSch.VtaTraFabricacion  a WITH(NOLOCK)
			INNER JOIN	OpeSch.OpeVtaRelFabricacionProyectoVw b WITH(NOLOCK)
			ON b.idFabricacion = a.idFabricacion
			WHERE a.IdFabricacion = @nIdFabricacion

--EXEC deaofinet05.ventas.dbo.sp_helptext 'VtaSch.VtaInsertaProformaSrv'
PRINT 'Inicio- EXEC deaofinet05.ventas.VtaSch.VtaInsertaProformaSrv'
PRINT '@nIdFabricacion'+' '+convert(varchar,@nIdFabricacion)

			EXEC deaofinet05.ventas.VtaSch.VtaInsertaProformaSrv
				   @FechaBaseFabricacion			=	@dFechaBaseFabricacion
				   , @Organizacion					=	@nOrganizacion
				   , @Planta						=	@nClaUbicacionVentas --@pnClaUbicacion
				   , @PedidoCliente					=	@sPedidoCliente
				   , @FechaPedido					=	@dFechaPedido				---- de Pedi
				   , @Cliente						=	@nCliente					---- de Pedi
				   , @Consignado					=	@nConsignado				---- de Pedi
				   , @Ciudad						=	@nCiudad					---- de Pedi
				   , @TipoFlete						=	@nTipoFlete					---- de Pedi
				   , @Iva							=	@nIva						---- de Pedi
				   , @FormaPago						=	@nFormaPago					---- de Pedi
				   , @Observ						=	@ObservacionEstimacion		---- de estimacion
				   , @DiasPlazo						=	@nDiasPlazo					---- de Pedi
				   , @ObservEnv						=	NULL
				   , @ObservVenta					=	@sObservVenta
				   , @CargoFinanciero				=	NULL
				   , @PorcentajeCargo				=	NULL
				   , @ClaTransportista				=	NULL						---- de Pedi
				   , @MedioEmbarque					=	@nMedioEmbarque				---- de Pedi
				   , @TipoPuntoFinalEmbarque		=	NULL
				   , @ClaTipoEmbarque				=	@nClaTipoEmbarque
				   , @FechaVenceCarta				=	NULL
				   , @ParidadConvenida				=	NULL
				   , @PagamosDescarga				=	NULL
				   , @IdProforma					=	@nIdProforma	OUTPUT
				   , @EsBack						=	@nEsBack
				   , @ClaProyecto					=	@nClaProyecto				---- de Pedi
				   , @EsFactRamos					=	NULL
				   , @ClaMovCargo					=	1							-- 1= Factura de Embarque   21) retención. 6% ---- 
				   , @ComentariosFactura			=	@sComentariosFactura
				   , @EsUsarNet						=	@nEsUsarNet
				   , @ClaMetodoPagoSAT				=	@nClaMetodoPagoSAT			---- de Pedi
				   , @ClaUsoCFDI					=	@nClaUsoCFDI				---- de Pedi
				   , @EsVentaInterempresa			=	@nEsVentaInterempresa
				   , @EsRespaldoBita				=	1
				   , @ComentariosMotivoProforma		=	@sComentariosMotivoProforma
				   , @ClavePedimento				=	NULL
				   , @EsRetieneIva					=	@nEsRetieneIva				---- de Pedi
				   , @PctRetencionIva				=	NULL						---- de Pedi
				   , @IdFabricacion					=	@nIdFabricacion				---- Fabricación

PRINT 'Fin- EXEC deaofinet05.ventas.VtaSch.VtaInsertaProformaSrv'


			SELECT	@nIdFabricacionDet = MIN(IdFabricacionDet)
			FROM	OpeSch.OpeTraFacturaEstimacionDet
			WHERE	ClaUbicacion = @pnClaUbicacion
			AND		idEstimacionFactura = @pnidEstimacionFactura
			AND		idFabricacion = @nidFabricacion

			WHILE @nIdFabricacionDet IS NOT NULL
			BEGIN

				SELECT 
					@sNomProductoFacturar	= a.NomProductoFacturar,
					@sComentariosFacturaDet	= a.ComentariosFacturaDet,
					@nCantidadSurtida		= a.CantSurtida

				FROM	OpeSch.OpeTraFacturaEstimacionDet a
				WHERE	a.ClaUbicacion = @pnClaUbicacion
				AND		a.idEstimacionFactura = @pnidEstimacionFactura
				AND		a.IdFabricacion		= @nIdFabricacion
				AND		a.IdFabricacionDet	= @nIdFabricacionDet


				SELECT 
						@nClaArticulo			=	ClaArticulo,
						@nClaLisPrecio			=	ClaListaPrecio,
						@nPrecioLista			=	PrecioLista,
						@nPrecioConfidencial	=	PrecioConfidencial,
						@nTipoCargoFlete		=	TipoCargoFlete,
						@nImpCargoFlete			=	ImporteCargoFlete,
						@nPrecioEntrega			=	PrecioEntrega,
						@nCantidadPedida		=	CantidadPedida,
						@sUnidadDeVenta			=	NombreUnidadVenta,
						@nNumeroDeRenglon		= NULL
				FROM deaofinet05.ventas.VtaSch.VtaTraFabricacionDet  a WITH(NOLOCK)
				INNER JOIN	OpeSch.OpeVtaRelFabricacionProyectoVw b WITH(NOLOCK)
				ON b.idFabricacion = a.idFabricacion
				WHERE	a.IdFabricacion = @nIdFabricacion
				AND		a.NumeroRenglon = @nIdFabricacionDet	
				


--exec deaofinet05.ventas.dbo.sp_help 'VtaSch.VtaTraFabricacionDet'
PRINT 'Inicio-Exec deaofinet05.ventas.VtaSch.VtaInsertaProformaDetSrv'	
PRINT '@nClaArticulo'+' '+convert(varchar,@nClaArticulo)

				EXEC deaofinet05.ventas.VtaSch.VtaInsertaProformaDetSrv		
						@IdProforma					=	@nIdProforma
						,@ClaArticulo				=	@nClaArticulo
						,@ClaLisPrecio				=	@nClaLisPrecio
						,@PrecioLista				=	@nPrecioLista
						,@PrecioConfidencial			=	@nPrecioConfidencial
						,@DesctoLineaTexto			=	NULL
						,@DesctoLineaValor			=	NULL
						,@TipoCargoFlete				=	@nTipoCargoFlete
						,@ImpCargoFlete				=	@nImpCargoFlete
						,@DesctoConfTexto			=	NULL
						,@DesctoConfValor			=	NULL
						,@TipoBonifFlete				=	NULL
						,@ImpBonifFlete				=	NULL
						,@ImpCargoFleteZona			=	NULL
						,@PrecioEntrega				=	@nPrecioEntrega				-- Precio Neto Unitario
						,@CantidadPedida			=	@nCantidadSurtida --@nCantidadPedida
						,@UnidadDeVenta				=	@sUnidadDeVenta
						,@NomProductoFacturar		=	@sNomProductoFacturar
						,@Calibre					=	NULL
						,@Disenio					=	NULL
						,@Alto						=	NULL
						,@Largo						=	NULL
						,@TipoDesctoConf				=	NULL
						,@NumeroDeRenglon			=	@nNumeroDeRenglon		OUTPUT
						,@ClaTipoDescuento			=	NULL
						,@DesctoAdicionalTexto		=	NULL
						,@ProducidoXDeacero			=	0
						,@ComentariosFactura			=	@sComentariosFacturaDet		-- Comentarios adicionales que se agregan debajo del producto en el PDF de la Factura.
						,@EsPrecioEntregaUnitario	=	0
						,@EsUsarNet					=	@nEsUsarNet
						,@EsResultSet				=	0
						,@EsRespaldoBita				=	1
						,@ImporteFleteEstadistico	=	NULL

PRINT 'Fin-Exec deaofinet05.ventas.VtaSch.VtaInsertaProformaDetSrv'	
PRINT '@nNumeroDeRenglon'+' '+convert(varchar,@nNumeroDeRenglon)
PRINT '@nIdFabricacionDet'+' '+convert(varchar,@nIdFabricacionDet)

				-- VALIDAR CON @nNumeroDeRenglon SI TODO FUNCIONÓ CORRECTAMENTE
				IF @nNumeroDeRenglon != @nIdFabricacionDet
				BEGIN
					PRINT 'ES AQUI 2'
					--SET @sErrorMsg = 'El numero de renglon generado es diferente al numero de renglon de la fabricacion'
					--GOTO ERROR
				END	


				SELECT	@nIdFabricacionDet = MIN(IdFabricacionDet)
				FROM	OpeSch.OpeTraFacturaEstimacionDet
				WHERE	ClaUbicacion = @pnClaUbicacion
				AND		idEstimacionFactura = @pnidEstimacionFactura
				AND		IdFabricacion = @nIdFabricacion
				AND		IdFabricacionDet > @nIdFabricacionDet 

			END -- WHILE @nIdFabricacionDet

			IF @pnCerrarFactura = 1
			BEGIN

Print 'Inicio-deaofinet05.ventas.VtaSch.VtaGeneraProformaFacturaAutomaticoSrv'
PRINT '@nIdProforma' +' '+convert(varchar,@nIdProforma)

				EXEC deaofinet05.ventas.VtaSch.VtaGeneraProformaFacturaAutomaticoSrv
						 @IdProforma			=	@nIdProforma
					   , @EsUsarNet				=	@nEsUsarNet
					   , @IdGrupoProforma		=	NULL
					   , @psNombrePcMod			=	@psNombrePcMod
					   , @pnClaUsuarioMod		=	@pnClaUsuarioMod

Print 'fin-deaofinet05.ventas.VtaSch.VtaGeneraProformaFacturaAutomaticoSrv'

				UPDATE OpeSch.OpeTraFacturaEstimacion
				SET IdProforma		= @nIdProforma,
					Estatus			= 3,
					FechaFactura	= GETDATE(),
					FechaUltimaMod	= GETDATE()
				WHERE ClaUbicacion = @pnClaUbicacion
				AND idEstimacionFactura = @pnidEstimacionFactura
				AND @nIdFabricacion = @nidFabricacion
				AND Estatus = 1

				SET @pnIdProforma = @nIdProforma

			END

			SELECT	@nidFabricacion = MIN(IdFabricacion)
			FROM	OpeSch.OpeTraFacturaEstimacionDet
			WHERE	ClaUbicacion = @pnClaUbicacion
			AND		idEstimacionFactura = @pnidEstimacionFactura
			AND		idFabricacion > @nidFabricacion	

		END --WHILE idFabricacion

	GOTO FINAL

	ERROR:
			RAISERROR(@sErrorMsg, 16, 1)
			RETURN



	FINAL:


END