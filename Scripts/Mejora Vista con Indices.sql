USE [Operacion]
GO


--EXEC SP_HELPINDEX 'OpeSch.OpeTraMovEntSal'
--EXEC SP_HELPINDEX 'OpeSch.OpeTraPlanCargaRemisionEstimacion'
--EXEC SP_HELPINDEX 'OpeSch.OPETraMovEntSalDet'
--EXEC SP_HELPINDEX 'OpeSch.OpeTraPlanCargaDet'

/*
DROP INDEX IDX_OpeTraMovEntSal_XXIII ON [OpeSch].[OpeTraMovEntSal]
DROP INDEX IDX_OPETraMovEntSalDet_XI ON [OpeSch].[OPETraMovEntSalDet]
DROP INDEX IDX_OPETraMovEntSalDet_XII ON [OpeSch].[OPETraMovEntSalDet]
DROP INDEX IDX_OpeTraPlanCargaDet_XIV ON [OpeSch].[OpeTraPlanCargaDet]

DROP VIEW OpeSch.OpeRelacionEmbarqueEncVw
DROP VIEW OpeSch.OpeRelacionEmbarqueDetVw
DROP VIEW OpeSch.OpeRelEmbarqueEstimacionVw2
*/


CREATE NONCLUSTERED INDEX [IDX_OpeTraMovEntSal_XXIII] ON [OpeSch].[OpeTraMovEntSal]
(
	[ClaUbicacion] ASC,
	[IdBoleta] ASC,
	[IdViaje] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IDX_OPETraMovEntSalDet_XI] ON [OpeSch].[OPETraMovEntSalDet]
(
	[ClaUbicacion] ASC,
	[IdMovEntSal] ASC,
	[IdFabricacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IDX_OPETraMovEntSalDet_XII] ON [OpeSch].[OPETraMovEntSalDet]
(
	[ClaUbicacion] ASC,
	[IdMovEntSal] ASC,
	[ClaArticulo] ASC,
	[IdFabricacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IDX_OpeTraPlanCargaDet_XIV] ON [OpeSch].[OpeTraPlanCargaDet]
(
	[ClaUbicacion] ASC,
	[IdPlanCarga] ASC,
	[IdFabricacion] ASC,
	[ClaArticulo] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


------------------------------------------------------------

CREATE VIEW OpeSch.OpeRelacionEmbarqueEncVw
AS
	SELECT	T1.ClaUbicacionVenta			AS PlantaVirtual,		
			TV2.IdBoleta					AS IdBoletaVenta,
			TV2.ClaMotivoEntrada			AS ClaMotivoEntradaVenta,
			TV2.Placa						AS PlacaVenta,
			TV2.ClaEstatusPlaca				AS ClaEstatusPlacaVenta,
			TV3.IdPlanCarga					AS IdPlanCargaVenta,
			TV3.ClaEstatusPlanCarga			AS ClaEstatusPlanCargaVenta,
			TV3.ClaTransporte				AS ClaTransporteVenta,
			TV4.IdViaje						AS IdViajeVenta,
			TV4.ClaEstatus					AS ClaEstatusViajeVenta,
			TV4.FechaViaje					AS FechaViajeVenta,
			TV4.ClaPais						AS ClaPaisVenta,
			TV4.ClaTipoViaje				AS TipoViajeVenta,
			TV4.ClaTipoTabular				AS TipoTabularVenta,
			TV4.IdNumTabular				AS NumTabularVenta,
			TV4.ClaTransportista			AS ClaTransportistaVenta,
			TV5.IdMovEntSal					AS IdMovEntSalVenta,
			TV5.IdFabricacion				AS FabricacionVenta,
			TV5.ClaValorEstatus				AS ClaValorEstatusVenta,
			TV5.IdFactura					AS FacturaVenta,
			TV5.IdFacturaAlfanumerico		AS FacturaAlfanumericoVenta,
			T1.ClaUbicacionEstimacion		AS PlantaEstimacion,
			TE2.IdBoleta					AS IdBoletaEstimacion,
			TE2.ClaMotivoEntrada			AS ClaMotivoEntradaEstimacion,
			TE2.Placa						AS PlacaEstimacion,
			TE2.ClaEstatusPlaca				AS ClaEstatusPlacaEstimacion,
			TE3.IdPlanCarga					AS IdPlanCargaEstimacion,
			TE3.ClaEstatusPlanCarga			AS ClaEstatusPlanCargaEstimacion,
			TE3.ClaTransporte				AS ClaTransporteEstimacion,
			TE4.IdViaje						AS IdViajeEstimacion,
			TE4.ClaEstatus					AS ClaEstatusViajeEstimacion,
			TE4.FechaViaje					AS FechaViajeEstimacion,
			TE4.ClaPais						AS ClaPaisEstimacion,
			TE4.ClaTipoViaje				AS TipoViajeEstimacion,
			TE4.ClaTipoTabular				AS TipoTabularEstimacion,
			TE4.IdNumTabular				AS NumTabularEstimacion,
			TE4.ClaTransportista			AS ClaTransportistaEstimacion,
			TE5.IdMovEntSal					AS IdMovEntSalEstimacion,
			TE5.IdFabricacion				AS FabricacionEstimacion,
			TE5.ClaValorEstatus				AS ClaValorEstatusEstimacion,
			TE5.IdEntSal					AS IdEntSalEstimacion
	FROM	OpeSch.OpeTraPlanCargaRemisionEstimacion T1 WITH(NOLOCK)
			--Embarque Venta Remisión
	INNER JOIN	OpeSch.OpeTraBoleta TV2 WITH(NOLOCK)
		ON	T1.ClaUbicacionVenta = TV2.ClaUbicacion 
		AND T1.IdBoletaVenta = TV2.IdBoleta 
	INNER JOIN	OpeSch.OpeTraPlanCarga TV3 WITH(NOLOCK)
		ON	T1.ClaUbicacionVenta = TV3.ClaUbicacion 
		AND T1.IdPlanCargaVenta = TV3.IdPlanCarga
	INNER JOIN	OpeSch.OpeTraViaje TV4 WITH(NOLOCK)
		ON	T1.ClaUbicacionVenta = TV4.ClaUbicacion 
		AND T1.IdViajeVenta = TV4.IdViaje
	INNER JOIN	OpeSch.OpeTraMovEntSal TV5 WITH(NOLOCK)
		ON	T1.ClaUbicacionVenta = TV5.ClaUbicacion 
		AND T1.IdBoletaVenta = TV5.IdBoleta
		AND T1.IdViajeVenta = TV5.IdViaje
			--Embarque Estimacion Traspaso
	INNER JOIN	OpeSch.OpeTraBoletaHis TE2 WITH(NOLOCK)
		ON	T1.ClaUbicacionEstimacion = TE2.ClaUbicacion 
		AND T1.IdBoletaEstimacion = TE2.IdBoleta 
	INNER JOIN	OpeSch.OpeTraPlanCarga TE3 WITH(NOLOCK)
		ON	T1.ClaUbicacionEstimacion = TE3.ClaUbicacion 
		AND T1.IdPlanCargaEstimacion = TE3.IdPlanCarga
	INNER JOIN	OpeSch.OpeTraViaje TE4 WITH(NOLOCK)
		ON	T1.ClaUbicacionEstimacion = TE4.ClaUbicacion 
		AND T1.IdViajeEstimacion = TE4.IdViaje
	INNER JOIN	OpeSch.OpeTraMovEntSal TE5 WITH(NOLOCK)	
		ON	T1.ClaUbicacionEstimacion = TE5.ClaUbicacion 
		AND T1.IdBoletaEstimacion = TE5.IdBoleta
		AND T1.IdViajeEstimacion = TE5.IdViaje


GO
CREATE VIEW OpeSch.OpeRelacionEmbarqueDetVw
AS
	SELECT	T1.PlantaVirtual,
			T1.IdBoletaVenta,
			T1.ClaMotivoEntradaVenta,
			T1.PlacaVenta,
			T1.ClaEstatusPlacaVenta,
			T1.IdPlanCargaVenta,
			T1.ClaEstatusPlanCargaVenta,
			T1.ClaTransporteVenta,
			T1.IdViajeVenta,
			T1.ClaEstatusViajeVenta,
			T1.FechaViajeVenta,
			T1.ClaPaisVenta,
			T1.TipoViajeVenta,
			T1.TipoTabularVenta,
			T1.NumTabularVenta,
			T1.ClaTransportistaVenta,
			T1.IdMovEntSalVenta,
			T1.FabricacionVenta,
			T1.ClaValorEstatusVenta,
			T1.FacturaVenta,
			T1.FacturaAlfanumericoVenta,
			TV2.ClaArticulo					AS ClaArticuloVenta,
			TV2.CantEmbarcada				AS CantEmbarcadoVenta,
			TV2.PesoEmbarcado				AS PesoEmbarcadoVenta,
			T1.PlantaEstimacion,
			T1.IdBoletaEstimacion,
			T1.ClaMotivoEntradaEstimacion,
			T1.PlacaEstimacion,
			T1.ClaEstatusPlacaEstimacion,
			T1.IdPlanCargaEstimacion,
			T1.ClaEstatusPlanCargaEstimacion,
			T1.ClaTransporteEstimacion,
			T1.IdViajeEstimacion,
			T1.ClaEstatusViajeEstimacion,
			T1.FechaViajeEstimacion,
			T1.ClaPaisEstimacion,
			T1.TipoViajeEstimacion,
			T1.TipoTabularEstimacion,
			T1.NumTabularEstimacion,
			T1.ClaTransportistaEstimacion,
			T1.IdMovEntSalEstimacion,
			T1.FabricacionEstimacion,
			T1.ClaValorEstatusEstimacion,
			T1.IdEntSalEstimacion,
			TE2.ClaArticulo					AS ClaArticuloEstimacion,
			TE2.CantEmbarcada				AS CantEmbarcadoEstimacion,
			TE2.PesoEmbarcado				AS PesoEmbarcadoEstimacion,
			TE3.OrdenAcomodo				AS OrdenAcomodoEstimacion,
			TE3.CantEmbarcar				AS CantEmbarcarPCEstimacion,
			TE3.CantEmbarcada				AS CantEmbarcadaPCEstimacion
	FROM	OpeSch.OpeRelacionEmbarqueEncVw T1
			--Embarque Venta Remisión
	INNER JOIN	OpeSch.OPETraMovEntSalDet TV2 WITH(NOLOCK)	-- ClaUbicacion, IdMovEntSal, ClaArticulo, IdEntSalDet
		ON	T1.PlantaVirtual = TV2.ClaUbicacion 
		AND	T1.IdMovEntSalVenta = TV2.IdMovEntSal
		AND T1.FabricacionVenta = TV2.IdFabricacion
			--Embarque Estimacion Traspaso
	INNER JOIN	OpeSch.OPETraMovEntSalDet TE2 WITH(NOLOCK)
		ON	T1.PlantaEstimacion = TE2.ClaUbicacion 
		AND	T1.IdMovEntSalEstimacion = TE2.IdMovEntSal
		AND TV2.ClaArticulo = TE2.ClaArticulo 
		AND T1.FabricacionEstimacion = TE2.IdFabricacion
	INNER JOIN	OpeSch.OpeTraPlanCargaDet TE3 WITH(NOLOCK)
		ON	T1.PlantaEstimacion = TE3.ClaUbicacion 
		AND T1.IdPlanCargaEstimacion = TE3.IdPlanCarga
		AND T1.FabricacionEstimacion = TE3.IdFabricacion
		AND TV2.ClaArticulo = TE3.ClaArticulo

GO
CREATE VIEW  OpeSch.OpeRelEmbarqueEstimacionVw2
AS
SELECT	T1.PlantaAgrupador,
		T1.ClienteProyectoAgp,
		T1.ProyectoAgrupador,
		T1.FabricacionAgrupador,
		T1.RenglonAgrupador,
		T1.ClaArticulo,
		T1.ClaveArticulo,
		T1.NomArticulo,
		T1.PesoTeoricoKgs,
		T1.PrecioListaAgrupador,
		T1.PlantaVirtualAgrupador,
		T1.FabricacionVenta,
		T1.RenglonVenta,
		T1.PrecioListaVenta,
		T2.IdBoletaVenta,
		T2.ClaMotivoEntradaVenta,
		T2.PlacaVenta,
		T2.ClaEstatusPlacaVenta,
		T2.IdPlanCargaVenta,
		T2.ClaEstatusPlanCargaVenta,
		T2.ClaTransporteVenta,
		T2.IdViajeVenta,
		T2.ClaEstatusViajeVenta,
		T2.FechaViajeVenta,
		T2.ClaPaisVenta,
		T2.TipoViajeVenta,
		T2.TipoTabularVenta,
		T2.NumTabularVenta,
		T2.ClaTransportistaVenta,
		T2.IdMovEntSalVenta,
		T2.ClaValorEstatusVenta,
		T2.FacturaVenta,
		T2.FacturaAlfanumericoVenta,
		T2.CantEmbarcadoVenta,
		T2.PesoEmbarcadoVenta,
		T1.PlantaEstimacion,
		T1.FabricacionEstimacion,
		T1.RenglonEstimacion,
		T2.IdBoletaEstimacion,
		T2.ClaMotivoEntradaEstimacion,
		T2.PlacaEstimacion,
		T2.ClaEstatusPlacaEstimacion,
		T2.IdPlanCargaEstimacion,
		T2.ClaEstatusPlanCargaEstimacion,
		T2.ClaTransporteEstimacion,
		T2.OrdenAcomodoEstimacion,
		T2.CantEmbarcarPCEstimacion,
		T2.CantEmbarcadaPCEstimacion,
		T2.IdViajeEstimacion,
		T2.ClaEstatusViajeEstimacion,
		T2.FechaViajeEstimacion,
		T2.ClaPaisEstimacion,
		T2.TipoViajeEstimacion,
		T2.TipoTabularEstimacion,
		T2.NumTabularEstimacion,
		T2.ClaTransportistaEstimacion,
		T2.IdMovEntSalEstimacion,
		T2.ClaValorEstatusEstimacion,
		T2.IdEntSalEstimacion,
		T2.CantEmbarcadoEstimacion,
		T2.PesoEmbarcadoEstimacion
FROM	OpeSch.OpeRelDetalleFabricacionEstimacionVw T1 WITH(NOLOCK)
INNER JOIN OpeSch.OpeRelacionEmbarqueDetVw T2
	ON	T1.PlantaVirtualAgrupador	= T2.PlantaVirtual
	AND	T1.FabricacionVenta			= T2.FabricacionVenta
	AND	T1.PlantaEstimacion			= T2.PlantaEstimacion
	AND	T1.FabricacionEstimacion	= T2.FabricacionEstimacion
	AND T1.ClaArticulo				= T2.ClaArticuloVenta
	AND T1.ClaArticulo				= T2.ClaArticuloEstimacion

UNION

SELECT	
		PlantaAgrupador				= T2.ClaPlanta,
		ClienteProyectoAgp			= T10.ClaClienteCuenta,
		ProyectoAgrupador			= T9.ClaProyecto,
		FabricacionAgrupador		= T2.IdFabricacion,
		RenglonAgrupador			= T3.IdFabricacionDet,
		ClaArticulo					= T3.ClaArticulo,
		ClaveArticulo				= T11.ClaveArticulo,
		NomArticulo					= T11.NomArticulo,
		PesoTeoricoKgs				= T11.PesoTeoricoKgs,
		PrecioListaAgrupador		= T3.PrecioLista,
		PlantaVirtualAgrupador		= T4.ClaPlanta,
		FabricacionVenta			= T4.IdFabricacion,
		RenglonVenta				= T5.IdFabricacionDet,
		PrecioListaVenta			= T5.PrecioLista,
		T1.IdBoletaVenta,
		T1.ClaMotivoEntradaVenta,
		T1.PlacaVenta,
		T1.ClaEstatusPlacaVenta,
		T1.IdPlanCargaVenta,
		T1.ClaEstatusPlanCargaVenta,
		T1.ClaTransporteVenta,
		T1.IdViajeVenta,
		T1.ClaEstatusViajeVenta,
		T1.FechaViajeVenta,
		T1.ClaPaisVenta,
		T1.TipoViajeVenta,
		T1.TipoTabularVenta,
		T1.NumTabularVenta,
		T1.ClaTransportistaVenta,
		T1.IdMovEntSalVenta,
		T1.ClaValorEstatusVenta,
		T1.FacturaVenta,
		T1.FacturaAlfanumericoVenta,
		T1.CantEmbarcadoVenta,
		T1.PesoEmbarcadoVenta,
		PlantaEstimacion			= T6.ClaPlanta,
		FabricacionEstimacion		= T6.IdFabricacion,
		RenglonEstimacion			= T7.IdFabricacionDet,
		T1.IdBoletaEstimacion,
		T1.ClaMotivoEntradaEstimacion,
		T1.PlacaEstimacion,
		T1.ClaEstatusPlacaEstimacion,
		T1.IdPlanCargaEstimacion,
		T1.ClaEstatusPlanCargaEstimacion,
		T1.ClaTransporteEstimacion,
		T1.OrdenAcomodoEstimacion,
		T1.CantEmbarcarPCEstimacion,
		T1.CantEmbarcadaPCEstimacion,
		T1.IdViajeEstimacion,
		T1.ClaEstatusViajeEstimacion,
		T1.FechaViajeEstimacion,
		T1.ClaPaisEstimacion,
		T1.TipoViajeEstimacion,
		T1.TipoTabularEstimacion,
		T1.NumTabularEstimacion,
		T1.ClaTransportistaEstimacion,
		T1.IdMovEntSalEstimacion,
		T1.ClaValorEstatusEstimacion,
		T1.IdEntSalEstimacion,
		T1.CantEmbarcadoEstimacion,
		T1.PesoEmbarcadoEstimacion
FROM	OpeSch.OpeRelacionEmbarqueDetVw T1
INNER JOIN	OpeSch.OpeTraFabricacionVw T2 WITH(NOLOCK)
	ON	T2.IdFabricacion				= (	SELECT	FA.IdFabricacionAgrupado
											FROM	OpeSch.OpeBitFabricacionEstimacion FA
											WHERE	FA.IdFabricacionEstimacion = T1.FabricacionEstimacion)
INNER JOIN	OpeSch.OpeTraFabricacionDetVw T3 WITH(NOLOCK)
	ON	T2.IdFabricacion				= T3.IdFabricacion
	AND T1.ClaArticuloVenta				= T3.ClaArticulo
INNER JOIN	OpeSch.OpeTraFabricacionVw T4 WITH(NOLOCK)
	ON	T1.FabricacionVenta				= T4.IdFabricacion
INNER JOIN	OpeSch.OpeTraFabricacionDetVw T5 WITH(NOLOCK)
	ON	T4.IdFabricacion				= T5.IdFabricacion
	AND	T1.ClaArticuloVenta				= T5.ClaArticulo
INNER JOIN	OpeSch.OpeTraFabricacionVw T6 WITH(NOLOCK)
	ON	T1.FabricacionEstimacion		= T6.IdFabricacion
INNER JOIN	OpeSch.OpeTraFabricacionDetVw T7 WITH(NOLOCK)
	ON	T6.IdFabricacion				= T7.IdFabricacion
	AND	T1.ClaArticuloEstimacion		= T7.ClaArticulo
INNER JOIN	OpeSch.OpeVtaRelFabricacionProyectoVw T8 WITH(NOLOCK)
	ON	T2.IdFabricacion				= T8.IdFabricacion
INNER JOIN	OpeSch.OpeVtaCatProyectoVw T9 WITH(NOLOCK)
	ON	T8.ClaProyecto					= T9.ClaProyecto
INNER JOIN	OpeSch.OpeVtaCatClienteCuentaVw T10 WITH(NOLOCK)
	ON	T9.ClaClienteCuenta				= T10.ClaClienteCuenta
INNER JOIN	OpeSch.OpeArtCatArticuloVw T11 WITH(NOLOCK)
	ON	T1.ClaArticuloVenta				= T11.ClaArticulo
	AND	T11.ClaTipoInventario			= 1
WHERE	FacturaAlfanumericoVenta IN ('QS1419', 'QS1421', 'QS1403', 'QS1417')
