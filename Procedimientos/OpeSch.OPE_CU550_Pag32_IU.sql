ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_IU
	@pnClaUbicacion             INT,
    @pnClaUsuarioMod            INT,	
    @psNombrePcMod              VARCHAR(64),
    @pnEsEditableEnc            INT = 0,
    @pnClaTipoTraspaso          INT = 0,
    @pnClaTipoEvento            INT = 0,
    @pnClaSolicitud	            INT OUT,
	@pnClaPedido				INT OUT,
    @pnClaPedidoCliente         VARCHAR(16),
    @pnClaPedidoOrigen          INT = 0,
    @pnCmbProyecto              INT = 0,
    @pnCmbPlantaPide            INT = 0,
    @pnCmbPlantaSurte           INT = 0,
    @pnCmbCliente               INT = 0,
    @pnCmbConsignado            INT = 0,
    @ptFechaDesea               DATETIME,
	@pnCmbTipoFlete				INT = 0,
    @pnChkAceptaAntes           INT = 0,
    @pnChkAceptaParcial         INT = 0,
    @pnChkSurtirSinExcederse    INT = 0,
    @pnChkSuministroDirecto     INT = 0,
    @pnChkLlaveEnMano           INT = 0,
	@pnChkDoorToDoor			INT = 0,
    @psObservaciones            VARCHAR(800),
    @pnClaEstatusSolicitud      INT = 0,
	@pnEsMensajeTraspaso		TINYINT =0 OUTPUT,
	@psMensajeTraspaso			VARCHAR(MAX) = '' OUTPUT,
	@pnDebug					TINYINT = 0
AS  
BEGIN
    
    SET NOCOUNT ON

	SELECT	  @pnEsMensajeTraspaso	= 0
			, @psMensajeTraspaso	= ''

    IF ( @pnClaTipoEvento = 0 )
    BEGIN
        --Validación de Registro Editable o No Editable
        IF ( ISNULL( @pnEsEditableEnc,0 ) = 1 AND ISNULL( @pnClaEstatusSolicitud,0 ) = 0 )
        BEGIN
            --Validaciones de Registro en Situación Correcta
            IF ( ISNULL( @pnCmbPlantaPide,0 ) = 0 ) --Validamos Registro de Campo Obligatorio
            BEGIN
                THROW 127001, 'Es necesario seleccionar una Planta Pide.', 1;
                RETURN
            END
            IF ( ISNULL( @pnCmbPlantaSurte,0 ) = 0 )
            BEGIN
                THROW 127002, 'Es necesario seleccionar una Planta Surte.', 1;  
                RETURN
            END
            IF ( ISNULL( @pnCmbCliente,0 ) = 0 )
            BEGIN
                THROW 127003, 'Es necesario seleccionar un Cliente.', 1;  
                RETURN
            END
            IF ( @ptFechaDesea IS NULL OR @ptFechaDesea < DATEADD( DD,1,CONVERT( DATE, GETDATE() ) ) )
            BEGIN
                THROW 127004, 'La Fecha Deseada debe ser mayor a 1 día de la Fecha Actual.', 1;  
                RETURN
            END
            IF ( LEN( ISNULL( @psObservaciones,'' ) ) = 0 ) 
            BEGIN
                THROW 127005, 'El campo de Observaciones no debe registrarse vacio', 1;
                RETURN  
            END
            IF ( ISNULL( @pnCmbPlantaPide,0 ) = ISNULL( @pnCmbPlantaSurte,0 ) ) --Validamos Que la Planta Pide y Surte sean diferentes
            BEGIN
                THROW 127006, 'La Planta Pide no puede ser la misma que la Planta Surte.', 2;  
                RETURN
            END
            IF ( (ISNULL( @pnChkSuministroDirecto,0 ) = 1 OR ISNULL(@pnChkDoorToDoor,0) = 1 ) AND ISNULL( @pnClaPedidoOrigen,0 ) = 0 ) --Validamos Que Una Solicitud de Suministro Directo Tenga Informado el Pedido Origen
            BEGIN
                THROW 127007, 'Es necesario registrar la referencia de Pedido Origen para las Solicitudes de Suministro Directo.', 3;  
                RETURN
            END
            IF ( ISNULL( @pnClaTipoTraspaso,0 ) IN (3,4) AND ISNULL( @pnCmbConsignado,0 ) > 0 ) --Validamos Que Una Solicitud de Suministro Directo No Tenga Informado el Consignado
            BEGIN
                THROW 127008, 'Una Solicitud de Suministro Directo no requiere tener informado el campo de Consignado.', 4;  
                RETURN
            END
            IF ( ISNULL( @pnClaTipoTraspaso,0 ) = 2 AND ISNULL( @pnCmbConsignado,0 ) = 0 ) --Validamos Que Una Solicitud de Compra Filial Tenga Informado el Consignado
            BEGIN
                THROW 127009, 'Una Solicitud de Compra Filial requiere tener informado el campo de Consignado.', 5;  
                RETURN
            END
            IF ( ISNULL( @pnClaTipoTraspaso,0 ) = 1 AND ISNULL( @pnCmbConsignado,0 ) > 0 ) --Validamos Que Una Solicitud de Traspaso No Tenga Informado el Consignado
            BEGIN
                THROW 127010, 'Una Solicitud de Traspaso no requiere tener informado el campo de Consignado.', 6;  
                RETURN
            END
            IF ( ISNULL( @pnCmbTipoFlete,0 ) = 0 )
            BEGIN
                THROW 127003, 'Es necesario seleccionar un Tipo de Flete.', 1;  
                RETURN
            END

			-- Validar que una Planta de Ingetek se encuentre como Planta Pide o Plantas Surte en la Solicitud
			/*
			IF NOT EXISTS (
				SELECT	1 
				FROM	OpeSch.OpeTiCatUbicacionVw WITH(NOLOCK)  
				WHERE	(ClaEmpresa IN (52)
						 OR	ClaUbicacion IN (277,278,364)
						)
				AND		(ClaUbicacion = @pnCmbPlantaPide OR ClaUbicacion = @pnCmbPlantaSurte)
			)
			*/
			IF NOT EXISTS (
				SELECT	1 
				FROM	OpeSch.OpeTiCatUbicacionIngetekVw WITH(NOLOCK)  
				WHERE	(ClaUbicacion = @pnCmbPlantaPide OR ClaUbicacion = @pnCmbPlantaSurte) )
			BEGIN
				RAISERROR('Es necesario que el traspaso manual este compuesto por al menos una Ubicación de Ingetek',16,1)
				RETURN
			END


            --Definimos si sera proceso de Registro o Edición
            IF ( NOT EXISTS ( SELECT 1 FROM OpeSch.OpeTraSolicitudTraspasoEncVw WHERE IdSolicitudTraspaso = @pnClaSolicitud )
                    OR ISNULL( @pnClaSolicitud,0 ) = 0  ) -- Proceso de Registro
            BEGIN
                --IF ISNULL( @pnClaTipoTraspaso,0 ) IN (3,4)
                --BEGIN
                --    SET @pnChkAceptaParcial = 0
                --END
                
                INSERT INTO OpeSch.OpeTraSolicitudTraspasoEncVw
                        (ClaPedidoCliente,          ClaPedidoOrigen,        ClaCliente,             ClaProyecto,            ClaConsignado,
                        ClaUbicacionSolicita,       ClaUbicacionSurte,      FechaDesea,             ClaEstatusSolicitud,    Observaciones,
                        ClaMotivoRechazo,           ComentariosRechazo,     EsAceptaAntes,          EsAceptaParcial,        EsSurtirSinExcederse,
                        EsSuministroDirecto,        EsLlaveEnMano,          EsCanceladaSolicitud,   EsCanceladoPedido,      FechaCancela,
                        ClaUsuarioCancela,          EsEnviadoVta,           EsEnviadoPta,           FechaAutorizacion,      ClaUsuarioAutoriza,
                        FechaIns,                   ClaUsuarioIns,          FechaUltimaMod,         ClaUsuarioMod,          NombrePcMod,
						EsDoorToDoor,				ClaTipoFlete)
                SELECT  @pnClaPedidoCliente,        @pnClaPedidoOrigen,     @pnCmbCliente,          @pnCmbProyecto,         @pnCmbConsignado,
                        @pnCmbPlantaPide,           @pnCmbPlantaSurte,      @ptFechaDesea,          0,                      @psObservaciones,
                        NULL,                       NULL,                   @pnChkAceptaAntes,      @pnChkAceptaParcial,    @pnChkSurtirSinExcederse,
                        @pnChkSuministroDirecto,    @pnChkLlaveEnMano,      NULL,                   NULL,                   NULL,
                        NULL,                       0,                      0,                      NULL,                   NULL,
                        GETDATE(),                  @pnClaUsuarioMod,       GETDATE(),              @pnClaUsuarioMod,       @psNombrePcMod,
						@pnChkDoorToDoor,			@pnCmbTipoFlete


                SELECT  @pnClaSolicitud = @@IDENTITY      

                --IF ( ISNULL( @pnClaTipoTraspaso,0 ) IN (3,4) AND @pnClaPedidoOrigen > 0 AND @pnClaSolicitud > 0 )
				IF 	( @pnClaPedidoOrigen > 0 AND @pnClaSolicitud > 0 ) --Considerar todos los Tipos de Traspasos Hv_07/03/23
                BEGIN
                    EXEC    OpeSch.OPE_CU550_Pag32_Servicio_CargaPartidasOrigen_Proc
                            @pnClaSolicitud             = @pnClaSolicitud,
                            @pnClaPedidoOrigen          = @pnClaPedidoOrigen,
                            @pnClaTipoTraspaso          = @pnClaTipoTraspaso,
                            @pnClaUsuarioMod            = @pnClaUsuarioMod,
                            @psNombrePcMod				= @psNombrePcMod,
							@psMensajeTraspaso			= @psMensajeTraspaso OUTPUT,
							@pnClaUbicacion				= @pnClaUbicacion
                END
            END
            ELSE IF ( EXISTS ( SELECT 1 FROM OpeSch.OpeTraSolicitudTraspasoEncVw WHERE IdSolicitudTraspaso = @pnClaSolicitud AND ClaEstatusSolicitud IN (0) ) ) -- Proceso de Edición
            BEGIN
                --IF ISNULL( @pnClaTipoTraspaso,0 ) IN (3,4)
                --BEGIN
                --    SET @pnChkAceptaParcial = 0
                --END

                UPDATE  a
                SET     ClaPedidoCliente        = @pnClaPedidoCliente,  
                        ClaPedidoOrigen         = @pnClaPedidoOrigen,        
                        ClaCliente              = @pnCmbCliente,             
                        ClaProyecto             = @pnCmbProyecto,            
                        ClaConsignado           = @pnCmbConsignado,
                        ClaUbicacionSolicita    = @pnCmbPlantaPide,       
                        ClaUbicacionSurte       = @pnCmbPlantaSurte,      
                        FechaDesea              = @ptFechaDesea,       
                        Observaciones           = @psObservaciones,
                        EsAceptaAntes           = @pnChkAceptaAntes,          
                        EsAceptaParcial         = @pnChkAceptaParcial,        
                        EsSurtirSinExcederse    = @pnChkSurtirSinExcederse,
                        EsSuministroDirecto     = @pnChkSuministroDirecto,        
                        EsLlaveEnMano           = @pnChkLlaveEnMano,          
                        FechaUltimaMod          = GETDATE(),         
                        ClaUsuarioMod           = @pnClaUsuarioMod,          
                        NombrePcMod             = @psNombrePcMod,
						EsDoorToDoor			= @pnChkDoorToDoor,
						ClaTipoFlete			= @pnCmbTipoFlete
                FROM    OpeSch.OpeTraSolicitudTraspasoEncVw a 
                WHERE   a.IdSolicitudTraspaso = @pnClaSolicitud
                AND     a.ClaEstatusSolicitud = 0
            END
        END
    END
    ELSE IF ( @pnClaTipoEvento = 1 )
    BEGIN
        EXEC    [OpeSch].[OPE_CU550_Pag32_Servicio_AutorizacionTraspasoManual_Proc]
                @pnClaTipoTraspaso          = @pnClaTipoTraspaso,   --Clave de Tipo de Traspaso = 0: No Muestra Resultados / 1: Escenario Traspaso Muestra El Cliente Declarado para Ubicacion Pide / 2: Escenario Compra Filial para MP Muestra Los Clientes Declarados para Relación Filial / 3: Escenario Compra Filial para SD Muestra Los Clientes Declarados para Relación Filial
                @pnClaSolicitud             = @pnClaSolicitud,      --Clave de Solicitud de Traspaso Manual 
                @pnClaUsuarioMod            = @pnClaUsuarioMod,     --Usuario Autorizador
                @psNombrePcMod              = @psNombrePcMod,
                @pnFabricacionGenerada      = @pnClaPedido OUTPUT,   --Identificador de Fabricación Generada para Traspaso Manual
				@pnDebug					= @pnDebug    
	END
    ELSE IF ( @pnClaTipoEvento = 2 )
    BEGIN
        EXEC    [OpeSch].[OPE_CU550_Pag32_Servicio_CancelacionSolicitud_Proc]
                @pnClaSolicitud             = @pnClaSolicitud,		--Clave de Solicitud de Traspaso Manual 
                @pnClaUsuarioMod            = @pnClaUsuarioMod,		--Usuario Cancelador
                @psNombrePcMod              = @psNombrePcMod
    END
    ELSE IF ( @pnClaTipoEvento = 3 )
    BEGIN
        EXEC    [OpeSch].[OPE_CU550_Pag32_Servicio_CancelacionPedido_Proc]
                @pnClaSolicitud             = @pnClaSolicitud,		--Clave de Solicitud de Traspaso Manual 
                @pnClaPedido                = @pnClaPedido,			--Id Fabricacion de Traspaso Manual
                @pnClaUsuarioMod            = @pnClaUsuarioMod,		--Usuario Autorizador
                @psNombrePcMod              = @psNombrePcMod
    END

	IF ISNULL(@psMensajeTraspaso,'') <> '' 
		SELECT	@pnEsMensajeTraspaso = 1
			

    SELECT  @pnClaSolicitud = @pnClaSolicitud,
            @pnClaPedido    = @pnClaPedido   

    SET NOCOUNT OFF    

	RETURN
END