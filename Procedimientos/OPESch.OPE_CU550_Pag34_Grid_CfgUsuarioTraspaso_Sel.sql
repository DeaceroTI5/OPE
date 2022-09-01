USE Operacion
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag34_Grid_CfgUsuarioTraspaso_Sel
	  @pnClaUsuarioF			INT = NULL
	, @pnClaTipoUbicacion	INT = NULL
	, @pnClaUbicacionF	INT = NULL
	, @pnVerBajas			TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	SELECT	  a.ClaUsuario
			, NomUsuario = CONVERT(VARCHAR(10),b.ClaEmpleado) + ' - ' + b.NomUsuario
			, a.ClaTipoUbicacion
			, NomTipoUbicacion = CASE WHEN a.ClaTipoUbicacion = -1 THEN 'Todos' ELSE c.NombreTipoUbicacion END
			, ClaUbicacionCfg = a.ClaUbicacion
			, NomUbicacionCfg = CASE WHEN a.ClaUbicacion = -1 THEN 'Todos' ELSE d.NomUbicacion END
			, a.EsUsuarioCancelaSolicitud
			, a.EsUsuarioCancelaPedido
			, a.EsUsuarioAutorizador
			, a.BajaLogica
	FROM	OpeSch.OpeCfgUsuarioTraspaso a WITH(NOLOCK)
	LEFT JOIN OpeSch.OpeTiCatUsuarioVw b
	ON		a.ClaUsuario = b.ClaUsuario
	LEFT JOIN OpeSch.OpeTiCatTipoUbicacionVw c
	ON		a.ClaTipoUbicacion = c.ClaTipoUbicacion
	LEFT JOIN OpeSch.OpeTiCatUbicacionVw d
	ON		a.ClaUbicacion = d.ClaUbicacion
	WHERE	(@pnClaUsuarioF IS NULL OR (a.ClaUsuario = @pnClaUsuarioF))
	AND		(@pnClaTipoUbicacion IS NULL OR (a.ClaTipoUbicacion = @pnClaTipoUbicacion))
	AND		(@pnClaUbicacionF IS NULL OR (a.ClaUbicacion = @pnClaUbicacionF))
	AND		(@pnVerBajas = 1 OR a.BajaLogica = @pnVerBajas)

	SET NOCOUNT OFF
END