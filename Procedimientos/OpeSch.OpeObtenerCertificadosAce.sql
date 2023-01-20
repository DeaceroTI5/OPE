USE Operacion
GO
-- 'OpeSch.OpeObtenerCertificadosAce'
GO
ALTER PROCEDURE OpeSch.OpeObtenerCertificadosAce
	@pnClaUbicacion		INT,
	@pnIdViajeAux		INT,
	@pnClaUsuarioMod	INT,
	@psNombrePcMod		VARCHAR(64)
AS
BEGIN

	-- EXEC OpeSch.OpeObtenerCertificadosAce 325, 2615, 1

	SET NOCOUNT ON

	DECLARE @sNombrePcModNuevo VARCHAR(64)

	SET @sNombrePcModNuevo = LTRIM(RTRIM(@psNombrePcMod)) + ' - OpeObtenerCertificadosAce'

	INSERT INTO OpeSch.OpeRelViajeDocumento
	( ClaUbicacion, IdViaje, IdDocumento, ClaTipoDocumento, NombreArchivo, ExtensionArchivo, ClaUsuarioMod, NombrePcMod, FechaUltimaMod, NumDocumento, IdFabricacion )
	SELECT	a.ClaUbicacion, a.IdViaje, a.IdFactura, 27, a.NumFactura, 'pdf', @pnClaUsuarioMod, @sNombrePcModNuevo, GETDATE(), a.IdCertificado, null
	FROM	Deaofinet04.Operacion.ACESCH.AceTraCertificado a WITH(NOLOCK)
	WHERE	a.ClaUbicacion = @pnClaUbicacion
	AND		a.IdViaje = @pnIdViajeAux
	AND		ISNULL(a.IdFactura, -1) <> -1
	AND		a.Archivo IS NOT NULL
	AND		NOT EXISTS	(	SELECT	1
							FROM	OpeSch.OpeRelViajeDocumento b WITH(NOLOCK)
							WHERE	a.ClaUbicacion = b.ClaUbicacion
							AND		a.IdViaje = b.IdViaje
							AND		a.IdFactura = b.IdDocumento
							AND		a.IdCertificado = b.NumDocumento
							AND		b.ClaTipoDocumento = 27	)


	UPDATE	OpeSch.OpeRelViajeDocumento
	SET		IdFabricacion = b.IdFabricacion
	FROM	OpeSch.OpeRelViajeDocumento a
	INNER JOIN OpeSch.OpeTraMovEntSal b WITH(NOLOCK)
	ON		a.ClaUbicacion = b.ClaUbicacion
	AND		a.IdViaje = b.IdViaje
	AND		a.IdDocumento = b.IdFactura
	WHERE	a.ClaUbicacion = @pnClaUbicacion
	AND		a.IdViaje = @pnIdViajeAux
	AND		a.IdFabricacion IS NULL

	INSERT INTO OpeSch.OpeReporteFactura
	( ClaUbicacion, IdFactura, ClaFormatoImpresion, IdCertificado, Impresion, FechaUltimaMod, NombrePcMod, ClaUsuarioMod )
	SELECT	a.ClaUbicacion, a.IdFactura, 27, a.IdCertificado, a.Archivo, GETDATE(), @sNombrePcModNuevo, @pnClaUsuarioMod 
	FROM	Deaofinet04.Operacion.ACESCH.AceTraCertificado a WITH(NOLOCK)
	WHERE	a.ClaUbicacion = @pnClaUbicacion
	AND		a.IdViaje = @pnIdViajeAux
	AND		ISNULL(a.IdFactura, -1) <> -1
	AND		a.Archivo IS NOT NULL
	AND		NOT EXISTS	(	SELECT	1
							FROM	OpeSch.OpeReporteFactura b WITH(NOLOCK)
							WHERE	a.ClaUbicacion = b.ClaUbicacion
							AND		a.IdFactura = b.IdFactura
							AND		a.IdCertificado = b.IdCertificado
							AND		b.ClaFormatoImpresion = 27	)


END