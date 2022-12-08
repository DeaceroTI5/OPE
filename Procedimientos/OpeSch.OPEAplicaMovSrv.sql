ALTER PROCEDURE OpeSch.OPEAplicaMovSrv        
      @pnVersion              int,        
      @pnClaUbicacion              int,        
      @pnIdTokenMovimiento         int,        
      @pnClaTipoInventario         int,        
      @pnTipoMovimiento       int,        
      @pnAccionTransito       int,        
      @pnClaveMovimiento           int   OUTPUT        
AS        
BEGIN        
SET NOCOUNT ON        
SET ANSI_NULLS ON        
SET ANSI_WARNINGS OFF   
	SELECT 'PROCEDIMIENTO OpeSch.OPEAplicaMovSrv'

--* Declaraci<"®n de Variables Locales         
DECLARE @pnERROR int, @psNombreSp varchar(50)        
DECLARE @pnRowCount int         
DECLARE @pnNumEncabezado int, @pnNumDetalles int        
DECLARE @pnRedondeoDec int        
DECLARE @pnRedondeoDecKilos int        
DECLARE @pnDebugLevel   int           
DECLARE @pnIdRenglon int        
DECLARE @pntrancount int        
DECLARE @pdFechaHoraMovimiento     Datetime,         
      @pdFechaMovimiento      Datetime,         
      @pdFechaUltimaMod       Datetime,         
      @psNombrePcAutorizo     varchar(50),        
      @psClaUsuarioMod int,        
      @psNombrePcMod          varchar(50),        
--    @pnClaveMovimiento      int,        
      @pnIdMovimiento         int        
DECLARE @pnIdMovimientoOriginal int,        
      @pnViajeOriginal  int,        
      @pnClaUbicacionOrigen   int,        
      @pnIdMovimientoMt int,        
      @pnIdSeq          int ,      
   @pnMoneda   int,      
   @pnRegistros  int      

	--WTI 14679: las claves de servicio no son materiales fisicos, no deben contar como parte del peso de la unidad para afectación a la cuenta puente. 
 	DECLARE @nFamiliaServicios INT
	SELECT @nFamiliaServicios = nvalor1 from opesch.opeTiCatconfiguracionVw where claubicacion = @pnClaUbicacion and claSistema = 127 and claConfiguracion = 1271229 and bajalogica = 0--518
	CREATE TABLE #temp__ClavesServicio (ClaArticulo INT)
	INSERT INTO #temp__ClavesServicio (ClaArticulo)
	SELECT ClaArticulo 	From OpeSch.OpeArtCatArticuloVw (NOLOCK) WHERE ClaTipoInventario = 1 And claFamilia = ISNULL(@nFamiliaServicios,-1)

--Manejo de Transacciones      
DECLARE @l_bAbrirTrans INT, @SesionError int         
SET @l_bAbrirTrans = 1      
IF( @@trancount > 0 )       
 SET @l_bAbrirTrans = 0      
IF( @l_bAbrirTrans = 1 )      
 BEGIN TRANSACTION      
--SELECT @@trancount AS Aplica0, @l_bAbrirTrans AS l_bAbrirTrans     


Create Table #tmp_MovTransito        
      (IdSeq int identity (1,1) ,         
      IdMovimiento int)        
--Verifica si existe ya Transacion para la session.        
--Select @pntrancount = @@trancount        
--IF @pntrancount = 0 BEGIN TRAN         
--* Inicializar Variables        


Set @psNombreSp = 'InvAplicaMovSrv'        
Set @pnERROR = 0        
Set @pnDebugLevel = 0
Set @pnMoneda = 1      
SELECT @pdFechaUltimaMod = FechaUltimaMod,        
      @pdFechaMovimiento = FechaMovimiento,        
      @pdFechaHoraMovimiento = FechaHoraMovimiento,        
      @psNombrePcAutorizo = NombrePcAutorizo,        
      @psClaUsuarioMod = ClaUsuarioMod,        
      @psNombrePcMod = NombrePcMod,        
      @pnClaveMovimiento = ClaveMovimiento,        
      @pnViajeOriginal = ViajeOriginal,        
      @pnClaUbicacionOrigen = ClaUbicacionOrigen        
FROM OPESch.OpeTraIntRegMovEnc WITH (NOLOCK)        
WHERE IdTokenMovimiento = @pnIdTokenMovimiento AND      
 ClaUbicacion = @pnClaUbicacion AND      
 ClaTipoInventario = @pnClaTipoInventario     
 
IF @pnClaveMovimiento IS NULL or @pnClaveMovimiento = 0        
BEGIN        
      --Se Obtiene el Id de Movimiento Para Mercancias en Transito si Aplica y Movimiento , Pendiente Funcion de Foliador        
      EXEC OPEsch.OpeTiObtenSiguienteFolioProc @pnClaUbicacion, 23, 1, @pnClaveMovimiento OUTPUT        
END        
IF @pnTipoMovimiento <> 2        
      BEGIN        
     --Obtiene el IdMovimiento (Consecutivo de registro de Movimientos)       
        EXEC OPEsch.OpeTiObtenSiguienteFolioProc @pnClaUbicacion, 23, 3, @pnIdMovimiento OUTPUT            
        --SELECT @pnIdMovimiento =  max(isnull(IdMovimiento,0)) + 1 FROM OPESch.OpeTraRegistroMovEnc WITH (NOLOCK)      
  EXEC OPEsch.OpeTiObtenSiguienteFolioProc @pnClaUbicacion, 23, 4, @pnIdMovimientoMT OUTPUT            
PRINT '@pnIdMovimientoMT OUTPUT 1'
PRINT @pnIdMovimientoMT   
  --SELECT @pnIdMovimientoMT = max(isnull(IdMovimiento,0)) + 1 FROM OPESch.OpeTraMovMciasTranEnc -WITH (NOLOCK)      
  IF @pnIdMovimiento IS NULL SET @pnIdMovimiento = 1        
     IF @pnIdMovimientoMT IS NULL SET @pnIdMovimientoMT = 1        
      END 
ELSE        
      BEGIN        
        SELECT @pnIdMovimiento = IdMovimiento FROM OPESch.OpeTraRegistroMovEnc WITH (NOLOCK)       
         WHERE ClaveMovimiento = @pnClaveMovimiento and ClaUbicacion = @pnClaUbicacion --LVR      
      --SELECT @pnIdMovimientoMT = max(isnull(IdMovimiento,0)) + 1 FROM OPESch.OpeTraMovMciasTranEnc WITH (NOLOCK)      
         EXEC OPEsch.OpeTiObtenSiguienteFolioProc @pnClaUbicacion, 23, 4, @pnIdMovimientoMT OUTPUT    --LVR  
PRINT '@pnIdMovimientoMT OUTPUT 2'
PRINT @pnIdMovimientoMT 

      END        
--Actualizar tablas temporales con Numero de Movimiento y Clave Movimiento        
UPDATE OPESch.OpeTraIntRegMovEnc --WITH(UPDLOCK,ROWLOCK)      
Set IdMovimiento = @pnIdMovimiento,        
      ClaveMovimiento = @pnClaveMovimiento        
Where IdTokenMovimiento = @pnIdTokenMovimiento AND      
 ClaUbicacion = @pnClaUbicacion AND      
 ClaTipoInventario = @pnClaTipoInventario        
UPDATE OPESch.OpeTraIntRegMovDet --WITH(UPDLOCK,ROWLOCK)      
Set IdMovimiento = @pnIdMovimiento        
Where IdTokenMovimiento = @pnIdTokenMovimiento   AND      
 ClaUbicacion = @pnClaUbicacion AND      
 ClaTipoInventario = @pnClaTipoInventario      
IF @pnDebugLevel <> 0  select @pnClaveMovimiento '@pnClaveMovimiento'        
--Validar que no exista la Clave Movimiento para el tipo de Inventario    

    
IF @pnTipoMovimiento <> 2        
BEGIN         
      IF EXISTS(SELECT * FROM OPESch.OpeTraRegistroMovEnc WITH (NOLOCK)        
                  WHERE ClaveMovimiento =  @pnClaveMovimiento        
                  AND ClaTipoInventario = @pnClaTipoInventario        
                  AND ClaUbicacion = @pnClaUbicacion)        
      BEGIN         
            SET @pnERROR = 5        
			EXEC OpeSch.ErrLanzaExcepcionNegocio @pnNumError = @pnERROR, @psNombreSP = @psNombreSp, @pnRef1 = @pnClaveMovimiento        
            IF @pnDebugLevel <> 0 PRINT 'No es Modificacion, El numero de movimiento ya existe para el tipo de inventario. ' +  @psNombreSp        
            GOTO FINSP        
      END         
END        
--* Inicializaci<"®n del objeto        
--* Cuerpo del objeto         
--* Valida Encabezado vs Detalle        
IF NOT EXISTS(SELECT COUNT(1), NoRenglonesMovimiento         
            FROM OPESch.OpeTraIntRegMovEnc WITH (NOLOCK)         
            WHERE IdTokenMovimiento = @pnIdTokenMovimiento   AND      
     ClaUbicacion = @pnClaUbicacion AND      
     ClaTipoInventario = @pnClaTipoInventario      
            GROUP BY NoRenglonesMovimiento        
            HAVING NoRenglonesMovimiento IN( SELECT COUNT(1)         
                  FROM OPESch.OpeTraIntRegMovDet A WITH (NOLOCK)                      
                  WHERE IdTokenMovimiento = @pnIdTokenMovimiento AND      
      ClaUbicacion = @pnClaUbicacion AND      
      ClaTipoInventario = @pnClaTipoInventario))        
   --HAVING  COUNT(1) >0 ))      
      BEGIN        
            SET @pnERROR = 1        
            EXEC OpeSch.ErrLanzaExcepcionNegocio @pnNumError = @pnERROR, @psNombreSP = @psNombreSp, @pnRef1 = @pnClaveMovimiento        
            IF @pnDebugLevel <> 0 PRINT 'Valida Encabezado vs Detalle. ' +  @psNombreSp        
            GOTO FINSP        
END        
--* Aplicar Redondeo de Decimales Por Configuracion a Numericos        
      --Numero de Decimales a configurar para Redondeo en Registro de Movimientos        
      SELECT @pnRedondeoDec = isNull(nValor1,4)   
      FROM OPESch.OpeCatConfiguracion WITH (NOLOCK)        
      WHERE ClaConfiguracion = 2        
AND ClaSistema = 23         
     AND ClaUbicacion = @pnClaUbicacion      
      AND ClaTipoInventario = @pnClaTipoInventario      
      --Si no existe el Valor Defaul es 4 decimales        
      IF @pnRedondeoDec IS Null SET @pnRedondeoDec = 4        
      UPDATE OPESch.OpeTraIntRegMovEnc --WITH (ROWLOCK, UPDLOCK)        
      SET PesoEntrada = ROUND(PesoEntrada,@pnRedondeoDec),        
            PesoSalida = ROUND(PesoSalida,@pnRedondeoDec),        
            PesoTara = ROUND(PesoTara,@pnRedondeoDec)        
      WHERE IdTokenMovimiento = @pnIdTokenMovimiento  AND      
   ClaUbicacion = @pnClaUbicacion AND      
   ClaTipoInventario = @pnClaTipoInventario      
      SET @pnERROR = @@Error        
      IF @pnERROR <> 0         
            BEGIN         
                  IF @pnDebugLevel <> 0 PRINT 'Error al Actualizar, pesos en OPETraIntRegMovEnc. ' +  @psNombreSp        
   GOTO FINSP        
            END        
      UPDATE OPESch.OpeTraIntRegMovDet  --WITH (ROWLOCK, UPDLOCK)        
      SET Cantidad = ROUND(Cantidad,@pnRedondeoDec),        
            KilosPesados = ROUND(KilosPesados,@pnRedondeoDec),        
            PesoTeorico = ROUND(PesoTeorico,@pnRedondeoDec)        
      WHERE IdTokenMovimiento = @pnIdTokenMovimiento    AND      
   ClaUbicacion = @pnClaUbicacion AND      
   ClaTipoInventario = @pnClaTipoInventario      
      SET @pnERROR = @@Error        
      IF @pnERROR <> 0         
            BEGIN         
                  IF @pnDebugLevel <> 0 PRINT 'Error al Actualizar, Cantidad en OPETraIntRegMovDet. ' +  @psNombreSp        
                  GOTO FINSP        
            END        

       
--* Validadion por Modificacion        
IF @pnTipoMovimiento = 2        
BEGIN        
      --* Aplicar validacion VA16 , IdMovimiento, claveMovimiento y clatipo inventario existan para Modificacion        
      EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'VA16', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out        
      IF @pnERROR <> 0         
            BEGIN        
                  IF @pnDebugLevel <> 0 PRINT 'Aplicar validacion VA16 , IdMovimiento, claveMovimiento y clatipo inventario existan para Modificacion. ' +  @psNombreSp        
                  GOTO FINSP        
            END        
END        
--* Aplicar validacion VA01,Verificar que el tipo de inventario existe         
EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'VA01', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out        
IF @pnERROR <> 0         
      BEGIN        
            IF @pnDebugLevel <> 0 PRINT 'Aplicar validacion VA01,Verificar que el tipo de inventario existe. ' +  @psNombreSp        
            GOTO FINSP        
      END       
	  
	IF @@SERVERNAME = 'SRVDBDES01\ITKQA'
	   SELECT '' AS 'OpeTraIntRegMovDet', * FROM OPESch.OpeTraIntRegMovDet A WITH(NOLOCK) WHERE A.IdTokenMovimiento = @pnIdTokenMovimiento  AND A.ClaUbicacion = @pnClaUbicacion AND  A.ClaTipoInventario = @pnClaTipoInventario     
--SELECT 'SI PASA1' , @pnVersion AS '@pnVersion', @pnClaUbicacion AS '@pnClaUbicacion', @pnIdTokenMovimiento AS '@pnIdTokenMovimiento', @pnClaTipoInventario AS '@pnClaTipoInventario', @pnTipoMovimiento AS '@pnTipoMovimiento', @pnAccionTransito AS '@pnAccionTransito', @pnClaveMovimiento AS '@pnClaveMovimiento'

--------------------------------------------------------**


--* Aplicar validacion RN30, para Encabezado Fecha Movimiento V<"®lida         
EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'RN30', @pnClaUbicacion, @pnIdTokenMovimiento,      @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out    

--------------------------------------------------------**

IF @pnERROR <> 0         
      BEGIN         
            IF @pnDebugLevel <> 0 PRINT 'Aplicar validacion RN30, para Encabezado Fecha Movimiento Valida. ' +  @psNombreSp        
            GOTO FINSP        
      END    
	  

--* Aplicar Regla RN40 Calcular peso neto, Se redondea con dato de Configuracion        
UPDATE OPESch.OpeTraIntRegMovEnc --WITH (ROWLOCK, UPDLOCK)        
SET PesoNeto = ROUND(ABS(ABS(PesoEntrada - PesoSalida) - PesoTara),@pnRedondeoDec)       
WHERE IdTokenMovimiento = @pnIdTokenMovimiento  AND      
 ClaUbicacion = @pnClaUbicacion AND      
 ClaTipoInventario = @pnClaTipoInventario      
SET @pnERROR = @@Error        
IF @pnERROR <> 0         
      BEGIN         
            IF @pnDebugLevel <> 0 PRINT 'Error al Actualizar, Peso en OPETraIntRegMovEnc con RN40. ' +  @psNombreSp        
            GOTO FINSP        
      END     
	  

--*         
--* Aplicar Validaciones para Detalles  VAG01, VA02, VA03, VA13, VA14, VA15, VA04, VA05, VA06, VA07, VA08, VA09, VA10        
--*         
--Aplicar VAG01,  No se pueden capturar cantidades negativas, Solo Detalles?





EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'VAG01', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR  out                          

IF @pnERROR <> 0         
      BEGIN         
            IF @pnDebugLevel <> 0 PRINT 'Aplicar VAG01,  No se pueden capturar cantidades negativas. ' +  @psNombreSp        
            GOTO FINSP        
      END        
--Aplicar VA02, verificar que Articulo Exista       
--Pendiente ClaArticulo        
EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'VA02', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out                    
IF @pnERROR <> 0         
      BEGIN         
            IF @pnDebugLevel <> 0 PRINT 'Aplicar VA02, verificar que Articulo Exista. ' +  @psNombreSp        
            GOTO FINSP        
      END        
--Aplicar VA03, Verificar que el TMA existe en el cat<"®logo        
EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'VA03', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out              
IF @pnERROR <> 0         
      BEGIN         
            IF @pnDebugLevel <> 0 PRINT 'Aplicar VA03, Verificar que el TMA existe en el catalogo. ' +  @psNombreSp        
            GOTO FINSP        
      END   
      
     
--Aplicar VA13, y VA14 Si en la ubicaci<"®n se afecta cuenta puente (configuraci<"®n general)        
IF EXISTS (SELECT * FROM OPESch.OpeCatConfiguracion WITH (NOLOCK)        
      WHERE ClaConfiguracion = 4        
      AND ClaSistema = 23         
      AND nValor1 = 1        
      AND ClaUbicacion = @pnClaUbicacion      
      AND ClaTipoInventario = @pnClaTipoInventario)        
      BEGIN        
            EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'VA13', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out        
            IF @pnERROR <> 0         
                  BEGIN         
                        IF @pnDebugLevel <> 0 PRINT 'Aplicar VA13, Si en la ubicacion se afecta cuenta puente. ' +  @psNombreSp        
                        GOTO FINSP        
                  END        
            --Aplicar VA14        
            --Pendiente ClaArticulo        
            EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'VA14', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out        
            IF @pnERROR <> 0         
                  BEGIN         
                   IF @pnDebugLevel <> 0 PRINT 'Aplicar VA14, verificar que si el TMA es para afectacion a cuenta puente tiene configurado el articulo a utilizar en la afectacion y el articulo existe y esta activo. ' +  @psNombreSp        
                        GOTO FINSP        
                  END        
      END  
      
      
--Aplicar VA15,Si el TMA del movimiento es de mercanc<"®as en tr<"®nsito tiene configurado el TMA contraparte y los TMA existen        
EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'VA15', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out        
IF @pnERROR <> 0         
      BEGIN         
            IF @pnDebugLevel <> 0 PRINT 'Aplicar VA15,Si el TMA del movimiento es de mercancias en transito tiene configurado el TMA contraparte y los TMA existen. ' +  @psNombreSp        
            GOTO FINSP        
   END        
--Aplicar VA04, Verificar que el almac<"®n existe        
EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'VA04', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out        
IF @pnERROR <> 0      
      BEGIN         
            IF @pnDebugLevel <> 0 PRINT 'Aplicar VA04, Verificar que el almacen existe. ' +  @psNombreSp        
            GOTO FINSP        
 END        
--Aplicar VA05, Verificar que el sub-almac<"®n existe y pertenece al almac<"®n        
EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'VA05', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out        
IF @pnERROR <> 0         
      BEGIN         
            IF @pnDebugLevel <> 0 PRINT 'Aplicar VA05, Verificar que el sub-almacen existe y pertenece al almacen. ' +  @psNombreSp        
            GOTO FINSP        
      END        
--Aplicar VA06, Verificar que el sub-sub-almac<"®n existe y pertenece al almac<"®n y sub-almac<"®n        
EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'VA06', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out        
IF @pnERROR <> 0         
      BEGIN         
            IF @pnDebugLevel <> 0 PRINT 'Aplicar VA06, Verificar que el sub-sub-almacen existe y pertenece al almacen y sub-almacen. ' +  @psNombreSp        
            GOTO FINSP        
      END        
--Aplicar VA07, Verificar que la secci<"®n existe y pertenece al almacen, sub-almaceny sub-sub-almacen.        
EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'VA07', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out        
IF @pnERROR <> 0         
      BEGIN         
            IF @pnDebugLevel <> 0 PRINT 'Aplicar VA07, Verificar que la seccion existe y pertenece al almacen, sub-almacen y sub-sub-almacen. ' +  @psNombreSp        
            GOTO FINSP        
      END        
--Aplicar VA08, Validar que se proporcionaron todos los almacenes requeridos (almacen, sub-almacen, sub-sub-almacen, secci<"®n        
EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'VA08', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out        
IF @pnERROR <> 0         
      BEGIN         
            IF @pnDebugLevel <> 0 PRINT 'Aplicar VA08, Validar que se proporcionaron todos los almacenes requeridos (almacen, sub-almacen, sub-sub-almacen, seccion. ' +  @psNombreSp        
            GOTO FINSP        
      END  
    
--Aplicar VA09, Validar que las referencias proporcionadas (cuando son diferente de null) ,validar si configuracion lo indica        
--Pendiente referencias con Articulos        
--Aplicar Validacion: Validar que Referencia Exista        
--If @pnAccionTransito IS NULL        
--BEGIN        
--      IF EXISTS (SELECT * FROM OPESch.OpeCatConfiguracion WITH (NOLOCK)        
--            WHERE ClaConfiguracion = 19        
--            AND ClaSistema = 23         
--            AND nValor1 = 1        
--            AND ClaUbicacion = @pnClaUbicacion      
--            AND ClaTipoInventario = @pnClaTipoInventario)        
--            BEGIN        
--                  EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'VA09', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out        
--                  IF @pnERROR <> 0         
--                        BEGIN         
--                             IF @pnDebugLevel <> 0 PRINT 'Aplicar VA09, Validar que las referencias proporcionadas (cuando son diferente de null) ,validar si configuracion lo indica. ' +  @psNombreSp        
--                             GOTO FINSP     
--                        END       
--            END        
--END        
--Aplicar VA10, Validar que el dato proporcionado para el detalle del movimiento en entrada/salida es v<"®lido para el TMA.        
EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'VA10', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out     
IF @pnERROR <> 0         
      BEGIN         
            IF @pnDebugLevel <> 0 PRINT 'Aplicar VA10, Validar que el dato proporcionado para el detalle del movimiento en entrada/salida es valido para el TMA. ' +  @psNombreSp        
            GOTO FINSP        
      END        
--* Aplicar Regla RN31, RN32, RN33 Para Detalles        
-- Validar RN31, Art<"®culo activo <"® Verificar si el art<"®culo est<"® activo si el TMA indica que se valida        
--Pendiente ClaArticulo        
EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'RN31', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out        
IF @pnERROR <> 0         
      BEGIN         
            IF @pnDebugLevel <> 0 PRINT 'Validar RN31, Articulo activo o Verificar si el articulo este activo si el TMA indica que se valida. ' +  @psNombreSp        
            GOTO FINSP        
      END        
-- Validar RN32, TMA activo <"® Verificar que el TMA tenga estatus de activo        
EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'RN32', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out        
IF @pnERROR <> 0         
      BEGIN         
            IF @pnDebugLevel <> 0 PRINT 'Validar RN32, TMA activo o Verificar que el TMA tenga estatus de activo. ' +  @psNombreSp        
            GOTO FINSP        
      END        
-- Validar RN32, Familia y almacenvalidos para TMA         
EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'RN33', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out        
IF @pnERROR <> 0         
      BEGIN         
            IF @pnDebugLevel <> 0 PRINT 'Validar RN33, Familia y almacen validos para TMA. ' +  @psNombreSp        
            GOTO FINSP        
      END        
-- Validar VA17, Validaci<"®n de diferencia de pesos entrada/salida        
--Pendiente ClaArticulo        
IF EXISTS (SELECT PesoEntrada, PesoSalida FROM OPESch.OpeTraIntRegMovEnc WITH (NOLOCK)        
      WHERE (ISNull(PesoEntrada,0) <> 0         
      OR ISNULL(PesoSalida,0) <>0)        
      AND IdTokenMovimiento = @pnIdTokenMovimiento AND      
  ClaUbicacion = @pnClaUbicacion AND      
  ClaTipoInventario = @pnClaTipoInventario)        
      BEGIN        
            EXEC OPEsch.OPEValidaAplicaMovProc @pnVersion, 'VA17', @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @pnERROR out        
            IF @pnERROR <> 0         
                  BEGIN         
                        IF @pnDebugLevel <> 0 PRINT 'Validar VA17, validacion de diferencia de pesos entrada/salida. ' +  @psNombreSp        
                        GOTO FINSP        
                  END        
      END        
  /* */  
   
------------------------------------------------------------------------------------------        
-- Si el Mov no es por Cambio de Peso teorico, Ejecutar el servicio Cambio de peso te<"®rico        
------------------------------------------------------------------------------------------        
--Pendiente... Se Debe de actualiza el Peso teorico de los Articulos   
     
UPDATE  OPESch.OpeTraIntRegMovDet --WITH (ROWLOCK, UPDLOCK)      
SET PesoTeorico = ISNULL(B.PesoTeoricoKgs, 1)      
FROM OPESch.OpeTraIntRegMovDet A /*WITH (NOLOCK)*/      
LEFT JOIN opeSch.OpeArtCatArticuloVw B WITH (NOLOCK)         
ON B.ClaArticulo = A.ClaArticulo         
AND B.ClaTipoInventario = A.ClaTipoInventario        
WHERE A.IdTokenMovimiento = @pnIdTokenMovimiento  AND      
 A.ClaUbicacion = @pnClaUbicacion AND      
 A.ClaTipoInventario = @pnClaTipoInventario 
 

     
--Valida no sea un movimiento por cambio de peso teorico        
IF NOT EXISTS (SELECT 1 FROM OPESch.OpeTraIntRegMovEnc WITH (NOLOCK)      
            WHERE CambioPesoTeorico = 1        
         AND IdTokenMovimiento = @pnIdTokenMovimiento AND      
   ClaUbicacion = @pnClaUbicacion AND      
   ClaTipoInventario = @pnClaTipoInventario)        
BEGIN        
      EXEC OPEsch.OPECambioPesoTeoricoSrv @pnVersion, @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnClaveMovimiento, @psNombrePcAutorizo, @psClaUsuarioMod, @psNombrePcMod,         
            @pdFechaHoraMovimiento, @pdFechaMovimiento, @pnERROR OUT, @pnRegistros OUT        
            IF @pnERROR <> 0         
                  BEGIN         
                        IF @pnDebugLevel <> 0 PRINT 'Error en Servicio de Cambio de Peso Teorico. ' +  @psNombreSp        
                        GOTO FINSP        
                  END        
            --Actualiza el IdMovimiento en caso de que se generen movimientos por cambio peso teorico        
            IF @pnTipoMovimiento <> 2  AND @pnRegistros <> 0      
                  BEGIN        
                        --Obtiene el IdMovimiento (Consecutivo de registro de Movimientos)        
                        EXEC OPEsch.OpeTiObtenSiguienteFolioProc @pnClaUbicacion, 23, 3, @pnIdMovimiento OUTPUT      
                            --SELECT @pnIdMovimiento =  max(isnull(IdMovimiento,0)) + 1 FROM OPESch.OpeTraRegistroMovEnc WITH (NOLOCK)      
                        IF @pnIdMovimiento IS NULL SET @pnIdMovimiento = 1        
                  END           
            ELSE        
                  BEGIN        
                        SELECT @pnIdMovimiento = IdMovimiento FROM OPESch.OpeTraRegistroMovEnc WITH (NOLOCK)       
                        WHERE ClaveMovimiento = @pnClaveMovimiento and  ClaUbicacion = @pnClaUbicacion --LVR      
                  END        
            --Actualizar tablas temporales con Numero de Movimiento y Clave Movimiento        
            UPDATE OPESch.OpeTraIntRegMovEnc --WITH(UPDLOCK,ROWLOCK)      
            Set IdMovimiento = @pnIdMovimiento,        
            ClaveMovimiento = @pnClaveMovimiento        
            Where IdTokenMovimiento = @pnIdTokenMovimiento   AND      
    ClaUbicacion = @pnClaUbicacion AND      
    ClaTipoInventario = @pnClaTipoInventario      
            UPDATE OPESch.OpeTraIntRegMovDet  --WITH(UPDLOCK,ROWLOCK)      
            Set IdMovimiento = @pnIdMovimiento        
            Where IdTokenMovimiento = @pnIdTokenMovimiento   AND      
    ClaUbicacion = @pnClaUbicacion AND      
    ClaTipoInventario = @pnClaTipoInventario      
END        

--Numero de Decimales a configurar para Redondeo en Registro de Movimientos        
SELECT @pnRedondeoDecKilos = ISNULL(nValor1,4)        
FROM OPESch.OpeCatConfiguracion WITH (NOLOCK)        
WHERE ClaConfiguracion = 45 AND      
  ClaSistema = 23 AND      
  ClaUbicacion = @pnClaUbicacion AND      
  ClaTipoInventario = @pnClaTipoInventario      
       
--Si no existe el Valor Defaul es 4 decimales        
IF @pnRedondeoDecKilos IS NULL SET @pnRedondeoDec = 4      
       
------------------------------------------------------------------------------------------        
-- Ejecuta RN39, Calcular kilos te<"®ricos para cada detalle         
------------------------------------------------------------------------------------------        
IF @pnClaTipoInventario = 2 --Si el tipo de inventarios es Compras      
BEGIN      
 UPDATE OPESch.OpeTraIntRegMovDet --WITH (ROWLOCK, UPDLOCK)      
 SET  KilosTeoricos = ROUND(Cantidad * PesoTeorico, @pnRedondeoDecKilos)      
 WHERE IdTokenMovimiento = @pnIdTokenMovimiento AND      
   ClaUbicacion = @pnClaUbicacion AND      
   ClaTipoInventario = @pnClaTipoInventario      
END      
ELSE      
BEGIN      
 DECLARE @nIdRenglonCicloK INT,      
   @nCantidadCicloK NUMERIC(22,4),      
   @nKilosTeoricosCicloK NUMERIC(22,4)      
       
 SELECT @nIdRenglonCicloK = MIN(IdRenglon)   
 FROM OPESch.OpeTraIntRegMovDet WITH (NOLOCK)      
 WHERE IdTokenMovimiento = @pnIdTokenMovimiento AND      
   ClaUbicacion = @pnClaUbicacion AND      
   ClaTipoInventario = @pnClaTipoInventario      
       
 WHILE @nIdRenglonCicloK IS NOT NULL      
 BEGIN      
  SELECT @nCantidadCicloK = ISNULL(B.Cantidad,0) + SUM(CASE WHEN C.IdRenglon < A.IdRenglon THEN C.Cantidad * C.EntradaSalida ELSE 0 END),      
    @nKilosTeoricosCicloK = ISNULL(B.KilosTeoricos,0) + SUM(CASE WHEN C.IdRenglon < A.IdRenglon THEN C.KilosTeoricos * C.EntradaSalida ELSE 0 END)      
  FROM OPESch.OpeTraIntRegMovDet A WITH (NOLOCK)      
    LEFT JOIN OPESch.OpeTraExistencias B WITH (NOLOCK) ON      
     A.ClaUbicacion = B.ClaUbicacion and      
     A.ClaTipoInventario = B.ClaTipoInventario and      
     A.ClaArticulo = B.ClaArticulo and      
     A.ClaAlmacen = B.ClaAlmacen and      
     isnull(A.ClaSubAlmacen,0) = isnull(B.ClaSubAlmacen,0) and      
     isnull(A.ClaSubSubAlmacen,0) = isnull(B.ClaSubSubAlmacen,0) and      
     isnull(A.ClaSeccion,0) = isnull(B.ClaSeccion,0) and      
     isnull(A.CampoEntero1,0) = isnull(B.ClaTipoReferencia1,0) and      
     isnull(A.CampoEntero2,0) = isnull(B.ClaTipoReferencia2,0) and      
     isnull(A.CampoEntero3,0) = isnull(B.ClaTipoReferencia3,0) and      
     isnull(A.CampoEntero4,0) = isnull(B.ClaTipoReferencia4,0) and      
     isnull(A.CampoEntero5,0) = isnull(B.ClaTipoReferencia5,0) and      
     isnull(A.CampoTexto1,'') = isnull(B.ValorReferencia1,'') and      
     isnull(A.CampoTexto2,'') = isnull(B.ValorReferencia2,'') and      
     isnull(A.CampoTexto3,'') = isnull(B.ValorReferencia3,'') and      
     isnull(A.CampoTexto4,'') = isnull(B.ValorReferencia4,'') and      
     isnull(A.CampoTexto5,'') = isnull(B.ValorReferencia5,'')      
    INNER JOIN OPESch.OpeTraIntRegMovDet C WITH (NOLOCK) ON      
     C.ClaUbicacion = A.ClaUbicacion and      
     C.ClaTipoInventario = A.ClaTipoInventario and      
     C.IdTokenMovimiento = A.IdTokenMovimiento and      
     C.ClaArticulo = A.ClaArticulo and      
     C.ClaAlmacen = A.ClaAlmacen and      
     isnull(C.ClaSubAlmacen,0) = isnull(A.ClaSubAlmacen,0) and      
     isnull(C.ClaSubSubAlmacen,0) = isnull(A.ClaSubSubAlmacen,0) and      
     isnull(C.ClaSeccion,0) = isnull(A.ClaSeccion,0) and      
     isnull(C.CampoEntero1,0) = isnull(A.CampoEntero1,0) and      
     isnull(C.CampoEntero2,0) = isnull(A.CampoEntero2,0) and      
     isnull(C.CampoEntero3,0) = isnull(A.CampoEntero3,0) and      
     isnull(C.CampoEntero4,0) = isnull(A.CampoEntero4,0) and      
     isnull(C.CampoEntero5,0) = isnull(A.CampoEntero5,0) and      
     isnull(C.CampoTexto1,'') = isnull(A.CampoTexto1,'') and      
     isnull(C.CampoTexto2,'') = isnull(A.CampoTexto2,'') and      
     isnull(C.CampoTexto3,'') = isnull(A.CampoTexto3,'') and      
     isnull(C.CampoTexto4,'') = isnull(A.CampoTexto4,'') and      
     isnull(C.CampoTexto5,'') = isnull(A.CampoTexto5,'')      
  WHERE A.IdTokenMovimiento = @pnIdTokenMovimiento AND      
    A.ClaUbicacion = @pnClaUbicacion AND      
    A.ClaTipoInventario = @pnClaTipoInventario AND      
    A.IdRenglon = @nIdRenglonCicloK      
  GROUP BY ISNULL(B.Cantidad,0), ISNULL(B.KilosTeoricos,0)      
       
  UPDATE OPESch.OpeTraIntRegMovDet --WITH (ROWLOCK, UPDLOCK)      
  SET  KilosTeoricos = ABS(ROUND((@nCantidadCicloK + (Cantidad * EntradaSalida)) * PesoTeorico, @pnRedondeoDecKilos) - @nKilosTeoricosCicloK)      
  FROM OPESch.OpeTraIntRegMovDet /*WITH (NOLOCK)*/      
  WHERE IdTokenMovimiento = @pnIdTokenMovimiento AND      
    ClaUbicacion = @pnClaUbicacion AND      
    ClaTipoInventario = @pnClaTipoInventario AND      
    IdRenglon = @nIdRenglonCicloK      
  
   
 
  SELECT @nIdRenglonCicloK = MIN(IdRenglon)      
  FROM OPESch.OpeTraIntRegMovDet WITH (NOLOCK)      
  WHERE IdTokenMovimiento = @pnIdTokenMovimiento AND      
    ClaUbicacion = @pnClaUbicacion AND      
    ClaTipoInventario = @pnClaTipoInventario AND      
    IdRenglon > @nIdRenglonCicloK      
 END      
END      
       
SET @pnERROR = @@Error        
IF @pnERROR <> 0         
      BEGIN         
            IF @pnDebugLevel <> 0 PRINT 'Error al Actualizar, Kilos Teoricos en OPETraIntRegMovEnc con RN39. ' +  @psNombreSp        
            GOTO FINSP        
      END        
--SELECT 'TEST RN39', * FROM OPESch.OpeTraIntRegMovDet WITH (NOLOCK) WHERE IdTokenMovimiento = @pnIdTokenMovimiento        
------------------------------------------------------------------------------------------        
-- Ejecuta RN35, Kilos pesados en rango         
------------------------------------------------------------------------------------------        
IF EXISTS (SELECT * FROM OPESch.OpeTraIntRegMovDet WITH (NOLOCK)        
      WHERE IdTokenMovimiento = @pnIdTokenMovimiento  AND      
   ClaUbicacion = @pnClaUbicacion AND      
   ClaTipoInventario = @pnClaTipoInventario      
      AND ISNULL(KilosPesados,0) > 0)        
BEGIN        
      DECLARE @pnLimiteInfDifKilos numeric(22,4)        
      DECLARE @pnLimiteSupDifKilos numeric(22,4)        
      --Lim Inf de Rango de Tolerancia para Diferencia en Kilos teoricos y kilos pesados        
      SELECT @pnLimiteInfDifKilos = nValor1        
      FROM OPESch.OpeCatConfiguracion WITH (NOLOCK)        
      WHERE ClaUbicacion = @pnClaUbicacion        
      AND ClaConfiguracion = 8        
      AND ClaSistema = 23        
      AND ClaTipoInventario = @pnClaTipoInventario      
      --Lim Sup de Rango de Tolerancia para Diferencia en Kilos teoricos y kilos pesados        
      SELECT @pnLimiteSupDifKilos = nValor1        
      FROM OPESch.OpeCatConfiguracion WITH (NOLOCK)        
      WHERE ClaUbicacion = @pnClaUbicacion        
      AND ClaConfiguracion = 9        
      AND ClaSistema = 23        
      AND ClaTipoInventario = @pnClaTipoInventario      
      IF EXISTS(SELECT *        
            FROM OPESch.OpeTraIntRegMovDet A WITH(NOLOCK)           
            WHERE ABS(KilosPesados - KilosTeoricos) <> 0         
            AND IdTokenMovimiento = @pnIdTokenMovimiento  AND      
   ClaUbicacion = @pnClaUbicacion AND      
   ClaTipoInventario = @pnClaTipoInventario      
            AND ( ((1 - CASE WHEN KilosPesados <> 0 THEN (KilosTeoricos/KilosPesados) ELSE 0 End) * 100) < @pnLimiteInfDifKilos         
            OR ((1 - CASE WHEN KilosPesados <> 0 THEN (KilosTeoricos/KilosPesados) ELSE 0 End) * 100) > @pnLimiteSupDifKilos ))        
      BEGIN        
            SET @pnERROR = 2        
            EXEC OpeSch.ErrLanzaExcepcionNegocio @pnNumError = @pnERROR, @psNombreSP = @psNombreSp, @pnRef1 = @pnClaveMovimiento        
            IF @pnDebugLevel <> 0 PRINT 'RN35, diferencia entre los kilos teoricos y kilos pesados excede el rango de tolerancia. ' +  @psNombreSp        
            GOTO FINSP        
      END        
END        
------------------------------------------------------------------------------------------        
-- Ejecutar el flujo Manejo de cuenta puente para todo el movimiento        
------------------------------------------------------------------------------------------        
-- Aplica afectacion de cuenta puente para la Ubicacion        
--Aplica afectacion de cuenta puente para la Ubicacion  

    
IF EXISTS(SELECT * FROM OPESch.OpeCatConfiguracion WITH (NOLOCK) 
WHERE ClaConfiguracion = 4        
AND ClaSistema = 23        
AND ClaUbicacion = @pnClaUbicacion        
AND nValor1 = 1      
AND ClaTipoInventario = @pnClaTipoInventario        
)        
BEGIN        
IF EXISTS(SELECT  A.ClaTMA FROM OPESch.OpeTraIntRegMovDet A WITH (NOLOCK)         
                  JOIN OPESch.OpeCatTMAVw B WITH (NOLOCK)        
ON  B.ClaTMA = A.ClaTMA         
                  AND B.ClaTipoInventario = A.ClaTipoInventario        
               WHERE A.IdTokenMovimiento = @pnIdTokenMovimiento  AND      
      A.ClaUbicacion = @pnClaUbicacion AND      
      A.ClaTipoInventario = @pnClaTipoInventario      
                  AND B.AfectaCuentaPuente = 1
				  AND A.ClaArticulo NOT IN (SELECT ClaArticulo FROM #temp__ClavesServicio) ) --- LAS CLAVES DE SERVICIO NO AFECTAN CUENTA PUENTE        
      BEGIN        
            --Si Aplica Manejo de cuenta puente para todo el movimiento        
            EXEC OPEsch.OPECuentaPuenteSrv @pnVersion, @pnClaUbicacion, @pnIdTokenMovimiento, @pnClaTipoInventario, @pnTipoMovimiento, @pnAccionTransito, @pnIdMovimiento,        
             @psNombrePcAutorizo, @psClaUsuarioMod, @psNombrePcMod, @pdFechaHoraMovimiento, @pdFechaUltimaMod, @pnERROR out        
                  IF @pnERROR <> 0         
                        BEGIN         
  IF @pnDebugLevel <> 0 PRINT 'Error en Manejo de cuenta puente para todo el movimiento. ' +  @psNombreSp        
                             GOTO FINSP        
                        END        
      END        
--SELECT 'TEST cuenta puente', * FROM OPESch.OpeTraIntRegMovDet WITH (NOLOCK) where IdTokenMovimiento = @pnIdTokenMovimiento        
END        
--Actualizar ClaFamilia y ClaSubFamilia con los que correspondan a el Articulo        
UPDATE OPESch.OpeTraIntRegMovDet --WITH (ROWLOCK, UPDLOCK)      
SET ClaFamilia = B.ClaFamilia,         
      ClaSubFamilia = B.ClaSubFamilia        
FROM OPESch.OpeTraIntRegMovDet A /*WITH (NOLOCK)*/      
JOIN opeSch.OpeArtCatArticuloVw B WITH (NOLOCK)        
ON B.ClaArticulo = A.ClaArticulo        
AND B.ClaTipoInventario = A.ClaTipoInventario        
WHERE A.IdTokenMovimiento = @pnIdTokenMovimiento   AND      
 A.ClaUbicacion = @pnClaUbicacion AND      
 A.ClaTipoInventario = @pnClaTipoInventario      
SELECT @pnERROR = @@Error         
IF @pnERROR <> 0         
      BEGIN         
            set @pnERROR = 99        
            IF @pnDebugLevel <> 0 PRINT 'Error, al Actualizar ClaFamilia y ClaSubFamilia con los que correspondan a el Articulo. ' +  @psNombreSp        
            GOTO FINSP        
      END        
------------------------------------------------------------------------------------------        
-- validar de la configuraci<"®n del TMA, si los utilizados en el movimiento         
-- son mercanc<"®as en tr<"®nsito        
------------------------------------------------------------------------------------------        
IF @pnAccionTransito IS NOT NULL         
BEGIN        
IF NOT EXISTS(SELECT * FROM OPESch.OpeCatTMAVw A WITH (NOLOCK)        
      JOIN OPESch.OpeTraIntRegMovDet B WITH (NOLOCK)        
      ON B.ClaTMA = A.ClaTMA         
      AND B.ClaTipoInventario = A.ClaTipoInventario        
      WHERE A.EsMercanciaEnTransito = 1        
      AND B.IdTokenMovimiento = @pnIdTokenMovimiento  AND      
   B.ClaUbicacion = @pnClaUbicacion AND      
   B.ClaTipoInventario = @pnClaTipoInventario)        
      BEGIN        
            SET @pnERROR = 3        
            EXEC OpeSch.ErrLanzaExcepcionNegocio @pnNumError = @pnERROR, @psNombreSP = @psNombreSp, @pnRef1 = @pnClaveMovimiento        
            IF @pnDebugLevel <> 0 PRINT 'Error, El Movimiento no Tiene Mercancias en Transito. ' +  @psNombreSp        
            GOTO FINSP        
      END        
END




--Para MT         
IF @pnClaveMovimiento IS NULL SET @pnClaveMovimiento = @pnIdMovimiento        
--Verifica si existe al menos un movimiento de mercancias en transito        
IF EXISTS(SELECT * FROM OPESch.OpeCatTMAVw A WITH (NOLOCK)        
  JOIN OPESch.OpeTraIntRegMovDet B WITH (NOLOCK)        
    ON  B.ClaTMA = A.ClaTMA         
    AND  B.ClaTipoInventario = A.ClaTipoInventario        
 JOIN OPESch.OpeTraIntRegMovEnc C  WITH (NOLOCK)       
 ON  C.IdTokenMovimiento = B.IdTokenMovimiento and      
   C.ClaUbicacion = B.ClaUbicacion and      
   C.ClaTipoInventario = B.ClaTipoInventario      
 WHERE A.EsMercanciaEnTransito = 1  AND      
  B.IdTokenMovimiento = @pnIdTokenMovimiento AND      
  B.ClaUbicacion = @pnClaUbicacion AND      
  B.ClaTipoInventario = @pnClaTipoInventario AND      
  isnull(C.ClaUbicacionOrigen, 0) != 0 AND      
  Isnull(B.ClaUbicacionDestino, 0) != 0 )       
BEGIN        
      --Validacion, si es Modificacion y tiene un movimiento de mercancia en transito se marca error.        
      IF @pnTipoMovimiento = 2        
      BEGIN         
            SET @pnERROR = 4        
            EXEC OpeSch.ErrLanzaExcepcionNegocio @pnNumError = @pnERROR, @psNombreSP = @psNombreSp, @pnRef1 = @pnClaveMovimiento        
            IF @pnDebugLevel <> 0 PRINT 'Error, El Movimiento Tiene Mercancias en Transito. ' +  @psNombreSp        
            GOTO FINSP        
      END        
      --IF @pnDebugLevel <> 0 PRINT 'Los TMA, utilizados en el movimiento son Mercancia en Transito, Servicio Mercancias en Transito. ' +  @psNombreSp        
      -- Pendiante, la ubicaci<"®n del movimiento, si es la ubicaci<"®n de mercanc<"®as en tr<"®nsito         
      DECLARE @pnUbicacionMciaTrans int        
      SELECT @pnUbicacionMciaTrans = nValor1        
      FROM  OPESch.OpeCatConfiguracion  WITH (NOLOCK)        
      WHERE  ClaUbicacion = @pnClaUbicacion        
      AND  ClaSistema = 23        
      AND  ClaConfiguracion = 35      
      AND  ClaTipoInventario = @pnClaTipoInventario      
      if @pnUbicacionMciaTrans is null  set @pnUbicacionMciaTrans = 100        
      -- si es la ubicaci<"®n de mercanc<"®as en tr<"®nsito y en acci<"®n par<"®metro se recibe 0 (ENV<"®O) <"® 1 (RECEPCI<"®N) entonces termina el flujo.        
      IF (@pnUbicacionMciaTrans = @pnClaUbicacion) and (@pnAccionTransito IN (0,1) )        
      BEGIN        
            IF @pnDebugLevel <> 0 PRINT 'El Movimiento es de Entrada o Salida de Mercancia Transito en la Ubicacion de MT, ' +  @psNombreSp        
      END        
      ELSE        
      BEGIN        
            --IF @pnDebugLevel <> 0 PRINT 'Se Generan los movimiento de Mercancia en Transito, Servicio Mercancias en Transito. ' +  @psNombreSp        
            --Pendiente, Servicio Mercancias en Transito, Obtener el IdMovimiento        
            -- Tabla de Enc Mcias Transito, InvTraMovMciasTranEnc        
--   INSERT INTO OPETraMovMciasTranEnc  (ClaUbicacion, ClaTipoInventario, IdMovimiento, ClaMotivoInventario, ClaTipoClaveMovimiento, ClaUbicacionOrigen,         
--                             ClaUsuarioAutorizo, ClaveMovimiento, FechaAutorizacion, FechaHoraMovimiento, NombrePcAutorizo, NoRenglonesMovimiento, PesoEntrada,         
--                             PesoNeto, PesoSalida, PesoTara, ViajeOriginal, CampoEntero1, CampoEntero2, CampoEntero3, CampoEntero4, CampoEntero5, CampoEntero6,         
--                             CampoEntero7, CampoEntero8, CampoEntero9, CampoEntero10, CampoTexto1, CampoTexto2, CampoTexto3, CampoTexto4, CampoTexto5, CampoTexto6,         
--                             CampoTexto7, CampoTexto8, CampoTexto9, CampoTexto10, FechaMovimiento, FechaUltimaMod, ClaUsuarioMod, NombrePcMod)        
IF HOST_NAME()='100-RCASTRO'
BEGIN

SELECT * FROM OPESch.OpeTraMovMciasTranEnc
WHERE ClaUbicacion = @pnClaUbicacion AND ClaTipoInventario = @pnClaTipoInventario and IdMovimiento = @pnIdMovimientoMT

PRINT 'INSERT INTO OPESch.OpeTraMovMciasTranEnc'
SELECT      ClaUbicacion, ClaTipoInventario, @pnIdMovimientoMT, ClaMotivoInventario, ClaTipoClaveMovimiento, ClaUbicacionOrigen,         
                    ClaUsuarioAutorizo, @pnClaveMovimiento, FechaAutorizacion, 0, FechaHoraMovimiento, NombrePcAutorizo, NoRenglonesMovimiento, PesoEntrada,         
                    PesoNeto, PesoSalida, PesoTara, ViajeOriginal, CampoEntero1, CampoEntero2, CampoEntero3, CampoEntero4, CampoEntero5, CampoEntero6,         
                    CampoEntero7, CampoEntero8, CampoEntero9, CampoEntero10, CampoTexto1, CampoTexto2, CampoTexto3, CampoTexto4, CampoTexto5, CampoTexto6,         
                    CampoTexto7, CampoTexto8, CampoTexto9, CampoTexto10, FechaMovimiento, NULL, @pnMoneda, ClaTransporte, ClaTransportista, Placas, NombreChofer,      
  GETDATE(), ClaUsuarioMod, NombrePcMod ,      
  ClaGrupoTMA, PesoDocumentado, PesoNoDocumentado      
  --, Observaciones, NomTransportista, Caja, Sello, EjeTransporte, AgenciaAduanal --Agragado para PLO      
        FROM OPESch.OpeTraIntRegMovEnc WITH (NOLOCK)        
        WHERE IdTokenMovimiento = @pnIdTokenMovimiento AND       
 ClaUbicacion = @pnClaUbicacion AND      
 ClaTipoInventario = @pnClaTipoInventario 
     
END

	IF @@SERVERNAME = 'SRVDBDES01\ITKQA'
		SELECT   ''AS'OpeTraIntRegMovEnc', *  FROM OPESch.OpeTraIntRegMovEnc WITH (NOLOCK)        
            WHERE IdTokenMovimiento = @pnIdTokenMovimiento AND       
     ClaUbicacion = @pnClaUbicacion AND      
     ClaTipoInventario = @pnClaTipoInventario  

   INSERT INTO OPESch.OpeTraMovMciasTranEnc  (ClaUbicacion, ClaTipoInventario, IdMovimiento, ClaMotivoInventario, ClaTipoClaveMovimiento, ClaUbicacionOrigen,      
        ClaUsuarioAutorizo, ClaveMovimiento, FechaAutorizacion, EstatusTransito, FechaHoraMovimiento, NombrePcAutorizo, NoRenglonesMovimiento, PesoEntrada,      
        PesoNeto, PesoSalida, PesoTara, NumViaje, CampoEntero1, CampoEntero2, CampoEntero3, CampoEntero4, CampoEntero5, CampoEntero6,   
        CampoEntero7, CampoEntero8, CampoEntero9, CampoEntero10, CampoTexto1, CampoTexto2, CampoTexto3, CampoTexto4, CampoTexto5, CampoTexto6,      
        CampoTexto7, CampoTexto8, CampoTexto9, CampoTexto10, FechaMovimiento, FechaCierreTraspaso, Moneda, ClaTransporte, ClaTransportista, Placas, NombreChofer,      
        FechaUltimaMod, ClaUsuarioMod, NombrePcMod,      
       ClaGrupoTMA, PesoDocumentado, PesoNoDocumentado)      
        --,Observaciones, NomTransportista, Caja, Sello, EjeTransporte, AgenciaAduanal)--Agragado para PLO)        
            SELECT      ClaUbicacion, ClaTipoInventario, @pnIdMovimientoMT, ClaMotivoInventario, ClaTipoClaveMovimiento, ClaUbicacionOrigen,         
                        ClaUsuarioAutorizo, @pnClaveMovimiento, FechaAutorizacion, 0, FechaHoraMovimiento, NombrePcAutorizo, NoRenglonesMovimiento, PesoEntrada,         
                        PesoNeto, PesoSalida, PesoTara, ViajeOriginal, CampoEntero1, CampoEntero2, CampoEntero3, CampoEntero4, CampoEntero5, CampoEntero6,         
                        CampoEntero7, CampoEntero8, CampoEntero9, CampoEntero10, CampoTexto1, CampoTexto2, CampoTexto3, CampoTexto4, CampoTexto5, CampoTexto6,         
                        CampoTexto7, CampoTexto8, CampoTexto9, CampoTexto10, FechaMovimiento, NULL, @pnMoneda, ClaTransporte, ClaTransportista, Placas, NombreChofer,      
      GETDATE(), ClaUsuarioMod, NombrePcMod ,      
      ClaGrupoTMA, PesoDocumentado, PesoNoDocumentado      
      --, Observaciones, NomTransportista, Caja, Sello, EjeTransporte, AgenciaAduanal --Agragado para PLO      
            FROM OPESch.OpeTraIntRegMovEnc WITH (NOLOCK)        
            WHERE IdTokenMovimiento = @pnIdTokenMovimiento AND       
     ClaUbicacion = @pnClaUbicacion AND      
     ClaTipoInventario = @pnClaTipoInventario      
       



     SELECT @pnERROR = @@Error , @pnRowCount = @@RowCount        
       IF @pnERROR <> 0 or @pnRowCount = 0        
                  BEGIN         
                        IF @pnDebugLevel <> 0 PRINT 'Error, Insertar Mercancias en Transito, OPETraMovMciasTranEnc. ' +  @psNombreSp        
                        GOTO FINSP        
                  END                 
          SET @pnERROR = 0      
          SET @pnRowCount = 0      
            --Pendiente, Servicio Mercancias en Transito, Obtener el IdMovimiento        
            -- Tabla de Det Mcias Transito, OPETraMovMciasTranDet        
            --SubSubAlmacen, seccion, ImporteMN y ClaveListaInventario son Null        
            --Almacen = ClaUbicacionOrigen y SubAlmacen = ClaUbicacionDestino        
--            INSERT INTO OPETraMovMciasTranDet (ClaUbicacion, ClaTipoInventario, IdRenglon, IdMovimiento, ClaTMA, ClaArticulo, ClaFamilia, ClaAlmacen, ClaSeccion,         
--  ClaSubAlmacen, ClaSubFamilia, ClaSubSubAlmacen, ClaveListaInventario, ClaUbicacionDestino, CampoEntero1, CampoEntero2, CampoEntero3,         
--                        CampoEntero4, CampoEntero5, CampoEntero6, CampoTexto1, CampoTexto2, Cantidad, EntradaSalida, EstatusTransito, FechaHoraMovimiento,         
--                        ImporteMN, KilosPesados, KilosTeoricos, PesoTeorico, ReferenciaCompras, FechaUltimaMod, ClaUsuarioMod, NombrePCMod)        
  
            INSERT INTO OPESch.OpeTraMovMciasTranDet (ClaUbicacion, ClaTipoInventario, IdRenglon, IdMovimiento, ClaTMA, ClaArticulo, ClaUbicacionDestino, CampoEntero1,      
        CampoEntero2, CampoEntero3, CampoEntero4, CampoEntero5, CampoEntero6, CampoTexto1, CampoTexto2, CantidadEnviada, CantidadRecibida,       
        CantidadCancelada, CantidadDepurada, Saldo, EntradaSalida, EstatusTransito, FechaHoraMovimiento, Importe, KilosPesados, KilosTeoricos,      
        PesoTeorico, ReferenciaCompras, FechaUltimaMod, ClaUsuarioMod, NombrePCMod,      
        KilosTara, NumericoExtra1,NumericoExtra2 ,NumericoExtra3,NumericoExtra4,NumericoExtra5,NumericoExtra6,NumericoExtra7,      
        TextoExtra1,TextoExtra2,TextoExtra3,TextoExtra4,TextoExtra5,TextoExtra6,TextoExtra7) --Agragado para PLO       
       --IdRemision, IdRemisionTexto, IdFabricacion, IdFabricacionDet, Tarimas) --Agragado para PLO       
            SELECT A.ClaUbicacion, A.ClaTipoInventario, A.IdRenglon, @pnIdMovimientoMT, A.ClaTMA, A.ClaArticulo,       
       --A.ClaFamilia, @pnClaUbicacionOrigen, Null, Case @pnAccionTransito when 2 Then A.ClaSubAlmacen when 3  Then A.ClaSubAlmacen  when 4  Then A.ClaSubAlmacen else A.ClaUbicacionDestino end,         
                   --A.ClaSubFamilia, Null, Null,         
                   A.ClaUbicacionDestino, A.CampoEntero1, A.CampoEntero2, A.CampoEntero3,         
                   A.CampoEntero4, A.CampoEntero5, A.CampoEntero6, A.CampoTexto1, A.CampoTexto2, A.Cantidad, 0, 0, 0, A.Cantidad,       
                   A.EntradaSalida, ISNull(A.EstatusTransito,0), A.FechaHoraMovimiento,  NULL, A.KilosPesados, A.KilosTeoricos,       
       A.PesoTeorico, A.ReferenciaCompras, GETDATE(), A.ClaUsuarioMod, A.NombrePCMod ,      
       KilosTara, NumericoExtra1,NumericoExtra2 ,NumericoExtra3,NumericoExtra4,NumericoExtra5,NumericoExtra6,NumericoExtra7,      
       TextoExtra1,TextoExtra2,TextoExtra3,TextoExtra4,TextoExtra5,TextoExtra6,TextoExtra7 --Agragado para PLO       
       --IdRemision, IdRemisionTexto, IdFabricacion, IdFabricacionDet, Tarimas --Agragado para PLO      
            FROM OPESch.OpeTraIntRegMovDet A WITH (NOLOCK)        
JOIN OPESch.OpeCatTMAVw B WITH (NOLOCK)        
            ON B.ClaTMA = A.ClaTMA        
            AND B.ClaTipoInventario = A.ClaTipoInventario        
            AND B.EsMercanciaEnTransito = 1        
   JOIN OPESch.OpeTraIntRegMovEnc C  WITH (NOLOCK)       
   ON C.IdTokenMovimiento = A.IdTokenMovimiento and      
   C.ClaUbicacion = A.ClaUbicacion and      
   C.ClaTipoInventario = A.ClaTipoInventario      
            WHERE A.IdTokenMovimiento = @pnIdTokenMovimiento  AND      
      A.ClaUbicacion = @pnClaUbicacion AND      
      A.ClaTipoInventario = @pnClaTipoInventario      
            AND A.Pesoteorico IS NOT NULL  AND      
   isnull(C.ClaUbicacionOrigen, 0) != 0 AND      
   Isnull(A.ClaUbicacionDestino, 0) != 0       
            SELECT @pnERROR = @@Error , @pnRowCount = @@RowCount        
            IF @pnERROR <> 0 or @pnRowCount = 0        
                  BEGIN         
                        set @pnERROR = 99        
                        IF @pnDebugLevel <> 0 PRINT 'Error, Insertar Mercancias en Transito, OPETraMovMciasTranDet. ' +  @psNombreSp        
                        GOTO FINSP        
                  END        
      END           
END        
       

--Actualizar tablas temporales con Numero de Movimiento y Clave Movimiento, Por Cuenta Puente        
UPDATE OPESch.OpeTraIntRegMovEnc  --WITH(UPDLOCK,ROWLOCK)      
Set IdMovimiento = @pnIdMovimiento,        
      ClaveMovimiento = @pnClaveMovimiento        
Where IdTokenMovimiento = @pnIdTokenMovimiento    AND      
  ClaUbicacion = @pnClaUbicacion AND      
  ClaTipoInventario = @pnClaTipoInventario      

UPDATE OPESch.OpeTraIntRegMovDet  --WITH(UPDLOCK,ROWLOCK)      
Set IdMovimiento = @pnIdMovimiento        
Where IdTokenMovimiento = @pnIdTokenMovimiento    AND      
 ClaUbicacion = @pnClaUbicacion AND      
 ClaTipoInventario = @pnClaTipoInventario      
------------------------------------------------------------------------------------------        
-- validar si el movimiento es us una Modificacion        
------------------------------------------------------------------------------------------        
	IF @@SERVERNAME = 'SRVDBDES01\ITKQA'
		SELECT '' AS 'OpeTraMovMciasTranDet2', * FROM OPESch.OpeTraMovMciasTranDet Where IdMovimiento = @pnIdMovimientoMT AND ClaUbicacion = @pnClaUbicacion AND ClaTipoInventario = @pnClaTipoInventario 


IF @pnTipoMovimiento <> 2        
BEGIN        
      --Registrar Movimiento, Insertar encabezado y detalles (incluyendo los de afectaci<"®n a cuenta puente         
            INSERT INTO OPESch.OpeTraRegistroMovEnc (ClaUbicacion, ClaTipoInventario, IdMovimiento, ClaMotivoInventario, ClaTipoClaveMovimiento, ClaUbicacionOrigen, ClaUsuarioAutorizo, ClaveMovimiento,         
                        FechaAutorizacion, FechaHoraMovimiento, FechaMovimiento, NombrePcAutorizo, NoRenglonesMovimiento, PesoEntrada, PesoNeto, PesoSalida, PesoTara, ViajeOriginal,         
                        CampoEntero1, CampoEntero2, CampoEntero3, CampoEntero4, CampoEntero5, CampoEntero6, CampoEntero7, CampoEntero8, CampoEntero9, CampoEntero10, CampoTexto1,      
                        CampoTexto2, CampoTexto3, CampoTexto4, CampoTexto5, CampoTexto6, CampoTexto7, CampoTexto8, CampoTexto9, CampoTexto10, FechaUltimaMod, ClaUsuarioMod, NombrePcMod,      
                        ClaGrupoTMA, PesoDocumentado, PesoNoDocumentado)--, Observaciones, NomTransportista, Caja, Sello, EjeTransporte, AgenciaAduanal)--Agragado para PLO        
          SELECT ClaUbicacion, ClaTipoInventario, @pnIdMovimiento, ClaMotivoInventario, ClaTipoClaveMovimiento, ClaUbicacionOrigen, ClaUsuarioAutorizo, @pnClaveMovimiento,         
                        FechaAutorizacion, FechaHoraMovimiento, FechaMovimiento, NombrePcAutorizo, NoRenglonesMovimiento, PesoEntrada, PesoNeto, PesoSalida, PesoTara, ViajeOriginal,         
                        CampoEntero1, CampoEntero2, CampoEntero3, CampoEntero4, CampoEntero5, CampoEntero6, CampoEntero7, CampoEntero8, CampoEntero9, CampoEntero10, CampoTexto1,         
                        CampoTexto2, CampoTexto3, CampoTexto4, CampoTexto5, CampoTexto6, CampoTexto7, CampoTexto8, CampoTexto9, CampoTexto10, GETDATE(), ClaUsuarioMod, NombrePcMod ,      
                        ClaGrupoTMA, PesoDocumentado, PesoNoDocumentado--, Observaciones, NomTransportista, Caja, Sello, EjeTransporte, AgenciaAduanal --Agragado para PLO      
            FROM OPESch.OpeTraIntRegMovEnc WITH (NOLOCK)        
            WHERE IdTokenMovimiento = @pnIdTokenMovimiento AND      
     ClaUbicacion = @pnClaUbicacion AND      
     ClaTipoInventario = @pnClaTipoInventario      
            SELECT @pnERROR = @@Error , @pnRowCount = @@RowCount        
            IF @pnERROR <> 0 or @pnRowCount = 0        
                  BEGIN         
                        set @pnERROR = 99        
                        IF @pnDebugLevel <> 0 PRINT 'Error, Insertar Mercancias en Transito, OPETraMovMciasTranDet. ' +  @psNombreSp        
                        GOTO FINSP        
                  END        
  SET @pnERROR = 0      
          SET @pnRowCount = 0      
              
    
    
        
            INSERT INTO OPESch.OpeTraRegistroMovDet (IdMovimiento, IdRenglon, ClaUbicacion, ClaTipoInventario, ClaTMA, ClaArticulo, ClaFamilia, ClaAlmacen, ClaSeccion,         
                        ClaSubAlmacen, ClaSubFamilia, ClaSubSubAlmacen, ClaveListaInventario, ClaUbicacionDestino, CampoEntero1, CampoEntero2, CampoEntero3,         
                        CampoEntero4, CampoEntero5, CampoEntero6, CampoTexto1, CampoTexto2,CampoTexto3,CampoTexto4,CampoTexto5, Cantidad, EntradaSalida, EstatusTransito, FechaHoraMovimiento,         
                        ImporteMN, KilosPesados, KilosTeoricos, PesoTeorico, ReferenciaCompras, FechaUltimaMod, ClaUsuarioMod, NombrePCMod        
                        ,ClaTipoReferencia, ClaCrc, EsConsumoEspecial, CampoEntero10, ClaDepartamento, Existencia, Costo, ImporteDlls,      
                        KilosTara, NumericoExtra1,NumericoExtra2 ,NumericoExtra3,NumericoExtra4,NumericoExtra5,NumericoExtra6,NumericoExtra7,      
      TextoExtra1,TextoExtra2,TextoExtra3,TextoExtra4,TextoExtra5,TextoExtra6,TextoExtra7) --Agragado para PLO       
                        --IdRemision, IdRemisionTexto, IdFabricacion, IdFabricacionDet, Tarimas)  --Agragado para PLO      
            SELECT @pnIdMovimiento, IdRenglon, ClaUbicacion, ClaTipoInventario, ClaTMA, ClaArticulo, ClaFamilia, ClaAlmacen, ClaSeccion,         
                        ClaSubAlmacen, ClaSubFamilia, ClaSubSubAlmacen, ClaveListaInventario, ClaUbicacionDestino, CampoEntero1, CampoEntero2, CampoEntero3,         
                        CampoEntero4, CampoEntero5, CampoEntero6, CampoTexto1, CampoTexto2,CampoTexto3,CampoTexto4,CampoTexto5, Cantidad, EntradaSalida, EstatusTransito, FechaHoraMovimiento,         
                        ImporteMN, KilosPesados, KilosTeoricos, PesoTeorico, ReferenciaCompras, GETDATE(), ClaUsuarioMod, NombrePCMod         
                        ,ClaTipoReferencia, ClaCrc, EsConsumoEspecial, CampoEntero10, ClaDepartamento, Existencia,Costo, ImporteDlls,      
                        KilosTara, NumericoExtra1,NumericoExtra2 ,NumericoExtra3,NumericoExtra4,NumericoExtra5,NumericoExtra6,NumericoExtra7,      
      TextoExtra1,TextoExtra2,TextoExtra3,TextoExtra4,TextoExtra5,TextoExtra6,TextoExtra7 --Agragado para PLO       
                        --IdRemision, IdRemisionTexto, IdFabricacion, IdFabricacionDet, Tarimas --Agragado para PLO      
            FROM OPESch.OpeTraIntRegMovDet    WITH (NOLOCK)      
            WHERE IdTokenMovimiento = @pnIdTokenMovimiento AND      ClaUbicacion = @pnClaUbicacion AND      
    ClaTipoInventario = @pnClaTipoInventario     
    
  --  SELECT  *  
  --FROM    OPESch.OpeTraIntRegMovDet    WITH (NOLOCK)      
  --          WHERE IdTokenMovimiento = @pnIdTokenMovimiento AND      ClaUbicacion = @pnClaUbicacion AND      
  --  ClaTipoInventario = @pnClaTipoInventario   
    


            SELECT @pnERROR = @@Error , @pnRowCount = (SELECT COUNT(*) FROM OPESch.OpeTraRegistroMovDet WITH (NOLOCK) WHERE IdMovimiento = @pnIdMovimiento)--@@RowCount                
--SELECT * FROM OPETraRegistroMovDet WITH (NOLOCK) WHERE IdMovimiento = @pnIdMovimiento      
--SELECT @pnERROR, @pnRowCount      
            IF @pnERROR <> 0 or @pnRowCount = 0        
     BEGIN         
     set @pnERROR =  71       
     EXEC OpeSch.ErrLanzaExcepcionNegocio @pnNumError = @pnERROR, @psNombreSP = @psNombreSp        
     IF @pnDebugLevel <> 0 PRINT 'Error, Insertar Mercancias en Transito, OPETraMovMciasTranDet. ' +  @psNombreSp        
     GOTO FINSP    
     END        
--SELECT 'si sale inserta det'          
--SELECT @@trancount AS AplicaD1      
      --Actualiza Mercancia en transito si @pnAccionTransito es 3 Cambio de destino o 2 Cancelacion        
      if @pnAccionTransito in ( 2, 3 )        
      BEGIN        
    INSERT INTO #tmp_MovTransito (IdMovimiento)        
    SELECT A.IdMovimiento        
    FROM OPESch.OpeTraRegistroMovEnc A WITH (NOLOCK)         
    JOIN OPESch.OpeTraRegistroMovDet B WITH (NOLOCK)         
    on A. IdMovimiento = B.IdMovimiento        
    WHERE A.ViajeOriginal =  @pnViajeOriginal        
    AND B.EstatusTransito in ( 0, 1 )        
   END      
    SELECT @pnIdSeq = MIN(IdSeq)         
    FROM #tmp_MovTransito  /*WITH (NOLOCK)*/      
    IF @pnAccionTransito = 2      
    BEGIN      
    WHILE @pnIdSeq IS NOT NULL        
    BEGIN            
    Select @pnIdMovimientoMt = IdMovimiento        
    From #tmp_MovTransito  /*WITH (NOLOCK)*/      
    Where IdSeq = @pnIdSeq        
    UPDATE OPESch.OpeTraRegistroMovDet --WITH (ROWLOCK, UPDLOCK)              
    SET EstatusTransito = A.EstatusTransito,        
     FechaUltimaMod = GETDATE(),         
     NombrePCMod = @psNombrePcMod        
    FROM OPESch.OpeTraIntRegMovDet A  WITH (NOLOCK)      
    JOIN OPESch.OpeTraRegistroMovDet B /*WITH (NOLOCK)*/      
    ON  B.IdMovimiento = @pnIdMovimientoMt        
    AND A.ClaUbicacion =  B.ClaUbicacion      
    AND A.ClaTipoInventario = B.ClaTipoInventario      
    AND A.ClaArticulo = B.ClaArticulo        
    AND A.ClaAlmacen = B.ClaAlmacen        
    AND A.ClaSubAlmacen = B.ClaSubAlmacen      
    AND B.EntradaSalida = 1      --** este es el cambio que se aplico para lo de las cancelaciones.      
    WHERE  A.IdTokenMovimiento = @pnIdTokenMovimiento AND      
      A.ClaUbicacion = @pnClaUbicacion AND      
      A.ClaTipoInventario = @pnClaTipoInventario      
    SELECT @pnIdSeq = MIN(IdSeq)         
    FROM #tmp_MovTransito  /*WITH (NOLOCK)*/      
    WHERE IdSeq > @pnIdSeq               
     END       
    END        
    ELSE IF @pnAccionTransito = 3      
    BEGIN      
       WHILE @pnIdSeq IS NOT NULL        
    BEGIN            
    Select @pnIdMovimientoMt = IdMovimiento        
    From #tmp_MovTransito  /*WITH (NOLOCK)*/      
    Where IdSeq = @pnIdSeq        
    UPDATE OPESch.OpeTraRegistroMovDet --WITH (ROWLOCK, UPDLOCK)             
    SET EstatusTransito = A.EstatusTransito,        
     FechaUltimaMod = GETDATE(),         
     NombrePCMod = @psNombrePcMod        
    FROM OPESch.OpeTraIntRegMovDet A  WITH (NOLOCK)      
    JOIN OPESch.OpeTraRegistroMovDet B /*WITH (NOLOCK)*/      
    ON  B.IdMovimiento = @pnIdMovimientoMt       
    AND A.ClaUbicacion = B.ClaUbicacion      
    AND A.ClaTipoInventario = B.ClaTipoInventario       
    AND A.ClaArticulo = B.ClaArticulo        
    AND A.ClaAlmacen = B.ClaAlmacen        
    AND A.ClaSubAlmacen = B.ClaSubAlmacen        
    WHERE  A.IdTokenMovimiento = @pnIdTokenMovimiento  AND      
      A.ClaUbicacion = @pnClaUbicacion AND      
      A.ClaTipoInventario = @pnClaTipoInventario      
    SELECT @pnIdSeq = MIN(IdSeq)         
    FROM #tmp_MovTransito  /*WITH (NOLOCK)*/      
    WHERE IdSeq > @pnIdSeq               
     END       
    END      
END        
ELSE        
BEGIN        
      -- Si el movimiento es una modificaci<"®n se actualizan los datos del movimiento en la entidad Registro de Movimientos        
      IF @pnDebugLevel <> 0 PRINT 'El Movimiento es una Modificacion. ' +  @psNombreSp        
      --Actualiza Encabezado        
--Select 'TEST ANTES', * FROM OPESch.OpeTraRegistroMovEnc WITH (NOLOCK) WHERE IdMovimiento = @pnIdMovimiento         
      UPDATE OPESch.OpeTraRegistroMovEnc --WITH (ROWLOCK, UPDLOCK)       
      SET FechaMovimiento = A.FechaMovimiento,        
          FechaHoraMovimiento = A.FechaHoraMovimiento,        
          PesoEntrada = A.PesoEntrada,        
          PesoNeto = A.PesoNeto,        
          PesoSalida = A.PesoSalida,        
          PesoTara = A.PesoTara,        
          FechaUltimaMod = GETDATE(),        
          NombrePcMod = A.NombrePcMod        
      FROM OPESch.OpeTraIntRegMovEnc A  WITH (NOLOCK)      
      JOIN OPESch.OpeTraRegistroMovEnc B /*WITH (NOLOCK)*/          
      ON B.ClaUbicacion = A.ClaUbicacion         
      AND B.ClaTipoInventario = A.ClaTipoInventario        
      AND A.IdMovimiento = B.IdMovimiento        
      WHERE A.IdMovimiento = @pnIdMovimiento        
      AND IdTokenMovimiento = @pnIdTokenMovimiento      AND      
   A.ClaUbicacion = @pnClaUbicacion AND      
   A.ClaTipoInventario = @pnClaTipoInventario      
--Select 'TEST DESPUES', * FROM OPESch.OpeTraRegistroMovEnc WITH (NOLOCK) WHERE IdMovimiento = @pnIdMovimiento         
  IF (@pnClaTipoInventario = 1)      
  BEGIN      
     --Select 'TEST ANTES', * FROM OPESch.OpeTraRegistroMovDet WITH (NOLOCK) WHERE IdMovimiento = @pnIdMovimiento        
     --Actualiza Detalles        
     update OPETraRegistroMovDet --WITH (ROWLOCK, UPDLOCK)       
     SET Cantidad = A.Cantidad,        
      EntradaSalida = A.EntradaSalida,        
      FechaHoraMovimiento = A.FechaHoraMovimiento,        
      KilosPesados = A.KilosPesados,        
      KilosTeoricos = A.KilosTeoricos,        
      PesoTeorico = A.PesoTeorico,        
      FechaUltimaMod = GETDATE(),        
      ClaUsuarioMod = A.ClaUsuarioMod,        
      NombrePCMod = A.NombrePCMod        
     FROM OPESch.OpeTraIntRegMovDet A  WITH (NOLOCK)      
     JOIN OPESch.OpeTraRegistroMovDet B /*WITH (NOLOCK)*/      
     ON B.ClaUbicacion = A.ClaUbicacion        
     AND B.ClaTipoInventario = A.ClaTipoInventario        
     AND B.ClaArticulo = A.ClaArticulo        
     AND B.ClaAlmacen = A.ClaAlmacen        
     AND ISNULL(B.ClaSubAlmacen,0) = ISNULL(A.ClaSubAlmacen,0)        
     AND ISNULL(B.ClaSubSubAlmacen,0) = ISNULL(A.ClaSubSubAlmacen,0)        
     AND ISNULL(B.ClaSeccion,0) = ISNULL(A.ClaSeccion,0)        
     AND (ISNULL(B.CampoEntero1,0) = ISNULL(A.CampoEntero1,0) AND ISNULL(B.CampoTexto1,'') = ISNULL(A.CampoTexto1,''))      
     AND (ISNULL(B.CampoEntero2,0) = ISNULL(A.CampoEntero2,0) AND ISNULL(B.CampoTexto2,'') = ISNULL(A.CampoTexto2,''))      
     AND (ISNULL(B.CampoEntero3,0) = ISNULL(A.CampoEntero3,0) AND ISNULL(B.CampoTexto3,'') = ISNULL(A.CampoTexto3,''))      
     AND (ISNULL(B.CampoEntero4,0) = ISNULL(A.CampoEntero4,0) AND ISNULL(B.CampoTexto4,'') = ISNULL(A.CampoTexto4,''))      
     AND (ISNULL(B.CampoEntero5,0) = ISNULL(A.CampoEntero5,0) AND ISNULL(B.CampoTexto5,'') = ISNULL(A.CampoTexto5,''))       
     AND A.IdMovimiento = B.IdMovimiento        
     AND A.IdRenglon = B.IdRenglon        
     WHERE A.IdMovimiento = @pnIdMovimiento        
     AND IdTokenMovimiento = @pnIdTokenMovimiento  AND      
    A.ClaUbicacion = @pnClaUbicacion AND      
    A.ClaTipoInventario = @pnClaTipoInventario       
  END      
  ELSE IF (@pnClaTipoInventario = 2)      
  BEGIN      
     --Actualiza Detalles        
     update OPESch.OpeTraRegistroMovDet --WITH (ROWLOCK, UPDLOCK)      
     SET Cantidad = A.Cantidad,        
      EntradaSalida = A.EntradaSalida,        
      FechaHoraMovimiento = A.FechaHoraMovimiento,        
      KilosPesados = A.KilosPesados,        
      KilosTeoricos = A.KilosTeoricos,        
      PesoTeorico = A.PesoTeorico,        
      FechaUltimaMod = GETDATE(),        
      ClaUsuarioMod = A.ClaUsuarioMod,        
      NombrePCMod = A.NombrePCMod        
     FROM OPESch.OpeTraIntRegMovDet A  WITH (NOLOCK)      
     JOIN OPESch.OpeTraRegistroMovDet B /*WITH (NOLOCK)*/           
     ON B.ClaUbicacion = A.ClaUbicacion        
     AND B.ClaTipoInventario = A.ClaTipoInventario        
     AND B.ClaArticulo = A.ClaArticulo        
     AND B.ClaAlmacen = A.ClaAlmacen        
     AND ISNULL(B.ClaSubAlmacen,0) = ISNULL(A.ClaSubAlmacen,0)        
     AND ISNULL(B.ClaSubSubAlmacen,0) = ISNULL(A.ClaSubSubAlmacen,0)        
     AND ISNULL(B.ClaSeccion,0) = ISNULL(A.ClaSeccion,0)         
     AND A.IdMovimiento = B.IdMovimiento        
     AND A.IdRenglon = B.IdRenglon        
     WHERE A.IdMovimiento = @pnIdMovimiento        
     AND IdTokenMovimiento = @pnIdTokenMovimiento AND      
    A.ClaUbicacion = @pnClaUbicacion AND      
    A.ClaTipoInventario = @pnClaTipoInventario       
  END            
END              
IF( @l_bAbrirTrans = 1 )      
 COMMIT TRAN               
SET NOCOUNT OFF              
SET ANSI_NULLS OFF              
RETURN 0              
--* Terminaci<"®n del objeto              
FINSP:              
IF @pnERROR <> 0      
BEGIN      
 --SELECT 'llega error', @pnERROR AS ERROR      
 IF  EXISTS (SELECT * FROM tempdb.sys.objects WITH (NOLOCK) WHERE name = '##TmpSesionError' AND type in (N'U'))        
 BEGIN      
  SET @SesionError = (SELECT COUNT(*) FROM ##TmpSesionError  /*WITH (NOLOCK)*/ where spid = @@spid)      
 END      
  IF ((@SesionError > 0) OR @pnERROR <> 0)      
  BEGIN         
--SELECT 'llega ROLL', @l_bAbrirTrans AS l_bAbrirTrans_Error      
  IF( @l_bAbrirTrans = 1 )      
  ROLLBACK TRAN       
  DELETE OPESch.OpeTraIntRegMovDet  /*WITH (ROWLOCK)*/ WHERE IdTokenMovimiento = @pnIdTokenMovimiento      
  DELETE OPESch.OpeTraIntRegMovEnc  /*WITH (ROWLOCK)*/ WHERE IdTokenMovimiento = @pnIdTokenMovimiento               
  END        
SET NOCOUNT OFF              
SET ANSI_NULLS OFF              
SET ANSI_WARNINGS ON            
  RETURN @pnERROR              
 END             
END