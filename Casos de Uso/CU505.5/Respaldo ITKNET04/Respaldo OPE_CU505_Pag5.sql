EXEC SP_HELPTEXT 'OPESch.OPE_CU505_Pag5_Grid_EstFacturacion_Sel'
EXEC SP_HELPTEXT 'OPESch.OPE_CU505_Pag5_Boton_CargarConfiguraciones_Proc'


Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--*==============================================================
--*Objeto:		'OPESch.OPE_CU505_Pag5_Grid_EstFacturacion_Sel'
--*Autor:		Luis F Verastegui
--*Fecha:		10/12/2015
--*Objetivo:	
--*Entrada:
--*Salida:
--*Precondiciones:
--*Revisiones: 
--*==============================================================

CREATE PROCEDURE [OPESch].[OPE_CU505_Pag5_Grid_EstFacturacion_Sel]
	 @pnNumVersion			INT
	,@pnClaUbicacion		INT
	,@pdFechaInicial		DATETIME
	,@pdFechaFinal			DATETIME
	,@pnClaFamilia			INT
	,@pnClaArticulo			INT
	,@pnClaAgrupador		INT
	,@pnClaCliente			INT
	,@pnClaGpoCosteo		INT
	,@pnClaArtAlambron		INT
	,@pnClaTipoMercado		INT
	,@psClaMarca			VARCHAR(max)
AS
BEGIN

	/*
	exec OPESch.OPE_CU505_Pag5_Grid_EstFacturacion_Sel @pnNumVersion=1,@pnClaUbicacion=325,@pdFechaInicial='2022-08-10 00:00:00',
	@pdFechaFinal='2022-08-10 00:00:00',@pnClaFamilia=NULL,@pnClaArticulo=NULL,@pnClaAgrupador=NULL,@pnClaCliente=NULL,@pnClaGpoCosteo=NULL,
	@pnClaArtAlambron=NULL,@pnClaTipoMercado=NULL,@psClaMarca=''
	*/

	SET NOCOUNT ON
	--* Declaracion de variables locales
	DECLARE	 @nClaTipoInventario		INT
			,@nClaSistemaPLO			INT	
			,@nClaEstatusCerrado		INT
			,@nClaEstatusCerradoVtas	INT
			,@sNomIsoIdiomaIngles		VARCHAR(2)
			,@sNomIsoIdiomaOtro			VARCHAR(2)
			,@sCadenaOPM				VARCHAR(100)
			,@nClaTMATraspaso			INT
			,@nIndice					INT 
			,@nIdPlanCarga				INT 
			,@nTotal					INT 
			,@nIdFabricacion			INT 
			,@nIdFabricacionDet			INT 
			,@psNomIsoIdioma		VARCHAR(2)
			
	select @pnClaFamilia = isNull(@pnClaFamilia, -1)
	select @pnClaArticulo = isNull(@pnClaArticulo , -1)
	select @pnClaAgrupador = isNull(@pnClaAgrupador, -1)
	select @pnClaCliente = isNull(@pnClaCliente, -1)
	select @pnClaGpoCosteo = isNull(@pnClaGpoCosteo, -1)
	select @pnClaArtAlambron = isNull(@pnClaArtAlambron, -1)
	select @pnClaTipoMercado = isNull(@pnClaTipoMercado, -1)
	Select @psNomIsoIdioma='es'			
	
	SELECT	 @nIndice					 = 1
			,@nIdPlanCarga				 = 0
			,@nTotal					 = 0
			,@nIdFabricacion			 = 0
			,@nIdFabricacionDet			 = 0

	SET	@nClaSistemaPLO			= 127 
	SET @nClaEstatusCerrado		= 3
	SET @nClaEstatusCerradoVtas = 4
	SET @nClaTMATraspaso		= 200

	-- Tabla temporal de filro de marcas
	IF object_id('tempdb..#marca_filtro') IS NOT NULL
		DROP TABLE #marca_filtro
		
   CREATE TABLE #marca_filtro (ClaMarca INT)

   INSERT   #marca_filtro (ClaMarca)
            SELECT   VALUE
            FROM     OpeSch.OpeSplitFn(@psClaMarca, ',')

	--* Obtener tipo inventario configurado
	SELECT	@nClaTipoInventario = nValor1 
	FROM	OpeSch.OpeTiCatConfiguracionVw (NOLOCK)
	WHERE	ClaUbicacion = @pnClaUbicacion 
	AND		ClaSistema = @nClaSistemaPLO 
	AND		ClaConfiguracion = 11

	--* Obtener nombre idioma ingles configurado
	SELECT	@sNomIsoIdiomaIngles = LTRIM(RTRIM(sValor1))    
	FROM	OpeSch.OpeTiCatConfiguracionVw (NOLOCK)    
	WHERE	ClaSistema		= @nClaSistemaPLO 
	AND		ClaConfiguracion= 4  

	--* Obtener nombre idioma otro configurado    
	SELECT	@sNomIsoIdiomaOtro = LTRIM(RTRIM(sValor1))    
	FROM	OpeSch.OpeTiCatConfiguracionVw (NOLOCK)   
	WHERE	ClaSistema		= @nClaSistemaPLO 
	AND		ClaConfiguracion= 5

	--* Obtener Opm para los peoductos facturados
	IF object_id('tempdb..#tOpm') IS NOT NULL
		DROP TABLE #tOpm	
	CREATE TABLE #tOpm (	 ClaUbicacion		INT
							,IdPlanCarga		INT
							,IdFabricacion		INT
							,IdFabricacionDet	INT
							,IdOpm				VARCHAR(1255)				
						)
	
	-- Si es una planta industrial, se debe de considerar las OPM del plan de carga					
	IF(EXISTS(SELECT ClaUbicacion FROM OpeSch.OpeTiCatUbicacionVw Where ClaTipoUbicacion = 6 and ClaUbicacion = @pnClaUbicacion ))
	BEGIN 				
		INSERT INTO #tOpm
		SELECT ClaUbicacion, IdPlanCarga, IdFabricacion, IdFabricacionDet, SUBSTRING (CamposConcatenados, 0, LEN(CamposConcatenados) - 1)
		FROM OpcSch.OpcTraPlanCargaOpmDet As t1
		CROSS APPLY
		(
			SELECT Convert(VARCHAR,IdOPM) + ' , '
			FROM OpcSch.OpcTraPlanCargaOpmDet As t2
			WHERE t1.IdPlanCarga = t2.IdPlanCarga
				and ClaveRollo = '0'
				and t1.IdFabricacion = t2.IdFabricacion
				and t1.IdFabricacionDet = t2.IdFabricacionDet
				and t2.IdOPM IS NOT NULL
				and	(	CONVERT(DATETIME, CONVERT(VARCHAR, t2.FechaUltimaMod, 103),103) BETWEEN 
						CONVERT(DATETIME, CONVERT(VARCHAR, @pdFechaInicial, 103),103) AND CONVERT(DATETIME, CONVERT(VARCHAR, @pdFechaFinal, 103),103) 	)			
			GROUP BY IdOPM		
			FOR XML PATH('')
		) pre_trimmed (CamposConcatenados)
		WHERE	ClaUbicacion = @pnClaUbicacion
		AND		CamposConcatenados IS NOT NUll
		GROUP BY ClaUbicacion, IdPlanCarga, IdFabricacion, IdFabricacionDet, CamposConcatenados
	END

	-- ShipID
	SELECT b.ClaUbicacion, b.IdViaje, ShipId = STUFF( (	SELECT	', ' + ShipId
													FROM	OpeSch.OpeRelViajeShipID a
													WHERE	a.IdViaje = b.IdViaje
													FOR XML PATH('')), 1, 2, '') 
	INTO	#tViajeShipId
	FROM	OpeSch.OpeRelViajeShipID b WITH(NOLOCK)
	WHERE	b.ClaUbicacion = @pnClaUbicacion
	GROUP BY b.ClaUbicacion, b.IdViaje

	IF OBJECT_ID('tempdb..#tPedidos') IS NOT NULL
		DROP TABLE #tPedidos	
	CREATE TABLE #tPedidos (
								 IdViaje		INT
								,IdMovEntSal	INT
								,FechaViaje		DATETIME
								,ClaArticulo	INT
								,ClaveArticulo	VARCHAR(50)
								,NomArticulo	VARCHAR(255)
								,ClaPedido		INT
								,ClaCliente		INT
								,NombreCliente	VARCHAR(255)
								,FechaPromesaOrigen DATETIME
								,KilosSurtidos	NUMERIC(22,4)
								,UnidadesSurtidas NUMERIC(22,4)
								,IdPlanCarga	varchar(10)
								,IdFactura		VARCHAR(255)
								,IdOpm			VARCHAR(1255)
								,ClaTipoMercado	INT
								,NomTipoMercado	VARCHAR(255)
								,NomTransportista VARCHAR(200)
								,ImporteFlete	NUMERIC(22,4)
								,IdNumTabular	INT
								,PesoTeoricoKgs NUMERIC(22,4)
								,ClaConsignado	INT
								,NombreConsignado VARCHAR(100)
								,ClaMoneda		INT
								,NombreCortoMoneda	VARCHAR(20)
								,ShipID			VARCHAR(250)
							)

	INSERT INTO #tPedidos
	SELECT		 t1.IdViaje
				,t2.IdMovEntSal
				,t1.FechaViaje--t1.FechaEntSal
				,t3.ClaArticulo
				,t9.ClaveArticulo
				,CASE	WHEN @psNomIsoIdioma = @sNomIsoIdiomaIngles	THEN t9.NomArticuloIngles
						WHEN @psNomIsoIdioma = @sNomIsoIdiomaOtro	THEN t9.NomArticuloOtroIdioma
						ELSE t9.NomArticulo 
				 END
				,t5.IdFabricacion
				,t5.ClaCliente
				,t7.NombreCliente
				,t5.FechaPromesaActual
				,t3.PesoEmbarcado
				,t3.CantEmbarcada
				,isnull(convert(varchar(10),t1.IdPlanCarga),'OE-'+convert(varchar(10),oe.idOrdenenvio))
				,CASE WHEN ISNULL(t2.IdFacturaAlfanumerico,'') <> '' 
					THEN t2.IdFacturaAlfanumerico 
					ELSE CAST(t2.IdEntSal AS VARCHAR) END AS IdFacturaAlfanumerico
				,t6.IdOpm
				,t5.ClaTipoMercadoPta
				,t8.NomTipoMercado
				,t11.NomTransportista AS NomTransportista 
				,E.ImporteSinIVA   As ImporteFlete
				,t1.IdNumTabular
				,t9.PesoTeoricoKgs
				,t5.ClaConsignado
				,t13.NombreConsignado
				,t14.ClaMoneda
				,t15.NombreCortoMoneda
				,t16.ShipId
	FROM		OpeSch.OpeTraViaje				t1 (NOLOCK)
	LEFT JOIN 	OpeSch.OpeTraMovEntSal			t2 (NOLOCK)	ON	t1.ClaUbicacion		= t2.ClaUbicacion
													AND	t1.IdVIaje			= t2.IdViaje 
													AND t1.IdBoleta			= t2.IdBoleta 
	LEFT JOIN	OpeSch.OpeTraMovEntSalDet		t3 (NOLOCK) ON	t2.ClaUbicacion		= t3.ClaUbicacion
													AND t2.IdMovEntSal		= t3.IdMovEntSal
	LEFT JOIN	OpeSch.OpeTraFabricacionVw		t5 (NOLOCK)	ON	t1.ClaUbicacion		= t5.ClaPlanta
													AND t2.IdFabricacion	= t5.IdFabricacion
	LEFT JOIN	#tOpm					t6 (NOLOCK)	ON	t3.ClaUbicacion		= t6.ClaUbicacion
													AND	t3.IdFabricacion	= t6.IdFabricacion
													AND t1.IdPlanCarga		= t6.IdPlanCarga
													AND t3.IdFabricacionDet	= t6.IdFabricacionDet 	
	LEFT JOIN	OpeSch.OpeVtaCatClienteVw			t7 (NOLOCK) ON	t5.ClaCliente		= t7.ClaCliente
	LEFT JOIN	OpeSch.OpeCatTipoMercadoEmbVw	t8 (NOLOCK)	ON	t5.ClaTipoMercadoPta= t8.ClaTipoMercado
	LEFT JOIN	OpeSch.OpeArtCatArticuloVw		t9 (NOLOCK)	ON	t9.ClaTipoInventario= @nClaTipoInventario
													AND t3.ClaArticulo	= t9.ClaArticulo
	LEFT JOIN	OpeSch.OpeFleCatTransportistaVw	t11 (NOLOCK)ON t1.ClaUbicacion		= t11.ClaUbicacion
													AND t1.ClaTransportista = t11.ClaTransportista
	INNER JOIN	#marca_filtro t10 /*WITH(NOLOCK)*/ 
													ON ISNULL(t9.ClaMarca, -1) = (CASE WHEN @psClaMarca = '' THEN ISNULL(t9.ClaMarca, -1)
                                                      ELSE t10.ClaMarca END)
	LEFT JOIN	OpcSch.OpcRelArticuloDatosPlanta t12 (NOLOCK) ON t12.ClaArticulo = t3.ClaArticulo
													AND t12.ClaUbicacion	= t3.ClaUbicacion
	LEFT JOIN	OpeSch.OpeFleTratabularDetVw E WITH(NOLOCK) ON 
												 t1.IdNumTabular = E.IdTabular AND
												 t1.ClaUbicacion = E.ClaUbicacion AND
												 t3.IdFabricacion = E.ClaPedido AND
												 t3.IdFabricacionDet = E.ClaRenglonPedido
	LEFT JOIN	OpeSch.OpeTraOrdenEnvio OE WITH(NOLOCK) ON 
												oe.IdViaje = t1.IdViaje and
												oe.ClaUbicacion = t1.ClaUbicacion
	LEFT JOIN	OpeSch.OpeVtaCatConsignadoVw t13 WITH(NOLOCK) ON
												t5.ClaConsignado = t13.ClaConsignado
	LEFT JOIN	FleSch.FleTratabularVw t14 WITH(NOLOCK) ON
												t1.ClaUbicacion = t14.ClaUbicacion AND
												t1.IdNumTabular = t14.IdTabular
	LEFT JOIN	OpeSch.OpeTesCatMonedaVw t15 WITH(NOLOCK) ON
												t14.ClaMoneda = t15.ClaMoneda												
	LEFT JOIN	#tViajeShipId t16 ON
												t16.ClaUbicacion = t1.ClaUbicacion AND
												t16.IdViaje = t1.IdViaje								
													
	WHERE	t1.ClaUbicacion = @pnClaUbicacion
	AND		t1.ClaEstatus IN (@nClaEstatusCerrado,@nClaEstatusCerradoVtas)
	AND		(
				CONVERT(DATETIME, CONVERT(VARCHAR, t1.FechaViaje, 103),103) BETWEEN 
				CONVERT(DATETIME, CONVERT(VARCHAR, @pdFechaInicial, 103),103) AND CONVERT(DATETIME, CONVERT(VARCHAR, @pdFechaFinal, 103),103)
			)
	AND		(t9.ClaFamilia			= @pnClaFamilia		OR @pnClaFamilia	= -1)
	AND		(t3.ClaArticulo			= @pnClaArticulo	OR @pnClaArticulo	= -1)
	AND		(ISNULL(t12.ClaGrupoTipoArticulo,4) = @pnClaAgrupador	OR @pnClaAgrupador	= -1)
	AND		(t5.ClaCliente			= @pnClaCliente		OR @pnClaCliente	= -1)
	AND		(t9.ClaGpoCosteo		= @pnClaGpoCosteo	OR @pnClaGpoCosteo	= -1)
	AND		(t12.ClaArticulo		= @pnClaArtAlambron	OR @pnClaArtAlambron= -1)
	AND		(t5.ClaTipoMercadoPta	= @pnClaTipoMercado OR @pnClaTipoMercado= -1)
	AND		
			(
				(t2.IdEntSal IS NOT NULL AND t3.ClaTMA = @nClaTMATraspaso)
				OR 
				(t2.IdEntSal IS NULL AND t2.IdFactura IS NOT NULL)
			)


	SELECT 	 ClaArticulo
			,FechaViaje
			,ClaveArticulo
			,NomArticulo
			,ClaPedido	
			--,ClaCliente	
			,NombreCliente
			,FechaPromesaOrigen
			,KilosSurtidos
			,UnidadesSurtidas
			,IdPlanCarga
			,IdViaje
			,IdFactura	
			,IdOpm		
			--,ClaTipoMercado
			,NomTipoMercado
			,NomTransportista
			,ImporteFlete
			,IdNumTabular
			,PesoTeoricoKgs
			,ClaConsignado
			,NombreConsignado
			,ClaMoneda
			,NombreCortoMoneda
			,ShipID
	FROM	#tPedidos /*WITH (NOLOCK)*/
	ORDER BY FechaViaje,IdPlanCarga, ClaArticulo	

	SET NOCOUNT OFF
END


Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--*==============================================================
--*Objeto:		'OPESch.OPE_CU505_Pag5_Boton_CargarConfiguraciones_Proc'
--*Autor:		Luis F Verastegui
--*Fecha:		14/12/2015
--*Objetivo:	
--*Entrada:
--*Salida:
--*Precondiciones:
--*Revisiones: 
--*==============================================================

CREATE PROCEDURE OPESch.OPE_CU505_Pag5_Boton_CargarConfiguraciones_Proc
	@pnClaUbicacion int,
	@pnEsInvocada INT
AS
Begin
	Set Nocount on
	
		Declare @pdFechaInicial datetime, @pdFechaFinal datetime, @pnClaTipoInventario  int, @pnClaFamiliaAlambron int
		Select @pdFechaInicial = Getdate() , @pdFechaFinal = getdate()
							
		--	Clave Familia Int.Alambron
		SELECT  @pnClaFamiliaAlambron  = NumValor1 
		FROM OpeSch.OpecfgParametroNeg WITH (NOLOCK)
		WHERE   ClaUbicacion = @pnClaUbicacion 
		AND ClaParametro = 17
		
		-- 	Tipo de Inventario de PT					
		SELECT @pnClaTipoInventario = nValor1
		from TiCatConfiguracionVw (NOLOCK)   
		where ClaSistema = 127 and    
		ClaUbicacion = @pnClaUbicacion and    
		ClaConfiguracion = 11   

		IF(@pnEsInvocada = 0)
		BEGIN
			Select @pdFechaInicial as FechaInicial, @pdFechaFinal as FechaFinal,
					@pnClaTipoInventario as ClaTipoInventario,
					@pnClaFamiliaAlambron as ClaFamiliaAlambron
		END
		ELSE
		BEGIN
			SELECT 1
		END
				
	Set Nocount off
End