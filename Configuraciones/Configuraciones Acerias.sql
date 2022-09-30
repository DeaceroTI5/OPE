USE Operacion
GO
      /*Insertar Configuración*/
      DECLARE @pnClaUbicacion            INT
                  ,@nClaConfiguracion          INT
                  ,@sNombreConfiguracion  VARCHAR(80)
                  ,@sValor1                    VARCHAR(400)
                  ,@sValor2                    VARCHAR(400)
                  ,@nValor1                    NUMERIC(25,3)
                  ,@nValor2                    NUMERIC(25,3)
                  ,@dValor1                    DATETIME
                  ,@dValor2                    DATETIME                

     SELECT  @pnClaUbicacion					= 325
                  ,@nClaConfiguracion          = 1271212    
                  ,@sNombreConfiguracion		= 'Configuraciones Acerias'
                  ,@sValor1						= '1271213,1271214,1271215'
				  ,@sValor2                    = NULL                     
                  ,@nValor1                    = NULL
                  ,@nValor2                    = NULL
                  ,@dValor1                    = NULL
                  ,@dValor2                    = NULL
      ----------------------------------------------------------------------------
     INSERT INTO OPESch.OpeTiCatConfiguracionVw (
         ClaUbicacion
            ,ClaSistema
            ,ClaConfiguracion
            ,NomConfiguracion
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
            @pnClaUbicacion        --  ClaUbicacion
        ,127                       --  ClaSistema  
        ,@nClaConfiguracion        --  ClaConfiguracion        
        ,@sNombreConfiguracion     --  NombreConfiguracion
        ,@sValor1                  --  sValor1     
        ,@sValor2               --  sValor2           
        ,@nValor1                  --  nValor1           
        ,@nValor2                  --  nValor2           
        ,@dValor1               --  dValor1                 
        ,@dValor2               --  dValor2           
        ,0                      --  BajaLogica              
        ,NULL                   --  FechaBajaLogica              
        ,GETDATE()              --  FechaUltimaMod               
        ,'CargaInicial'         --  NombrePcMod 
        ,1                               --    ClaUsuarioMod            
      )

	  GO
      DECLARE @pnClaUbicacion            INT
                  ,@nClaConfiguracion          INT
                  ,@sNombreConfiguracion  VARCHAR(80)
                  ,@sValor1                    VARCHAR(400)
                  ,@sValor2                    VARCHAR(400)
                  ,@nValor1                    NUMERIC(25,3)
                  ,@nValor2                    NUMERIC(25,3)
                  ,@dValor1                    DATETIME
                  ,@dValor2                    DATETIME                

     SELECT  @pnClaUbicacion					= 325
                  ,@nClaConfiguracion          = 1271213    
                  ,@sNombreConfiguracion		= 'Proveedor MP Acería Celaya'
                  ,@sValor1						= 'ACE_7CELAYA_LNKSRVR'
				  ,@sValor2                    = 'Acería Celaya'                     
                  ,@nValor1                    = 1
                  ,@nValor2                    = 7
                  ,@dValor1                    = NULL
                  ,@dValor2                    = NULL
      ----------------------------------------------------------------------------
     INSERT INTO OPESch.OpeTiCatConfiguracionVw (
         ClaUbicacion
            ,ClaSistema
            ,ClaConfiguracion
            ,NomConfiguracion
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
            @pnClaUbicacion        --  ClaUbicacion
        ,127                       --  ClaSistema  
        ,@nClaConfiguracion        --  ClaConfiguracion        
        ,@sNombreConfiguracion     --  NombreConfiguracion
        ,@sValor1                  --  sValor1     
        ,@sValor2               --  sValor2           
        ,@nValor1                  --  nValor1           
        ,@nValor2                  --  nValor2           
        ,@dValor1               --  dValor1                 
        ,@dValor2               --  dValor2           
        ,0                      --  BajaLogica              
        ,NULL                   --  FechaBajaLogica              
        ,GETDATE()              --  FechaUltimaMod               
        ,'CargaInicial'         --  NombrePcMod 
        ,1                               --    ClaUsuarioMod            
      )

GO
	  GO
      DECLARE @pnClaUbicacion            INT
                  ,@nClaConfiguracion          INT
                  ,@sNombreConfiguracion  VARCHAR(80)
                  ,@sValor1                    VARCHAR(400)
                  ,@sValor2                    VARCHAR(400)
                  ,@nValor1                    NUMERIC(25,3)
                  ,@nValor2                    NUMERIC(25,3)
                  ,@dValor1                    DATETIME
                  ,@dValor2                    DATETIME                

     SELECT  @pnClaUbicacion					= 325
                  ,@nClaConfiguracion          = 1271214   
                  ,@sNombreConfiguracion		= 'Proveedor MP Acería Saltillo'
                  ,@sValor1						= 'ACE_1SALTILLO_LNKSRV'
				  ,@sValor2                    = 'Acería Saltillo'                     
                  ,@nValor1                    = 2
                  ,@nValor2                    = 1
                  ,@dValor1                    = NULL
                  ,@dValor2                    = NULL
      ----------------------------------------------------------------------------
     INSERT INTO OPESch.OpeTiCatConfiguracionVw (
         ClaUbicacion
            ,ClaSistema
            ,ClaConfiguracion
            ,NomConfiguracion
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
            @pnClaUbicacion        --  ClaUbicacion
        ,127                       --  ClaSistema  
        ,@nClaConfiguracion        --  ClaConfiguracion        
        ,@sNombreConfiguracion     --  NombreConfiguracion
        ,@sValor1                  --  sValor1     
        ,@sValor2               --  sValor2           
        ,@nValor1                  --  nValor1           
        ,@nValor2                  --  nValor2           
        ,@dValor1               --  dValor1                 
        ,@dValor2               --  dValor2           
        ,0                      --  BajaLogica              
        ,NULL                   --  FechaBajaLogica              
        ,GETDATE()              --  FechaUltimaMod               
        ,'CargaInicial'         --  NombrePcMod 
        ,1                               --    ClaUsuarioMod            
      )

GO
	  GO
      DECLARE @pnClaUbicacion            INT
                  ,@nClaConfiguracion          INT
                  ,@sNombreConfiguracion  VARCHAR(80)
                  ,@sValor1                    VARCHAR(400)
                  ,@sValor2                    VARCHAR(400)
                  ,@nValor1                    NUMERIC(25,3)
                  ,@nValor2                    NUMERIC(25,3)
                  ,@dValor1                    DATETIME
                  ,@dValor2                    DATETIME                

     SELECT  @pnClaUbicacion					= 325
                  ,@nClaConfiguracion          = 1271215   
                  ,@sNombreConfiguracion		= 'Proveedor MP Acería Ramos Arizpe'
                  ,@sValor1						= 'ACE_22ACE3M_LNKSVR'
				  ,@sValor2                    = 'Acería Ramos Arizpe'                     
                  ,@nValor1                    = 3
                  ,@nValor2                    = 22
                  ,@dValor1                    = NULL
                  ,@dValor2                    = NULL
      ----------------------------------------------------------------------------
     INSERT INTO OPESch.OpeTiCatConfiguracionVw (
         ClaUbicacion
            ,ClaSistema
            ,ClaConfiguracion
            ,NomConfiguracion
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
            @pnClaUbicacion        --  ClaUbicacion
        ,127                       --  ClaSistema  
        ,@nClaConfiguracion        --  ClaConfiguracion        
        ,@sNombreConfiguracion     --  NombreConfiguracion
        ,@sValor1                  --  sValor1     
        ,@sValor2               --  sValor2           
        ,@nValor1                  --  nValor1           
        ,@nValor2                  --  nValor2           
        ,@dValor1               --  dValor1                 
        ,@dValor2               --  dValor2           
        ,0                      --  BajaLogica              
        ,NULL                   --  FechaBajaLogica              
        ,GETDATE()              --  FechaUltimaMod               
        ,'CargaInicial'         --  NombrePcMod 
        ,1                               --    ClaUsuarioMod            
      )

GO