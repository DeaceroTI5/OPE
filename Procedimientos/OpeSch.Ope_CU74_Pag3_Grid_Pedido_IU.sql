ALTER PROCEDURE OpeSch.Ope_CU74_Pag3_Grid_Pedido_IU
@pnIdPlanCarga		INT,
@pnClaUbicacion		INT,
@pnClaUsuarioMod	INT,
@pnIdFabricacion	INT,
@pnIdFabricacionDet INT,
@pnClaArticulo		INT,
@pnCantEmbarcar		NUMERIC(22,8),
@pnCantEnPlanes		NUMERIC(22,8), -- AGREGADO
@psNombrePcMod		VARCHAR(64) ,
@psIdioma			VARCHAR(15)='SPANISH'
 AS
 BEGIN
	SET NOCOUNT ON
	
	---- Obtener Tipo de Inventario  
	DECLARE @ClaTipoInventario				 INT  
 
	SELECT  @ClaTipoInventario = 1   
	
	DECLARE @nPesoTeoricoKgs	NUMERIC(22,8),
			@nKgsASurtir		NUMERIC(22,8),
			@nCantPlanes		NUMERIC(22,4), 
			@nCantPlanAct		NUMERIC(22,4),
			@nClaArticulo		INT  
												
	SELECT	@nPesoTeoricoKgs	= PesoTeoricoKgs
	FROM	OpeSch.OpeArtCatArticuloVw with(nolock)
	WHERE	ClaArticulo			= @pnClaArticulo
	AND		ClaTipoInventario	= @ClaTipoInventario

	SELECT	@nCantPlanAct = PlanCargaDet.CantEmbarcada ,
			@nClaArticulo = PlanCargaDet.ClaArticulo
	FROM	OpeSch.OpeTraPlanCargaDet	PlanCargaDet WITH(NOLOCK)
	INNER JOIN	 OpeSch.OpeTraPlanCarga plancarga WITH(NOLOCK)		 
			ON  PlanCargaDet.ClaUbicacion =  plancarga.ClaUbicacion 
			AND plancargadet.IdPlanCarga = plancarga.IdPlanCarga  
	WHERE	PlanCargaDet.ClaUbicacion	  = @pnClaUbicacion AND
			PlanCargaDet.IdPlanCarga	  = @pnIdPlanCarga  AND
			PlanCargaDet.IdFabricacion    = @pnIdFabricacion AND
			PlanCargaDet.IdFabricacionDet = @pnIdFabricacionDet

	DECLARE @nEsFamActWMS	INT , 
			@sMensaje		VARCHAR(200) 

 	SET @nEsFamActWMS = 0 
	SET @sMensaje = ''


	-- INI: 02/05/23 - DCABRERAH - DECLARACION Y SETEADO DE VARIABLES PARA EL PROCESO DE MOVIMIENTO DE INVENTARIO --
	DECLARE @nDiferenciaPlanyEmbarque NUMERIC(22,8),
			@nDiferenciaPlanyEmbarquePorcen NUMERIC(22,8),
			@nErrorEnMovInventario INT,
			@nClaAlmacen INT,
			@sClaveArticulo VARCHAR(20)

	SET @nDiferenciaPlanyEmbarque = ABS(@pnCantEmbarcar	- @pnCantEnPlanes)
	
	IF(@pnCantEmbarcar >= @pnCantEnPlanes)
		SET @nDiferenciaPlanyEmbarquePorcen = @nDiferenciaPlanyEmbarque/@pnCantEmbarcar * 100
	ELSE
		SET @nDiferenciaPlanyEmbarquePorcen = @nDiferenciaPlanyEmbarque/@pnCantEnPlanes * 100

	SELECT	@sClaveArticulo = ClaveArticulo
	FROM	OpeSch.OpeArtCatArticuloVw WITH(NOLOCK)
	WHERE	ClaArticulo = @pnClaArticulo

	SELECT	@nClaAlmacen = ClaAlmacen
	FROM	OpeSch.OpeRecepcionPTPorRolloFn(@pnClaUbicacion, @sClaveArticulo, @psIdioma)

    DECLARE @nUbicacionSumDir INT

    SELECT  @nUbicacionSumDir = ISNULL(nValor1,0)
    FROM    OpeSch.OpeTiCatConfiguracionVw
    WHERE   ClaUbicacion = @pnClaUbicacion
    AND     ClaSistema = 127
    AND     ClaConfiguracion = 1271224

	IF ISNULL(@nUbicacionSumDir, 0) = 1
	BEGIN
		IF (@nDiferenciaPlanyEmbarquePorcen > 5.0) -- Si la diferencia es mayor al 5%
		BEGIN
			SET @sMensaje = 'La diferencia entre la Cantidad del Plan de Carga y la Cantidad de Embarque es mayor al 5 porciento.  Favor de verificar.' 
			RAISERROR(@sMensaje,16,1)
			RETURN 
		END
		
		-- AQUI SE EXEC EL CAMBIO DE INVENTARIO 
		EXEC OPESch.OPE_CU400_Pag1_Boton_btnGuardarAfectar_Proc 
			@pnClaUbicacion=@pnClaUbicacion,
			@pnCantidadCalidad=@nDiferenciaPlanyEmbarque,
			@pnKgsCapturados=@nDiferenciaPlanyEmbarque,
			@pnKgsTara=NULL,
			@pnIdOpm=NULL,
			@psClaveRollo='',
			@pnClaArticulo=@pnClaArticulo,
			@pnClaAlmacen=@nClaAlmacen,
			@pnClaSubAlmacen=NULL,
			@pnClaSubSubAlmacen=NULL,
			@pnClaSeccion=NULL,
			@pnClaUsuarioMod=@pnClaUsuarioMod,
			@psNombrePcMod=@psNombrePcMod,
			@pnTramosMult=NULL,
			@pnDispReservar=0,
			@psNomUnidad='Kg',
			@pnValidarAutPorcTolerancia=0,
			@pnAutorizadoPorcToler=0,
			@pnAutorizado=1,
			@pnAfectarError = @nErrorEnMovInventario OUTPUT
	END
	-- FIN: DECLARACION Y SETEADO DE VARIABLES PARA EL PROCESO DE MOVIMIENTO DE INVENTARIO --


	SELECT  @nEsFamActWMS = nValor1
	from	OpeSch.OpeCatConfiguracion WITH(NOLOCK)
	WHERE	ClaUbicacion = @pnClaUbicacion AND 
			ClaTipoInventario = 1 AND 
			ClaSistema =23 AND 
			ClaConfiguracion  = 156 
	 
	-- SI CAMBIÓ LA CANTIDAD DE LA ORDEN DE CARGA, VALIDA QUE NO SE TRATE DE UNA GENERADA
	-- AUTOMÁTICAMENTE POR MIDCONTINENT
	IF ISNULL(@nCantPlanAct,0)<> ISNULL(@pnCantEmbarcar,0)
	BEGIN
		-- VALIDA QUE LA ORDEN DE CARGA QUE SE DESEA MODIFICAR NO CORRESPONDA A UNA GENERADA POR MID CONTINENT
		EXEC OpeSch.OPE_CU74_Pag3_ValidarPlanCargaAutomatica_Proc	@pnIdPlanCarga    = @pnIdPlanCarga,
																	@pnClaUbicacion    = @pnClaUbicacion, 
																	@psIdioma          = @psIdioma 
 
		-- REVISAR QUE ESTÉ ACTIVA LA CONFIGURACIÓN POR FAMILIA
		-- QUE EL ARTICULO ESTÉ EN LA CONFIGURACIÓN
		-- QUE EL PLAN DE CARGA NO SE HAA ENVIADO
		IF ISNULL(@nEsFamActWMS,0)= 1 
		BEGIN 
		
			IF EXISTS (	SELECT 1 
						FROM	OpeSch.OpeCfgFAmiliasActivasWMS A WITH(NOLOCK)  
						WHERE	A.ClaUbicacion = @pnClaUbicacion AND
								A.ClaArticulo = @nClaArticulo  AND  
								A.BajaLogica =0 )
			BEGIN

				--SI EXISTE AL PLAN DE CARGA YA ENVIADO
				--  EL PLAN DE CARGA NO SE HAYA ENVIADO A WMS   
				 IF EXISTS (	SELECT 1  
								FROM	OPESCH.OpePlanesCargaEnviadosAWMS WITH(NOLOCK)  
								WHERE	ClaUbicacion = @pnClaUbicacion AND
										IdPlanCarga = @pnIdPlanCarga )
				BEGIN
					SET @sMensaje = 'No es posible modificar la cantidad del artículo ya que el plan de Carga puesto que ya fue enviado a WMS ' 
					RAISERROR(@sMensaje,16,1)
					RETURN 
				END 
			

			END 
		
		END
	
	END

		
	SET @nKgsASurtir = (@pnCantEmbarcar * @nPesoTeoricoKgs)
		
	UPDATE	 PlanCargaDet WITH (ROWLOCK)
	SET		CantEmbarcada		= @pnCantEmbarcar,
			PesoEmbarcado		= @nKgsASurtir,
			PesoCub				= (@nKgsASurtir * ISNULL(t2.FactorCubicaje, 1) )/1000,
			--PesoMaximoEmbarcar	= @nKgsASurtir,
			FechaUltimaMod		= getdate(),
			NombrePcMod			= @psNombrePcMod,
			ClaUsuarioMod		= @pnClaUsuarioMod 
	FROM	OpeSch.OpeTraPlanCargaDet				PlanCargaDet
	INNER JOIN	OpeSch.OpeTraPlanCarga				plancarga		ON (plancargadet.ClaUbicacion = plancarga.ClaUbicacion
																		AND plancargadet.IdPlanCarga = plancarga.IdPlanCarga)
	LEFT JOIN OpeSch.OpeRelArtTranspCubicajeVw	t2 with(nolock) ON	(t2.ClaArticulo = PlanCargaDet.ClaArticulo 
																		AND t2.ClaTransporte = plancarga.ClaTransporte)
	WHERE	PlanCargaDet.ClaUbicacion	= @pnClaUbicacion
	AND		PlanCargaDet.IdPlanCarga	= @pnIdPlanCarga
	AND		IdFabricacion				= @pnIdFabricacion
	AND		IdFabricacionDet			= @pnIdFabricacionDet
	
	-- NNAVA ¿Se debe usar vista de ple o de ope?
	--'PleSch.PleFleRelArtTranspCubicajeVw'
	--'OpeSch.OpeRelArtTranspCubicajeVw'


	--SE ACTUALIZA LA CANTIDAD EN PLANES.
	SELECT		@nCantPlanes = SUM(CantEmbarcada) 
	FROM		OpeSch.OpeTraPlanCargaDet A WITH(NOLOCK)
	INNER JOIN	OpeSch.OpeTraPlanCarga B WITH(NOLOCK) ON	(A.IdPlanCarga = B.IdPlanCarga
															AND A.ClaUbicacion = B.ClaUbicacion)
	WHERE A.IdFabricacion		= @pnIdFabricacion
	AND A.IdFabricacionDet		= @pnIdFabricacionDet
	AND A.ClaUbicacion			= @pnClaUbicacion
	AND B.ClaEstatusPlanCarga IN (0,1,2)
	
	UPDATE OpeSch.OpeTraFabricacionDet	WITH (ROWLOCK)
		SET CantPlanes			= ISNULL(@nCantPlanes, 0),
			FechaUltimaMod		= getdate(),
			NombrePcMod			= @psNombrePcMod,
			ClaUsuarioMod		= @pnClaUsuarioMod
	WHERE	IdFabricacion		= @pnIdFabricacion 
	AND		IdFabricacionDet	= @pnIdFabricacionDet
	
	
	SET NOCOUNT OFF	

 END