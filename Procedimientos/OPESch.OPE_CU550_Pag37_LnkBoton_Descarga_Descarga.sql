USE Operacion
GO
-- EXEC SP_HELPTEXT 'OPESch.OPE_CU550_Pag37_LnkBoton_Descarga_Descarga'
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag37_LnkBoton_Descarga_Descarga
	@pnClaUbicacion		INT,
	@pnIdRelFactura		INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	FileData = ArchivoCertificado,
			FileName = CASE WHEN ISNULL(NumCertificado,'')<> '' 
							THEN NumCertificado 
							ELSE CONVERT(VARCHAR(20),IdCertificado) END,
			FileExt = 'pdf'
	FROM	OpeSch.OpeRelFacturaSuministroDirecto a WITH(NOLOCK)
	WHERE	a.ClaUbicacion = @pnClaUbicacion
	AND		a.IdRelFactura = @pnIdRelFactura

	SET NOCOUNT OFF
END