GO
-- 'OpeSch.OPE_CU550_Pag32_Servicio_AutorizacionTraspasoManual_Proc'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_Servicio_AutorizacionTraspasoManual_Proc
    @pnClaTipoTraspaso          INT, --Clave de Tipo de Traspaso = 0: No Muestra Resultados / 1: Escenario Traspaso Muestra El Cliente Declarado para Ubicacion Pide / 2: Escenario Compra Filial para MP Muestra Los Clientes Declarados para Relación Filial / 3: Escenario Compra Filial para SD Muestra Los Clientes Declarados para Relación Filial
    @pnClaSolicitud             INT, --Clave de Solicitud de Traspaso Manual 
    @pnClaUsuarioMod            INT, --Usuario Autorizador
    @psNombrePcMod              VARCHAR(64),
    @pnFabricacionGenerada      INT OUT -- Identificador de Fabricación Generada para Traspaso Manual
AS
BEGIN

	SET NOCOUNT ON

    --Declaración de Variables Encabezado Fabricación

    DECLARE @nClaCliente INT,		            @nClaConsignado INT,	        @tFechaBase DATETIME,	        @tFechaPromesa DATETIME,	
			@tFechaAct DATETIME,	            @nMedioEmbarque INT,	        @tFechaVenceCarta DATETIME,     @nEsAceptaFabAntes SMALLINT,	
            @nEsAceptaParcialidad SMALLINT,     @tFechaPedido DATETIME,	        @nTipoFlete INT,                @nClaFormaPago INT,		
            @nPctParcialidad SMALLINT,          @nCargoFinanciero INT,          @nPedidoVerde INT,              @nClaTransportista INT,			
            @sPedidoCliente	 VARCHAR(15),       @nClaTipoEmbarque INT,          @sObservVenta VARCHAR(255),	    @sObservEnv VARCHAR(255),	
			@nClaClienteFacturar INT,           @nUbicacion INT,			    @tFechaVence DATETIME,          @tFechaVerde DATETIME, 
            @nEnviadoSn SMALLINT,			    @nVersion INT,                  @nTipoPuntoFinEmb INT,          @nPagamosDescargaSn SMALLINT,		
            @nParidadConvenida INT,	            @nClaIdioma SMALLINT,	        @nEsMidContinent BIT,			@nEsUbicacionLegacy	TINYINT,
			@nEsProforma SMALLINT,	            @nEsBack SMALLINT,              @nClaMetodoPago TINYINT,	    @sObservacion VARCHAR(255),		
            @nFabricacion INT,                  @nPedidoExpress SMALLINT, 	    @nClaProyecto INT,              @tFechaNecesitaCliente DATETIME,
			@nEsFabOriginal INT,				@sCuentaPago VARCHAR(30),		@nEstatusFab INT

    --Asignación de Valores Default a Variables Encabezado Fabricación
    SELECT  @nClaIdioma = 1,	        @nEsMidContinent = 0,		@nEsUbicacionLegacy = 1,	@nEsProforma = 0,	    @nEsBack = NULL,
			@sObservacion = '',		    @nEsFabOriginal = 0,		@nPedidoExpress = NULL,		@nClaProyecto = NULL,   @nClaMetodoPago = NULL,
			@sCuentaPago = NULL,	    @nEstatusFab = 4,			@tFechaVence = NULL

    --Declaración de Variables Detalle Fabricación
    DECLARE	@nNumRenglon INT,                   @nClaArticulo INT,              @nClaArticuloComponente INT,    @nCantidadComponente NUMERIC(22,4),
			@nArgumento SMALLINT,               @nCantPedida NUMERIC(19,4),     @nIdListaPrecio	INT,            @nClaTipoDescuento INT, 
            @sDesctoAdicTexto VARCHAR(10),      @nCriterio SMALLINT,            @sNomLargo VARCHAR(5),          @sNomAlto VARCHAR(5),	
            @nPctPreco NUMERIC,                 @nPrecioLista NUMERIC(19,4),    @nTipoDesctoConf INT,            @nCantSurtida NUMERIC(19,4),
            @nEsProformaDet SMALLINT,		    @nEstatusFabDet	INT,            @nCantXRenglon	INT,			@nClaClasifCliente INT,
		    @nError TINYINT,                    @sMensajeError VARCHAR(255),	@nNumRenglonPedido INT,			 @nClaUbicacionVentas INT

    --Asignación de Valores Default a Variables Detalle Fabricación
    SELECT  @nEsProformaDet = 0,        @nEstatusFabDet = 4,       @nCantXRenglon = NULL,		@nClaClasifCliente = NULL

	--------------------------------------------------------------------------
	IF ( @pnClaSolicitud > 0 )
    BEGIN
        --Proceso Encabezado
        --Consulta de Información de Solicitud y Asignación de Valores para Tipo Traspaso 1 Nivel Encabezado

        SELECT @nClaCliente				= T1.ClaCliente, --El Cliente se obtiene de la Ubicación Solicita
                @nClaConsignado			= -- El Consignado queda vacio en los Traspasos
					CASE	WHEN @pnClaTipoTraspaso = 2 THEN T1.ClaConsignado ELSE NULL END,
                @tFechaBase				= GETDATE(), 
                @tFechaNecesitaCliente	= T1.FechaDesea, 
                @tFechaPromesa			= T1.FechaDesea, 
                @tFechaAct				= T1.FechaDesea, --Los Pedidos de Traspaso que se investigaron tenian el campo informado NULL, Adriana hace petición para agregar la fecha promesa actual igual a la fecha desea que registra el usuario y ver su comportamiento
                @nMedioEmbarque			= 3, --Tipo de Medio de Embarque Declarado en Ejemplos de Traspaso
                @tFechaVenceCarta		= NULL,
                @nEsAceptaFabAntes		= T1.EsAceptaAntes, 
                @nEsAceptaParcialidad	= T1.EsAceptaParcial,
                @tFechaPedido			= GETDATE(), 
                @nTipoFlete				= 1, --Tipo de Flete Declarado en Ejemplos de Traspaso
                @nClaFormaPago			= --Forma de Pago Declarado en Ejemplos de Traspaso
					CASE	WHEN @pnClaTipoTraspaso = 1 THEN 33 ELSE 37 END,
				@nPctParcialidad		= --Pct Parcialidad Declarado en Ejemplos de Traspaso
					CASE	WHEN @pnClaTipoTraspaso = 1 THEN 0 ELSE NULL END,
				@nCargoFinanciero		= 0, --Clave Cargo Financiero Declarado en Ejemplos de Traspaso
                @nPedidoVerde			= --Pedido Verde Declarado en Ejemplos de Traspaso
					CASE	WHEN @pnClaTipoTraspaso = 1 THEN 0 ELSE NULL END,                
				@nClaTransportista		= --Clave Transportista Declarado en Ejemplos de Traspaso
					CASE	WHEN @pnClaTipoTraspaso = 1 THEN 0 ELSE NULL END, 
				@sPedidoCliente			= T1.ClaPedidoCliente,
                @nClaTipoEmbarque		=  --Clave Tipo Embarque Declarado en Ejemplos de Traspaso
					CASE	WHEN @pnClaTipoTraspaso = 1 THEN NULL ELSE 2 END, 
				@sObservVenta			= T1.Observaciones, 
                @sObservEnv				= T1.Observaciones, 
                @nClaClienteFacturar	= --Clave Cliente Facturar Declarado en Ejemplos de Traspaso
					CASE	WHEN @pnClaTipoTraspaso = 1 THEN 0 ELSE NULL END, 
				@nUbicacion				= T1.ClaUbicacionSurte, 
                @tFechaVenceCarta		= NULL,
                @tFechaVerde			= GETDATE(), 
                @nEnviadoSn				= 0, --T1.EsEnviado
                @nVersion				= 1, --Version Declarada en Ejemplos de Traspaso
                @nTipoPuntoFinEmb		= --Variable que se informar siempre como 17-DAP en Proceso de Ventas para Solicitudes de Traspaso de AG
					CASE	WHEN @pnClaTipoTraspaso = 1 THEN 17 ELSE NULL END, 
				@nPagamosDescargaSn		= 0, --Paga Descarga Declarada en Ejemplos de Traspaso
                @nParidadConvenida		= --Paridad Convenida Declarada en Ejemplos de Traspaso
					CASE	WHEN @pnClaTipoTraspaso = 1 THEN 0 ELSE NULL END
        FROM    OpeSch.OpeTraSolicitudTraspasoEncVw T1 WITH(NOLOCK)  
        WHERE   T1.IdSolicitudTraspaso = @pnClaSolicitud
        AND     T1.ClaEstatusSolicitud = 0


		--------------------------------------------------------------------------------
		IF @pnClaTipoTraspaso IN (3,4)
		BEGIN
			--Consulta / Generación de Consignado SD
			DECLARE @nFabricacionOrigen     INT = 0

			SELECT  @nFabricacionOrigen = ClaPedidoOrigen
			FROM    OpeSch.OpeTraSolicitudTraspasoEncVw WITH(NOLOCK)  
			WHERE   IdSolicitudTraspaso = @pnClaSolicitud
			AND     ClaEstatusSolicitud = 0

			EXEC    [OpeSch].[OPE_CU550_Pag32_Servicio_GeneracionConsignado_Proc]
					@pnFabricacionOrigen    = @nFabricacionOrigen,
					@pnClaClienteCuenta     = @nClaCliente, --Cuenta Cliente de Ubicación Pide
					@pnClaUsuarioMod        = @pnClaUsuarioMod,
					@psNombrePcMod          = @psNombrePcMod,
					@pnClaConsignado        = @nClaConsignado OUTPUT,
					@psMensaje				= @sMensajeError OUTPUT
		

			IF @@SERVERNAME = 'SRVDBDES01\ITKQA'
				SELECT @sMensajeError AS '@sMensajeError'

			-- Si existe error al generar el consignado, mostrará ERROR en pantalla
			IF ISNULL(@sMensajeError,'') <> ''
			BEGIN
				GOTO ABORT
			END


			IF ( ISNULL( @nClaConsignado,0 )  = 0 )
			BEGIN
				-- Consignado ya existe
				SELECT @sMensajeError = ISNULL(ERROR_MESSAGE(),'')  + '. Consignado[0,-1] (OpeSch.OPE_CU550_Pag32_Servicio_GeneracionConsignado_Proc).'
				GOTO ABORT
			END

			SELECT  'Consignado Generado No. ' + CONVERT(VARCHAR, @nClaConsignado)
		END
		--------------------------------------------------------------------------------

 		-- Ubicacion de Ventas	
		SELECT	@nClaUbicacionVentas = ClaUbicacionVentas 
		FROM	OpeSch.OpeTiCatUbicacionVw 
		WHERE	ClaUbicacion		= @nUbicacion

        --Creación de Fabricación Encabezado
        EXEC    [DEAOFINET05].Ventas.VtaSch.VtaInsVtaTraFab 
                @FechaBase		        = @tFechaBase,	
                @FechaPromesa	        = @tFechaPromesa,	
                @FechaAct		        = @tFechaAct,
                @Ubicacion		        = @nClaUbicacionVentas, --@nUbicacion,	
                @Cliente		        = @nClaCliente,		
                @Consignado		        = @nClaConsignado,
                @Observ			        = @sObservacion,		
                @ObservEnv		        = @sObservEnv,		
                @ObservVenta	        = @sObservVenta,
                @MedioEmbarque	        = @nMedioEmbarque,
                @Fabricacion	        = @nFabricacion OUTPUT,
                @dtFechaVence	        = @tFechaVence,	
                @EsAceptaFabAntes       = @nEsAceptaFabAntes,	
                @EsAceptaParcialidad    = @nEsAceptaParcialidad,
                @EsBack			        = @nEsBack,		
                @PctParcialidad	        = @nPctParcialidad,
                @PedidoExpress	        = @nPedidoExpress,	
                @ClaProyecto            = @nClaProyecto,		
                @ClaMetodoPago          = @nClaMetodoPago,
                @CuentaPago		        = @sCuentaPago,		
                @EstatusFab	            = @nEstatusFab,			
                @Version		        = @nVersion,
                @PedidoVerde	        = @nPedidoVerde,	
                @FechaVerde				= @tFechaVerde,		
                @PedidoCliente	        = @sPedidoCliente,
                @FechaPedido	        = @tFechaPedido,	
                @TipoFlete		        = @nTipoFlete,		
                @ClaFormaPago	        = @nClaFormaPago,
                @CargoFinanciero        = @nCargoFinanciero,	
                @ClaTransportista	    = @nClaTransportista,	
                @EnviadoSn              = @nEnviadoSn,
                @TipoPuntoFinEmb	    = @nTipoPuntoFinEmb,
                @ClaTipoEmbarque	    = @nClaTipoEmbarque,	
                @FechaVenceCarta	    = @tFechaVenceCarta,
                @EsFabOriginal	        = @nEsFabOriginal,		
                @ParidadConvenida	    = @nParidadConvenida,	
                @PagamosDescargaSn	    = @nPagamosDescargaSn,
                @EsProforma		        = @nEsProforma,			
                @ClaClienteFacturar	    = @nClaClienteFacturar,	
                @EsUbicacionLegacy	    = @nEsUbicacionLegacy,
                @FechaNecesitaCliente	= @tFechaNecesitaCliente,	
                @ClaIdioma		        = @nClaIdioma,	
                @EsMidContinent	        = @nEsMidContinent

        IF ( ISNULL( @nFabricacion,0 ) IN ( 0, -1 ) )
        BEGIN
			SELECT @sMensajeError = ISNULL(ERROR_MESSAGE(),'') + '. Fabricacion[0,-1] (Ventas.VtaSch.VtaInsVtaTraFab).'
            GOTO ABORT
        END
        
        SELECT  'Se Genero la Fabricación No.' + CONVERT(VARCHAR, @nFabricacion)

        --Proceso Detalle

        SELECT	@nNumRenglon = MIN( IdRenglon )
        FROM	OpeSch.OpeTraSolicitudTraspasoDetVw T1 WITH(NOLOCK)  
        WHERE	IdSolicitudTraspaso = @pnClaSolicitud
        AND     ClaEstatus = 0

        WHILE	ISNULL( @nNumRenglon,0 ) != 0
        BEGIN
            --Consulta de Información de Solicitud y Asignación de Valores para Tipo Traspaso 1 Nivel Detalle

            SELECT	@nClaArticulo		= T1.ClaProducto, 
                    @nArgumento			= 1, 
                    @nCantPedida		= T1.CantidadPedida,
                    @nCantSurtida		= NULL,
                    @nIdListaPrecio		= CASE	WHEN @pnClaTipoTraspaso = 1		 THEN 1 
												WHEN @pnClaTipoTraspaso = 4		 THEN 817559,
												ELSE 37513 END
                    @nClaTipoDescuento	= NULL, 
                    @sDesctoAdicTexto	= NULL, 
                    @nCriterio			= CASE WHEN @pnClaTipoTraspaso = 1 THEN 2 ELSE 1 END,
                    @sNomLargo			= NULL, 
                    @sNomAlto			= NULL, 
                    @nPctPreco			= 1, 
                    @nPrecioLista		= T1.PrecioLista,
                    @nTipoDesctoConf	= CASE WHEN @pnClaTipoTraspaso = 1 THEN 1 ELSE NULL END
            FROM	OpeSch.OpeTraSolicitudTraspasoDetVw T1 WITH(NOLOCK)  
            WHERE	T1.IdSolicitudTraspaso = @pnClaSolicitud
            AND		T1.IdRenglon = @nNumRenglon

            --Creación de Fabricación Detalle

            EXEC    [DEAOFINET05].Ventas.VtaSch.VtaInsVtaTraFabDet
                    @IdFabricacion	    = @nFabricacion,		
                    @ClaArticulo	    = @nClaArticulo,	
                    @CantPedida		    = @nCantPedida,
                    @NumRenglon		    = @nNumRenglonPedido OUTPUT,
                    @IdListaPrecio	    = @nIdListaPrecio,	
                    @TipoDesctoConf	    = @nTipoDesctoConf,
                    @Argumento		    = @nArgumento,		
                    @Criterio		    = @nCriterio,
                    @PctPreco		    = @nPctPreco,		
                    @EsProforma		    = @nEsProformaDet,		
                    @EstatusFab		    = @nEstatusFabDet,
                    @ClaTipoDescuento	= @nClaTipoDescuento,			
                    @DesctoAdicTexto	= @sDesctoAdicTexto,
                    @CantXRenglon		= @nCantXRenglon,				
                    @ClaClasifCliente	= @nClaClasifCliente,
                    @NomAlto		    = @sNomAlto,		
                    @NomLargo		    = @sNomLargo,
                    @Error			    = @nError OUTPUT,
                    @MensajeError	    = @sMensajeError OUTPUT,
                    @PrecioLista	    = @nPrecioLista	

            IF IsNull(@nError, 0) != 0
            BEGIN
                SELECT  @nError = @nError, @sMensajeError = ISNULL(@sMensajeError,'') + ' (Ventas.VtaSch.VtaInsVtaTraFabDet).'
                GOTO ABORT
            END

            SELECT	@nNumRenglon = MIN( IdRenglon )
			FROM	OpeSch.OpeTraSolicitudTraspasoDetVw T1 WITH(NOLOCK)  
            WHERE	IdSolicitudTraspaso = @pnClaSolicitud
            AND     ClaEstatus = 0
            AND     IdRenglon > @nNumRenglon	
        END

        --Ejecución de Proceso de Autorización Legacy

        EXEC    DEAOFINET05.Ventas.VtaSch.ReplicaTraspasoaLegacy 
                @idFabricacion = @nFabricacion

        --Actualización de Solicitud de Traspaso

        IF ( ISNULL( @nFabricacion,0 ) NOT IN ( 0, -1 ) )
        BEGIN
            UPDATE  a
            SET     a.ClaPedido = @nFabricacion,
					a.ClaConsignado = CASE WHEN @pnClaTipoTraspaso IN (3,4) THEN @nClaConsignado ELSE a.ClaConsignado END,
                    a.ClaEstatusSolicitud = 1,
                    a.EsEnviadoVta = 1,
                    a.EsEnviadoPta = 1,
                    a.FechaAutorizacion = GETDATE(),
                    a.ClaUsuarioAutoriza = @pnClaUsuarioMod,
                    a.FechaUltimaMod = GETDATE(),
                    a.ClaUsuarioMod = @pnClaUsuarioMod,
                    a.NombrePcMod = @psNombrePcMod
            FROM    OpeSch.OpeTraSolicitudTraspasoEncVw a
            WHERE   a.IdSolicitudTraspaso = @pnClaSolicitud
            AND     a.ClaEstatusSolicitud = 0

            UPDATE  b
            SET     b.ClaEstatus = 1,
                    b.FechaUltimaMod = GETDATE(),
                    b.ClaUsuarioMod = @pnClaUsuarioMod,
                    b.NombrePcMod = @psNombrePcMod
            FROM    OpeSch.OpeTraSolicitudTraspasoDetVw b
            WHERE   b.IdSolicitudTraspaso = @pnClaSolicitud
            AND     b.ClaEstatus = 0
        END
    END
	--------------------------------------------------------------------------
	SET NOCOUNT OFF    

	RETURN            

	-- Manejo de Errores              
	ABORT: 
	SELECT @sMensajeError = ISNULL(@sMensajeError,'')
	RAISERROR(@sMensajeError, 16, 1)        

END