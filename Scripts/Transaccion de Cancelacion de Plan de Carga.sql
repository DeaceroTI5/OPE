------Inicio: Transaccion de Cancelacion de Plan de Carga------
select PlacaEstimacion, PlacaVenta, IdBoletaEstimacion, ClaEstatusPlacaEstimacion, IdPlanCargaEstimacion, ClaEstatusPlanCargaEstimacion, IdViajeEstimacion, ClaEstatusViajeEstimacion,
IdBoletaVenta, ClaEstatusPlacaVenta, IdPlanCargaVenta, ClaEstatusPlanCargaVenta, IdViajeVenta, ClaEstatusViajeVenta, * 
from	OpeSch.OpeRelEmbarqueEstimacionVw
where	PlacaVenta = 'SZ9380K'

select * from Opesch.OpeTraPlanCargaRemisionEstimacion
where ClaUbicacionEstimacion = 329 AND IdPlanCargaEstimacion = 24

BEGIN TRAN
	select 'Caso a revisar de Plan de Carga Cancelado'
	select * from Opesch.OpeTraPlanCargaRemisionEstimacion where ClaUbicacionEstimacion = 329 AND IdPlanCargaEstimacion = 24

	select 'Actualización previa a proceso de Cancelacion de Plan de Carga y Eliminación de Placa'
	--update a set a.claestatusplancarga = 2, a.ClaTipoViaje = 5 from OpeSch.OpeTraPlanCarga a where a.IdPlanCarga = 449 and a.ClaUbicacion = 365
	--update a set a.ClaTipoViaje = 5, IdNumTabular = 0 from OpeSch.OpeTraViaje a where a.idboleta = 222290010 and a.ClaUbicacion = 365

	select 'Consulta de Cambios realizados'
	select * from OpeSch.OpeTraPlanCarga a where a.IdPlanCarga = 449 and a.ClaUbicacion = 365
	select * from OpeSch.OpeTraViaje a where a.idboleta = 222290010 and a.ClaUbicacion = 365
	select * from OpeSch.OpeTraMovEntSal a where a.idboleta = 222290010 and a.ClaUbicacion = 365
	select * from OpeSch.OpeTraBoleta a where a.idboleta = 222290010 and a.ClaUbicacion = 365
	select * from OpeSch.OpeTraBoletaHis a where a.idboleta = 222290010 and a.ClaUbicacion = 365
	select 'Consulta de Factura PreCancelacion'
	select * from vtapta.dbo.ev_factura_viaje where cla_planta = 365 and cla_viaje = 449
	select * from vtapta.dbo.ev_factura_enc where cla_planta = 365 and cla_viaje = 449
	select * from vtapta.dbo.ev_factura_det where cla_planta = 365 and cla_viaje = 449

	select 'Ejecucion de Proceso de Cancelacion de Plan de Carga'
	--EXEC	[OpeSch].[OPE_CU72_Pag8_Grid_PlanEncCU72PAG8_IU]
	--		@pnClaUbicacion = 365,
	--		@pnIdPlanCargaCU72PAG8 = 449,
	--		@pnClaUsuarioMod = 10001,
	--		@psNombrePcMod = 'EstimacionesIngetek',
	--		@psIdioma = 'Spansih'

	select 'Ejecucion de Eliminacion de Placa'
	--EXEC	OpeSch.OpeEliminaPlacasProc 
	--		@pnClaUbicacion = 365, 
	--		@pnIdBoleta = 222290010, 
	--		@psNombrePcMod = 'EstimacionesIngetek', 
	--		@pnClaUsuarioMod = 10001

	select 'Consulta de Caso Post Operacion'
	select * from OpeSch.OpeTraPlanCarga a where a.IdPlanCarga = 449 and a.ClaUbicacion = 365
	select * from OpeSch.OpeTraViaje a where a.idboleta = 222290010 and a.ClaUbicacion = 365
	select * from OpeSch.OpeTraMovEntSal a where a.idboleta = 222290010 and a.ClaUbicacion = 365
	select * from OpeSch.OpeTraBoleta a where a.idboleta = 222290010 and a.ClaUbicacion = 365
	select * from OpeSch.OpeTraBoletaHis a where a.idboleta = 222290010 and a.ClaUbicacion = 365

	select 'Consulta de Factura PostCancelacion'
	select * from vtapta.dbo.ev_factura_viaje where cla_planta = 365 and cla_viaje = 449
	select * from vtapta.dbo.ev_factura_enc where cla_planta = 365 and cla_viaje = 449
	select * from vtapta.dbo.ev_factura_det where cla_planta = 365 and cla_viaje = 449

	select 'Consulta de Regitro en PlanCargaRemision - Operacion Bitacora'
	select * from OpeSch.OpeTraPlanCargaRemisionEstimacion

	--insert into OpeSch.OpeTraPlanCargaRemisionEstimacionBit
	--select * 
	--from OpeSch.OpeTraPlanCargaRemisionEstimacion
	--where ClaUbicacionVenta = 365	
	--and IdBoletaVenta = 222290010	
	--and IdPlanCargaVenta = 449	
	--and IdViajeVenta = 449

	--delete from OpeSch.OpeTraPlanCargaRemisionEstimacion
	--where ClaUbicacionVenta = 365	
	--and IdBoletaVenta = 222290010	
	--and IdPlanCargaVenta = 449	
	--and IdViajeVenta = 449

	select * from OpeSch.OpeTraPlanCargaRemisionEstimacion

	select * from OpeSch.OpeTraPlanCargaRemisionEstimacionBit

ROLLBACK TRAN
--COMMIT TRAN

------Fin: Transaccion de Cancelacion de Plan de Carga-----
