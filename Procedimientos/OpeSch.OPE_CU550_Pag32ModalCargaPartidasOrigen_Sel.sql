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
            @nFabricacionCP     INT,
			@nEsExportacion		INT

	SELECT	  @nEsExportacion	= EsDoorToDoor
	FROM	OpeSch.OpeTraSolicitudTraspasoEncVw WITH(NOLOCK)
	WHERE	IdSolicitudTraspaso = @pnClaSolicitud

	IF ISNULL(@nEsExportacion,0) = 0
	BEGIN
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
	END
	ELSE
	BEGIN
		SELECT  @sClienteCP       = CASE WHEN d.ClaClienteCuenta IS NOT NULL 
											THEN CONVERT(VARCHAR(10),d.ClaClienteCuenta) + ' - '  + LTRIM(RTRIM(d.NomClienteCuenta))
											ELSE CONVERT(VARCHAR(10),f.ClaClienteCuenta) + ' - '  + LTRIM(RTRIM(f.NomClienteCuenta)) END,
				@sProyectoCP      = CONVERT(VARCHAR(10),c.ClaProyecto) + ' - '  + LTRIM(RTRIM(c.NomProyecto)),
				@nFabricacionCP   = a.IdFabricacion
		FROM    DEAOFINET05.Ventas.VtaSch.VtaTraFabricacion a WITH(NOLOCK)  
		LEFT JOIN  OpeSch.OpeVtaRelFabricacionProyectoVw b WITH(NOLOCK)  
			ON  a.IdFabricacion = b.IdFabricacion
		LEFT JOIN  OpeSch.OpeVtaCatProyectoVw c WITH(NOLOCK)  
			ON  b.ClaProyecto = c.ClaProyecto
		LEFT JOIN  OpeSch.OpeVtaCatClienteCuentaVw d WITH(NOLOCK)  
			ON  c.ClaClienteCuenta = d.ClaClienteCuenta
		LEFT JOIN  OpeSch.OpeVtaCatProyectoVw e WITH(NOLOCK)  
			ON  a.ClaProyecto = e.ClaProyecto
		LEFT JOIN  OpeSch.OpeVtaCatClienteCuentaVw f WITH(NOLOCK)  
			ON  e.ClaClienteCuenta = f.ClaClienteCuenta
		WHERE a.IdFabricacion = @pnClaPedidoOrigen
	END
    
    SELECT  ClienteCP       = @sClienteCP,
            ProyectoCP      = @sProyectoCP,
            FabricacionCP   = @nFabricacionCP

    SET NOCOUNT OFF    

	RETURN
END