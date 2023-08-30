USE Operacion
GO
-- EXEC SP_HELPTEXT 'OpeSch.OPE_CU550_Pag32_Grid_GridCargaPartidasOrigenDet_IU'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_Grid_GridCargaPartidasOrigenDet_IU
	@pnClaUbicacion             INT,
    @pnClaUsuarioMod            INT,	
    @psNombrePcMod              VARCHAR(64),
    @pnEsEditableDet            INT = 0,
    @pnClaTipoTraspaso			INT = 0,
    @pnClaTipoEvento            INT = 0,
    @pnClaSolicitud	            INT = 0,
    @pnClaPedidoOrigen	        INT = 0,
    @pnColSeleccionCPD          INT = 0,
    @pnColClaProductoCPD        INT = 0,
    @psColProductoCPD           VARCHAR(255),
    @psColUnidadCPD             VARCHAR(10),
    @pnColCantPedidaCPD         NUMERIC(22,4),
	@pnColCantPedidaOriginalCPD NUMERIC(22,4),
    @pnColPrecioListaMPCPD      NUMERIC(22,4),
    @pnColPrecioListaCPD        NUMERIC(22,4),
    @pnColPesoTeoricoCPD        NUMERIC(22,4),
    @pnColCantidadMinAgrupCPD   NUMERIC(22,4),
    @pnColEsMultiploCPD         INT = 0,
	@pnColCantidadDisponible	NUMERIC(22,4)=NULL,
	@pnColCantidadSolicitada	NUMERIC(22,4)=NULL,
	@pnColNoRenglonCPD			INT = NULL,
	@pnDebug					INT = 0
AS  
BEGIN
    
	--EXEC OpeSch.OPE_CU550_Pag32_Grid_GridCargaPartidasOrigenDet_IU @pnClaUbicacion=325,@pnClaUsuarioMod=100026157,@psNombrePcMod='100CESUAREZ',
	--@pnEsEditableDet=0,@pnClaTipoTraspaso=3,@pnClaTipoEvento=0,@pnClaSolicitud=3780,@pnClaPedidoOrigen=24777675,@pnColSeleccionCPD=1,@pnColClaProductoCPD=696890,
	--@psColProductoCPD='24938 - VARILLA DA- 457 G56 C5 1" 12.0 m P05 R INGETEK',@psColUnidadCPD='Kg',@pnColCantPedidaCPD=11442.0000,@pnColPrecioListaMPCPD=13.7632,
	--@pnColPrecioListaCPD=17.2000,@pnColPesoTeoricoCPD=1.0000,@pnColCantidadMinAgrupCPD=1907.0000, @pnColEsMultiploCPD=1,@pnColCantidadDisponible=11442.0000,@pnColCantidadSolicitada=0, @pnDebug = 1

    SET NOCOUNT ON

    IF ( @pnClaTipoEvento = 0 AND @pnColSeleccionCPD = 1 )
    BEGIN
		---- No ingresar los registros que superan la cantidad disponible (Suministro directo) 
		IF @pnClaTipoTraspaso IN (3,4) AND (@pnColCantPedidaCPD > @pnColCantidadDisponible)	
		BEGIN
			RETURN
		END

        --Declaración de Variables Internas 
        DECLARE @nNoRenglon         INT = -1,
                @nClaEstatus        INT = -1,
				@sMensajeError		VARCHAR(800)

        --Validamos si existe una coincidencia con el ClaProducto a Intentar Trabajar en la tabla de Detalle relacionada al IdSolicitudTraspaso
        SELECT  @nNoRenglon     = b.IdRenglon,
                @nClaEstatus    = b.ClaEstatus
        FROM    OpeSch.OpeTraSolicitudTraspasoEncVw a WITH(NOLOCK)  
        INNER JOIN  OpeTraSolicitudTraspasoDetVw b WITH(NOLOCK)  
            ON  a.IdSolicitudTraspaso = b.IdSolicitudTraspaso
        WHERE   a.IdSolicitudTraspaso   = @pnClaSolicitud	
        AND     a.ClaPedidoOrigen       = @pnClaPedidoOrigen
        AND     b.ClaProducto           = @pnColClaProductoCPD

        --Validación de Registro Editable o No Editable + Validación de un Estatus menor a 1, 2 o 3
        IF ( ISNULL( @pnEsEditableDet,0 ) = 1 AND ISNULL( @nClaEstatus,-1 ) < 1 )
        BEGIN
            --Validaciones de Registro en Situación Correcta
            IF ( ISNULL( @pnColClaProductoCPD,0 ) = 0 ) --Validamos Registro de Campo Obligatorio
            BEGIN
				SELECT	@sMensajeError = 'Es necesario seleccionar un Producto.';
                THROW 127014, @sMensajeError, 8;
                RETURN
            END
            IF ( ISNULL( @pnColCantPedidaCPD,0 ) = 0 )
            BEGIN
				SELECT	@sMensajeError = 'La Cantidad Pedida necesita ser mayor a 0.00. (' + @psColProductoCPD + ')';
                THROW 127015, @sMensajeError, 8;  
                RETURN
            END
            IF ( ISNULL( @pnColPrecioListaCPD,0 ) = 0 AND ISNULL( @pnClaTipoTraspaso,0 ) IN (2,3,4) )
            BEGIN
                SELECT	@sMensajeError = 'Para una Solicitud de Compra Filial es necesario registrar el Precio de Lista. (' + @psColProductoCPD + ')';
				THROW 127016, @sMensajeError, 8;  
                RETURN
            END

            --Definimos si sera proceso de Registro o Edición (Proceso que Edita Datos de Registro Internos)
            IF ( NOT EXISTS ( SELECT 1  FROM OpeSch.OpeTraSolicitudTraspasoEncVw a
                                        INNER JOIN OpeSch.OpeTraSolicitudTraspasoDetVw b    ON      a.IdSolicitudTraspaso = b.IdSolicitudTraspaso
                                                                                            WHERE   a.IdSolicitudTraspaso = @pnClaSolicitud
                                                                                            AND     a.ClaPedidoOrigen = @pnClaPedidoOrigen
                                                                                            AND     b.ClaProducto = @pnColClaProductoCPD )
                    OR (ISNULL( @pnClaSolicitud,0 ) = 0  AND ISNULL( @pnColClaProductoCPD,0 ) > 0) ) -- Proceso de Registro
            BEGIN
                SELECT  @nNoRenglon = MAX(b.IdRenglon)
                FROM    OpeSch.OpeTraSolicitudTraspasoEncVw a
                INNER JOIN OpeSch.OpeTraSolicitudTraspasoDetVw b   
                    ON  a.IdSolicitudTraspaso = b.IdSolicitudTraspaso 
                WHERE   a.IdSolicitudTraspaso = @pnClaSolicitud

                SELECT  @nNoRenglon = ISNULL( @nNoRenglon,0 ) + 1

                INSERT INTO OpeSch.OpeTraSolicitudTraspasoDetVw
                        (IdSolicitudTraspaso,       ClaProducto,                IdRenglon,                  CantidadPedidaOrigen,       CantidadPedida,
                        Unidad,                     PesoTeoricoKgs,             CantidadMinAgrup,           Multiplo,                   PrecioListaOrigen,
                        PrecioListaMP,              PrecioLista,                ClaEstatus,                 ClaMotivoRechazo,           ClaMotivoAutomatico,
                        FechaUltimaMod,             ClaUsuarioMod,              NombrePcMod)

                SELECT  @pnClaSolicitud,            @pnColClaProductoCPD,       @nNoRenglon,                @pnColCantPedidaOriginalCPD,@pnColCantPedidaCPD,
                        @psColUnidadCPD,            @pnColPesoTeoricoCPD,       @pnColCantidadMinAgrupCPD,  @pnColEsMultiploCPD,        @pnColPrecioListaCPD,
                        @pnColPrecioListaMPCPD,     @pnColPrecioListaMPCPD,     0,                          0,                          0,
                        GETDATE(),                  @pnClaUsuarioMod,           @psNombrePcMod   
            END
            ELSE IF ( EXISTS ( SELECT 1  FROM OpeSch.OpeTraSolicitudTraspasoEncVw a
                                        INNER JOIN OpeSch.OpeTraSolicitudTraspasoDetVw b    ON      a.IdSolicitudTraspaso = b.IdSolicitudTraspaso
                                                                                            WHERE   a.IdSolicitudTraspaso = @pnClaSolicitud
                                                                                            AND     a.ClaPedidoOrigen = @pnClaPedidoOrigen
                                                                                            AND     b.ClaProducto = @pnColClaProductoCPD) 
                    AND (ISNULL( @pnClaSolicitud,0 ) > 0  AND ISNULL( @pnColClaProductoCPD,0 ) > 0 AND ISNULL( @nClaEstatus,-1 ) = 0) ) -- Proceso de Edición
            BEGIN
                UPDATE  a
                SET     CantidadPedida		    = @pnColCantPedidaCPD,
						CantidadPedidaOrigen    = @pnColCantPedidaOriginalCPD,
                        Unidad                  = @psColUnidadCPD,
                        PesoTeoricoKgs          = @pnColPesoTeoricoCPD,        
                        CantidadMinAgrup        = @pnColCantidadMinAgrupCPD,
                        Multiplo                = @pnColEsMultiploCPD,
                        PrecioListaOrigen       = @pnColPrecioListaCPD,
                        PrecioListaMP           = ISNULL( @pnColPrecioListaMPCPD,0.00 ),
                        FechaUltimaMod          = GETDATE(),
                        ClaUsuarioMod           = @pnClaUsuarioMod,
                        NombrePcMod             = @psNombrePcMod   
                FROM    OpeSch.OpeTraSolicitudTraspasoDetVw a 
                WHERE   a.IdSolicitudTraspaso = @pnClaSolicitud
                AND     a.IdRenglon = @nNoRenglon
                AND     a.ClaEstatus = 0
            END
        END
    END
	ELSE IF (@pnClaTipoEvento = 0 AND @pnColSeleccionCPD = 0)
	BEGIN
		SELECT 'HV'
		DELETE
        FROM    OpeSch.OpeTraSolicitudTraspasoDetVw
        WHERE   IdSolicitudTraspaso	= @pnClaSolicitud
        AND     IdRenglon			= @pnColNoRenglonCPD
        AND     ClaEstatus			= 0	
	END

	IF @pnDebug = 1
	SELECT *
	FROM OpeSch.OpeTraSolicitudTraspasoDetVw
	WHERE IdSolicitudTraspaso = @pnClaSolicitud

    SET NOCOUNT OFF    

	RETURN
END