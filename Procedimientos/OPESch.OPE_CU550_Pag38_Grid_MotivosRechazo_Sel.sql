USE Operacion
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag38_Grid_MotivosRechazo_Sel
	  @psNomMotivoRechazoF		VARCHAR(300) = ''
	, @pnClaUbicacion			INT  
	, @pnVerBajas				TINYINT 
AS  
BEGIN  
	SET NOCOUNT ON  
	
	SET @psNomMotivoRechazoF = ISNULL(@psNomMotivoRechazoF,'')

	SELECT    ClaMotivoRechazoSol = ClaMotivoRechazoSolTraspaso
			, NomMotivoRechazoSol = NomMotivoRechazoSolTraspaso
			, BajaLogica
	FROM	OpeSch.OpeCatMotivoRechazoSolTraspasoVw a
	WHERE	(@psNomMotivoRechazoF = '' OR (a.NomMotivoRechazoSolTraspaso LIKE '%'+@psNomMotivoRechazoF+'%'))
	AND		(@pnVerBajas = 1 OR a.BajaLogica = 0)
	ORDER BY ClaMotivoRechazoSolTraspaso ASC 
		
	SET NOCOUNT OFF  
END