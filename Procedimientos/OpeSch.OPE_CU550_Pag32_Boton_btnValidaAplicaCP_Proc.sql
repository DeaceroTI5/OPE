USE Operacion
GO
-- 'OpeSch.OPE_CU550_Pag32_Boton_btnValidaAplicaCP_Proc'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_Boton_btnValidaAplicaCP_Proc
    @pnClaUbicacion     INT,
    @pnClaUsuarioMod    INT,
    @pnClaSolicitud	    INT = 0,
    @pnClaPedido	    INT = 0,
    @pnEsAutorizadorCP  INT OUT,
    @pnEsEditableCP     INT OUT
AS
BEGIN    

    SET NOCOUNT ON

    DECLARE @nAplicaCP              INT = 0,
            @nTipoUbicacionSolicita INT = 0,
            @nUbicacionSolicita     INT = 0

    SELECT  @pnClaSolicitud     = ISNULL( @pnClaSolicitud,0 ),
            @pnClaPedido        = ISNULL( @pnClaPedido,0 )

    IF ( EXISTS ( SELECT 1  FROM OpeSch.OpeTraSolicitudTraspasoEncVw a
                            INNER JOIN OpeSch.OpeVtaTraFabricacionVw b -- DEAOFINET05.Ventas.VtaSch.VtaTraFabricacion
							ON a.ClaPedido = b.IdFabricacion
                            WHERE a.IdSolicitudTraspaso = @pnClaSolicitud AND a.ClaPedido = @pnClaPedido AND b.ClaEstatusFabricacion IN (4,5) ) 
        AND @pnClaSolicitud > 0 AND @pnClaPedido > 0 ) 
    BEGIN
        SELECT  @nUbicacionSolicita = ClaUbicacionSolicita
        FROM    OpeSch.OpeTraSolicitudTraspasoEncVw 
        WHERE   IdSolicitudTraspaso = @pnClaSolicitud 
        AND     ClaEstatusSolicitud IN (1)

        SELECT  @nTipoUbicacionSolicita = ClaTipoUbicacion
        FROM	OpeSch.OpeTiCatUbicacionVw WITH(NOLOCK)  
        WHERE	ClaUbicacion = @nUbicacionSolicita
        --AND     (ClaEmpresa IN (52)
        --OR		ClaUbicacion IN (277,278,364))

        IF ( EXISTS ( SELECT 1 FROM OpeSch.OpeCfgUsuarioTraspaso t1 WHERE   t1.ClaUsuario = @pnClaUsuarioMod 
                                                                    AND     t1.ClaUbicacion = -1 
                                                                    AND     t1.ClaTipoUbicacion = -1 
                                                                    AND     t1.EsUsuarioCancelaPedido = 1
                                                                    AND     t1.BajaLogica = 0 ) )
        BEGIN
            SELECT  @nAplicaCP = 1
        END
        ELSE IF ( EXISTS ( SELECT 1 FROM OpeSch.OpeCfgUsuarioTraspaso t2    WHERE   t2.ClaUsuario = @pnClaUsuarioMod 
                                                                            AND     t2.ClaUbicacion = -1 
                                                                            AND     t2.ClaTipoUbicacion = @nTipoUbicacionSolicita
                                                                            AND     t2.EsUsuarioCancelaPedido = 1
                                                                            AND     t2.BajaLogica = 0 ) )
        BEGIN
            SELECT  @nAplicaCP = 1
        END
        ELSE IF ( EXISTS ( SELECT 1 FROM OpeSch.OpeCfgUsuarioTraspaso t3    WHERE   t3.ClaUsuario = @pnClaUsuarioMod 
                                                                            AND     t3.ClaUbicacion = @nUbicacionSolicita
                                                                            AND     t3.EsUsuarioCancelaPedido = 1
                                                                            AND     t3.BajaLogica = 0 ) )
        BEGIN
            SELECT  @nAplicaCP = 1
        END
    END

    SELECT  @pnEsAutorizadorCP  = ISNULL( @nAplicaCP,0 ),
            @pnEsEditableCP     = ISNULL( @nAplicaCP,0 )

	SET NOCOUNT OFF    

	RETURN     

	-- Manejo de Errores              
	ABORT: 
    RAISERROR('El SP (OPE_CU550_Pag32_Boton_btnValidaAplicaCP_Proc) no puede ser procesado.', 16, 1)        

END