exec OPESch.OPE_CU550_Pag28_Grid_GridConsFactEstimaciones_Sel 
  @pnClaUbicacion=325
, @pnCmbCliente=NULL
, @pnCmbProyecto=NULL
, @pnCmbTipoProyecto=NULL
, @pnChkRemNoEntregadas=1
, @psClaUbicacionOrig=''
, @pdFechaInicio=NULL
, @pdFechaFin=NULL
, @pnCmbTransportista=NULL
, @pnChkRemCanceladas=0
, @pnClaUsuarioMod=100010318
, @psTxtRemision=''
, @pnViajeSel=NULL
, @pnDebug=default


--exec OPESch.OPE_CU550_Pag28_Grid_GridConsultaDetArticulo_Sel @pnClaUbicacion=325,@pnFabricacionVenta=23416945,@pnViajeVenta=3,@psRemision='QS2'

--exec OPESch.OPE_CU550_Pag28_Grid_GridConsultaTraArticulo_Sel @pnClaUbicacion=325,@pnIdFabVentaDet=23416945,@pnIdFabDetVentaDet=1,@pnArticuloDet=699630,@pnViajeDet=3,@psRemisionDet='QS2'