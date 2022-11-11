USE Operacion
GO
-- 'OpeSch.OPE_CU550_Pag32_Grid_GridTraspasoManualDet_CambioValor_ColCantPedida_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_Grid_GridTraspasoManualDet_CambioValor_ColCantPedida_Sel
    @pnClaUbicacion     INT,
	@pnClaSolicitud		INT = NULL,
    @pnColProducto	    INT = 0,
    @pnColCantPedida    NUMERIC(22,4),
	@pnClaTipoTraspaso	INT = 0,
	@pnClaPedidoOrigen	INT = NULL,
	@pnDebug			TINYINT = 0
AS
BEGIN
	-- exec OPESch.OPE_CU550_Pag32_Grid_GridTraspasoManualDet_CambioValor_ColCantPedida_Sel @pnClaUbicacion=325,@pnColProducto=4022,@pnColCantPedida=500000.0000,@pnClaPedidoOrigen=24240401,@pnDebug=1

	SET NOCOUNT ON

	DECLARE	  @nCantidadDisponible	NUMERIC(22,4)
			, @smsj					VARCHAR(300)

	DECLARE @tbOtrasSolicitudes TABLE(
		  Id					INT IDENTITY(1,1)
		, ClaPedido				INT
		, ClaProducto			INT
		, ClaEstatus			INT
		, CantidadFabricacion	NUMERIC(22,4)
		, CantidadSolicitada	NUMERIC(22,4)
		, CantidadDisponible	NUMERIC(22,4)
	)

    SELECT  @pnColProducto = ISNULL( @pnColProducto,0 )

    IF ( @pnColProducto > 0 )
    BEGIN
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
			WHERE	Id = 1

			IF  @pnColCantPedida > @nCantidadDisponible
			BEGIN
				SELECT @smsj = 'La Cantidad pedida ('+CONVERT(VARCHAR(30),FORMAT(@pnColCantPedida, '###,###.####'))+') no puede se mayor a la Cantidad total de otras solicitudes. </br></br>Saldo pendiente: ' + CONVERT(VARCHAR(30),FORMAT(@nCantidadDisponible, '###,###.####'))
				RAISERROR(@smsj,16,1)
				RETURN
			END
		END

        SELECT  ColKilosPedidos = ISNULL( @pnColCantPedida * ISNULL( a.PesoTeoricoKgs,1),0 )
        FROM    OpeSch.OpeArtCatArticuloVw a WITH(NOLOCK)  
        WHERE   a.ClaArticulo = @pnColProducto
    END    
    ELSE
    BEGIN
        SELECT  ColCantPedida    = 0.00,
                ColKilosPedidos  = 0.00
    END

	SET NOCOUNT OFF    

	RETURN            
	-- Manejo de Errores              
	ABORT: 
    RAISERROR('El SP (OPE_CU550_Pag32_Grid_GridTraspasoManualDet_CambioValor_ColCantPedida_Sel) no puede ser procesado.', 16, 1)     

END