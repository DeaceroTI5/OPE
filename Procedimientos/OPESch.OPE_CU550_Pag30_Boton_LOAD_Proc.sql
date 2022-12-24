USE Operacion
GO

ALTER PROCEDURE OPESch.OPE_CU550_Pag30_Boton_LOAD_Proc
	@pnClaUbicacion	INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @nEsUbicacionIngetek TINYINT 

	SELECT	@nEsUbicacionIngetek = CASE WHEN ClaEmpresa = 52 THEN 1 ELSE 0 END
	FROM	OpeSch.OpeTiCatUbicacionVw 
	WHERE	ClaUbicacion = @pnClaUbicacion


	SELECT EsUbicacionIngetek = ISNULL(@nEsUbicacionIngetek,0)

	SET NOCOUNT OFF
END