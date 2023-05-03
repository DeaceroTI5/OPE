	SELECT * 
	FROM	OpeSch.OpeTraPlanCargaVw a WITH (NOLOCK) 
	WHERE	a.ClaUbicacion = 267
	AND		a.IdPlanCarga = 40

	SELECT	* 
	FROM	OpeSch.OpeTraViajeVw e WITH (NOLOCK)
	WHERE	e.ClaUbicacion= 267
	--AND		e.IdPlanCarga = 40
	ORDER BY e.IdPlanCarga ASC


	SELECT	* 
	FROM	OpeSch.OpeTraViajeVw e WITH (NOLOCK)
	WHERE	e.ClaUbicacion= 267
	AND		e.IdPlanCarga IS NULL


SELECT * FROM OPESch.OpeFleTraTabularDetVw WITH (NOLOCK)
SELECT * FROM OPESch.OPEFleTraTabularVw WITH (NOLOCK)


--------------------------------------------------------------------

USE Operacion
GO

exec OPESch.OPE_CU70_Pag1_Grid_OCEnProceso_Sel @pnclaUbicacion=267,@pnSoloStayTuff=0,@pnIdPlanCargaConsulta=NULL,@pnVerTodosPlanes=0,@ptFechaPlanConsulta=NULL,@pnClaUsuarioMod=100010318,@psNombrePcMod='100acgomez'


        SELECT * 
        FROM   FleSch.FLETraConvenio t0(NOLOCK)  
               INNER JOIN FleSch.FLETraConvenioTransportistaVw t1(NOLOCK)  
                    ON  t1.ClaUbicacion = t0.ClaUbicacion  
                    AND t1.IdConvenio = t0.IdConvenio  
                    AND t1.EsBaja = 0  
        WHERE  t0.ClaUbicacion = 267  
         --      AND t0.IdConvenio = @nIdConvenio  
         --      AND t0.NumVersion = @nNumVersion  
               AND t0.ClaTransporte = 42 --@nClaTransporte  
               AND t1.ClaTransportista = @nClaTransportista  

SELECT * FROM FleSch.FLETraConvenioTransportistaVw t1(NOLOCK) WHERE ClaUbicacion = 267 AND EsBaja = 0


BEGIN TRAN
	declare @p6 int
	set @p6=0
	exec OPESch.OPE_CU70_Pag1_Boton_BtnSaveFact_Proc @pnClaUbicacion=267,@pnOCMF=40,@pnValorClaEstatus=1,@pnClaUsuarioMod=100009927,@psNombrePcMod='422-favilaltp',@pnconError=@p6 output
	select @p6
	go
	declare @p6 int
	set @p6=25
	SELECT '2 OPE_CU70_Pag1ModFact_IU'
	exec OPESch.OPE_CU70_Pag1ModFact_IU @pnClaUbicacion=267,@pnOCMF=40,@psSelloMF='',@pnValorcubReal=12500000.0000,@pnClaJefeEmbMF=100009927,@pnViajeMF=@p6 output,@pnClaUsuarioMod=100009927,@psNombrePcMod='422-favilaltp'
	select @p6
	go
	SELECT '3 OPE_CU70_Pag1_Grid_GridDetalleMF_IU'
	exec OPESch.OPE_CU70_Pag1_Grid_GridDetalleMF_IU @pnClaUbicacion=267,@pnOCMF=40,@pnViajeMF=25,@pnColidFabricacion=24475258,@psColcomentarios='«Total Pieces: 4, C330521A0F: 1 
	, C330521A0F: 1 
	, C330521A0F: 1 
	, C330521A0F: 1 ',@pnColtotal=1,@pnClaUsuarioMod=100009927,@psNombrePcMod='422-favilaltp'
	go
	SELECT '4 OPE_CU70_Pag1_Grid_GridDetalleMF_IU'
	exec OPESch.OPE_CU70_Pag1_Grid_GridDetalleMF_IU @pnClaUbicacion=267,@pnOCMF=40,@pnViajeMF=25,@pnColidFabricacion=24495606,@psColcomentarios='«Total Pieces: 3, C110516AbF: 1 
	, C110516AbF: 1 
	, c110517abf: 1 ',@pnColtotal=0,@pnClaUsuarioMod=100009927,@psNombrePcMod='422-favilaltp'
	go
	SELECT '5 OPE_CU70_Pag1_Boton_BtnGenerarFacturar_Proc'
	exec OPESch.OPE_CU70_Pag1_Boton_BtnGenerarFacturar_Proc @pnClaUbicacion=267,@pnOcMF=40,@pnViajeMF=25,@PsNombrePcMod='422-favilaltp',@pnClaUsuarioMod=100010318,@pnAplicarSalidaAutomatica=0
	go

ROLLBACK TRAN

  SELECT *  
  FROM FleSch.FleTraConvenioVw con WITH(NOLOCK)    
  INNER JOIN FleSch.FleTraConvenioTransportistaVw tra WITH(NOLOCK) ON tra.IdConvenio   = con.IdConvenio   
                   AND tra.ClaUbicacion  = con.ClaUbicacion   
                   AND tra.ClaTransportista = 101263   
                   AND ISNULL(tra.FechaBaja,0) = 0    
  WHERE con.ClaUbicacion			= 267   
  AND  ISNULL(con.ClaTipoBoleta,-1) IN (1,-1)   
  AND  con.ClaCiudadOrigen  = 24415   
  AND   con.ClaGrupoTransporte = 1   
  AND   con.ClaTransporte  = 42   
  AND   con.ClaCiudadDestino = 6017868   
--  AND    con.ClaTipoMaterialFFCC = @pnClaTipoMaterialFFCC   
--  AND   con.ClaEstatusConvenio BETWEEN @pnConfigConvenio AND 3   
--  AND   con.ClaTipoConvenio IN (1,3,6) -- CuotaTon / CuotaFija / CuotaFijaxRango    
--  AND  con.ClaMaterial   = @pnClaMaterial    
--  AND  con.ClaCup    = @pnClaCUP    
--  AND  con.ClaCliente IS NULL  
  ORDER BY con.FechaAlta DESC   

---------------------------------------------------------------------------------
-- /* [FleSch].[FLE_CU7_Pag1_Boton_ObtenerConvenio_Proc]  */
DECLARE @nIdConvenio INT, 
 @nNumVersion INT, 
 @nClaMoneda  INT 

 exec [FleSch].[FLE_CU7_Pag1_Boton_ObtenerConvenio_Proc] 
 @pnClaUbicacion   = 267
,@pnClaCiudadOrigen  = 24415
,@pnClaCiudadDestino  = 6017868
,@psClaZipCodeDestino = 0
,@pnClaTransportista  = 101263
,@pnClaGrupoTransporte = 1
,@pnClaTransporte  = 42
,@pnClaTipoBoleta  = null
,@psNumBoleta   = null
,@pnClaTipoMaterialFFCC = null
,@pnConfigConvenio  = 3
,@pnKmsPagables   = 1213
,@pnIdConvenio   = @nIdConvenio OUTPUT
,@pnNumVersion   = @nNumVersion OUTPUT
,@pnClaMoneda   = @nClaMoneda OUTPUT 
,@pnClaCUP    = null
,@pnClaMaterial   = null
,@pnClaCliente   = null

 SELECT @nIdConvenio AS IdConvenio, @nNumVersion as NumVersion, @nClaMoneda as ClaMoneda   
     GO 
---------------------------------------------------------------------------------


	DECLARE @nClaUbicacionConvenio  INT
  EXEC FleSch.FLE_CU7_Pag1_Boton_ObtenerUbicacionConvenio_Proc 267, 1, @nClaUbicacionConvenio OUTPUT  
  SELECT @nClaUbicacionConvenio  

  SELECT * FROM FleSch.FleVtaCatCiudadVw WHERE ClaCiudad = 24415
  SELECT * FROM FleSch.FleVtaCatCiudadVw WHERE ClaCiudad = 6017868
  
  SELECT FechaAlta, *  
  FROM FleSch.FleTraConvenioVw con WITH(NOLOCK)    
  WHERE con.ClaUbicacion			= 267   
-- AND	con.ClaCiudadDestino = 6017868
  ORDER BY con.FechaAlta DESC   




  SELECT	* 
  FROM		FleSch.FleTraConvenioTransportistaVw tra WITH(NOLOCK) 
  WHERE		tra.ClaUbicacion  = 267
  AND		tra.ClaTransportista = 101263   
  AND ISNULL(tra.FechaBaja,0) = 0    
  ORDER BY IdConvenio DESC
