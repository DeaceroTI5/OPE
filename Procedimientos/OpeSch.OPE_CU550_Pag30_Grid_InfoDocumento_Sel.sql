USE Operacion
GO
	-- 'OpeSch.OPE_CU550_Pag30_Grid_InfoDocumento_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag30_Grid_InfoDocumento_Sel
	@pnClaUbicacion		INT,
	@pnIdViajeAux		INT,
	@pnClaUsuarioMod	INT,
	@psNombrePcMod		VARCHAR(64)
AS
BEGIN

	-- EXEC OPESch.OPE_CU550_Pag30_Grid_InfoDocumento_Sel 325, 2650, 1

	SET NOCOUNT ON
	 
	DECLARE	@nIdFactura	INT = NULL

	SELECT	@nIdFactura = a.IdFactura
	FROM	OpeSch.OpeTraMovEntSal a WITH(NOLOCK)
	WHERE	a.ClaUbicacion = @pnClaUbicacion
	AND		a.IdViaje = @pnIdViajeAux	

	IF NOT EXISTS (	SELECT	1 
					FROM	OpeSch.OpeRelViajeDocumento a WITH(NOLOCK)
					WHERE	a.ClaUbicacion = @pnClaUbicacion
					AND		a.IdViaje = @pnIdViajeAux	
					AND		a.ClaTipoDocumento = 27	)
	   AND @nIdFactura IS NOT NULL
	BEGIN
		EXEC OpeSch.OpeObtenerCertificadosAce @pnClaUbicacion, @pnIdViajeAux, @pnClaUsuarioMod, @psNombrePcMod
	END

	/* El dato de Fabricacion se incluyo mejor en la tabla de OpeSch.OpeRelViajeDocumento
	CREATE TABLE #FabricacionViaje
	(	
		ClaUbicacion	INT,
		IdViaje			INT,
		IdFactura		INT,
		IdFabricacion	INT
	)

	INSERT	INTO #FabricacionViaje
	( ClaUbicacion, IdViaje, IdFactura, IdFabricacion )
	SELECT	ClaUbicacion, IdViaje, IdFactura, IdFabricacion
	FROM	OpeSch.OpeTraMovEntSalVw 
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		IdViaje = @pnIdViajeAux
	*/

	SELECT	  IdDocumento			AS IdDocumento
			, ClaTipoDocumento
			, NumDocumento
			, b.NomFormatoImpresion AS TipoDocumento
			, NombreArchivo			= ISNULL(NombreArchivo,'') + '.' + ISNULL(ExtensionArchivo,'')
			, btnAbrirArchivo		= 'Ver'
			, btnEditarArchivo		= 'Editar'
			, IdFabricacion			= a.IdFabricacion
			, NomOrigenDocumento	= CONVERT(VARCHAR(10),a.ClaOrigenDocumento)+' - '+c.NomUbicacion
			, a.ClaOrigenDocumento
	FROM	OpeSch.OpeRelViajeDocumento a WITH(NOLOCK)
	INNER JOIN OpeSch.OpeCatFormatoImpresion b
	ON		a.ClaTipoDocumento = b.ClaFormatoImpresion
	LEFT JOIN OpeSch.OpeCatUbicacionGalvanizadoVw c
	ON		a.ClaOrigenDocumento = c.ClaUbicacion
	--LEFT JOIN #FabricacionViaje c
	--ON		a.ClaUbicacion = c.ClaUbicacion
	--AND		a.IdViaje = c.IdViaje
	--AND		a.IdDocumento = c.IdFactura
	WHERE	a.ClaUbicacion = @pnClaUbicacion
	AND		a.IdViaje = @pnIdViajeAux
	
	SET NOCOUNT OFF

END