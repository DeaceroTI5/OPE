ALTER PROCEDURE OpeSch.OPE_CU74_Pag1_Grid_GridDetalleMF_Sel
 @pnOCMF INT,      
 @pnViajeMF INT,      
 @pnClaUbicacion INT      
AS       
BEGIN      
    
 SET NOCOUNT ON    
    
    
 CREATE TABLE #temp70det(  FactSal INT,     idFabricacion INT,     claCliente INT,     nombreCliente VARCHAR (70),     FechaPromesaActual DATETIME,     comentarios VARCHAR (max),     porcMin NUMERIC (22, 4),     total BIT,     esFact INT,     esUltimoPsg 

  
BIT,     esTotModif INT, PintarRojo INT)      
    
 DECLARE @esindustrial INT, @id_ped INT,  @id_art INT,  @idFab INT,  @idFabDet INT,  @ClaArt INT,  @ClaveArt VARCHAR(50),  @comentarios VARCHAR(MAX),      
   @comentariosAct VARCHAR(MAX),  @rollos NUMERIC(22,4), @clatipoempaque INT, @tipoempaque VARCHAR(50),  @piezas NUMERIC(22,4),   @stotrollos VARCHAR(5000),      
   @totpiezas NUMERIC(22,4)      
       
                
 SELECT @esindustrial = CASE WHEN  ClaTipoUbicacion = 6 THEN 1 ELSE 0 END       
 FROM OpeSch.OPETiCatUbicacionVw WITH (nolock)      
 WHERE  ClaUbicacion = @pnClaUbicacion       
       
    
 INSERT INTO #temp70det(FactSal, idFabricacion, claCliente, nombreCliente, FechaPromesaActual,      
   comentarios, porcMin, total, esFact, esUltimoPsg, esTotModif )      
 EXEC OpeSch.OPETraMovEntSalBodSel 1,@pnOCMF,@pnViajeMF,0,NULL,@pnClaUbicacion      

	-------------------------
	DECLARE	  @nUbicacionSumDir			INT
   			, @nClaTransportistaDefault INT = NULL

    SELECT  @nUbicacionSumDir = ISNULL(nValor1,0)
    FROM    OpeSch.OpeTiCatConfiguracionVw
    WHERE   ClaUbicacion = @pnClaUbicacion
    AND     ClaSistema = 127
    AND     ClaConfiguracion = 1271224

	IF ISNULL(@nUbicacionSumDir,0)=1
	BEGIN
		UPDATE #temp70det
		SET		comentarios = 'La maniobra de descarga es por cuenta del cliente.'
		WHERE	ISNULL(comentarios,'') = ''
	END
	-------------------------
    
 CREATE TABLE #tPlaneado (IdFabricacion  INT,     
       IdFabricacionDet INT,     
       CantEmbarcada  NUMERIC(22,4),    
       PesoTeoricoKgs  NUMERIC(22,4))    
    
 CREATE TABLE #tSubido (IdFabricacion  INT,     
       IdFabricacionDet INT,     
       CantEmbarcada  NUMERIC(22,4),    
       PesoTeoricoKgs  NUMERIC(22,4))    
                 
 INSERT INTO #tPlaneado (IdFabricacion, IdFabricacionDet, CantEmbarcada, PesoTeoricoKgs)    
 SELECT IdFabricacion, IdFabricacionDet, CantEmbarcada, PesoTeoricoKgs = CantEmbarcada * PesoTeoricoKgs    
 FROM OpeSch.OpeTraPlanCargaDetTemp det WITH (NOLOCK)    
 LEFT JOIN OpeSch.OpeArtCatArticuloVw art ON (det.ClaArticulo    = art.ClaArticulo    
             AND art.ClaTIpoInventario = 1)    
 WHERE det.ClaUbicacion = @pnClaUbicacion    
 AND det.IdPlanCarga = @pnOCMF    
     
 /* SE CAMBIA POR LA TABLA DE PASO YA QUE PlanCargaDet se actualiza al finalizar carga    
 SELECT IdFabricacion, IdFabricacionDet, CantEmbarcada, PesoTeoricoKgs = CantEmbarcada * PesoteoricoKgs    
 FROM  OpeSch.OpeTraPlanCargaDet det WITH (NOLOCK)    
 LEFT JOIN OpeSch.OpeArtCatArticuloVw art ON (det.ClaArticulo    = art.ClaArticulo    
             AND art.ClaTIpoInventario = 1)    
 WHERE ClaUbicacion   = @pnClaUbicacion    
 AND  IdPlanCarga    = @pnOCMF    
 AND  ISNULL(CantEmbarcada, 0)> 0    
 */    
    
 INSERT INTO #tSubido (IdFabricacion, IdFabricacionDet, CantEmbarcada, PesoTeoricoKgs)    
 SELECT IdFabricacion, IdFabricacionDet, CantEmbarcada = SUM(CantEmbarcada), PesoTeoricoKgs = SUM(CantEmbarcada * PesoTeoricoKgs)    
 FROM OpeSch.OpeTraPlanCargaLocInv det WITH (NOLOCK)    
 LEFT JOIN OpeSch.OpeArtCatArticuloVw art ON (det.ClaArticulo    = art.ClaArticulo    
             AND art.ClaTIpoInventario = 1)    
 WHERE ClaUbicacion   = @pnClaUbicacion    
 AND  IdPlanCarga    = @pnOCMF    
 GROUP BY IdFabricacion, IdFabricacionDet    
    
    
 UPDATE det    
  SET PintarRojo = CASE WHEN DIF.IdFabricacion IS NULL THEN 0 ELSE 1 END    
 FROM #temp70det  det    
 LEFT JOIN ( SELECT  DISTINCT pla.IdFabricacion    
    FROM  #tPlaneado pla     
    LEFT OUTER JOIN #tSubido sub ON (sub.IdFabricacion = pla.IdFabricacion    
            AND sub.IdFabricacionDet = pla.IdFabricacionDet)    
    WHERE  IsNull(sub.PesoTeoricoKgs, 0) <> IsNull(pla.PesoTeoricoKgs, 0) ) DIF ON (DIF.IdFabricacion = det.IdFabricacion)    
    
       
 SELECT t.FactSal  AS  ColFacSal,       
   t.idFabricacion  AS  ColidFabricacion,       
   t.nombreCliente  AS  ColnombreCliente,       
   CONVERT(VARCHAR(10),t.FechaPromesaActual,103)  AS  ColFechaPromesaActual,      
   t.comentarios  AS  Colcomentarios,       
   t.porcMin  AS  ColporcMin,       
   CONVERT(INT,t.total)  AS  Coltotal,    
   t.esFact  AS  ColesFact,       
   CONVERT(INT,t.esUltimoPsg)  AS  ColEsUltimoPsg,       
   t.esTotModif  AS  ColesTotModif ,       
   CONVERT(INT,t.total)  AS  ColtotalAnt    
   --, 2 AS WebGridAction       
   , OrdenAcomodo    
   , PintarRojo    
 FROM #temp70det t     
 LEFT OUTER JOIN (SELECT DISTINCT IdFabricacion, OrdenAcomodo FROM OpeSch.OpeTraPlanCargaDet WHERE ClaUbicacion = @pnClaUbicacion AND IdPlanCarga = @pnOCMF) Det ON Det.IdFabricacion = t.idFabricacion     
 -- WHERE t.porcMin > 0    
 ORDER BY Det.OrdenAcomodo    
        
    DROP TABLE #temp70det    
    DROP TABLE #tPlaneado    
 DROP TABLE #tSubido    
        
END