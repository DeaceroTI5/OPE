ALTER PROCEDURE OpcSch.OpcEtiquetaZebraRolloIDProc
	@pnNumVersion 		INT,
	@pnClaUbicacion		INT,
	@pnIdRolloEntradaZebra INT
AS 
BEGIN 
	--exec OpcSch.OpcEtiquetaZebraRolloIDProc 1, 61, 13

	SET  NOCOUNT  ON 
	DECLARE	@nNumrollo	   			INT,
			@nNumHoja	   			INT,
			@nContador				INT,
			@nCantidadCopias		INT,
			@nClaPesoLb				INT,
			@nEsImpresionExp		INT,
			@nEsImpresionCliente	INT,
			@nclaarticulo			INT,						
			@nClaIdioma				INT,			
			@pnClaEtiqueta			INT,
			@pnClaUsuario			INT,
			@nConceptoPeso			INT,
			@nConceptoCab			INT,
			@nPedido				INT						
			
	DECLARE  @tbImpresionZebraSalida AS TABLE (
			 Id 				INT IDENTITY(1,1)
			,IdRenglon 			INT 
			,RenglonDesc 		VARCHAR(800)
			,ClaUbicacion 		INT
			,ClaEtiqueta  		INT
			,ClaUsuario			INT 
			,IdRollo			INT
			,IdHoja				INT 
			,EsExportacion		INT 
			,EsImpresionCliente	INT ) 

	DECLARE  
	@sEtiArt				VARCHAR(50)
	,@sClaveArt				VARCHAR(50)
	,@sNomArt				VARCHAR(200)
	,@sEtiCantidad			VARCHAR(50)
	,@sValCantidad			VARCHAR(50)
	,@sEtiPesoN				VARCHAR(50)
	,@sPesoN				VARCHAR(50)
	,@sEtiPesoB				VARCHAR(50)
	,@sPesoB				VARCHAR(50)				
	,@sEtiRollo				VARCHAR(50)
	,@sClaveRollo			VARCHAR(50)
	,@sEtiCab				VARCHAR(50)		
	,@sValCab				VARCHAR(50)
	,@sEtiOpm				VARCHAR(50)
	,@sValOpm				VARCHAR(50)
	,@sAprobCalidadEsp		VARCHAR(50)
	,@sAprobCalidadIng		VARCHAR(50)
	,@sEtiIndustrial		VARCHAR(100)
	,@nUnidadBase			INT
	,@sNomUnidadVta			VARCHAR(50)
	,@nConceptoLong			INT
	,@nConceptoLongFT		INT
	,@nPesoTeorico			NUMERIC(22,4)
	,@nCantidad				NUMERIC(22,4)
	,@nCantidadFT			NUMERIC(22,4)
	,@sCantidad				VARCHAR(50)
	,@sCantidadFT			VARCHAR(50)
	,@nPesoNeto				NUMERIC(22,0)
	,@sDirUbicacion			VARCHAR(50)
   	,@sLeyenda				VARCHAR(50)
	,@sdesc_planta_seg1		VARCHAR(100)
	,@sdesc_planta_seg2		VARCHAR(100)
	,@sdesc_planta_seg3		VARCHAR(100)
	,@sdesc_planta_seg4		VARCHAR(100)
	,@sdesc_planta_Linea1	VARCHAR(200)
	,@sdesc_planta_Linea2	VARCHAR(200)
	,@nConceptoPesoBruto	INT
	,@sPesoBruto			VARCHAR(50)
	,@nPesoBruto			NUMERIC(22,0)
	,@dFechaCaptura			DATETIME
	,@sNombrePlantaEsp		VARCHAR(100)
	,@sNombrePlantaIng		VARCHAR(100)

   	  
 
	SELECT	@pnClaEtiqueta = ClaEtiqueta,
			@pnClaUsuario = ClaUsuario
	FROM	OpcSch.OpcTmpRolloEntradaZebraVw WITH(NOLOCK)
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		IdRolloEntradaZebra = @pnIdRolloEntradaZebra	
 
	SET @nNumHoja = 1
	
	SELECT	@nConceptoCab = nValor1
	FROM	OpcSch.OpcTiCatConfiguracionVw 
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		ClaSistema = 246
	AND		ClaConfiguracion = 	24620

	SELECT	@nConceptoPesoBruto = nValor1
	FROM	OpcSch.OpcTiCatConfiguracionVw 
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		ClaSistema = 246
	AND		ClaConfiguracion = 	24623	
			
	SELECT	@nConceptoLong = nValor1,
			@nConceptoLongFT = nValor2
	FROM	OpcSch.OpcTiCatConfiguracionVw 
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		ClaSistema = 246
	AND		ClaConfiguracion = 	24618
		
	SELECT	--@sEtiIndustrial = sValor1,
			@sLeyenda = sValor2
	FROM	OpcSch.OpcTiCatConfiguracionVw 
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		ClaSistema = 246
	AND		ClaConfiguracion = 	24622

	SELECT	  @sNombrePlantaEsp	= sValor1
			, @sNombrePlantaIng	= sValor2
	FROM	OpcSch.OpcTiCatConfiguracionVw 
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		ClaSistema = 246
	AND		ClaConfiguracion = 	246153

	
	SELECT	@sClaveRollo	= RTRIM(ClaveRollo),
			@nNumrollo	=  IdRollo  ,
			@nclaarticulo = claarticulo,
			@nEsImpresionCliente= EsImpresionCliente,
			@nEsImpresionExp = EsExportacion
	FROM	OpcSch.OpcTmpRolloEntradaZebraVw WITH(NOLOCK)
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		IdRolloEntradaZebra = @pnIdRolloEntradaZebra		
	
	SELECT	@sValOpm = isnull(CAST( rollo.IdOpm	 AS  VARCHAR(50)),'')
			,@dFechaCaptura = rollo.FechaRegistro
	FROM	OpcSch.OpcTraRolloVw rollo WITH(NOLOCK)     
	WHERE   rollo.ClaUbicacion = @pnClaUbicacion
	AND		rollo.IdRollo = @nNumrollo 
		
	select	@sClaveArt	= ClaveArticulo,
			@sNomArt = NomArticulo,
			@nUnidadBase = ClaUnidadBase,
			@nPesoTeorico = PesoTeoricoKgs
	from	OpcSch.OpcArtCatArticuloVw WITH(NOLOCK)
	where	ClaTipoInventario = 1
	AND		ClaArticulo = @nClaArticulo
	

	IF @nUnidadBase = 32 -- FT
	BEGIN
		SELECT
		@sEtiArt		= 'CODE'
		,@sEtiCantidad	= 'QUANTITY'
		,@sEtiPesoN		= 'NET WEIGHT'
		,@sEtiPesoB		= 'GROSS WEIGHT'
		,@sEtiRollo		= 'REEL #'
		,@sEtiCab		= 'W.O.'	--'CAB'
		,@sEtiOpm		= 'OPM'
		,@sAprobCalidadIng = 'APPROVED BY QUALITY DEPARTMENT'
		,@sAprobCalidadEsp = ''
		,@sEtiIndustrial = @sNombrePlantaIng
	END
	ELSE
	BEGIN
		SELECT
		@sEtiArt		= 'CLAVE'
		,@sEtiCantidad	= 'CANTIDAD'
		,@sEtiPesoN		= 'PESO NETO'
		,@sEtiPesoB		= 'PESO BRUTO'
		,@sEtiRollo		= 'ROLLO'
		,@sEtiCab		= 'CAB'
		,@sEtiOpm		= 'OPM'
		,@sAprobCalidadEsp = 'APROBADO POR CALIDAD'	
		,@sAprobCalidadIng = ''
		,@sEtiIndustrial = @sNombrePlantaEsp
	END
	
	/*Modificación solicitada por Abel Rdz. y Omar España 05/03/2021 */
	IF @pnClaUbicacion = 61 --AND @nClaArticulo IN (691113, 692066)
	BEGIN
		--SELECT	 @sEtiOpm		= 'FECHA'
		--		,@sValOpm		= CONVERT(VARCHAR(10),@dFechaCaptura,103)
		
		SELECT	 @sEtiOpm		= CASE WHEN @nUnidadBase = 32 THEN 'DATE' ELSE 'FECHA' END
				,@sValOpm		= CASE WHEN @nUnidadBase = 32 THEN CONVERT(VARCHAR(10),@dFechaCaptura,101) ELSE CONVERT(VARCHAR(10),@dFechaCaptura,103) END
	END

	--EXEC OpcSch.OpcSeparaDescripcionProc @sNomArt,  @sdesc_planta_seg1 output, @sdesc_planta_seg2 output,  @sdesc_planta_seg3 output,  @sdesc_planta_seg4 OUTPUT

	--IF LEN(@sdesc_planta_seg1 + @sdesc_planta_seg2) < 30
	--	SELECT	@sdesc_planta_linea1 = @sdesc_planta_seg1 + ' ' + @sdesc_planta_seg2,
	--			@sdesc_planta_linea2 = isnull(@sdesc_planta_seg3,'') + ' ' + isnull(@sdesc_planta_seg4,'') + ' ' 
				
	--ELSE
	--	SELECT	@sdesc_planta_linea1 = @sdesc_planta_seg1 ,
	--			@sdesc_planta_linea2 = @sdesc_planta_seg2 + ' ' + isnull(@sdesc_planta_seg3,'') + ' ' + isnull(@sdesc_planta_seg4,'') + ' ' 				
	
	IF LEN(LTRIM(RTRIM(@sNomArt))) < 47
	BEGIN
		SET @sdesc_planta_Linea1 = LTRIM(RTRIM(@sNomArt))
		SET @sdesc_planta_Linea2 = ''
	END
	ELSE
	BEGIN
		SET @sdesc_planta_Linea1 = SUBSTRING(@sNomArt,1,46)
		SET @sdesc_planta_Linea2 = LTRIM(RTRIM(SUBSTRING(@sNomArt,47,len(@sNomArt)-46)))
	END
	
	SELECT	@sNomUnidadVta = NomCortoUnidad
	FROM	OpcSch.OpcArtCatUnidadVw WITH(NOLOCK)
	WHERE	ClaUnidad = @nUnidadBase
	AND		ClaTipoInventario = 1

	SELECT	@sValCab = ltrim( rtrim(valor))
	FROM	OpcSch.OPCTraPruebaRollo prollo WITH(NOLOCK)
	INNER JOIN OpcSch.OPCTraRollo rollo WITH(NOLOCK) 
	ON		rollo.ClaUbicacion = prollo.ClaUbicacion
	AND		rollo.IdRollo = prollo.IdRollo
	INNER JOIN OpcSch.OPCCatConceptoLaboratorio concepto WITH(NOLOCK) 
	ON		concepto.ClaUbicacion = prollo.ClaUbicacion
	AND		concepto.ClaConceptoLaboratorio = prollo.ClaConceptoLaboratorio
	WHERE   prollo.ClaUbicacion = @pnClaUbicacion
	AND		prollo.IdRollo = @nNumrollo
	AND		concepto.ClaConceptoLaboratorio = @nConceptoCab
	AND		prollo.Valor IS NOT NULL	
	
	SELECT	@sCantidad = ltrim( rtrim(valor))
	FROM	OpcSch.OPCTraPruebaRollo prollo WITH(NOLOCK)
	INNER JOIN OpcSch.OPCTraRollo rollo WITH(NOLOCK) 
	ON		rollo.ClaUbicacion = prollo.ClaUbicacion
	AND		rollo.IdRollo = prollo.IdRollo
	INNER JOIN OpcSch.OPCCatConceptoLaboratorio concepto WITH(NOLOCK) 
	ON		concepto.ClaUbicacion = prollo.ClaUbicacion
	AND		concepto.ClaConceptoLaboratorio = prollo.ClaConceptoLaboratorio
	WHERE   prollo.ClaUbicacion = @pnClaUbicacion
	AND		prollo.IdRollo = @nNumrollo
	AND		concepto.ClaConceptoLaboratorio = @nConceptoLong
	AND		prollo.Valor IS NOT NULL	
	
	IF @nConceptoLongFT IS NOT NULL 
	BEGIN
		SELECT	@sCantidadFT = ltrim( rtrim(valor))
		FROM	OpcSch.OPCTraPruebaRollo prollo WITH(NOLOCK)
		INNER JOIN OpcSch.OPCTraRollo rollo WITH(NOLOCK) 
		ON		rollo.ClaUbicacion = prollo.ClaUbicacion
		AND		rollo.IdRollo = prollo.IdRollo
		INNER JOIN OpcSch.OPCCatConceptoLaboratorio concepto WITH(NOLOCK) 
		ON		concepto.ClaUbicacion = prollo.ClaUbicacion
		AND		concepto.ClaConceptoLaboratorio = prollo.ClaConceptoLaboratorio
		WHERE   prollo.ClaUbicacion = @pnClaUbicacion
		AND		prollo.IdRollo = @nNumrollo
		AND		concepto.ClaConceptoLaboratorio = @nConceptoLongFT
		AND		prollo.Valor IS NOT NULL	
	END
	
	SELECT	@sPesoBruto = ltrim( rtrim(valor))
	FROM	OpcSch.OPCTraPruebaRollo prollo WITH(NOLOCK)
	INNER JOIN OpcSch.OPCTraRollo rollo WITH(NOLOCK) 
	ON		rollo.ClaUbicacion = prollo.ClaUbicacion
	AND		rollo.IdRollo = prollo.IdRollo
	INNER JOIN OpcSch.OPCCatConceptoLaboratorio concepto WITH(NOLOCK) 
	ON		concepto.ClaUbicacion = prollo.ClaUbicacion
	AND		concepto.ClaConceptoLaboratorio = prollo.ClaConceptoLaboratorio
	WHERE   prollo.ClaUbicacion = @pnClaUbicacion
	AND		prollo.IdRollo = @nNumrollo
	AND		concepto.ClaConceptoLaboratorio = @nConceptoPesoBruto
	AND		prollo.Valor is not null	 	

	SELECT	@sDirUbicacion = Direccion
	FROM	OpcSch.OpcTiCatUbicacionVw WITH(NOLOCK)
	WHERE	ClaUbicacion = @pnClaUbicacion

	SET @nCantidad = CONVERT(NUMERIC(22,4),@sCantidad)	
	SET @nCantidadFT = CONVERT(NUMERIC(22,4),@sCantidadFT)
	
	IF @nUnidadBase = 32 -- FT
	BEGIN
		--IF ISNULL(@nCantidadFT,0) <> 0
		--BEGIN
		--	SET @nPesoNeto = @nCantidadFT * @nPesoTeorico * 2.20462
		--	SET @nPesoBruto = CONVERT(NUMERIC(22,4),@sPesoBruto) * 2.20462
		--	SET @sPesoN = REPLACE(CONVERT(VARCHAR(50),CAST(ROUND(@nPesoNeto,0) AS MONEY),1),'.00','') + ' Lb'
		--	SET @sPesoB = REPLACE(CONVERT(VARCHAR(50),CAST(ROUND(@nPesoBruto,0) AS MONEY),1),'.00','') + ' Lb'
		--END
		--ELSE
		--BEGIN
			SET @nPesoNeto = @nCantidad * @nPesoTeorico * 2.20462
			SET @nPesoBruto = CONVERT(NUMERIC(22,4),@sPesoBruto) * 2.20462
			SET @sPesoN = REPLACE(CONVERT(VARCHAR(50),CAST(ROUND(@nPesoNeto,0) AS MONEY),1),'.00','') + ' Lb'
			SET @sPesoB = REPLACE(CONVERT(VARCHAR(50),CAST(ROUND(@nPesoBruto,0) AS MONEY),1),'.00','') + ' Lb'
		--END
	END
	ELSE
	BEGIN
		SET @nPesoNeto = @nCantidad * @nPesoTeorico
		SET @nPesoBruto = CONVERT(NUMERIC(22,4),@sPesoBruto)	
		SET @sPesoN = REPLACE(CONVERT(VARCHAR(50),CAST(@nPesoNeto AS MONEY),1),'.00','') + ' Kg'
		SET @sPesoB = REPLACE(CONVERT(VARCHAR(50),CAST(@nPesoBruto AS MONEY),1),'.00','') + 'Kg'
	END
	
	--IF @nUnidadBase = 32 AND ISNULL(@nCantidadFT,0) <> 0
	--	SELECT @sValCantidad = REPLACE(CONVERT(VARCHAR(50),CAST(ROUND(@nCantidadFT,0) AS MONEY),1),'.00','') + ' ' + @sNomUnidadVta
	--ELSE
	IF @nUnidadBase <> 49
	BEGIN
		SELECT @sValCantidad = REPLACE(CONVERT(VARCHAR(50),CAST(ROUND(@nCantidad,0) AS MONEY),1),'.00','') + ' ' + @sNomUnidadVta
	END
	ELSE
	BEGIN
		SELECT @sValCantidad = CONVERT(VARCHAR(50),CAST(ROUND(@nCantidad,1) AS MONEY),1)
		SELECT @sValCantidad = LEFT(@sValCantidad, LEN(@sValCantidad) -1) + ' ' + @sNomUnidadVta
	END

	SELECT	@nContador = 0
	SELECT	@nCantidadCopias = 2
	
			  
	--Hacer un ciclo por la cantidad de copias configuradas
	WHILE @nContador < @nCantidadCopias
	BEGIN	
  		INSERT INTO @tbImpresionZebraSalida
		SELECT 
			IdRenglon
			,CASE 
			WHEN  IdRenglon = 10 AND CHARINDEX('@@EtiArt',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@EtiArt', ISNULL(@sEtiArt, ''))
			WHEN  IdRenglon = 11 AND CHARINDEX('@@ClaveArt',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@ClaveArt', ISNULL(@sClaveArt, ''))
			WHEN  IdRenglon = 13 AND CHARINDEX('@@Nom1Art',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@Nom1Art', ISNULL(@sdesc_planta_Linea1, ''))
			WHEN  IdRenglon = 33 AND CHARINDEX('@@Nom2Art',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@Nom2Art', ISNULL(@sdesc_planta_Linea2, ''))
			WHEN  IdRenglon = 15 AND CHARINDEX('@@EtiCantidad',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@EtiCantidad', ISNULL(@sEtiCantidad, ''))
			WHEN  IdRenglon = 16 AND CHARINDEX('@@ValCantidad',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@ValCantidad', ISNULL(@sValCantidad, ''))
			WHEN  IdRenglon = 17 AND CHARINDEX('@@EtiPesoN',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@EtiPesoN', ISNULL(@sEtiPesoN, ''))
			WHEN  IdRenglon = 18 AND CHARINDEX('@@PesoN',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@PesoN', ISNULL(@sPesoN, ''))
			WHEN  IdRenglon = 19 AND CHARINDEX('@@EtiPesoB',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@EtiPesoB', ISNULL(@sEtiPesoB, ''))
			WHEN  IdRenglon = 20 AND CHARINDEX('@@PesoB',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@PesoB', ISNULL(@sPesoB, ''))
			WHEN  IdRenglon = 21 AND CHARINDEX('@@EtiRollo',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@EtiRollo', ISNULL(@sEtiRollo, ''))
			WHEN  IdRenglon = 22 AND CHARINDEX('@@ClaveRollo',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@ClaveRollo', ISNULL(@sClaveRollo, ''))
			WHEN  IdRenglon = 23 AND CHARINDEX('@@EtiCab',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@EtiCab', ISNULL(@sEtiCab, ''))
			WHEN  IdRenglon = 24 AND CHARINDEX('@@ValCab',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@ValCab', ISNULL(@sValCab, ''))
			--WHEN  IdRenglon = 25 AND CHARINDEX('@@EtiOpm',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@EtiOpm', ISNULL(@sEtiOpm, ''))
			--WHEN  IdRenglon = 26 AND CHARINDEX('@@ValOpm',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@ValOpm', ISNULL(@sValOpm, ''))
			WHEN  IdRenglon = 25 AND CHARINDEX('@@EtiOpm',RenglonDesc) > 0 THEN replace(CASE WHEN @pnClaUbicacion = 61 THEN '^FT550,665^A0N,30,33^FD@@EtiOpm^FS' ELSE RenglonDesc END, '@@EtiOpm', ISNULL(@sEtiOpm, ''))
			WHEN  IdRenglon = 26 AND CHARINDEX('@@ValOpm',RenglonDesc) > 0 THEN replace(CASE WHEN @pnClaUbicacion = 61 THEN '^FT645,665^A0N,30,33^FD@@ValOpm^FS' ELSE RenglonDesc END, '@@ValOpm', ISNULL(@sValOpm, ''))
			WHEN  IdRenglon = 29 AND CHARINDEX('@@CodBarClave',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@CodBarClave', ISNULL(@sClaveRollo, ''))
			WHEN  IdRenglon = 30 AND CHARINDEX('@@EtiIndustrial',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@EtiIndustrial', ISNULL(@sEtiIndustrial, ''))
			WHEN  IdRenglon = 31 AND CHARINDEX('@@DirIndustrial',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@DirIndustrial', ISNULL(@sDirUbicacion, ''))
			WHEN  IdRenglon = 32 AND CHARINDEX('@@Eti2Industrial',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@Eti2Industrial', ISNULL(@sLeyenda, ''))
			WHEN  IdRenglon = 34 AND CHARINDEX('@@Eti3IndustrialEsp',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@Eti3IndustrialEsp', ISNULL(@sAprobCalidadEsp, ''))
			WHEN  IdRenglon = 35 AND CHARINDEX('@@Eti3IndustrialIng',RenglonDesc) > 0 THEN replace(RenglonDesc, '@@Eti3IndustrialIng', ISNULL(@sAprobCalidadIng, ''))
			ELSE  RenglonDesc  END 
			, ClaUbicacion
			, ClaEtiqueta 
			, @pnClaUsuario
			, @nNumrollo
			, @nNumHoja
			, @nEsImpresionExp  
			, @nEsImpresionCliente  
		FROM OpcSch.OpcCfgFormatoEtiquetaVw WITH (NOLOCK)
		WHERE ClaUbicacion =  @pnClaUbicacion
		AND   ClaEtiqueta  =  @pnClaEtiqueta

		--Continua con la siguiente Copia
		SELECT  @nNumHoja = @nNumHoja + 1	
		SELECT  @nContador = @nContador + 1
	END	--FIN DE CICLO DE LAS COPIAS  
			  
	
	--Registra en la tabla PloTmpRolloSalidaZebra
    INSERT INTO OpcSch.OPCTmpRolloSalidaZebraVw
    SELECT  ClaUbicacion
			,ClaUsuario 	    
			,ClaEtiqueta  	    
			,IdRollo			 
			,IdHoja	 
			,IdRenglon 
			,RenglonDesc 		    
			,EsExportacion		 
			,EsImpresionCliente	 
			,0
			,getdate()
			,@pnClaUsuario
			,getdate()  
			,''
	FROM	@tbImpresionZebraSalida
	
	SELECT * FROM @tbImpresionZebraSalida
	
	SET NOCOUNT OFF

END