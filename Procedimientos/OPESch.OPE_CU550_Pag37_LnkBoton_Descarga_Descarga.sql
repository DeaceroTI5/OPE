ALTER PROCEDURE OPESch.OPE_CU550_Pag37_LnkBoton_Descarga_Descarga
	  @pnClaUbicacion INT
	, @psNumFacturaFilial	VARCHAR(20)
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
	AND		a.NumFacturaFilial = @psNumFacturaFilial

	SET NOCOUNT OFF
END

