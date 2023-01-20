GO
-- 'OpeSch.OPE_CU550_Pag32_Boton_btnValidaAplicaAA_Proc'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_Boton_btnValidaAplicaAA_Proc
    @pnClaUbicacion             INT,
    @pnClaSolicitud	            INT = 0,
    @pnClaPedidoOrigen          INT = 0,
    @pnClaEstatusPedidoOrigen	INT = 0,
    @pnEsEditableAA             INT OUT
AS
BEGIN

	SET NOCOUNT ON

    DECLARE @nAplicaAA              INT = 0

    SELECT  @pnClaSolicitud             = ISNULL( @pnClaSolicitud,0 ),
            @pnClaPedidoOrigen          = ISNULL( @pnClaPedidoOrigen,0 ),
            @pnClaEstatusPedidoOrigen   = ISNULL( @pnClaEstatusPedidoOrigen,0 )

    IF ( EXISTS ( SELECT 1 FROM OpeSch.OpeTraSolicitudTraspasoEncVw WHERE IdSolicitudTraspaso = @pnClaSolicitud AND ClaEstatusSolicitud IN (0) ) 
        AND @pnClaSolicitud > 0 AND @pnClaPedidoOrigen > 0 AND @pnClaEstatusPedidoOrigen > 0 ) 
    BEGIN
        IF ( EXISTS( SELECT 1  FROM OpeSch.OpeVtaTraFabricacionVw a -- DEAOFINET05.Ventas.VtaSch.VtaTraFabricacion 
                            INNER JOIN OpeSch.OpeVtaTraFabricacionDetVw b -- DEAOFINET05.Ventas.VtaSch.VtaTraFabricacionDet 
							ON a.IdFabricacion = b.IdFabricacion
                            WHERE a.IdFabricacion = @pnClaPedidoOrigen AND b.ClaEstatusFabricacion IN (4,5) ) )
        BEGIN
            SELECT  @nAplicaAA = 1
        END
    END

    SELECT  @pnEsEditableAA = ISNULL( @nAplicaAA,0 )

	SET NOCOUNT OFF    

	RETURN            

	-- Manejo de Errores              
	ABORT: 
    RAISERROR('El SP (OPE_CU550_Pag32_Boton_btnValidaAplicaAA_Proc) no puede ser procesado.', 16, 1)        

END