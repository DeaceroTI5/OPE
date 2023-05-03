USE Operacion
GO

EXEC sp_stored_procedures '%OPE%CU550_Pag30%Grid%GridColada%'

EXEC SP_HELPTEXT 'OpeSch.OPE_CU550_Pag30_Grid_PlanCargaEnc_Sel'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU550_Pag30_Grid_ShippingTicketInfo_Sel'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU550_Pag30_Grid_PlanillaDet_Sel'

OpeSch.OPEASAShippingTicketHeatData
OpeSch.OPEASAShippingTicket
OpeSch.OPEASAShippingTicketDet

SELECT * FROM opeSch.AceColadaEmbarcadaIngetekVw


'%%Horno%Cmb%'

'OpeSch.OPECatHornoVw'
OPMSch.PloCatHornoVw

 FROM OpcSch.OpcCatHorno WITH(NOLOCK)  

'%Molino%%'
		
	--'%OPE%Estatus%'

	SELECT * FROM OpeSch.OpeTiCatEstatusPlanCargaVw WHERE ClaEstatus 

	SELECT
		t1.IdPlanCarga,
		t2.IdViaje,
		t1.IdBoleta,
		t1.PesoRealEmbarcado AS TonEmbarcadas,
		t2.FechaViaje
	FROM OpeSch.OpeTraPlanCarga t1 WITH(NOLOCK)
		LEFT JOIN opeSch.OpeTraViaje t2 WITH(NOLOCK)
		ON t2.ClaUbicacion = t1.ClaUbicacion
		AND t2.IdPlanCarga = t1.IdPlanCarga
	WHERE t1.ClaUbicacion = 325
	AND	t1.ClaEstatusPlanCarga IN (2,3)
	AND (( t1.IdPlanCarga = 2935
	OR  t2.IdViaje = 2574))


	SELECT a.WarehouseName, a.ShipID, a.ShipDate, a.ShipStatusDescr, a.JobID, a.JobName, a.CustomerID, a.CustomerName, a.ShipWeight, a.LoadID, a.ShipID AS ShippingTicket
	FROM OpeSch.OpeRelViajeShipID b
			INNER JOIN opesch.OPEASAShippingTicket a
			ON b.ShipID = a.ShipID
	WHERE b.ClaUbicacion = 325 
	AND b.IdViaje = 2574

	SELECT  											
		c.[Order], c.ControlCode, c.[Status], 												
		c.Product, c.ProductDescr, c.Diameter, c.Grade, c.Texture, c.Material, c.Coating, 												
		c.TotalItems, c.TotalPieces, c.TotalKgs, 												
		c.StraightItems, c.StraightPieces, c.StraightKgs,												
		c.BentItems, c.BentPieces, c.BentKgs
	FROM opesch.OPEASAControlCodeSummary c													
		INNER JOIN opesch.OPEASAShippingTicketDet b										
		on c.[order] = b.orderID													
		and c.ControlCode = b.CtrlCode													
		and c.Product = b.Product			
	WHERE	b.ShipID = 'REM-07040'


	'opeSch.AceColadaEmbarcadaIngetekVw'

	USE TiCatalogo
	GO

	ticatalogo.dbo.AceColadaEmbarcadaIngetekVw
	'dbo.AceColadaEmbarcadaIngetekVw'
 Select * from dbo.AceColadaEmbarcadaIngetek with(nolock)


	SELECT DISTINCT
			  Num_viaje
			, Cla_Planta
			, Cla_horno_fusion
			, Cla_Molino, *
	FROM	opeSch.AceColadaEmbarcadaIngetekVw 
	WHERE	Cla_planta IN (1,2,3)

	SELECT * FROM OpeSch.OpeTiCatUbicacionVw

	SELECT * FROM OPESch.OpeTiCatConfiguracionVw WHERE ClaSistema = 127 AND ClaConfiguracion >= 1271210