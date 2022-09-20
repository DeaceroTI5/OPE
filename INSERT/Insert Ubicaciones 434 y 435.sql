USE Operacion
GO

BEGIN TRAN	

	DECLARE @tUbicacionesCopia TABLE(
		  Id				INT IDENTITY(1,1)
		, ClaUbicacionCopia INT
	)

	DECLARE @nClaUbicacionCopia INT
	------------------------------------------------------------------------------------
	---- Ubicaciones a Insertar
	INSERT INTO @tUbicacionesCopia (ClaUbicacionCopia)
	SELECT 434
	UNION
	SELECT 435

	SELECT	@nClaUbicacionCopia = MIN(ClaUbicacionCopia)
	FROM	@tUbicacionesCopia
	------------------------------------------------------------------------------------
	WHILE @nClaUbicacionCopia IS NOT NULL
	BEGIN
		--- 'OpeSch.OpeCfgMaquilaParametroNeg'
		INSERT INTO OpeSch.OpeCfgMaquilaParametroNeg (
			  ClaUbicacion			, ClaParametro		, NomParametro		, FechaValor1
			, FechaValor2			, NumValor1			, NumValor2			, NumValor3
			, TextoValor1			, TextoValor2		, BajaLogica		, FechaBajaLogica
			, FechaUltimaMod		, NombrePcMod		, ClaUsuarioMod
		)
		SELECT	  ClaUbicacion		= @nClaUbicacionCopia
				, ClaParametro
				, NomParametro
				, FechaValor1
				, FechaValor2
				, NumValor1
				, NumValor2
				, NumValor3
				, TextoValor1
				, TextoValor2
				, BajaLogica
				, FechaBajaLogica
				, FechaUltimaMod	= GETDATE()
				, NombrePcMod		= 'CargaInicial'
				, ClaUsuarioMod		= 1
		FROM	OpeSch.OpeCfgMaquilaParametroNeg 
		WHERE	ClaUbicacion = 437 
		AND		BajaLogica = 0


		---- 'OpeSch.OpeTiCatConfiguracionVw'
		INSERT INTO OpeSch.OpeTiCatConfiguracionVw(
			  ClaUbicacion		, ClaSistema		, ClaConfiguracion	, NomConfiguracion
			, sValor1			, sValor2			, nValor1			, nValor2
			, dValor1			, dValor2			, BajaLogica		, FechaBajaLogica
			, FechaUltimaMod	, NombrePcMod
			, ClaUsuarioMod
		)
		SELECT	  ClaUbicacion		= @nClaUbicacionCopia
				, ClaSistema
				, ClaConfiguracion
				, NomConfiguracion
				, sValor1
				, sValor2
				, nValor1
				, nValor2
				, dValor1
				, dValor2
				, BajaLogica
				, FechaBajaLogica
				, FechaUltimaMod	= GETDATE()
				, NombrePcMod		= 'CargaInicial'
				, ClaUsuarioMod		= 1
		FROM	OpeSch.OpeTiCatConfiguracionVw 
		WHERE	ClaUbicacion = 437
		AND		Clasistema = 39 
		AND		BajaLogica = 0


		SELECT	@nClaUbicacionCopia = MIN(ClaUbicacionCopia)
		FROM	@tUbicacionesCopia
		WHERE	ClaUbicacionCopia > @nClaUbicacionCopia 
	END

	SELECT * FROM opesch.opecfgmaquilaparametroneg	WHERE ClaUbicacion in (434, 435)
	SELECT * FROM opesch.opeticatconfiguracionvw	WHERE ClaUbicacion in (434, 435) AND Clasistema = 39 

COMMIT TRAN


	--SELECT * FROM opesch.opecfgmaquilaparametroneg	WHERE ClaUbicacion in (434, 435)
	--SELECT * FROM opesch.opeticatconfiguracionvw	WHERE ClaUbicacion in (434, 435) AND Clasistema = 39 