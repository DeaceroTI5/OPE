GO
-- 'OpeSch.OPE_CU550_Pag32ModalCargaPartidasOrigen_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag32ModalCargaPartidasOrigen_Sel
	@pnClaUbicacion         INT,
    @pnClaSolicitud         INT,
    @pnClaPedidoOrigen      INT
AS
BEGIN
    
    SET NOCOUNT ON
    
    DECLARE @sClienteCP         VARCHAR(500),
            @sProyectoCP        VARCHAR(500),
            @nFabricacionCP     INT

    SELECT  @sClienteCP       = CONVERT(VARCHAR(10),d.ClaClienteCuenta) + ' - '  + LTRIM(RTRIM(d.NomClienteCuenta)),
            @sProyectoCP      = CONVERT(VARCHAR(10),c.ClaProyecto) + ' - '  + LTRIM(RTRIM(c.NomProyecto)),
            @nFabricacionCP   = a.IdFabricacion
    FROM    OpeSch.OpeTraFabricacionVw a WITH(NOLOCK)  
    INNER JOIN  OpeSch.OpeVtaRelFabricacionProyectoVw b WITH(NOLOCK)  
        ON  a.IdFabricacion = b.IdFabricacion
    INNER JOIN  OpeSch.OpeVtaCatProyectoVw c WITH(NOLOCK)  
        ON  b.ClaProyecto = c.ClaProyecto
    INNER JOIN  OpeSch.OpeVtaCatClienteCuentaVw d WITH(NOLOCK)  
        ON  c.ClaClienteCuenta = d.ClaClienteCuenta
    WHERE a.IdFabricacion = @pnClaPedidoOrigen
    
    SELECT  ClienteCP       = @sClienteCP,
            ProyectoCP      = @sProyectoCP,
            FabricacionCP   = @nFabricacionCP

    SET NOCOUNT OFF    

	RETURN
END