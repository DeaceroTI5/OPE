USE Operacion
GO
	-- 'OPESch.OPE_CU53_Pag24_Grid_grdCfgAutorizador_Sel'
GO
ALTER PROCEDURE OPESch.OPE_CU53_Pag24_Grid_grdCfgAutorizador_Sel
	@pnClaUbicacion			INT,
	@pnClaTipoAutorizacion	INT = NULL,
	@pnClaAutorizacion		INT = NULL,
	@pnClaUsuario			INT = NULL,
	@pnBajaLogica			TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	SELECT A.ClaTipoAutorizacion,
		B.NomTipoAutorizacion,
		A.ClaAutorizacion,
		C.NomAutorizacion,
		A.IdUsuario AS ClaUsuario,
		(LTRIM(RTRIM(ISNULL(CONVERT(VARCHAR(20), D.ClaEmpleado),''))) + CHAR(32) + ' - ' + CHAR(32) +  
			LTRIM(RTRIM(ISNULL(D.NombreUsuario,''))) + CHAR(32) +  
			LTRIM(RTRIM(ISNULL(D.ApellidoPaterno,''))) + CHAR(32) +  
			LTRIM(RTRIM(ISNULL(D.ApellidoMaterno,'')))) AS NomUsuario,
		A.FechaInicio,
		A.FechaFin,
		A.HoraLVInicio,
		A.HoraLVFin,
		A.HoraSDInicio,
		A.HoraSDFin ,
		A.BajaLogica
	FROM OpeSch.OpeCfgAutorizador A WITH(NOLOCK)
	INNER JOIN OpeSch.OpeCatTipoAutorizacion B WITH(NOLOCK) ON
		B.ClaUbicacion = A.ClaUbicacion AND
		B.ClaTipoAutorizacion = A.ClaTipoAutorizacion
	INNER JOIN OpeSch.OpeCatAutorizacion C WITH(NOLOCK) ON
		C.ClaUbicacion = A.ClaUbicacion AND
		C.ClaTipoAutorizacion = A.ClaTipoAutorizacion AND
		C.ClaAutorizacion = A.ClaAutorizacion
	INNER JOIN OpeSch.OpeCatUsuarioVw D WITH(NOLOCK) ON
		D.IdUsuario = A.IdUsuario AND   
		D.Perfil = 0 AND
		D.BajaLogica = 0
	WHERE A.ClaUbicacion = @pnClaUbicacion 
	AND	A.BajaLogica = (CASE WHEN @pnBajaLogica = 1 THEN A.BajaLogica ELSE @pnBajaLogica END)
	AND	(@pnClaTipoAutorizacion	IS NULL OR (@pnClaTipoAutorizacion = A.ClaTipoAutorizacion))
	AND	(@pnClaAutorizacion	IS NULL OR(@pnClaAutorizacion = A.ClaAutorizacion))
	AND	(@pnClaUsuario IS NULL OR (@pnClaUsuario = A.IdUsuario))
	ORDER BY D.IdUsuario
	
	SET NOCOUNT OFF
END