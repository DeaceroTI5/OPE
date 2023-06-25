	/*Insertar Configuración*/
	DECLARE @pnClaUbicacion			INT
			,@nClaConfiguracion		INT
			,@sNombreConfiguracion	VARCHAR(80)
			,@sValor1				VARCHAR(400)
			,@sValor2				VARCHAR(400)
			,@nValor1				NUMERIC(25,3)
			,@nValor2				NUMERIC(25,3)
			,@dValor1				DATETIME
			,@dValor2				DATETIME			

     SELECT  @pnClaUbicacion		= 61
			,@nClaConfiguracion		= 246153	
			,@sNombreConfiguracion	= 'Nombre de planta para etiquetas'
			,@sValor1				= 'PLANTA QUERETARO'	
			,@sValor2				= 'QUERETARO PLANT'
			,@nValor1				= NULL
			,@nValor2				= NULL
			,@dValor1				= NULL
			,@dValor2				= NULL
	----------------------------------------------------------------------------
     INSERT INTO OPCSch.OpcTiCatConfiguracionVw(
         ClaUbicacion
		,ClaSistema
		,ClaConfiguracion
		,NombreConfiguracion
		,sValor1
		,sValor2
		,nValor1
		,nValor2
		,dValor1
		,dValor2
		,BajaLogica
		,FechaBajaLogica
		,FechaUltimaMod
		,NombrePcMod
		,ClaUsuarioMod
     )VALUES(
		 @pnClaUbicacion		--  ClaUbicacion
        ,246					--  ClaSistema  
        ,@nClaConfiguracion		--  ClaConfiguracion        
        ,@sNombreConfiguracion	--  NombreConfiguracion
        ,@sValor1				--  sValor1     
        ,@sValor2               --  sValor2           
        ,@nValor1				--  nValor1           
        ,@nValor2				--  nValor2           
        ,@dValor1               --  dValor1                 
        ,@dValor2               --  dValor2           
        ,0                      --  BajaLogica              
        ,NULL                   --  FechaBajaLogica              
        ,GETDATE()              --  FechaUltimaMod               
        ,'CargaInicial'         --  NombrePcMod             
        ,0                      --  ClaUsuarioMod     
     )
     

--	 SELECT * FROM OPCSch.OpcTiCatConfiguracionVw WHERE ClaUbicacion = 61 AND ClaConfiguracion = 246153
