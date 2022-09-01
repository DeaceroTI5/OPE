USE Operacion
GO
ALTER PROCEDURE OPESch.OPEClienteTraspasoCmb
	  @pnClaUbicacion		INT
	, @pnClaUbicacionPide	INT
	, @pnClaUbicacionSurte	INT
	, @pnEsTraspasoEmpresa	INT
	, @psValor				VARCHAR(100)	-- Texto a Buscar  
	, @pnTipo				INT				-- 1=Buscar por la ClaveXxxxx  
	, @pnModoSel			INT = 1			-- 1=Retorno Clave - Descripcion   <>1  Descripcion  
	, @pnBajasSn			INT = 0  
AS
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #TmpCliente
	(
		  ClaCliente	INT
		, NomCliente	VARCHAR(60)
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

	-- /* Valida si es Traspaso entre misma Empresa* */
	IF EXISTS (
		SELECT	1
		FROM	#TmpUbicaciones
		WHERE	ClaUbicacion = @pnClaUbicacionSurte
		AND		BajaLogica = 0
	) 
	BEGIN
		INSERT INTO #TmpCliente (ClaCliente, NomCliente, BajaLogica)
		SELECT	a.ClaCliente, b.NomCliente, b.BajaLogica
		FROM	OpeSch.OpeTiCatUbicacionVw a
		INNER JOIN OpeSch.OPEVtaCatClienteVw b
		ON		a.ClaCliente	= b.ClaCliente
		WHERE	ClaUbicacion	= @pnClaUbicacionPide
	END
	ELSE
	BEGIN
		-- /* Es traspaso filial (diferente empresa) */
		INSERT INTO #TmpCliente (ClaCliente, NomCliente, BajaLogica)
		SELECT	DISTINCT 
				ClaClienteFilial, b.NomCliente, b.BajaLogica
		FROM	OpeSch.OpeVtaCatClienteFilialVw a
		INNER JOIN OpeSch.OPEVtaCatClienteVw b
		ON		a.ClaClienteFilial	= b.ClaCliente
		WHERE	ClaUbicacionOrigen	= @pnClaUbicacionSurte 
		AND		ClaUbicacionDestino = @pnClaUbicacionPide
	END

	------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------
	IF (@psValor = '' OR @psValor IS NULL)  
	BEGIN
		SELECT  TOP 500  
				  ClaClienteTraspaso = ClaCliente 
				, NomClienteTraspaso =  CASE @pnModoSel WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(10), ClaCliente))) + '-' + NomCliente ELSE NomCliente END  
		FROM	#TmpCliente
		WHERE	(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1)  
		ORDER BY CASE  WHEN @pnModoSel = 1 THEN   ClaCliente END,
					CASE  WHEN  @pnModoSel = 2 THEN  NomCliente END  
	END
	ELSE
	BEGIN
		IF @pnTipo  IN (1,99)   
			SELECT TOP 500  
					  ClaClienteTraspaso= ClaCliente  
					, NomClienteTraspaso =  CASE @pnModoSel WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(10), ClaCliente))) + '-' + NomCliente ELSE NomCliente END  
			FROM	#TmpCliente
			WHERE	(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1)  
			AND		ClaCliente = @psValor    
			ORDER BY CASE  WHEN @pnModoSel = 1 THEN   ClaCliente END,
						CASE  WHEN  @pnModoSel = 2 THEN  NomCliente END  
		ELSE  
		BEGIN  
			SELECT TOP 500  
					  ClaClienteTraspaso = ClaCliente 
					, NomClienteTraspaso =  CASE @pnModoSel WHEN 1 THEN LTRIM(RTRIM(CONVERT(VARCHAR(10), ClaCliente))) + '-' + NomCliente ELSE NomCliente END  
			FROM	#TmpCliente
			WHERE	(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1)  
			AND		NomCliente LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'
			ORDER BY CASE  WHEN @pnModoSel = 1 THEN   ClaCliente END,
						CASE  WHEN  @pnModoSel = 2 THEN  NomCliente END  
		END  
	END
	------------------------------------------------------------------------------------
	
	DROP TABLE #TmpCliente
	SET NOCOUNT OFF
END