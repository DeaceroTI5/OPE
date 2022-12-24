ALTER PROCEDURE OPESch.OpeOrigenDocumentoCmb 
	 @psValor		VARCHAR(100)-- Texto a Buscar    
	,@pnTipo		INT			-- 1=Buscar por la ClaveXxxxx    
--	,@pnModoSel		INT = 1
--	,@pnBajasSn		INT = 0
AS
BEGIN
	
	SELECT @psValor = ISNULL(@psValor,'')

	IF @pnTipo  IN (1,99)	--Se agrega validación para Mostrar Default
		SELECT	 ClaOrigenDocumento = ClaUbicacion
				,NomOrigenDocumento = CONVERT(VARCHAR(10),ClaUbicacion)+' - '+ NomUbicacion
		FROM	OpeSch.OpeCatUbicacionGalvanizadoVw
		WHERE	ClaUbicacion = @psValor
	ELSE 
		SELECT	 ClaOrigenDocumento = ClaUbicacion
				,NomOrigenDocumento = CONVERT(VARCHAR(10),ClaUbicacion)+' - '+ NomUbicacion
		FROM	OpeSch.OpeCatUbicacionGalvanizadoVw
		WHERE	(NomUbicacion = '' OR (NomUbicacion LIKE '%' + @psValor + '%'))	
END

