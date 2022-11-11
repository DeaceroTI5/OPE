USE Operacion
GO
	BEGIN TRAN

	DECLARE	  @pnClaUbicacion       INT

	DECLARE @tUbicaciones AS TABLE(
		ClaUbicacion	INT
	)

	INSERT INTO @tUbicaciones (ClaUbicacion)
	SELECT 	b.ClaUbicacion
	FROM	OpeSch.OpeTiCatUbicacionVw b
	WHERE	b.ClaUbicacion IN (277, 278, 364)
	AND		BajaLogica = 0
	UNION
	SELECT  a.ClaUbicacion
	FROM	OpeSch.OpeTiCatUbicacionVw a
	WHERE	ClaEmpresa	= 52
	AND		BajaLogica = 0

	SELECT	@pnClaUbicacion = MIN(ClaUbicacion) 
	FROM	@tUbicaciones

	WHILE	@pnClaUbicacion IS NOT NULL
	BEGIN

		  ----------------------------------------------------------------------------
		 INSERT INTO OPESch.OpeTiCatConfiguracionVw (
				ClaUbicacion
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
			  , FechaUltimaMod
			  , NombrePcMod
			  , ClaUsuarioMod
		 ) 
		 VALUES (
			  @pnClaUbicacion			-- ClaUbicacion
			, 127						-- ClaSistema  
			, 1271230					-- ClaConfiguracion        
			, 'Fecha de Ultima Modificación de Cambios de Destinos en Traspasos Manuales' -- NombreConfiguracion
			, NULL						-- sValor1     
			, NULL						-- sValor2           
			, NULL 						-- nValor1           
			, NULL						-- nValor2           
			, '2010-11-04 00:00:00.001'	-- dValor1                 
			, NULL						-- dValor2           
			, 0							-- BajaLogica              
			, NULL						-- FechaBajaLogica              
			, GETDATE()					-- FechaUltimaMod               
			, 'CargaInicial'			-- NombrePcMod 
			, 1							-- ClaUsuarioMod            
		)


		SELECT	@pnClaUbicacion = MIN(ClaUbicacion) 
		FROM	@tUbicaciones
		WHERE	ClaUbicacion > @pnClaUbicacion
	END



	-- Consulta
	SELECT	*
	from	OPESch.OpeTiCatConfiguracionVw  (NOLOCK)   
	where	ClaSistema = 127 
	and		ClaConfiguracion = 1271230 

	--ROLLBACK TRAN
	COMMIT TRAN