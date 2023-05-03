USE Operacion
GO
EXEC SP_HELPTEXT 'OPESch.OPE_CU441_Pag2_Boton_ObtenerInfoFactura_Proc'

EXEC SP_STORED_PROCEDURES '%OPE%CU441_PAG2%'

SELECT @@SERVERNAME
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Boton_AceptarModCMT_Proc'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Boton_CreaPlanDet_Proc'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Boton_EliminaPlanRec_Proc'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Boton_EliminaPlanRecDet_Proc'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Boton_IdFacturaAlfanumerico_Proc'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Boton_LOAD_Proc'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Boton_MsgFaltaPlanTipo_Proc'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Boton_ObtenerInfoFactura_Proc'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Grid_ConsultaModCR_CambioValor_CantRecolectar_Sel'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Grid_ConsultaModET_CambioValor_CantRecolectar_Sel'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Grid_ConsultaModET_IU'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Grid_ConsultaModET_Sel'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Grid_DetPlan_CambioValor_CantRecolectar_Sel'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Grid_DetPlan_CambioValor_PesoRecolectar_Sel'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_ImprimirSrvBack_Proc'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_IU'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Sel'
------------------------------------------------------------------------
--@@GRABAGRID_DetPlan
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Grid_DetPlan_IU'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Grid_DetPlan_Sel'
--@@FILTRAGRID_ConsultaModCR
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Grid_ConsultaModCR_IU'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Grid_ConsultaModCR_Sel'
-- Botón aceptar
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Boton_CreaPlan_Proc'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Boton_ObtieneCiudadMasKms_Proc'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Grid_CapturaManFact_CambioValor_CantRecolectar_Sel'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Grid_CapturaManFact_IU'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Grid_CapturaManFact_Sel'
----------------------------------------------------------------------

	DECLARE @sConexion varchar(1000)  
	SET @sConexion = ''  
   
	SELECT  @sConexion = ISNULL(ConexionRemota,'')  
	FROM	OpeSch.OpeTraConexionRemota WITH(NOLOCK)  
	WHERE	ClaUbicacion = 325 --@pnClaUbicacion  
    AND		ClaSistema = 1990--@pnClaSistema   
    AND		NombreClave = 'VTA5'--@psNombreClave  
	
	SELECT @sConexion as '@sConexion'

	SET @sConexion = @sConexion + '.' + @psObjetoRemoto  


	SELECT * FROM dbo.TiCatClasificacionEstatusVw WHERE NombreClasificacionEstatus like '%reclam%'

	--1270014	Estatus de Plan de Recolección
	--1270011	Estatus Devolucion
	--1270006	Estatus de Reclasificaciones Devoluciones

	SELECT * FROM OpeSch.OpeTiCatestatusVw WHERE ClaClasificacionEstatus = 1270014
	SELECT * FROM OpeSch.OpeTiCatestatusVw WHERE ClaClasificacionEstatus = 1270006


	SELECT  *
	FROM	OpeSch.OpeTraConexionRemota WITH(NOLOCK)  
	WHERE	ClaSistema	= 1990	
    AND		NombreClave = 'VTA5'


	-- DEAWWRNET01
	INSERT INTO OpeSch.OpeTraConexionRemota
	SELECT	  ClaUbicacion		= 267
			, ClaSistema		= 1990
			, ConexionRemota	= '[DEAOFINET05].Ventas.vtasch'
			, ClaUsuarioMod		= 1
			, FechaUltimaMod	= GETDATE()
			, NombrePcMod		= 'CargaInicial'
			, NombreClave		= 'VTA5'


	SELECT * FROM OpeSch.OpeTraPlanRecoleccion WITH(NOLOCK) WHERE ClaUbicacionGenero = 267 OR ClaUbicacionDestino = 267
	SELECT * FROM OpeSch.OpeTraPlanRecoleccionDet WITH(NOLOCK) 


	SELECT	* 
	FROM	OPE_6OFGRALES_LNKSVR.Operacion.OpeSch.OpeTraPlanRecoleccionOfiDet WITH(NOLOCK)	-- DEAOFINET04
	WHERE	ClaUbicacion = 267 
	AND		IdFactura = 1058000001


/*Trace*/
exec OPESch.OPE_CU441_Pag2_Sel @pnClaUbicacion=267,@pnIdPlanRecoleccion=NULL,@pnClaTipoInventario=default,@psIdioma='Spanish'
go
exec OPESch.OPE_CU441_Pag2_Grid_DetPlan_Sel @pnClaUbicacion=267,@pnIdPlanRecoleccion=NULL,@pnClaTipoInventario=default,@psIdioma='Spanish'
go
exec OPESch.OPE_CU441_Pag2_Grid_ConsultaModET_Sel @pnClaUbicacion=267,@pnClaTipoInventario=default,@pnClaClienteModET=NULL,@pnClaConsignadoModET=NULL,@pnClaCiudadModET=NULL,@psIdioma='Spanish'
go
exec OPESch.OPE_CU441_Pag2_Grid_ConsultaModCR_Sel @pnClaUbicacion=267,@pnIdPlanRecoleccion=NULL,@pnClaTipoInventario=default,@pnIdRmaModCR=NULL,@pnClaClienteModCR=NULL,@pnClaConsignadoModCR=NULL,@psIdioma='Spanish'
go
exec OPESch.OPE_CU441_Pag2_Grid_CapturaManFact_Sel @pnClaUbicacion=267,@psIdFacturaAlfanumerico=''
go
-- + RMA
exec OPESch.OPE_CU441_Pag2_Grid_ConsultaModCR_Sel @pnClaUbicacion=267,@pnIdPlanRecoleccion=NULL,@pnClaTipoInventario=default,@pnIdRmaModCR=NULL,@pnClaClienteModCR=NULL,@pnClaConsignadoModCR=NULL,@psIdioma='Spanish'
go
-- Capturar RMA


