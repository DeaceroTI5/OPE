ALTER proc OPESch.Ope_CU445_Pag3_Grid_ConfigCtasContables_Sel
	@pnClaUbicacion INT,
	@pnVerBajaLogica INT,
	@psIdioma VARCHAR(10) = 'Spanish',  
	@pnClaIdioma INT = 5,
	@pnClaArticulo	INT = NULL
AS 

BEGIN  

	SET NOCOUNT ON
 
	DECLARE @nClaEmpresa INT
	DECLARE @nClasificacionCuenta INT
	DECLARE @sGrupoAsignacion VARCHAR(400)
 
	SELECT @nClasificacionCuenta = NumValor1 
	FROM OpeSch.OpeCfgMaquilaParametroNeg WITH(NOLOCK) 
	WHERE ClaUbicacion = @pnClaUbicacion AND
		ClaParametro = 2
 
	SELECT @sGrupoAsignacion = LTRIM(RTRIM(TextoValor1))
	FROM OpeSch.OpeCfgMaquilaParametroNeg WITH(NOLOCK) 
	WHERE ClaUbicacion = @pnClaUbicacion AND
		ClaParametro = 3
 
	SELECT @nClaEmpresa = ClaEmpresa
	FROM OpeSch.OpeTiCatUbicacionVw WITH(NOLOCK) 
	WHERE ClaUbicacion = @pnClaUbicacion
 
	SELECT 
		A.ClaArticulo,
		C.ClaveArticulo +'-'+LTRIM(RTRIM(C.NomArticulo)) AS NomArticulo,
		A.ClaDireccion, 
		NomDireccion = CONVERT(VARCHAR, A.ClaDireccion) + ' ' + F.NombreDireccion, 
		@nClasificacionCuenta AS ClasificacionCuenta,
		A.ClaCRC,
		NomCrc = CONVERT(VARCHAR,A.ClaCRC)+'-'+D.NombreCrc,
		A.ClaTipoGasto,
		NomTipoGasto = CONVERT(VARCHAR,A.ClaTipoGasto)+'-'+E.NombreTipoGasto,
		@sGrupoAsignacion AS GrupoAsignacion, 
		CONVERT(BIT, A.BajaLogica) AS BajaLogica
	FROM OpeSch.OpeCfgPagoArticulo A WITH(NOLOCK) 
	LEFT JOIN OpeSch.ArtCatArticuloVw C WITH(NOLOCK) ON 
		C.ClaTipoInventario = 1 AND 
		C.ClaArticulo = A.ClaArticulo
	LEFT JOIN OpeSch.OpeConCatCrcVw D WITH(NOLOCK) ON 
		D.ClaClasificacionCrc = 0 AND
		D.EsAutorizado = 1 AND 
		D.ClaTipoCrc IN (1 ,3) AND 
		D.ClaCrc = A.ClaCRC
	LEFT JOIN OpeSch.OpeConCatTipoGastoVw E WITH(NOLOCK) ON 
		E.ClaEmpresa = @nClaEmpresa AND
		E.ClaTipoGasto = A.ClaTipoGasto
	LEFT JOIN OpeSch.OpeConCatDireccionVw F WITH(NOLOCK) ON 
		F.ClaUbicacion = @pnClaUbicacion AND 
		F.ClaDireccion = A.ClaDireccion
	WHERE A.ClaUbicacion = @pnClaUbicacion 
	AND (@pnVerBajaLogica=1 OR A.BajaLogica = @pnVerBajaLogica)
	AND	(@pnClaArticulo IS NULL OR (A.ClaArticulo= @pnClaArticulo))
	ORDER BY C.ClaveArticulo +'-'+LTRIM(RTRIM(C.NomArticulo))
		
	SET NOCOUNT OFF

END