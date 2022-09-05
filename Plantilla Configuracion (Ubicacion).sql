	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	USE Operacion
	GO
	
	/*Consulta Consecutivo*/
	DECLARE @nClaSistema INT
	SELECT	@nClaSistema = 127 
	
	SELECT Servidor, ClaUbicacion, ClaConfiguracionSig FROM (
		SELECT	TOP 1 'SRVLABUSANET01 (des)' AS Servidor, ClaUbicacion, MAX(ClaConfiguracion)+1 AS ClaConfiguracionSig 
		FROM	OPESch.OpeTiCatConfiguracionVw WHERE ClaSistema = @nClaSistema GROUP BY ClaUbicacion ORDER BY ClaConfiguracionSig DESC
		UNION ALL
		SELECT	TOP 1 'SRVDBDES01 (des)' AS Servidor, ClaUbicacion, MAX(ClaConfiguracion)+1 AS ClaConfiguracionSig 
		FROM	SRVDBDES01.Operacion.OPESch.OpeTiCatConfiguracionVw WHERE ClaSistema = @nClaSistema GROUP BY ClaUbicacion ORDER BY ClaConfiguracionSig DESC
		UNION ALL
		SELECT	TOP 1 'DEAITKUSANET01' AS Servidor, ClaUbicacion, MAX(ClaConfiguracion)+1 AS ClaConfiguracionSig 
		FROM	DEAITKUSANET01.operacion.OPESch.OpeTiCatConfiguracionVw WHERE ClaSistema = @nClaSistema GROUP BY ClaUbicacion ORDER BY ClaConfiguracionSig DESC
		UNION ALL
		SELECT TOP 1 'DEAALPNET03' AS Servidor, ClaUbicacion, MAX(ClaConfiguracion)+1  AS ClaConfiguracionSig 
		FROM	DEAALPNET03.Operacion.OPESch.OpeTiCatConfiguracionVw WHERE	ClaSistema = @nClaSistema GROUP BY ClaUbicacion ORDER BY ClaConfiguracionSig DESC
		UNION ALL
		SELECT TOP 1 'DEADATNET03' AS Servidor, ClaUbicacion, MAX(ClaConfiguracion)+1 AS ClaConfiguracionSig 
		FROM	DEADATNET03.Operacion.OPESch.OpeTiCatConfiguracionVw WHERE	ClaSistema = @nClaSistema GROUP BY ClaUbicacion ORDER BY ClaConfiguracionSig DESC
		UNION ALL
		SELECT TOP 1 'DEAINDNET02' AS Servidor,  ClaUbicacion, MAX(ClaConfiguracion)+1 AS ClaConfiguracionSig 
		FROM	DEAINDNET02.Operacion.OPESch.OpeTiCatConfiguracionVw WHERE	ClaSistema = @nClaSistema GROUP BY ClaUbicacion ORDER BY ClaConfiguracionSig DESC
		UNION ALL
		SELECT TOP 1 'DEAAGANET03' AS Servidor, ClaUbicacion, MAX(ClaConfiguracion)+1 AS ClaConfiguracionSig 
		FROM	DEAAGANET03.Operacion.OPESch.OpeTiCatConfiguracionVw WHERE	ClaSistema = @nClaSistema GROUP BY ClaUbicacion ORDER BY ClaConfiguracionSig DESC
		UNION ALL
		SELECT TOP 1 'DEALEONET03' AS Servidor, ClaUbicacion, MAX(ClaConfiguracion)+1 AS ClaConfiguracionSig 
		FROM	DEALEONET03.Operacion.OPESch.OpeTiCatConfiguracionVw WHERE	ClaSistema = @nClaSistema GROUP BY ClaUbicacion ORDER BY ClaConfiguracionSig DESC
		UNION ALL
		SELECT TOP 1 'DEAQRONET03' AS Servidor, ClaUbicacion, MAX(ClaConfiguracion)+1 AS ClaConfiguracionSig 
		FROM	DEAQRONET03.Operacion.OPESch.OpeTiCatConfiguracionVw WHERE	ClaSistema = @nClaSistema GROUP BY ClaUbicacion ORDER BY ClaConfiguracionSig DESC
		UNION ALL
		SELECT TOP 1 'DEAHOUNET03' AS Servidor, ClaUbicacion, MAX(ClaConfiguracion)+1 AS ClaConfiguracionSig 
		FROM	DEAHOUNET03.Operacion.OPESch.OpeTiCatConfiguracionVw WHERE	ClaSistema = @nClaSistema GROUP BY ClaUbicacion	ORDER BY ClaConfiguracionSig DESC
	) AS H ORDER BY ClaConfiguracionSig DESC
	

	-- Revisión ultimas configuraciones
	;WITH H AS (
		SELECT	TOP 5
				ClaUbicacion, ClaConfiguracion, NomConfiguracion
		FROM	DEAITKUSANET01.operacion.OPESch.OpeTiCatConfiguracionVw 
		WHERE	ClaSistema = 127
		ORDER BY ClaConfiguracion DESC
	)	SELECT * FROM H



	--SELECT @@servername AS Servidor, MAX(ClaConfiguracion)+1 AS ClaConfiguracionSig 
	--FROM OPESch.OpeTiCatConfiguracionVw WHERE	ClaSistema = @nClaSistema		

	
	RETURN
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------	

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

     SELECT		  @pnClaUbicacion			= 369
				, @nClaConfiguracion		= 1271220    
                , @sNombreConfiguracion		= 'Tipo de documentación (ClaFormatoImpresion) permitidos Ingetek'
                , @sValor1					= '27,36,37'
				, @sValor2					= NULL                     
                , @nValor1					= NULL
                , @nValor2					= NULL
                , @dValor1					= NULL
                , @dValor2					= NULL
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

      

     
	SELECT	*
	FROM	OpeSch.OpeTiCatConfiguracionVw
	WHERE	ClaUbicacion = 12
	AND		ClaSistema = 127
	AND		ClaConfiguracion = 1271204

