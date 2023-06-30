USE Operacion
GO
ALTER PROCEDURE OpeSch.OPE_CU444_Pag7_Grid_GridProductoReferencias_IU
   @pnClaUbicacion  INT  
    , @pnClaPlanCarga  INT  
    , @pnClaPedido   INT  
    , @pnClaPedidoDet  INT  
    , @psClaveArticulo  VARCHAR(20)  
    , @pnClaArticuloAux  INT  
--    , @pnClaTipoReferencia INT    -- 1  
    , @psOPM    VARCHAR(20)  
 , @psRollo    VARCHAR(20)  
 , @psCarrete   VARCHAR(20) = NULL  
 , @pnAgrega    INT  
 , @pnClaUsuarioMod  INT  
 , @psNombrePcMod  VARCHAR(64)  
AS  
BEGIN  
 DECLARE @sErrorMsg VARCHAR(200)  
 --- NO MODIFICAR CARGA FINALIZADA!!!!!  
 DECLARE @EsCargaFinalizada INT  
 DECLARE @nClaTara INT, @nPesoTara NUMERIC(22,4), @nCantTara INT, @nPesoTaraTotal NUMERIC(22,4)  

 SELECT @EsCargaFinalizada = EsCargaTerminada  
 FROM OpeSch.OpeTraPlanCarga WITH(NOLOCK)  
 WHERE ClaUbicacion = @pnClaUbicacion   
 AND IdPlanCarga = @pnClaPlanCarga  

 IF @EsCargaFinalizada = 1  
 BEGIN  
  SELECT @sErrorMsg = 'No se puede modificar una carga finalizada'  
  GOTO ERROR  
 END  

 DECLARE @nExiste INT, @nCantidad NUMERIC(22,4), @nKilosTeoricos NUMERIC(22,4), @nIdRenglon INT  
 DECLARE @nClaAlmacen INT, @nClaSubAlmacen INT, @nClaSeccion INT, @nClaTipoInventario INT  ,@nClaSubSubAlmacen INT
 DECLARE @sReferencia1 VARCHAR(20), @sReferencia2 VARCHAR(20), @sReferencia6 VARCHAR(20)  

 SELECT @nClaAlmacen = 1, @nClaSubAlmacen = NULL, @nClaSeccion = NULL, @nClaTipoInventario = 1  
 SELECT @sReferencia1 = NULL, @sReferencia2 = NULL, @sReferencia6 = NULL   

 -- BUSCAR EL PRODUCTO EN EXISTENCIA Y OBTENER CANTIDAD, PESO, ALMACEN, SUBALMACEN, SECCION, ETC  
 SELECT @nCantidad = Cantidad, @nKilosTeoricos = KilosTeoricos, @nClaAlmacen = ClaAlmacen
		,@nClaSeccion = ClaSeccion, @nClaSubAlmacen = ClaSubAlmacen, @nClaSubSubAlmacen = ClaSubSubAlmacen	-- Hv_20230629
 FROM OpeSch.OpeTraExistencias Ex WITH(NOLOCK)  
 WHERE Ex.ClaUbicacion = @pnClaUbicacion  
 AND Ex.ClaArticulo = @pnClaArticuloAux  
 AND Ex.ClaTipoReferencia1 = 3   
 AND Ex.ValorReferencia1 = @psOPM   
 AND Ex.ValorReferencia2 = @psRollo  
 AND Ex.ClaTipoInventario = 1  
 AND Ex.ClaAlmacen NOT IN (2,3)  ----RCASTRO, MLMTZR. 20160714. Se cambio a que obtuviera todo excluyendo lo de cuarentena    
 AND Ex.Cantidad > 0   

 IF EXISTS( SELECT 1 FROM OpeSch.OpeTraPlanCargaLocInv   WITH(NOLOCK) 
     WHERE ClaUbicacion = @pnClaUbicacion   
     AND IdPlanCarga = @pnClaPlanCarga  
     AND IdFabricacion = @pnClaPedido  
     AND IdFabricacionDet = @pnClaPedidoDet  
     AND ClaArticulo = @pnClaArticuloAux   
     AND (  
      (referencia3 = @psOpm AND referencia4 = @psRollo AND referencia3 IS NOT NULL AND referencia4 IS NOT NULL)  
      OR  
      (referencia5 = @psCarrete AND referencia5 IS NOT NULL)  
      ) )  
  SELECT @nExiste = 1    
 ELSE  
  SELECT @nExiste = 0  

 IF @nExiste = @pnAgrega  
 BEGIN  
  -- NO CAMBIÓ  
  RETURN  
 END  

 IF @nExiste = 1 AND @pnAgrega = 0  
 BEGIN  
  DELETE OpeSch.OpeTraPlanCargaLocInv
  WHERE ClaUbicacion = @pnClaUbicacion   
  AND IdPlanCarga = @pnClaPlanCarga  
  AND IdFabricacion = @pnClaPedido  
  AND IdFabricacionDet = @pnClaPedidoDet  
  AND ClaArticulo = @pnClaArticuloAux   
  AND ((referencia3 = @psOpm AND referencia4 = @psRollo AND referencia3 IS NOT NULL AND referencia4 IS NOT NULL)  
   OR  
    (referencia5 = @psCarrete AND referencia5 IS NOT NULL))  
 END  

 IF @nExiste = 0 AND @pnAgrega = 1  
 BEGIN  
  -- OBTENER CONSECUTIVO DE LOCINV  
  SELECT @nIdRenglon = MAX(IdRenglon)  
  FROM OpeSch.OpeTraPlanCargaLocInv   WITH(NOLOCK)
  WHERE ClaUbicacion = @pnClaUbicacion   
  AND IdPlanCarga = @pnClaPlanCarga  
  AND IdFabricacion = @pnClaPedido  
  AND IdFabricacionDet = @pnClaPedidoDet  
  AND ClaArticulo = @pnClaArticuloAux   
  
  SELECT @nIdRenglon = ISNULL(@nIdRenglon, 0) + 1   
  
  INSERT INTO OpeSch.OpeTraPlanCargaLocInv(ClaUbicacion, IdPlanCarga, IdFabricacion, IdFabricacionDet, IdRenglon, ClaArticulo, ClaAlmacen, ClaSubAlmacen, ClaSeccion, 
  Referencia1, Referencia2, Referencia3, Referencia4, Referencia5, Referencia6, ClaTipoInventario, CantEmbarcada, PesoEmbarcado, FechaUltimaMod, NombrePcMod, ClaUsuarioMod, IdBoleta, KilosReales, PorcentajeMaterial, Observaciones, EsPesajeParcial, ClaTipoReferencia, IdPesajeParcial, KilosMaterial)  
  VALUES(@pnClaUbicacion, @pnClaPlanCarga, @pnClaPedido, @pnClaPedidoDet, @nIdRenglon, @pnClaArticuloAux, @nClaAlmacen, @nClaSubAlmacen, @nClaSeccion, 
  @sReferencia1, @sReferencia2, @psOpm, @psRollo, @psCarrete, @sReferencia6, @nClaTipoInventario, @nCantidad, @nKilosTeoricos, GETDATE(), @psNombrePcMod, @pnClaUsuarioMod, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL)  
 END  

 -- ACTUALIZAR OpeSch.OpeTraPlanCargaTara  
 -- SEGÚN ARTÍCULO Y UBICACIÓN SE OBTIENE ClaTara y PesoTara  
 SELECT TOP 1 @nClaTara = t.ClaTara, @nPesoTara = t.PesoTara  
 FROM OpeSch.OpeRelArticuloTara AT   WITH(NOLOCK)
 INNER JOIN OpeSch.OpeCatTara T ON AT.ClaTara = T.ClaTara  
 WHERE AT.ClaArticulo = @pnClaArticuloAux  
 AND AT.ClaUbicacion = @pnClaUbicacion  
 AND AT.BajaLogica = 0  
 AND T.EsRetornable = 1  
 AND T.BajaLogica = 0  
 ORDER BY Prioridad ASC  

 IF @nClaTara IS NOT NULL  
 BEGIN   
  -- OBTENEMOS CUANTOS REGISTROS CON REFERENCIAS SE HAN INGRESADO PARA ESE ARTICULO, PEDIDO, PEDIDODET  
  SELECT @nCantTara = COUNT(*)  
  FROM OpeSch.OpeTraPlanCargaLocInv   WITH(NOLOCK)
  WHERE ClaUbicacion = @pnClaUbicacion  
  AND IdPlanCarga = @pnClaPlanCarga  
  AND IdFabricacion = @pnClaPedido  
  AND IdFabricacionDet = @pnClaPedidoDet  

  SELECT @nPesoTaraTotal = @nCantTara * @nPesoTara  

  IF EXISTS   
   (  
    SELECT 1   
    FROM OpeSch.OpeTraPlanCargaTara    WITH(NOLOCK)
    WHERE ClaUbicacion = @pnClaUbicacion   
    AND IdPlanCarga = @pnClaPlanCarga   
    AND IdFabricacion = @pnClaPedido   
    AND IdFabricacionDet = @pnClaPedidoDet  
   )  
  BEGIN  
   -- UPDATE  
   UPDATE PCT  
   SET   
      CantTara   = @nCantTara  
    , PesoTara   = @nPesoTaraTotal  
    , FechaUltimaMod = GETDATE()  
    , NombrePcMod  = @psNombrePcMod   
    , ClaUsuarioMod  = @pnClaUsuarioMod  
   FROM OpeSch.OpeTraPlanCargaTara PCT WITH(NOLOCK)
   WHERE ClaUbicacion = @pnClaUbicacion   
   AND IdPlanCarga = @pnClaPlanCarga   
   AND IdFabricacion = @pnClaPedido   
   AND IdFabricacionDet = @pnClaPedidoDet  
  END  
  ELSE  
  BEGIN  
   -- INSERT  
   INSERT INTO OpeSch.OpeTraPlanCargaTara (ClaUbicacion, IdPlanCarga, IdFabricacion, IdFabricacionDet, ClaTara, CantTara, PesoTara, FechaUltimaMod, NombrePcMod, ClaUsuarioMod)  
   VALUES (@pnClaUbicacion, @pnClaPlanCarga, @pnClaPedido, @pnClaPedidoDet, @nClaTara, @nCantTara, @nPesoTaraTotal, GETDATE(), @psNombrePcMod, @pnClaUsuarioMod)  
  END  
 END  

 -- GUARDAR EN REGISTRO DE ETAPAS DE PLAN DE CARGA (Inicio de Carga)  
 IF (ISNULL(@pnClaUbicacion, -1) > 0 AND ISNULL(@pnClaPlanCarga, -1) > 0)  
  IF NOT EXISTS (SELECT 1 FROM OpeSch.OpeLogPlanCarga  WITH(NOLOCK) WHERE ClaUbicacion = @pnClaUbicacion AND IdPlanCarga = @pnClaPlanCarga AND TipoRegistro = 30)  
   IF EXISTS (SELECT 1 FROM OpeSch.OpeTraPlanCargaLocInv  WITH(NOLOCK) WHERE ClaUbicacion = @pnClaUbicacion AND IdPlanCarga = @pnClaPlanCarga)  
    INSERT INTO OpeSch.OpeLogPlanCarga (ClaUbicacion, IdPlanCarga, TipoRegistro, FechaUltimaMod, ClaUsuarioMod, NombrePcMod)  
    SELECT @pnClaUbicacion, @pnClaPlanCarga, 30, GETDATE(), @pnClaUsuarioMod, @psNombrePcMod  
 RETURN  

ERROR:  
 RAISERROR(@sErrorMsg,16,1)  
 RETURN  
END