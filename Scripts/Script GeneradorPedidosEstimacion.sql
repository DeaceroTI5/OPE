

BEGIN TRAN

	--------------------------------------------------------------------------------------------------------------------
      /*Insertar Configuración*/	-- TallerTlalnepantla
      DECLARE	  @pnClaUbicacion       INT
				, @nClaConfiguracion    INT
				, @sNombreConfiguracion	VARCHAR(80)
				, @sValor1              VARCHAR(400)
				, @sValor2              VARCHAR(400)
				, @nValor1              NUMERIC(25,3)
				, @nValor2              NUMERIC(25,3)
				, @dValor1              DATETIME
				, @dValor2              DATETIME                

     SELECT		  @pnClaUbicacion		= 326
				, @nClaConfiguracion	= 1271221    
                , @sNombreConfiguracion	= 'Notificación de generación de pedido espejo'
                , @sValor1				= 'lbenitez@ingetek.com.mx; jjmejia@ingetek.com.mx'
				, @sValor2				= NULL                     
                , @nValor1				= 1
                , @nValor2				= NULL
                , @dValor1				= NULL
                , @dValor2				= NULL

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
		  @pnClaUbicacion        -- ClaUbicacion
		, 127                    -- ClaSistema  
		, @nClaConfiguracion     -- ClaConfiguracion        
		, @sNombreConfiguracion  -- NombreConfiguracion
		, @sValor1               -- sValor1     
		, @sValor2               -- sValor2           
		, @nValor1               -- nValor1           
		, @nValor2               -- nValor2           
		, @dValor1               -- dValor1                 
		, @dValor2               -- dValor2           
		, 0                      -- BajaLogica              
		, NULL                   -- FechaBajaLogica              
		, GETDATE()              -- FechaUltimaMod               
		, 'CargaInicial'         -- NombrePcMod 
		, 1                      -- ClaUsuarioMod            
	)
	
	GO
	--------------------------------------------------------------------------------------------------------------------
      /*Insertar Configuración*/	-- TallerGarcia
      DECLARE	  @pnClaUbicacion       INT
				, @nClaConfiguracion    INT
				, @sNombreConfiguracion	VARCHAR(80)
				, @sValor1              VARCHAR(400)
				, @sValor2              VARCHAR(400)
				, @nValor1              NUMERIC(25,3)
				, @nValor2              NUMERIC(25,3)
				, @dValor1              DATETIME
				, @dValor2              DATETIME                

     SELECT		  @pnClaUbicacion		= 325
				, @nClaConfiguracion	= 1271221    
                , @sNombreConfiguracion	= 'Notificación de generación de pedido espejo'
                , @sValor1				= 'catinoco@ingetek.com.mx; arncan@ingetek.com.mx'
				, @sValor2				= NULL                     
                , @nValor1				= 1
                , @nValor2				= NULL
                , @dValor1				= NULL
                , @dValor2				= NULL

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
		  @pnClaUbicacion        -- ClaUbicacion
		, 127                    -- ClaSistema  
		, @nClaConfiguracion     -- ClaConfiguracion        
		, @sNombreConfiguracion  -- NombreConfiguracion
		, @sValor1               -- sValor1     
		, @sValor2               -- sValor2           
		, @nValor1               -- nValor1           
		, @nValor2               -- nValor2           
		, @dValor1               -- dValor1                 
		, @dValor2               -- dValor2           
		, 0                      -- BajaLogica              
		, NULL                   -- FechaBajaLogica              
		, GETDATE()              -- FechaUltimaMod               
		, 'CargaInicial'         -- NombrePcMod 
		, 1                      -- ClaUsuarioMod            
	)


	GO
	--------------------------------------------------------------------------------------------------------------------
      /*Insertar Configuración*/	-- TallerMexicali
      DECLARE	  @pnClaUbicacion       INT
				, @nClaConfiguracion    INT
				, @sNombreConfiguracion	VARCHAR(80)
				, @sValor1              VARCHAR(400)
				, @sValor2              VARCHAR(400)
				, @nValor1              NUMERIC(25,3)
				, @nValor2              NUMERIC(25,3)
				, @dValor1              DATETIME
				, @dValor2              DATETIME                

     SELECT		  @pnClaUbicacion		= 327
				, @nClaConfiguracion	= 1271221    
                , @sNombreConfiguracion	= 'Notificación de generación de pedido espejo'
                , @sValor1				= 'JAVIVEROS@deacero.com; MSFERNANDEZ@deacero.com'
				, @sValor2				= NULL                     
                , @nValor1				= 1
                , @nValor2				= NULL
                , @dValor1				= NULL
                , @dValor2				= NULL

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
		  @pnClaUbicacion        -- ClaUbicacion
		, 127                    -- ClaSistema  
		, @nClaConfiguracion     -- ClaConfiguracion        
		, @sNombreConfiguracion  -- NombreConfiguracion
		, @sValor1               -- sValor1     
		, @sValor2               -- sValor2           
		, @nValor1               -- nValor1           
		, @nValor2               -- nValor2           
		, @dValor1               -- dValor1                 
		, @dValor2               -- dValor2           
		, 0                      -- BajaLogica              
		, NULL                   -- FechaBajaLogica              
		, GETDATE()              -- FechaUltimaMod               
		, 'CargaInicial'         -- NombrePcMod 
		, 1                      -- ClaUsuarioMod            
	)

	GO
	--------------------------------------------------------------------------------------------------------------------
      /*Insertar Configuración*/	-- TallerCancun
      DECLARE	  @pnClaUbicacion       INT
				, @nClaConfiguracion    INT
				, @sNombreConfiguracion	VARCHAR(80)
				, @sValor1              VARCHAR(400)
				, @sValor2              VARCHAR(400)
				, @nValor1              NUMERIC(25,3)
				, @nValor2              NUMERIC(25,3)
				, @dValor1              DATETIME
				, @dValor2              DATETIME                

     SELECT		  @pnClaUbicacion		= 329
				, @nClaConfiguracion	= 1271221    
                , @sNombreConfiguracion	= 'Notificación de generación de pedido espejo'
                , @sValor1				= 'pedesp@ingetek.com.mx'
				, @sValor2				= NULL                     
                , @nValor1				= 1
                , @nValor2				= NULL
                , @dValor1				= NULL
                , @dValor2				= NULL

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
		  @pnClaUbicacion        -- ClaUbicacion
		, 127                    -- ClaSistema  
		, @nClaConfiguracion     -- ClaConfiguracion        
		, @sNombreConfiguracion  -- NombreConfiguracion
		, @sValor1               -- sValor1     
		, @sValor2               -- sValor2           
		, @nValor1               -- nValor1           
		, @nValor2               -- nValor2           
		, @dValor1               -- dValor1                 
		, @dValor2               -- dValor2           
		, 0                      -- BajaLogica              
		, NULL                   -- FechaBajaLogica              
		, GETDATE()              -- FechaUltimaMod               
		, 'CargaInicial'         -- NombrePcMod 
		, 1                      -- ClaUsuarioMod            
	)



		EXEC OpeSch.OpeEstGeneradorPedidosEstimacion
			  @pnConsecutivo			= NULL
			, @pnUbicacion			= NULL
			, @pnFabricacion			= NULL
			, @pnClaUsuarioMod		= 1000
			, @psNombrePcMod			= 'EstimacionIngetek'
			, @pnFabricacionEspejo	= NULL
			, @pnDebug				= 1

	


ROLLBACK TRAN 
PRINT 'FIN TRANSACTION'