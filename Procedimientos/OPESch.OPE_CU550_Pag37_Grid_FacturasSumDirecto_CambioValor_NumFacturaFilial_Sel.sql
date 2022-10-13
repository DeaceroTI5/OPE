USE Operacion
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_CambioValor_NumFacturaFilial_Sel
	  @pnClaUbicacion		INT
	, @psNumFacturaFilial	VARCHAR(15)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE	  @sMensajeError	VARCHAR(1000) = ''
			, @sUbicacion		VARCHAR(50)

	SELECT	@sUbicacion = NombreUbicacion
	FROM	OpeSch.OpeTiCatUbicacionVw
	WHERE	ClaUbicacion = @pnClaUbicacion

	IF NOT EXISTS(
				SELECT	1 
				FROM	OpeSch.OpeTraMovEntSal WITH(NOLOCK)
				WHERE	ClaUbicacion = @pnClaUbicacion
				AND		IdFacturaAlfanumerico = @psNumFacturaFilial
	)
	BEGIN
		SELECT @sMensajeError = 'La factura <b>' + @psNumFacturaFilial + '</b> no existe en ' + ISNULL(@sUbicacion,'') + '.'
		RAISERROR(@sMensajeError,16,1)
		RETURN
	END

	SET NOCOUNT OFF
END