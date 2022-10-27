USE Operacion
GO
-- 'OpeSch.OPE_CU550_Pag32_Grid_GridTraspasoManualDet_IU'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_Grid_GridTraspasoManualDet_IU
	@pnClaUbicacion             INT,
    @pnClaUsuarioMod            INT,	
    @psNombrePcMod              VARCHAR(64),
    @pnAccionSp                 INT,
    @pnEsEditableDet            INT = 0,
    @pnClaTipoTraspaso			INT = 0,
    @pnClaTipoEvento            INT = 0,
    @pnClaSolicitud	            INT = 0,
    @pnColNoRenglon             INT = 0,
    @pnColProducto              INT = 0,
    @psColUnidad                VARCHAR(10),
    @pnColCantPedidaOrigen      NUMERIC(22,4),
    @pnColCantPedida            NUMERIC(22,4),
    @pnColPrecioListaOrigen     NUMERIC(22,4),
    @pnColPrecioListaMP         NUMERIC(22,4),
    @pnColPrecioLista           NUMERIC(22,4),
    @pnColPesoTeorico           NUMERIC(22,4),
    @pnColCantidadMinAgrup      NUMERIC(22,4),
    @pnColEsMultiplo            INT = 0,
    @pnColClaEstatus            INT = 0,
	@pnClaPedidoOrigen			INT = NULL,
	@pnDebug					TINYINT = 0
AS  
BEGIN
    
    SET NOCOUNT ON

	DECLARE	  @nCantidadDisponible	NUMERIC(22,4)
			, @smsj					VARCHAR(350)
			, @sProducto			VARCHAR(20)

	DECLARE @tbOtrasSolicitudes TABLE(
		  Id					INT IDENTITY(1,1)
		, ClaPedido				INT
		, ClaProducto			INT
		, ClaEstatus			INT
		, CantidadFabricacion	NUMERIC(22,4)
		, CantidadSolicitada	NUMERIC(22,4)
		, CantidadDisponible	NUMERIC(22,4)
	)

	---- No ingresar los registros que superan la cantidad disponible (Suministro directo) 
	IF @pnClaPedidoOrigen IS NOT NULL AND @pnClaTipoTraspaso = 3
	BEGIN
	---- CANTIDAD
		INSERT INTO @tbOtrasSolicitudes (ClaPedido, ClaProducto, ClaEstatus, CantidadFabricacion, CantidadSolicitada, CantidadDisponible)
		EXEC OpeSch.OPE_CU550_Pag32_ValidaCantidadPedidoOrigenProc
			  @pnClaPedidoOrigen	= @pnClaPedidoOrigen
			, @pnClaSolicitud		= @pnClaSolicitud
			, @pnClaArticulo		= @pnColProducto

		SELECT	@nCantidadDisponible = CantidadDisponible
		FROM	@tbOtrasSolicitudes
		
		SELECT	@sProducto = ClaveArticulo
        FROM    OpeSch.OpeArtCatArticuloVw a WITH(NOLOCK)  
        WHERE   a.ClaArticulo = @pnColProducto	

		IF @pnDebug = 1
			SELECT @pnColCantPedida AS '@pnColCantPedida', @nCantidadDisponible AS '@nCantidadDisponible'

		IF  @pnColCantPedida > @nCantidadDisponible
		BEGIN
			SELECT @smsj = 'La Cantidad pedida ('+CONVERT(VARCHAR(30),FORMAT(@pnColCantPedida, '###,###.####'))+') del producto clave: '+ISNULL(@sProducto,'')+' no puede se mayor a la Cantidad total de otras solicitudes. </br></br>Saldo pendiente: ' + CONVERT(VARCHAR(30),FORMAT(@nCantidadDisponible, '###,###.####'))
			RAISERROR(@smsj,16,1)
			RETURN
		END
	END

    IF ( @pnClaTipoEvento = 0 )
    BEGIN
        --Validación de Registro Editable o No Editable
        IF ( ISNULL( @pnEsEditableDet,0 ) = 1 AND ISNULL( @pnColClaEstatus,0 ) = 0 )
        BEGIN
            --Validaciones de Registro en Situación Correcta
            IF ( ISNULL( @pnColProducto,0 ) = 0 ) --Validamos Registro de Campo Obligatorio
            BEGIN
                THROW 127011, 'Es necesario seleccionar un Producto.', 7;
                RETURN
            END
            IF ( ISNULL( @pnColCantPedida,0 ) = 0 )
            BEGIN
                THROW 127012, 'La Cantidad Pedida necesita ser mayor a 0.00.', 7;  
                RETURN
            END
            IF ( ISNULL( @pnColPrecioLista,0 ) = 0 AND ISNULL( @pnClaTipoTraspaso,0 ) IN (2,3) )
            BEGIN
                THROW 127013, 'Para una Solicitud de Compra Filial es necesario registrar el Precio de Lista.', 7;  
                RETURN
            END

            --Definimos si sera proceso de Registro o Edición
            IF ( NOT EXISTS ( SELECT 1  FROM OpeSch.OpeTraSolicitudTraspasoEncVw a
                                        INNER JOIN OpeSch.OpeTraSolicitudTraspasoDetVw b    ON      a.IdSolicitudTraspaso = b.IdSolicitudTraspaso
                                                                                            WHERE   a.IdSolicitudTraspaso = @pnClaSolicitud
                                                                                            AND     b.ClaProducto = @pnColProducto )
                    OR (ISNULL( @pnClaSolicitud,0 ) = 0  AND ISNULL( @pnColProducto,0 ) > 0 AND ISNULL( @pnAccionSp,0 ) = 1) ) -- Proceso de Registro
            BEGIN
                SELECT  @pnColNoRenglon = MAX(b.IdRenglon) 
                FROM    OpeSch.OpeTraSolicitudTraspasoEncVw a
                INNER JOIN OpeSch.OpeTraSolicitudTraspasoDetVw b   
                    ON  a.IdSolicitudTraspaso = b.IdSolicitudTraspaso 
                WHERE   a.IdSolicitudTraspaso = @pnClaSolicitud

                SELECT  @pnColNoRenglon = ISNULL( @pnColNoRenglon,0 ) + 1

                INSERT INTO OpeSch.OpeTraSolicitudTraspasoDetVw
                        (IdSolicitudTraspaso,       ClaProducto,            IdRenglon,              CantidadPedidaOrigen,       CantidadPedida,
                        Unidad,                     PesoTeoricoKgs,         CantidadMinAgrup,       Multiplo,                   PrecioListaOrigen,
                        PrecioListaMP,              PrecioLista,            ClaEstatus,             ClaMotivoRechazo,           ClaMotivoAutomatico,
                        FechaUltimaMod,             ClaUsuarioMod,          NombrePcMod)
                SELECT  @pnClaSolicitud,            @pnColProducto,         @pnColNoRenglon,        @pnColCantPedidaOrigen,     @pnColCantPedida,
                        @psColUnidad,               @pnColPesoTeorico,      @pnColCantidadMinAgrup, @pnColEsMultiplo,           @pnColPrecioListaOrigen,
                        @pnColPrecioListaMP,        @pnColPrecioLista,      @pnColClaEstatus,       0,                          0,
                        GETDATE(),                  @pnClaUsuarioMod,       @psNombrePcMod   
            END
            ELSE IF ( EXISTS ( SELECT 1  FROM OpeSch.OpeTraSolicitudTraspasoEncVw a
                                        INNER JOIN OpeSch.OpeTraSolicitudTraspasoDetVw b    ON      a.IdSolicitudTraspaso = b.IdSolicitudTraspaso
                                                                                            WHERE   a.IdSolicitudTraspaso = @pnClaSolicitud
                                                                                            AND     b.ClaProducto = @pnColProducto ) 
                    AND (ISNULL( @pnClaSolicitud,0 ) > 0  AND ISNULL( @pnColProducto,0 ) > 0 AND ISNULL( @pnAccionSp,0 ) = 2) ) -- Proceso de Edición
            BEGIN
                UPDATE  a
                SET     ClaProducto             = @pnColProducto,        
                        CantidadPedidaOrigen    = @pnColCantPedidaOrigen,
                        CantidadPedida          = @pnColCantPedida,
                        Unidad                  = @psColUnidad,
                        PesoTeoricoKgs          = @pnColPesoTeorico,        
                        CantidadMinAgrup        = @pnColCantidadMinAgrup,
                        Multiplo                = @pnColEsMultiplo,
                        PrecioListaOrigen       = @pnColPrecioListaOrigen,
                        PrecioListaMP           = @pnColPrecioListaMP,
                        PrecioLista             = @pnColPrecioLista,
                        FechaUltimaMod          = GETDATE(),
                        ClaUsuarioMod           = @pnClaUsuarioMod,
                        NombrePcMod             = @psNombrePcMod   
                FROM    OpeSch.OpeTraSolicitudTraspasoDetVw a 
                WHERE   a.IdSolicitudTraspaso = @pnClaSolicitud
                AND     a.IdRenglon = @pnColNoRenglon
                AND     a.ClaEstatus = 0
            END
            ELSE IF ( EXISTS ( SELECT 1  FROM OpeSch.OpeTraSolicitudTraspasoEncVw a
                                        INNER JOIN OpeSch.OpeTraSolicitudTraspasoDetVw b    ON      a.IdSolicitudTraspaso = b.IdSolicitudTraspaso
                                                                                            WHERE   a.IdSolicitudTraspaso = @pnClaSolicitud
                                                                                            AND     b.ClaProducto = @pnColProducto ) 
                    AND (ISNULL( @pnClaSolicitud,0 ) > 0  AND ISNULL( @pnColProducto,0 ) > 0 AND ISNULL( @pnAccionSp,0 ) = 3) ) -- Proceso de Eliminación
            BEGIN
                DELETE
                FROM    OpeSch.OpeTraSolicitudTraspasoDetVw
                WHERE   IdSolicitudTraspaso = @pnClaSolicitud
                AND     IdRenglon = @pnColNoRenglon
                AND     ClaEstatus = 0
            END
        END
    END

    SET NOCOUNT OFF    

	RETURN
END