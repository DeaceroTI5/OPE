-- Revisión relacionada con el mensaje de error al capturar certificados (Error algenerar certificado)
-- 'OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_IU'
-- 
USE Operacion
GO
	SET NOCOUNT ON

	DECLARE   @pnClaUbicacion	INT = 362
			, @nId				INT
			, @sFacturaFilial	VARCHAR(20)
			, @sFacturaOrigen	VARCHAR(20)
			, @nIdFacturaFilial	INT
			, @nFacturaOrigen	INT

	DECLARE @tbUniverso TABLE(
		  Id				INT IDENTITY(1,1)
		, FacturaFilial		VARCHAR(20)
		, FacturaOrigen		VARCHAR(20)
	)

	INSERT INTO @tbUniverso (FacturaFilial, FacturaOrigen)
	VALUES   ('QP462','BQ47747')
			,('QP463','BQ47748')
			,('QP580','BQ48256')
			,('QP1399','PP24501')

	SELECT	@nId = MIN(Id)
	FROM	@tbUniverso

	SELECT ''AS'Ubicacion',* FROM OPESch.OpeTiCatUbicacionVw WHERE ClaUbicacion = @pnClaUbicacion

	WHILE @nId IS NOT NULL
	BEGIN
		SELECT	  @sFacturaFilial	= FacturaFilial
				, @sFacturaOrigen	= FacturaOrigen
				, @nIdFacturaFilial = NULL
				, @nFacturaOrigen	= NULL
		FROM	@tbUniverso
		WHERE	Id = @nId

		SELECT '' AS '-------'
		SELECT @sFacturaFilial AS '@sFacturaFilial', @sFacturaOrigen AS '@sFacturaOrigen'

		SELECT  ''AS'RelFacturaSuministroDirecto',*
		FROM	OpeSch.OpeRelFacturaSuministroDirecto WITH(NOLOCK)
		WHERE	NumFacturaFilial	= @sFacturaFilial
--		AND		ClaUbicacion		= @pnClaUbicacion
--		AND		IdFacturaFilial		= @nIdFacturaFilial
	
		SELECT	''AS'Factura',* 
		FROM	DEAOFINET04.Operacion.AceSch.VtaCTraFacturaVw WITH(NOLOCK)
		WHERE	IdFacturaAlfanumerico IN (@sFacturaFilial, @sFacturaOrigen)

		--- Se valida la factura filial con base a los movimientos (valor grabado)
		SELECT	@nIdFacturaFilial		= IdFactura
		FROM	OpeSch.OpeTraMovEntSal WITH(NOLOCK)
		WHERE	ClaUbicacion			= @pnClaUbicacion
		AND		IdFacturaAlfanumerico	= @sFacturaFilial

		SELECT	@nFacturaOrigen = IdFactura
		FROM	DEAOFINET04.Operacion.AceSch.VtaCTraFacturaVw WITH(NOLOCK)
		WHERE	IdFacturaAlfanumerico = @sFacturaOrigen

		SELECT 	''AS'Certificado filial',* 
		FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK)
		WHERE	IdFactura			= @nIdFacturaFilial
		ORDER BY FechaUltimaMod DESC	

		SELECT 	''AS'Certificado Origen',* 
		FROM	DEAOFINET04.Operacion.ACESch.AceTraCertificado WITH(NOLOCK)
		WHERE	IdFactura			= @nFacturaOrigen
		ORDER BY FechaUltimaMod DESC
	
		SELECT	@nId = MIN(Id)
		FROM	@tbUniverso
		WHERE	Id > @nId
	END

	SET NOCOUNT OFF
RETURN
	


		--/*Validaciones*/
		--EXEC OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_CambioValor_NumFacturaOrigen_Sel
		--	  @psNumFacturaOrigen	= @psNumFacturaOrigen

		--EXEC OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_CambioValor_NumFacturaFilial_Sel
		--	  @pnClaUbicacion		= @pnClaUbicacion	
		--	, @psNumFacturaFilial	= @psNumFacturaFilial

--IF @nClaTipoUbicacion IN (2)	-- Acerias DEAOFINET04.Operacion.AceSch.AceGeneraCertificadoSumDirectoSrv
-- else EXEC DEAOFINET04.Operacion.ACESch.AceGeneraCertificadoPuntoLogisticoSrv