BEGIN TRAN
	SET NOCOUNT ON
	BEGIN TRY
		DECLARE @tCfgUbicacion TABLE
		(
			  Id			INT IDENTITY(1,1)
			, ClaUbicacion	INT
			, Servidor		VARCHAR(20)
			, sValor1					VARCHAR(400)
			, sValor2					VARCHAR(400)
			, nValor1					NUMERIC(25,3)
			, nValor2					NUMERIC(25,3)
			, dValor1					DATETIME
			, dValor2					DATETIME
		)

		DECLARE   @pnClaUbicacion			INT
				, @pnClaSistema				INT
				, @pnClaConfiguracion		INT
				, @psNombreConfiguracion	VARCHAR(80)
				, @psValor1					VARCHAR(400)
				, @psValor2					VARCHAR(400)
				, @pnValor1					NUMERIC(25,3)
				, @pnValor2					NUMERIC(25,3)
				, @pdValor1					DATETIME
				, @pdValor2					DATETIME	

		--/*Asignacion de valores*/
		SET @pnClaSistema			= 246
		SET @pnClaConfiguracion		= 246148	
		SET @psNombreConfiguracion	= 'Mostrar datos colada a partir del rollo mp'


		INSERT INTO @tCfgUbicacion (ClaUbicacion, Servidor, nValor1) 
		SELECT	10 ,'DEAAGANET03'	,0

		INSERT INTO @tCfgUbicacion (ClaUbicacion, Servidor, nValor1) 
		SELECT	12	,'DEADATNET03'	,0

		INSERT INTO @tCfgUbicacion (ClaUbicacion, Servidor, nValor1) 
		SELECT	20	,'DEAALPNET03'	,1

		INSERT INTO @tCfgUbicacion (ClaUbicacion, Servidor, nValor1) 
		SELECT	53	,'DEALEONET03'	,1

		INSERT INTO @tCfgUbicacion (ClaUbicacion, Servidor, nValor1) 
		SELECT	54	,'DEALEONET03'	,1

		INSERT INTO @tCfgUbicacion (ClaUbicacion, Servidor, nValor1) 
		SELECT	61	,'DEAQRONET03'	,1

		INSERT INTO @tCfgUbicacion (ClaUbicacion, Servidor, nValor1) 
		SELECT	65	,'DEAHOUNET03'	,1

		INSERT INTO @tCfgUbicacion (ClaUbicacion, Servidor, nValor1) 
		SELECT	300	,'DEAINDNET02'	,0

		INSERT INTO @tCfgUbicacion (ClaUbicacion, Servidor, nValor1) 
		SELECT	12	,'SRVDBDES01'	,1

		INSERT INTO @tCfgUbicacion (ClaUbicacion, Servidor, nValor1) 
		SELECT	20	,'SRVDBDES01'	,0


		IF 1=1
		BEGIN
	
			DECLARE @tCfgSrv TABLE
			(
				  Id			INT IDENTITY(1,1)
				, ClaUbicacion	INT
				, sValor1		VARCHAR(400)
				, sValor2		VARCHAR(400)
				, nValor1		NUMERIC(25,3)
				, nValor2		NUMERIC(25,3)
				, dValor1		DATETIME
				, dValor2		DATETIME		

			)

			INSERT INTO @tCfgSrv (
				  ClaUbicacion	
				, sValor1		
				, sValor2		
				, nValor1		
				, nValor2		
				, dValor1		
				, dValor2			
			)
			SELECT    ClaUbicacion	
					, sValor1		
					, sValor2		
					, nValor1		
					, nValor2		
					, dValor1		
					, dValor2		
			FROM	@tCfgUbicacion 
			WHERE	Servidor = @@SERVERNAME

			SELECT	@pnClaUbicacion = MIN(ClaUbicacion)
			FROM	@tCfgSrv

			WHILE @pnClaUbicacion IS NOT NULL
			BEGIN
				SET		@psValor1 = NULL
				SET		@psValor2 = NULL
				SET		@pnValor1 = NULL
				SET		@pnValor2 = NULL
				SET		@pdValor1 = NULL
				SET		@pdValor2 = NULL

				SELECT	  @psValor1  = sValor1
						, @psValor2  = sValor2
						, @pnValor1  = nValor1
						, @pnValor2  = nValor2
						, @pdValor1  = dValor1
						, @pdValor2  = dValor2
				FROM	@tCfgSrv
				WHERE	ClaUbicacion = @pnClaUbicacion

				----------------------------------------------------------------------------
				INSERT INTO OPCSch.OpcTiCatConfiguracionVw(
					  ClaUbicacion
					, ClaSistema
					, ClaConfiguracion
					, NombreConfiguracion
					, sValor1
					, sValor2
					, nValor1
					, nValor2
					, dValor1
					, dValor2
					, BajaLogica
					, FechaBajaLogica
					, FechaUltimaMod
					, NombrePcMod
					, ClaUsuarioMod
				)
				SELECT
					  @pnClaUbicacion			AS  ClaUbicacion
					, @pnClaSistema				AS  ClaSistema  
					, @pnClaConfiguracion		AS  ClaConfiguracion        
					, @psNombreConfiguracion	AS  NombreConfiguracion
					, @psValor1					AS  sValor1     
					, @psValor2					AS  sValor2           
					, @pnValor1					AS  nValor1           
					, @pnValor2					AS  nValor2           
					, @pdValor1					AS  dValor1                 
					, @pdValor2					AS  dValor2           
					, 0							AS  BajaLogica              
					, NULL						AS  FechaBajaLogica              
					, GETDATE()					AS  FechaUltimaMod               
					, 'CargaInicial'			AS  NombrePcMod             
					, 0							AS  ClaUsuarioMod
			

				SELECT	'' as 'Consulta', * 
				FROM	OPCSch.OpcTiCatConfiguracionVw 
				WHERE	ClaUbicacion	= @pnClaUbicacion
				AND		ClaSistema		= @pnClaSistema
				AND		ClaConfiguracion = @pnClaConfiguracion

				SELECT	@pnClaUbicacion = MIN(ClaUbicacion)
				FROM	@tCfgSrv
				WHERE	ClaUbicacion > @pnClaUbicacion
			END
		END

		COMMIT TRAN

	--	SELECT 'Prueba antes del commit'
	--	RAISERROR('',16,1)
	--	ROLLBACK TRAN
	--	SELECT 'Prueba despues del commit'
	END TRY

	BEGIN CATCH
		SELECT 'HUBO UN ERROR! ' + ERROR_MESSAGE()
		ROLLBACK TRAN
	END CATCH
