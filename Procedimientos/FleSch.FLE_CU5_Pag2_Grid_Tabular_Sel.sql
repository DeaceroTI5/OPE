USE Operacion
GO
--EXEC SP_HELPTEXT 'FleSch.FLE_CU5_Pag2_Grid_Tabular_Sel'
GO
ALTER PROCEDURE FleSch.FLE_CU5_Pag2_Grid_Tabular_Sel            
 @pnClaUbicacion INT,            
 @pnIdTabular INT,            
 @pnNumViaje INT,            
 @psNumBoleta VARCHAR(50),            
 @pnNumPedido INT,             
 @psNumFactura VARCHAR(50) ,            
 @pnClaTipoTabular INT,            
 @pnClaTipoBoleta INT,            
 @pnClaEstatusTabular INT,             
 @pnClaGrupoTransporte INT,            
 @pnClaTransporte INT,            
 @pnClaTransportista INT,            
 @pnEsConDiscrepancia TINYINT,            
 @pnClaCiudad INT,            
 @pnClaCiudad2 INT,            
 @pnClaTipoMaterial INT,            
 @pnClaTipoConvenio INT,             
 @pnClaAgregado INT,            
 @pnClaDeduccion INT,             
 @ptFechaInicial DATETIME,             
 @ptFechaFinal DATETIME,            
 @pnEsNinguno INT = 1,             
 @pnEsPorTabular INT,             
 @pnEsPorViaje INT,             
 @pnEsPorBoleta INT,             
 @pnEsPorPedido INT,               
 @pnEsPorFactura INT,             
 @psIdioma VARCHAR(10) = 'Spanish',            
 @pnClaIdioma INT = 5,            
 @pnIdFolio INT = NULL,            
 @pnEsPorFolio INT = 0            
AS            
BEGIN            
 SET NOCOUNT ON             
           
           
           
  DECLARE @sconexion VARCHAR (MAX),             
    @sComando  NVARCHAR(MAX)          
    --@nClaSistema INT,            
    --@nClaSistemaPol INT            
              
    DECLARE @cup int          
              
	--SET  @nClaSistema = [FleSch].[FleObtenerClaSistemaFletesFn]()              

	DECLARE @sClaveServicio VARCHAR(400)

	SELECT	@sClaveServicio = sValor1
	FROM	TiCatalogo.dbo.TiCatConfiguracionVw
	WHERE	ClaUbicacion	= @pnClaUbicacion 
	AND		ClaSistema		= 127 
	AND		ClaConfiguracion = 1271229

	CREATE TABLE #TmpClaveSerivio(
		ID					INT IDENTITY(1,1),
		ClaveServicio		INT
	)
	
	IF ISNULL(@sClaveServicio,'') <> ''
	BEGIN
		INSERT INTO #TmpClaveSerivio 
		SELECT DISTINCT LTRIM(RTRIM(string))
		FROM FleSch.FleUtiSplitStringFn(@sClaveServicio, ',')
	END	

              
      /*GCC 15MAr16        
  SELECT @nClaSistemaPol = nValor1 FROM FleSch.FleTiCatConfiguracionVw            
  WHERE ClaUbicacion = @pnClaUbicacion AND ClaConfiguracion = 211            
  */        
              
--  SELECT  @sconexion = [FleSch].[FleObtieneConexionRemotaFn](@pnClaUbicacion, @nClaSistemaPol, 'PolCTraTramiteVw' )            
              
    /*          
  si se especifica transportista, sacar el cup para obtener los dos trasportistas           
    */              
    CREATE TABLE #transportista (clatransportista int)          
    IF @pnClaTransportista IS NOT NULL          
    BEGIN          
  SELECT @cup = ftv.ClaCUP from FleSch.FLECatTransportistaVw ftv with (nolock)          
  WHERE ftv.ClaUbicacion = @pnClaUbicacion AND ftv.ClaTransportista = @pnClaTransportista          
            
  INSERT INTO #transportista(clatransportista)          
  SELECT clatransportista          
  from FleSch.FLECatTransportistaVw ftv with (nolock)          
  WHERE ftv.ClaUbicacion = @pnClaUbicacion           
  AND ftv.ClaCUP = @cup          
    END            
              
       /* GCC 15Mar16        
  SET @sComando =             
  'SELECT IdFolioTramiteLocal            
    ,ClaUbicacion            
    ,QuienEntregaCheque            
    ,ClaAgrupador            
    ,Concepto            
    ,ClaCuentaBancaria            
    ,ClaCUP            
    ,ClaBeneficiario            
    ,ClaDepartamentoContable            
    ,ClaDireccion            
    ,ClaEmpresa            
    ,EsChequeViajero            
    ,ClaEstatus            
    ,FechaElaboraTramite            
    ,FechaPagoReal            
    ,FechaPagoDeseada            
    ,ClaFormaPago            
    ,ImporteIVA            
    ,ImportePagar            
    ,ClaMoneda            
    ,NumeroCheque            
    ,FolioTramiteCentral            
    ,EsQuitaLeyendaBeneficiario            
    ,ReferenciaBancaria            
    ,ReferenciaNumerica            
    ,ClaSistemaOrigen            
    ,TipoCambio            
    ,ClaTipoReferencia            
    ,ClaTipoTramite            
    ,ClaTramitePasivo            
    ,ClaUsuarioAutoriza            
    ,ClaUsuarioElabora            
    ,ClaEstatusAutorizacion            
    ,ClaEstatusImpresionCheque           
    ,EsCalcularAmortizacion            
    ,IdentificadorFlujoAutorizacion            
    ,ClaPolizaGpo            
    ,ClaPolizaOrigen            
    ,ClaTipoPoliza            
    ,ClaPolizaContable            
    ,ClaTrabajador            
    ,ClaTipoPersona            
    ,ClaSistema            
    ,ClaUsuarioMod            
    ,FechaUltimaMod            
    ,NombrePcMod            
    ,ClaMonedaOrigen            
  from ' + @sconexion + ' WHERE ClaUbicacion= ' + CAST (@pnClaUbicacion as varchar (4)) + ' AND ISNULL(ClaPolizaContable,0)  > 0 AND ClaSistema = ' + CAST (@nClaSistema as varchar (4))            
         
            
    CREATE TABLE #PolCTraTramiteVw          
 (         
    IdFolioTramiteLocal INT ,            
    ClaUbicacion INT ,            
    QuienEntregaCheque VARCHAR(250) ,            
    ClaAgrupador INT ,            
    Concepto VARCHAR(250) ,            
    ClaCuentaBancaria INT ,            
    ClaCUP INT ,            
    ClaBeneficiario INT ,            
    ClaDepartamentoContable INT ,            
    ClaDireccion CHAR(4) ,            
    ClaEmpresa INT ,            
    EsChequeViajero INT ,            
    ClaEstatus INT ,            
    FechaElaboraTramite DATETIME ,            
    FechaPagoReal DATETIME ,            
    FechaPagoDeseada DATETIME ,            
    ClaFormaPago INT ,            
    ImporteIVA NUMERIC(19, 6) ,            
    ImportePagar NUMERIC(19, 6) ,            
    ClaMoneda INT ,            
    NumeroCheque VARCHAR(50) ,            
    FolioTramiteCentral INT ,            
    EsQuitaLeyendaBeneficiario INT ,            
    ReferenciaBancaria VARCHAR(20) ,            
    ReferenciaNumerica INT ,            
    ClaSistemaOrigen INT ,            
    TipoCambio NUMERIC(19, 6) ,            
    ClaTipoReferencia INT ,            
    ClaTipoTramite INT ,            
    ClaTramitePasivo INT ,            
    ClaUsuarioAutoriza INT ,            
    ClaUsuarioElabora INT ,            
    ClaEstatusAutorizacion INT ,            
    ClaEstatusImpresionCheque INT ,            
    EsCalcularAmortizacion INT ,            
   IdentificadorFlujoAutorizacion INT ,            
    ClaPolizaGpo INT ,            
    ClaPolizaOrigen INT ,            
    ClaTipoPoliza INT ,            
    ClaPolizaContable INT ,            
    ClaTrabajador INT ,            
    ClaTipoPersona INT ,            
    ClaSistema INT ,            
   ClaUsuarioMod INT ,            
    FechaUltimaMod DATETIME ,            
    NombrePcMod VARCHAR(64) ,            
    ClaMonedaOrigen INT            
  )            
          
            
  INSERT INTO #PolCTraTramiteVw (IdFolioTramiteLocal,ClaUbicacion,QuienEntregaCheque,ClaAgrupador ,            
    Concepto ,    ClaCuentaBancaria , ClaCUP ,      ClaBeneficiario  , ClaDepartamentoContable  ,            
    ClaDireccion  ,   ClaEmpresa  ,   EsChequeViajero,    ClaEstatus  ,  FechaElaboraTramite  ,            
    FechaPagoReal  ,   FechaPagoDeseada,  ClaFormaPago ,     ImporteIVA,   ImportePagar,            
    ClaMoneda,    NumeroCheque ,  FolioTramiteCentral,EsQuitaLeyendaBeneficiario,ReferenciaBancaria ,             
    ReferenciaNumerica ,ClaSistemaOrigen  , TipoCambio  ,  ClaTipoReferencia , ClaTipoTramite  ,            
    ClaTramitePasivo  , ClaUsuarioAutoriza  , ClaUsuarioElabora , ClaEstatusAutorizacion ,ClaEstatusImpresionCheque  ,            
    EsCalcularAmortizacion, IdentificadorFlujoAutorizacion  ,ClaPolizaGpo  , ClaPolizaOrigen  ,ClaTipoPoliza  ,            
    ClaPolizaContable  ,ClaTrabajador  ,  ClaTipoPersona  , ClaSistema  ,  ClaUsuarioMod  ,            
    FechaUltimaMod ,   NombrePcMod  ,  ClaMonedaOrigen             
  )            
  EXEC (@sComando)          
  */          
            
   DECLARE @nValor1 INT,           
   @nImporteAutopistas NUMERIC(22,8),          
 @EsCentral INT  
 SELECT @EsCentral = 0          
 SELECT @nImporteAutopistas = 0.0          
 SELECT @EsCentral = ISNULL(nValor1,0)           
 FROM flesch.FleTiCatConfiguracionVw WITH (NOLOCK)          
 WHERE ClaUbicacion = @pnClaUbicacion AND ClaSistema = 10 AND ClaConfiguracion = 223        
           
 IF ISNULL(@EsCentral,0) = 1           
 BEGIN          
  --ES CENTRAL   
  SELECT @nImporteAutopistas = SUM(Importe)            
  FROM FleSch.FleTraTabularConceptoVw WITH (NOLOCK)          
  WHERE ClaUbicacion = @pnClaUbicacion AND IdTabular = @pnIdTabular   AND  ClaConcepto  = 17          
              
 END           
               
 SELECT  t0.ClaUbicacion AS ClaUbicacion            
   ,t0.IdTabular AS IdTabular      
   ,t0.IdTabularOTM            
   ,t0.ClaTipoTabular AS ClaTipoTabular            
   ,CASE WHEN t0.ClaTipoTabular in (1,3) THEN t0.Referencia1 ELSE NULL END AS NumViaje            
   ,CASE WHEN t0.ClaTipoTabular in (1,3) THEN (SELECT NumOrdenCarga FROM FleSch.FleTraViaje v(NOLOCK) WHERE v.ClaUbicacion = t0.ClaUbicacion AND CONVERT(VARCHAR,v.NumViaje) = t0.Referencia1) ELSE NULL END AS NumOrdenCarga      
   ,CASE WHEN t0.ClaTipoTabular = 2 THEN t0.Referencia1 ELSE NULL END AS NumBoleta            
   ,CASE WHEN t0.ClaTipoTabular = 3 THEN t0.Referencia2 ELSE NULL END AS NumReexpedicion            
   ,t0.ClaTipoBoleta AS ClaTipoBoleta            
   ,t0.NumGuia AS NumGuia            
   ,t0.ClaUbicacionConvenio AS ClaUbicacionConvenio            
   ,t0.IdConvenio AS IdConvenio            
   ,t0.NumVersionConvenio AS NumVersion            
   ,t0.ClaMoneda AS ClaMoneda            
   ,t0.ClaCiudadOrigen AS ClaCiudadOrigen            
   ,t0.ClaCiudadDestino AS ClaCiudadDestino            
   ,t0.ClaZipCodeOrigen AS ClaZipCodeOrigen            
   ,t0.ClaZipCodeDestino AS ClaZipCodeDestino       
   ,PODDigital =case [FleSch].[FlePODDigitalPendienteFn](t0.ClaUbicacion,t0.IdTabular)          
         when 2 then 'POD Faltante'          
         when 1 then 'POD Completo'          
         else ''          
        end             
   ,IdTramitePasivo = ISNULL(CxPViaje.IdTramitePasivoConta, CxPBoleta.IdTramitePasivoConta)      
   ,IdTramitePago = CxPTabular.IdTramiteConta            
   --,t0.IdTramitePago AS IdTramitePago   
   --,t0.IdTramitePasivo AS IdTramitePasivo             
   ,t0.EsConDiscrepancia AS EsConDiscrepancia            
   ,t0.ClaGrupoTransporte AS ClaGrupoTransporte            
   ,t0.ClaTransporte AS ClaTransporte            
   ,t0.ClaTransportista AS ClaTransportista            
   ,t0.ClaTipoMaterialFfcc AS ClaTipoMaterialFfcc            
   ,t0.EsManiobrasCarga AS EsManiobrasCarga            
   ,t0.EsManiobrasDescarga AS EsManiobrasDescarga            
   ,t0.EsManiobrasCargaOriginal AS EsManiobrasCargaOriginal            
   ,t0.EsManiobrasDescargaOriginal AS EsManiobrasDescargaOriginal            
   ,t0.NumRepartosTotales AS NumRepartosTotales            
   ,t0.NumRepartosPagados AS NumRepartosPagados            
   ,t0.EficienciaCarga AS EficienciaCarga            
   ,t0.EficienciaFalso AS EficienciaFalso            
   ,t0.EficienciaViaje AS EficienciaViaje            
   ,t0.KgsReal/1000 AS KgsReal            
   ,t0.KgsCubicado/1000 AS KgsCubicado            
   ,t0.KgsConvenido/1000 AS KgsConvenido            
   ,t0.KgsPagar/1000 AS KgsPagar            
   ,t0.KmsReal AS KmsReal            
   ,t0.KmsConvenido AS KmsConvenido            
   ,t0.KmsPagar AS KmsPagar            
   ,t0.CuotaCostoBase AS CuotaCostoBase            
   ,t0.ImporteCostoBase AS ImporteCostoBase            
   ,t0.ImporteRepartos AS ImporteRepartos            
   ,t0.ImporteManiobrasCarga AS ImporteManiobrasCarga            
   ,t0.ImporteManiobrasDescarga AS ImporteManiobrasDescarga            
   ,t0.ImporteTramoMontanoso AS ImporteTramoMontanoso            
   ,t0.ImporteTransbordo AS ImporteTransbordo            
   ,t0.PorcFuelSurcharge AS PorcFuelSurcharge            
   ,t0.CuotaPorMillaFuelSurcharge AS CuotaPorMillaFuelSurcharge            
   ,t0.ImporteFuelSurcharge AS ImporteFuelSurcharge            
   ,t0.ImporteConvenio AS ImporteConvenio            
   ,t0.ImporteConvenioOriginal AS ImporteConvenioOriginal            
   ,isnull(t0.ImporteTotalAgregadosAfectaFlete,0) + isnull(t0.ImporteTotalAgregadosNoAfectaFlete,0) AS ImporteAgregados            
   ,isnull(t0.ImporteTotalDeduccionesAfectaFlete,0) + isnull(t0.ImporteTotalDeduccionesNoAfectaFlete,0) AS ImporteDeducciones            
   ,t0.PorcDescCarroPrivado AS PorcDescCarroPrivado            
   ,t0.ImporteDescCarroPrivado AS ImporteDescCarroPrivado            
   ,t0.PorcDPPP AS PorcDPPP            
   ,t0.ImporteDPPP AS ImporteDPPP            
   ,t0.PorcDPPPOriginal AS PorcDPPPOriginal            
   ,t0.ImporteMonitoreo AS ImporteMonitoreo        
   ,t0.ImporteEquipo AS ImporteEquipo        
   ,t0.ImporteDPPPOriginal AS ImporteDPPPOriginal            
   ,t0.PorcIVA AS PorcIVA            
   ,t0.ImporteIVA AS ImporteIVA            
   ,t0.PorcRetencion AS PorcRetencion            
   ,t0.ImporteRetencion AS ImporteRetencion            
   ,t0.ImporteSubtotal AS ImporteSubtotal            
   ,t0.ImporteSinIVA AS ImporteSinIVA            
   ,t0.ImporteConIVA AS ImporteConIVA            
   ,t0.ImporteConRetencionIVA AS ImporteConRetencionIVA            
   ,t0.ImportePagarFinal AS ImportePagarFinal            
   ,t0.MontoTonCubicadas AS MontoTonCubicadas            
   ,t0.MontoKm AS MontoKm            
   ,t0.MontoTonReales AS MontoTonReales            
   ,t0.EsAutorizarRectivacion AS EsAutorizarRectivacion            
   ,t0.IdAutorizacionReactivacion AS IdAutorizacionReactivacion            
   ,t0.IdUsuarioAutorizacionReactivacion AS IdUsuarioAutorizacionReactivacion            
   ,t0.FechaAutorizacionReactivacion AS FechaAutorizacionReactivacion            
   ,t0.EsModificarCubicajeConvenido AS EsModificarCubicajeConvenido            
   ,t0.IdUsuarioAutorizacionCubicaje AS IdUsuarioAutorizacionCubicaje            
   ,t0.FechaAutorizacionCubicaje AS FechaAutorizacionCubicaje            
   ,t0.ComentariosCubicaje AS ComentariosCubicaje            
   ,t0.EsCambioConvenio AS EsCambioConvenio            
   ,t0.PesoConvenioAnterior AS PesoConvenioAnterior            
   ,t0.IdUsuarioAutorizaConvenio AS IdUsuarioAutorizaConvenio            
   ,t0.FechaCambioConvenio AS FechaCambioConvenio            
   ,t0.EsNotificacionBloqueo AS EsNotificacionBloqueo            
   ,t0.EsManiobrasTonReal AS EsManiobrasTonReal            
   ,t0.EsCerradoEnPlanta AS EsCerradoEnPlanta            
   ,t0.MotivoCambioTransportista AS MotivoCambioTransportista            
   ,t0.ClaEstatusTabular AS ClaEstatusTabular            
   ,t0.Observaciones AS Observaciones            
   ,t0.FechaTabular AS FechaTabular            
   ,t1.NomTipoTabular AS NomTipoTabular          
   ,t2.NomTipoBoleta AS NomTipoBoleta          
   ,t3.NomGrupoTransporte AS NomGrupoTransporte            
   ,t4.NomTransporte AS NomTransporte            
   ,--,case when t13.clatransportistacen is null then ' <Font Color="red">(Transportista NO Asociado a Ubicacion)<br> </font>'else '' end + --
   t5.NomTransportista AS NomTransportista            
   ,t6.NomEstatusTabular AS NomEstatusTabular            
   ,t7.NomMoneda AS NomMoneda            
   ,t8.NomCiudadEstado AS NomCiudadOrigen             
   ,t9.NomCiudadEstado AS NomCiudadDestino            
   ,t10.NomTipoMaterial AS NomTipoMaterialFFCC            
   ,t12.NomTipoConvenio AS NomTipoConvenio            
   ,PrefijoTabular = LTRIM(rtrim(STR( t0.IdTabular ))) --ISNULL(LTRIM(RTRIM(t0.Prefijo)),'') + LTRIM(rtrim(STR( t0.IdTabular )))            
   ,t0.NumGuia            
   ,concentrado.IdFolio            
   ,PagarSinDevolucion = CASE WHEN t0.ClaEstatusTabular = 5 THEN 'Liberar' ELSE '' END         
   ,guia.FechaGuia as FechaInicioTramite          
   ,CxPTabular.FechaPagoReal as FechaPago          
   , datediff(dd,guia.FechaGuia,CxPTabular.FechaPagoReal)as CicloPago            
   , datediff(dd,t0.FechaTabular,CxPTabular.FechaPagoReal)as CicloPagoReal --GCC 15Mar16        
   ,ISNULL(CC.CuotaFerry,0) AS CuotaFerry          
   ,@nImporteAutopistas  AS ImporteAutopista      
----       
   ,Estatus.NomEstatusConcentrado  AS NomEstatusFolio       
   ,concentrado.EsConDiscrepancia AS EsConDiscrepanciaFolio      
     ,t5.ClaCup as ClaCupG      
     ,t0.FechaTabular as  FechaTabularG      
    ,isnull(t0.EnviadoCXP ,0) as EnviadoCXPG      
	,PesoAceroFisico = (ISNULL(H.KgCubicados,H2.KgCubicados)) / 1000.00
 FROM FLESch.FLETraTabularVw t0 WITH(NOLOCK)            
 LEFT JOIN FlESch.FLECatTipoTabularVw t1 WITH(NOLOCK) ON t0.ClaUbicacion = t1.ClaUbicacion AND t0.ClaTipoTabular = t1.ClaTipoTabular            
 LEFT JOIN FlESch.FLECatTipoBoletaVw t2 WITH(NOLOCK) ON t0.ClaUbicacion = t2.ClaUbicacion AND t0.ClaTipoBoleta = t2.ClaTipoBoleta            
 LEFT JOIN FlESch.FLECatGrupoTransporteVw t3 WITH(NOLOCK) ON t0.ClaGrupoTransporte = t3.ClaGrupoTransporte            
 LEFT JOIN FlESch.FLECatTransporteVw t4 WITH(NOLOCK) ON t0.ClaGrupoTransporte = t4.ClaGrupoTransporte AND t0.ClaTransporte = t4.ClaTransporte            
 LEFT JOIN FlESch.FLECatTransportistaVw t5 WITH(NOLOCK) ON t0.ClaUbicacion = t5.ClaUbicacion AND t0.ClaTransportista = t5.ClaTransportista            
 LEFT JOIN FLESch.FLECatEstatusTabularVw t6 WITH(NOLOCK) ON t0.ClaEstatusTabular = t6.ClaEstatusTabular            
 LEFT JOIN FLESch.FLETesCatMonedaVw t7 WITH(NOLOCK) ON t0.ClaMoneda = t7.ClaMoneda            
 LEFT JOIN FLESch.FLEVtaCatCiudadVw t8 WITH(NOLOCK) ON t0.ClaCiudadOrigen = t8.ClaCiudad            
 LEFT JOIN FLESch.FLEVtaCatCiudadVw t9 WITH(NOLOCK) ON t0.ClaCiudadDestino = t9.ClaCiudad            
 LEFT JOIN FLESch.FLEFfccCatTipoMaterialVw t10 WITH(NOLOCK) ON t0.ClaTipoMaterialFFCC = t10.ClaTipoMaterial            
 LEFT JOIN FLESch.FLETraConvenioVw t11 WITH(NOLOCK) ON t0.ClaUbicacion = t11.ClaUbicacion AND t0.IdConvenio = t11.IdConvenio AND t0.NumVersionConvenio = t11.NumVersion            
 LEFT JOIN FLESch.FLECatTipoConvenioVw t12 WITH(NOLOCK) ON t0.ClaUbicacionConvenio = t12.ClaUbicacion AND t0.ClaGrupoTransporte = t12.ClaGrupoTransporte AND t11.ClaTipoConvenio = t12.ClaTipoConvenio             
 LEFT JOIN FleSch.FleTraguia AS guia WITH(NOLOCK)            
     ON guia.ClaUbicacion = t0.ClaUbicacion            
     AND guia.NumGuia  = t0.NumGuia            
     AND guia.Clatransportista = t0.Clatransportista   
	 LEFT JOIN (
		SELECT	NumViaje = CONVERT(VARCHAR(50),fac.NumViaje),
				KgCubicados = SUM(b.KgCubicados)
		FROM	FleSch.FleTraViajeFactura			fac		WITH (NOLOCK)
		INNER JOIN FleSch.FleTraViajeFacturaDet b
		ON		fac.ClaUbicacion	= b.ClaUbicacion
		AND		fac.NumFactura		= b.NumFactura
		INNER JOIN FleSch.FleArtCatArticuloVw c
		ON		b.ClaArticulo		= c.ClaArticulo
		AND		C.ClaTipoInventario = 1
		INNER JOIN #TmpClaveSerivio serv
		ON		c.ClaFamilia <> serv.ClaveServicio
		WHERE	fac.ClaUbicacion = @pnClaUbicacion
		GROUP BY fac.NumViaje
	)	H ON	t0.ClaTipoTabular = 1 
		AND		t0.Referencia1	= H.NumViaje 
	LEFT JOIN (
		SELECT	NumViaje = CONVERT(VARCHAR(50),ent.NumViaje),	
				KgCubicados = SUM(b.KgCubicados)
		FROM	FleSch.FleTraViajeEntsal			ent		WITH (NOLOCK)
		LEFT JOIN FleSch.FleTraViajeEntsalDet b
		ON		ent.ClaUbicacion	= b.ClaUbicacion
		AND		ent.NumEntsal		= b.NumEntsal
		LEFT JOIN FleSch.FleArtCatArticuloVw c
		ON		b.ClaArticulo		= c.ClaArticulo
		AND		C.ClaTipoInventario = 1	
		INNER JOIN #TmpClaveSerivio serv
		ON		c.ClaFamilia <> serv.ClaveServicio
		WHERE	ent.ClaUbicacion = @pnClaUbicacion
		GROUP BY CONVERT(VARCHAR(50),ent.NumViaje)
	)	H2 ON	t0.ClaTipoTabular = 1 
		AND		t0.Referencia1 = H2.NumViaje 
 LEFT JOIN FleSch.FleTraconcentrado AS concentrado WITH(NOLOCK)            
     ON concentrado.IdConcentrado  = guia.IdConcentrado            
     AND concentrado.ClaUbicacion  = guia.ClaUbicacion        
  left Join FleCatEstatusConcentradoVw AS Estatus WITH(NOLOCK)      
  ON Estatus.ClaEstatusConcentrado = concentrado.ClaEstatusConcentrado       
 LEFT JOIN FleSch.FleTratramite AS Tramite WITH(NOLOCK)            
     ON Tramite.IdConcentrado  = guia.IdConcentrado            
     AND Tramite.ClaUbicacion  = guia.ClaUbicacion             
 LEFT JOIN FleSch.FleCXPTraTabularVw as CxPTabular        
 ON CxPTabular.ClaUbicacion = t0.ClaUbicacion        
 AND CxPTabular.IdTabular = t0.IdTabular        
 LEFT JOIN FleSch.FleCXPTraViajeVw as CxPViaje        
 ON CxPViaje.ClaUbicacion = t0.ClaUbicacion        
 AND CONVERT(VARCHAR, CxPViaje.IdViaje) = t0.Referencia1      
 AND CxPViaje.ClaSistema = 52      
 LEFT JOIN FleSch.FleCXPTraViajeVw as CxPBoleta        
 ON CxPBoleta.ClaUbicacion = t0.ClaUbicacion        
 AND CONVERT(VARCHAR, CxPBoleta.IdViaje) = t0.Referencia1      
 AND CxPBoleta.ClaSistema = 33      
   /*gcc 15Mar16        
 LEFT JOIN #PolCTraTramiteVw as poltramite WITH(NOLOCK)            
    on poltramite.idfoliotramitelocal = tramite.folioTramite          
   AND poltramite.ClaUbicacion  = Tramite.ClaUbicacion             
   */        
 LEFT JOIN FleSch.FleTraConvenioCen CC WITH (NOLOCK) ON  CC.IdConvenioCen = t0.IdConvenio AND CC.NumVersioncen = t0.NumVersionConvenio AND CC.FechaBaja IS NULL                     
 --LEFT JOIN flesch.flereltransportistacentransportistaVW T13 WITH(NOLOCK)         
 --ON t13.ClaUbicacion = t5.ClaUbicacion AND (T13.ClaTransportistaCen =  T5.ClaTransportista or T13.ClaTransportista =  T5.ClaTransportista )        
 WHERE  ( @pnEsNinguno = 1            
 AND  (@pnClaUbicacion IS NULL OR t0.ClaUbicacion = @pnClaUbicacion)            
 AND  (@pnClaTipoTabular IS NULL OR t0.ClaTipoTabular = @pnClaTipoTabular)            
 AND  (@pnClaTipoBoleta IS NULL OR t0.ClaTipoBoleta = @pnClaTipoBoleta)            
 AND  (@pnClaCiudad IS NULL OR t0.ClaCiudadOrigen = @pnClaCiudad)            
 AND  (@pnClaCiudad2 IS NULL OR t0.ClaCiudadDestino = @pnClaCiudad2)            
 AND  (@pnEsConDiscrepancia IS NULL OR t0.EsConDiscrepancia = @pnEsConDiscrepancia)            
 AND  (@pnClaGrupoTransporte IS NULL OR t0.ClaGrupoTransporte = @pnClaGrupoTransporte)            
 AND  (@pnClaTransporte IS NULL OR t0.ClaTransporte = @pnClaTransporte)            
 AND  (@pnClaTransportista IS NULL OR t0.ClaTransportista IN (SELECT ClaTransportista FROM #transportista))--= @pnClaTransportista)            
 AND  (@pnClaTipoMaterial IS NULL OR t0.ClaTipoMaterialFfcc = @pnClaTipoMaterial)            
 AND  (@pnClaEstatusTabular IS NULL OR t0.ClaEstatusTabular = @pnClaEstatusTabular)             
 AND  (@pnClaTipoConvenio IS NULL OR t11.ClaTipoConvenio = @pnClaTipoConvenio)             
 AND  t0.FechaTabular >= @ptFechaInicial            
 AND  t0.FechaTabular < DATEADD(dd,1,@ptFechaFinal) 
 )             
 OR     (             
   ( (@pnEsNinguno = 0 AND (@pnEsPorTabular = 1 AND (@pnIdTabular IS NULL OR t0.IdTabular = @pnIdTabular)) )            
 OR      (@pnEsNinguno = 0 AND (@pnEsPorFolio = 1 AND (@pnIdFolio IS NULL OR concentrado.IdFolio = @pnIdFolio)) )            
 OR      (@pnEsNinguno = 0 AND (@pnEsPorViaje = 1  AND t0.ClaTipoTabular = 1 AND (@pnNumViaje IS NULL OR t0.Referencia1 = CONVERT(VARCHAR(200), @pnNumViaje) )) )             
 OR      (@pnEsNinguno = 0 AND (@pnEsPorBoleta = 1 AND t0.ClaTipoTabular = 2 AND (t0.Referencia1 LIKE '%'+LTRIM(RTRIM(ISNULL(@psNumBoleta,'')))+'%')) )            
 OR      (@pnEsNinguno = 0 AND (@pnEsPorPedido = 1 AND (@pnNumPedido IS NULL OR t0.IdTabular IN (SELECT IdTabular FROM FLESch.FLETraTabularDet WITH(NOLOCK) WHERE ClaUbicacion = @pnClaUbicacion AND ClaPedido = @pnNumPedido GROUP BY IdTabular)))  )        


 OR      (@pnEsNinguno = 0 AND (@pnEsPorFactura = 1 AND (@psNumFactura IS NULL OR t0.NumGuia = @psNumFactura   )) )             
   )            
 and (@pnClaUbicacion IS NULL OR t0.ClaUbicacion = @pnClaUbicacion)             
 )             
 --OR  (@pnEsNinguno = 0 AND (@pnEsPorFactura = 1 AND (@psNumFactura IS NULL OR t0.Referencia1  IN (SELECT CONVERT(VARCHAR(200), a.NumViaje) FROM FLESch.FLETraViajeVw a            
 --                  LEFT JOIN FLESch.FleTraViajeFacturaVw b ON a.ClaUbicacion = b.ClaUbicacion AND a.NumViaje = b.NumViaje             
 --                  WHERE b.NumFactura = @psNumFactura))) )            


 SET NOCOUNT OFF            
END