USE Operacion
GO
ALTER PROCEDURE OPESch.OPEConsignadoTraspasoCmb
	  @pnClaUbicacion		INT
	, @pnClaUbicacionPide	INT
	, @pnClaUbicacionSurte	INT
	, @pnwtk0				INT = NULL
	, @psValor				VARCHAR(100)	-- Texto a Buscar  
	, @pnTipo				INT				-- 1=Buscar por la ClaveXxxxx  
	, @pnModoSel			INT = 1			-- 1=Retorno Clave - Descripcion   <>1  Descripcion  
	, @pnBajasSn			INT = 0
	, @pnDebug				TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #TmpConsignado
	(
		  ClaConsignado	INT
		, NomConsignado	VARCHAR(50)
		, BajaLogica	TINYINT
	)

	CREATE TABLE #TmpUbicaciones
	(
		  ClaUbicacion	INT	
		, BajaLogica	TINYINT 
	)
	
	DECLARE   @nClaEmpresa			INT
			, @nClaConfiguracion	INT

	--/* Asignacion de valores default */
	SELECT	  @nClaEmpresa			= 52	--INGETEK
			, @nClaConfiguracion	= 1271221


	INSERT INTO #TmpUbicaciones (ClaUbicacion, BajaLogica)
	SELECT	ClaUbicacion, BajaLogica 
	FROM	OpeSch.OpeConsultaUbicacionesEmpresaFn(@pnClaUbicacion, @nClaEmpresa, @nClaConfiguracion)

	IF @pnDebug = 1
		SELECT '' AS '#TmpUbicaciones', * FROM #TmpUbicaciones

	-- /* Valida si es Traspaso entre misma Empresa* */
	IF EXISTS (
		SELECT	1
		FROM	#TmpUbicaciones
		WHERE	ClaUbicacion = @pnClaUbicacionSurte
		AND		BajaLogica = 0
	) 
	BEGIN
		INSERT INTO #TmpConsignado (ClaConsignado, NomConsignado, BajaLogica)
		SELECT	DISTINCT 
				a.ClaConsignado, a.NombreConsignado, a.BajaLogica
		FROM	Opesch.OpeVtaRelClienteConsignadoVw a
		WHERE	ClaCliente = @pnwtk0
		AND		(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1) 
	END
	ELSE
	BEGIN
		-- /* Es traspaso filial (diferente empresa) */
		INSERT INTO #TmpConsignado (ClaConsignado, NomConsignado, BajaLogica)
		SELECT	DISTINCT 
				a.ClaConsignado, a.NombreConsignado, a.BajaLogica
		FROM	Opesch.OpeVtaRelClienteConsignadoVw a
		WHERE	ClaCliente = @pnwtk0
		AND		(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1) 
	END


	------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------
	IF (@psValor = '' OR @psValor IS NULL)  
	BEGIN
		SELECT  TOP 500  
				  ClaConsignado = ClaConsignado 
				, NomConsignado = CASE @pnModoSel WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(10), ClaConsignado))) + '-' + NomConsignado ELSE NomConsignado END  
		FROM	#TmpConsignado 
		ORDER BY CASE  WHEN @pnModoSel = 1 THEN   ClaConsignado END,
					CASE  WHEN  @pnModoSel = 2 THEN  NomConsignado END  
	END
	ELSE
	BEGIN
		IF @pnTipo  IN (1,99)   
			SELECT TOP 500  
					  ClaConsignado	= ClaConsignado  
					, NomConsignado = CASE @pnModoSel WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(10), ClaConsignado))) + '-' + NomConsignado ELSE NomConsignado END  
			FROM	#TmpConsignado
			WHERE	ClaConsignado = @psValor    
			ORDER BY CASE  WHEN @pnModoSel = 1 THEN   ClaConsignado END,
						CASE  WHEN  @pnModoSel = 2 THEN  NomConsignado END  
		ELSE  
		BEGIN  
			SELECT TOP 500  
					  ClaConsignado = ClaConsignado 
					, NomConsignado = CASE @pnModoSel WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(10), ClaConsignado))) + '-' + NomConsignado ELSE NomConsignado END  
			FROM	#TmpConsignado
			WHERE	NomConsignado LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'
			ORDER BY CASE  WHEN @pnModoSel = 1 THEN   ClaConsignado END,
						CASE  WHEN  @pnModoSel = 2 THEN  NomConsignado END  
		END  
	END
	------------------------------------------------------------------------------------
	
	DROP TABLE #TmpConsignado
	SET NOCOUNT OFF
END