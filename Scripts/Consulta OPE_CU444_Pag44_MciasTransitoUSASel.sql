-- CREATE PROCEDURE [OpeSch].[OPE_CU444_Pag44_MciasTransitoUSASel]
DECLARE 
	@pnClaUbicacion		INT,  
    @pnVerPor			INT,  
    @FechaInicial		DATETIME,  
    @FechaFinal			DATETIME,  
    @pnNumIni			INT,  
    @pnNumFin			INT,  
    @pnClaArticulo		INT,  
    @pnStatus			INT,  
    @psNomIsoIdioma		VARCHAR(2),  
    @pnClaOrigen		INT,  
    @pnSoloEncabezado	INT = 0,
	@pnIdentificador	INT = 0,
	@pnDebug			INT = 0

SELECT
      @pnClaUbicacion	= 362 
    , @pnVerPor			= 0
    , @FechaInicial		= NULL
    , @FechaFinal		= NULL
    , @pnNumIni			= NULL
    , @pnNumFin			= NULL
    , @pnClaArticulo	= NULL
    , @pnStatus			= -1
    , @psNomIsoIdioma	= 'es'
    , @pnClaOrigen		= 0
    , @pnSoloEncabezado	= 1
	, @pnIdentificador	= 1
	, @pnDebug			= 1
IF 1=1 --AS  
BEGIN    	
	SET NOCOUNT ON  
  
    -- COPIADO DE [PLOSCH].[PLOCONSULTAMCIASTRANSITOUSASEL]         
    SELECT @pnClaOrigen = CASE WHEN ISNULL(@pnClaOrigen,-1) <= 0 THEN NULL ELSE ISNULL(@pnClaOrigen,-1) END   
    
    CREATE TABLE #Traspaso( [ClaOrigen] [int] NOT NULL,  
                            [Origen] [char](50) NULL,  
                            [ClaDestino] [int] NOT NULL,  
                            [Destino] [char](50) NULL,  
                            [FechaMovimiento] [datetime] NULL,  
                            [ViajeOriginal] [int] NOT NULL,  
                            [EstatusTransito] [int] NULL,  
                            [Estatus] [int] NULL,  
                            [ClaArticulo] [int] NULL,  
                            [NomArticulo] [varchar](250) NOT NULL,  
                            [CantidadEnviada] [numeric](22, 4) NULL,  
                            [CantidadRecibida] [int] NULL,  
                            [CantidadCancelada] [int] NULL,  
                            [CantidadTransito] [int] NULL,  
                            [CantidadDepurada] [int] NULL,  
                            [KilosPesados] [int] NULL,  
                            [KilosTeoricos] [numeric](38, 6) NULL,  
                            [KilosEnviados] [numeric](22, 4) NULL,  
                            [KilosRecibidos] [int] NULL,  
                            [KilosTransito] [int] NULL,  
                            [PesoTeorico] [numeric](22, 7) NULL,  
                            [PesoEntrada] [numeric](22, 4) NULL,  
                            [PesoNeto] [int] NULL,  
                            [PesoSalida] [int] NULL,  
                            [PesoTara] [numeric](22, 4) NULL,  
                            [CampoEntero4] [int] NULL,  
                            [CampoTexto1] [int] NULL,  
                            [FechaHoraMovimientoEntrada] [datetime] NULL,  
                            [ClaTransporte] [int] NULL,  
                            [ClaTransportista] [int] NULL,  
                            [Placas] [varchar](12) NULL,  
                            [NombreChofer] [varchar](100) NULL,  
                            [ClaveMovimiento] [int] NULL,  
                            [NomTransportista] [varchar](100) NULL,  
                            [Caja] [varchar](12) NULL,  
                            [ClaRemision] [varchar](30) NULL,  
                            [ClaveRemision] [varchar](30) NULL,  
                            [IdFabricacion] [int] NOT NULL,  
                            [IdFabricacionDet] [int] NOT NULL,  
                            [KilosTara] [int] NULL,  
                            [Tarimas] [int] NULL,  
                            [Sello] [VARCHAR](255) NULL,--[Sello] [int] NULL,  
                            [EjeTransporte] [int] NULL,  
                            [AgenciaAduanal] [int] NULL,  
                            [Observaciones] [int] NULL,  
                            [ImporteRemisionado]  [numeric](22, 4) NULL)  
          
    DECLARE @pnTipoInventario INT  
    DECLARE @NomIsoIdiomaIngles VARCHAR(2)   
    DECLARE @NomIsoIdiomaOtro VARCHAR(2)  
    DECLARE @tbEstatus TABLE(numEstatus INT)  
    DECLARE @psEstatus VARCHAR(100)  
    
    SELECT  @NomIsoIdiomaIngles = LTRIM(RTRIM(sValor1))    
    FROM    OpeSch.OPETiCatConfiguracionVw (NOLOCK)    
    WHERE   ClaSistema = 127 AND    
            ClaConfiguracion = 4    
                      
	SELECT	@NomIsoIdiomaOtro = ltrim(rtrim(sValor1))    
    FROM    OpeSch.OPETiCatConfiguracionVw (NOLOCK)    
    WHERE   ClaSistema = 127 AND  
            ClaConfiguracion = 5       
        
    SELECT	@pnTipoInventario = nValor1   
    FROM	OpeSch.OPETiCatConfiguracionVw (NOLOCK)   
    WHERE	ClaSistema = 127 AND   
			ClaUbicacion = @pnClaUbicacion AND   
            ClaConfiguracion = 11  

    CREATE TABLE #TraspRecibir  
                    (ClaOrigen                   INT  
                    ,Origen                      VARCHAR(50)  
                    ,ClaUbicacionDestino         INT  
                    ,Destino                     VARCHAR(50)  
                    ,FechaMovimiento             DATETIME  
                    ,NumViaje                    INT  
                    ,EstatusTransito             INT  
                    ,Estatus                     INT  
                    ,ClaArticulo                 INT  
                    ,NomArticulo                 VARCHAR(300)  
                    ,CantidadEnviada             NUMERIC(22,4)  
                    ,CantidadRecibida            NUMERIC(22,4)  
                    ,CantidadCancelada           NUMERIC(22,4)  
                    ,CantidadTransito            NUMERIC(22,4)  
                    ,CantidadDepurada            NUMERIC(22,4)  
                    ,KilosPesados                NUMERIC(22,4)  
                    ,KilosTeoricos               NUMERIC(22,4)  
                    ,KilosEnviados               NUMERIC(38,6)  
                    ,KilosRecibidos              NUMERIC(38,6)  
                    ,KilosTransito               NUMERIC(38,6)  
                    ,PesoTeorico                 NUMERIC(22,4)  
                    ,PesoEntrada                 NUMERIC(22,4)  
                    ,PesoNeto                    NUMERIC(22,4)  
                    ,PesoSalida                  NUMERIC(22,4)  
                    ,PesoTara                    NUMERIC(22,4)  
                    ,CampoEntero4                INT  
                    ,CampoTexto1                 VARCHAR(100)  
                    ,FechaHoraMovimientoEntrada  DATETIME  
                    ,ClaTransporte               INT  
                    ,ClaTransportista            INT  
                    ,Placas                      VARCHAR(12)  
                    ,NombreChofer                VARCHAR(200)  
                    ,ClaveMovimiento             INT  
                    ,NomTransportista            VARCHAR(500)  
                    ,Caja                        VARCHAR(100)  
                    ,Remision                    INT  
                    ,ClaveRemision               VARCHAR(500)  
                    ,IdFabricacion               INT  
                    ,IdFabricacionDet            INT  
                    ,KilosTara                   NUMERIC(22,4)  
                    ,Tarimas                     NUMERIC(22,4)  
                    ,Sello                       VARCHAR(255)  
                    ,EjeTransporte               INT  
                    ,AgenciaAduanal              INT  
                    ,Observaciones               VARCHAR(500)  
                    ,NumericoExtra5              NUMERIC(22,4)  
                    ,IdFabricacionCliente        INT  
                    ,ClaEstatus                  INT )  

	IF(@pnVerPor<>0)  
    BEGIN  
		SET @FechaInicial=NULL  
        SET @FechaFinal=NULL  
	END  

    IF(@pnStatus IN (0,1,2,-1))  
    BEGIN    
		IF(@pnStatus=-1)  
        BEGIN  
			INSERT INTO @tbEstatus( numEstatus )  
			SELECT 0  
			UNION  
			SELECT 1  
			UNION  
			SELECT 2  
		END  
		ELSE  
		BEGIN  
			INSERT INTO @tbEstatus( numEstatus )  
			SELECT @pnStatus  
		END  
        
		if @pnDebug = 1
		select 1,@pnClaUbicacion ubicacion,NULL, @pnClaUbicacion ubicacion,@FechaInicial,@FechaFinal,0,NULL, @pnNumIni--,NULL  

		INSERT INTO #TraspRecibir ( ClaOrigen                                 
                                    ,Origen                                   
									,ClaUbicacionDestino                
                                    ,Destino                                  
                                    ,FechaMovimiento  
                                    ,NumViaje  
                                    ,EstatusTransito  
                                    ,Estatus              
                                    ,ClaArticulo                        
                                    ,NomArticulo                        
                                    ,CantidadEnviada                    
                                    ,CantidadRecibida                   
                                    ,CantidadCancelada                  
                                    ,CantidadTransito                   
                                    ,CantidadDepurada     
                                    ,KilosPesados                             
                                    ,KilosTeoricos                            
                                    ,KilosEnviados                            
                                    ,KilosRecibidos                     
                                    ,KilosTransito                            
                                    ,PesoTeorico                        
                                    ,PesoEntrada                        
                                    ,PesoNeto                                 
                                    ,PesoSalida                         
                                    ,PesoTara                                 
                                    ,CampoEntero4         
                                    ,CampoTexto1   
                                    ,FechaHoraMovimientoEntrada         
                                    ,ClaTransporte        
                                    ,ClaTransportista  
                                    ,Placas                             
                                    ,NombreChofer                             
                                    ,ClaveMovimiento  
                                    ,NomTransportista            
                                    ,Caja                 
                                    ,Remision  
                                    ,ClaveRemision  
                                    ,IdFabricacion  
                                    ,IdFabricacionDet  
                                    ,KilosTara  
                                    ,Tarimas  
                                    ,Sello  
                                    ,EjeTransporte  
                                    ,AgenciaAduanal       
                                    ,Observaciones  
                                    ,NumericoExtra5)               
		EXEC [OpeSch].[OpeConsultarTraspasosSel_Viaje] 1,@pnClaUbicacion,NULL, @pnClaUbicacion,@FechaInicial,@FechaFinal,0,NULL, @pnNumIni,1--,NULL                 
	END
		
	IF @pnDebug = 1
		SELECT 1, 'OpeConsultarTraspasosSel_Viaje', * FROM #TraspRecibir
       
	ALTER TABLE #TraspRecibir ADD Tipo INT       
      
    IF(@pnStatus in (3,4,-1))  
    BEGIN       
		IF(@pnStatus=-1)  
        BEGIN  
			INSERT INTO @tbEstatus( numEstatus )  
            SELECT 3  
            UNION  
            SELECT 4  
		END  
        ELSE  
        BEGIN  
			INSERT INTO @tbEstatus( numEstatus )  
			SELECT @pnStatus  
		END  
        
		SELECT @psEstatus='3,4'  
            
        INSERT INTO #Traspaso([ClaOrigen],  
                                [Origen],  
                                [ClaDestino],  
                                [Destino],  
                                [FechaMovimiento],  
                                [ViajeOriginal],  
                [EstatusTransito],  
                                [Estatus],  
                                [ClaArticulo],  
                                [NomArticulo],  
                                [CantidadEnviada],  
                                [CantidadRecibida],  
                                [CantidadCancelada],  
                                [CantidadTransito],  
                                [CantidadDepurada],  
                                [KilosPesados],  
                                [KilosTeoricos],  
                                [KilosEnviados],  
                                [KilosRecibidos],  
                                [KilosTransito],  
                                [PesoTeorico],  
                                [PesoEntrada],  
                                [PesoNeto],  
                                [PesoSalida],  
                                [PesoTara],  
                                [CampoEntero4],  
                                [CampoTexto1],  
                                [FechaHoraMovimientoEntrada],  
                                [ClaTransporte],  
                                [ClaTransportista],  
                                [Placas],  
                                [NombreChofer],  
                                [ClaveMovimiento],  
                                [NomTransportista],  
                                [Caja],  
                                [ClaRemision],  
                                [ClaveRemision],  
                                [IdFabricacion],  
                                [IdFabricacionDet],  
                                [KilosTara],  
                                [Tarimas],  
                                [Sello],  
                                [EjeTransporte],  
                                [AgenciaAduanal],  
                                [Observaciones],  
                                [ImporteRemisionado])  
		--EXEC PloConsultarTraspasoProc @pnVersion,@pnClaUbicacion,@FechaInicial,@FechaFinal,@pnClaArticulo,@psEstatus,@psNomIsoIdioma  
        EXEC [OpeSch].[OPE_CU444_Pag44_Traspaso_Sel] @pnClaUbicacion,@FechaInicial,@FechaFinal,@pnClaArticulo,@psEstatus,@psNomIsoIdioma, @pnNumIni, @pnNumFin, @pnClaOrigen
            
		IF @pnDebug = 1
			SELECT 2, 'OPE_CU444_Pag44_Traspaso_Sel', * FROM #Traspaso
 
		INSERT INTO #TraspRecibir (ClaOrigen,Origen,ClaUbicacionDestino, Destino, FechaMovimiento, NumViaje, EstatusTransito, Estatus,   
                                                            ClaArticulo, NomArticulo, CantidadEnviada, CantidadRecibida, CantidadCancelada, CantidadTransito,   
                                                            CantidadDepurada, KilosPesados, KilosTeoricos, KilosEnviados, KilosRecibidos, KilosTransito, PesoTeorico,   
                                                            PesoEntrada, PesoNeto, PesoSalida, PesoTara, CampoEntero4, CampoTexto1, FechaHoraMovimientoEntrada,   
                                                            ClaTransporte, ClaTransportista, Placas, NombreChofer, ClaveMovimiento, NomTransportista, Caja, Remision,   
                                                            ClaveRemision, IdFabricacion, IdFabricacionDet, KilosTara, Tarimas, Sello, EjeTransporte, AgenciaAduanal,   
                                                            Observaciones, NumericoExtra5, tipo )  
		SELECT ClaOrigen, Origen, ClaDestino, Destino, FechaMovimiento, ViajeOriginal, EstatusTransito, Estatus,   
                        ClaArticulo, NomArticulo, CantidadEnviada, CantidadRecibida, CantidadCancelada, CantidadTransito,   
                        CantidadDepurada, KilosPesados, KilosTeoricos, KilosEnviados, KilosRecibidos, KilosTransito, PesoTeorico,
   
                        PesoEntrada, PesoNeto, PesoSalida, PesoTara, CampoEntero4, CampoTexto1, FechaHoraMovimientoEntrada,   
                        ClaTransporte, ClaTransportista, Placas, NombreChofer, ClaveMovimiento, NomTransportista, Caja, ClaRemision,   
                        ClaveRemision, IdFabricacion, IdFabricacionDet, KilosTara, Tarimas, Sello, EjeTransporte, AgenciaAduanal,   
                        Observaciones, ImporteRemisionado, 2   
		FROM	#Traspaso  
			
		IF @pnDebug = 1
			SELECT 3, * FROM #TraspRecibir
			 
	END  
  
    ALTER TABLE #TraspRecibir ADD EsCompraFilial TINYINT  
	 
	--Obtiene Fabricacion del Cliente y su estatus 
	UPDATE	#TraspRecibir 
	SET		IdFabricacionCliente = t2.IdFabricacionCliente,    
			ClaEstatus = t3.ClaEstatus  
	FROM	#TraspRecibir t1   
	LEFT JOIN PloSch.PloTraFabInterUbicacion t2 WITH(NOLOCK) 
	ON		t2.ClaEstatus = 2 AND  
			t2.idfabricacion = t1.idfabricacion AND  
			t2.claUbicacion = @pnClaUbicacion              
	INNER JOIN OpeSch.OpeTraFabricacionVw t3 WITH(NOLOCK) 
	ON		t2.IdFabricacionCliente = t3.idfabricacion  

	IF @pnDebug = 1
		SELECT 4, 'Cliente-Estatus', * FROM #TraspRecibir
  
	UPDATE  #TraspRecibir  
	SET     EsCompraFilial = 0  
	
	UPDATE  #TraspRecibir  
	SET     EsCompraFilial = 1  
	WHERE	ClaveRemision IS NOT NULL  
	
	UPDATE  #TraspRecibir  
	SET     EsCompraFilial = 1  
	WHERE   ClaUbicacionDestino = @pnClaUbicacion AND  
			NumViaje IN (	SELECT	NumViaje   
							FROM	#TraspRecibir  
							WHERE	EsCompraFilial = 1 AND  
									ClaUbicacionDestino = @pnClaUbicacion	)

	IF @pnDebug = 1
		SELECT 5, '#TraspRecibir', * FROM #TraspRecibir

	UPDATE  #TraspRecibir  
    SET     ClaTransportista = NULL  
    
	--Actualizar ClaTransportista con NumTransportista, resolverlo con el nombre  
    UPDATE  #TraspRecibir  
    SET     ClaTransportista = t2.NumTransportista  
    FROM    #TraspRecibir t1  
    INNER JOIN FleCatTransportistaVw t2(nolock) 
	ON		t2.ClaUbicacion = @pnClaUbicacion AND  
			LTRIM(RTRIM(t2.Nombre)) LIKE '%' + LTRIM(RTRIM(t1.NomTransportista)) + '%' AND   
			t2.BajaLogica = 0  
  
	IF @pnDebug = 1
		SELECT 6, 'Transportista', * FROM #TraspRecibir
  
	CREATE TABLE #tmpMovEntSal (ClaUbicacion INT,IdBoleta INT,IdEntSal INT)  
  
    INSERT	INTO  #tmpMovEntSal  
    SELECT	mov.ClaUbicacion  
            ,mov.IdBoleta  
            ,mov.IdEntSal  
	FROM	#TraspRecibir trasp   
    LEFT JOIN OpeSch.OpeTraRecepTraspaso recep (NOLOCK)      
	ON      recep.IdViajeOrigen=trasp.NumViaje   
    AND     recep.ClaUbicacionOrigen=trasp.ClaOrigen   
    AND     recep.ClaUbicacion= @pnClaUbicacion  
    LEFT JOIN OpeSch.OpeTraMovEntSal  mov (NOLOCK) 
	ON		mov.ClaUbicacion=@pnClaUbicacion   
    AND     mov.IdBoleta=recep.idBoleta  
    INNER JOIN  @tbEstatus estatus                           
	ON		1 = 1   
    WHERE	CASE WHEN recep.ClaEstatus IS NULL THEN 0 ELSE recep.ClaEstatus END = estatus.numEstatus AND  
			trasp.ClaOrigen = isnull(@pnClaOrigen,trasp.ClaOrigen) AND 
            (isnull(@pnClaArticulo,-1)<0 or trasp.ClaArticulo=@pnClaArticulo) AND  
                    (  
                    ( @pnVerPor =1 AND trasp.Remision BETWEEN @pnNumIni AND @pnNumFin ) OR  
                    (@pnVerPor =2 AND (trasp.NumViaje>= @pnNumIni AND trasp.NumViaje<=@pnNumFin) ) OR  
                    (@pnVerPor=0)  
                      )  
  
	IF @pnDebug = 1
		SELECT 7, 'MovEntSal', * FROM #tmpMovEntSal 
  
	--Se quitan los traspasos a plantas vecinas que como quiera sí están registran en tránsito lo cual no debería.  
    DELETE	FROM #TraspRecibir   
    WHERE	EXISTS (	SELECT	1  
						FROM	PloSch.PloTraTraspasoVecino B  WITH(NOLOCK)  
						WHERE	B.ClaUbicacionOrigen = #TraspRecibir.ClaOrigen AND   
								B.ClaUbicacionDestino = #TraspRecibir.ClaUbicacionDestino AND   
								B.IdEntSalOrigen = #TraspRecibir.Remision	) 
							
	IF @pnDebug = 1
		SELECT 8, 'Delete', * FROM #tmpMovEntSal 
  
	SELECT	ClaUbicacion, ClaUbicacionOrigen, IdViajeOrigen, SUM(rtp.PesoRemisionado) AS PesoRemisionado  
    INTO	#PloTraRecepTraspasoProd  
    FROM	(SELECT DISTINCT NumViaje, ClaOrigen, ClaUbicacionDestino FROM #TraspRecibir) t1  
    INNER JOIN OpeSch.OpeTraRecepTraspasoProd rtp(NOLOCK)  
    ON		rtp.IdViajeOrigen=t1.NumViaje AND    
            rtp.ClaUbicacionOrigen=t1.ClaOrigen AND    
            rtp.ClaUbicacion=@pnClaUbicacion   
	GROUP BY ClaUbicacion, ClaUbicacionOrigen, IdViajeOrigen  
  
  	IF @pnDebug = 1
		SELECT 9, '#PloTraRecepTraspasoProd', * FROM #PloTraRecepTraspasoProd   
			         
	SELECT	CAST(0 as bit) as Inc,
			t1.Origen as NomOrigen,
			t1.NumViaje,
			t1.Placas,
			t1.FechaMovimiento,  
            COALESCE(T6.FechaHoraEntrada,his.FechaHoraEntrada,t1.FechaHoraMovimientoEntrada) AS FechaHoraMovimientoEntrada,  
            --t1.FechaHoraMovimientoEntrada,  
            CASE WHEN t3.ClaEstatus IS NULL THEN 0 ELSE t3.ClaEstatus END AS ClaEstatus,  
			--CASE WHEN t4.NombreEstatus IS NULL THEN 'En Tránsito' ELSE t4.NombreEstatus END AS NombreEstatus,  
            t4.NombreEstatus,   
            t1.Caja,  
            --ISNULL(t1.ClaveRemision, t1.Remision) AS Remision,  
            ISNULL( (	CASE
                            WHEN    t1.ClaveRemision IS NOT NULL AND ISNUMERIC(t1.ClaveRemision) = 0 AND T11.ClaTipoUbicacion = 2 --Acerias
                            THEN    t1.ClaveRemision
                            WHEN    ISNUMERIC(t1.ClaveRemision) = 1 AND t1.ClaveRemision IS NOT NULL AND T11.ClaTipoUbicacion = 2 --Acerias
                            THEN    T12.prefijostr + 
                                    SUBSTRING(  CONVERT(VARCHAR,t1.ClaveRemision), 
                                                PATINDEX('%' + CONVERT(VARCHAR, T12.claPrefijo) + '%',   CONVERT(VARCHAR, t1.ClaveRemision)) + LEN(T12.claPrefijo),
                                                LEN(t1.ClaveRemision) ) 
                            ELSE    (	SELECT  TOP 1
												es.IdFacturaAlfanumerico
										FROM    DEAOFINET04.Operacion.PloSch.PloTraMovEntSal es
										WHERE   es.ClaUbicacion = t1.ClaOrigen
                                        AND     es.IdViaje = t1.NumViaje
										AND		es.IdFabricacion = t1.IdFabricacion)
                        END ), ISNULL(t1.ClaveRemision, t1.Remision) ) AS Remision,  
            t1.IdFabricacion,
			t1.IdFabricacionDet,
			t1.ClaArticulo,
			t2.ClaveArticulo,  
            (CASE WHEN @psNomIsoIdioma = @NomIsoIdiomaIngles THEN t2.NomArticuloIngles  
                  WHEN @psNomIsoIdioma = @NomIsoIdiomaOtro THEN t2.NomArticuloOtroIdioma  
				  ELSE t2.NomArticulo END) AS NomArticulo,  
            t8.NomUnidad,    
            SUM(t1.CantidadEnviada) as CantidadEnviada, -- FP 296245 Se le agrega el SUM ya que existe una diferencia en los datos que arroja sin este SUM      
            SUM(t1.KilosEnviados) as KilosEnviados,-- FP 296545 Se agrega sum ya que estaba sumando datos duplicados, kilos enviados del transito
            t1.ClaTransporte,  
            t1.ClaTransportista,  
            ClaOrigen as Origen,  
            KilosTara,ClaveRemision,ISNULL(t3.IdBoleta,-1) AS IdBoleta,  
			CASE WHEN (CASE WHEN t3.ClaEstatus IS NULL THEN 0 ELSE t3.ClaEstatus END)=2 THEN  T5.PesoRemisionado else null end as PesoDocumentado,    
            t1.PesoTara,  
            t6.PesoEntrada,  
            t1.NomTransportista,  
            t1.NombreChofer  as NomChofer,  
            NULL AS NomJefeEmbarque,  
            t1.Sello,  
            (SELECT TOP 1 AA.IdEntSal FROM #tmpMovEntSal/*PloTraMovEntSal*/ AA WITH(NOLOCK) WHERE AA.ClaUbicacion = @pnClaUbicacion AND AA.IdBoleta = t3.IdBoleta) AS IdEntSal, --t7.IdEntSal,  
            t1.Observaciones,  
            t1.Tarimas,  
            t3.HrLiberacion,  
            his.FechaHoraSalida AS HrFinDescarga,  
            --CASE WHEN T10.IdFabricacion IS NOT NULL THEN 1 ELSE 0 END AS esFactVirtual,  
			CASE WHEN T10.IdFabricacionCliente IS NOT NULL THEN 1 ELSE 0 END   AS esFactVirtual,  
            --t10.IdFabricacionCliente,  
            t1.IdFabricacionCliente,  
            --t1.IdFabricacion,  
            t2.PesoTeoricoKgs,  
            t1.ClaEstatus AS ClaEstatusFabricacion, t1.EsCompraFilial  
	INTO	#tmpR  
    FROM	#TraspRecibir t1 /*WITH (NOLOCK)*/  
    INNER JOIN ArtCatArticuloVw t2 (NOLOCK)  
	ON		t2.Claarticulo=t1.ClaArticulo AND  
			t2.ClaTipoInventario=@pnTipoInventario  
    LEFT JOIN OpeSch.OpeTraRecepTraspaso  t3 (NOLOCK) 
	ON		t3.IdViajeOrigen=t1.NumViaje AND  
			t3.ClaUbicacionOrigen=t1.ClaOrigen AND  
			t3.ClaUbicacion= @pnClaUbicacion    
	LEFT JOIN OpeSch.OpeTiCatestatusVw T4 (NOLOCK) 
	ON		T4.CLACLASIFICACIONESTATUS=1270007 AND  
            T4.CLAESTATUS=CASE WHEN t3.ClaEstatus IS NULL THEN 0 ELSE t3.ClaEstatus END   
    LEFT JOIN #PloTraRecepTraspasoProd T5 (NOLOCK) 
	ON		T5.IdViajeOrigen=t1.NumViaje AND  
			T5.ClaUbicacionOrigen=t1.ClaOrigen AND  
			T5.ClaUbicacion=@pnClaUbicacion  
    LEFT JOIN OpeSch.OpeTraBoleta T6 (NOLOCK) 
	ON      T6.ClaUbicacion=@pnClaUbicacion AND  
			T6.IdBoleta=t3.IdBoleta             
    --LEFT JOIN PloTraMovEntSal T7 (NOLOCK) ON  
    --     t7.ClaUbicacion=@pnClaUbicacion AND  
    --     t7.IdBoleta=t3.idBoleta  
    LEFT JOIN OpeSch.OpeTraBoletaHis his (NOLOCK) 
	ON		his.ClaUbicacion=@pnClaUbicacion AND  
			his.IdBoleta=t3.IdBoleta            
    INNER JOIN  OpeSch.OpeArtCatUnidadVw T8 (NOLOCK) 
	ON      t8.ClaTipoInventario=@pnTipoInventario AND       
			t8.ClaUnidad=t2.ClaUnidadBase  
    INNER JOIN  @tbEstatus t9 /*WITH (NOLOCK)*/  
	ON		1 = 1  
    LEFT JOIN PloSch.PloTraFabInterUbicacion T10 (NOLOCK) 
	ON		T10.IdFabricacion=t1.IdFabricacion AND  
			T10.ClaUbicacion=@pnClaUbicacion  
--           LEFT JOIN PloTraFabricacionVw t11 WITH(NOLOCK) ON   
--                  t11.ObservacionParaEmbarque LIKE '<<fabesp%' + convert(VARCHAR(20), t1.IdFabricacion) + '%'    
--              --t11.IdFabricacion = t1.IdFabricacion  
    --INNER JOIN PloCfgClienteFilial T12 WITH(NOLOCK) ON   
    --     T12.ClaUbicacionOrigen = @pnClaUbicacion AND   
    --     T12.ClaUbicacionDestino = t1.ClaOrigen AND   
    --     T12.BajaLogica = 0  
	INNER JOIN OpeSch.OpeTiCatUbicacionVw T11 WITH(NOLOCK) 
	ON		t1.ClaOrigen = T11.ClaUbicacion
	LEFT JOIN FleSch.FleVtaCatPrefijoFactura T12 WITH(NOLOCK)
	ON		T11.ClaEmpresa = T12.ClaEmpresa AND
			T11.ClaUbicacionVentas = T12.ClaUbicacion
    WHERE   CASE WHEN t3.ClaEstatus IS NULL THEN 0 ELSE t3.ClaEstatus END=t9.numEstatus AND  
			t1.ClaOrigen = isnull(@pnClaOrigen,t1.ClaOrigen) AND  
            (isnull(@pnClaArticulo,-1)<0 or t1.ClaArticulo=@pnClaArticulo) AND  
                    (  
                    ( @pnVerPor =1 AND t1.Remision BETWEEN @pnNumIni AND @pnNumFin ) OR  
                    (@pnVerPor =2 AND (t1.NumViaje>= @pnNumIni AND t1.NumViaje<=@pnNumFin) ) OR  
                    (@pnVerPor=0)  
                      )  AND --VEHA  
                    ((t1.Tipo IS NULL AND ISNULL(his.ClaEstatusPlaca,-1)<>6) OR (t1.Tipo=2)) --VEHA  
	GROUP BY T11.ClaTipoUbicacion, t1.Origen,t1.NumViaje,t1.Placas,t1.FechaMovimiento,T6.FechaHoraEntrada,his.FechaHoraEntrada,t1.FechaHoraMovimientoEntrada,t3.ClaEstatus,t4.NombreEstatus,t1.Caja,t1.Remision,  
             t1.IdFabricacion,t1.IdFabricacionDet,T10.IdFabricacion,t1.ClaArticulo,t2.ClaveArticulo,t2.NomArticuloIngles,t2.NomArticuloOtroIdioma,t2.NomArticulo,    
             t1.CantidadEnviada,t1.KilosEnviados,t1.ClaTransporte,t1.ClaTransportista,ClaOrigen,KilosTara,ClaveRemision, T12.prefijostr, T12.claPrefijo, NombreChofer,t3.IdBoleta,t6.PesoEntrada,t1.NomTransportista,t1.NombreChofer,t1.Sello,  
             t1.Observaciones,t1.Tarimas,t3.HrFinDescarga,t3.HrLiberacion,t8.NomUnidad,his.FechaHoraSalida,t2.PesoTeoricoKgs,t1.IdFabricacionCliente, t1.IdFabricacion, t1.ClaEstatus,  
			 t1.EsCompraFilial,T10.IdFabricacionCliente, t1.PesoTara , T5.PesoRemisionado--, NombreCliente  
	ORDER BY t3.ClaEstatus,t1.NumViaje,t1.Placas 
	   
	IF @pnDebug = 1
		SELECT 10, * FROM #tmpR 
  
	IF (@pnSoloEncabezado = 0)   
	BEGIN
       SELECT * FROM #tmpR  
	END  
	ELSE  
	BEGIN
		SELECT  
				EspejoManual		= 0,
				DarEntrada          = CASE WHEN a.ClaEstatus = 0 THEN '<img src= "/Common/Images/WebToolImages/Truck24.png"/>' ELSE '' END,  
                ImpOrdenDescarga    = CASE WHEN a.ClaEstatus > 0 THEN '<img src= "/Common/Images/WebToolImages/Montacargas24.png"/>' ELSE '' END,  
                ImpInvoice          = '<img src= "/Common/Images/WebToolImages/File24.png"/>',  
                lnkFacturar         = CASE WHEN ISNULL(b.IdPlanCarga,0) > 0  THEN '<img src= "/Common/Images/WebToolImages/Dinero24.png"/>' ELSE '' END,  
                b.IdPlanCarga,  
				NomEstatusPC = CASE WHEN ISNULL(b.IdPlanCarga,0) > 0 THEN EST.NombreEstatus ELSE '' END,
				Origen,   NomOrigen,   NumViaje,   
                Remisiones          = STUFF((	SELECT	', ' + st.Remision
                                                FROM	#tmpR st
                                                WHERE	st.Origen	= a.Origen
                                                AND     st.NumViaje	= a.NumViaje												
                                                GROUP BY
                                                        st.Remision
                                                FOR XML PATH ('')
                                                ), 1, 1, ''),  
                Placas,   FechaMovimiento,   FechaHoraMovimientoEntrada,   a.ClaEstatus,  a.NombreEstatus,   Caja,   a.ClaTransporte,   a.ClaTransportista,   
				NomTransportista,   NomChofer,   NomJefeEmbarque,  Sello,   IdEntSal,   Observaciones,  a.IdBoleta,  
                KilosEnviados       = SUM(KilosEnviados), 
                NombreCliente,		HrFinDescarga, KilosEmbarcadosVirtual = (	SELECT SUM(PesoEmbarcado)
																				FROM OpeSch.OpeTraPlanCargaDet CarDet
																				WHERE CarDet.ClaUbicacion = @pnClaUbicacion
																				AND CarDet.IdPlanCarga = b.IdPlanCarga
																			)
		INTO #tblFinal
        FROM    #tmpR a  
            LEFT JOIN OpeSch.OpeRelPlanCargaViajeVirtual b WITH(NOLOCK)			ON  a.NumViaje = b.IdViajeOrigen AND a.Origen = b.ClaUbicacionOrigen
            LEFT JOIN OpeSch.OpeTraNumeroFabricacionEspejoVw ES WITH(NOLOCK)	ON  (ES.ClaUbicacion   = @pnClaUbicacion  AND ES.ClaFabricacionEspejo = a.IdFabricacion)  
            LEFT JOIN OpeSch.OpeTraFabricaciocionEquivBodVirt FE WITH(NOLOCK)   ON  (FE.ClaUbicacion   = @pnClaUbicacion  AND FE.ClaFabricacionEspejo = a.IdFabricacion)  
            INNER JOIN OpeSch.OpeTraFabricacionVw Fab WITH(NOLOCK)              ON  (Fab.IdFabricacion   = ISNULL(FE.ClaFabricacion, ES.ClaFabricacion))                           
            LEFT JOIN OpeSch.OPEVtaCatClienteVw cli WITH(NOLOCK)                ON  (Fab.ClaCliente    = cli.ClaCliente)
			LEFT JOIN OpeSch.OpeTraPlanCarga PC WITH(NOLOCK)					ON	(PC.ClaUbicacion = b.ClaUbicacion AND PC.IdPlanCarga = b.IdPlanCarga)
			LEFT JOIN OpeSch.OpeTiCatestatusVw Est WITH(NOLOCK)					ON	(EST.ClaClasificacionEstatus = 1270002 AND PC.ClaEstatusPlanCarga = EST.ClaEstatus)
			--LEFT JOIN OpeSch.OpeTraPlanCargaDet CarDet WITH(NOLOCK)				ON	(CarDet.ClaUbicacion = @pnClaUbicacion AND CarDet.IdPlanCarga = b.IdPlanCarga) --Descomentar esta tabla para conectarla a OpeSch.OpeTraFabricacionVw y sacar el EsPesoNorma
		WHERE fab.IdFabricacion IS NOT NULL
        GROUP BY    Origen, NomOrigen, NumViaje, Placas, FechaMovimiento, FechaHoraMovimientoEntrada,HrFinDescarga, a.ClaEstatus,  
                    a.NombreEstatus, Caja, a.ClaTransporte, a.ClaTransportista, NomTransportista, NomChofer, NomJefeEmbarque,  
                    Sello, IdEntSal, Observaciones, a.IdBoleta, b.IdPlanCarga, EST.NombreEstatus, NombreCliente
  
	   UNION

			SELECT
				EspejoManual = 1,
				DarEntrada   = CASE WHEN a.ClaEstatus = 0 THEN '...' ELSE '' END,
                ImpOrdenDescarga    = '',  
                ImpInvoice          = '',  
                lnkFacturar         = '',  
                b.IdPlanCarga, 
				NomEstatusPC = CASE WHEN ISNULL(b.IdPlanCarga,0) > 0 THEN EST.NombreEstatus ELSE '' END,
				Origen,   NomOrigen,   NumViaje,   
                Remisiones          = STUFF((	SELECT	', ' + st.Remision
                                                FROM	#tmpR st
                                                WHERE	st.Origen	= a.Origen
                                                AND     st.NumViaje	= a.NumViaje												
                                                GROUP BY
                                                        st.Remision
                                                FOR XML PATH ('')
                                                ), 1, 1, ''),  
                Placas,   FechaMovimiento,   FechaHoraMovimientoEntrada,   a.ClaEstatus,  a.NombreEstatus,   Caja,   a.ClaTransporte,   a.ClaTransportista,   
				NomTransportista,   NomChofer,   NomJefeEmbarque,  Sello,   IdEntSal,   Observaciones,  a.IdBoleta,  
                KilosEnviados       = SUM(KilosEnviados), 
                /*Probar concatenar*/NombreCliente,		HrFinDescarga, KilosEmbarcadosVirtual = (	SELECT SUM(PesoEmbarcado)
																				FROM OpeSch.OpeTraPlanCargaDet CarDet
																				WHERE CarDet.ClaUbicacion = @pnClaUbicacion
																				AND CarDet.IdPlanCarga = b.IdPlanCarga
																			)
        FROM    #tmpR a  
            LEFT JOIN OpeSch.OpeRelPlanCargaViajeVirtual b (NOLOCK)             ON  (a.NumViaje = b.IdViajeOrigen AND a.Origen = b.ClaUbicacionOrigen AND b.ClaUbicacion = @pnClaUbicacion)
            LEFT JOIN OpeSch.OpeTraNumeroFabricacionEspejoVw ES WITH(NOLOCK)	ON  (ES.ClaUbicacion   = @pnClaUbicacion  AND ES.ClaFabricacionEspejo = a.IdFabricacion)  
            LEFT JOIN OpeSch.OpeTraFabricaciocionEquivBodVirt FE WITH(NOLOCK)   ON  (FE.ClaUbicacion   = @pnClaUbicacion  AND FE.ClaFabricacionEspejo = a.IdFabricacion)  
            LEFT JOIN OpeSch.OpeTraFabricacionVw Fab WITH(NOLOCK)				ON  (Fab.IdFabricacion   = ISNULL(FE.ClaFabricacion, ES.ClaFabricacion))         
            LEFT JOIN OpeSch.OPEVtaCatClienteVw cli WITH(NOLOCK)                ON  (Fab.ClaCliente    = cli.ClaCliente)
			LEFT JOIN OpeSch.OpeTraPlanCarga PC WITH(NOLOCK)					ON	(PC.ClaUbicacion = b.ClaUbicacion AND PC.IdPlanCarga = b.IdPlanCarga)
			LEFT JOIN OpeSch.OpeTiCatestatusVw Est WITH(NOLOCK)					ON	(EST.ClaClasificacionEstatus = 1270002 AND PC.ClaEstatusPlanCarga = EST.ClaEstatus)
			LEFT JOIN OpeSch.OpeTraPlanCargaDet CarDet WITH(NOLOCK)				ON	(CarDet.ClaUbicacion = @pnClaUbicacion AND CarDet.IdPlanCarga = b.IdPlanCarga) --Agregar a la parte de arriba
		WHERE Fab.IdFabricacion IS NULL
        GROUP BY    Origen, NomOrigen, NumViaje, Placas, FechaMovimiento, FechaHoraMovimientoEntrada,HrFinDescarga, a.ClaEstatus,  
                    a.NombreEstatus, Caja, a.ClaTransporte, a.ClaTransportista, NomTransportista, NomChofer, NomJefeEmbarque,  
                    Sello, IdEntSal, Observaciones, a.IdBoleta, b.IdPlanCarga, EST.NombreEstatus, NombreCliente
       ORDER BY     ClaEstatus 

		IF @pnDebug = 1
		SELECT 20, '#tblFinal', * FROM #tblFinal

	   UPDATE a
	   set		DarEntrada   = '',  
                ImpOrdenDescarga    = '',  
                ImpInvoice          = '',  
                lnkFacturar         = ''
		FROM #tblFinal a
		inner join #tblFinal b
		on b.origen = a.origen and b.numviaje = a.numviaje
		WHERE b.DarEntrada = ''

	   SELECT EspejoManual, DarEntrada, ImpOrdenDescarga, ImpInvoice, lnkFacturar, IdPlanCarga, NomEstatusPC, Origen, NomOrigen, NumViaje, Remisiones,	Placas, FechaMovimiento,
	   FechaHoraMovimientoEntrada, ClaEstatus, NombreEstatus, Caja, ClaTransporte, ClaTransportista, NomTransportista, NomChofer, NomJefeEmbarque,
	   Sello, IdEntSal, Observaciones, IdBoleta, SUM(KilosEnviados) AS KilosEnviados, KilosEmbarcadosVirtual,
	   NombreCliente = STUFF((	SELECT ', ' + c.NombreCliente
								FROM #tblFinal c
								WHERE c.Origen = a.Origen
								AND c.NumViaje = a.NumViaje
								GROUP BY c.NombreCliente
								FOR XML PATH ('')), 1, 1, ''),
	   HrFinDescarga , RemEst = null
	   INTO #tblFinal2
	   FROM #tblFinal a
	   GROUP BY
	   EspejoManual, DarEntrada, ImpOrdenDescarga, ImpInvoice, lnkFacturar, IdPlanCarga, NomEstatusPC, Origen, NomOrigen, NumViaje, Remisiones,	Placas, FechaMovimiento,
	   FechaHoraMovimientoEntrada, ClaEstatus, NombreEstatus, Caja, ClaTransporte, ClaTransportista, NomTransportista, NomChofer, NomJefeEmbarque,
	   Sello, IdEntSal, Observaciones, IdBoleta, /*KilosEnviados, NombreCliente,*/ HrFinDescarga, KilosEmbarcadosVirtual
	   
	   IF @pnDebug = 1
		SELECT 21, '#tblFinal', * FROM #tblFinal
		
		IF ISNULL(@pnIdentificador, 0) = 0
		BEGIN
			SELECT EspejoManual, DarEntrada, ImpOrdenDescarga, ImpInvoice, lnkFacturar, IdPlanCarga, NomEstatusPC, Origen, NomOrigen, NumViaje, Remisiones, Placas, FechaMovimiento,
			FechaHoraMovimientoEntrada, ClaEstatus, NombreEstatus, Caja, ClaTransporte, ClaTransportista, NomTransportista, NomChofer, NomJefeEmbarque, Sello, IdEntSal, Observaciones,
			IdBoleta, KilosEnviados, NombreCliente,
			HrFinDescarga, RemEst, KilosEmbarcadosVirtual, (((KilosEmbarcadosVirtual/KilosEnviados)-1)*100) AS 'Rendimiento',
			lnkRemVen = IIF(IdPlanCarga is not null,'Ver',''),
			lnkAplPeNo = IIF(IdPlanCarga is not null,'Ver',''),
			lnkCerCal = IIF(IdPlanCarga is not null,'Ver','')

			FROM #TblFinal2
		END

		ELSE
		IF @pnIdentificador = 1
		BEGIN
			SELECT	DarEntrada, IdPlanCarga, NomEstatusPC, Origen, NomOrigen, NumViaje, Remisiones, Placas, FechaHoraMovimientoEntrada, ClaEstatus, NombreEstatus,
					ClaTransporte, NomChofer, KilosEnviados
			FROM #tblFinal2
		END

   END  
         
		DROP TABLE #TraspRecibir  
		DROP TABLE #tmpMovEntSal  
		DROP TABLE #Traspaso  
		DROP TABLE #tmpR  , #PloTraRecepTraspasoProd, #tblFinal, #tblFinal2
         
       fin:  
       SET NOCOUNT OFF  
END