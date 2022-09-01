CREATE PROC OpeSch.Ope_CU70_Pag1ModFact_IU
	@pnClaUbicacion 	INT,
	@pnOCMF				INT,
	@psSelloMF			VARCHAR(20),
	@pnValorcubReal		NUMERIC(22,4),
	@pnClaJefeEmbMF		INT,
	@pnViajeMF 		INT OUTPUT,
	@pnClaUsuarioMod 	INT,
	@psNombrePcMod 		varchar(100)
 
AS
 
BEGIN
 
--	RAISERROR('Favor de usar PLO para facturar.', 16,1)
--	GOTO FINSP
	SET NOCOUNT ON
 
	DECLARE @idFab INT, @esSurtidoTotal INT
	
	exec OpeSch.OpePlanCargaFacturacionSu 
					1, /*@pnNumVersion,*/
					@pnClaUbicacion,
					@pnOCMF,
					@pnClaJefeEmbMF,
					@psSelloMF,
					@psNombrePcMod,
					@pnClaUsuarioMod
					
	/*hacer ciclo para 'Inicializar los movi de facturacion' igual hacerlo masivo*/
	
	CREATE TABLE #temp70det(
		FactSal INT, 
		idFabricacion INT, 
		claCliente INT, 
		nombreCliente VARCHAR (70), 
		FechaPromesaActual DATETIME, 
		comentarios VARCHAR (8000), 
		porcMin NUMERIC (22, 4), 
		total BIT, 
		esFact INT, 
		esUltimoPsg BIT, 
		esTotModif INT)
 
 
	INSERT INTO #temp70det(FactSal,	idFabricacion, claCliente,	nombreCliente,	FechaPromesaActual,
						comentarios, porcMin, total, esFact, esUltimoPsg, esTotModif )
	EXEC OpeSch.OpeTraMovEntSalSel  1,@pnOCMF,NULL,0,NULL,@pnClaUbicacion
	
	SELECT @idFab = MIN(idFabricacion)
	FROM #temp70det
	
	WHILE @idFab IS NOT NULL
	BEGIN
	
		SELECT @esSurtidoTotal =total 
		FROM #temp70det
		WHERE idFabricacion = @idFab
			

		exec OpeSch.OpeTraMovEntSalSu 
					1,
					@pnOCMF,
					-1,
					@idFab,
					-1,
					'',
					@esSurtidoTotal,
					@pnClaUbicacion,
					@psNombrePcMod,
					@pnClaUsuarioMod
		
		SELECT @idFab = MIN(idFabricacion)
		FROM #temp70det
		WHERE idFabricacion > @idFab
			
	
	END
	
 
	declare @p15 INT, @p16 INT 
	
	set @p15=0
	set @p16=null

 		
	--'OpeSch.OpeTraPlanCargaFacturaProc'
	exec OpeSch.OpeTraPlanCargaFacturaProc 
				1,
				@pnOCMF,
				-1,
				-1,
				@pnClaJefeEmbMF,
				1,
				@pnValorCubReal,
				0,
				0,
				0,
				@pnClaUbicacion,
 
				@psSelloMF,
				@PsNombrePcMod,
				@PnClaUsuarioMod,
				@p15 output,@p16 output

 		
SELECT @pnViajeMF = @p16
	
-- FALTA CAMBIAR A UNA CONFIGURACION DE OPE
DECLARE @PlantaManejaEstimacion INT, @IdBoleta INT,
@IdBoletaVenta INT,	@idViajeVenta INT, @IdPlanCargaVenta INT

--IF @pnClaUbicacion IN (329,327,326,325,324,323)
--	SET @PlantaManejaEstimacion = 1

	-- Ubicación utiliza el módulo de Estimaciones
	SELECT	@PlantaManejaEstimacion = nValor1
	FROM	OPESch.OpeTiCatConfiguracionVw (NOLOCK)   
	WHERE	ClaSistema		= 127 
	AND		ClaUbicacion	= @pnClaUbicacion 
	AND		ClaConfiguracion = 1271221
	AND		BajaLogica		= 0
 
 IF @psNombrePcMod = 'SOPORTE1'
	PRINT '@PlantaManejaEstimacion:' + CONVERT(VARCHAR,@PlantaManejaEstimacion)
 
 --select * from OpeSch.OpeTraFabricacionEspejoEstimacion
IF ISNULL(@PlantaManejaEstimacion,0) = 1
BEGIN

	IF @psNombrePcMod = 'SOPORTE1'
	BEGIN
		PRINT 'ViajeEstimacion'
		PRINT 'Ubiacion:' + convert(varchar,@pnClaUbicacion)
		PRINT 'Viaje:' + convert(varchar,@pnViajeMF)
	END
	
	--EL PLAN DE CARGA ES DE TRASPASO Y TIENE PEDIDO DE ESTIMACION
	IF EXISTS(SELECT 1 
					  FROM OpeSch.OpeTraMovEntSal B WITH(NOLOCK) 
					  INNER JOIN OpeSch.OpeTraViaje C WITH(NOLOCK) 
					  ON    C.ClaUbicacion = B.ClaUbicacion AND 
							C.IdViaje = B.IdViaje
					  INNER JOIN OpeSch.OpeTraFabricacionEspejoEstimacion D WITH(NOLOCK)
					  ON	D.claUbicacionEstimacion = B.ClaUbicacion
					  AND	D.idFabricacionEstimacion = B.idFabricacion
					  WHERE B.ClaUbicacion = @pnClaUbicacion AND 
							B.IdViaje = @pnViajeMF AND
							B.idFactura IS NULL	)
	BEGIN	
		IF @psNombrePcMod = 'SOPORTE1'
		BEGIN
			PRINT 'ViajeEstimacion'
			PRINT 'Ubiacion:' + convert(varchar,@pnClaUbicacion)
			PRINT 'Viaje:' + convert(varchar,@pnViajeMF)
		END
						
		SELECT @IdBoleta = idboleta
		FROM OpeSch.OpeTraPlanCarga WITH(NOLOCK)							
		WHERE ClaUbicacion = @pnClaUbicacion
		AND idPlanCarga = @pnOCMF
		
		DECLARE @esPrimeraInvocacion INT
		SELECT @esPrimeraInvocacion = 1
		
		SELECT	@IdBoletaVenta = a.IdBoletaVenta,
				@IdPlanCargaVenta = a.IdPlanCargaVenta,
				@idViajeVenta = a.idViajeVenta,
				@esPrimeraInvocacion = 0
		FROM OpeSch.OpeTraPlanCargaRemisionEstimacion a
		WHERE a.claUbicacionEstimacion = @pnClaUbicacion
		AND a.idBoletaEstimacion = @IdBoleta
		AND a.idPlanCargaEstimacion = @pnOCMF
		AND a.idViajeEstimacion = @pnViajeMF
		
		IF @psNombrePcMod = 'SOPORTE1'
			PRINT '@esPrimeraInvocacion:' +CONVERT(VARCHAR,@esPrimeraInvocacion)
	
		
		--FALTA AGREGAR EL LINKEDSERVER PARA HACERLO MULTISERVIDOR
		EXEC OpeSch.OpeGeneraRemisionEstimacionProc
				@pnClaUbicacion, 
				@IdBoleta,
				@pnOCMF, 
				@pnViajeMF,
				@IdBoletaVenta OUTPUT, -- si este parametro es nulo es insert de lo contrario es update. Tiene que ser tipo OUTPUT
				@IdPlanCargaVenta OUTPUT,
				@idViajeVenta OUTPUT
				,@print = 0

		IF ISNULL(@esPrimeraInvocacion,0) = 1
		BEGIN
			--select * from OpeSch.OpeTraPlanCargaRemisionEstimacion
			INSERT INTO OpeSch.OpeTraPlanCargaRemisionEstimacion (
				ClaUbicacionEstimacion,IdBoletaEstimacion,IdPlanCargaEstimacion,IdViajeEstimacion,
				ClaUbicacionVenta,IdBoletaVenta,IdPlanCargaVenta,IdViajeVenta,
				FechaIns, FechaUltimaMod,ClaUsuarioMod,NombrePCMod )
			SELECT
				@pnClaUbicacion,@IdBoleta, @pnOCMF,@pnViajeMF,
				365, @IdBoletaVenta, @IdPlanCargaVenta, @idViajeVenta,
				GETDATE(),GETDATE(), @pnClaUsuarioMod ,@psNombrePcMod
			
		END
		ELSE
		BEGIN
			UPDATE a
			SET FechaUltimaMod	= GETDATE(),
				ClaUsuarioMod	= @pnClaUsuarioMod,
				NombrePcMod		= @psNombrePcMod
			FROM OpeSch.OpeTraPlanCargaRemisionEstimacion a
			WHERE a.claUbicacionEstimacion = @pnClaUbicacion
			AND a.idBoletaEstimacion = @IdBoleta
			AND a.idPlanCargaEstimacion = @pnOCMF
			AND a.idViajeEstimacion = @pnViajeMF
		END
	END
END
 
 
FINSP:
	SET NOCOUNT OFF
	
END