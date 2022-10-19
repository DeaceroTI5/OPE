ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_Sel
	@pnClaUbicacion     INT,
    @pnClaUsuarioMod    INT,	
    @pnClaSolicitud	    INT = 0
AS
BEGIN
    
    SET NOCOUNT ON

    IF OBJECT_ID('TEMPDB..#TempEstatusPedidosVTA') IS NOT NULL
		DROP TABLE #TempEstatusPedidosVTA

    CREATE TABLE #TempEstatusPedidosVTA    (ClaEstatus INT,
                                            NomEstatus  VARCHAR(60))

    INSERT INTO #TempEstatusPedidosVTA
    SELECT 0, 'Creada'
    UNION
    SELECT 200, 'Pendiente Autorización'
    UNION
    SELECT 204, 'Autorizada'
    UNION
    SELECT 1, 'Activa'
    UNION
    SELECT 2, 'Detenida'
    UNION
    SELECT 3, 'Cancelada'
    UNION
    SELECT 4, 'Pendiente Total'
    UNION
    SELECT 5, 'Surtido Parcial'
    UNION
    SELECT 6, 'Surtido Total'

    --Declaración de Variables para Almacenar el Valor registrados en Solicitud de Traspasos
    DECLARE @nClaSolicitud              INT = NULL,
            @nClaPedido                 INT = NULL,
            @nClaPedidoCliente          VARCHAR(16) = NULL,
            @nClaPedidoOrigen           INT = NULL,
            @tFechaDesea                DATETIME = NULL,
            @nChkAceptaAntes            INT = 1,
            @nChkAceptaParcial          INT = 1,
            @nChkSurtirSinExcederse     INT = 0,
            @nChkSuministroDirecto      INT = 0,
            @nChkLlaveEnMano            INT = 0,
            @sHechoPor                  VARCHAR(100) = NULL,
            @nClaHechoPor               INT = NULL,
            @tFechaCaptura              DATETIME = NULL,
            @tFechaAutorizacion         DATETIME = NULL,
            @sEstatusSolicitud          VARCHAR(100) = NULL,
            @nClaEstatusSolicitud       INT = 0,
            @sEstatusPedido             VARCHAR(100) = NULL,
            @nClaEstatusPedido          INT = 0,
            @sCanceladoPor              VARCHAR(100) = NULL,
            @nClaCanceladoPor           INT = NULL,
            @sObservaciones             VARCHAR(800) = NULL
            
    DECLARE @nClaTipoTraspaso           INT = 0,
            @nClaEstatusPedidoOrigen    INT = 0,
            @nEsEditableEnc             INT = 1,
            @nEsEditableDet             INT = 0
    
    DECLARE @nEsAutorizadorCS           INT = 0,
            @nEsAutorizadorCP           INT = 0,
            @nEsAutorizadorTM           INT = 0,
            @nEsEditableCS              INT = 0,
            @nEsEditableCP              INT = 0,
            @nEsEditableAutorizarTM     INT = 0,
            @nEsEditableAA              INT = 0

    DECLARE @nCmbPlantaPide             INT = 0,
            @nCmbPlantaSurte            INT = 0,
            @nClaValorUbicacionPide     INT = 0,
            @nClaValorUbicacionSurte    INT = 0,
            @nCmbCliente                INT = 0,
            @nCmbProyecto               INT = 0,
            @nCmbConsignado             INT = 0

    DECLARE @nClaEmpresaPide            INT = 0,
            @nClaEmpresaSurte           INT = 0

    --Inicialización de Proceso de Envio de Datos Nivel Encabezado
    SELECT  @pnClaSolicitud = ISNULL( @pnClaSolicitud,0 )

    --Escenario de Solicitud Nueva, Retorno de Valores Default
    IF  ( @pnClaSolicitud = 0 ) OR ( NOT EXISTS ( SELECT 1 FROM OpeSch.OpeTraSolicitudTraspasoEncVw WHERE IdSolicitudTraspaso = @pnClaSolicitud ) )
    BEGIN 
        SELECT  ClaSolicitud = NULL,
                ClaPedido = NULL,
                ClaPedidoCliente = NULL,
                ClaPedidoOrigen = NULL,
                FechaDefault = DATEADD(DD,1,GETDATE()),
                FechaDesea = DATEADD(DD,1,GETDATE()),
                ChkAceptaAntes = 1,
                ChkAceptaParcial = 1,
                ChkSurtirSinExcederse = 0,
                ChkSuministroDirecto = 0,
            ChkLlaveEnMano = 0,
                HechoPor = NULL,
                ClaHechoPor = NULL,
                FechaCaptura = NULL,
                FechaAutorizacion = NULL,
                EstatusSolicitud = NULL,
                ClaEstatusSolicitud = 0,
                EstatusPedido = NULL,
                ClaEstatusPedido = 0,
                CanceladoPor = NULL,
                ClaCanceladoPor = NULL,
                Observaciones = NULL,
                ClaTipoTraspaso = 0,
                ClaTipoEvento = 0,
                ClaEstatusPedidoOrigen = 0,
                EsEditableEnc = 1,
                EsEditableDet = 0,
                EsEditableConsignado = 1,
                EsEditableCS = 0,
                EsEditableCP = 0,
                EsEditableAutorizarTM = 0,
                EsEditableAA = 0,
                ClaValorUbicacionPide = 0,
                ClaValorUbicacionSurte = 0,
                EsAutorizadorCS = 0,
                EsAutorizadorCP = 0,
                EsAutorizadorTM = 0

        RETURN
    END

    --Captura de Información de Registro Existente de Traspaso a Nivel Encabezado
    SELECT  @nClaSolicitud              = a.IdSolicitudTraspaso,
            @nClaPedido                 = a.ClaPedido,
            @nClaPedidoCliente          = a.ClaPedidoCliente,
            @nClaPedidoOrigen           = a.ClaPedidoOrigen,
            @nCmbPlantaPide             = a.ClaUbicacionSolicita,
            @nCmbPlantaSurte            = a.ClaUbicacionSurte,
            @nClaValorUbicacionPide     = a.ClaUbicacionSolicita,
            @nClaValorUbicacionSurte    = a.ClaUbicacionSurte,
            @nCmbCliente                = a.ClaCliente,
            @nCmbProyecto               = a.ClaProyecto,
            @nCmbConsignado             = a.ClaConsignado,
            @tFechaDesea                = ( CASE    
                                                WHEN ISNULL( a.ClaEstatusSolicitud,0 ) = 0 AND ISNULL( a.ClaUsuarioIns,0 ) = @pnClaUsuarioMod
                                                THEN ISNULL( a.FechaDesea,DATEADD(DD,1,GETDATE()) )
                                                ELSE a.FechaDesea
                                            END),
            @nChkAceptaAntes            = a.EsAceptaAntes,
            @nChkAceptaParcial          = a.EsAceptaParcial,
            @nChkSurtirSinExcederse     = ( CASE    
                                                WHEN ISNULL( a.ClaEstatusSolicitud,0 ) = 0
                                                THEN ISNULL( d.EsSurtirSinExcederse,0 )
                                                ELSE ISNULL( a.EsSurtirSinExcederse,0 )
                                            END),
            @nChkSuministroDirecto      = a.EsSuministroDirecto,
            @nChkLlaveEnMano            = a.EsLlaveEnMano,
            @sHechoPor                  = RTRIM(LTRIM(e.NombreUsuario)) + ' ' + RTRIM(LTRIM(e.ApellidoPaterno)) + ' ' + RTRIM(LTRIM(e.ApellidoMaterno)),
            @nClaHechoPor               = a.ClaUsuarioIns,
            @tFechaCaptura              = a.FechaIns,
            @tFechaAutorizacion         = a.FechaAutorizacion,
            @sEstatusSolicitud          = f.NombreEstatus,
            @nClaEstatusSolicitud       = a.ClaEstatusSolicitud,
            @sEstatusPedido             = g.NomEstatus,
            @nClaEstatusPedido          = b.ClaEstatusFabricacion,
            @nClaCanceladoPor           = ( CASE    
                                                WHEN ISNULL( b.ClaEstatusFabricacion,0 ) = 3
                                                THEN ISNULL( b.ClaUsuarioMod,0 )
                                                WHEN ISNULL( a.ClaEstatusSolicitud,0 ) = 2
                                                THEN ISNULL( a.ClaUsuarioCancela,0 )
                                                ELSE NULL
                                            END),
            @sObservaciones             = a.Observaciones,
            @nClaEstatusPedidoOrigen    = ( CASE    
                                                WHEN ISNULL( c.ClaEstatus,0 ) = 1
                                                THEN 1
                                                ELSE 0
                                            END),
            @nEsEditableEnc             = ( CASE    
                                                WHEN ISNULL( a.ClaEstatusSolicitud,0 ) = 0 AND ISNULL( a.ClaUsuarioIns,0 ) = @pnClaUsuarioMod
                                                THEN 1
                                                ELSE 0
                                            END),
            @nEsEditableDet             = ( CASE    
                                                WHEN ISNULL( a.ClaEstatusSolicitud,0 ) = 0 AND ISNULL( a.ClaUsuarioIns,0 ) = @pnClaUsuarioMod
                                                THEN 1
                                                ELSE 0
                                            END)
    FROM    OpeSch.OpeTraSolicitudTraspasoEncVw a WITH(NOLOCK)  
    LEFT JOIN  DEAOFINET05.Ventas.VtaSch.VtaTraFabricacion b WITH(NOLOCK)  
        ON  a.ClaPedido = b.IdFabricacion --AND a.ClaUbicacionSurte = b.ClaUbicacion /*Se identifican casos con discrepancia entre ClaUbicación y ClaUbicacionVenta al generarse las Fabricaciones*/
    LEFT JOIN   OpeSch.OpeTraFabricacionVw c WITH(NOLOCK)  
        ON  a.ClaPedidoOrigen = c.IdFabricacion
    LEFT JOIN   OpeSch.OpeVtaCatClienteCuentaVw d WITH(NOLOCK)  
        ON  a.ClaCliente = d.ClaClienteCuenta
    LEFT JOIN   OpeSch.OpeTiCatUsuarioVw e WITH(NOLOCK)  
        ON  a.ClaUsuarioIns = e.ClaUsuario
    LEFT JOIN   TiCatalogo.dbo.TiCatEstatus f WITH(NOLOCK)  
        ON  a.ClaEstatusSolicitud = f.ClaEstatus AND f.ClaClasificacionEstatus = 1270105 AND ISNULL( f.BajaLogica,0 ) = 0
    LEFT JOIN   #TempEstatusPedidosVTA g WITH(NOLOCK)  
        ON  b.ClaEstatusFabricacion = g.ClaEstatus
    WHERE   IdSolicitudTraspaso = @pnClaSolicitud

    --Captura Nombre de Usuario que Realiza Cancelación (Pedido o Solicitud)
    SELECT  @sCanceladoPor = RTRIM(LTRIM(a.NombreUsuario)) + ' ' + RTRIM(LTRIM(a.ApellidoPaterno)) + ' ' + RTRIM(LTRIM(a.ApellidoMaterno))
    FROM    OpeSch.OpeTiCatUsuarioVw a WITH(NOLOCK)  
    WHERE   a.ClaUsuario = @nClaCanceladoPor

    --Captura de Tipo de Traspaso Realizado en Registro Existente
    SELECT  @nClaTipoTraspaso = ISNULL( @nClaTipoTraspaso,0 )

    IF ( @nCmbPlantaPide > 0 AND @nCmbPlantaSurte > 0 ) 
    BEGIN
        SELECT  @nClaEmpresaPide = ClaEmpresa
        FROM    OpeSch.OpeTiCatUbicacionVw WITH(NOLOCK)  
        WHERE   ClaUbicacion = @nCmbPlantaPide

        SELECT  @nClaEmpresaSurte = ClaEmpresa
        FROM    OpeSch.OpeTiCatUbicacionVw WITH(NOLOCK)  
        WHERE   ClaUbicacion = @nCmbPlantaSurte

        IF ( @nClaEmpresaPide = @nClaEmpresaSurte )
        BEGIN
            SELECT  @nClaTipoTraspaso = 1
        END 
        ELSE IF ( @nClaEmpresaPide != @nClaEmpresaSurte AND @nChkSuministroDirecto = 0 )
        BEGIN
            SELECT  @nClaTipoTraspaso = 2
        END 
        ELSE IF ( @nClaEmpresaPide != @nClaEmpresaSurte AND @nChkSuministroDirecto = 1 )
        BEGIN
            SELECT  @nClaTipoTraspaso = 3
        END 
        ELSE 
        BEGIN
            SELECT  @nClaTipoTraspaso = 0
        END 
    END  

    --Captura de Autorizaciones de Usuario de Captura
    EXEC    [OpeSch].[OPE_CU550_Pag32_Boton_btnValidaAplicaCS_Proc]
            @pnClaUbicacion     = @pnClaUbicacion,
            @pnClaUsuarioMod    = @pnClaUsuarioMod,
            @pnClaSolicitud	    = @nClaSolicitud,
            @pnEsAutorizadorCS  = @nEsAutorizadorCS OUTPUT,
            @pnEsEditableCS     = @nEsEditableCS OUTPUT

    EXEC    [OpeSch].[OPE_CU550_Pag32_Boton_btnValidaAplicaCP_Proc]
            @pnClaUbicacion     = @pnClaUbicacion,
            @pnClaUsuarioMod    = @pnClaUsuarioMod,
            @pnClaSolicitud	    = @nClaSolicitud,
            @pnClaPedido	    = @nClaPedido,
            @pnEsAutorizadorCP  = @nEsAutorizadorCP OUTPUT,
            @pnEsEditableCP     = @nEsEditableCP OUTPUT

    EXEC    [OpeSch].[OPE_CU550_Pag32_Boton_btnValidaAplicaAutorizarTM_Proc]
            @pnClaUbicacion             = @pnClaUbicacion,
            @pnClaUsuarioMod            = @pnClaUsuarioMod,
            @pnClaSolicitud	            = @nClaSolicitud,
            @pnEsAutorizadorTM          = @nEsAutorizadorTM OUTPUT,
            @pnEsEditableAutorizarTM    = @nEsEditableAutorizarTM OUTPUT

    EXEC    [OpeSch].[OPE_CU550_Pag32_Boton_btnValidaAplicaAA_Proc]
            @pnClaUbicacion             = @pnClaUbicacion,
            @pnClaSolicitud	            = @nClaSolicitud,
            @pnClaPedidoOrigen          = @nClaPedidoOrigen,
            @pnClaEstatusPedidoOrigen   = @nClaEstatusPedidoOrigen,
            @pnEsEditableAA             = @nEsEditableAA OUTPUT

    --Retorno de Información Consultada para Escenario de Registro Existente
    SELECT  ClaSolicitud = @nClaSolicitud,
            ClaPedido = @nClaPedido,
            ClaPedidoCliente = @nClaPedidoCliente,
            ClaPedidoOrigen = @nClaPedidoOrigen,
            FechaDesea = @tFechaDesea,
            ChkAceptaAntes = @nChkAceptaAntes,
            ChkAceptaParcial = @nChkAceptaParcial,
            ChkSurtirSinExcederse = @nChkSurtirSinExcederse,
            ChkSuministroDirecto = @nChkSuministroDirecto,
            ChkLlaveEnMano = @nChkLlaveEnMano ,
            HechoPor = @sHechoPor,
            ClaHechoPor = @nClaHechoPor,
            FechaCaptura = CONVERT(VARCHAR,@tFechaCaptura,20),
            FechaAutorizacion = CONVERT(VARCHAR,@tFechaAutorizacion,20),
            EstatusSolicitud = @sEstatusSolicitud ,
            ClaEstatusSolicitud = @nClaEstatusSolicitud ,
            EstatusPedido = @sEstatusPedido ,
            ClaEstatusPedido = @nClaEstatusPedido,
            CanceladoPor = @sCanceladoPor,
            ClaCanceladoPor = @nClaCanceladoPor,
            Observaciones = @sObservaciones,
            ClaTipoTraspaso = @nClaTipoTraspaso,
            ClaTipoEvento = 0,
            ClaEstatusPedidoOrigen = @nClaEstatusPedidoOrigen,
            EsEditableEnc = @nEsEditableEnc,
            EsEditableDet = @nEsEditableDet,
            EsEditableCS = @nEsEditableCS,
            EsEditableCP = @nEsEditableCP,
            EsEditableAutorizarTM = @nEsEditableAutorizarTM,
            EsAutorizadorCS = @nEsAutorizadorCS,
            EsAutorizadorCP = @nEsAutorizadorCP,
            EsAutorizadorTM = @nEsAutorizadorTM,
            CmbPlantaPide = @nCmbPlantaPide,
            CmbPlantaSurte = @nCmbPlantaSurte,
            ClaValorUbicacionPide = @nClaValorUbicacionPide,
            ClaValorUbicacionSurte = @nClaValorUbicacionSurte,
            CmbCliente = @nCmbCliente,
            CmbProyecto = @nCmbProyecto,
            CmbConsignado = @nCmbConsignado            

    SET NOCOUNT OFF    

	RETURN
END
