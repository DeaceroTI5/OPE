USE [Operacion]
GO
--'OpeSch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_Sel
	  @pnClaUbicacion		INT
	, @psNumFacturaFilial	VARCHAR(20)
	, @pnClaUbicacionOrigen	INT
	, @psNumFacturaOrigen	VARCHAR(20)
	, @pnVerBajas			TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	-- exec OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_Sel @pnClaUbicacion=324,@psNumFacturaFilial='',@psClaUbicacionOrigen=191,@psNumFacturaOrigen='',@pnVerBajas=0

	SELECT	  a.IdRelFactura
			, a.ClaUbicacionOrigen
			, NomUbicacionOrigen = CONVERT(VARCHAR(10),a.ClaUbicacionOrigen) + ' - ' + b.NomUbicacion
			, a.NumFacturaFilial
			, a.NumFacturaOrigen
			, Numcertificado = ISNULL(a.Numcertificado,'')
			, a.ClaAceriaOrigen
			, NomAceriaOrigen = CONVERT(VARCHAR(10),a.ClaAceriaOrigen) +' - '+ d.NomUbicacion 
			, Estatus = CASE	WHEN a.ClaEstatus = 1 THEN 'Pendiente'
								WHEN a.ClaEstatus = 2 THEN 'En Proceso'
								WHEN a.ClaEstatus = 3 THEN 'Generado'
								ELSE 'Error' END
			, MensajeError = NULLIF(a.MensajeError,'')
			, Descarga = 'Descargar'
			, EsRegenerar = CASE WHEN /*c.ClaTipoUbicacion <> 2 AND */ a.ArchivoCertificado IS NOT NULL THEN 'Regenerar' ELSE '' END 
			, a.BajaLogica
	FROM	OpeSch.OpeRelFacturaSuministroDirecto a WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTiCatUbicacionVw b
	ON		a.ClaUbicacionOrigen = b.ClaUbicacion
	--LEFT JOIN OpeSch.OpeTiCatUbicacionVw c
	--ON		a.ClaUbicacion = c.ClaUbicacion
	LEFT JOIN OpeSch.OpeTiCatUbicacionVw d
	ON		a.ClaAceriaOrigen = d.ClaUbicacion
	WHERE	a.ClaUbicacion = @pnClaUbicacion
	AND		(@psNumFacturaFilial = '' OR(a.NumFacturaFilial LIKE '%'+@psNumFacturaFilial+'%'))
	AND		(@pnClaUbicacionOrigen IS NULL OR(a.ClaUbicacionOrigen = @pnClaUbicacionOrigen))
	AND		(@psNumFacturaOrigen = '' OR(a.NumFacturaOrigen LIKE '%'+ @psNumFacturaOrigen+'%'))
	AND		(a.BajaLogica = @pnVerBajas)
	--AND		(@pnVerBajas = 1 OR a.BajaLogica = 0)
	ORDER BY NumFacturaFilial ASC

	SET NOCOUNT OFF
END