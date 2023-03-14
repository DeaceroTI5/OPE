USE Operacion
GO

    /*Insertar Configuración*/
      DECLARE	  @pnClaUbicacion       INT
				, @nClaConfiguracion    INT
				, @sNombreConfiguracion	VARCHAR(80)
				, @sValor1              VARCHAR(400)
				, @sValor2              VARCHAR(400)
				, @nValor1              NUMERIC(25,3)
				, @nValor2              NUMERIC(25,3)
				, @dValor1              DATETIME
				, @dValor2              DATETIME                

     SELECT		  @pnClaUbicacion		= 267
				, @nClaConfiguracion	= 1271236      
                , @sNombreConfiguracion	= 'Muestra Nombre Empresa USA (1-Nombre Empresa Usa / 0 - Nombre Empresa)'
                , @sValor1				= NULL
				, @sValor2				= NULL                     
                , @nValor1				= 1
                , @nValor2				= NULL
                , @dValor1				= NULL
                , @dValor2				= NULL
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
