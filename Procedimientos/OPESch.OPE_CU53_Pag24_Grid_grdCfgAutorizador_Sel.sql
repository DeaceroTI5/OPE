Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE PROCEDURE OPESch.OPE_CU53_Pag24_Grid_grdCfgAutorizador_Sel
	@pnClaUbicacion INT,
	@pnBajaLogica TINYINT
AS
BEGIN
	SET NOCOUNT ON

	SELECT A.ClaTipoAutorizacion,
		B.NomTipoAutorizacion,
		A.ClaAutorizacion,
		C.NomAutorizacion,
		A.IdUsuario AS ClaUsuario,
		(LTRIM(RTRIM(ISNULL(CONVERT(VARCHAR(20), D.IdUsuario),''))) + CHAR(32) + ' - ' + CHAR(32) +  
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
	LEFT JOIN OpeSch.OpeCatTipoAutorizacion B WITH(NOLOCK) ON
		B.ClaUbicacion = A.ClaUbicacion AND
		B.ClaTipoAutorizacion = A.ClaTipoAutorizacion
	LEFT JOIN OpeSch.OpeCatAutorizacion C WITH(NOLOCK) ON
		C.ClaUbicacion = A.ClaUbicacion AND
		C.ClaTipoAutorizacion = A.ClaTipoAutorizacion AND
		C.ClaAutorizacion = A.ClaAutorizacion
	LEFT JOIN OpeSch.OpeCatUsuarioVw D WITH(NOLOCK) ON
		D.IdUsuario = A.IdUsuario AND   
		D.Perfil = 0
	WHERE A.ClaUbicacion = @pnClaUbicacion AND
		A.BajaLogica = (CASE WHEN @pnBajaLogica = 1 THEN A.BajaLogica ELSE @pnBajaLogica END)
	ORDER BY D.IdUsuario
	
	SET NOCOUNT OFF
END