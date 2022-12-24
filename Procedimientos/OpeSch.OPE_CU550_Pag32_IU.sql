USE Operacion
GO
-- 'OpeSch.OPE_CU550_Pag32_IU'
GO
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
    @pnChkAceptaAntes           INT = 0,
    @pnChkAceptaParcial         INT = 0,
    @pnChkSurtirSinExcederse    INT = 0,
    @pnChkSuministroDirecto     INT = 0,
    @pnChkLlaveEnMano           INT = 0,
	@pnChkDoorToDoor			INT = 0,
    @psObservaciones            VARCHAR(800),
    @pnClaEstatusSolicitud      INT = 0,
	@pnEsMensajeTraspaso		TINYINT =0 OUTPUT,
	@psMensajeTraspaso			VARCHAR(MAX) = '' OUTPUT
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

			-- Validar que una Planta de Ingetek se encuentre como Planta Pide o Plantas Surte en la Solicitud
			IF NOT EXISTS (
				SELECT	1 
				FROM	OpeSch.OpeTiCatUbicacionVw WITH(NOLOCK)  
				WHERE	(ClaEmpresa IN (52)
						 OR	ClaUbicacion IN (277,278,364)
						)
				AND		(ClaUbicacion = @pnCmbPlantaPide OR ClaUbicacion = @pnCmbPlantaSurte)
			)
			BEGIN
				RAISERROR('Es necesario que el traspaso manual este compuesto por al menos una Ubicación de Ingetek',16,1)
				RETURN
			END


            --Definimos si sera proceso de Registro o Edición
            IF ( NOT EXISTS ( SELECT 1 FROM OpeSch.OpeTraSolicitudTraspasoEncVw WHERE IdSolicitudTraspaso = @pnClaSolicitud )
                    OR ISNULL( @pnClaSolicitud,0 ) = 0  ) -- Proceso de Registro
            BEGIN
                IF ISNULL( @pnClaTipoTraspaso,0 ) IN (3)
                BEGIN
                    SET @pnChkAceptaParcial = 0
                END
                
                INSERT INTO OpeSch.OpeTraSolicitudTraspasoEncVw
                        (ClaPedidoCliente,          ClaPedidoOrigen,        ClaCliente,             ClaProyecto,            ClaConsignado,
                        ClaUbicacionSolicita,       ClaUbicacionSurte,      FechaDesea,             ClaEstatusSolicitud,    Observaciones,
                        ClaMotivoRechazo,           ComentariosRechazo,     EsAceptaAntes,          EsAceptaParcial,        EsSurtirSinExcederse,
                        EsSuministroDirecto,        EsLlaveEnMano,          EsCanceladaSolicitud,   EsCanceladoPedido,      FechaCancela,
                        ClaUsuarioCancela,          EsEnviadoVta,           EsEnviadoPta,           FechaAutorizacion,      ClaUsuarioAutoriza,
                        FechaIns,                   ClaUsuarioIns,          FechaUltimaMod,         ClaUsuarioMod,          NombrePcMod,
						EsDoorToDoor)
                SELECT  @pnClaPedidoCliente,        @pnClaPedidoOrigen,     @pnCmbCliente,          @pnCmbProyecto,         @pnCmbConsignado,
                        @pnCmbPlantaPide,           @pnCmbPlantaSurte,      @ptFechaDesea,          0,                      @psObservaciones,
                        NULL,                       NULL,                   @pnChkAceptaAntes,      @pnChkAceptaParcial,    @pnChkSurtirSinExcederse,
                        @pnChkSuministroDirecto,    @pnChkLlaveEnMano,      NULL,                   NULL,                   NULL,
                        NULL,                       0,                      0,                      NULL,                   NULL,
                        GETDATE(),                  @pnClaUsuarioMod,       GETDATE(),              @pnClaUsuarioMod,       @psNombrePcMod,
						@pnChkDoorToDoor


                SELECT  @pnClaSolicitud = @@IDENTITY      

                IF ( ISNULL( @pnClaTipoTraspaso,0 ) IN (3,4) AND @pnClaPedidoOrigen > 0 AND @pnClaSolicitud > 0 )
                BEGIN
                    EXEC    OpeSch.OPE_CU550_Pag32_Servicio_CargaPartidasOrigen_Proc
                            @pnClaSolicitud             = @pnClaSolicitud,
                            @pnClaPedidoOrigen          = @pnClaPedidoOrigen,
                            @pnClaTipoTraspaso          = @pnClaTipoTraspaso,
                            @pnClaUsuarioMod            = @pnClaUsuarioMod,
                            @psNombrePcMod              = @psNombrePcMod,
							@psMensajeTraspaso			= @psMensajeTraspaso OUTPUT
                END
            END
            ELSE IF ( EXISTS ( SELECT 1 FROM OpeSch.OpeTraSolicitudTraspasoEncVw WHERE IdSolicitudTraspaso = @pnClaSolicitud AND ClaEstatusSolicitud IN (0) ) ) -- Proceso de Edición
            BEGIN
                IF ISNULL( @pnClaTipoTraspaso,0 ) IN (3,4)
                BEGIN
                    SET @pnChkAceptaParcial = 0
                END

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
						EsDoorToDoor			= @pnChkDoorToDoor
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
                @pnFabricacionGenerada      = @pnClaPedido OUTPUT   --Identificador de Fabricación Generada para Traspaso Manual
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

	--IF @@SERVERNAME = 'SRVDBDES01\ITKQA'
	--	SELECT @psMensajeTraspaso = '<!DOCTYPE html>     <html>     <style type="text/css">      .tabla{font-family:Arial;font-size:12px;color:#000000;}      .header{color:#FFFFFF;background-color:#3dbab3;}      .texto1{color=#000000" style="font-family: Arial; font-size: 10pt;}      .centrar{text-align: center;}      .izquierda{text-align: left;}      .derecha{text-align: right;}     </style>     <body>      <FONT class="texto1">      <h5><strong>AVISO:</strong></h5>        <p>Las siguientes partidas del pedido Origen <b>23416945</b> se identificaron para otras solicitudes:</FONT></br></br>     <table class="tabla" cellspacing="0" border="1" width="100%">      <tr class="header">        <th WIDTH="5%">Pedido</th>        <th WIDTH="20%">Producto</th>        <th WIDTH="3%">Unidad</th>        <th WIDTH="4%">Cant. Pedida Cliente</th>        <th WIDTH="4%">Cant. Solicitada</th>        <th WIDTH="4%">Cant. Disponible</th>        <th WIDTH="6%">Etatus MP</th>      </tr><tr><td class="centrar" bgcolor="#bdbdbd">23281999</td><td class="izquierda" bgcolor="#bdbdbd">23619 - FLAT BAR 1" x 3/16" A36/529-50 24 2.5T ASTM A6/A36/A529-50</td><td class="centrar" bgcolor="#bdbdbd">BDL</td><td class="derecha" bgcolor="#bdbdbd">50</td><td class="derecha" bgcolor="#bdbdbd">12</td><td class="derecha" bgcolor="#bdbdbd">28</td><td class="centrar" bgcolor="#bdbdbd">Pendiente Total</td></tr><tr><td class="centrar" bgcolor="white">23514668</td><td class="izquierda" bgcolor="white">23619 - FLAT BAR 1" x 3/16" A36/529-50 24 2.5T ASTM A6/A36/A529-50</td><td class="centrar" bgcolor="white">BDL</td><td class="derecha" bgcolor="white">50</td><td class="derecha" bgcolor="white">10</td><td class="derecha" bgcolor="white">28</td><td class="centrar" bgcolor="white">Surtida Parcial</td></tr><tr><td class="centrar" bgcolor="#bdbdbd">23281999</td><td class="izquierda" bgcolor="#bdbdbd">23620 - FLAT BAR 1 1/4" x 3/16" A36/529-50 24 2.5T ASTM A6/A36/A529-50</td><td class="centrar" bgcolor="#bdbdbd">BDL</td><td class="derecha" bgcolor="#bdbdbd">42</td><td class="derecha" bgcolor="#bdbdbd">42</td><td class="derecha" bgcolor="#bdbdbd">0</td><td class="centrar" bgcolor="#bdbdbd">Surtida Total</td></tr><tr><td class="centrar" bgcolor="white">23281999</td><td class="izquierda" bgcolor="white">60582 - FLAT BAR 1" x 3/16" A-36 20 2.0T ASTM A6/A36</td><td class="centrar" bgcolor="white">BDL</td><td class="derecha" bgcolor="white">88</td><td class="derecha" bgcolor="white">88</td><td class="derecha" bgcolor="white">0</td><td class="centrar" bgcolor="white">Surtida Total</td></tr><tr><td class="centrar" bgcolor="#bdbdbd">23281999</td><td class="izquierda" bgcolor="#bdbdbd">ITK0000001 - VARILLA G42</td><td class="centrar" bgcolor="#bdbdbd">TON</td><td class="derecha" bgcolor="#bdbdbd">50</td><td class="derecha" bgcolor="#bdbdbd">10</td><td class="derecha" bgcolor="#bdbdbd">30</td><td class="centrar" bgcolor="#bdbdbd">Pendiente Total</td></tr><tr><td class="centrar" bgcolor="white">23514668</td><td class="izquierda" bgcolor="white">ITK0000001 - VARILLA G42</td><td class="centrar" bgcolor="white">TON</td><td class="derecha" bgcolor="white">50</td><td class="derecha" bgcolor="white">10</td><td class="derecha" bgcolor="white">30</td><td class="centrar" bgcolor="white">Surtida Parcial</td></tr></table></body></html>'



	IF ISNULL(@psMensajeTraspaso,'') <> '' 
	SELECT	@pnEsMensajeTraspaso = 1
			

    SELECT  @pnClaSolicitud = @pnClaSolicitud,
            @pnClaPedido    = @pnClaPedido   

    SET NOCOUNT OFF    

	RETURN
END