USE Operacion
GO
-- 'OPESch.OPE_CU109_Pag11_Boton_Load_Proc'
GO
ALTER PROCEDURE OPESch.OPE_CU109_Pag11_Boton_Load_Proc
										@pnClaUbicacion			int,
										@pnClaUsuarioMod        INT
	
as
BEGIN
	SET NOCOUNT ON

--*==============================================================
--*Objeto:		'OPESch.OPE_CU109_Pag11_Boton_Load_Proc'
--*Autor:		Luis F Verastegui
--*Fecha:		27/10/2015
--*Objetivo:	
--*Entrada:
--*Salida:
--*Precondiciones:
--*Revisiones:								exec   OPESch.OPE_CU109_Pag11_Boton_Load_Proc 325, 360047
--*==============================================================


DECLARE @pnClaUbicacionClick    INT
Select @pnClaUbicacionClick = @pnClaUbicacion
Declare @pnEsIndustrial int,
	@psUrlPedidosPorSurtir varchar(250),
	@psUrlPlaneadorEmbarques varchar(250),
	@psUrlCitasyPisos varchar(250),
	@psUrlMonitorEmbarques varchar(250),
	@psUrlCitasyPisos2 varchar(250),
	@psUrlIndicadoresLocales varchar(250),
	@psUrlBuscadordeArticulos varchar(250),
	@psUrlPagoFletes varchar(250),
	@psUrlSIIdeProduccion varchar(250),
	@psUrlMicroprogramador varchar(250),
	@psUrlExcelenciaOpe varchar(250),
	@psUrlControlInventarios varchar(250),
	@psUrlInventarioCablesDeacero varchar(250),
	@psUrlEvaluacióndePersonal varchar(250),
	@psUrlCalidaddeProductos varchar(250),
	@psUrlPedidosPorSurtirXOPM varchar(250),
	
	@psUrlConsultaOfertadeServicio varchar(250),
	@psUrlDeudaExistenciaporOPM varchar(250),
	
	@pnHabilitaEntSalVarias INT,
	
	--Fijos
	@psUrlTraspasosporrecibir varchar(250),
	@psUrlIndicadoresCentrales varchar(250),
	@psUrlProgramadorProdCables varchar(250),
	@psUrlIndicadoresDirPlantaInd varchar(250),
	@psUrlOfertaServicio varchar(250)
	
	,@nEsUbicacionIngetek TINYINT = 0
	
--Para Auto Login 
DECLARE @sLoginUserName VARCHAR(20),@sToken                 VARCHAR(MAX)
      
      CREATE TABLE #tToken (token VARCHAR(MAX))
      
      SELECT      @sLoginUserName   = LoginUserName
      FROM  TiSeguridad.dbo.TiTraUsuario
      WHERE IdUsuario         = @pnClaUsuarioMod      
      
      INSERT #tToken (token)
      EXEC [TiSeguridad].[DTSch].[LoginGeneraToken] @sLoginUserName, NULL

      SELECT @sToken = Token
      FROM #tToken                        
	

select @pnEsIndustrial = 0
If Exists (Select 1 from opeSch.Opeticatubicacionvw with (nolock)
	where ClaUbicacion = @pnClaUbicacion
	and ClaTipoUbicacion = 6)
Begin	
	select @pnEsIndustrial = 1
End
If @pnClaUbicacion = 53-- Excepcion para Mostrar Otros Sistemas
Begin	
	select @pnEsIndustrial = 1
End


	--MJLV 17/Marzo/2020 Se agrega validacion para habilitar Modulo de Ent/Salidas Varias
	SELECT	@pnHabilitaEntSalVarias = (	SELECT nValor1
										FROM OpeSch.OpeCatConfiguracion
										WHERE ClaConfiguracion = 138
										AND ClaSistema = 23
										AND ClaTipoInventario = 1
										AND ClaUbicacion = @pnClaUbicacion
									  )


Select 	@psUrlTraspasosporrecibir = 'http://appnet02:2249/Pages/INV_CU1_Pag1.aspx?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken ,
	@psUrlIndicadoresCentrales = 'http://appnet03:2161/Pages/WTI_CU250_Pag2.aspx?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken ,
	--@psUrlProgramadorProdCables = 'http://appqronet:2155/default.aspx?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken , ---LVR UBICACION 61
	--@psUrlProgramadorProdCables = 'http://appqronet:2155/default.aspx?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE 61 END ) + '&' + @sToken ,
	@psUrlProgramadorProdCables = 'http://APPQRONET03:2155/default.aspx?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE 61 END ) + '&' + @sToken ,
	@psUrlIndicadoresDirPlantaInd = 'http://appindnet02:2162/default.aspx?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken ,
	@psUrlOfertaServicio = 'http://appnet06:2237/Pages/ope_CU442_Pag6.aspx?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken 

--Pendiente validar si estara por Ubicaciones o Central
Select 	@psUrlBuscadordeArticulos = 'http://appnet03:2018/Pages/MAN_CU254_Pag1.aspx?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken
--Buscador de Artículo -- si es por Ubicacion se configura y activa esta linea
---Select @psUrlBuscadordeArticulos = Pagina from OpeSch.OpeCatProcesoDetPag  where ClaSistema = 224 and ClaProceso = 800 and ClaElemento = 800

--Link de Otros sistemas
/*
select A.ClaElemento, A.NomElemento,   B.Pagina
from  OpeSch.OpeCatProcesoDet a inner join OpeSch.OpeCatProcesoDetPag b on a.ClaSistema = b.ClaSistema
and a.ClaProceso = b.ClaProceso
and a.ClaElemento = b.ClaElemento
Where	a.ClaSistema	= 224 and a.ClaProceso	= 800 and Pagina not like '%4243%'
*/

--Planear Embarque
Select @psUrlPlaneadorEmbarques = Pagina from OpeSch.OpeCatProcesoDetPag  where ClaSistema = 224 and ClaProceso = 800 and ClaElemento = 310
Select @psUrlPlaneadorEmbarques = @psUrlPlaneadorEmbarques + '?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken 
--Sitas y Pisos
Select @psUrlCitasyPisos = Pagina from OpeSch.OpeCatProcesoDetPag  where ClaSistema = 224 and ClaProceso = 800 and ClaElemento = 330
Select @psUrlCitasyPisos = @psUrlCitasyPisos + '?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken 
Select @psUrlCitasyPisos2 = Pagina from OpeSch.OpeCatProcesoDetPag  where ClaSistema = 224 and ClaProceso = 800 and ClaElemento = 330
Select @psUrlCitasyPisos2 = @psUrlCitasyPisos2 + '?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken 
--Monitor de Embarque
select @psUrlMonitorEmbarques = Pagina from OpeSch.OpeCatProcesoDetPag  where ClaSistema = 224 and ClaProceso = 800 and ClaElemento = 800
Select @psUrlMonitorEmbarques = @psUrlMonitorEmbarques + '?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken 
--Pago de Fletes 
Select @psUrlPagoFletes = Pagina from OpeSch.OpeCatProcesoDetPag  where ClaSistema = 224 and ClaProceso = 800 and ClaElemento = 760
Select @psUrlPagoFletes = @psUrlPagoFletes + '?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken 
--Indicadores Locales
Select @psUrlIndicadoresLocales = Pagina from OpeSch.OpeCatProcesoDetPag  where ClaSistema = 224 and ClaProceso = 800 and ClaElemento = 440
Select @psUrlIndicadoresLocales = @psUrlIndicadoresLocales + '?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken 
--Calidad de Prodcutos
Select @psUrlCalidaddeProductos = Pagina from OpeSch.OpeCatProcesoDetPag  where ClaSistema = 224 and ClaProceso = 800 and ClaElemento = 850
Select @psUrlCalidaddeProductos = @psUrlCalidaddeProductos + '?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken 
--SII de Producción (PAL)
Select @psUrlSIIdeProduccion = Pagina from OpeSch.OpeCatProcesoDetPag  where ClaSistema = 224 and ClaProceso = 800 and ClaElemento = 810
Select @psUrlSIIdeProduccion = @psUrlSIIdeProduccion + '?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken 
--Control de Inventarios (ATI)
Select @psUrlControlInventarios = Pagina from OpeSch.OpeCatProcesoDetPag  where ClaSistema = 224 and ClaProceso = 800 and ClaElemento = 820
Select @psUrlControlInventarios = @psUrlControlInventarios + '?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken 
--Inventario cables DEACERO (ATI)
Select 	@psUrlInventarioCablesDeacero = 'http://appnet03:2269/Pages/Ati_CU125_Pag6.aspx?wu=6'+ '&' + @sToken


--Microprogramador (MIC)
Select @psUrlMicroprogramador = Pagina from OpeSch.OpeCatProcesoDetPag  where ClaSistema = 224 and ClaProceso = 800 and ClaElemento = 830
Select @psUrlMicroprogramador = @psUrlMicroprogramador + '?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken 
--Excelencia Operacional
select @psUrlExcelenciaOpe = Pagina from OpeSch.OpeCatProcesoDetPag  where ClaSistema = 224 and ClaProceso = 800 and ClaElemento = 1210
Select @psUrlExcelenciaOpe  = @psUrlExcelenciaOpe + '?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken 


--Evaluación de Personal Planta Industriales (EPI)
Select @psUrlEvaluacióndePersonal = Pagina from OpeSch.OpeCatProcesoDetPag  where ClaSistema = 224 and ClaProceso = 800 and ClaElemento = 840
Select @psUrlEvaluacióndePersonal = @psUrlEvaluacióndePersonal + '?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken 
--Pedidos por Surtir
Select @psUrlPedidosPorSurtir = Pagina from OpeSch.OpeCatProcesoDetPag  where ClaSistema = 224 and ClaProceso = 800 and ClaElemento = 790
Select @psUrlPedidosPorSurtir = @psUrlPedidosPorSurtir + '?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken 
--Pedidos Por Surtir X OPM
Select @psUrlPedidosPorSurtirXOPM = Pagina from OpeSch.OpeCatProcesoDetPag  where ClaSistema = 224 and ClaProceso = 800 and ClaElemento = 860
Select @psUrlPedidosPorSurtirXOPM = @psUrlPedidosPorSurtirXOPM + '?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken 

--Consulta Oferta de Servicio
Select @psUrlConsultaOfertadeServicio = Pagina from OpeSch.OpeCatProcesoDetPag  where ClaSistema = 224 and ClaProceso = 800 and ClaElemento = 870
Select @psUrlConsultaOfertadeServicio = @psUrlConsultaOfertadeServicio + '?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken 

---Deuda y Existencia por OPM
Select @psUrlDeudaExistenciaporOPM = Pagina from OpeSch.OpeCatProcesoDetPag  where ClaSistema = 224 and ClaProceso = 800 and ClaElemento = 1100
Select @psUrlDeudaExistenciaporOPM = @psUrlDeudaExistenciaporOPM + '?wu='+CONVERT(VARCHAR(100), CASE WHEN @pnClaUbicacionClick = 999 THEN 200 ELSE @pnClaUbicacionClick END ) + '&' + @sToken 



	IF EXISTS (
		SELECT	1
		FROM	OpeSch.OpeTiCatUbicacionIngetekVw
		WHERE	ClaUbicacion = @pnClaUbicacion
	)
	BEGIN 
		SET @nEsUbicacionIngetek = 1
	END

Select 	@pnEsIndustrial as EsIndustrial,
	@psUrlTraspasosporrecibir as UrlTraspasosporrecibir,
	@psUrlIndicadoresCentrales as UrlIndicadoresCentrales, 
	@psUrlProgramadorProdCables as UrlProgramadorProdCables,
	@psUrlIndicadoresDirPlantaInd as UrlIndicadoresDirPlantaInd,
	@psUrlOfertaServicio as UrlOfertaServicio,
	@psUrlPedidosPorSurtir as UrlPedidosPorSurtir,
	@psUrlPlaneadorEmbarques as UrlPlaneadorEmbarques  ,
	@psUrlCitasyPisos as UrlCitasyPisos ,
	@psUrlMonitorEmbarques as UrlMonitorEmbarques,
	@psUrlCitasyPisos2 as UrlCitasyPisos2,
	@psUrlIndicadoresLocales as UrlIndicadoresLocales,
	@psUrlBuscadordeArticulos as UrlBuscadordeArticulos,
	@psUrlPagoFletes as UrlPagoFletes,
	@psUrlSIIdeProduccion as UrlSIIdeProduccion, --- se comenta para INGETEK
	@psUrlMicroprogramador as UrlMicroprogramador ,
	--@psUrlExcelenciaOpe    as UrlExcelenciaOpe, --- se comenta para INGETEK
	--@psUrlControlInventarios as UrlControlInventarios,--- se comenta para INGETEK
	@psUrlInventarioCablesDeacero as UrlInventarioCablesDeacero,
	@psUrlEvaluacióndePersonal as UrlEvaluacióndePersonal,
	@psUrlCalidaddeProductos as UrlCalidaddeProductos,
	@psUrlPedidosPorSurtirXOPM as UrlPedidosPorSurtirXOPM,
	@psUrlConsultaOfertadeServicio as UrlConsultaOfertadeServicio,
	@psUrlDeudaExistenciaporOPM as UrlDeudaExistenciaporOPM,
	(CASE WHEN @pnClaUbicacionClick = 20 THEN 1 ELSE 0 END) AS MostrarPlanCargaQueretaro
	,@pnHabilitaEntSalVarias as HabilitaEntSalVarias
	, @nEsUbicacionIngetek	as EsUbicacionIngetek

	SET NOCOUNT OFF
END