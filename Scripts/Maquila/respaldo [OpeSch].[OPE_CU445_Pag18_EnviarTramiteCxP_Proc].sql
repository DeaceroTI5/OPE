--respaldo
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--*----  
--*Objeto:  OPE_CU445_Pag18_EnviarTramiteCxP_Proc  
--*Autor:  RCASTRO  
--*Fecha:   16/02/2016  
--*Objetivo: Enviar elementos de pago a CxP por tramite  
--*Entrada:    
--*Salida:    
--*Precondiciones:   
--*Revisiones:    
--*----   
ALTER PROCEDURE [OpeSch].[OPE_CU445_Pag18_EnviarTramiteCxP_Proc]  
 @pnIdTramiteMaquilador INT  
 ,@pnClaUbicacion  INT  
 ,@pnClaUsuarioMod  INT  
 ,@psNombrePcMod   VARCHAR(64)  
 ,@pnError    INT OUTPUT  
 ,@psMensajeError  VARCHAR(2000) OUTPUT  
 ,@pnEsDebug    BIT = 0  
 ,@psIdioma    VARCHAR(10) = 'Spanish'  
 ,@pnClaIdioma   INT = 5  
AS     
BEGIN    
SET NOCOUNT ON  
SET XACT_ABORT ON

IF @pnClaUsuarioMod = 100010318
BEGIN
	select '' as '[OpeSch].[OPE_CU445_Pag18_EnviarTramiteCxP_Proc]'
	set @pnEsDebug=1
END

 DECLARE @IdControlRecepcion INT  
   ,@IdControlRecepcionUnico uniqueidentifier  
   ,@nClaSistemaMaquilas INT  
   ,@nClaSistemaOrigen INT  
   ,@nMovsAutorizados INT  
   ,@nMovsConError  INT  
    
 DECLARE @CXPTmpEntradaMaquila TABLE(  
        IdEntradaMaquila   int  
        ,ClaUbicacion    int  
        ,ClaSistema     int  
        ,IdControlRecepcion   int  
        ,IdControlRecepcionUnico uniqueidentifier  
        ,MensajeRecepcion   varchar(max)  
        ,ErroresRecepcion   varchar(max)  
        ,ClaEstatusRecepcion  int     
        ,DetallesAEnviar   int  
        ,Fecha      datetime  
        ,ClaCup      int  
        ,ClaMoneda     int  
        --,IdContrato     int  
        ,ImporteNeto    numeric(22, 8)  
        ,PorcentajeIVA    numeric(22, 2)  
        ,ImporteIVA     numeric(22, 8)  
        ,ImporteTotal    numeric(22, 8)  
        ,Kilos      numeric(22, 0)  
        ,Concepto     varchar(100)  
        ,EsGenerarPasivoEnCxP  int  
        ,EsTramitarPagoEnCxP  int  
        ,IdTramitePasivoOrig  int  
        ,IdTramitePagoOrig   int  
        ,ClaUsuarioMod    int  
        ,FechaUltimaMod    datetime  
        ,NombrePcMod    varchar(64)  
       )  
  
 DECLARE @CXPTmpEntradaMaquilaDet TABLE(  
         IdEntradaMaquila   int  
         ,ClaUbicacion    int  
         ,ClaSistema     int  
         ,IdControlRecepcion   int  
         ,IdRenglon     int  
         ,IdControlRecepcionUnico uniqueidentifier  
         ,IdContrato    int  
         ,ClaArticulo    int  
         ,NomArticulo    varchar(100)  
         ,ClaUnidad     int  
         ,NomUnidad     varchar(20)  
         ,Concepto     varchar(100)  
         ,ClaDireccion    char(4)  
         ,ClaCRC      int  
         ,ClaTipoGasto    int  
         ,Cantidad     numeric(22, 8)  
         ,Kilos      numeric(22, 0)  
         ,PrecioUnitario    numeric(22, 8)  
         ,Descuento     numeric(22, 8)  
         ,ImporteNeto    numeric(22, 8)  
         ,PorcentajeIVA    numeric(22, 2)  
         ,ImporteIVA     numeric(22, 8)  
         ,ImporteTotal    numeric(22, 8)  
         ,ClaUsuarioMod    int  
         ,FechaUltimaMod    datetime  
         ,NombrePcMod    varchar(64)  
        )  
 DECLARE @Contratos TABLE(IdContratro INT)  
 DECLARE @IdContrato INT  
   
 -----------------------------  
 -- OBTENEMOS CONFIGURACIONES   
 -----------------------------  
 SET @pnError = 1-- SE MARCA COMO ERROR Y AL FINAL SI TODO FUE EXITOSO SE CAMBIA A CERO  
 SET @nClaSistemaMaquilas = 39 --Maquilas  
 SELECT @nClaSistemaOrigen = nValor1     -- Sistema Origen 61   
 FROM OpeSch.OpeTiCatConfiguracionVw WITH (NOLOCK)        
 WHERE ClaUbicacion = @pnClaUbicacion AND        
 ClaSistema = @nClaSistemaMaquilas AND        
 ClaConfiguracion = 13   

 IF(@pnEsDebug = 1)
 BEGIN
	SELECT   
	'CXP Ver Fecha aqui' as 'Where',
  A.IdRecepOrdenMaquila IdEntradaMaquila,  
  A.ClaUbicacion,  
  count(DISTINCT A.ClaArticulo) DetallesAEnviar,  
  O.FechaHoraSalida Fecha,  
  maq.ClaCup,  
  contrato.ClaMoneda,  
  ImporteNeto  = SUM(ROUND(A.ImporteSinIVADeduc, 2)),   
  A.PorcIVA PorcentajeIVA,   
ImporteIVA  = SUM(ROUND(A.ImporteIVARecep, 2)),   
  ImporteTotal = SUM(ROUND(A.ImporteConIVADeduc, 2)),   
  Kilos   = SUM(ROUND(E.PesoRecibido, 2)),  
  Concepto  = CONVERT(VARCHAR(100),'Pago de la entrada '+  
           CONVERT(VARCHAR, P.IdTramiteMaquilador)+'-'+  
           CONVERT(VARCHAR, I.IdBoleta)+'-'+  
           CONVERT(VARCHAR, A.IdRecepOrdenMaquila )+' al maquilador '+  
           maq.NomMaquilador),  
  1 EsGenerarPasivoEnCxP,  
  CASE WHEN ISNULL(IdTramitePOL,0) = 0 THEN 1 ELSE 0 END EsTramitarPagoEnCxP,  
  null IdTramitePasivoOrig,  
  IdTramitePOL IdTramitePagoOrig  
 FROM OpeSch.OpeTraTramiteMaquilador P  
 INNER JOIN OpeSch.OpeTraPagoFacturaMaquilador A WITH(NOLOCK)  
  ON A.ClaUbicacion = P.ClaUbicacion AND  
   A.IdTramite = P.IdTramiteMaquilador  
 INNER JOIN OpeSch.OpeTraRecepOrdenMaquilaDet E WITH(NOLOCK)   
  ON E.ClaUbicacion = A.ClaUbicacion AND   
   E.IdRecepOrdenMaquila = A.IdRecepOrdenMaquila AND  
   E.IdRecepOrdenMaquilaDet = A.IdRecepOrdenMaquilaDet AND  
   E.IdContrato = A.IdContrato AND  
   E.ClaArticulo = A.ClaArticulo  
 INNER JOIN OPESCH.OpeTraRecepOrdenMaquila I (nolock)   
  ON I.ClaUbicacion = E.ClaUbicacion AND  
   I.IdRecepOrdenMaquila = E.IdRecepOrdenMaquila  
 INNER JOIN OPESCH.OpeTraBoletaHisVw O    (nolock)   
  ON O.IdBoleta = I.IdBoleta AND   
   O.ClaUbicacion = I.ClaUbicacion  
 INNER JOIN OPESCH.OpeTraContratoMaquila contrato (nolock)   
  ON contrato.ClaUbicacion = E.ClaUbicacion AND  
   contrato.IdContrato = E.IdContrato  
 INNER JOIN OPESCH.OpeCatMaquilador maq (nolock)  
  ON maq.ClaUbicacion = contrato.ClaUbicacion AND  
   maq.ClaMaquilador = contrato.ClaMaquilador  
 WHERE A.ClaUbicacion = @pnClaUbicacion   
   and P.IdTramiteMaquilador = @pnIdTramiteMaquilador  
 GROUP BY   
  A.IdRecepOrdenMaquila,   
  A.ClaUbicacion,   
  I.IdBoleta,  
  O.FechaHoraSalida,   
  maq.ClaCup,   
  contrato.ClaMoneda,  
  A.PorcIVA,   
  maq.NomMaquilador,   
  P.IdTramitePOL,  
  P.IdTramiteMaquilador
 END
   
 -- OBTENEMOS LAS ENTRADAS REGISTRADAS PARA EL CONTROL  
 INSERT INTO @CXPTmpEntradaMaquila(  
  IdEntradaMaquila,  
  ClaUbicacion,  
  DetallesAEnviar,  
  Fecha,  
  ClaCup,  
  ClaMoneda,  
  --IdContrato,  
  ImporteNeto,  
  PorcentajeIVA,   
  ImporteIVA,   
  ImporteTotal,  
  Kilos,  
  Concepto,  
  EsGenerarPasivoEnCxP,  
  EsTramitarPagoEnCxP,  
  IdTramitePasivoOrig,  
  IdTramitePagoOrig  
 )  
 SELECT   
  A.IdRecepOrdenMaquila IdEntradaMaquila,  
  A.ClaUbicacion,  
  count(DISTINCT A.ClaArticulo) DetallesAEnviar,  
  O.FechaHoraSalida Fecha,  
  maq.ClaCup,  
  contrato.ClaMoneda,  
  ImporteNeto  = SUM(ROUND(A.ImporteSinIVADeduc, 2)),   
  A.PorcIVA PorcentajeIVA,   
  ImporteIVA  = SUM(ROUND(A.ImporteIVARecep, 2)),   
  ImporteTotal = SUM(ROUND(A.ImporteConIVADeduc, 2)),   
  Kilos   = SUM(ROUND(E.PesoRecibido, 2)),  
  Concepto  = CONVERT(VARCHAR(100),'Pago de la entrada '+  
           CONVERT(VARCHAR, P.IdTramiteMaquilador)+'-'+  
           CONVERT(VARCHAR, I.IdBoleta)+'-'+  
           CONVERT(VARCHAR, A.IdRecepOrdenMaquila )+' al maquilador '+  
           maq.NomMaquilador),  
  1 EsGenerarPasivoEnCxP,  
  CASE WHEN ISNULL(IdTramitePOL,0) = 0 THEN 1 ELSE 0 END EsTramitarPagoEnCxP,  
  null IdTramitePasivoOrig,  
  IdTramitePOL IdTramitePagoOrig  
 FROM OpeSch.OpeTraTramiteMaquilador P  
 INNER JOIN OpeSch.OpeTraPagoFacturaMaquilador A WITH(NOLOCK)  
  ON A.ClaUbicacion = P.ClaUbicacion AND  
   A.IdTramite = P.IdTramiteMaquilador  
 INNER JOIN OpeSch.OpeTraRecepOrdenMaquilaDet E WITH(NOLOCK)   
  ON E.ClaUbicacion = A.ClaUbicacion AND   
   E.IdRecepOrdenMaquila = A.IdRecepOrdenMaquila AND  
E.IdRecepOrdenMaquilaDet = A.IdRecepOrdenMaquilaDet AND  
   E.IdContrato = A.IdContrato AND  
   E.ClaArticulo = A.ClaArticulo  
 INNER JOIN OPESCH.OpeTraRecepOrdenMaquila I (nolock)   
  ON I.ClaUbicacion = E.ClaUbicacion AND  
   I.IdRecepOrdenMaquila = E.IdRecepOrdenMaquila  
 INNER JOIN OPESCH.OpeTraBoletaHisVw O    (nolock)   
  ON O.IdBoleta = I.IdBoleta AND   
   O.ClaUbicacion = I.ClaUbicacion  
 INNER JOIN OPESCH.OpeTraContratoMaquila contrato (nolock)   
  ON contrato.ClaUbicacion = E.ClaUbicacion AND  
   contrato.IdContrato = E.IdContrato  
 INNER JOIN OPESCH.OpeCatMaquilador maq (nolock)  
  ON maq.ClaUbicacion = contrato.ClaUbicacion AND  
   maq.ClaMaquilador = contrato.ClaMaquilador  
 WHERE A.ClaUbicacion = @pnClaUbicacion   
   and P.IdTramiteMaquilador = @pnIdTramiteMaquilador  
 GROUP BY   
  A.IdRecepOrdenMaquila,   
  A.ClaUbicacion,   
  I.IdBoleta,  
  O.FechaHoraSalida,   
  maq.ClaCup,   
  contrato.ClaMoneda,  
  A.PorcIVA,   
  maq.NomMaquilador,   
  P.IdTramitePOL,  
  P.IdTramiteMaquilador  
  
--  PRINT 'SELECT'
  
--  SELECT* from OPESCH.OpeTraBoletaHisVw where ClaUbicacion = 3 and IdBoleta = 160530075
--    SELECT* from OPESCH.OpeTraBoletaHisVw where ClaUbicacion = 3 and IdBoleta = 190100023
--    SELECT* from OPESCH.OpeTraBoletaHisVw where ClaUbicacion = 3 and IdBoleta = 202110013
  
--    SELECT MAX(idboleta) from OPESCH.OpeTraBoletaHisVw where ClaUbicacion = 3 
--SELECT   *
-- FROM OpeSch.OpeTraTramiteMaquilador P  
-- INNER JOIN OpeSch.OpeTraPagoFacturaMaquilador A WITH(NOLOCK)  
--  ON A.ClaUbicacion = P.ClaUbicacion AND  
--   A.IdTramite = P.IdTramiteMaquilador  
-- INNER JOIN OpeSch.OpeTraRecepOrdenMaquilaDet E WITH(NOLOCK)   
--  ON E.ClaUbicacion = A.ClaUbicacion AND   
--   E.IdRecepOrdenMaquila = A.IdRecepOrdenMaquila AND  
--   E.IdRecepOrdenMaquilaDet = A.IdRecepOrdenMaquilaDet AND  
--   E.IdContrato = A.IdContrato AND  
--   E.ClaArticulo = A.ClaArticulo  
-- INNER JOIN OPESCH.OpeTraRecepOrdenMaquila I (nolock)   
--  ON I.ClaUbicacion = E.ClaUbicacion AND  
--   I.IdRecepOrdenMaquila = E.IdRecepOrdenMaquila  
-- INNER JOIN OPESCH.OpeTraBoletaHisVw O    (nolock)   
--  ON O.IdBoleta = I.IdBoleta AND   
--   O.ClaUbicacion = I.ClaUbicacion  
-- INNER JOIN OPESCH.OpeTraContratoMaquila contrato (nolock)   
--  ON contrato.ClaUbicacion = E.ClaUbicacion AND  
--   contrato.IdContrato = E.IdContrato  
-- INNER JOIN OPESCH.OpeCatMaquilador maq (nolock)  
--  ON maq.ClaUbicacion = contrato.ClaUbicacion AND  
--   maq.ClaMaquilador = contrato.ClaMaquilador  
-- WHERE A.ClaUbicacion = @pnClaUbicacion   
--   and P.IdTramiteMaquilador = @pnIdTramiteMaquilador  
  

 IF(@pnEsDebug = 1)
 BEGIN
	SELECT   
	'CXP Detalle',
	  A.IdRecepOrdenMaquila IdEntradaMaquila,  
  A.ClaUbicacion,  
  ROW_NUMBER() OVER(PARTITION BY A.IdRecepOrdenMaquila ORDER BY A.IdRecepOrdenMaquila ASC) AS IdRenglon,  
  contrato.IdContrato,  
  A.ClaArticulo,  
  CONVERT(VARCHAR(100),Art.NomArticulo),  
  t3.ClaUnidad,  
  RTRIM(LTRIM(t3.NomCortoUnidad)) NomUnidad,  
  Concepto  = CONVERT(VARCHAR(100),'Pago de la entrada '+  
           CONVERT(VARCHAR, P.IdTramiteMaquilador)+'-'+  
           CONVERT(VARCHAR, I.IdBoleta)+'-'+  
           CONVERT(VARCHAR, A.IdRecepOrdenMaquila )+' del producto '+  
           Art.NomArticulo),  
  A.ClaDireccion,   
  A.ClaCRC,   
  A.ClaTipoGasto,   
  CantRecibida = ROUND(SUM(A.CantRecibida*contrato.FactorConversion), 2),  
  Kilos   = ROUND(SUM(E.PesoRecibido), 2),   
  PrecioUnitario = contrato.PrecioNegociado,   
  Descuento  = ROUND(SUM(A.ImporteDeduccionRecep), 2),   
  ImporteNeto  = ROUND(SUM(A.ImporteSinIVADeduc), 2),   
  A.PorcIVA PorcentajeIVA,   
  ImporteIVA  = ROUND(SUM(A.ImporteIVARecep), 2),   
  ImporteTotal = ROUND(SUM(A.ImporteConIVADeduc), 2)  
 FROM OpeSch.OpeTraTramiteMaquilador P  
 INNER JOIN OpeSch.OpeTraPagoFacturaMaquilador A WITH(NOLOCK)  
  ON A.ClaUbicacion = P.ClaUbicacion AND  
   A.IdTramite = P.IdTramiteMaquilador  
 INNER JOIN OpeSch.OpeTraRecepOrdenMaquilaDet E WITH(NOLOCK)   
  ON E.ClaUbicacion = A.ClaUbicacion AND   
   E.IdRecepOrdenMaquila = A.IdRecepOrdenMaquila AND  
   E.IdRecepOrdenMaquilaDet = A.IdRecepOrdenMaquilaDet AND  
   E.IdContrato = A.IdContrato AND  
   E.ClaArticulo = A.ClaArticulo  
 INNER JOIN OPESCH.OpeTraRecepOrdenMaquila I (nolock)   
  ON I.ClaUbicacion = E.ClaUbicacion AND  
   I.IdRecepOrdenMaquila = E.IdRecepOrdenMaquila  
 INNER JOIN OpeSch.OpeArtCatArticuloVw Art WITH(NOLOCK)  
  ON Art.ClaTipoInventario = 1 AND  
   Art.ClaArticulo = E.ClaArticulo  
 INNER JOIN OPESCH.OpeTraContratoMaquila contrato (nolock)   
  ON contrato.ClaUbicacion = E.ClaUbicacion AND  
   contrato.IdContrato = E.IdContrato  
 INNER JOIN opeSch.OpeArtCatUnidadVw t3 WITH (NOLOCK)  
   ON t3.ClaTipoInventario = 1 AND (t3.ClaUnidad = contrato.ClaUnidadPrecio OR ( contrato.ClaUnidadPrecio IS NULL AND t3.ClaUnidad = 1))  
 WHERE A.ClaUbicacion = @pnClaUbicacion   
   and P.IdTramiteMaquilador = @pnIdTramiteMaquilador  
 GROUP BY   
   A.IdRecepOrdenMaquila,  
   A.ClaUbicacion,  
   contrato.IdContrato,  
   A.ClaArticulo,  
   Art.NomArticulo,  
   t3.ClaUnidad,  
   t3.NomCortoUnidad,  
   I.IdBoleta,  
   A.ClaDireccion,   
   A.ClaCRC,   
   A.ClaTipoGasto,  
   A.PorcIVA,  
   contrato.PrecioNegociado,  
   P.IdTramiteMaquilador  
END

 -- OBTENEMOS EL DETALLE DE LAS ENTRADAS REGISTRADAS PARA EL CONTROL  
 INSERT INTO @CXPTmpEntradaMaquilaDet(  
  IdEntradaMaquila  
  ,ClaUbicacion  
  ,IdRenglon  
  ,IdContrato  
  ,ClaArticulo  
  ,NomArticulo  
  ,ClaUnidad  
  ,NomUnidad  
  ,Concepto  
  ,ClaDireccion  
  ,ClaCRC  
  ,ClaTipoGasto  
  ,Cantidad  
  ,Kilos  
  ,PrecioUnitario  
  ,Descuento  
  ,ImporteNeto  
  ,PorcentajeIVA  
  ,ImporteIVA  
  ,ImporteTotal  
 )  
 SELECT   
  A.IdRecepOrdenMaquila IdEntradaMaquila,  
  A.ClaUbicacion,  
  ROW_NUMBER() OVER(PARTITION BY A.IdRecepOrdenMaquila ORDER BY A.IdRecepOrdenMaquila ASC) AS IdRenglon,  
  contrato.IdContrato,  
  A.ClaArticulo,  
  CONVERT(VARCHAR(100),Art.NomArticulo),  
  t3.ClaUnidad,  
  RTRIM(LTRIM(t3.NomCortoUnidad)) NomUnidad,  
  Concepto  = CONVERT(VARCHAR(100),'Pago de la entrada '+  
           CONVERT(VARCHAR, P.IdTramiteMaquilador)+'-'+  
           CONVERT(VARCHAR, I.IdBoleta)+'-'+  
           CONVERT(VARCHAR, A.IdRecepOrdenMaquila )+' del producto '+  
           Art.NomArticulo),  
  A.ClaDireccion,   
  A.ClaCRC,   
  A.ClaTipoGasto,   
  CantRecibida = ROUND(SUM(A.CantRecibida*contrato.FactorConversion), 2),  
  Kilos   = ROUND(SUM(E.PesoRecibido), 2),   
  PrecioUnitario = contrato.PrecioNegociado,   
  Descuento  = ROUND(SUM(A.ImporteDeduccionRecep), 2),   
  ImporteNeto  = ROUND(SUM(A.ImporteSinIVADeduc), 2),   
  A.PorcIVA PorcentajeIVA,   
  ImporteIVA  = ROUND(SUM(A.ImporteIVARecep), 2),   
  ImporteTotal = ROUND(SUM(A.ImporteConIVADeduc), 2)  
 FROM OpeSch.OpeTraTramiteMaquilador P  
 INNER JOIN OpeSch.OpeTraPagoFacturaMaquilador A WITH(NOLOCK)  
  ON A.ClaUbicacion = P.ClaUbicacion AND  
   A.IdTramite = P.IdTramiteMaquilador  
 INNER JOIN OpeSch.OpeTraRecepOrdenMaquilaDet E WITH(NOLOCK)   
  ON E.ClaUbicacion = A.ClaUbicacion AND   
   E.IdRecepOrdenMaquila = A.IdRecepOrdenMaquila AND  
   E.IdRecepOrdenMaquilaDet = A.IdRecepOrdenMaquilaDet AND  
   E.IdContrato = A.IdContrato AND  
   E.ClaArticulo = A.ClaArticulo  
 INNER JOIN OPESCH.OpeTraRecepOrdenMaquila I (nolock)   
  ON I.ClaUbicacion = E.ClaUbicacion AND  
   I.IdRecepOrdenMaquila = E.IdRecepOrdenMaquila  
 INNER JOIN OpeSch.OpeArtCatArticuloVw Art WITH(NOLOCK)  
  ON Art.ClaTipoInventario = 1 AND  
   Art.ClaArticulo = E.ClaArticulo  
 INNER JOIN OPESCH.OpeTraContratoMaquila contrato (nolock)   
  ON contrato.ClaUbicacion = E.ClaUbicacion AND  
   contrato.IdContrato = E.IdContrato  
 INNER JOIN opeSch.OpeArtCatUnidadVw t3 WITH (NOLOCK)  
   ON t3.ClaTipoInventario = 1 AND (t3.ClaUnidad = contrato.ClaUnidadPrecio OR ( contrato.ClaUnidadPrecio IS NULL AND t3.ClaUnidad = 1))  
 WHERE A.ClaUbicacion = @pnClaUbicacion   
   and P.IdTramiteMaquilador = @pnIdTramiteMaquilador  
 GROUP BY   
   A.IdRecepOrdenMaquila,  
   A.ClaUbicacion,  
   contrato.IdContrato,  
   A.ClaArticulo,  
   Art.NomArticulo,  
   t3.ClaUnidad,  
   t3.NomCortoUnidad,  
   I.IdBoleta,  
   A.ClaDireccion,   
   A.ClaCRC,   
   A.ClaTipoGasto,  
   A.PorcIVA,  
   contrato.PrecioNegociado,  
   P.IdTramiteMaquilador  
   
 ----------------------------------------------------------------------------  
 -- OBTENEMOS LOS CONTRATOS PARA VERIFICAR SI YA FUERON ENVIADOS A CXP  
 ----------------------------------------------------------------------------  
 INSERT INTO @Contratos  
 SELECT DISTINCT t0.IdContrato  
 FROM @CXPTmpEntradaMaquilaDet t0 INNER JOIN OpeSch.OpeTraContratoMaquila t1 (NOLOCK)  
  ON t1.ClaUbicacion = t0.ClaUbicacion AND t1.IdContrato = t0.IdContrato  
 WHERE ISNULL(t1.EnviadoCXP, 0) = 0 AND t1.ClaEstatus IN (2,3)--SE LIBERO O SE CERRO PERO NO SE ENVIO A CXP  
   
 SELECT @IdContrato = MIN(IdContratro) FROM @Contratos  
 WHILE @IdContrato IS NOT NULL  
 BEGIN  
  IF @pnEsDebug = 1  
  BEGIN  
   PRINT 'OpeSch.Ope_CU445_Pag7_Boton_Liberar_Proc'  
   PRINT @pnClaUbicacion  
   PRINT @IdContrato  
   PRINT @pnClaUsuarioMod  
   PRINT @psNombrePcMod  
   PRINT @pnEsDebug  
   PRINT @psIdioma  
   PRINT @pnClaIdioma  
  END  
  BEGIN TRY  
   EXEC OpeSch.Ope_CU445_Pag7_Boton_Liberar_Proc  
    @pnClaUbicacion  = @pnClaUbicacion  
    ,@pnIdContrato  = @IdContrato  
    ,@pnClaUsuarioMod = @pnClaUsuarioMod  
    ,@psNombrePcMod  = @psNombrePcMod  
    ,@pnDebug   = @pnEsDebug  
    ,@psIdioma   = @psIdioma  
    ,@pnClaIdioma  = @pnClaIdioma  
  END TRY  
  BEGIN CATCH  
  IF @@ERROR<>0  
  BEGIN  
   SET @pnError = 1  
   SET @psMensajeError = ERROR_MESSAGE()  
   SET @psMensajeError = 'Contrato de Cxp: '+ISNULL(@psMensajeError, '')  
   GOTO FIN  
  END  
  END CATCH  
  SELECT @IdContrato = MIN(IdContratro) FROM @Contratos WHERE IdContratro > @IdContrato  
 END  
  
 -- SE OBTIENE TOKENS DE CXP  
 IF @pnEsDebug = 1  
 BEGIN  
  PRINT 'CXP_6OFGRALES_LNKSVR.CxP.[CxpSch].[CxP_CU1_Pag15_RecibirEntradaMaquilaEnc_Srv]'  
  PRINT @pnClaUbicacion  
  PRINT @nClaSistemaOrigen  
 END  
 EXEC CXP_6OFGRALES_LNKSVR.CxP.[CxpSch].[CxP_CU1_Pag15_RecibirEntradaMaquilaEnc_Srv]  
  @pnIdEntradaMaquila    = NULL,  
  @pnClaUbicacion     = @pnClaUbicacion,  
  @pnClaSistema     = @nClaSistemaOrigen,  
  @pnDetallesAEnviar    = NULL,  
  @ptFecha      = NULL,  
  @pnClaCup      = NULL,  
  @pnClaMoneda     = NULL,  
  @psConcepto      = NULL,  
  @pnKilos      = NULL,  
  @pnImporteNeto     = NULL,  
  @pnPorcentajeIVA    = NULL,  
  @pnImporteIVA     = NULL,  
  @pnImporteTotal     = NULL,   
  @pnEsGenerarPasivoEnCxP   = 0,  
  @pnEsTramitarPagoEnCxP   = 0,  
  @pnIdTramitePasivoOrig   = NULL,  
  @pnIdTramitePagoOrig   = NULL,  
  @pnIdControlRecepcion   = @IdControlRecepcion OUT,   
  @pnIdControlRecepcionUnico  = @IdControlRecepcionUnico OUT, -- Son datos que la ubicacion le mando y/o viceversa cuando insertan los deben enviar..  
  @psMensajeError     = @psMensajeError OUT,  
  @pnClaUsuarioMod    = @pnClaUsuarioMod,  
  @psNombrePcMod     = @psNombrePcMod,  
  @psIdioma      = @psIdioma  
 IF @pnEsDebug = 1  
 BEGIN  
  PRINT @IdControlRecepcion  
  PRINT @IdControlRecepcionUnico  
  PRINT @psMensajeError  
 END  
 IF @@ERROR <> 0 OR ISNULL(@IdControlRecepcion,0) <= 0  
 BEGIN  
  SET @pnError = 1  
  SET @psMensajeError = 'Error al generar Control de Cxp: '+ISNULL(@psMensajeError, '')  
  GOTO FIN  
 END  
 -- ACTUALIZAMOS CON LOS TOKENS PARA INICIAR A ENVIAR A CXP  
 UPDATE @CXPTmpEntradaMaquila   
 SET ClaSistema     = @nClaSistemaOrigen  
  ,IdControlRecepcion   = @IdControlRecepcion  
  ,IdControlRecepcionUnico = @IdControlRecepcionUnico  
  ,ClaEstatusRecepcion  = NULL--Se asigna cuando se recibe la respuesta por parte de CxP  
  ,ClaUsuarioMod    = @pnClaUsuarioMod  
  ,FechaUltimaMod    = GETDATE()  
  ,NombrePcMod    = @psNombrePcMod  
 UPDATE @CXPTmpEntradaMaquilaDet   
 SET ClaSistema     = @nClaSistemaOrigen  
  ,IdControlRecepcion   = @IdControlRecepcion  
  ,IdControlRecepcionUnico = @IdControlRecepcionUnico  
  ,ClaUsuarioMod    = @pnClaUsuarioMod  
  ,FechaUltimaMod    = GETDATE()  
  ,NombrePcMod    = @psNombrePcMod  
 
 IF @pnEsDebug = 1  
 BEGIN  
  PRINT 'SELECT * FROM @CXPTmpEntradaMaquila'
  SELECT * FROM @CXPTmpEntradaMaquila
  PRINT 'SELECT * FROM @CXPTmpEntradaMaquilaDet'  
  SELECT * FROM @CXPTmpEntradaMaquilaDet  
 END  
 --------------------------------------------------------------  
   
 IF @pnEsDebug = 1  
 BEGIN  
  PRINT 'CXP_6OFGRALES_LNKSVR.CxP.CxpSch.CXPTmpEntradaMaquila'  
 END  
   print '@CXPTmpEntradaMaquila'

 --  SELECT   
 -- IdEntradaMaquila  
 -- ,ClaUbicacion  
 -- ,ClaSistema  
 -- ,IdControlRecepcion  
 -- ,IdControlRecepcionUnico  
 -- ,MensajeRecepcion  
 -- ,ErroresRecepcion  
 -- ,ClaEstatusRecepcion  
 -- ,DetallesAEnviar  
 -- ,Fecha  
 -- ,ClaCup  
 -- ,ClaMoneda  
 -- ,ImporteNeto  
 -- ,PorcentajeIVA  
 -- ,ImporteIVA  
 -- ,ImporteTotal  
 -- ,Kilos  
 -- ,Concepto  
 -- ,EsGenerarPasivoEnCxP  
 -- ,EsTramitarPagoEnCxP  
 -- ,IdTramitePasivoOrig  
 -- ,IdTramitePagoOrig  
 -- ,ClaUsuarioMod  
 -- ,FechaUltimaMod  
 -- ,NombrePcMod  
 --FROM @CXPTmpEntradaMaquila  
 
 BEGIN TRY
 
   
 INSERT INTO CXP_6OFGRALES_LNKSVR.CxP.CxpSch.CXPTmpEntradaMaquila(  
  IdEntradaMaquila  
  ,ClaUbicacion  
  ,ClaSistema  
  ,IdControlRecepcion  
  ,IdControlRecepcionUnico  
  ,MensajeRecepcion  
  ,ErroresRecepcion  
  ,ClaEstatusRecepcion  
  ,DetallesAEnviar  
  ,Fecha  
  ,ClaCup  
  ,ClaMoneda  
  ,ImporteNeto  
  ,PorcentajeIVA  
  ,ImporteIVA  
  ,ImporteTotal  
  ,Kilos  
  ,Concepto  
  ,EsGenerarPasivoEnCxP  
  ,EsTramitarPagoEnCxP  
  ,IdTramitePasivoOrig  
  ,IdTramitePagoOrig  
  ,ClaUsuarioMod  
  ,FechaUltimaMod  
  ,NombrePcMod  
 )  
 SELECT   
  IdEntradaMaquila  
  ,ClaUbicacion  
  ,ClaSistema  
  ,IdControlRecepcion  
  ,IdControlRecepcionUnico  
  ,MensajeRecepcion  
  ,ErroresRecepcion  
  ,ClaEstatusRecepcion  
  ,DetallesAEnviar  
  ,Fecha  
  ,ClaCup  
  ,ClaMoneda  
  ,ImporteNeto  
  ,PorcentajeIVA  
  ,ImporteIVA  
  ,ImporteTotal  
  ,Kilos  
  ,Concepto  
  ,EsGenerarPasivoEnCxP  
  ,EsTramitarPagoEnCxP  
  ,IdTramitePasivoOrig  
  ,IdTramitePagoOrig  
  ,ClaUsuarioMod  
  ,FechaUltimaMod  
  ,NombrePcMod  
 FROM @CXPTmpEntradaMaquila  
 
 IF @pnEsDebug = 1  
 BEGIN  
  SELECT * FROM CXP_6OFGRALES_LNKSVR.CxP.CxpSch.CXPTmpEntradaMaquila   
  WHERE IdControlRecepcion = @IdControlRecepcion AND ClaUbicacion = @pnClaUbicacion  
 END  
 END TRY  
 BEGIN CATCH  
 IF @@ERROR<>0  
 BEGIN  
  SET @pnError = 1  
  SET @psMensajeError = ERROR_MESSAGE()  
  SET @psMensajeError = 'Error al registrar encabezado de Cxp: '+ISNULL(@psMensajeError, '')  
  PRINT @psMensajeError  
  GOTO FIN  
 END  
 END CATCH  
   
	-- RCASTRO 20161017 FP372463.
	-- DEBIDO A LOS REDONDEOS AUTOMATICOS PORQUE CXP NO MANEJA DECIMALES EN KILOS SE TIENE QUE DESCONTAR DEL RENGLON POR ENTRADA CON MAS KILOS
	UPDATE det
		SET det.Kilos = det.Kilos + dif.KilosDiferencia
	FROM @CXPTmpEntradaMaquilaDet det
		INNER JOIN (
				SELECT 
					t0.IdEntradaMaquila, t0.Kilos, SUM(t1.Kilos) AS KilosPartidas, 
					(SELECT TOP 1 t3.IdRenglon FROM @CXPTmpEntradaMaquilaDet t3 
					WHERE t3.IdEntradaMaquila = t0.IdEntradaMaquila ORDER BY Kilos DESC) AS IdRenglon,
					t0.Kilos-SUM(t1.Kilos) AS KilosDiferencia
				FROM @CXPTmpEntradaMaquila t0 INNER JOIN @CXPTmpEntradaMaquilaDet t1 
				ON t0.IdEntradaMaquila = t1.IdEntradaMaquila
					GROUP BY t0.IdEntradaMaquila, t0.Kilos
				HAVING t0.Kilos <> SUM(t1.Kilos)) dif
		ON dif.IdEntradaMaquila =  det.IdEntradaMaquila
		AND dif.IdRenglon = det.IdRenglon
	WHERE dif.KilosDiferencia <> 0
   
 IF @pnEsDebug = 1  
 BEGIN  
  PRINT 'CXP_6OFGRALES_LNKSVR.CxP.CxpSch.CXPTmpEntradaMaquilaDet'  
 END  
 BEGIN TRY  
 INSERT INTO CXP_6OFGRALES_LNKSVR.CxP.CxpSch.CXPTmpEntradaMaquilaDet(  
  IdEntradaMaquila  
  ,ClaUbicacion  
  ,ClaSistema  
  ,IdControlRecepcion  
  ,IdRenglon  
  ,IdControlRecepcionUnico  
  ,ClaArticulo  
  ,NomArticulo  
  ,ClaUnidad  
  ,NomUnidad  
  ,IdContrato  
  ,Concepto  
  ,ClaDireccion  
  ,ClaCRC  
  ,ClaTipoGasto  
  ,Cantidad  
  ,Kilos  
  ,PrecioUnitario  
  ,Descuento  
  ,ImporteNeto  
  ,PorcentajeIVA  
  ,ImporteIVA  
  ,ImporteTotal  
  ,ClaUsuarioMod  
  ,FechaUltimaMod  
  ,NombrePcMod  
 )  
 SELECT  
  IdEntradaMaquila  
  ,ClaUbicacion  
  ,ClaSistema  
  ,IdControlRecepcion  
  ,IdRenglon  
  ,IdControlRecepcionUnico  
  ,ClaArticulo  
  ,NomArticulo  
  ,ClaUnidad  
  ,NomUnidad  
  ,IdContrato  
  ,Concepto  
  ,ClaDireccion  
  ,ClaCRC  
  ,ClaTipoGasto  
  ,Cantidad  
  ,Kilos  
  ,PrecioUnitario  
  ,Descuento  
  ,ImporteNeto  
  ,PorcentajeIVA  
  ,ImporteIVA  
  ,ImporteTotal  
  ,ClaUsuarioMod  
  ,FechaUltimaMod  
  ,NombrePcMod  
 FROM @CXPTmpEntradaMaquilaDet  
 IF @pnEsDebug = 1  
 BEGIN  
  SELECT ''as'CXP_6OFGRALES_LNKSVR.CxP.CxpSch.CXPTmpEntradaMaquilaDet ',* FROM CXP_6OFGRALES_LNKSVR.CxP.CxpSch.CXPTmpEntradaMaquilaDet  
  WHERE IdControlRecepcion = @IdControlRecepcion AND ClaUbicacion = @pnClaUbicacion  
 END  
 END TRY  
 BEGIN CATCH  
 PRINT ERROR_MESSAGE()  
 IF @@ERROR<>0  
 BEGIN  
  print 'error'  
  SET @pnError = 1  
  SET @psMensajeError = ERROR_MESSAGE()  
  SET @psMensajeError = 'Error al registrar detalles de Cxp: '+ISNULL(@psMensajeError, '')  
  PRINT @psMensajeError  
  GOTO FIN  
 END  
 END CATCH  
   
 IF @pnEsDebug = 1  
 BEGIN  
  PRINT 'CXP_6OFGRALES_LNKSVR.CxP.CxpSch.[CxP_CU1_Pag15_RecibirEntradaMaquilaAut_Srv]'  
  PRINT @pnClaUbicacion  
  PRINT @nClaSistemaOrigen  
  PRINT @IdControlRecepcion  
  PRINT @IdControlRecepcionUnico  
 END  
   
 BEGIN TRY  
  EXEC CXP_6OFGRALES_LNKSVR.CxP.CxpSch.[CxP_CU1_Pag15_RecibirEntradaMaquilaAut_Srv]  
   @pnClaUbicacion     = @pnClaUbicacion,  
   @pnClaSistema     = @nClaSistemaOrigen,  
   @pnIdControlRecepcion   = @IdControlRecepcion,  
   @pnIdControlRecepcionUnico  = @IdControlRecepcionUnico,   
   @pnError   = @pnError OUT,  
   @psMensajeError     = @psMensajeError OUTPUT,  
   @pnMovsAutorizados    = @nMovsAutorizados OUT,   
   @pnMovsConError     = @nMovsConError OUT,  
   @pnClaUsuarioMod    = @pnClaUsuarioMod,  
   @psNombrePcMod     = @psNombrePcMod,  
   @psIdioma      = @psIdioma  
  IF @@ERROR <> 0 OR @nMovsConError > 0  
  BEGIN  
   SET @psMensajeError = ''  
   SELECT @psMensajeError = @psMensajeError+ISNULL(ErroresRecepcion,'')+';'+ISNULL(MensajeRecepcion,'')  
   FROM CXP_6OFGRALES_LNKSVR.CxP.CxpSch.CXPTmpEntradaMaquila  
   WHERE IdControlRecepcion = @IdControlRecepcion AND ClaUbicacion = @pnClaUbicacion AND ClaEstatusRecepcion <> 1  
   SET @pnError = 1  
   SET @psMensajeError = 'Error al autorizar Control de Cxp (movimientos autorizados '+  
        convert(varchar,ISNULL(@nMovsAutorizados,0))+  
        ', movimientos con error '+convert(varchar,ISNULL(@nMovsConError,0))+  
        '): '+ISNULL(@psMensajeError, '')  
   GOTO FIN  
  END  
  IF @pnEsDebug = 1  
  BEGIN  
   PRINT @pnError  
   PRINT @psMensajeError  
   PRINT @nMovsAutorizados  
   PRINT @nMovsConError  
   PRINT @pnClaUsuarioMod  
   PRINT @psNombrePcMod  
  END  
 END TRY  
 BEGIN CATCH  
 PRINT ERROR_MESSAGE()  
  print 'ERROR AL EJECUTAR CXP_6OFGRALES_LNKSVR.CxP.CxpSch.[CxP_CU1_Pag15_RecibirEntradaMaquilaAut_Srv]'  
  SET @pnError = 1  
  SET @psMensajeError = ERROR_MESSAGE()  
  SET @psMensajeError = 'Excepcion al autorizar en Cxp: '+ISNULL(@psMensajeError, '')  
  PRINT @psMensajeError  
  GOTO FIN  
 END CATCH  
   
 UPDATE t0  
 SET   
   t0.EnviadoCxp    = CASE WHEN t2.ClaEstatusRecepcion = 1 /*1-Recibido en CXP*/THEN 1 ELSE 0 END  
  ,t0.IdControlRecepcion  = t2.IdControlRecepcion  
  ,t0.IdControlRecepcionUnico = t2.IdControlRecepcionUnico  
  ,t0.MensajeRecepcion  = t2.MensajeRecepcion  
  ,t0.ErroresRecepcion  = t2.ErroresRecepcion  
  ,t0.FechaUltimaMod   = GETDATE()  
  ,t0.ClaUsuarioMod   = @pnClaUsuarioMod  
  ,t0.NombrePcMod    = @psNombrePcMod  
 FROM OpeSch.OpeTraRecepOrdenMaquila t0 INNER JOIN @CXPTmpEntradaMaquila t1  
  ON t1.ClaUbicacion = t0.ClaUbicacion  
  AND t1.IdEntradaMaquila = t0.IdRecepOrdenMaquila  
 LEFT JOIN CXP_6OFGRALES_LNKSVR.CxP.CxpSch.CXPTmpEntradaMaquila t2  
  ON t2.ClaUbicacion = t1.ClaUbicacion  
  AND t2.IdEntradaMaquila = t1.IdEntradaMaquila  
  AND t2.IdControlRecepcion = t1.IdControlRecepcion  
  AND t2.IdControlRecepcionUnico = t1.IdControlRecepcionUnico  
   
 IF @pnEsDebug = 1  
 BEGIN  
  SELECT '' as 'OpeTraRecepOrdenMaquila',t0.* , t1.*  
  FROM OpeSch.OpeTraRecepOrdenMaquila t0 INNER JOIN @CXPTmpEntradaMaquila t1  
   ON t1.ClaUbicacion = t0.ClaUbicacion  
   AND t1.IdEntradaMaquila = t0.IdRecepOrdenMaquila  
  LEFT JOIN CXP_6OFGRALES_LNKSVR.CxP.CxpSch.CXPTmpEntradaMaquila t2  
   ON t2.ClaUbicacion = t1.ClaUbicacion  
   AND t2.IdEntradaMaquila = t1.IdEntradaMaquila  
   AND t2.IdControlRecepcion = t1.IdControlRecepcion  
   AND t2.IdControlRecepcionUnico = t1.IdControlRecepcionUnico  
 END  
   
FIN:  
SET NOCOUNT OFF  
SET XACT_ABORT OFF  
END
