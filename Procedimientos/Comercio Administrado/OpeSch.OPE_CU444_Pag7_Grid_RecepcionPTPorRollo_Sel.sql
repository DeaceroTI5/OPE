USE Operacion
-- EXEC SP_HELPTEXT 'OpeSch.OPE_CU444_Pag7_Grid_RecepcionPTPorRollo_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU444_Pag7_Grid_RecepcionPTPorRollo_Sel
--DECLARE  
   @pnClaUbicacion INT     
 , @pnClaPlanCarga INT  
AS  
BEGIN  
 SET NOCOUNT ON  
 -- SELECT @pnClaUbicacion=11,@pnClaPlanCarga=123201  
    DECLARE @sAlmacenCuarentena VARCHAR(20)  
 DECLARE @nClaAlmacenCuarentenaTraspasos INT, @nClaAlmacenCuarentenaDevoluciones INT, @ClaTipoInventario INT, @nClaUnidadKilos INT  
        
 SELECT  @ClaTipoInventario = 1,  -- INVENTARIO DE PRODUCTO TERMINADO  
   @nClaUnidadKilos = 1   -- ?  
   
 CREATE TABLE #ProductosParaCarga   
  (  
     ClaPedido   INT    , ClaPedidoDet  INT    , ClaArticulo  INT   , ClaveArticulo VARCHAR(20)  , NomArticulo VARCHAR(100)  
   , NomFamilia  VARCHAR(100)  
   , CantPlan   NUMERIC(22,4) , ClaUnidad   INT    , NomUnidad   VARCHAR(20) , CantEmbarcada NUMERIC(22,4) , Observaciones VARCHAR(20)  
   , EsCancelado  INT    , EsContadoYKilos INT    , AceptaParcialidad INT  
   , ClaveArticuloAto VARCHAR(20)  , Existencia  NUMERIC(22,4) , ConReferencias INT  
   , OrdenAcomodo  INT    , NomMarca   VARCHAR(20)  , ClaCliente  INT   , ClaConsignado INT  
   , PesoKgs   NUMERIC(22,4) , Vejez    INT    , Destino   VARCHAR(250), Referencias VARCHAR(20), MultiAlmacen INT, ClaAlmacen INT)  
        
 CREATE TABLE #ProductoConReferencia (ClaArticulo INT, ClaFamilia INT, ClaSubFamilia INT, EsRequerida INT)
 
 DECLARE @tbRelPlanCargaViajeOrigen TABLE ( IdFabricacion INT, IdFabricacionDet INT, ClaArticulo INT, CantDocumentada NUMERIC(22,4))
      
 SELECT @nClaAlmacenCuarentenaDevoluciones = NumValor1  
 FROM OpeSch.OpeCfgParametroNegVw WITH(NOLOCK)  
 WHERE ClaParametro = 25 AND   
   ClaUbicacion = @pnClaUbicacion AND   
   ISNULL(BajaLogica,0) = 0   
   
  -- Obtener Almacen de Cuarentena de Traspaso  
  SELECT @nClaAlmacenCuarentenaTraspasos = NumValor1  
  FROM OpeSch.OpeCfgParametroNegVw WITH(NOLOCK)  
  WHERE ClaParametro = 26 AND  
   ClaUbicacion = @pnClaUbicacion AND   
   ISNULL(BajaLogica,0) = 0    
  
 -- OBTENER LOS PRODUCTOS QUE APARECEN EN MÁS DE UN ALMACEN   
 SELECT @sAlmacenCuarentena=sValor1  
 FROM OpeSch.OpeCatConfiguracionVw with (nolock) 
 WHERE ClaTipoInventario = 1      -- PT  
 AND  ClaUbicacion  = @pnClaUbicacion   
 AND  ClaSistema   = 23      -- Inventario  
 AND  ClaConfiguracion = 111      -- Clave de Almacenes de Cuarentena     
  
 DECLARE @tbAlamcenesCuarentena TABLE (claAlmacen INT)  
    
 INSERT INTO @tbAlamcenesCuarentena  ( claAlmacen )    
 SELECT * FROM OpeSch.OpeSplitFn(@sAlmacenCuarentena,',')  
    
    CREATE TABLE #ProductoMultiAlmacen (ClaArticulo INT, TotalAlmacenes INT)  
      
    INSERT INTO #ProductoMultiAlmacen (ClaArticulo, TotalAlmacenes)  
    SELECT ClaArticulo, COUNT(ClaAlmacen)  
    FROM (  
   SELECT DISTINCT e.ClaArticulo, e.ClaAlmacen  
   FROM OpeSch.OpeTraExistencias e  with (nolock)
   WHERE e.ClaUbicacion = @pnClaUbicacion   
   AND e.ClaAlmacen NOT IN (SELECT ClaAlmacen FROM @tbAlamcenesCuarentena)  
   AND e.ClaTipoInventario = 1  
   AND e.Cantidad > 0  
  ) X  
 GROUP BY ClaArticulo  
 HAVING COUNT(ClaAlmacen) > 1  
      
 INSERT INTO #ProductoConReferencia (ClaArticulo, ClaFamilia, ClaSubFamilia)  
 SELECT DISTINCT a.ClaArticulo, a.ClaFamilia, a.ClaSubFamilia  
 FROM OpeSch.OpeArtCatArticuloVw a with (nolock) 
 INNER JOIN OpeSch.OpeTraPlanCargaDet pcd ON pcd.ClaArticulo = a.ClaArticulo    
 WHERE pcd.ClaUbicacion = @pnClaUbicacion  
 AND pcd.IdPlanCarga = @pnClaPlanCarga  
        
  
 UPDATE #ProductoConReferencia  
 SET EsRequerida = 1  
 FROM #ProductoConReferencia pr  
 INNER JOIN OpeSch.OpeRelTipoRefArticulo ref with (nolock)  
  ON ref.ClaTipoInventario = 1   
  AND ref.ClaFamilia = pr.ClaFamilia   
  AND (  
    IsNull(ref.ClaSubFamilia, -1) = -1  
    OR (IsNull(ref.ClaSubFamilia, -1) = pr.ClaSubFamilia AND IsNull(ref.ClaArticulo, -1) = -1)   
    OR (IsNull(ref.ClaSubFamilia, -1) = pr.ClaSubFamilia AND IsNull(ref.ClaArticulo, -1) = pr.ClaArticulo))  
 WHERE ref.ClaUbicacion = @pnClaUbicacion   
 AND ref.BajaLogica = 0  
    
 INSERT INTO #ProductosParaCarga (ClaPedido, ClaPedidoDet, ClaArticulo, ClaveArticulo, NomArticulo, NomFamilia,   
 CantPlan, ClaUnidad, NomUnidad, CantEmbarcada  , Observaciones, ClaveArticuloAto, EsCancelado, Existencia,   
 EsContadoYKilos, AceptaParcialidad, ConReferencias, OrdenAcomodo, NomMarca,  
 ClaCliente, ClaConsignado, PesoKgs, Vejez, Destino, Referencias, MultiAlmacen, ClaAlmacen)   
 SELECT   
    ClaPedido2  = Det.IdFabricacion  
  , ClaPedidoDet2  = Det.IdFabricacionDet  
  , ClaArticulo  = Det.ClaArticulo  
  , ClaveArticulo2 = b.ClaveArticulo  
  , NomArticulo  = b.NomArticulo  
  , NomFamilia  = fam.NomFamilia    
  , CantPlan   = MAX(Det.CantEmbarcada)  
  , ClaUnidad   = F.ClaUnidad  
  , NomUnidad   = F.NomUnidad  
  , CantEmbarcada  = IsNull(Sum(a.CantEmbarcada), 0)  
  , Observaciones  = CONVERT(INT, SUM(CASE   
         WHEN OpeSch.IsReallyNumeric(a.Observaciones) = 1 THEN CONVERT(INT, a.Observaciones)  
         ELSE 0  
        END))  
  , ClaveArticuloAto = IsNull(ArtAto.ClaveArticulo, 'N/A')  
  , EsCancelado  = CASE WHEN h1.ClaEstatus = 3 OR d1.ClaEstatus = 3 THEN 1 ELSE 0 END  
  , Existencia  = (SELECT  CONVERT(FLOAT, SUM(ISNULL(Cantidad,0))) AS Existencia  
        FROM  OpeSch.OpeCTraExistenciasVw exVw WITH(NOLOCK)  
        WHERE  ClaUbicacion   = @pnClaUbicacion  
        AND   exVw.ClaTipoInventario = 1  
        AND   exVw.ClaAlmacen <> @nClaAlmacenCuarentenaDevoluciones  
        AND   exVw.ClaAlmacen <> @nClaAlmacenCuarentenaTraspasos  
        AND   ClaArticulo  = Det.ClaArticulo)  
  , EsContadoYKilos = CASE   
         WHEN h1.EsContado = 1 AND f.ClaUnidad = 1 THEN 1  
         ELSE 0  
        END  
  , AceptaParcialidad = ISNULL(EsAceptadaParcialidad, 0)  
  , ConReferencias = CASE WHEN EXISTS (SELECT 1 FROM #ProductoConReferencia cr WHERE cr.ClaArticulo = det.ClaArticulo AND cr.EsRequerida = 1) THEN 1 ELSE 0 END  
  , OrdenAcomodo  = Det.OrdenAcomodo   --OrdenAcomodo  = ROW_NUMBER() OVER(PARTITION BY Det.IdFabricacion ORDER BY Det.OrdenAcomodo asc)   
  , NomMarca   = UPPER(mar.NomMarca)  
  , ClaCliente  = ISNULL(ClaCliente, 0)  
  , ClaConsignado  = ISNULL(ClaConsignado,0)  
  , PesoKgs   = CONVERT(FLOAT, ISNULL(CONVERT(FLOAT, MAX(Det.CantEmbarcada)), 0) * ISNULL( b.PesoTeoricoKgs, 0))  
  , Vejez    = DATEDIFF(d, ISNULL(h1.FechaPromesaActual, ISNULL(h1.FechaBaseFabricacion, ISNULL(h1.FechaPromesaOrigen, GETDATE()))), GETDATE())  
  , Destino   = ISNULL(ciudad.NomCiudad,'') + ', ' + ISNULL(estado.NomEstado,'')  
  , Referencias  = CASE   
        WHEN EXISTS (SELECT 1 FROM #ProductoConReferencia cr WHERE cr.ClaArticulo = det.ClaArticulo AND cr.EsRequerida = 1) THEN 'Capturar'   
        WHEN EXISTS (SELECT 1 FROM #ProductoMultiAlmacen ma WHERE ma.ClaArticulo = det.ClaArticulo) THEN 'Capturar'   
        ELSE ''   
         END    
  , MultiAlmacen  = CASE WHEN EXISTS (SELECT 1 FROM #ProductoMultiAlmacen ma WHERE ma.ClaArticulo = det.ClaArticulo) THEN 1 ELSE 0 END  
  , ClaAlmacen  = a.ClaAlmacen  
 from OpeSch.OpeTraPlanCargaDet Det   with (nolock)
 LEFT OUTER JOIN OpeSch.OpeTraPlanCargaLocInv a   with (nolock)   ON a.ClaUbicacion = Det.ClaUbicacion AND a.IdPlanCarga = Det.IdPlanCarga  AND a.ClaArticulo = Det.ClaArticulo  AND a.IdFabricacion = Det.IdFabricacion  
 AND a.IdFabricacionDet = Det.IdFabricacionDet  LEFT OUTER JOIN OpeSch.OpeArtCatArticuloVw (NOLOCK) b   ON b.claTipoInventario = 1 AND b.claArticulo = Det.ClaArticulo    
 LEFT OUTER JOIN OpeSch.OpeArtCatFamiliaVw (NOLOCK) fam   ON b.ClaTipoInventario = fam.ClaTipoInventario AND b.ClaFamilia = fam.ClaFamilia  
 LEFT OUTER JOIN OpeSch.OPeArtCatMarcaVw mar with (nolock)     ON b.ClaMarca = mar.ClaMarca         
 LEFT OUTER JOIN OpeSch.OpeCatAlmacenVw (NOLOCK) d    ON d.claTipoInventario = 1 AND d.claAlmacen = a.ClaAlmacen  AND d.ClaUbicacion = Det.ClaUbicacion        
 LEFT OUTER JOIN OpeSch.OpeCatSubAlmacenVw (NOLOCK) e   ON e.claTipoInventario = 1 AND e.claAlmacen = a.ClaAlmacen  AND e.claSubAlmacen = a.ClaSubAlmacen AND e.ClaUbicacion = Det.ClaUbicacion        
 LEFT OUTER JOIN OpeSch.OpeArtCatUnidadVw (NOLOCK) f    ON f.claTipoInventario = 1 AND f.claUnidad = b.ClaUnidadBase  
 LEFT OUTER JOIN PleSch.PleAgCatProductoEquivalenciaVw RelAto ON RelAto.ClaProducto = Det.ClaArticulo AND RelAto.BajaLogica = 0 AND ClaPlanta = @pnClaUbicacion  
 LEFT OUTER JOIN OpeSch.OpeArtCatArticuloVw ArtAto with (nolock)   ON ArtAto.ClaTipoInventario = 1 AND ArtAto.ClaArticulo = RelAto.ClaProductoAto  
 LEFT OUTER JOIN OpeSch.OpeTraFabricacionVw (NOLOCK) h1    ON h1.idFabricacion = det.idfabricacion and h1.ClaPlanta = det.ClaUbicacion  
 LEFT OUTER JOIN OpeSch.OpeTraFabricacionDetVw (NOLOCK) d1  ON d1.idFabricacion = det.idfabricacion and d1.idFabricaciondet = det.idFabricaciondet  
 LEFT OUTER JOIN OpeSch.OpeVtaCatCiudadVw ciudad WITH(NOLOCK) ON (ciudad.ClaCiudad = h1.ClaCiudad)  
 LEFT OUTER JOIN OpeSch.OpeVtaCatEstadoVw estado WITH(NOLOCK) ON (estado.clapais  = ciudad.ClaPais AND estado.claestado= ciudad.ClaEstado)  
 where Det.idPlanCarga = @pnClaPlanCarga   
 and Det.ClaUbicacion = @pnClaUbicacion  
 AND Det.CantEmbarcada > 0  
 Group by Det.OrdenAcomodo, Det.ClaUbicacion, Det.IdPlanCarga , Det.ClaArticulo, Det.IdFabricacion, Det.IdFabricacionDet ,              
  Det.CantPorSurtir,   
  b.ClaveArticulo,  
  b.NomArticulo,  
  fam.NomFamilia,  
  f.claUnidad,  
  f.NomUnidad,  
  mar.NomMarca,  
  ArtAto.ClaveArticulo,  
  h1.EsContado,  
  ISNULL(EsAceptadaParcialidad, 0),  
  ClaCliente,  
  ClaConsignado,  
  CASE WHEN h1.ClaEstatus = 3 OR d1.ClaEstatus = 3 THEN 1 ELSE 0 END,  
  b.PesoTeoricoKgs,  
  h1.FechaPromesaActual,  
  h1.FechaBaseFabricacion,   
  h1.FechaPromesaOrigen,  
  ciudad.NomCiudad,  
  estado.NomEstado,  
  a.ClaAlmacen  
 order by Max(Det.OrdenAcomodo) asc, Det.IdFabricacionDet asc  
  
	-- Calcula Cantidad Documentada a nivel de partida para el Plan de Carga
	INSERT INTO @tbRelPlanCargaViajeOrigen (IdFabricacion, IdFabricacionDet, ClaArticulo, CantDocumentada)
	SELECT	a.IdFabricacion, a.IdFabricacionDet, a.ClaArticulo, CantDocumentada = SUM(CantDocumentada) 
	FROM	OpeSch.OpeRelPlanCargaViajeOrigenDet a WITH(NOLOCK)
	INNER JOIN #ProductosParaCarga b
	ON		a.IdFabricacion		= b.ClaPedido
	AND		a.IdFabricacionDet	= b.ClaPedidoDet
	AND		a.ClaArticulo		= b.ClaArticulo
	WHERE	a.ClaUbicacion	= @pnClaUbicacion
	AND		a.IdPlanCarga	= @pnClaPlanCarga
	AND		a.BajaLogica	= 0
	GROUP BY a.IdFabricacion, a.IdFabricacionDet, a.ClaArticulo

DECLARE @sRutaImagen VARCHAR(200)
SELECT @sRutaImagen = '..\Common\Images\WebToolImages'

 SELECT   
    Pintar   = CASE WHEN ord.NuevoOrd % 2 = 0 THEN 1 ELSE 2 END  
  , dat.OrdenAcomodo  
  , dat.ClaCliente  
  , dat.ClaConsignado  
  , ClaPedido2  = ClaPedido  
  , ClaPedidoDet2  = ClaPedidoDet  
  , dat.ClaArticulo  
  , ClaveArticulo2 = ClaveArticulo  
  , NomArticulo  
  , NomFamilia  
  , CantPlan   = CONVERT(FLOAT, ISNULL(CantPlan, 0))  
  , ClaUnidad  
  , NomUnidad  
  , CantEmbarcada  = CONVERT(FLOAT, ISNULL(CantEmbarcada, 0))  
  , CantDocumentada = c.CantDocumentada
  , Observaciones  = CONVERT(INT, CASE   
          WHEN OpeSch.IsReallyNumeric(Observaciones) = 1 THEN CONVERT(INT, Observaciones)  
          ELSE 0  
         END)  
  , EsCancelado  
  , EsContadoYKilos  
  , AceptaParcialidad = CASE WHEN EsCancelado = 1 THEN 1 ELSE AceptaParcialidad END  
  , ClaveArticuloAto  
  , Existencia  
  , ConReferencias  
  , NuevoOrd  
  , NomMarca  
  , PesoKgs  
  , Vejez  
  , Destino  
  , Pintado   = ''  
  , Referencias    
  , MultiAlmacen    
  , ClaAlmacen  
--  , RelViajeOrigen = 'Relacionar'
  , RelViajeOrigen =	CASE WHEN c.ClaArticulo IS NULL 
							THEN '<img src="'+@sRutaImagen+'/Agregar16.png" />' 
							ELSE '<img src="'+@sRutaImagen+'/Pencil16.png" />' END
 FROM #ProductosParaCarga  dat  
 INNER JOIN ( SELECT NuevoOrd = ROW_NUMBER() OVER (ORDER BY MIN(OrdenAcomodo), ClaCliente, ClaConsignado),  
       MinOrdenAcomodo = MIN(OrdenAcomodo),   
       ClaCliente,   
       ClaConsignado  
     FROM #ProductosParaCarga  
     GROUP BY ClaCliente, ClaConsignado  
    ) ord ON (dat.ClaCliente   = ord.ClaCliente  
       AND dat.ClaConsignado = ord.ClaConsignado)  
 LEFT JOIN @tbRelPlanCargaViajeOrigen c
 ON		dat.ClaPedido		= c.IdFabricacion
 AND	dat.ClaPedidoDet	= c.IdFabricacionDet
 AND	dat.ClaArticulo		= c.ClaArticulo
 ORDER BY dat.OrdenAcomodo, ClaPedidoDet2  
  
 DROP TABLE #ProductoConReferencia  
 DROP TABLE #ProductoMultiAlmacen  
  
 SET NOCOUNT OFF  
END