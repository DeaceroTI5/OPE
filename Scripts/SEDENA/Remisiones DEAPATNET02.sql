--DEAPATNET02
BEGIN TRAN
    DECLARE
        @nConsecutivo   INT = NULL

    DECLARE
        @tFacturas      TABLE
        (
            Factura     VARCHAR(20)
        )

    INSERT  INTO @tFacturas (Factura)
    SELECT 'FB12068' UNION
    SELECT 'FB11988' UNION
    SELECT 'FB11990' UNION
    SELECT 'FB11992' UNION
    SELECT 'FB11996' UNION
    SELECT 'FB11998' UNION
    SELECT 'FB12000' UNION
    SELECT 'FB12002' UNION
    SELECT 'FB12005' UNION
    SELECT 'FB12023' UNION
    SELECT 'FB12024' UNION
    SELECT 'FB12025' 


    SELECT  NoUbicacion     = T6.ClaUbicacion,
            Ubicacion       = CONVERT(VARCHAR, T6.ClaUbicacion) + ' - ' + T6.NombreUbicacion,   
            Viaje           = T1.IdViaje,
            Fabricacion     = T1.IdFabricacion,
            NumeroFactura   = T1.IdFactura,
            Factura         = T1.IdFacturaAlfanumerico,
            Factura02       = T2.IdFacturaAlfanumerico,
            FechaFactura    = T1.FechaFactura,
            Estatus         = NULL,
            Mensaje         = NULL
    INTO    #tempFacturasPendientes
    FROM    @tFacturas T0
    INNER JOIN  DEAOFINET05.Ventas.VtaSch.VtaTraFacturaVw T1 WITH(NOLOCK)
        ON  T0.Factura      = T1.IdFacturaAlfanumerico
    INNER JOIN  AMPSch.AmpRelRegistroEntradaFactura T2 WITH(NOLOCK)
        ON  T0.Factura      = T2.IdFacturaAlfanumerico
    INNER JOIN  AMPSch.TiCatUbicacionVw T6 WITH(NOLOCK)
        ON  T1.ClaUbicacion = T6.ClaUbicacion

    SELECT  *
    FROM    #tempFacturasPendientes

    SELECT  @nConsecutivo   = MIN(NumeroFactura)
    FROM    #tempFacturasPendientes

    DECLARE
        @pnClaUbicacion         INT,
        @pnNumViajeM            INT,
        @pnNumFacturaImprimeM   INT,
        @pnEsImpresionPDF       INT,
        @psNombrePcMod          VARCHAR(64)
    
    DECLARE 
        @nEstatus               INT,
        @sMensaje               VARCHAR(1000)
    
    DECLARE 
        @nClFormatoImpresion    INT

    WHILE   ISNULL( @nConsecutivo,0 ) != 0
    BEGIN
        SELECT  @pnClaUbicacion         = NoUbicacion,
                @pnNumViajeM            = Viaje,
                @pnNumFacturaImprimeM   = NumeroFactura,
                @pnEsImpresionPDF       = NULL,
                @psNombrePcMod          = 'IngetekSedena',
                @nEstatus               = NULL,
                @sMensaje               = NULL,
                @nClFormatoImpresion    = NULL
        FROM    #tempFacturasPendientes
        WHERE   NumeroFactura = @nConsecutivo
        
        SET     @nClFormatoImpresion = AMPSch.AmpConfiguracionNumericoFn(643, @pnClaUbicacion, 1)   
    
        SELECT  @pnEsImpresionPDF = EsImpresionPDF
        FROM    AMPSch.AmpCfgFacturaVentasPDF 
        WHERE   ClaUbicacion = @pnClaUbicacion

        --Continua con la impresion habitual
        EXEC AMPSch.AmpImprimeFacturaVentasProc @pnClaUbicacion = @pnClaUbicacion,
                                                @pnNumViaje     = @pnNumViajeM,
                                                @pnNumFactura   = @pnNumFacturaImprimeM,
                                                @pnClFormatoImpresion = @nClFormatoImpresion,
                                                @psNombrePcMod  = @psNombrePcMod,
                                                @pnEstatus      = @nEstatus OUTPUT,
                                                @psMensaje      = @sMensaje OUTPUT

        UPDATE  T0
        SET     T0.Estatus      = @nEstatus,
                T0.Mensaje      = @sMensaje
        FROM    #tempFacturasPendientes T0
        WHERE   NumeroFactura   = @nConsecutivo

        SELECT  @nConsecutivo   = MIN(NumeroFactura)
        FROM    #tempFacturasPendientes
        WHERE   NumeroFactura   > @nConsecutivo     
    END

    SELECT  *
    FROM    #tempFacturasPendientes
COMMIT TRAN
