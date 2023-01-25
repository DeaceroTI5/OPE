Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 
CREATE PROC OPESch.OPE_CU53_Pag1_Grid_LecturaBascula_Sel
@pnClaUbicacion INT,
@psnombrePcMod VARCHAR(100),
@pnUsaBasculasn INT = 1
AS
BEGIN
	SET NOCOUNT ON
	IF @pnUsaBasculasn = 0
	BEGIN
		SELECT null AS clabascula, null AS pesoBascula 
		WHERE 1 <> 1
		RETURN
	end
 
	SELECT	 t1.ClaBascula, CAST(ROUND (t1.Peso,0,1) AS INT)  AS pesoBascula
	FROM	OpeSch.OpeLogPesajeEstativo t1(nolock)
	INNER JOIN OpeSch.OpeCfgBasculasPorPc t2(nolock) ON	t2.ClaBascula = t1.ClaBascula AND
													t2.ClaUbicacion = t1.ClaPlanta AND
													t2.BajaLogica = 0
	INNER JOIN OpeSch.OpeCatBasculas t3(nolock) ON	t3.ClaBAscula = t1.ClaBascula AND
												t3.ClaPlanta = @pnClaUbicacion
	WHERE	t2.NomPC like @psnombrePcMod AND
			t1.ClaPlanta = @pnClaUbicacion
	UNION
	SELECT	t1.ClaBascula, CAST(ROUND (t1.Peso,0,1) AS INT) AS pesoBascula
	FROM	OpeSch.OpeLogPesajeEstativo t1(nolock)
	INNER JOIN OpeSch.OpeCatBasculas t2(nolock) ON	t2.ClaBAscula = t1.ClaBascula AND
												t2.ClaPlanta = @pnClaUbicacion
	WHERE	t1.ClaPlanta = @pnClaUbicacion AND
			t1.ClaBascula NOT IN(	SELECT	t2.ClaBascula
									FROM	OpeSch.OpeCfgBasculasPorPc t2(nolock) 
									WHERE	t2.NomPC like @psnombrePcMod AND
											t2.ClaUbicacion = @pnClaUbicacion AND
											t2.BajaLogica = 0)
 
	SET NOCOUNT OFF
END