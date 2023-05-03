DECLARE   @pnClaUbicacionOrigen	INT = 70
		, @pnIdFacturaOrigen	INT = 135011041
		, @pnClaUbicacion		INT = 324
		, @pnIdFactura			INT = 1034002675

	SELECT	*
	FROM	AceSch.AceTraCertificado (NOLOCK)
	WHERE	IdFactura = 1034002666


	DECLARE @tAcerias TABLE(
		  Orden		INT IDENTITY(1, 1)
		, ClaAceria INT
	)
	
	DECLARE @nClaAceria				INT,
			@nClaUbicacionOrigen	INT,
			@nIdFabricacion			INT

	INSERT INTO @tAcerias(ClaAceria)
	SELECT	DISTINCT ClaUbicacionOrigen
	FROM	AceSch.AceTraCertificado (NOLOCK)
	WHERE	ClaUbicacion = @pnClaUbicacionOrigen
	AND		IdFactura = @pnIdFacturaOrigen

	DECLARE @nCount INT = 1

	WHILE(@nCount <= (SELECT MAX(Orden) FROM @tAcerias))
	BEGIN
		SELECT TOP 1 @nClaAceria = ClaAceria
		FROM @tAcerias
		WHERE Orden = @nCount

		SELECT TOP 1
				@nIdFabricacion = IdFabricacion
		FROM	ACESch.VtaCTraFacturaVw (NOLOCK)
		WHERE	ClaUbicacion = @pnClaUbicacion
		ANd		IdFactura = @pnIdFactura

		SELECT
			@pnClaUbicacion ClaUbicacion,
			IdViaje,
			@nIdFabricacion IdFabricacion,
			@nClaUbicacionOrigen ClaUbicacionOrigen,
			ClaArticuloExt,
			NumViaje,
			@pnIdFactura IdFactura
		FROM AceSch.AceTraCertificado (NOLOCK)
		WHERE ClaUbicacion = @pnClaUbicacionOrigen
		AND IdFactura = @pnIdFacturaOrigen
		AND ClaUbicacionOrigen = @nClaUbicacionOrigen
		AND NOT EXISTS(
			SELECT 1
			FROM AceSch.AceTraCertificado (NOLOCK)
			WHERE ClaUbicacion = @pnClaUbicacion
			AND IdFactura = @pnIdFactura
			AND ClaUbicacionOrigen = @nClaUbicacionOrigen
		)
	--	AND @pnEsRegeneraCertificado = 0
		SET @nCount = @nCount + 1
	END