ALTER PROCEDURE OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_Sel
	  @pnClaUbicacion		INT
	, @psNumFacturaFilial	VARCHAR(20)
	, @psClaUbicacionOrigen	INT
	, @psNumFacturaOrigen	VARCHAR(20)
	, @pnVerBajas			TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	-- exec OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_Sel @pnClaUbicacion=324,@psNumFacturaFilial='',@psClaUbicacionOrigen=191,@psNumFacturaOrigen='',@pnVerBajas=0

	SELECT	  a.NumFacturaFilial
			, a.ClaUbicacionOrigen
			, NomUbicacionOrigen = b.NomUbicacion
			, a.NumFacturaOrigen
			, Numcertificado = ISNULL(a.Numcertificado,'')
			, Estatus = CASE	WHEN a.ClaEstatus = 1 THEN 'Pendiente'
								WHEN a.ClaEstatus = 2 THEN 'En Proceso'
								WHEN a.ClaEstatus = 3 THEN 'Generado'
								ELSE 'Error' END
			, MensajeError = NULLIF(a.MensajeError,'')
			, Descarga = 'Descargar'
			, a.BajaLogica
	FROM	OpeSch.OpeRelFacturaSuministroDirecto a WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTiCatUbicacionVw b
	ON		a.ClaUbicacionOrigen = b.ClaUbicacion
	WHERE	a.ClaUbicacion = @pnClaUbicacion
	AND		(@psNumFacturaFilial = '' OR(a.NumFacturaFilial = @psNumFacturaFilial))
	AND		(@psClaUbicacionOrigen IS NULL OR(a.ClaUbicacionOrigen = @psClaUbicacionOrigen))
	AND		(@psNumFacturaOrigen = '' OR(a.NumFacturaOrigen = @psNumFacturaOrigen))
	AND		(@pnVerBajas = 1 OR a.BajaLogica = 0)
	ORDER BY NumFacturaFilial ASC

	SET NOCOUNT OFF
END
