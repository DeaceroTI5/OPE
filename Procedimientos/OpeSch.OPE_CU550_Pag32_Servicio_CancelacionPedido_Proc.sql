USE Operacion
GO
-- 'OpeSch.OPE_CU550_Pag32_Servicio_CancelacionPedido_Proc'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_Servicio_CancelacionPedido_Proc
    @pnClaSolicitud             INT, --Clave de Solicitud de Traspaso Manual 
    @pnClaPedido                INT, --Id Fabricacion de Traspaso Manual
    @pnClaUsuarioMod            INT, --Usuario Autorizador
    @psNombrePcMod              VARCHAR(64)
AS
BEGIN

	SET NOCOUNT ON

    IF ( EXISTS ( SELECT 1  FROM OpeSch.OpeTraSolicitudTraspasoEncVw a
                            INNER JOIN DEAOFINET05.Ventas.VtaSch.VtaTraFabricacion b ON a.ClaPedido = b.IdFabricacion
                            WHERE a.IdSolicitudTraspaso = @pnClaSolicitud AND a.ClaPedido = @pnClaPedido AND b.ClaEstatusFabricacion IN (4,5) ) 
        AND @pnClaSolicitud > 0 AND @pnClaPedido > 0 ) 
    BEGIN
        --Declaración de Variables Cancelacion
        DECLARE @nFabricacionCancelacion INT = NULL, @nErrorCancelacion INT = NULL, @sResMensajeCancelacion VARCHAR(200) = NULL, @sNoUtilCancelacion VARCHAR(4000) = Null

        DECLARE @PedidosCancelacion TABLE
                (Consecutivo        INT IDENTITY(1,1),
                IdFabricacion       INT,
                Partidas            INT,
                ClaEstatusFab       INT,
                PartidasActivas     INT,
                Error               INT,
                Mensaje             VARCHAR(200))

        --Proceso de llenado de Fabriaciones a Cancelar
        INSERT INTO @PedidosCancelacion (IdFabricacion, Partidas, ClaEstatusFab, PartidasActivas, Error, Mensaje)
        SELECT	a.IdFabricacion, COUNT(b.NumeroRenglon), a.ClaEstatusFabricacion, SUM(CASE WHEN b.ClaEstatusFabricacion IN (4,5) THEN 1 ELSE 0 END), NULL, NULL
        FROM	DEAOFINET05.Ventas.VtaSch.VtaTraFabricacion a WITH(NOLOCK)
            INNER JOIN	DEAOFINET05.Ventas.VtaSch.VtaTraFabricacionDet b WITH(NOLOCK)
                        ON b.IdFabricacion = a.IdFabricacion
        WHERE	a.IdFabricacion IN (@pnClaPedido)
        GROUP BY
                a.IdFabricacion, a.ClaEstatusFabricacion
        

        --Proceso de Cancelación
        IF EXISTS ( SELECT  1    
                    FROM    @PedidosCancelacion
                    WHERE   ClaEstatusFab IN (4,5)
                    AND     Partidas > 0
                    AND     PartidasActivas > 0)
        BEGIN
            SELECT	@nFabricacionCancelacion = IdFabricacion
            FROM	@PedidosCancelacion
            WHERE	IdFabricacion = @pnClaPedido

            EXEC DEAOFINET05.Ventas.Vtasch.VtaCancelarFabricacionSrv
                    @pnIdFabricacion = @nFabricacionCancelacion, 
                    @pnNumeroRenglon = 0, --@pnIdRenglon,
                    @pnTipoCancelacion = 2, -- No se usa
                    @pnEsCancelacionTotal = 1,
                    @pnClaTipoCancelacion = 5, --(VTASch.VtaCatTipoCancelacionVw) 1.Cancelación, 2.Recapturas, 3.Automáticas, 4.Masivas, 5.Cambios, 6.Liberación Master
                    @pnOrigenCancelacion = 1, --(VTASch.VtaCatOrigenCancelacionVw) 1.Ventas,2.Logística,3.Operación,4.Calidad,5.Cliente,6.Portal de clientes
                    @pnMotivoCancelacion = 1077, --(vtasch.VtaCatMotivoVw) --1077.Incremento cantidad mismas partidas, 1079.Agregar nuevas partidas
                    @pnClaUsuarioMod = @pnClaUsuarioMod,
                    @psNombrePcMod = @psNombrePcMod, ---@psNombrePcMod,
                    @pnError = @nErrorCancelacion OUT,
                    @psMsgError = @sResMensajeCancelacion OUTPUT,
                    @psNoUtil = @sNoUtilCancelacion OUTPUT      
        END


		IF ISNULL(@nErrorCancelacion,0) <> 0
		BEGIN
			SELECT @sResMensajeCancelacion = ISNULL(@sResMensajeCancelacion,'') + ' (Vtasch.VtaCancelarFabricacionSrv).'
			GOTO ABORT
		END

    END

	SET NOCOUNT OFF    

	RETURN            

	-- Manejo de Errores              
	ABORT:
	SELECT @sResMensajeCancelacion = 'El SP (OPE_CU550_Pag32_Servicio_CancelacionPedido_Proc) no puede ser procesado. ' + ISNULL(@sResMensajeCancelacion,'')
    RAISERROR(@sResMensajeCancelacion, 16, 1)        

END