USE Operacion
GO
-- 'OpeSch.OPE_CU550_Pag32_Boton_btnValidaFabricacionOrigen_Proc'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_Boton_btnValidaFabricacionOrigen_Proc
    @pnClaUbicacion             INT,
    @pnClaSolicitud	            INT = 0,
	@pnClaPedidoOrigen          INT = 0,
    @pnClaTipoTraspaso          INT = 0,
    @ptFechaDefault             DATETIME,
    @pnCmbProyecto              INT OUT,
    @pnCmbPlantaPide            INT OUT,
    @psClaPedidoCliente         VARCHAR(16) OUT,
    @pnClaEstatusPedidoOrigen   INT OUT,
    @ptFechaDesea               DATETIME OUT,
	@psObservaciones			VARCHAR(800) = '' OUT,
	@pnCmbPlantaSurte			INT OUT,	-- Se agregan para no perder el dato previamente guardado
	@pnCmbCliente				INT OUT,	-- Se agregan para no perder el dato previamente guardado
	@pnCmbConsignado			INT OUT		-- Se agregan para no perder el dato previamente guardado 
AS
BEGIN

	SET NOCOUNT ON

    DECLARE @nClaProyecto               INT = 0,
            @nClaUbicacionSolicita      INT = 0,
            @sClaPedidoCliente          VARCHAR(16) = NULL,
            @nClaEstatusPedidoOrigen    INT = 0,
            @tFechaDesea                DATETIME

    SELECT  @pnClaPedidoOrigen = ISNULL( @pnClaPedidoOrigen,0 )

    IF	( NOT EXISTS (	SELECT	1 
						FROM	OpeSch.OpeTraSolicitudTraspasoEncVw 
						WHERE	IdSolicitudTraspaso = @pnClaSolicitud 
						AND		ClaEstatusSolicitud NOT IN (0) ) 
		AND @pnClaPedidoOrigen > 0 ) 
    BEGIN
        --SELECT  @nClaUbicacionSolicita  =  (    CASE
        --                                            WHEN    ISNULL( ClaEstatus,0 ) = 1
        --                                            THEN    ClaPlanta
        --                                            ELSE    @pnCmbPlantaPide
        --                                        END),
        --        @sClaPedidoCliente      =  (    CASE
        --                                            WHEN    ISNULL( ClaEstatus,0 ) = 1
        --                                            THEN    ClaPedidoCliente
        --                                            ELSE    @psClaPedidoCliente
        --                                        END),
        --        @nClaEstatusPedidoOrigen =  (   CASE
        --                                            WHEN    ISNULL( ClaEstatus,0 ) = 1
        --                                            THEN    1
        --                                            ELSE    0
        --                                        END),
        --        @ptFechaDesea           =  (    CASE
        --                                            WHEN    ISNULL( ClaEstatus,0 ) = 1 AND @pnClaTipoTraspaso IN (3,4) AND @ptFechaDefault <= FechaPromesaOrigen
        --                                            THEN    FechaPromesaOrigen
        --                                            ELSE    @ptFechaDesea 
        --                                        END)
        --FROM    OpeSch.OpeTraFabricacionVw WITH(NOLOCK)  
        --WHERE   IdFabricacion = @pnClaPedidoOrigen

        SELECT  @nClaUbicacionSolicita  =  (    CASE
                                                    WHEN    ISNULL( ClaEstatusFabricacion,0 ) = 1
                                                    THEN    ClaUbicacion
                                                    ELSE    @pnCmbPlantaPide
                                                END),
                @sClaPedidoCliente      =  (    CASE
                                                    WHEN    ISNULL( ClaEstatusFabricacion,0 ) = 1
                                                    THEN    ClaPedidoCliente
                                                    ELSE    @psClaPedidoCliente
                                                END),
                @nClaEstatusPedidoOrigen =  (   CASE
                                                    WHEN    ISNULL( ClaEstatusFabricacion,0 ) = 1
                                                    THEN    1
                                                    ELSE    0
                                                END),
                @ptFechaDesea           =  (    CASE
                                                    WHEN    ISNULL( ClaEstatusFabricacion,0 ) = 1 AND @pnClaTipoTraspaso IN (3,4) AND @ptFechaDefault <= FechaPromesaOriginal
                                                    THEN    FechaPromesaOriginal
                                                    ELSE    @ptFechaDesea 
                                                END)
        FROM    DEAOFINET05.Ventas.VtaSch.VtaTraFabricacionVw WITH(NOLOCK)  
        WHERE   IdFabricacion = @pnClaPedidoOrigen


		SELECT	DISTINCT
                @nClaProyecto  = a.ClaProyecto
        FROM	OpeSch.OpeVtaCatProyectoVw a WITH(NOLOCK)  
        INNER JOIN	OpeSch.OpeVtaRelFabricacionProyectoVw b WITH(NOLOCK)  
        ON		a.ClaProyecto = b.ClaProyecto
        INNER JOIN	OpeSch.OpeTraFabricacionVw c WITH(NOLOCK)  
        ON		b.IdFabricacion = c.IdFabricacion
        WHERE	c.IdFabricacion = @pnClaPedidoOrigen
        AND     @nClaEstatusPedidoOrigen = 1
--      AND		ISNULL(a.BajaLogica,0) != 1

		IF @nClaEstatusPedidoOrigen <> 0
			SELECT @psObservaciones = '[Fab Ventas - '+CONVERT(VARCHAR(16),@pnClaPedidoOrigen)+']' + CHAR(13) + ISNULL(@psObservaciones,'')
	

		--- Ubicacion para Estimaciones
		IF EXISTS (
			SELECT	1
			FROM	OpeSch.OpeBitFabricacionEstimacion a WITH(NOLOCK)
			WHERE	a.IdFabricacionOriginal = @pnClaPedidoOrigen
		)
		BEGIN
			SELECT	@nClaUbicacionSolicita = ClaUbicacion 
			FROM	OpeSch.OpeBitFabricacionEstimacion a WITH(NOLOCK)
			WHERE	a.IdFabricacionOriginal = @pnClaPedidoOrigen
		END

    END

	IF @pnCmbPlantaPide <> @nClaUbicacionSolicita	-- Si hay diferencias con la Ubicación pide, setea a nulo los campos dependientes
	BEGIN
		SELECT	  @pnCmbPlantaSurte	= NULL
				, @pnCmbCliente		= NULL	
				, @pnCmbConsignado	= NULL	
	END

    SELECT  @pnCmbProyecto              = ISNULL( @nClaProyecto,0 ),
            @pnCmbPlantaPide            = @nClaUbicacionSolicita,
            @psClaPedidoCliente         = @sClaPedidoCliente,
            @pnClaEstatusPedidoOrigen   = ISNULL( @nClaEstatusPedidoOrigen,0 ),
            @ptFechaDesea               = @ptFechaDesea 

	SET NOCOUNT OFF    

	RETURN            

	-- Manejo de Errores              
	ABORT: 
    RAISERROR('El SP (OPE_CU550_Pag32_Boton_btnValidaFabricacionOrigen_Proc) no puede ser procesado.', 16, 1)        

END